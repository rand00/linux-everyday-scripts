(*
    Pok - open pdf's or directories of pdf's in Okular.
    Copyright (C) 2014 Claes Worm

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

open Batteries

let quote_string s = 
  let q = "\"" in String.concat "" [ q; s; q ]

let ext file = String.(
  let _,ext = (try rsplit ~by:"." file with _ -> ("",""))
  in lowercase ext)

let is_existingdir dir = Sys.(
  file_exists dir && is_directory dir)

let print_msg ss =
  let sss = List.map Re_str.(split (regexp "[\r\n\t ]")) ss in
  let open Format in
  print_string "Pok: ";
  open_box 0;
  List.iter (fun ss' ->
      List.iter (fun s' ->
          print_string s';
          print_space ();
        ) ss';
      force_newline ();
    ) sss;
  close_box ()
    

let rec open_pdfs ?(first_run=true) = function
  | [] -> ()
  | pdfs -> 
    Unix.run_and_read
      (String.concat " " 
         (List.flatten 
            [[ "okular" ]; 
             List.map quote_string pdfs;
             [ "2>/dev/null &" ]]))
    |> function
    | Unix.WEXITED 0, _ -> ()
    | _, err_str ->
      let okular_resp_contains_fix = 
        Re_str.(split (regexp "\n") err_str)
        |> List.exists (fun line ->
            Re_str.(string_match (regexp ".*export \\$(dbus-launch).*") line 0)
          )
      in
      if okular_resp_contains_fix then 
        begin
          if first_run then begin
            print_msg [
              "Pok: Okular terminated unsuccesfully but we will try to correct the \
               environment with 'export $(dbus-launch)'..."
            ];
            ignore @@ Sys.command "export $(dbus-launch)";
            open_pdfs ~first_run:false pdfs
          end else
            print_msg [
              "Pok: No luck this time either - Okular didn't run on second try."
            ]
        end
      else
        print_msg [
          "Pok: Okular terminated unsuccesfully, and we were not able to fix \
           the error. The message from Okular was:";
          "--------------------------------------------------------";
          err_str
        ]


let find_pdfs dir = 
  Sys.files_of dir //@ (fun file ->
    match ext file = "pdf" with
      | true  -> Some (dir ^ "/" ^ file)
      | false -> None)
  |> List.of_enum
  |> function
      | [] -> 
        print_msg [
          Printf.sprintf
            "No pdf's where present in the supplied directory, '%s'."
            dir
        ]; 
        [] 
      | l -> l

let pok () = 
  match peek (args ()) with 
  | Some (<:re< "-"* "help">>) -> 
    print_msg [
      "Usage: Supply a mixed list of pdf-files or directories \
       containing pdf-files as arguments. Pok will open them all in \
       the Okular pdf-viewer."
    ]
  | Some _ ->
    let args = args () |> List.of_enum in
    open_pdfs
      (List.
         (flatten
            (map
               (fun arg -> 
                  match is_existingdir arg with
                  | true  -> find_pdfs arg
                  | false -> [ arg ]
               ) args )))
  | None -> 
    open_pdfs (find_pdfs (Sys.getcwd ()))
    


let () = pok ()      

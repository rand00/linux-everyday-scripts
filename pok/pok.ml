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
    | _, str ->
      Re_str.(split (regexp "\n") str)
      |> List.exists (fun line ->
          Re_str.(string_match (regexp ".*export \\$(dbus-launch).*") line 0)
        )
      |> function
      | false ->
        print_msg [
          "Pok: Ocular terminated unsuccesfully, and we were not able to fix \
           the error. The message from Ocular was:";
          "--------------------------------------------------------";
          str
        ]
      | true ->
        begin
          if first_run then begin
            print_msg [
              "Pok: Ocular terminated unsuccesfully but we will try to correct the \
               environment with 'export $(dbus-launch)'..."
            ];
            Sys.command "export $(dbus-launch)" |> ignore;
            open_pdfs ~first_run:false pdfs
          end
          else
            print_msg [ "Pok: No luck this time either - Ocular didn't run on \
                         second try."]
        end

let find_pdfs dir = 
  Sys.files_of dir //@ (fun file ->
    match ext file = "pdf" with
      | true  -> Some (dir ^ "/" ^ file)
      | false -> None)
  |> List.of_enum
  |> function
      | [] -> 
        let _ = print_endline 
          (String.concat "" 
             [ "No pdf's where present in the supplied directory, '";
               dir; "'." ]) 
        in [] 
      | l -> l

let pok () = 
  match peek (args ()) with 
  | Some (<:re< "-"* "help">>) -> 
    print_endline 
      (String.concat ""
         [ "Pok usage // Supply a mixed list of pdf-files or directories ";
           "containing pdf-files as arguments. Pok will open them all in ";
           "the Okular pdf-viewer." ])
  | Some _ -> 
    open_pdfs
      (List.( flatten ( map (fun arg -> 
        match is_existingdir arg with
          | false -> [ arg ]
          | true  -> find_pdfs arg
       ) (args () |> List.of_enum ))))
  (*< goto write with pipes*)
  | None -> 
    open_pdfs (find_pdfs (Sys.getcwd ()))
    


let () = pok ()      

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

(*
let sleep_millis i =
  let diff = (Float.of_int i) /. 1000. 
  and start = Unix.gettimeofday () in
  while start +. diff < Unix.gettimeofday () do
*)
   
let tmp_okular_resp_file = ref "/tmp/pok_oku_resp"
let tmp_okular_done = ref "/tmp/pok_oku_done"
let tmp_tail = ref ""

let rec open_pdfs ?(first_run=true) = function
  | [] -> ()
  | (pdf1::_) as pdfs ->
    if first_run then
      begin      
        tmp_tail :=
          (Digest.string
             ((Float.to_string @@ Unix.gettimeofday ()) ^ pdf1)
           |> Digest.to_hex);
        tmp_okular_resp_file := !tmp_okular_resp_file ^ !tmp_tail;
        tmp_okular_done := !tmp_okular_done ^ !tmp_tail;
        at_exit
          (fun () ->
             List.iter (fun f ->
                 if Sys.file_exists f then ignore @@ Sys.command ("rm "^f)
               ) [ !tmp_okular_done; !tmp_okular_resp_file; ]
          )
      end;
    ignore @@
    (Sys.command
       (String.concat " " 
          (List.flatten [
              [ "(okular" ]; 
              List.map quote_string pdfs;
              [ "1>&2 2>"^ !tmp_okular_resp_file];
              ["; touch "^ !tmp_okular_done];
              [") &" ]
            ])));
    let times = ref 0 in
    while not (Sys.file_exists !tmp_okular_done || !times > 1) do
      (*goto - have finer timing-window; some kind of millis for finetuning - c binding?
        > nanoseconds : http://stackoverflow.com/questions/1157209/is-there-an-alternative-sleep-function-in-c-to-milliseconds
      *)
      incr times;
      Unix.sleep 1;
    done;
    if Sys.(file_exists !tmp_okular_done && file_exists !tmp_okular_resp_file) then
      let okular_resp_str = IO.read_all (open_in !tmp_okular_resp_file) in
      let okular_resp_contains_fix = 
        Re_str.(split (regexp "\n") okular_resp_str)
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
          okular_resp_str
        ]
    else exit 0 (*We think Okular is running succesfully*)


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
  | Some arg when Re_str.(string_match (regexp "-+h\\(elp\\)?") arg 0) -> 
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

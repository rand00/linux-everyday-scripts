
open Batteries

let ext file = String.(
  let _,ext = (try rsplit ~by:"." file with _ -> ("",""))
  in lowercase ext)

let is_existingdir dir = Sys.(
  file_exists dir && is_directory dir)

let open_pdfs = function
  | [] -> ()
  | pdfs -> 
    Sys.command 
      (String.concat " " 
         (List.flatten 
            [[ "okular" ]; pdfs;
             [ "2>/dev/null 1>/dev/null &" ]]))
    |> ignore (*Okular handles the errors*)

let find_pdfs dir = 
  Sys.files_of dir //@ (fun file ->
    match ext file = "pdf" with
      | true  -> Some (dir ^ file)
      | false -> None)
  |> List.of_enum

let pok () = 
  match peek (args ()) with 
  | Some (<:re< "-"* "help">>) -> 
    print_endline 
      (String.concat ""
         [ "Pok usage // Supply a mixed list of pdf-files or directories ";
           "containing pdf-files as arguments. Pok will open them all in ";
           "the Okular pdf-viewer." ])
  | _ -> 
    open_pdfs
      (List.( flatten ( map (fun arg -> 
        match is_existingdir arg with
          | false -> [ arg ]
          | true  -> find_pdfs arg
       ) (args () |> List.of_enum ))))


let () = pok ()      

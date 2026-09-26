;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;       Developed by Rustin Gesner, Joseph Smith, and Patrick Haessly       
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
;;;* GPATH.LSP
;;;* GPATH takes a path name and a file name. It returns the joined filespec.
;;;* If the PATH argument is nil or "", it returns the filename unaltered.
;;;* You can feed it one of the #NAME path variables defined below, or an
;;;* explicit path name in the form "/name/".
;;;*
(defun gpath (path file)
  (if path                ;If the path is not nil
    (strcat path file)    ;Combine with the file name
    file                  ;Else just return the file name
  );if
);defun

;;;* Initialize #NAME path variables.
(setq #dwg "/IL/")   ;hard-codes the drawing path variable

;;;* LAMBDA is used to initialize a set of paths. The function below sets 
;;;* each #NAME path to the value returned by GETENV for NAME. 
;;;* Use SET #NAME=\path to set environment variables. If GETENV
;;;* returns nil, the #NAME is set to the corresponding DEF default.
;;;* It appends an / to return the format "/name/".
;;;*
(mapcar '(lambda (path def)  ;Map lambda to each set of path and def args
           (set (read path)  ;Convert path arg to symbol and set to...
             (if (setq path (getenv path))  ;If env. var. path set 
               (strcat path "/")            ;Then use it, adding /
               def                          ;Else use default
           ) )
         );lambda
        '("#lsp"      "#blk"      "#mnu"      "#shx"   )   ;PATH arguments
        '("/IL/"      "/IL/"      "/IL/"      "/ACAD/" )   ;DEF arguments 
);mapcar
;;;*end of GPATH.LSP

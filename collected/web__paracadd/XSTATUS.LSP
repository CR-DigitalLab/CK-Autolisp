;;;   XSTATUS.lsp
;;;   Copyright (C) 1991, 1992 by Autodesk, Inc.
;;;
;;;   Permission to use, copy, modify, and distribute this software and its
;;;   documentation for any purpose and without fee is hereby granted.
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY.
;;;   ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR PURPOSE AND OF
;;;   MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;
;;;   by Carl Bethea
;;;   9 September 1991
;;;
;;;   Revised: 17 Mar 92  CBB
;;;   Revised: 18 May 92  CBB
;;;
;;; * No error function defined. *
;;;--------------------------------------------------------------------------;
;;;   DESCRIPTION
;;;
;;;   This function represents the nesting of XRefs graphically.
;;;
;;;   XSTATUS prints a listing of the block table, indenting each name
;;;   based on the nesting level of the block.  It tries not to repeat block
;;;   names at the first level.  That is, if the block name is nested in
;;;   another block which XSTATUS has already investigated, then it won't be
;;;   listed again as an individual block, though it will show up if it is
;;;   nested again within another block.
;;;
;;;   Note: Externally dependent anonymous blocks have peculiar enames.
;;;   When an attempt is made to access the block def in the nested block,
;;;   ENTGET will fail. You will notice a period "." printed after a
;;;   anonymous block name indicating that TBLSEARCH failed.  Don't try
;;;   to access these block names through TBLSEARCH.
;;;
;;;
;;;--- c:xstatus --------------------------------------------
;;;    print block names, indented for each level of nesting
;;;
(defun c:xstatus (/ i data bname blist level dxf show page ferret fh df nopage)

   ;; return the value of group <x>
   ;;
   (defun dxf (x)(cdr (assoc x data)))

   (if (not nopage)

      ;; pause after 20 lines
      (defun page ()
         (if (< i 20)
            (setq i (1+ i))
            (setq i (getstring "more ...")
                i 0
            )
         )
            (princ "\r")
      )

      (defun page () nil)
   )

   (defun show (bname level)
      (terpri)
      (page)
      (if (not (minusp level))
         (princ "        ")          ; tab for clarity
      )
      (repeat level                  ; foreach nesting level
        (princ "    ")               ; TAB (4) right
      )
      (princ bname)
      i
   );show


   (initget "Yes No")
   (cond
      ((and
         (= "Yes"  (getkword "\nSave XREF status to a file Yes/<No>: "))
         (setq df (strcat (getvar "dwgprefix") (getvar "dwgname") ".xrf"))
         (if (or (= "" (setq fh (getstring (strcat "\nFilename <" df ">:
"))))
                 (null fh)
             )
             (setq fh df)
             (setq df fh)
         )
         (setq fh (open fh "a"))
       )

         ;; revise show function to print to file
         (setq show
            (append
               (list
                  (car show)               ; arg list
                 '(if (not (minusp level))
                      (princ "        " fh); tab for clarity
                  )
                 '(repeat level            ; foreach nesting level
                      (princ "    " fh)    ; TAB (4) right
                  )
                 '(princ bname fh)
                 '(princ "\n" fh)
               )
               (cdr show)
            )
         )
      )
      (T  (princ "No file opened."))
   )


   ;; if the block contains an INSERT,
   ;; then check for further nesting
   ;;
   (defun ferret (ent level / bname mark data blist)

      (while
         (and
            ent
            (setq data (entget ent))
            (/= "ENDBLK" (dxf 0))
         )
         (if (and
                ;; it's a block insert
                (= "INSERT" (dxf 0))

                ;; get the name
                (setq bname (dxf 2))

                ;; not multiple inserts of the same block
                (if (not (member bname blist))
                   (setq blist (cons bname blist))
                )

                (if (dxf -1) ; save the ename of the INSERT
                    (setq mark (dxf -1))
                    (prompt " ... not a valid ename.")
                )


                ;; get the block def
                (if (tblsearch "BLOCK" bname)
                    (setq data (tblsearch "BLOCK" bname))
                    (prompt ".")   ; ... tblsearch failed")
                )

                ;; print the block or XREF name
                (show
                   (if (dxf 1)
                      (strcat "|" (dxf 1))
                      bname
                   )
                   level
                )

                ;; get the ename of the first entity in the block
                (setq ent (dxf -2))

             );and

             ;; check the block def for nested INSERTs
             (setq level (1+ level)
                     ent (ferret ent level)
                   level (1- level)
             )
         );if

         ;; get the next entity in the BLOCK def
         (if (dxf -1); valid ename
             (setq ent (entnext (dxf -1)))
             (setq ent (entnext mark))
         );
      );while

   );ferret

   ;; start working
   (terpri)
   (setq i 0)
   (show
      (strcat
         (getvar "dwgprefix") (getvar "dwgname")
         "    " (rtos (getvar "cdate") 2 4)
      )
      -1
   )
   (setq data (tblnext "block" T))
   (while data
        (setq bname (dxf 2))
        (if (not (wcmatch bname "*|*"))
           (progn
                ;; print the block or XREF name
                (show
                   (if (dxf 1)
                      (strcat "|" (dxf 1))
                      bname
                   )
                   0
                )
                (ferret (dxf -2) 1)
            )
        )
      (setq data (tblnext "block"))
   );while
   (if fh (close fh))
   (princ)
)
;;;   To disable the pause for each page of the listing ...
;;;
(initget "Yes No")
(if (= "No" (getkword "\nPause for each page <Yes>/No: "))
    (progn
       (setq c:xstatus
          (cons
             (car c:xstatus)
             (cons  '(setq nopage T)
                (cdr c:xstatus)
             )
          )
       )
       (princ "Page pause OFF.")
    )
    (princ "Page pause ON.")
)
(terpri)
(terpri)
(princ "Command: XSTATUS to list the XREF chains")
(princ)
;;;
;;;--- end of file -----------------------------------------
          
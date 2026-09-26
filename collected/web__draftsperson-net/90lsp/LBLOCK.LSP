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
(if (not (and dxf ukword ustr))                         ;Test subroutines
  (prompt "\nRequires DXF UKWORD and USTR functions. Load aborted. ")    
  (progn                                                ;Else load OK

;;;* C:LBLOCK updates a Library of BLOCKS. It is executed from within 
;;;* a master "block library" drawing. It Wblocks out all defined Blocks 
;;;* to a designated directory. It optionally creates an UPDBLK.LSP file 
;;;* and UPDBLK.SCR file which combine to perform a batch insertion of
;;;* all blocks into a designated list of drawing files. If so, defined
;;;* blocks within each drawing file are updated. However, no additional
;;;* library "blocks" are added to a drawing where they were not
;;;* previously defined.
;;;*
;;;* UPDBLK.LSP and UPDBLK.SCR are saved in the block library directory,
;;;* along with the Wblocked drawings. 
;;;*
;;;* Required functions are DXF, the user GET functions, FILELIB.LSP
;;;* and BATCHSCR.LSP.
;;;*

;;Ensure batchscr is loaded, batchscr also loads filelib
(if getfil nil (load "batchscr"))

(defun C:LBLOCK ( / flag blkdef blist path wpath expert cmd file fun)
  (if (setq blkdef (tblnext "BLOCK" T))     ;Test for blocks in drawing
    (progn                                  
      (textpage)                            ;Flip to text screen, clear it
      (prompt (strcat "\n** NOTE: Existing .DWG files in chosen directory **"
                      "\n  ** will be overwritten if Blocknames match. **\n")
      );prompt
      (prompt "\nSpecify block library directory...")
      (setq path (vpath)                    ;Assign verified path name
            blist (list (dxf 2 blkdef))     ;Start block list
      )

      ;;loop and make list of block defs, append to block list
      (while (setq blkdef (tblnext "BLOCK"))
        (setq blist (cons (dxf 2 blkdef) blist))
      );while
      (setq expert (getvar "EXPERT")        ;Store current setting
            cmd (getvar "CMDECHO")          ;Save echo state
      );setq
      (setvar "CMDECHO" 0)                  ;Turn off echo
      (setvar "EXPERT" 3)                   ;Allow file overwrite w/o warning
      (foreach blknam blist
        ;omit anonymous blocks
        (if (or (> (strlen blknam) 8)(= "*" (substr blknam 1 1)))
          (prompt (strcat "\nBlock " blknam
                          " exceeds 8 characters or is an anonymous block. "
                  );strcat
          );prompt
          (progn                                            ;Else
            (command "WBLOCK" (strcat path blknam) blknam)  ;wblock each out
            (prompt (strcat "\nWblocking " blknam))      ;& prompt each name
      ) ) );if,progn&foreach

;;;* If you don't have a need for updating of existing blocks within a group
;;;* of drawings, you can disable or delete the entire following
;;;* IF expression:
      (if (= "Y" (ukword 1 "Y N" (strcat 
            "\nYou may create a program to update blocks in other drawings."
            "\nDo you want to do so? ") "Y"))
        (progn                              ;Yes create an UPDBLK.LSP file
          (setq file (open (strcat path "updblk.lsp") "w")
                wpath (slash path)          ;Forces foward slash
          )
          (write-line "(setq blist '(" file);Write list of blocks
          (foreach blkdef blist             ;Loop for each block name
            (print blkdef file)             ;Print each, quoted 1 per line
          );foreach

          ;;write out path name
          (write-line (strcat ") path \"" wpath "\" )" ) file)

          ;;make a list for the output file, set regen auto off
          ;;then loop through each block and check for block in
          ;;the block table. If it exists, insert the file
          (setq fun '((setq regen (getvar "REGENMODE"))
                      (setvar "REGENMODE" 0)
                      (foreach blkdef blist
                        (if (tblsearch "BLOCK" blkdef)
                           (command "_.INSERT" (strcat blkdef "=" path blkdef)
                             (not (setq flag T))  ;Set save flag to true
                           );command   
                           (setq flag nil)  ;Block not in drawing -- set flag
                        );if
                      );foreach
                      (setvar "REGENMODE" regen)     ;Reset regenauto
                      (if flag (command "_.SAVE" ""));If flag T save drawing
                      (command "_.RESUME")           ;Resume the script
                     );end list of expressions to write out
           );setq
           (foreach expr fun                ;Write each expr to file
             (print expr file)
           );foreach
           (close file)                     ;Done writing updblk.lsp
           (updscr wpath)                   ;Make update script UPDBLK.SCR
           (setvar "EXPERT" expert)         ;Reset expert mode
           (setvar "CMDECHO" cmd)           ;Reset echo
        );progn
      );if create program -- end of optional disable/delete
    );progn
    ;;else of the if blist
    (prompt "\nNo Blocks found in current drawing.\n")
  );if blocks
  (princ)
);defun C:LBLOCK
;;;*

;;;* If you disabled or deleted the above IF to update existing
;;;* blocks within a group of drawings, you can disable or delete
;;;* the entire following function:

;;;* UPDSCR generates a list of files to update using the block library.
;;;* It gets a path and drawing spec from the user and creates a batch
;;;* script using the BATCHSCR.LSP program. The BATCH.SCR file is copied
;;;* to UPDBLK.SCR.
;;;*
(defun updscr (wpath / fspec dpath)
  (prompt "\nSpecify drawings to update...")  ;Tell user type of file spec.
  ;;Get the verified path, the filespec w/ extension
  ;;Make the script line, enter drawing, load "updblk.lsp" function
  ;;no need to Save, UPDBLK Saves if updated
  (setq dpath (vpath)
        fspec (ffname (ustr 0 "Drawing names " "*" nil) "DWG")
        scrlst (list "_.OPEN Y" 'FNAME
                 (strcat "(load \"" wpath "UPDBLK\")")
               );list
  );setq

  ;;call the batch builder
  (batscr fspec dpath scrlst "_.Quit Y")

  ;;copy the file
  (command "_.FILES" "5" "BATCH.SCR"
           (strcat dpath "UPDBLK.SCR") "" ""
  );command
  (prompt (strcat "\nStart AutoCAD from OS by"    ;Instruct on use
                  "\n" (pslash "\\path\\") "ACAD X " dpath "UPDBLK")
  );prompt 
  (princ)
);defun UPDSCR
;;;*

;;;* SLASH forces "\\"s or "/"s in path strings to "/" 
;;;*
(defun slash (path / slash inc wpath char)
  (setq inc 1  wpath ""  slash  "/")              ;Initialize variables
  (while (/= "" (setq char (substr path inc 1)))  ;Test each char
    (setq wpath                                   ;Append proper char back
      (strcat wpath (if (member char '("\\" "/")) slash char))
      inc (1+ inc)                                ;Increment counter
  ) );while&setq
  wpath
);defun SLASH
;;;*

(princ)
;;;* end of LBLOCK.LSP
;;;*
));test subroutines                                                  

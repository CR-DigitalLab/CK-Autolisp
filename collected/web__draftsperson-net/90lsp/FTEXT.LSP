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
(if (not (and dxf ukword upoint uint uangle))            ;Test subroutines   
  (prompt
    "\nRequires DXF UKWORD UPOINT UINT and UANGLE functions. Load aborted. ")
  (progn                                                ;Else load OK

;;;* C:FTEXT imports an ASCII file into AutoCAD as text. It uses the default
;;;* style, either fixed or variable height.  The WW option wordwraps,
;;;* or the MT option imports unformatted as a table. MT is designed to
;;;* use a default MONOTXT.SHX font style.  If WW, it prompts for the
;;;* maximum characters per line.  Variables MAXC and ROT float for
;;;* defaults.
;;;*
(defun C:FTEXT ( / mtable file pt lftovr instr str len pos c notfixed)
  (if (setq file (open (getstring "\nEnter text source filename.ext: ") "r"))
    (progn                                               ;Then do it
      (setq mtable (ukword 1 "MT WW" "MonoTable or Word Wrap? MT/WW " "WW")
            pt (upoint 1 "" "Start point" nil nil) ;Text start point
            lftovr ""                              ;Initialize leftover string
      );setq
      (if (= mtable "MT")                          ;If mono table
        (progn                                     ;Then warn user and
          (prompt "\nLines over 132 chars will be truncated.")
          (prompt " Current font should be MONOTXT.\n")
          (setq rot 0)                             ;Hardcode rotation
        )
        (progn                                     ;Else
          (setq mtable nil                         ;Set flag nil & get format
                maxc (uint 1 "" "Maximum characters per line " maxc)
                rot (uangle 1 "" "Rotation angle " rot pt)
      ) ) );setq, progn & if mono table

      ;;Test the current text style to see if it is a fixed height
      ;;style. If it is, make the program commands skip supplying a height
      (if (= 0.0 (dxf 40 (tblsearch "STYLE" (getvar "TEXTSTYLE"))))
        (setq notfixed T)
      )

      ;;Start Text command, supply a height only if non-fixed style
      (command "_.TEXT" pt)
      (if notfixed
        (command "")  ;default to current height
      )
      ;;Add the rotation angle
      (command (angtos rot))

      ;;While loops for each line of text from the file
      (while (setq instr (read-line file))
        (cond                                ;Filter for conditions
          (mtable                            ;Enter text & start new line
            (command instr "_.TEXT" "")
          )
          ((and (= lftovr "") (= instr ""))  ;Nothing left, and blank line
            (command "" "_.TEXT" "")         ;Start a new paragraph
          )
          ((and (/= lftovr "") (= instr "")) ;Something left, and blank line
            (command lftovr "_.TEXT" ""      ;Finish string, then start
                     "" "_.TEXT" ""          ;new paragraph
            )
            (setq lftovr "")                 ;Reset leftover to nothing
          )
          (T                                 ;All other cases
            (if (= lftovr "")                ;If nothing left
              ;;Only the input string
              (setq str instr)

              ;;Else add leftover to new input
              (setq str (strcat lftovr " " instr))
            );if
            (setq len (strlen str))          ;Determine string length
            (while (> len maxc)              ;Loop while string is too long
              (setq pos maxc)                ;Set or reset position

              ;;Loop in search of characters
              (while (not 
                       (member (setq c (substr str pos 1))
                              '("" "-" " ")
                       );member
                     );not
                (setq pos (1- pos))          ;Decrement position
              );while

              ;;Pass to waiting Text command
              (command
                (substr str 1 (if (= c "-") pos (1- pos)))
                "_.TEXT" ""                  ;Then restart Text command
              );command
              (setq str (substr str (1+ pos));Chop old part of string
                    len (strlen str)         ;Get length of remainder
              );setq
            );while > len
            (setq lftovr str)                ;Save remainder as leftover
          );T
        );cond
      );while setq instr
      (command lftovr)                       ;Finish Text, might be leftover
      (close file)
    );progn
    (prompt "\nSource text file not found.\n")                  ;Else prompt
  );if
  (princ)
);defun FTEXT
;;;*
(princ)
;;;*end of FTEXT.LSP
;;;*
));test subroutines                                                  

;;;*;WARNING: ETEXT.LSP contains ; semicolons in strings - Do Not LSPSTRIP/S
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
;;;* ETEXT is a single line text editor allowing users to move the cursor
;;;* along the text and insert or delete characters as required. 
;;;* ANSI.SYS is required for program to work.
;;;* PUT THIS LINE IN CONFIG.SYS: DEVICE=C:\DOS\ANSI.SYS
;;;* (Assuming your ANSI.SYS file is in the C:\DOS directory.)

;;;* This program includes modifications by Douglas L. Jones from the original 
;;;* program developed by Rustin Gesner, Patrick Haessly and Joseph Smith

;;;* CHGERR restores the original function of the keys if the program aborts.
(defun chgerr (s)                     
  (setq *error* olderr  olderr nil)           ;Restore original error function
  (if (not (member s '("" "console break" "Function cancelled")))
    (princ (strcat "\nError: " s))
  ) 
  (setvar "BLIPMODE" blip)
  (textscr)
  (setvar "CMDECHO" cmdech)
  (prompt "\e[0;59;0;59p")                    ;Restore <F1>
  (graphscr)
  (if (/= "" s)
      (foreach s '(entity txt test txtlen curpos key blip cmdech) (set s nil))
  )
  (princ)
);defun chgerr

(defun C:ETEXT (/ entity txt test txtlen curpos key)
  (setq olderr *error*                        ;Initialize variables
        *error* chgerr
        key 0                                 ;Zero out key
        cmdech (getvar "CMDECHO")
        blip   (getvar "BLIPMODE")
  )
  (setvar "CMDECHO" 0)                        ;Turn echo off
  (setvar "BLIPMODE" 0)                       ;Turn blips off
  (setq entity                                ;Gets edata
        (entget (car (while (not entity)      ;While ensures entity selection
                            (setq entity (entsel "\nPick text to edit: ")
  )     )       )    )      )
  (if (= "TEXT" (setq test (cdr (assoc 0 entity)))) ;Test if text was selected
    (progn                                 ;Then 
      (setq txt (cdr (assoc 1 entity))     ;Get text string
            txtlen (1+ (strlen txt))       ;Get text length
            curpos 1                       ;Initial cursor position=length
      )
      (textscr)                            ;Go to text screen
      (prompt "\e[0;59;0;3p")              ;Change <F1> to nul
      (prompt "\e[2J")                     ;Clear screen and place header
      (prompt (strcat "\e[7;1;37;44m"
                      "                           "
                      "Inside AutoLISP Line Editor"
                      "                           "
      )       )
      (prompt (strcat "\e[2;1H  "
                      "                                       "
                      "                                       "
      )       )
      (prompt (strcat "\e[3;1H"
                      "        use  <LEFT>  <RIGHT>  <DEL>  "
                      "<BACKSPACE>  or type to insert text        "
      )       )
      (prompt "\e[0;37;40m")               ;Sets ANSI screen to normal
      (prompt "\e[8;1HEdit text:")         ;Print title
      (prompt "\e[1m")                     ;Bold
      (prompt "\e[m")                      ;Normal
      (prompt (strcat "\e[10;1H" txt))
      (prompt "\r")
      (while (/= key 13)                   ;While key is not Enter key
        (prompt (strcat "\e[10;" (itoa curpos) "H"))   ;Initial cursor position
        (setq key (last (grread nil 10)))              ;Return all keys, 
                                                       ;suppress *Cancel*
        (cond
          ( (= key 203)                                ;Left arrow
            (setq curpos (1- curpos))
            (if (< curpos 1) (setq curpos txtlen))
          )
          ( (= key 205)                                ;Right arrow
            (setq curpos (1+ curpos))
            (if (> curpos txtlen) (setq curpos 1))
          )
          ( (= key 127)                                ;If key was del
            (setq txt (strcat (substr txt 1 (1- curpos))
                                            (substr txt (1+ curpos))))
            (setq txtlen (1+ (strlen txt)))            ;Get new text length
            (prompt (strcat "\e[10;1H" txt " "))       ;Display txt string
          )
          ( (and (= key 8) (> curpos 1))               ;Delete back arrow key
            (setq curpos (1- curpos))
            (setq txt (strcat (substr txt 1 (1- curpos))
                              (substr txt (1+ curpos))))
            (setq txtlen (1+ (strlen txt)))            ;Get new text length
            (prompt (strcat "\e[10;1H" txt " "))       ;Display txt string
          )
          ( (and (> key 31) (< key 127))  ;If valid char key - create new text 
                                          ;string including the new character 
                                          ;at the cursor position
            (setq txt (strcat (substr txt 1 (1- curpos)) (chr key)
                                            (substr txt curpos)))
            (setq txtlen (1+ (strlen txt)))          ;Get new text length
            (setq curpos (1+ curpos))                ;Get new cursor position
            (prompt (strcat "\e[10;1H" txt " "))     ;Display new text string
          )
          (t nil)
        );cond
      );while
      (chgerr "")
      (prompt "\e[2J")
      (textpage)                                     ;Clear screen
      (setq entity (subst (cons 1 txt) (assoc 1 entity) entity))    
                                                     ;Change entity list
      (entmod entity)                                ;Update entity
    );progn
    (prompt "\nEntity was not text.")                ;Print bad pick message
  );if
  (if (= "TEXT" test) (textpage))                    ;Clear screen
  (graphscr)                                         ;Return to drawing
  (princ)
);defun C:ETEXT

(princ)
;;;*End of ETEXT.LSP file

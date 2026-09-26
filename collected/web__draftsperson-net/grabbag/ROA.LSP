; ROA.LSP
; ReOrder Attributes (definitions)
; Copyright 1988 Alacrity

; Introduction...
;
; This routine assists the user in reordering the attribute definitions in
; the drawing database so that when an attribute block is created from the
; attribute definitions (plus whatever other entities), the attribute prompts
; will appear in the desired order.
;
; First a bit of background information...
; 
; When selecting entities with the Window or Crossing options, the entities
; drawn most recently will be selected first.  When creating an attribute 
; block, this can lead to having the attributes prompts out of order.  The way
; to avoid this is to select entities singularly.  But this can be time
; consuming and frustrating when creating something of the scale of a title
; and border block.
;
; What ROA.LSP does...
;
; Apon running, ROA finds all of the attribute definitions in the drawing.
; ROA will then display up to 40 of the attribute defintions on the text
; screen (numbered sequencially).  The order that the attribute definitions
; is shown on the screen is the order that they will prompt once a block is
; created.  The user can change the prompting order by specifying the old 
; position number and the new position number (example below) for the each of
; the attribute definitions.  When the user is satisfied with the order of the
; attribute definitions, a [ENTER] exits from the program.  The attribute
; definitions will then be reordered as specified.
;
; Example...
;
;   Command: (load "ROA") [ENTER]
;   ROA.LSP - (C)1988 Alacrity
;
;   Command: ROA
;   Finding all attribute definitions...
;  
;   NUM  TAG          PROMPT
;   [1]  AAA        - Enter AAA
;   [2]  BBB        - Enter BBB
;   [3]  CCC        - Enter CCC
;   [4]  DDD        - Enter DDD
;   Old number: 4 [ENTER]
;   New number: 2 [ENTER]
;
;   NUM  TAG          PROMPT
;   [1]  AAA        - Enter AAA
;   [2]  DDD        - Enter DDD
;   [3]  BBB        - Enter BBB
;   [4]  CCC        - Enter CCC
;   Old number: [ENTER]
;
;   Reordering attribute definitions in drawing...
;
;   Command:
;
; Wrap it up...
;
; The practical application of ROA.LSP is limited.  It was a neat programming
; project and has helped me save some of my sanity when working on attribute
; blocks.  Since ROA.LSP will find all the attribute definitions in the
; drawing, it is assumed that the drawing you are working in will be used as
; a block to inserted into other drawings.  This is not a limitation, just
; that ROA.LSP is not the fastest routine in existance and will take longer 
; to run on a bigger drawing.  Also, by reordering the attribute definitions
; within the drawing database, the user is not required to WBLOCK.  (I have
; typically WBLOCKed attribute blocks when I'm done "just to be sure".)
;
; ROA.LSP has some neat functions and programming examples in it.  At the very
; least, someone who is still learning AutoLISP should be able to garner some
; practical knowledge from it.  After the user specifys the order for the 
; attribute definitions, ROA.LSP actually COPYs each of the definitions in the
; proper order (while deleting the old entities).
;
; 'Til next time...
;
; ROA.LSP is placed in the public domain for the benefit of AutoCAD user's
; near and far.  Please distribute freely.  No fee may charged for ROA.LSP.
; ROA.LSP does not include any garantee whatsoever.  Use at your own risk.
; I am confident that ROA.LSP works properly, I would just encourage persons
; to SAVE regularly.  Comments and suggestions are cheerfully accepted.
;
;    Jason Osgood
;    Alacrity
;    12405 SE 25th St
;    Bellevue, WA 98005
;    (206)746-0680
;
;    CompuServe: 73417,1756

(princ "\nROA.LSP - (C)1988 Alacrity\n")

(defun C:ROA (/ insert delete pad display lst p alist elist i 
                num str old new group ename elist ss chg?)
  ;---------------------
  ; Delete atom in list
  ;---------------------
  (defun delete (lst p)
    (cond
      ((zerop p) (cdr lst))
      (T (cons (car lst) (delete (cdr lst) (1- p))))
    )
  )
  ;---------------------
  ; Insert atom in list
  ;---------------------
  (defun insert (lst x p)
    (cond
      ((zerop p) (cons x lst))
      (T (cons (car lst) (insert (cdr lst) x (1- p))))
    )
  )
  ;-------------------------------
  ; Display Attribute Definitions
  ;-------------------------------
  (defun display ()
    (textscr)
    ; **************   HEY YOU! *************
    ; If ANSI.SYS is installed on your system, uncomment the next line
;    (princ "\e[2J")
    (princ "\nNUM  TAG          PROMPT\n")
    (setq i 1)
    (while (and (< i 21) (<= i num))
      (princ (strcat "\n" (if (< i 10) " " "") "[" (itoa i) "] " (cdr (nth (1- i) alist))))
      (if (and (> num 20) (<= (+ i 20) num))
        (princ (strcat "   [" (itoa (+ i 20)) "]" (cdr (nth (+ i 19) alist))))
      )
      (setq i (1+ i))
    )
  )
  ;------------------------
  ; Pad String With Spaces
  ;------------------------
  (defun pad (str x)
    (setq str (substr str 1 x))
    (while (< (strlen str) x)
      (setq str (strcat str " "))
    )
    str
  ) 
  ;-------------------------------
  ; Find all Attribue Definitions
  ;-------------------------------
  (setq num 0 alist nil)
  (princ "\nFinding all attribute definitions...")
  (if (setq ss (ssget "X" '((0 . "ATTDEF"))))
    (while (setq ename (ssname ss 0))
      (setq elist (entget ename)
            str   (strcat 
                    (pad (cdr (assoc 2 elist)) 10) 
                    " - " 
                    (pad (cdr (assoc 3 elist)) 20)
                  )
            alist (append (list (cons ename str)) alist)
            num (1+ num)
      )
      (ssdel ename ss)
    )
    (*error* "No attribute definitions found.")
  )
  (if alist
    (while
      (and
        (display)
        (not (initget 6))
        (setq old (getint "\nOld number: "))
        (not (initget 6))
        (setq new (getint "New number: "))
      )
      (if (not (or (= old new) (> old num) (> new num)))
        (setq group (nth (1- old) alist)
              alist (delete alist (1- old))
              alist (insert alist group (1- new))
              chg?  T
        )
      )
    )
  )
  (if chg? 
    (progn
      (setvar "CmdEcho" 0)
      (princ "\nReordering attribute definitions in drawing...")
      (SETQ ALIST (REVERSE ALIST))
      (foreach
        group
        alist
        (setq ename (car group))
        (command "COPY" ename "" "@" "@")
        (entdel ename)
      )
      (setvar "CmdEcho" 1)
    )
  )
  (redraw)
  (princ)
)

; End Of File
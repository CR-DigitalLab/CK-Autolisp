; TXTHGT.LSP
; 4/15/87
; Tony Tanzillo, A/E Automation Systems
;
; The information contained herein is being donated to the public domain
; soley for the benefit of licensed AutoCAD END USERS everywhere.  You are
; free to modify, or reproduce and distribute only in the un-altered
; original form, the information contained herein for ANY NON-COMMERCIAL
; use, provided such reproduction/disribution is NOT FOR PROFIT, and
; provided that with any such distribution, this NOTICE (or any portion
; thereof) is NOT REMOVED OR ALTERED from it's original content in ANY
; manner, shape, or form.
;
; You ARE NOT free to reproduce and/or distribute the information
; contained herein (regardless of medium or form of reproduction) for
; profit, or to include it or any portion thereof, as a part of any
; commercially marketed goods regardless of thier intended nature, scope,
; or form, without the expressed written permission of the author.
;
; If you seek such permission, it will be granted provided you furnish the
; author with ONE (1) fully-functional, licenseable sample of the finished
; product(s) in final marketed form.  In return for which you may solict
; and will recieve the objective opinions, advice and insight regarding
; any and all aspects of said product(s), free of charge, with appropriate
; and complete written assurance of non-disclosure.
;
; Additional information can be obtained
; by writing to:
;                 Anthony F. Tanzillo,
;                 32 Gould Ave.
;                 Paterson, N. J. 07503
;
; Or, via electronic medium thru;
;
;                 Compuserve ID: 70307,2556
;
; This is a user defined command that will scan the entire drawing
; database and change all text with the specified style to the
; specified height resulting in uniform height for all text entities
;
; REQUIRES THE FOLLOWING FUNCTIONS FROM TEXTED.LSP;
;
;   PFETCH
;   GLOBAL
;
; Tony Tanzillo, 70307,2556



(defun C:TEXTHGT( / ent sty hgt)
  (cond
    ((and
       (not
         (eq "" (setq sty (strcase (getstring "\nText style to change: ")))))
       (setq hgt (getdist (strcat "\nNew height for style " sty ": "))))

     (global t 'ent
       '(cond ((equal (pfetch ent '(0 7)) (list "TEXT" STY))
           (entput ent 40 hgt))))))
  (prin1))

(defun global (count smb expr / i)
  (set smb (entnext))
  (setq i (cond (count 0)))
  (prompt "\nProcessing drawing database... \n")
  (while
    (progn
      (if i (prompt (strcat "\rEntity " (itoa (setq i (1+ i))))))
      (eval expr)
      (set smb (entnext (eval smb))))))

(defun pfetch(e p / pr)
  (setq pr (entget (cond ((atom e) e) ((car e)))))
  (cond ((atom p) (cdr (assoc p pr)))
        ((mapcar '(lambda(x) (cdr (assoc x pr)))p))))


)))

(defun vert
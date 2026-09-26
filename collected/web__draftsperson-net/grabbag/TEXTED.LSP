; TEXTED.LSP  (TEXTEDIT.LSP)
; Tony Tanzillo, A/E Automation Systems
; 2/11/87
;
; Notice
;
; The information contained herein is being donated to the public domain
; soley for the benefit of licensed AutoCAD END USERS everywhere. You are
; free to reproduce, modify and distribute the information contained herein
; for ANY NON-COMMERCIAL use, provided such reproduction/distribution is
; NOT FOR PROFIT, and the information contained herein (or any portion
; thereof) is NOT ALTERED from it's original content in ANY manner, shape,
; or form.
;
; You ARE NOT free to reproduce and/or distribute the information contained
; herein (regardless of medium or form of reproduction) for profit, or to
; incorporate it or any portion thereof, as a part of any commercially
; marketed software, systems, or other goods regardless of the intended
; nature, scope, or form, without the expressed written permission of
; the author.
;
; If you seek such permission, it will be granted provided you furnish
; ONE fully-functional licensed sample of the finished product(s), in
; return for which you may solict and will recieve the author's objective
; opinions, advice and insight regarding any and all aspects of said
; product(s), free of charge, with appropriate and complete written
; assurance of non-disclosure.
;
; Additional information can be obtained
; by writing to:
;                   Anthony F. Tanzillo,
;                   32 Gould Ave.
;                   Paterson, N. J. 07503
;
; Or, via electronic mail thru;
;
;                   Compuserve ID: 70307,2556
;
; TEXTEDIT is a user-defined AutoLISP command that permits easier
; editing of text values on a drawing. Objects can be selected with
; the multiple object selection mechanisim, and the user can then
; edit each selected text value individually, without being
; prompted for other properties (as is the case with the AutoCAD
; CHANGE command). With EDIT, the user will only be prompted for
; new text values for the selected text entities.
;
; If you respond with a CR OR NOTHING BUT SPACES to the
; New text: prompt, the highlighted text will NOT be changed.
; This is to prevent creation of text entities that cannot be
; edited or deleted with normal AutoCAD editing commands.
;
; To use edit, LOAD the functions in this file, or add to your
; ACAD.LSP. Once loaded, enter "TEXTEDIT" to use the new command.
;
; Tony Tanzillo, 70307,2556

(defun C:TEXTEDIT( / pr new old)
  (prompt "\nSelect text to edit,")
  (ss-each nil 'ent
    '(cond
       ((setq pr (etype ent "TEXT"))
         (redraw ent 3)
         (if
           (and
             (setq new (getstr "New text" (setq old (get 1 pr)) t))
             (not (member new  (list old (space (strlen new))))))
           (entput ent 1 new)
           (redraw ent 4)))))
  (progn))

(defun ss-each(ss smb proc / i c)
  (setq i -1)
  (if (setq ss (orr '(ss (ssget))))
    (progn
      (while (set smb (ssname ss (setq i (1+ i)))) (eval proc))
      (sslength ss))))

(defun entput(e p v / pr o)
  (setq pr (entget e))
  (entmod
    (if (setq o (assoc p pr)) (subst (cons p v) o pr) (append pr (cons p v))))
  (eval e))

(defun getstr(p d c)
  (orr '(
    (string
      (getstring (strcat "\n" p (if d (strcat " <" d ">" ) "")": ")c))d)))

(defun etype(e n / pr)
  (cond
    ((eq (cdr (assoc 0 (setq pr (entget e)))) (strcase n)) pr) (t nil)))

(defun get(k l) (cdr (assoc k l)))

(defun pr-get(e p) (cdr (assoc p (entget e))))

(defun space(n)
  (substr "                                                        "  1 n))

(defun orr(l) (eval (cons 'cond (mapcar 'list l))))

(defun string(v) (cond ((not (eq v "")) v )))


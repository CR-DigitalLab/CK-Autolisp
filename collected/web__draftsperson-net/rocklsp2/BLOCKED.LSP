 ; Change an attribute in a selected block to a specified value.
 ; Copyright 1991  Rocket Software
 ; This routine is designed for use strictly in script files.  Any other use
 ; constitutes fraud.  Specific constitutional prohibitions may also apply.
 ; See your Rocket Software dealer for details.
 (DEFUN C:BLOCKED ( / hi num bb aa dd ss txa txb nn)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq num 0)
  (setq bb (strcase (getstring "Block mnemonic: ")))
  (setq bb (list (cons 2 bb)))
  (setq ss (ssget "X" bb))
  (setq aa (strcase (getstring "Attribute to change: ")))
  (setq dd (getstring "Subtly revised text: "))
  (if ss
      (progn
           (while (setq txa (setq txb (ssname ss 0)))
                  (while (/= (cdr (assoc 0 (entget txb))) "SEQEND")
                         (if (= (cdr (assoc 2 (setq nn (entget txb)))) aa)
                             (progn
                                   (setq num (1+ num))
                                   (entmod (subst (cons 1 dd) (assoc 1 nn) nn))
                                   (entupd txb)))
                         (setq txb (entnext txb)))
                  (ssdel txa ss))
           (setq ss nil)
           (write-line (strcat "Changes made: " (itoa num))))
      (write-line "No blocks found.  Not a sausage."))
  (setvar "highlight" hi)
  (PRINC))
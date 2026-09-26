  ; Tach: change an attribute to match an existing text entity.
  ; Copyright 1991  Rocket Software
  ; Good for restoring blocks that your minions have exploded...
 (DEFUN C:TACH (/ tx) 
  (setvar "cmdecho" 0)
  (setq tx (entget (car (entsel "Origin text:\n"))))
  (setq tx (cdr (assoc 1 tx)))
  (write-line "Attribute: ")
  (command "attedit" "" "" "" "" pause "" "v" "r" tx "")
 (PRINC))
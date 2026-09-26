  ; Igglesden Hole Inserter 
  ; Copyright Rocket Software 1991
  ; Crude and yet stangely effective - just like slotted angle iron.
 (DEFUN C:IHI ( / pa dd )
   (command "setvar" "cmdecho" "0")
   (setq pa (getpoint "\nPick insertion point\n"))
   (command "circle" pa "2" )
   (setq dd (entlast))
   (command "trim" "last" "" pa "")
   (entdel dd)
   (command "insert" "circ" pa "" "" "" )
  (PRINC)
 )
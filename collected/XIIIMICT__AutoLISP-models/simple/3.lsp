(defun c:lab ()
  (setq osm (getvar "osmode"))
  (setvar "osmode" 0)
  
  (command "ящик" '(0 0 0) "д" 100 80 45)
  (setq carcass (entlast))
  (command "цилиндр" '(50 60 0) 32 45)
  (setq bigger_cylinder (entlast))
  (command "цилиндр" '(50 60 0) 20 45)
  (setq smaller_cylinder (entlast))
  (command "ящик" '(0 30 0) "д" 100 80 45)
  (setq corner_block_1 (entlast))
  (command "повернуть" corner_block_1 "" '(0 30 0) '(25.02 80 0))
  (command "зеркало" corner_block_1 "" '(50 0 0) '(50 1 0) "н")
  (setq corner_block_2 (entlast))
  (command "ящик" '(0 42 22) "д" 100 100 23)
  (setq bigger_center_block (entlast))
  (command "ящик" '(17 30 22) "д" 66 100 23)
  (setq smaller_center_block (entlast))
	   
  (command "вычитание" carcass bigger_cylinder "" smaller_cylinder corner_block_1 corner_block_2 bigger_center_block smaller_center_block "")

  (command "повернуть3d" carcass "" '(0 0 0) '(1 0 0)	90)

  (command "цилиндр" '(50 -45 0) 15 30)

  (command "вычитание" carcass "" (entlast) "")
  
  (setvar "osmode" osm)
  )

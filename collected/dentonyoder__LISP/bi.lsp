(defun c:bi(/ ans myset p1 p2 oldcmdecho)
  ;;; build isometric macro by Denton Yoder (c) 2006
  (setq oldcmdecho (getvar "cmdecho"))
  (setvar "cmdecho" 0)
  (command "undo" "group")
  
  (princ"\nProgram by Denton Yoder to build an isometric view from existing geometry.")
  (setq ans (getstring "\nBuild from existing (Top, Front, or Side) T,F, or S:"))
  (princ "\nSelect objects to copy:")
  (setq MySet (ssget))
  (setq p1 (getpoint "\nFrom or Reference point:"))
  (setq p2 (getpoint p1 "\nTo or Destination point:"))

  (setq ans (strcase ans))
  (setq ans (substr ans 1 1))
  (if (= ans "T") (progn
	(command "copy" myset "" p1 p1)
	(command "move" myset "" p1 p2)
	(command "rotate" myset "" p2 "-45")
	(command "rotate3d" myset "" "x" p2 -60)
		    ))
  (if (= ans "F") (progn
	(command "copy" myset "" p1 p1)
	(command "move" myset "" p1 p2)
	(command "rotate3d" myset "" "y" p2 -45)
	(command "rotate3d" myset "" "x" p2 30)
		    ))
  (if (= ans "S") (progn
	(command "copy" myset "" p1 p1)
	(command "move" myset "" p1 p2)
	(command "rotate3d" myset "" "y" p2 45)
	(command "rotate3d" myset "" "x" p2 30)
		    ))
  
  (command "undo" "end")
  (setvar "cmdecho" oldcmdecho)
  (princ)
  )
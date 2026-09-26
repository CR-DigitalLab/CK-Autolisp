
(defun s::startup()
  	(setvar "cmdecho" 0)
	(command "navvcube" "off" "navbar" "off")
	(setvar "mbuttonpan" 1)
  	(setvar "filedia" 1)
  	(setvar "cmdecho" 1) 

    (defun c:za() (command "zoom" "e" "zoom" "0.9x"))

  )
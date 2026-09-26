   ; Useful facts about the current drawing &c.
   ; by SW for Rocket Software  Copyright 1991
   ; For those who need more information than the average man.
  (DEFUN C:INF ( / dd yy mm da mm mlst s t1 t2 se aa bb cc dd ee ff gg hh ii
                   ex lix)
   (command "setvar" "cmdecho" "0")
   (command "textscr")
   (SETQ DD (GETVAR "CDATE"))
   (SETQ YY (fix (/ dd 10000)))
   (setq mm (- (fix (/ dd 100)) (* yy 100.0)))
   (setq da (- (fix dd) (+ (* mm 100.0) (fix (* yy 10000.0)))))
   (setq mm (fix (1- mm)))
   (setq mlst (list "JANUARY " "FEBRUARY " "MARCH " "APRIL "
                    "MAY " "JUNE " "JULY " "AUGUST "
                    "SEPTEMBER " "OCTOBER " "NOVEMBER " "DECEMBER "))
   (setq mm (nth mm mlst)) 
   (setq dd (strcat mm (itoa (fix da)) ", " (itoa (fix yy))))
   (write-line (strcat "Today's date: " dd))

   (setq dd (rtos (fix (getvar "cdate"))))
   (setq yy (substr dd 3 2) mm (substr dd 5 2) da (substr dd 7 2))
   (write-line (strcat "Or in metric: " yy "/" mm "/" da))

   (setq s (getvar "tdupdate"))
   (setq t1 (* 86400.0 (- s (fix s))))
   (setq s (getvar "date"))
   (setq t2 (* 86400.0 (- s (fix s))))
   (setq se (rtos (- t2 t1) 2 1))
   (write-line (strcat "Seconds since drawing saved: " se))

   (setq aa (getvar "extmin"))
   (setq bb (rtos (car aa)) cc (rtos(cadr aa)))
   (write-line (strcat "Lower left point of drawing is at " bb "," cc))
   (setq aa (getvar "extmax"))
   (setq dd (rtos (setq dd1 (car aa))) ee (rtos (setq ee1 (cadr aa))))
   (write-line (strcat "   ...and upper right point is at " dd "," ee))

   (setq aa (getvar "limmin"))
   (setq ff (rtos (car aa)) gg (rtos(cadr aa)))
   (write-line (strcat "The limits, on the other hand, are " ff "," gg))
   (setq aa (getvar "limmax"))
   (setq hh (rtos (setq hh1 (car aa))) ii (rtos (setq ii1 (cadr aa))))
   (setq hh (rtos (car aa)) ii (rtos(cadr aa)))
   (write-line (strcat "                            ...and " hh "," ii))

   (setq ex (* dd1 ee1))
   (setq lix (* hh1 ii1))
   (write-line (strcat "(Limits are approximately "
                       (itoa (fix (* 100.0 (/ lix ex)))) "% of extents.)"))

   (write-line "Largest living carnivore: Sperm whale")
   (write-line (strcat "Drawing name: " (getvar "dwgname")))
   (write-line (strcat "Current menu name: " (getvar "menuname")))
   (write-line (strcat "AutoCad version: " (getvar "acadver")))
   (write-line (ver))
   (write-line (strcat "Autocad temporary file directory: " (getvar "tempprefix")))
   (write-line "Symbol names: < # >  Octathorpe")
   (write-line "              < & >  Ampersand")
   (write-line "              < * >  Asterisk")
   (write-line "              < ~ >  Tilde")
   (write-line (strcat "Expert status: " (itoa (getvar "expert"))))
   (write-line "User efficiency rating: 42.7%")
   (PRINC))
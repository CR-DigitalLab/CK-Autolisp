   ;  Convert lines to line and circle composites
   ;  of fixed line length (10) and circle diameter (2).
   ;  by SW for Rocket Software  Copyright 1991
   ;  Software for people who don't want to be nibbled to death by ducks.
 (DEFUN C:LAC1 ( / xa xb xa2 xa1 xa3 xah ang angg num remn n1)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq pt (entsel "Select a line:\n"))
   (if pt
       (progn
             (setq ll (entget (car pt)))
             (if (= "LINE" (cdr (assoc 0 LL)))
                 (progn
                       (setq xa (cdr (assoc 10 ll)))
                       (setq xb (cdr (assoc 11 ll)))
                       (entdel (car pt))
   (setq dd (distance xa xb)                         ; total length
         num (fix (/ dd 12))                         ; # of segments
         n1 0                                        ; draw counter
         remn (- (/ (rem dd 12) 2) 1)                ; end lengths
         angg (angle xa xb))                         ; setq end
  (if (< remn 4)
      (setq num (1- (fix (/ dd 12)))                 ; # of segments
            remn (+ 6 (- (/ (rem dd 12) 2) 1))))     ; end lengths
  (if (> dd 12)
      (progn
            (setq xa2 (polar xa angg remn))          ; 1st segment
            (command "line" xa xa2 "")
            (setq xa (polar xa2 angg 2))
            (command "circle" "2p" xa2 xa)
            (while (< n1 num)                        ; draw segments:
                   (setq xa1 (polar xa angg 10))
                   (command "line" xa xa1 "")
                   (setq xa3 (polar xa1 angg 2))
                   (command "circle" "2p" xa1 xa3)
                   (setq xa xa3)
                   (setq n1 (1+ n1))
            )                                        ; while end
            (command "line" xa xb "")
            (write-line (strcat "Segments drawn: " (itoa (1+ num))))
      )                                              ; progn end
      (if (> dd 6)
          (progn 
                (command "line" xa (setq xah (polar xa angg 
                                                  (/ (- dd 2) 2))) "")
                (command "circle" "2p" xah (setq xa (polar xah angg 2)))
                (command "line" xa xb "")
                (write-line "1 segment force-fit."))
          (Progn
                (command "line" xa xb "")
                (write-line "Sorry, no room for nonessentials."))))
 ) (write-line "That was not a line."))
 ) (write-line "You must select an entity. Preferably a line."))
 (PRINC))
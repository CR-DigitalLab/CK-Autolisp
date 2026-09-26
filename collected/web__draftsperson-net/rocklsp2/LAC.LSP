   ;  Line and circle constructor - fixed length (10) and diameter (2).
   ;  by SW for Rocket Software  Copyright 1991
   ;  Caution: this program will save time and trouble
   ;           and thus may incur the wrath of your superiors.
 (DEFUN C:LAC ( / xa xa2 xa1 xa3 xah ang angg num remn n1)
   (setvar "cmdecho" 0)
   (if (= XB ())
       (setq XA (getpoint "Start point?\n"))
       (progn
             (setq XA (getpoint "New start or <Return> to continue:\n"))
             (if (= XA ()) (setq XA XB))))
   (setq xb (getpoint xa "And end?\n"))
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
 (PRINC))
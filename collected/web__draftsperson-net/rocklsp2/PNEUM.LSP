  ; Pneumatic line constructor.
  ; Requires blocks PNEU90 (vertical) and PNEU0 (horizontal).
  ; Block spacing is 12 drawing units
  ; Copyright 1991  Rocket Software
  ; Rocket Software - All you have to do is think!
  ; (But then that's always the problem, isn't it?)
 (DEFUN C:PNEUM ( / xa angg ang blk num remn n1)
   (setvar "cmdecho" 0)
   (if (= XB ())
       (setq XA (getpoint "Start point?\n"))
       (progn
             (setq XA (getpoint "New start or <Return> to continue:\n"))
             (if (= XA ()) (setq XA XB))))
   (setq xb (getpoint xa "And end?\n"))
   (command "line" xa xb "")
   (setq dd (distance xa xb)                         ; total length
         num (fix (/ dd 12))                         ; # of segments
         n1 0                                        ; draw counter
         remn (/ (rem dd 12) 2)                      ; end lengths
         angg (angle xa xb)
         ang (* (/ 180 pi) angg))
  (if (or (> ang 315) (< ang 45) (and (> ang 135) (< ang 225)))
      (setq blk "pneu0")
      (progn
            (setq blk "pneu90")
            (setq ang (- ang 90))))
  (if (< remn 4)
      (setq num (1- (fix (/ dd 12)))                 ; # of segments
            remn (+ 6 (/ (rem dd 12) 2))))           ; end lengths
  (if (> dd 12)
      (progn
            (setq xa (polar xa angg remn))           ; 1st segment
            (command "insert" blk xa "" "" ang)
            (while (< n1 num)                        ; draw segments:
                   (setq xa (polar xa angg 12))
                   (command "insert" blk xa "" "" ang)
                   (setq n1 (1+ n1)))
            (write-line (strcat "Segments drawn: " (itoa (1+ num))))
      )                                              ; progn end
      (if (> dd 6)
          (progn 
                (setq xa (polar xa angg (/ dd 2)))
                (command "insert" blk xa "" "" ang)
                (write-line "1 segment force-fit."))
          (write-line "Sorry, no room for nonessentials.")))
 (PRINC))
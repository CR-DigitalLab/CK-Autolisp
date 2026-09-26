  ;  Line and circle constructor.
  ;  by SW for Rocket Software 1991
  ; "That lisp stuff will crash the network.  It's probably
  ;  full of viruses. Just do your work and stop thinking."
(DEFUN C:LACC ( / xa dd diax lenx gax xa2 xa1 xa3 
                                 xah ang angg num remn n1 totl)
  (setvar "cmdecho" 0)
  (if (= XB ())
      (setq XA (getpoint "Start point?\n"))
      (progn
            (setq XA (getpoint "New start or <Return> to continue:\n"))
            (if (= XA ()) (setq XA XB))))
  (setq xb (getpoint xa "And end?\n"))
  (if (and len dia gap)
      (setq dd (getstring "Use defaults? <Y>:\n")))
  (if (not (or (= dd "") (= dd "Y") (= dd "y")))
      (progn
  (if (= dia ())
      (setq dia (getdist xa "Circle diameter? "))
      (progn
      (setq diax (getdist xa (strcat "Circle diameter <" (rtos dia) ">: ")))
      (if diax (setq dia diax))))
  (while (or (null dia) (= dia 0))
         (setq dia (getdist xa "Diameter cannot be 0: ")))
  (if (= len ())
      (setq len (getdist xa "Line length? "))
      (progn
      (setq lenx (getdist xa (strcat "Line length <" (rtos len) ">: ")))
      (if lenx (setq len lenx))))
  (if (= gap ())
      (progn
      (setq gap (getdist xa "Line-circle gap length? <0> "))
      (if (null gap) (setq gap 0)))
      (progn
   (setq gax (getdist xa (strcat "Line-circle gap length <" (rtos gap) ">: ")))
      (if gax (setq gap gax))))))
  (setq totl (+ len dia (* 2 gap)))
  (setq dd (distance xa xb)                         ; total length
        num (fix (/ dd totl))                       ; # of segments
        n1 0                                        ; draw counter
        remn (/ (- (rem dd totl) dia (* 2 gap)) 2)  ; end lengths
        angg (angle xa xb))                         ; setq end
 (if (< remn (+ dia (* 2 gap)))
     (setq num (1- (fix (/ dd totl)))               ; # of segments
           remn (+ (/ totl 2) (/ (- (rem dd totl) dia (* 2 gap)) 2))))
 (if (> dd totl)
     (progn
           (setq xa2 (polar xa angg remn))          ; 1st segment
           (command "line" xa xa2 "")
           (setq xa (polar xa2 angg gap))           ; gap
           (setq xa2 (polar xa angg dia))
           (command "circle" "2p" xa xa2)
           (setq xa (polar xa2 angg gap))
           (while (< n1 num)                        ; draw segments:
                  (setq xa1 (polar xa angg len))
                  (command "line" xa xa1 "")
                  (setq xa1 (polar xa1 angg gap))
                  (setq xa2 (polar xa1 angg dia))
                  (command "circle" "2p" xa1 xa2)
                  (setq xa (polar xa2 angg gap))
                  (setq n1 (1+ n1))
           )                                        ; while end
           (command "line" xa xb "")
           (write-line (strcat "Segments drawn: " (itoa (1+ num))))
     )                                              ; progn end
     (if (and (> dd (+ (* 2 gap) (* dia 1.25))) (> dd totl))
         (progn 
               (command "line" xa (setq xah (polar xa angg 
                                              (/ (- dd dia (* 2 gap)) 2))) "")
               (setq xah (polar xah angg gap))
               (command "circle" "2p" xah (setq xa (polar xah angg dia)))
               (setq xa (polar xa angg gap))
               (command "line" xa xb "")
               (write-line "1 segment squashed in."))
         (Progn
               (command "line" xa xb "")
               (write-line "Sorry, no room for details."))))
 (PRINC))
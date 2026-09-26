  ;  Dash and block line drawer.
  ;  by SW for Rocket Software 1991
  ;  This program requires a block with a centred insertion point.
  ;  Call it Dab.dwg. And say good things about Rocket Software.
 (DEFUN C:DAB ( / xa dd radx lenx gax rotx xa2 xa1 xa3
                              xah angl angg num remn n1 totl)
  (setvar "cmdecho" 0)
  (if (= XB ())
      (setq XA (getpoint "Start point?\n"))
      (progn
            (setq XA (getpoint "New start or <Return> to continue:\n"))
            (if (= XA ()) (setq XA XB))))
  (setq xb (getpoint xa "And end?\n"))
  (if (and len radi gap rota)
      (setq dd (getstring "Use defaults? <Y>: ")))
  (if (not (or (= dd "") (= dd "Y") (= dd "y")))
      (progn
  (if (= radi ())
      (progn
      (setq radx (getreal (strcat "\nNew block scale or <Return = 1> ")))
      (if radx (setq radi radx) (setq radi 1.0)))
      (progn
      (setq radx (getreal (strcat "\nNew block scale or <Return = "
                                  (rtos radi) "> ")))
      (if radx (setq radi radx))))
  (if (= len ())
      (progn
      (setq len (getdist xa "\nLine length? <10>:"))
      (if (null len) (setq len 10)))
      (progn
      (setq lenx (getdist xa (strcat "\nLine length <" (rtos len) ">: ")))
      (if lenx (setq len lenx))))
  (if (= gap ())
      (progn
      (setq gap (getdist xa "\nBlock insertion space length? <2> "))
      (if (null gap) (setq gap 2)))
      (progn
      (setq gax (getdist xa (strcat "\nBlock insertion space length <"
                                     (rtos gap) ">: ")))
      (if gax (setq gap gax))))
  (if (= rota ())
      (progn
      (setq rota (getstring "\nXXRotate block to match line? <Y> "))
      (if (or (= rota "") (= rota "Y") (= rota "y"))
          (setq rota "Y")
          (setq rota "N")))
      (progn
      (setq rotx (getstring (strcat "\nRotate block to match line <"
                                     rota ">: ")))
      (cond ((or (= rotx "Y") (= rotx "y")) (setq rota "Y"))
            ((or (= rotx "N") (= rotx "n")) (setq rota "N")))))))
  (setq totl (+ len gap))
  (setq dd (distance xa xb)                          ; total length
        num (fix (/ dd totl))                        ; # of segments
        n1 0                                         ; draw counter
        remn (/ (- (rem dd totl) gap) 2)             ; end lengths
        angg (angle xa xb))
  (if (= rota "Y")
      (setq angl (* 360 (/ angg (* 2 pi))))
      (setq angl 0))
  (if (< remn (/ gap 2))
      (setq num (1- (fix (/ dd totl)))               ; # of segments
            remn (/ (- dd (* num totl) gap) 2)))
  (if (> dd totl)
      (progn
            (setq xa2 (polar xa angg remn))          ; 1st segment
            (command "line" xa xa2 "")
            (command "insert" "dab" (polar xa2 angg (/ gap 2)) radi "" angl)
            (setq xa (polar xa2 angg gap))           ; gap
            (while (< n1 num)                        ; draw segments:
                   (setq xa1 (polar xa angg len))
                   (command "line" xa xa1 "")
                   (command "insert" "dab" (polar xa1 angg 
                                             (/ gap 2)) radi "" angl)
                   (setq xa (polar xa1 angg gap))    ; gap
                   (setq n1 (1+ n1))
            )                                        ; while end
            (command "line" xa xb "")
            (write-line (strcat "Segments drawn: " (itoa (1+ num))))
      )                                              ; progn end
      (if (> dd (* 1.5 gap))
          (progn 
          (command "line" xa (setq xah (polar xa angg (/ (- dd gap) 2))) "")
          (command "insert" "dab" (polar xah angg (/ gap 2)) radi "" angl)
          (setq xa (polar xah angg gap))
          (command "line" xa xb "")
          (write-line "1 segment squashed in."))
          (Progn
                (command "line" xa xb "")
                (write-line "Sorry, no room for details."))))
 (PRINC))
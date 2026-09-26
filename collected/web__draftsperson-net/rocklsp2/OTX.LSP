   ;   Multiple text - you supply the line spacing.
   ;   Copyright 1990   Rocket Software
   ;   Earthshaking software for scintillating people
   ;          ...who draw forms for a living.
 (defun C:OTX ( / nt txp vdist reg txht angg ang nga fh nn lst tt)
   (setvar "cmdecho" 0)
   (setq txp (getpoint "\nFirst insertion: "))
   (setq reg (getstring "\nRegistration (C,L,M,or R) <C>: "))
   (if (= reg "") (setq reg "c"))
   (setq vdist (getdist txp "\nText spacing <4>:"))
   (if (null vdist) (setq vdist 4))
   (setq tt (getvar "textstyle"))
   (setq fh (cdr (assoc 40 (tblsearch "style" TT))))
   (if (= fh 0.0)
       (progn
             (setq txht (getdist txp "\nText Height <2>:"))
             (if (null txht) (setq txht 2))))
   (setq angg (getangle txp "\nText rotation nangle <0>:"))
   (if (or (null angg) (= angg 0))
       (progn 
             (setq angg 0)
             (setq ang 0))
       (setq ang (* (/ angg pi) 180)))
   (setq nga (getangle txp 
   "Angle between successive text insertions <Default = perp. to text angle>:"))
   (if (null nga)
       (setq nga (+ angg (* pi 1.5))))
   (setq nt (getstring t "\nText <Random German phrase>: "))
   (setq s (* (getvar "cdate") 10000000.0))
   (setq nn (fix (* 10 (- s ( fix s)))))
   (setq lst
            (list "Achtung!" "Ich liebe." "Your papers, please!"
                  "Heil Hitler!" "So, Fraulein..." "Shoot zis Amerikaner."
                  "Zese are nice uniforms, Fritz." "Bring me ze voman."
                  "Schweinhund!" "I vas only following orders."))
   (if (= nt "")
       (setq nt (nth nn lst)))
   (if txht
           (progn
                (WHILE (and (/= nt "") lst)
                       (if (or (= reg "L") (= reg "l"))
                           (command "text" txp txht ang nt)
                           (command "text" reg txp txht ang nt))
                       (setq nt (getstring t "More text: "))
                       (setq txp (polar txp nga vdist))))
           (progn
                (WHILE (and (/= nt "") lst)
                       (if (or (= reg "L") (= reg "l"))
                           (command "text" txp ang nt)
                           (command "text" reg txp ang nt))
                       (setq nt (getstring t "More text: "))
                       (setq txp (polar txp nga vdist))))
   ) (PRINC))
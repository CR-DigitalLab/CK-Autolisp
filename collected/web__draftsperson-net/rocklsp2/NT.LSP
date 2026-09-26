   ;  Numbers with text in nutritious tomato sludge.
   ;  Copyright 1990   Rocket Software
   ;  Software for the pure of heart -
   ;     please don't use this if you are basically evil, stupid,
   ;                                    or chef boy-ar-dee.
 (defun C:NT ( / acc nt ll vv incr pref suff num txp 
                          vdist reg mm txht tt df fh ang xxx)
   (setvar "cmdecho" 0)
   (setq acc 0)
   (setq nt (getstring "Initial numeral (Leading zeros OK) <1>: "))
   (if (= nt "") (setq nt "1"))
   (setq ll (strlen nt))                      ; length of string input
   (setq vv (read nt))                        ; integer equivalent of nt
   (setq pref (getstring t "\nPrefix text <zilch>:"))
   (setq suff (getstring t "\nSuffix text <firth>:"))
   (setq incr (getint "\nIncrement (negatives are OK) <1>: "))
   (if (null incr) (setq incr 1))
   (setq num (getint "\nNumber of numbers <12>: "))
   (if (null num) (setq num 12))
   (setq txp (getpoint "\nFirst insertion: "))
   (setq reg (getstring "\nRegistration (C,L,M,or R) <C>: "))
   (if (= reg "") (setq reg "c"))
   (setq vdist (getdist txp "\nVertical spacing <5>:"))
   (if (null vdist) (setq vdist 5))
   (setq tt (getvar "textstyle"))
   (setq fh (cdr (assoc 40 (tblsearch "style" TT))))
   (if (= fh 0.0)
       (progn
             (setq txht (getdist txp "\nText Height <2.5>:"))
             (if (null txht) (setq txht 2.5))))
   (setq ang (getangle txp "\nNangle <0>:"))
   (if (or (null ang) (= ang 0))
       (setq ang "0")
       (setq ang (* (/ ang pi) 180)))
   (while (> num acc)
          (setq mm (strlen (itoa vv)))               ; length of int. value
          (setq df (- ll mm))                        ; strlen - int. length
          (setq nt (itoa vv))                        ; integer to string
          (repeat df (setq nt (strcat "0" nt)))      ; add diff. in zeros
          (setq numt (strcat pref nt suff))          ; add prefix and suffix
          (if (or (= reg "L") (= reg "l"))           ; (1) if left justified
              (progn                                 ; then
                    (if txht                         ; if not fixed height
                            (command "text" txp txht ang numt)
                            (command "text" txp ang numt)))
              (progn                                 ; (1) otherwise
                    (if txht                         ; if not fixed height
                            (command "text" reg txp txht ang numt)
                            (command "text" reg txp ang numt)))) ; (1) if end
          (setq txp (list (car txp) (- (cadr txp) vdist)))       ; new point
          (setq acc (1+ acc))                        ; increment counter
          (setq vv (+ incr vv)))                     ; increment value
  (PRINC))
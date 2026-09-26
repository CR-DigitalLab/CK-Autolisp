   ; Incremented characters with text
   ; by SW for Rocket Software  Copyright 1991
   ; Useful for naming large numbers of children...
 (defun C:CT ( / acc prf nt tnt ll vv incr pref suff num txp 
                          vdist reg mm txht tt df fh ang xxx)
   (setvar "cmdecho" 0)
   (setq prf ())
   (setq acc 0)
   (setq nt (strcase (getstring "Starting character <A>: ")))
   (if (= nt "") (setq nt "A"))
   (setq pref (getstring t "\nPrefix text <zilch>:"))
   (setq suff (getstring t "\nSuffix text <nada>:"))
   (setq incr (getint "\nIncrement <1>: "))
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
          (if prf (setq tnt (strcat prf nt))
                  (setq tnt nt))
          (setq numt (strcat pref tnt suff))         ; add prefix and suffix
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
          (setq nt (chr (+ (ascii nt) incr)))        ; increment character
          (if (> (ascii nt) 90)                      ; if > Z
              (progn
                    (setq prf (if prf (chr (1+ (ascii prf))) "A")) ; prefix
                    (setq nt "A")))                  ; and reset chr. to A
          (setq acc (1+ acc)))                       ; increment counter
  (PRINC))
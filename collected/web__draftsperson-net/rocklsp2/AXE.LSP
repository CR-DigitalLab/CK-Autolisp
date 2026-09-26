 ;  AXE - Cartesian text editor
 ;  Copyright 1990  Rocket Software
 ;  Software most people couldn't even have hallucinated
 ;            - try to be worthy of it.
 (DEFUN C:AXE ( / bb nst dec arr rr lina txa nta orth psuff ppref)
  (setvar "cmdecho" 0)
  (setq orth (getvar "orthomode"))
  (setvar "orthomode" 0)
  (command "undo" "mark")
  (if (= st ())
      (setq st (cadr (setq AA (entsel "Pick text:\n"))))
    (progn
    (setq bb aa)
    (setq nst (cadr (setq AA (entsel "New text or <Return> for previous.\n"))))
    (if (/= nst ()) (setq st nst) (setq aa bb))))
  (setq dec (getpoint st "Pick above to add, down to delete.\n"))
  (if (> (cadr dec) (cadr st))                           ; if st above dec
      (setq dec 1)                                       ; then add (1)
      (setq dec 0))                                      ; else delete (0)
  (setq arr (getpoint st "Pick end to change.\n"))
  (if (> (car arr) (car st))                             ; if arr to R of st
      (setq rr 1)                                        ; then R (rr=1)
      (setq rr 0))                                       ; else L (rr=0)
  (setq lina (entget (car aa)))                          ; line a entity name
  (setq txa (cdr (assoc 1. lina)))                       ; text of line a 
  (if (= rr 1)                                           ; 1st if
   (progn                                                ; 1st if 1st progn
   (if (= dec 1) (progn                                  ; 2nd if
      (if (= (type suf) 'STR)
       (progn
            (setq psuff (getstring t (strcat "Text to append <" suf ">:")))
            (if (/= psuff "") (setq suf psuff)))
       (progn
            (setq suf (getstring t "Text to append:"))))
       (setq nta (strcat txa suf)))
       (progn                                      ; 2nd if else: progn
            (setq lena (STRLEN txa))               ; length of line a text
            (while  (/= (substr txa lena 1) " ")   ; look for position of space
                    (setq lena (1- lena)))         ; while end
            (setq nta (substr txa 1 (1- lena))))   ; textto space,2nd if progend
   )                                               ; 2nd if end   
            (entmod (subst (cons 1 nta) (cons 1 txa) lina))  ; entmod
   )                                               ; 1st if 1st progn end
   (progn                                          ; 1st if not: progn
       (if (= dec 1) (progn                        ; 3rd if
   (if (= (type pre) 'STR)
       (progn
           (setq ppref (getstring t (strcat "Text to preface <" pre ">:")))
           (if (/= ppref "") (setq pre ppref)))
       (progn
           (setq pre (getstring t "Text to preface:"))))
           (setq nta (strcat pre txa)))
           (progn                                  ; 3rd if progn
              (setq lena 1)                        ; start of line a text
              (while (/= (substr txa lena 1) " ")  ; look for position of space
                     (setq lena (1+ lena))
              )                                    ; while end
              (setq nta (substr txa (1+ lena)))    ; get text after space
       ))                                          ; 3rd if end, progend
       (entmod (subst (cons 1 nta) (cons 1 txa) lina)) ;entmod
      ))                                           ; 1st if not progend
  (setvar "orthomode" orth)
  (PRINC))
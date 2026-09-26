    ;  Crossing Locator
    ;  Copyright 1990   Rocket Software
    ;  Software to help alleviate the tedium of mindless labour.
  (DEFUN C:XING ( / NUM AA SS LLL LLN A1 B2 C3 D4 XX RAT RA PPT NI FF GG BB DD)
     (setvar "cmdecho" 0)
     (grtext -2 "   Grooaaaagh!      ")
     (setq s (getvar "date"))
     (setq t1 (* 86400.0 (- s (fix s))))
     (write-line "Select lines you wish to involve: ")
     (SETQ SS (SSGET))                           ; GET LINES
     (setq ni 0)
     (WHILE (SSNAME SS 1)                        ; while ENTITY #2 EXISTS
       (SETQ NUM 1)                              ; start counter    
       (SETQ LLL (SSNAME SS 0))                  ; GET 1st ENTITY NAME
       (SETQ LLN (ENTGET LLL))                   ; GET THE WHOLE THING
       (SETQ A1 (CDR (ASSOC 10 LLN)))            ; GET ITS START
       (SETQ B2 (CDR (ASSOC 11 LLN)))            ; GET ITS END
          (WHILE (SETQ RAT (SSNAME SS NUM))      ; while NEXT ENTITY EXISTS
            (SETQ RA (ENTGET RAT))               ; GET ITS NAME
            (SETQ C3 (CDR (ASSOC 10 RA)))        ; GET ITS START
            (SETQ D4 (CDR (ASSOC 11 RA)))        ; GET ITS END
            (SETQ XX (INTERS A1 B2 C3 D4))       ; get intersection
            (if (and xx (not (or (equal xx a1)
                                 (equal xx b2)
                                 (equal xx c3)
                                 (equal xx d4))))
                (SETQ AA (CONS XX AA)))          ; add it to list
            (SETQ NUM (1+ NUM))                  ; GO TO NEXT ENTITY
          )                                      ; WHILE END
            (SSDEL LLL SS)                       ; DEL FIRST FROM SS
     )                                           ; WHILE END
   (WHILE (SETQ PPT (CAR AA))
          (SETQ AA (CDR AA))
          (SETQ FF (car PPT))
          (SETQ GG (cadr ppt))
          (setq BB (list ff (+ gg 1)))           ; alter the 1 in these two
          (setq DD (list ff (- gg 1)))           ; lines for diff. break width
          (command "break" bb dd)
          (setq ni (1+ ni))
   )                                             ; WHILE END
   (if (= 1 ni)
       (write-line "1 intersection obliterated  "))
   (if (< 1 ni)
       (write-line (strcat (ITOA ni) " intersections fenestrated  ")))
   (if (= 0 ni)
       (write-line "There are no useable intersections, cretin. "))
     (setq s (getvar "date"))
     (setq t2 (* 86400.0 (- s (fix s))))
   (write-line (strcat "Elapsed time: " (rtos (- t2 t1) 2 1) " seconds "))
  (PRINC))
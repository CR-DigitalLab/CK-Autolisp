   ;  Move word to next line
   ;  By SW  Copyright 1990  Rocket Software
   ;  Software for those who want to make the big bucks
   ;                        and get the good looking women.
(DEFUN C:WMX ( / aa bb a z zz nn yy ii lina linb txa txb ntxb lena nta ntb)
  (setvar "cmdecho" 0)
  (setq aa (entsel "\nPick origin text: "))
  (while (or (null aa) (/= (cdr (assoc 0 (entget (car aa)))) "TEXT"))
         (setq aa (entsel "\nSelect a text entity:")))
  (setq bb (entsel "\nPick destination text or <Return> for new text line: "))
;********************make and position new (empty) text line******************
  (if (null bb)
      (progn
            (setq a (car aa))
            (if a (progn
            (command "copy" a "" "1,1" "1,1")           ; copy in place
            (setq zz (entget (setq z (entlast))))
            (entmod (subst (cons 1 "") (assoc 1 zz) zz)); disappear
            (redraw a)                                  ; bring back original
            (setq nn (cdr (assoc 72 zz)))               ; get insertion of text
            (if (and (= (cdr (assoc 0 zz)) "TEXT")      ; (depending on type)
                     (or (= nn 2) (= nn 4) (= nn 1)))
                (setq yy (cdr (assoc 11 zz)))           ; l justified or fit
                (setq yy (cdr (assoc 10 zz))))          ; m, r, or c justified
            (setq ii (getpoint yy "New text insertion: "))
            (command "move" z "" yy ii)
            (setq zz (entget (setq z (entlast))))
            (setq bb (cons z (list ii)))))))            ; if null bb end
;******************get positions, lengths, and text strings*******************
  (if (and aa bb)
      (progn
            (if (and (= "TEXT" (cdr (assoc 0 (setq lina (entget (car aa))))))
                (= "TEXT" (cdr (assoc 0 (setq linb (entget (car bb)))))))
                (progn
                      (command "undo" "mark")
                      (setq txa (cdr (assoc 1. lina)))  ; text of line a 
                      (setq txb (cdr (assoc 1. linb)))  ; text of line b 
                      (if (> (cadadr AA) (cadadr BB))   ; compare positions
;******************************if aa is above bb******************************
  (progn
        (setq lena (strlen txa))                        ; length of line a
        (while (and (< 0 lena) (/= (substr txa lena 1) " "))
               (setq lena (1- lena)))
        (if (/= 0 lena)
            (progn
                  (setq ntxb (substr txa (1+ lena)))    ; word after space
                  (setq nta (substr txa 1 (1- lena)))   ; text up to space
                  (if (= txb "")
                      (setq ntb ntxb)                   ; b = last word of a
                      (setq ntb (strcat ntxb " " txb))) ; last word of a + b
                  (entmod (subst (cons 1 nta) (cons 1 txa) lina))
                  (entmod (subst (cons 1 ntb) (cons 1 txb) linb)))
            (progn
                  (if (= txb "")
                      (setq ntb txa)                    ; set b = a
                      (setq ntb (strcat txa " " txb)))  ; b = a + b
                  (entdel (CAR AA))
                  (entmod (subst (cons 1 ntb) (cons 1 txb) linb))))
  )
;******************************if aa is below bb******************************
  (progn
        (setq lena 1)
        (while (and (> (strlen txa) lena) (/= (substr txa lena 1) " "))
               (setq lena (1+ lena)))
        (if (/= (strlen txa) lena)                      ; if a > 1 word
            (progn
                  (setq nta (substr txa (1+ lena)))     ; text after space
                  (setq ntxb (substr txa 1 (1- lena)))  ; word up to space
                  (if (= txb "")
                      (setq ntb ntxb)                   ; b = 1st word of a
                      (setq ntb (strcat txb " " ntxb))) ; b + 1st word of a
                  (entmod (subst (cons 1 nta) (cons 1 txa) lina))
                  (entmod (subst (cons 1 ntb) (cons 1 txb) linb)))
            (progn                                      ; if a = only 1 word
                  (if (= txb "")
                  (setq ntb txa)                        ; set b = a
                  (setq ntb (strcat txb " " txa)))      ; b = b + a
                  (entdel (car aa))
                  (entmod (subst (cons 1 ntb) (cons 1 txb) linb))))
  ))
;****************************clean endings &c.********************************
  ) (write-line "\nTEXT: the stuff with words in it. "))
  ) (write-line "\nYou must select a source entity. "))
  (PRINC))
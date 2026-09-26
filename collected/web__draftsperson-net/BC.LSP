; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  FILE   : BC.LSP                                                         บ
; วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
; บ  FUNC   : Program to count specific blocks in a drawing                  บ
; บ  ACCESS : Manual loading                                                 บ
; บ  FROM   : Gary Annable                                                   บ
; บ  DATE   : 5/23/91                                                        บ
; บ  NOTES  : Freely donated to the Public Domain Software Market.           บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

(defun C:BC (/ BSS1 BSS2 BSS3 TMP1 TMP2 FILE A ITEM THING NUM ENT ED BN
               DNAME NNAME FP ARG BNAME BNUMB)             ;all local variables
 (setq BSS1 nil)                                           ;set 3 selection
 (setq BSS2 nil)                                           ;sets to nothing
 (setq BSS3 nil)

 (setq BSS1 (cdr (assoc 2 (tblnext "BLOCK" T))))           ;search block table
 (setq BSS1 (list (cdr (assoc 2 (tblnext "BLOCK"))) BSS1)) ;for block names in
 (while (setq TMP (tblnext "BLOCK"))                       ;drawing and add 
  (setq BSS1 (cons (cdr (assoc 2 TMP)) BSS1))              ;them to BSS1
 )

 ;Get block list from file and add to BSS2
 (setq FILE (open "BLKTXT" "r"))                           ;open the file
 (setq BSS2 (list (read-line FILE)))                       ;read the first line
 (setq A t)                                                ;set a flag

 (while (/= A nil)                                         ;while flag=something
  (setq A (read-line FILE))                                ;read lines
  (if (and (/= A "EOF")(/= A nil))                         ;if flag is not these
   (setq BSS2 (cons A BSS2))                               ;add name to BSS2
  )
 )
 (close FILE)                                              ;close file

 ;If name in BSS1 is also in BSS2 then add to BSS3 & BSS4

 (princ "Counting blocks  .")                 ;to show that its working
 (foreach ITEM BSS1                           ;start loop through BSS1
  (progn
   (foreach THING BSS2                        ;start loop through BSS2
    (if (= THING ITEM)                        ;compare BSS2 thing to BSS1 item
     (progn
      (setq NUM 0)                            ;set counter to zero
      (setq ENT (entnext))                    ;get next entity in drawing
      (princ " .")                            ;working
      (while ENT                              ;search all entities
       (setq ED (entget ENT))                 ;ED = Entity
       (setq BN (cdr (assoc 2 ED)))           ;BN = Entity name
       (if (= BN ITEM)                        
        (setq NUM (+ NUM 1))                  ;increment counter
       )                                      ;end if
       (setq ENT (entnext ENT))               ;get next entity
      )                                       ;end while
      (setq BSS3 (cons (list ITEM NUM) BSS3)) ;Make BSS3 w/ block name & count
     )                                        ;end progn
    )                                         ;end if BSS2 thing = BSS1 item 
   )                                          ;end BSS2 loop compare
  )                                           ;end progn
 )                                            ;end BSS1 loop search

 ;Open file and write formatted strings to file

 (setq DNAME (getvar "DWGNAME"))              ;get drawing name
 (setq NNAME (strcat DNAME ".TMP"))           ;add extension to drawing name
 (setq FP (open NNAME "w"))                   ;open temporary file

 (foreach ARG BSS3                            ;foreach arguement of BSS3
  (progn
   (setq TMP1 (strcat (car ARG) "       "))   ;get name as first element
   (setq BNAME (substr TMP1 1 8))             ;trim name to 8 characters
   (setq TMP2 (rtos (cadr ARG) 2 0))          ;get number as second element
   (setq LEN (strlen TMP2))                   ;find length of string
   (if (= LEN 1)                              ;if string length is 1 character
    (setq BNUMB (strcat " " TMP2))            ;make a string of 2 characters
    (setq BNUMB TMP2)                         ;else leave it alone
   )                                          ;end if
   (princ BNAME FP)                           ;print name to file
   (princ "   " FP)                           ;print separator
   (princ BNUMB FP)                           ;print number to file
   (princ "\n" FP)                            ;print new line to file
  )                                           ;end progn
 )                                            ;end BSS3 loop
 (close fp)                                   ;close file
 (princ)                                      ;finish cleanly
)                                             ;end defun

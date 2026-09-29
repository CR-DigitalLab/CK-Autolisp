;;----------------------------------------------------------------------------;;
;; 【ご利用についてのお願い】
;; このコードは、作業効率化を目的として開発されたものです。
;; 個人利用や業務効率化のためにご活用いただけると幸いです。
;;
;; 【著作権および利用制限について】
;; 本スクリプトはCHIKOが著作権を保有しており、著作権によって保護されています。
;; 著作権表示は削除しないでください。
;; ご購入者様の個人利用、および所属する組織内での業務利用に限りご使用いただけます。
;; 本スクリプトの全部または一部を、許可なく複製、転載、再配布、販売することを禁止します。
;;----------------------------------------------------------------------------;;

(defun c:RANDOMBNAME (/ charset seed rand-val GetRandomString ss n i ent blk-name unique-names new-name count prefix total-len rand-len old-cmdecho)
  
  (setq prefix "A$C")
  (setq total-len 11)
  (setq rand-len (- total-len (strlen prefix)))
  (setq charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
  (setq seed (getvar "DATE"))
  
  (defun rand-val ()
    (setq seed (rem (+ (* seed 1664525) 1013904223) 4294967296))
    (fix (rem (/ seed 65536) (strlen charset)))
  )

  (defun GetRandomString (len / str idx)
    (setq str "")
    (repeat len
      (setq idx (1+ (rand-val)))
      (if (< idx 1) (setq idx 1))
      (setq str (strcat str (substr charset idx 1)))
    )
    str
  )

  (setq unique-names nil)
  (setq count 0)
  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (princ (strcat "\n名前を変更するブロックを一括選択してください"))
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (command "_.UNDO" "_BEGIN")
      
      (setq n (sslength ss))
      (setq i 0)
      (repeat n
        (setq ent (ssname ss i))
        (setq blk-name (cdr (assoc 2 (entget ent))))
        (if (not (member blk-name unique-names))
          (setq unique-names (cons blk-name unique-names))
        )
        (setq i (1+ i))
      )
      
      (foreach old-name unique-names
        (if (not (wcmatch old-name "`**")) 
          (progn
            (while 
              (progn
                (setq new-name (strcat prefix (GetRandomString rand-len)))
                (tblsearch "BLOCK" new-name)
              )
            )
            
            (if (tblsearch "BLOCK" old-name)
               (progn
                  (command ".-RENAME" "Block" old-name new-name)
                  (setq count (1+ count))
               )
            )
          )
        )
      )
      
      (command "_.UNDO" "_END")
      
      (princ (strcat "\n完了: " (itoa count) " 個のブロック定義名をランダムに変更しました！"))
    )
    (princ "\nブロックが選択されませんでした。")
  )
  (setvar "CMDECHO" old-cmdecho)
  (princ)
)

(defun c:RBN () (c:RANDOMBNAME))
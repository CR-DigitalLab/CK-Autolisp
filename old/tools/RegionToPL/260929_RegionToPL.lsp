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
(defun c:RegionToPL ( / ss si i ename last_ent exploded_ss next_ent first_ent is_spline)
    (princ "\nリージョンをポリラインに変換します。")
    (if (setq ss (ssget '((0 . "REGION"))))
        (progn
            (command "undo" "be")
            (setq si (getvar "PEDITACCEPT"))
            (setvar "PEDITACCEPT" 1)
            
            (setq i 0)
            (repeat (sslength ss)
                (setq ename (ssname ss i))
                
                (setq last_ent (entlast))
                (command "_.explode" ename)
                
                (setq exploded_ss (ssadd))
                (while (setq next_ent (entnext last_ent))
                    (ssadd next_ent exploded_ss)
                    (setq last_ent next_ent)
                )
                
                (if (> (sslength exploded_ss) 0)
                  (progn
                    (setq first_ent (ssname exploded_ss 0))
                    
                    (if (= (cdr (assoc 0 (entget first_ent))) "SPLINE")
                      (setq is_spline T)
                      (setq is_spline nil)
                    )
                    
                    (if is_spline
                      ; スプラインの場合： 精度指定("") -> J -> 対象選択 -> 選択終了("") -> PEDIT終了("")
                      (command "_.pedit" first_ent "" "_j" exploded_ss "" "")
                      ; 線や円弧の場合： J -> 対象選択 -> 選択終了("") -> PEDIT終了("")
                      (command "_.pedit" first_ent "_j" exploded_ss "" "")
                    )
                  )
                )
                
                (setq i (1+ i))
            )
            
            (setvar "PEDITACCEPT" si)
            (command "undo" "e")
        )
        (princ "\nリージョンが選択されませんでした。処理を中断します。")
    )
    (princ)
)

(defun c:RTP ()
    (c:RegionToPL)
    (princ)
)
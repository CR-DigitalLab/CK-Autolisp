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
;; RegionToPL ver2（2026-09-30）
;;   ・途中で Esc・エラーになったときの、Undo グループの終了と PEDITACCEPT の復元を追加
;;   ・Undo のオプションに「_」を追加（英語版以外の AutoCAD でも動くように）
;;   ・変換した個数を表示
;;   ・読み込み時にコマンド名を表示
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 と同じ
(defun c:RegionToPL ( / *error* ss si i ename last_ent exploded_ss next_ent first_ent is_spline rp-undo n-done)

  ;; エラー・Esc のときの後始末（Undo グループを閉じ、PEDITACCEPT を元に戻す）
  (defun *error* (msg)
    (if rp-undo (command-s "_.UNDO" "_E"))
    (if si (setvar "PEDITACCEPT" si))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

    (princ "\nリージョンをポリラインに変換します。")
    (if (setq ss (ssget '((0 . "REGION"))))
        (progn
            (command "_.UNDO" "_BE")
            (setq rp-undo T n-done 0)
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
                    (setq first_ent (ssname exploded_ss 0) n-done (1+ n-done))
                    
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
            (command "_.UNDO" "_E")
            (setq rp-undo nil)
            (princ (strcat "\n" (itoa n-done) " 個のリージョンをポリラインに変換しました。"))
        )
        (princ "\nリージョンが選択されませんでした。処理を中断します。")
    )
    (princ)
)

(defun c:RTP ()
    (c:RegionToPL)
    (princ)
)

(princ "\n[RegionToPL ver2] 読み込み完了  REGIONTOPL（RTP）＝リージョンをポリラインに変換")
(princ)

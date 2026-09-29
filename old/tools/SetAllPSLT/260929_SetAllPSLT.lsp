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

(defun c:SetAllPSLT (/ curLayout lay val oldcmdecho)
  (setq curLayout   (getvar "ctab"))
  (setq oldcmdecho  (getvar "cmdecho"))
  (setvar "cmdecho" 0)

  (princ "\n[SetAllPSLT] 全レイアウトの PSLTSCALE を一括変更します。")

  ;; 入力取得（0 または 1）
  (setq val (getint "\nPSLTSCALE値を入力してください (0 または 1): "))

  (cond
    ;; キャンセル（EscまたはEnterのみ）対応
    ((null val)
     (princ "\n処理を中止しました。"))
    
    ;; 入力値が 0 or 1 のときのみ処理
    ((member val '(0 1))
     
     (command "_.UNDO" "_BEGIN")

     (princ (strcat "\n[SetAllPSLT] 処理を開始します... (設定値 -> " (itoa val) ")"))

     ;; 全レイアウト巡回
     (foreach lay (layoutlist)
       (setvar "ctab" lay)
       (setvar "psltscale" val)
       (princ (strcat "\n処理中: " lay " -> psltscale=" (itoa val)))
     )

     ;; 元のレイアウトへ戻す
     (setvar "ctab" curLayout)

     ;; 再作図
     (command "_.REGENALL")

     (command "_.UNDO" "_END")

     (princ (strcat "\n完了: 全てのレイアウトで psltscale を " (itoa val) " にしました！"))
    )
    
    ;; 不正入力
    (t
     (princ "\n入力値が不正です。0 または 1 を指定してください。")
    )
  )

  ;; 設定を復元
  (setvar "cmdecho" oldcmdecho)
  (princ)
)
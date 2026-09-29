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
;; SetAllPSLT ver2（2026-09-29）
;;   ・途中で Esc・エラーになったとき、Undo グループを閉じ、元のレイアウトと CMDECHO に戻すようにした
;;   ・ショートカット SAP を追加した（SETALLPSLT もそのまま使えます）
;;   ・読み込んだときにコマンド名を表示するようにした
;;   ※ver1 のコマンド名・質問の順番・処理の結果は変わりません。

(defun c:SetAllPSLT (/ *error* curLayout lay val oldcmdecho sp-undo)

  ;; エラー・Esc のときの後始末（Undo グループを閉じ、元のレイアウトと CMDECHO に戻す）
  (defun *error* (msg)
    (if sp-undo (command-s "_.UNDO" "_END"))
    (if (and curLayout (/= (strcase (getvar "CTAB")) (strcase curLayout))) (setvar "CTAB" curLayout))
    (if oldcmdecho (setvar "CMDECHO" oldcmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )
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
     (setq sp-undo T)

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
     (setq sp-undo nil)

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

(defun c:SAP () (c:SetAllPSLT))   ; ショートカット

(princ "\n[SetAllPSLT ver2] 読み込み完了  SETALLPSLT（SAP）＝全レイアウトの PSLTSCALE を一括変更")
(princ)

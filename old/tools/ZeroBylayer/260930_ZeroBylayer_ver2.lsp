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
;; ZeroByLayer ver2（2026-09-29）
;;   ・終わったとき CMDECHO を「1」ではなく、実行前の値に戻すようにした（CMDECHO を 0 にしている人の設定を変えない）
;;   ・途中でエラーになったとき、Undo グループを閉じ、CMDECHO を元に戻すようにした
;;   ・読み込んだときにコマンド名を表示するようにした
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 から変わりません。
(defun c:ZeroByLayer ( / *error* old-cmdecho zb-undo)

  ;; エラー・Esc のときの後始末（Undo グループを閉じ、CMDECHO を元に戻す）
  (defun *error* (msg)
    (if zb-undo (command-s "_.UNDO" "_End"))
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  
  ;; Undo記録の開始
  (command "_.UNDO" "_Begin")
  (setq zb-undo T)
  
  ;; 現在の画層を「0」に設定
  (setvar "CLAYER" "0")
  
  ;; 各プロパティを「ByLayer」に設定
  (setvar "CECOLOR" "BYLAYER")   ; 色（文字列）
  (setvar "CELTYPE" "ByLayer")   ; 線種（文字列）
  (setvar "CELWEIGHT" -1)        ; 線の太さ（整数：-1 = ByLayer）
  (setvar "CETRANSPARENCY" -1)   ; 透過性（整数：-1 = ByLayer）
  
  ;; Undo記録の終了
  (command "_.UNDO" "_End")
  (setq zb-undo nil)
  
  (setvar "CMDECHO" old-cmdecho)          ; 実行前の値に戻す
  (princ "\n現在の画層を「0」にし、作成プロパティをすべて「ByLayer」にリセットしました。")
  (princ)
)

;; ショートカットコマンド：ZB
(defun c:ZB ()
  (c:ZeroByLayer)
  (princ)
)

(princ "\n[ZeroByLayer ver2] 読み込み完了  ZEROBYLAYER（ZB）＝現在の画層を 0、作成プロパティを ByLayer に")
(princ)

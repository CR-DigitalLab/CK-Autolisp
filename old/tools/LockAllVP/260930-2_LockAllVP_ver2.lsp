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
;; LockAllVP ver2（2026-09-30）
;;   ・ロックされた画層にあるビューポートは飛ばして続行し、その数を表示
;;   ・実行後、実行前のレイアウトに戻るように変更
;;   ・Undo グループを追加（実行後の U 1回で実行前に戻る）。エラー・Esc のときも元のレイアウトへ
;;   ・ロックしたビューポートの数を表示。変数をほかの LISP とぶつからないように整理
;;   ・読み込み時にコマンド名を表示
;;   ※コマンド名とロックする処理は ver1 と同じ
;; すべてのレイアウトのビューポートをロックする
(defun c:LockAllVP ( / *error* doc layouts orgLay lv-undo n skip vpid)
  (vl-load-com) ; COMライブラリをロード
  (setq doc (vla-get-ActiveDocument (vlax-get-Acad-Object)))

  ;; エラー・Esc のときの後始末（元のレイアウトに戻し、Undo グループを閉じる）
  (defun *error* (msg)
    (if orgLay (vl-catch-all-apply 'vla-put-ActiveLayout (list doc orgLay)))
    (if lv-undo (vla-EndUndoMark doc))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg)))
    (princ))

  (setq orgLay (vla-get-ActiveLayout doc))   ; 実行前のレイアウト
  (vla-StartUndoMark doc)
  (setq lv-undo T n 0 skip 0)

  ;; すべてのレイアウトを取得して処理
  (setq layouts (vla-get-Layouts doc)) ; レイアウトコレクションを取得

  (vlax-for layout layouts
    (vla-put-ActiveLayout doc layout) ; レイアウトをアクティブに設定

    ;; レイアウト内のビューポートを取得してロック
    (vlax-for obj (vla-get-Block layout)
      (if (eq (vla-get-ObjectName obj) "AcDbViewport") ; ビューポート判定
        (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-put-DisplayLocked (list obj :vlax-true))) ; ビューポートをロック
          (setq skip (1+ skip))                       ; ロック画層などで変更できなかったもの
          (progn
            ;; 用紙全体を表す内部のビューポート（番号1）は数えない
            (setq vpid (cdr (assoc 69 (entget (vlax-vla-object->ename obj)))))
            (if (/= vpid 1) (setq n (1+ n))))))))

  (vla-put-ActiveLayout doc orgLay)   ; 実行前のレイアウトに戻す
  (vla-EndUndoMark doc)
  (setq lv-undo nil)

  (princ "\nすべてのビューポートをロックしました。")
  (princ (strcat "（" (itoa n) " 個）"))
  (if (> skip 0)
    (princ (strcat "\n※ ロックされた画層にあるなどの理由で、" (itoa skip) " 個は変更できませんでした。")))
  (princ "\n")
  (princ))

(princ "\n[LockAllVP ver2] 読み込み完了  LOCKALLVP＝すべてのレイアウトのビューポートをロック")
(princ)

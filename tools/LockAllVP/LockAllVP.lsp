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
(defun c:LockAllVP ()
  (vl-load-com) ; COMライブラリをロード

  ;; すべてのレイアウトを取得して処理
  (setq layouts
        (vla-get-Layouts
          (vla-get-ActiveDocument
            (vlax-get-Acad-Object)))) ; レイアウトコレクションを取得

  (vlax-for layout layouts
    (vla-put-ActiveLayout
      (vla-get-ActiveDocument (vlax-get-Acad-Object))
      layout) ; レイアウトをアクティブに設定

    ;; レイアウト内のビューポートを取得してロック
    (vlax-for obj (vla-get-Block layout)
      (if (eq (vla-get-ObjectName obj) "AcDbViewport") ; ビューポート判定
        (vla-put-DisplayLocked obj :vlax-true))))      ; ビューポートをロック

  (princ "\nすべてのビューポートをロックしました。\n")
  (princ))
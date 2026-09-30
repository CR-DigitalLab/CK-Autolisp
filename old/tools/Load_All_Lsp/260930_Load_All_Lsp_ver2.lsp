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
;; Load_All_Lsp ver2（2026-09-29）
;;   ・フォルダの中の LISP が1つでもエラーになると、残りの LISP が読み込まれなかったのを直した（失敗したものは「読み込み失敗」と理由を表示して、続きを読み込む）
;;   ※読み込む LISP・順番・表示は ver1 から変わりません（失敗したときの表示だけ足しました）。
(vl-load-com)

(setq this-lisp-name "Load_all_lsp.lsp")

;; このLISPファイルのフルパスを取得
(setq full-path (findfile this-lisp-name))

(if full-path
  (progn
    ;; フォルダパスを抽出
    (setq target-dir (strcat (vl-filename-directory full-path) "\\"))
    
    ;; そのフォルダ内にあるすべての .lsp ファイルのリストを取得
    (setq lsp-list (vl-directory-files target-dir "*.lsp" 1))

    ;; ファイルリストをループ処理
    (if lsp-list
      (foreach lsp lsp-list
        ;; 自分自身（Load_all_lsp.lsp）は読み込まないように除外判定
        (if (/= (strcase lsp) (strcase this-lisp-name))
          (progn
            ;; 1つの LISP がエラーになっても、残りの LISP は続けて読み込む
            (setq lal-res (vl-catch-all-apply 'load (list (strcat target-dir lsp))))
            (if (vl-catch-all-error-p lal-res)
              (princ (strcat "\n読み込み失敗: " lsp "（" (vl-catch-all-error-message lal-res) "）"))
              (princ (strcat "\n読み込み完了: " lsp)))
          )
        )
      )
      (princ "\n同フォルダにLISPファイルが見つかりませんでした。")
    )
  )
  (princ (strcat "\nエラー: " this-lisp-name " のパスが取得できませんでした。"))
)

(princ)
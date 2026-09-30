;;------------------------------------------------------------------------------------;;
;; 【利用制限について】
;; 本スクリプトの全部または一部を、許可なく複製、転載、再配布、販売することを禁止します。
;;------------------------------------------------------------------------------------;;
;; CADSOZAI ver2（2026-09-29）
;;   ・文字コードを ANSI（Shift-JIS）にした（UTF-8 では AutoCAD のバージョンによって日本語が文字化けするため）
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 から変わりません。
(defun c:CADSOZAI ()
  (command "_.browser" "https://cad-freed-rawingsamples.com/sitemaps/")
  (princ) 
)

(defun c:TANUKISAN ()
  (c:CADSOZAI)
)

(princ "\n[CADSOZAI ver2] 「CADSOZAI」でCAD素材.comが開けます！")
(princ)
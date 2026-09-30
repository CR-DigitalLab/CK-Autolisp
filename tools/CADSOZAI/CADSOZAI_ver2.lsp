;;------------------------------------------------------------------------------------;;
;; 【利用制限について】
;; 本スクリプトの全部または一部を、許可なく複製、転載、再配布、販売することを禁止します。
;;------------------------------------------------------------------------------------;;
;; CADSOZAI ver2（2026-09-30）
;;   ・文字コードを ANSI（Shift-JIS）に変更（UTF-8 では AutoCAD のバージョンによって日本語が文字化けするため）
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 と同じ
(defun c:CADSOZAI ()
  (command "_.browser" "https://cad-freed-rawingsamples.com/sitemaps/")
  (princ) 
)

(defun c:TANUKISAN ()
  (c:CADSOZAI)
)

(princ "\n[CADSOZAI ver2] 「CADSOZAI」でCAD素材.comが開けます！")
(princ)
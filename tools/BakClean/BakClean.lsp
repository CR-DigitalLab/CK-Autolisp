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
(vl-load-com)

(defun C:BakClean ( / *error* old-cmdecho dwg-path bak-folder bak-files moved-count old-file new-file result-msg)
  
  (defun *error* (msg)
    (command-s "_.UNDO" "_E")
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*"))
      (princ (strcat "\nエラー: " msg))
    )
    (princ "\n処理を安全に終了しました。")
    (princ)
  )

  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.UNDO" "_BE")

  (if (= (getvar "DWGTITLED") 0)
    (setq result-msg "\n図面が保存されていません。一度図面を保存してから実行してください。")
    (progn
      (setq dwg-path (getvar "DWGPREFIX"))
      
      ;; ▼ フォルダの名前を変更する場合は、ここの「bakファイル」を変えてください ▼
      (setq bak-folder (strcat dwg-path "bakファイル"))
      
      (if (not (vl-file-directory-p bak-folder))
        (vl-mkdir bak-folder)
      )
      
      (setq bak-files (vl-directory-files dwg-path "*.bak" 1))
      (setq moved-count 0)
      
      (if bak-files
        (foreach file bak-files
          (setq old-file (strcat dwg-path file))
          (setq new-file (strcat bak-folder "\\" file))
          
          (if (findfile new-file)
            (vl-file-delete new-file)
          )
          
          (if (vl-file-rename old-file new-file)
            (setq moved-count (1+ moved-count))
          )
        )
      )
      
      (setq result-msg (strcat "\n" (itoa moved-count) " 個のbakファイルを整理しました。"))
    )
  )

  (command "_.UNDO" "_E")
  (setvar "CMDECHO" old-cmdecho)
  
  (princ result-msg)
  (princ)
)

;; ショートカット
(defun C:BC () (C:BakClean))

(princ "\nコマンド: BakClean (ショートカット: BC) がロードされました。")
(princ)
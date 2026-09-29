;;----------------------------------------------------------------------------;;
;; 【ご利用についてのお願い】
;; このコードは、作業効率化を目的として開発されたものです。
;; 個人利用や業務効率化のためにご活用いただけると幸いです。
;;
;; 【著作権および利用制限について】
;; 本スクリプトはCHIKOが著作権を保有しており、著作権によって保護されています。
;; 著作権表示は削除しないでください。
;; 個人利用、および所属する組織内での業務利用に限りご使用いただけます。
;; 本スクリプトの全部または一部を、許可なく複製、転載、再配布、販売することを禁止します。
;;----------------------------------------------------------------------------;;
(defun c:REVCLAUTO (/ *error* p1 p2 width height short-side arc-factor arc-length old-cmdecho old-osmode rect-ent cloud-ent result-msg)

  (defun *error* (msg)
    (setvar "CMDECHO" 0)
    (command-s "_.UNDO" "_E")
    
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if old-osmode (setvar "OSMODE" old-osmode))
    
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*QUIT*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
      (princ "\n*キャンセル*")
    )
    (princ)
  )

  (setq old-cmdecho (getvar "CMDECHO"))
  (setq old-osmode (getvar "OSMODE"))
  (setq result-msg nil) 
  
  (setvar "CMDECHO" 0)
  (command "_.UNDO" "_BE")
  
  (setq arc-factor 5.0)
  
  (setq p1 (getpoint "\n1 点目のコーナーを指定: "))
  (if p1
    (progn
      (setq p2 (getcorner p1 "\nもう一方のコーナーを指定: "))
      (if p2
        (progn
          (setvar "OSMODE" 0) 
          
          (setq width (abs (- (car p1) (car p2))))
          (setq height (abs (- (cadr p1) (cadr p2))))
          
          (if (< width height)
            (setq short-side width)
            (setq short-side height)
          )
          
          (if (> short-side 0.0001)
            (progn
              (setq arc-length (float (fix (+ (* (sqrt short-side) arc-factor) 0.5))))
              (if (< arc-length 1.0) (setq arc-length 1.0))
              
              (command "_.RECTANG" "_non" p1 "_non" p2)
              (setq rect-ent (entlast))
              
              (command "_.REVCLOUD" "_A" arc-length arc-length "_O" rect-ent "_N")
              (setq cloud-ent (entlast))
              
              (if (and (not (equal rect-ent cloud-ent)) (entget rect-ent))
                (entdel rect-ent)
              )
              
              (setq result-msg (strcat "\n円弧サイズ " (rtos arc-length 2 0) " で雲マークを作成しました。"))
            )
            (setq result-msg "\n無効なサイズです。")
          )
        )
        (setq result-msg "\n*キャンセル*")
      )
    )
    (setq result-msg "\n*キャンセル*")
  )
  
  (command "_.UNDO" "_E")
  
  (if old-osmode (setvar "OSMODE" old-osmode))
  (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
  
  (if result-msg (princ result-msg))
  
  (princ)
)

;; ショートカット
(defun c:RA () (c:REVCLAUTO))

(princ "\nREVCLAUTO.lsp がロードされました。コマンド: REVCLAUTO または RA を実行してください。")
(princ)
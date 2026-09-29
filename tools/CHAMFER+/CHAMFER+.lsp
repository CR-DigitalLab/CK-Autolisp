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
(defun c:CHAMFER+ ( / *error* old_cmdecho curA curB curFace sel userLen calcDist loop defFaceWidth)
  (defun *error* (msg)
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (if (= (getvar "UNDOCTL") 8) (command "_.UNDO" "_END"))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  
  (setq curA (getvar "CHAMFERA"))
  (setq curB (getvar "CHAMFERB"))

  ;; --- 追加: 値が0の場合はデフォルト面幅15を設定 ---
  (if (equal curA 0.0 0.0001)
    (progn
      (setq defFaceWidth 15.0) ; ★ここにデフォルト値を設定
      (setq curA (/ defFaceWidth (sqrt 2.0)))
      (setvar "CHAMFERA" curA)
      (setvar "CHAMFERB" curA)
      ;; (princ "\n初期値として面幅を15に設定しました。") ; 必要であればコメントアウトを外す
    )
  )
  ;; ----------------------------------------------------

  (if (not (equal curA curB 0.0001))
    (progn
      (setvar "CHAMFERB" curA)
      (princ "\n現在の設定値が不均等なため、距離1=距離2に統一しました。")
    )
  )
  
  (setq loop T)
  
  (while loop
    (setq curA (getvar "CHAMFERA"))
    (setq curFace (* curA (sqrt 2.0)))

    (initget "Face")
    (setq sel 
      (entsel 
        (strcat "\nCHAMFER+ 1本目の線を選択 または [面幅設定(F)] <現在の面幅: " (rtos curFace 2 2) ">: ")
      )
    )

    (command "_.UNDO" "_BEGIN")

    (cond
      ((= sel "Face")
        (initget 6)
        (setq userLen (getdist (strcat "\n新しい面幅(斜距離)を指定してください <" (rtos curFace 2 2) ">: ")))
        (if userLen
          (progn
            (setq calcDist (/ userLen (sqrt 2.0)))
            (setvar "CHAMFERA" calcDist)
            (setvar "CHAMFERB" calcDist)
            (princ (strcat "\n面幅を " (rtos userLen 2 2) " に設定しました。"))
          )
        )
        (command "_.UNDO" "_END")
      )

      ((listp sel)
        (setvar "CMDECHO" 1)
        (command "_.CHAMFER" (cadr sel))
        (while (> (getvar "CMDACTIVE") 0)
          (command pause)
        )
        (setvar "CMDECHO" 0)
        (command "_.UNDO" "_END")
      )

      (t
        (command "_.UNDO" "_END")
        (setq loop nil)
      )
    )
  )

  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

(defun c:CF ()
  (c:CHAMFER+)
)
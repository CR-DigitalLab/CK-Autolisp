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
;; CopyBlock ver2（2026-09-30）
;;   ・エラー処理の書き方を修正
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 と同じ
(vl-load-com)

(defun c:copyblock ( / *error* doc ent edata vlaEnt oldName defName inc newName blks 
                       lastEnt newEnt oldAttReq oldClayer oldLayer oldScaleX oldScaleY 
                       oldScaleZ oldRot rotStr newVlaEnt attList oldAtts newAtts match objCount objArray i oldBlkDef newBlkDef)
  
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq oldAttReq (getvar "ATTREQ"))
  (setq oldClayer (getvar "CLAYER"))

  (defun *error* (msg)
    (if oldAttReq (setvar "ATTREQ" oldAttReq))
    (if oldClayer (setvar "CLAYER" oldClayer))
    (if (and msg (not (wcmatch (strcase msg t) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (vla-EndUndoMark doc)
    (princ)
  )

  (vla-StartUndoMark doc)

  (setq blks (vla-get-blocks doc))

  (if (setq ent (car (entsel "\nコピー元となるブロックを選択(※ダイナミックブロックは非対応): ")))
    (progn
      (setq edata (entget ent))
      (if (= (cdr (assoc 0 edata)) "INSERT")
        (progn
          (setq vlaEnt (vlax-ename->vla-object ent))
          
          (setq oldName (vl-catch-all-apply 'vla-get-EffectiveName (list vlaEnt)))
          (if (vl-catch-all-error-p oldName)
            (setq oldName (vla-get-name vlaEnt))
          )

          (if (= (vla-get-IsDynamicBlock vlaEnt) :vlax-true)
            (princ "\n ※選択されたブロックはダイナミックブロックです。コピー後は通常のブロックになります。")
          )

          (setq oldLayer  (vla-get-layer vlaEnt))
          (setq oldScaleX (vla-get-XScaleFactor vlaEnt))
          (setq oldScaleY (vla-get-YScaleFactor vlaEnt))
          (setq oldScaleZ (vla-get-ZScaleFactor vlaEnt))
          (setq oldRot    (vla-get-Rotation vlaEnt))
          (setq rotStr    (angtos oldRot))

          (setq attList nil)
          (if (= (vla-get-HasAttributes vlaEnt) :vlax-true)
            (progn
              (setq oldAtts (vlax-invoke vlaEnt 'GetAttributes))
              (foreach att oldAtts
                (setq attList (cons (cons (vla-get-TagString att) (vla-get-TextString att)) attList))
              )
            )
          )

          (setq inc 1)
          (while (tblsearch "BLOCK" (setq defName (strcat oldName "_" (itoa inc))))
            (setq inc (1+ inc))
          )

          (setq newName (getstring T (strcat "\n新しいブロック名を入力 <" defName "> 【※そのままEnterキーで決定】: ")))
          (if (or (= newName "") (= newName nil))
            (setq newName defName)
          )

          (if (tblsearch "BLOCK" newName)
            (princ (strcat "\nエラー: ブロック名 '" newName "' は既に存在します。"))
            (progn
              
              (setq oldBlkDef (vla-item blks oldName))
              (setq newBlkDef (vla-add blks (vlax-3d-point '(0 0 0)) newName))
              
              (setq objCount (vla-get-count oldBlkDef))
              (if (> objCount 0)
                (progn
                  (setq objArray (vlax-make-safearray vlax-vbObject (cons 0 (1- objCount))))
                  (setq i 0)
                  (vlax-for obj oldBlkDef
                    (vlax-safearray-put-element objArray i obj)
                    (setq i (1+ i))
                  )
                  (vla-CopyObjects doc objArray newBlkDef)
                )
              )

              (setq lastEnt (entlast))
              (princ (strcat "\nブロック [" newName "] の配置位置を指定してください: "))
              
              (setvar "CLAYER" oldLayer)
              (setvar "ATTREQ" 0)

              (command "._-INSERT" newName "_X" oldScaleX "_Y" oldScaleY "_Z" oldScaleZ "_R" rotStr pause)

              (setvar "CLAYER" oldClayer)
              (setvar "ATTREQ" oldAttReq)

              (if (not (equal lastEnt (setq newEnt (entlast))))
                (progn
                  (setq newVlaEnt (vlax-ename->vla-object newEnt))
                  
                  (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-get-Color (list vlaEnt))))
                    (vla-put-Color newVlaEnt (vla-get-Color vlaEnt))
                  )
                  (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-get-Linetype (list vlaEnt))))
                    (vla-put-Linetype newVlaEnt (vla-get-Linetype vlaEnt))
                  )
                  (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-get-Lineweight (list vlaEnt))))
                    (vla-put-Lineweight newVlaEnt (vla-get-Lineweight vlaEnt))
                  )

                  (if (and attList (= (vla-get-HasAttributes newVlaEnt) :vlax-true))
                    (progn
                      (setq newAtts (vlax-invoke newVlaEnt 'GetAttributes))
                      (foreach att newAtts
                        (if (setq match (assoc (vla-get-TagString att) attList))
                          (vla-put-TextString att (cdr match))
                        )
                      )
                    )
                  )
                  
                  (princ (strcat "\n完了: 新しいブロック [" newName "] を作成・配置しました。"))
                )
                (princ "\n配置がキャンセルされました。")
              )
            )
          )
        )
        (princ "\nエラー: 選択されたオブジェクトはブロックではありません。")
      )
    )
    (princ "\nキャンセルされました。")
  )

  (vla-EndUndoMark doc)
  (princ)
)

(defun c:CB () (c:copyblock))

(princ "\n[CopyBlock ver2] ロード完了: 'copyblock' または 'cb' と入力して実行してください。")
(princ)
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
(defun c:Xforce (/ *error* doc layers ss i ent obj layName layObj blkName blkDef newObjsArr newObjsList finalSS x skipCount msg)
  (vl-load-com)
  
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq layers (vla-get-layers doc)) 
  (setq finalSS (ssadd)) 
  (setq skipCount 0) 

  (princ "\n強制分解したいブロックを選択してください: ")
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (vla-startundomark doc)
      
      (repeat (setq i (sslength ss))
        (setq ent (ssname ss (setq i (1- i))))
        (setq obj (vlax-ename->vla-object ent))
        
        (setq layName (vla-get-Layer obj))
        (setq layObj (vla-item layers layName))
        
        ;; ロックされていない場合(:vlax-false)のみ分解処理へ進む
        (if (= (vla-get-Lock layObj) :vlax-false)
          (progn
            ;; 1. ブロック定義の「分解許可」を強制的にONにする
            (setq blkName (vla-get-EffectiveName obj))
            (setq blkDef (vla-item (vla-get-blocks doc) blkName))
            
            (if (= (vla-get-explodable blkDef) :vlax-false)
              (vla-put-explodable blkDef :vlax-true)
            )

            ;; 2. 分解を実行
            (if (not (vl-catch-all-error-p 
                       (setq newObjsArr (vl-catch-all-apply 'vla-explode (list obj)))))
              (progn
                ;; 分解後のオブジェクトを取得
                (setq newObjsList (vlax-variant-value newObjsArr))
                
                ;; 配列に中身がある場合のみ処理
                (if (> (safearray-get-u-bound newObjsList 1) -1)
                  (progn
                    (setq newObjsList (vlax-safearray->list newObjsList))
                    
                    ;; 3. 新しいオブジェクトを最終選択セットに追加
                    (foreach x newObjsList
                      (ssadd (vlax-vla-object->ename x) finalSS)
                    )
                    
                    ;; 元のブロックを削除
                    (vla-delete obj)
                  )
                )
              )
            )
          )
          ;; --- 画層がロックされている場合はカウントを増やす ---
          (setq skipCount (1+ skipCount))
        )
      )
      
      (vla-endundomark doc)

      ;; 4. 結果を選択状態にする
      (if (> (sslength finalSS) 0)
        (progn
          (sssetfirst nil finalSS)
          (setq msg (strcat "\n" (itoa (sslength finalSS)) " 個の要素に分解・選択しました。"))
          ;; スキップしたブロックがあれば追記
          (if (> skipCount 0)
            (setq msg (strcat msg " (ロック画層のブロック " (itoa skipCount) " 個をスキップ)"))
          )
          (princ msg)
        )
        (progn
          (if (> skipCount 0)
            (princ (strcat "\n選択したブロックはロックされた画層にあります (スキップ: " (itoa skipCount) " 個)。"))
            (princ "\n分解できませんでした。")
          )
        )
      )
    )
    (princ "\nブロックが選択されていません。")
  )
  (princ)
)

(defun c:XF () (c:Xforce))
(princ)
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
;; LPON・LPOFF ver2（2026-09-30）
;;   ・画層に「印刷する／しない」の情報が書かれていない場合にも対応
;;   ・エラー処理の書き方を修正
;;   ・読み込み時にコマンド名を表示
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 と同じ

(vl-load-com) 

;;; ===================================================================
;;; コマンド: LAYERPLOTOFF (LPOFF)
;;; 機能: 選択したオブジェクトの画層を【非印刷】にする
;;; ===================================================================
(defun c:LAYERPLOTOFF (/ *error* doc ss i ent layname layer_list lay_ent lay_dxf)
  
  ;; エラーハンドラ（Escなどで中断した際にUndoを閉じる）
  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (if (and msg (not (wcmatch (strcase msg t) "*break*,*cancel*,*exit*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc) ; Undoグループ開始

  (prompt "\n画層を【非印刷】にするオブジェクトを選択: ")
  (if (setq ss (ssget)) ; オブジェクトを選択
    (progn
      (setq layer_list '()) ; 処理する画層リストの初期化
      (setq i 0)
      ;; 選択セットから画層名を取得し、リスト化（重複を除く）
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq layname (cdr (assoc 8 (entget ent))))
        (if (not (member layname layer_list))
          (setq layer_list (cons layname layer_list))
        )
        (setq i (1+ i))
      )
      
      ;; リスト内の画層設定を変更
      (foreach lay layer_list
        (setq lay_ent (tblobjname "LAYER" lay)) ; 画層のエンティティ名取得
        (if lay_ent
          (progn
            (setq lay_dxf (entget lay_ent))
            ;; DXFコード 290: 1=印刷可, 0=印刷不可
            (setq lay_dxf (if (assoc 290 lay_dxf)
                              (subst (cons 290 0) (assoc 290 lay_dxf) lay_dxf)
                              (append lay_dxf (list (cons 290 0)))))   ; 印刷の設定が書かれていない画層にも対応
            (entmod lay_dxf) ; 更新
          )
        )
      )
      
      ;; 変更した画層名を通知
      (princ "\n\n=== 以下の画層を非印刷に設定しました ===")
      (foreach lay (vl-sort layer_list '<) ; 名前順にソートして表示
        (princ (strcat "\n・" lay))
      )
      (prompt (strcat "\n\n合計 " (itoa (length layer_list)) " 個の画層を非印刷に設定しました。"))
    )
    (prompt "\n選択されませんでした。")
  )
  
  (vla-EndUndoMark doc) ; Undoグループ終了
  (princ)
)

;;; 短縮コマンド
(defun c:LPOFF () (c:LAYERPLOTOFF))


;;; ===================================================================
;;; コマンド: LAYERPLOTON (LPON)
;;; 機能: 選択したオブジェクトの画層を【印刷可能】にする
;;; ===================================================================
(defun c:LAYERPLOTON (/ *error* doc ss i ent layname layer_list lay_ent lay_dxf defpoints_skipped)
  
  ;; エラーハンドラ
  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (if (and msg (not (wcmatch (strcase msg t) "*break*,*cancel*,*exit*")))
      (princ (strcat "\nエラー: " msg))
    )
    (princ)
  )

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc) ; Undoグループ開始
  (setq defpoints_skipped nil) ; Defpointsスキップフラグ

  (prompt "\n画層を【印刷可能】にするオブジェクトを選択: ")
  (if (setq ss (ssget))
    (progn
      (setq layer_list '())
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq layname (cdr (assoc 8 (entget ent))))
        
        ;; Defpointsかどうかのチェック（大文字小文字区別なし）
        (if (= (strcase layname) "DEFPOINTS")
          (setq defpoints_skipped T) ; Defpointsならフラグを立ててリストには入れない
          (if (not (member layname layer_list))
            (setq layer_list (cons layname layer_list))
          )
        )
        (setq i (1+ i))
      )
      
      (if layer_list
        (progn
          (foreach lay layer_list
            (setq lay_ent (tblobjname "LAYER" lay))
            (if lay_ent
              (progn
                (setq lay_dxf (entget lay_ent))
                ;; DXFコード 290: 1=印刷可
                (setq lay_dxf (if (assoc 290 lay_dxf)
                                  (subst (cons 290 1) (assoc 290 lay_dxf) lay_dxf)
                                  (append lay_dxf (list (cons 290 1)))))   ; 印刷の設定が書かれていない画層にも対応
                (entmod lay_dxf)
              )
            )
          )

          ;; 変更した画層名を通知
          (princ "\n\n=== 以下の画層を印刷可能に設定しました ===")
          (foreach lay (vl-sort layer_list '<) ; 名前順にソートして表示
            (princ (strcat "\n・" lay))
          )
          (prompt (strcat "\n\n合計 " (itoa (length layer_list)) " 個の画層を印刷可能に設定しました。"))
        )
        (prompt "\n変更可能な画層が選択されませんでした。")
      )

      ;; Defpointsが選択されていた場合の通知
      (if defpoints_skipped
        (prompt "\n\n※ Defpoints画層が含まれていましたが、AutoCADの仕様により印刷可能にできないためスキップしました。")
      )
    )
    (prompt "\n選択されませんでした。")
  )
  
  (vla-EndUndoMark doc) ; Undoグループ終了
  (princ)
)

;;; 短縮コマンド
(defun c:LPON () (c:LAYERPLOTON))

(princ "\n[LPON・LPOFF ver2] 読み込み完了  LAYERPLOTOFF（LPOFF）＝非印刷に / LAYERPLOTON（LPON）＝印刷可能に")
(princ)

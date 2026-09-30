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
;; FlattenFast ver2（2026-09-29）
;;   ・Undo グループを付けた（実行後の U 1回で実行前に戻る）
;;   ・Esc で中止したときに「Error: Function cancelled」と出ないようにした
;;   ・読み込んだときにコマンド名を表示するようにした
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 から変わりません。
(defun c:FLATTENFAST( / *error* old_osmode old_cmdecho ss i en edata flatten-ent ff-undo)
  
  ;; --- エラーハンドラ ---
  (defun *error* (msg)
    (if ff-undo (command-s "_.UNDO" "_E"))   ; 開いた Undo グループを閉じる
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))   ; Esc のときは表示しない
      (princ (strcat "\nError: " msg)))
    (princ)
  )

  ;; --- サブ関数：平坦化する ---
  (defun flatten-ent (ent / edata new_edata pair code value)
    (setq edata (entget ent))
    (setq new_edata '())
    (foreach pair edata
      (setq code (car pair))
      (setq value (cdr pair))
      (cond
        ;; 座標値 (10-18) のZを0にする
        ((and (>= code 10) (<= code 18) (listp value) (= (length value) 3))
         (setq new_edata (cons (cons code (list (car value) (cadr value) 0.0)) new_edata))
        )
        ;; 厚み(39)、標高(38)を0にする
        ((or (= code 38) (= code 39))
         (setq new_edata (cons (cons code 0.0) new_edata))
        )
        ;; 押し出し方向(210)をリセット
        ((= code 210)
         (setq new_edata (cons (cons code '(0.0 0.0 1.0)) new_edata))
        )
        (t (setq new_edata (cons pair new_edata)))
      )
    )
    (entmod (reverse new_edata))
  )

  ;; --- メイン処理 ---
  (setq old_osmode (getvar "OSMODE"))
  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "OSMODE" 0)
  (setvar "CMDECHO" 0)
  
  (if (setq ss (ssget "_:L" '((-4 . "<NOT") (0 . "VIEWPORT") (-4 . "NOT>"))))
    (progn
      (command "_.UNDO" "_BE")
      (setq ff-undo T)
      (setq i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        
        (flatten-ent en)

        (if (= (cdr (assoc 66 (entget en))) 1)
          (progn
            (setq en (entnext en))
            (while (and en (/= (cdr (assoc 0 (entget en))) "SEQEND"))
              (flatten-ent en)      
              (setq en (entnext en)) 
            )
          )
        )
        
        (entupd (ssname ss i))
        
        (setq i (1+ i))
      )
      (command "_.UNDO" "_E")
      (setq ff-undo nil)
      (princ (strcat "\n" (itoa (sslength ss)) "個のオブジェクトのZ座標を0にしました！"))
    )
    (princ "\nオブジェクトが選択されませんでした。")
  )

  (setvar "OSMODE" old_osmode)
  (setvar "CMDECHO" old_cmdecho)
  (princ)
)

(defun c:FTF () (c:FLATTENFAST))

(princ "\n[FlattenFast ver2] 読み込み完了  FLATTENFAST（FTF）＝選んだ図形の Z 座標を 0 に")
(princ)
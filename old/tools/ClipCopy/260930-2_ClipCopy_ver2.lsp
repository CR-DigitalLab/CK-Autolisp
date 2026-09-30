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
;; ClipCopy ver2（2026-09-30）
;;   ・Undo グループを追加（実行後の U 1回で実行前に戻る）
;;   ・途中でエラーになったとき、自動で実行前の状態に戻す処理を追加
;;   ・選択の書き方を「_C」に変更（英語版以外の AutoCAD でも確実に動くように）
;;   ・読み込み時にコマンド名を表示
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 と同じ
(defun c:ClipCopy ( / *error* p1 p2 basePt ss blkName blkRef oldOsmode oldAttReq oldCmdecho minX minY maxX maxY dx dy zp1 zp2 cc-undo cc-mid )
  
  ;; エラー処理
  (defun *error* ( msg )
    ;; 開いた Undo グループを閉じる。図形をブロックにした後で止まったときは、元に戻す
    (if cc-undo
      (progn
        (command-s "_.UNDO" "_E")
        (if cc-mid
          (progn (command-s "_.U") (princ "\n途中で止まったため、実行前の状態に戻しました。")))))
    (if oldOsmode (setvar "OSMODE" oldOsmode))
    (if oldAttReq (setvar "ATTREQ" oldAttReq))
    (if oldCmdecho (setvar "CMDECHO" oldCmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラーまたはキャンセル: " msg))
    )
    (princ)
  )

  (setq oldCmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  
  (setq p1 (getpoint "\nクリップ範囲の1点目を指定: "))
  (if p1
    (progn
      (setq p2 (getcorner p1 "\n対角の2点目を指定: "))
      (if p2
        (progn
          ;; 基点を2点目(p2)に設定
          (setq basePt p2)
          
          (setq minX (min (car p1) (car p2)))
          (setq minY (min (cadr p1) (cadr p2)))
          (setq maxX (max (car p1) (car p2)))
          (setq maxY (max (cadr p1) (cadr p2)))
          (setq dx (* (- maxX minX) 0.05))
          (setq dy (* (- maxY minY) 0.05))
          (setq zp1 (list (- minX dx) (- minY dy)))
          (setq zp2 (list (+ maxX dx) (+ maxY dy)))
          
          (command "_.ZOOM" "_W" zp1 zp2)
          (setq ss (ssget "_C" p1 p2))
          (command "_.ZOOM" "_P") ; 元のズーム倍率に戻す
          
          (if ss
            (progn
              (setq oldOsmode (getvar "OSMODE"))
              (setq oldAttReq (getvar "ATTREQ"))
              (setvar "OSMODE" 0)
              (setvar "ATTREQ" 0)
              
              (setq blkName (strcat "CLIP_" (rtos (* (getvar "CDATE") 100000000) 2 0)))
              
              (command "_.UNDO" "_BE")
              (setq cc-undo T cc-mid T)
              (command "_.BLOCK" blkName "_NON" basePt ss "")
              (command "_.INSERT" blkName "_NON" basePt 1 1 0)
              (setq blkRef (entlast))
              
              (command "_.XCLIP" blkRef "" "_N" "_R" "_NON" p1 "_NON" p2)
              
              (command "_.COPYBASE" "_NON" basePt blkRef "")
              
              (entdel blkRef)
              (command "_.OOPS")
              (setq cc-mid nil)
              (command "_.UNDO" "_E")
              (setq cc-undo nil)
              
              (setvar "OSMODE" oldOsmode)
              (setvar "ATTREQ" oldAttReq)
              
              (princ (strcat "\n基点コピー完了 [ブロック名: " blkName "]"))
            )
            (princ "\n範囲内にオブジェクトがありませんでした。")
          )
        )
      )
    )
  )
  (setvar "CMDECHO" oldCmdecho)
  (princ)
)

(defun c:CLC () (c:ClipCopy))

(princ "\n[ClipCopy ver2] 読み込み完了  CLIPCOPY（CLC）＝指定範囲をクリップして基点コピー")
(princ)

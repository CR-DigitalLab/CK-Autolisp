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
(defun c:SolidToHatch ( / *error* doc ss i ent vla-ent edata 
                          p1 p2 p3 p4 pts p-arr poly loop-arr hatch 
                          spc elev normal )
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))

  ;; エラーハンドラ
  (defun *error* ( msg )
    (if (not (wcmatch (strcase msg t) "*BREAK*,*CANCEL*,*EXIT*"))
      (princ (strcat "\nエラー: " msg))
    )
    (vla-EndUndoMark doc)
    (princ)
  )

  (vla-StartUndoMark doc)

  (princ "\n変換する2Dソリッド(SOLID)を選択してください: ")
  (if (setq ss (ssget ":L" '((0 . "SOLID"))))
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq vla-ent (vlax-ename->vla-object ent))
        (setq edata (entget ent))
        
        ;; 頂点座標の取得
        (setq p1 (cdr (assoc 10 edata)))
        (setq p2 (cdr (assoc 11 edata)))
        (setq p3 (cdr (assoc 12 edata)))
        (setq p4 (cdr (assoc 13 edata)))
        
        ;; 三角形と四角形の判定・頂点順序の整理
        (if (equal p3 p4 1e-8)
          (setq pts (list p1 p2 p3))      ; 三角形
          (setq pts (list p1 p2 p4 p3))   ; 四角形 (境界ループ順序 1-2-4-3)
        )
        
        ;; 所属空間の取得
        (setq spc (vla-ObjectIdToObject doc (vla-get-OwnerId vla-ent)))
        
        ;; 座標配列の作成
        (setq p-arr (vlax-make-safearray vlax-vbDouble (cons 0 (1- (* 2 (length pts))))))
        (vlax-safearray-fill p-arr (apply 'append (mapcar '(lambda (p) (list (car p) (cadr p))) pts)))
        
        ;; 共通の高度と法線の取得
        (setq elev (caddr p1))
        (setq normal (if (assoc 210 edata) (cdr (assoc 210 edata)) '(0.0 0.0 1.0)))

        ;; 境界ポリラインの生成と空間設定
        (setq poly (vla-AddLightWeightPolyline spc p-arr))
        (vla-put-Closed poly :vlax-true)
        (vla-put-Elevation poly elev)
        (vla-put-Normal poly (vlax-3d-point normal))
        
        ;; ハッチング生成
        (setq hatch (vla-AddHatch spc 0 "SOLID" :vlax-false))
        (vla-put-Normal hatch (vlax-3d-point normal))
        (vla-put-Elevation hatch elev)
        
        ;; 境界ループ
        (setq loop-arr (vlax-make-safearray vlax-vbObject '(0 . 0)))
        (vlax-safearray-put-element loop-arr 0 poly)
        (vla-AppendOuterLoop hatch loop-arr)
        (vla-Evaluate hatch)
        
        ;; プロパティの移行
        (vla-put-Layer hatch (vla-get-Layer vla-ent))
        (vla-put-Color hatch (vla-get-Color vla-ent))
        (vla-put-Linetype hatch (vla-get-Linetype vla-ent))
        (vla-put-Lineweight hatch (vla-get-Lineweight vla-ent))
        (vla-put-LinetypeScale hatch (vla-get-LinetypeScale vla-ent))
        
        ;; 印刷スタイルの移行
        (if (vlax-property-available-p vla-ent 'PlotStyleName)
          (vl-catch-all-apply 'vla-put-PlotStyleName (list hatch (vla-get-PlotStyleName vla-ent)))
        )
        
        ;; TrueColorの移行
        (if (vlax-property-available-p vla-ent 'TrueColor)
          (vla-put-TrueColor hatch (vla-get-TrueColor vla-ent))
        )
        
        ;; 透過性の移行
        (if (vlax-property-available-p vla-ent 'EntityTransparency)
          (vla-put-EntityTransparency hatch (vla-get-EntityTransparency vla-ent))
        )
        
        ;; 不要になった元オブジェクトと境界の削除
        (vla-Delete poly)
        (vla-Delete vla-ent)
        
        (setq i (1+ i))
      )
      (princ (strcat "\n" (itoa i) " 個の2Dソリッドをハッチングに変換しました。"))
    )
    (princ "\n対象が選択されませんでした（またはロックされた画層のオブジェクトのみが選択されました）。")
  )
  
  (vla-EndUndoMark doc)
  (princ)
)

(defun c:STH ()
  (c:SolidToHatch)
  (princ)
)

(princ "\nコマンド「SolidToHatch」またはショートカット「STH」で変換を実行します。")
(princ)
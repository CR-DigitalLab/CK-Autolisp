;;; =========================================================================
;;; 程式名稱: chh.lsp (指定長寬矩形磁磚 Hatch 生成器 - 雙向自動疊加版)
;;; 指令名稱: CHH
;;; 功能特點: 1. 支援獨立輸入長度 (L) 與 寬度 (W)，完美生成矩形磁磚 (如 600x300)
;;;           2. 自動記憶上次使用的長寬尺寸
;;;           3. 支援「選取物件 (S)」與「點擊內部點 (P)」
;;;           4. 自動關閉 OSNAP 防止鎖點造成邊界失效
;;; =========================================================================

(vl-load-com)

(defun c:chh ( / oldEcho oldOsnap oldHpName oldHpSpace oldHpDouble oldHpAng len wid mode selSS pt angPt1 angPt2 deltaX deltaY angle)
  ;; 備份原始系統變數
  (setq oldEcho (getvar "CMDECHO"))
  (setq oldOsnap (getvar "OSMODE"))
  (setq oldHpName (getvar "HPNAME"))
  (setq oldHpSpace (getvar "HPSPACE"))
  (setq oldHpDouble (getvar "HPDOUBLE"))
  (setq oldHpAng (getvar "HPANG"))

  (setvar "CMDECHO" 0)
  (command "._undo" "_begin")

  ;; 1. 初始化全域預設長寬尺寸 (預設 600 x 300 mm)
  (if (not *CHH_TILE_LEN*) (setq *CHH_TILE_LEN* 600.0))
  (if (not *CHH_TILE_WID*) (setq *CHH_TILE_WID* 300.0))

  (princ (strcat "\n[CHH 磁磚 Hatch 生成器] 當前預設尺寸: " 
                 (rtos *CHH_TILE_LEN* 2 1) " x " (rtos *CHH_TILE_WID* 2 1) " mm"))

  ;; 2. 輸入方形/矩形磁磚的長度與寬度
  (setq len (getdist (strcat "\n請輸入磁磚【長度 L】(mm) <" (rtos *CHH_TILE_LEN* 2 1) ">: ")))
  (if (and len (> len 0))
    (setq *CHH_TILE_LEN* len)
    (setq len *CHH_TILE_LEN*)
  )

  (setq wid (getdist (strcat "\n請輸入磁磚【寬度 W】(mm) <" (rtos *CHH_TILE_WID* 2 1) ">: ")))
  (if (and wid (> wid 0))
    (setq *CHH_TILE_WID* wid)
    (setq wid *CHH_TILE_WID*)
  )
  ;; 3. 選擇角度，使用第一基準點與第二基準點來決定 Hatch 角度
  (setq angPt1 (getpoint "\n請指定第一基準點 (Hatch 角度起點): "))
  (setq angPt2 (getpoint angPt1 "\n請指定第二基準點 (Hatch 角度終點): "))
  (if (and angPt1 angPt2)
    (progn
      (setq deltaX (- (car angPt2) (car angPt1)))
      (setq deltaY (- (cadr angPt2) (cadr angPt1)))
      (setq angle (atan deltaY deltaX))
      (setvar "HPANG" angle)
      (princ (strcat "\n已設定 Hatch 角度為: " (rtos (* angle (/ 180.0 pi)) 2 2) " 度"))
    )
    (progn
      (setq angle 0.0)
      (setvar "HPANG" angle)
      (princ "\n未指定基準點，Hatch 角度預設為 0 度")
    )
  )
  ;; 4. 選擇操作模式：選取物件 (S) 或 點擊內部點 (P)
  (initget "S P s p")
  (setq mode (getkword "\n請選擇生成方式 [選取物件(S) / 點擊內部點(P)] <S>: "))
  (if (not mode) (setq mode "S"))

  ;; 5. 判斷長寬是否相同，自動選擇生成策略
  (cond
    ;; -----------------------------------------------------------------
    ;; 模式 A：選取既有閉合物件 (LWPOLYLINE, POLYLINE, CIRCLE, etc.)
    ;; -----------------------------------------------------------------
    ((or (= mode "S") (= mode "s"))
     (princ "\n請選擇要填滿磁磚的閉合物件: ")
     (setq selSS (ssget '((0 . "LWPOLYLINE,POLYLINE,CIRCLE,ELLIPSE,SPLINE,REGION"))))
     (if selSS
       (progn
         (if (= len wid)
           ;; 正方形：使用單一雙向 Hatch
           (progn
             (setvar "HPNAME" "_USER")
             (setvar "HPSPACE" len)
             (setvar "HPDOUBLE" 1)
             (setvar "HPANG" angle)
             (command "._-hatch" "_S" selSS "" "")
           )
           ;; 矩形：疊加橫向與豎向兩組 Hatch
           (progn
             ;; 第 1 層：橫向平行線 (間距 = 寬度 wid)
             (setvar "HPNAME" "_USER")
             (setvar "HPSPACE" wid)
             (setvar "HPDOUBLE" 0)
             (setvar "HPANG" angle)
             (command "._-hatch" "_S" selSS "" "")
             
             ;; 第 2 層：與自訂角度垂直的平行線 (間距 = 長度 len)
             (setvar "HPSPACE" len)
             (setvar "HPANG" (+ angle (/ pi 2.0)))
             (command "._-hatch" "_S" selSS "" "")
           )
         )
         (princ (strcat "\n[成功] 已生成 " (rtos len 2 1) " x " (rtos wid 2 1) " mm 磁磚 Hatch！"))
       )
       (princ "\n[提示] 未選取任何有效物件。")
     )
    )

    ;; -----------------------------------------------------------------
    ;; 模式 B：點擊範圍內部點 (關閉 OSNAP 防干擾)
    ;; -----------------------------------------------------------------
    ((or (= mode "P") (= mode "p"))
     (setq pt (getpoint "\n請點擊範圍內部點: "))
     (if pt
       (progn
         (setvar "OSMODE" 0) ; 暫時關閉物件鎖點
         (while pt
           (if (= len wid)
             ;; 正方形
             (progn
               (setvar "HPNAME" "_USER")
               (setvar "HPSPACE" len)
               (setvar "HPDOUBLE" 1)
               (setvar "HPANG" angle)
               (command "._-hatch" pt "")
             )
             ;; 矩形
             (progn
               ;; 橫向線
               (setvar "HPNAME" "_USER")
               (setvar "HPSPACE" wid)
               (setvar "HPDOUBLE" 0)
               (setvar "HPANG" angle)
               (command "._-hatch" pt "")
               
               ;; 與自訂角度垂直的線
               (setvar "HPSPACE" len)
               (setvar "HPANG" (+ angle (/ pi 2.0)))
               (command "._-hatch" pt "")
             )
           )
           (setvar "OSMODE" oldOsnap) ; 恢復鎖點供下次點選
           (setq pt (getpoint "\n請點擊下一個內部點 (Enter 結束): "))
           (if pt (setvar "OSMODE" 0))
         )
         (princ (strcat "\n[成功] 已生成 " (rtos len 2 1) " x " (rtos wid 2 1) " mm 磁磚 Hatch！"))
       )
       (princ "\n[提示] 未點擊任何點。")
     )
    )
  )

  ;; 還原系統變數
  (setvar "OSMODE" oldOsnap)
  (setvar "HPNAME" oldHpName)
  (setvar "HPSPACE" oldHpSpace)
  (setvar "HPDOUBLE" oldHpDouble)
  (setvar "HPANG" oldHpAng)
  (command "._undo" "_end")
  (setvar "CMDECHO" oldEcho)
  (princ)
)

(princ "\n[CHH] 矩形磁磚 Hatch 外掛已更新，請輸入指令：CHH")
(princ)
;;; ==========================================================================
;;; 專業 CAD 外掛：參數化鋼結構斷面生成工具
;;; 指令名稱: STEEL
;;; 支援類型: H鋼(H-Beam)、方管(Box Tube)、C型鋼(C-Channel)
;;; 圖層設定: 自動使用當前圖層 (Current Layer)
;;; ==========================================================================

(defun c:STEEL ( / old_cmd secType H W tw tf t_thk pt ptList ptList1 ptList2 DrawPoly)
  (vl-load-com)
  
  ;; 儲存並關閉指令回顯，保持畫面整潔
  (setq old_cmd (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.undo" "_begin")

  ;; 建立繪製閉合聚合線 (LWPOLYLINE) 的共用副程式
  (defun DrawPoly (pts basePt / )
    (entmakex
      (append
        (list '(0 . "LWPOLYLINE")
              '(100 . "AcDbEntity")
              '(100 . "AcDbPolyline")
              (cons 90 (length pts))
              '(70 . 1) ; 1 代表閉合 (Closed)
              (cons 8 (getvar "CLAYER")) ; 強制指定為當前圖層
        )
        ;; 將中心點座標加上偏移量，計算出絕對座標
        (mapcar '(lambda (p) (cons 10 (list (+ (car basePt) (car p)) (+ (cadr basePt) (cadr p))))) pts)
      )
    )
  )

  ;; 1. 選擇斷面類型
  (initget 1 "H B C")
  (setq secType (getkword "\n請選擇鋼構斷面類型 [H鋼(H) / 方管(B) / C型鋼(C)]: "))

  ;; 2. 根據類型引導輸入參數並繪製
  (cond
    ;; ==========================================
    ;; 【 H 鋼 (H-Beam) 】
    ;; ==========================================
    ((= secType "H")
      (setq H  (getdist "\n請輸入 H鋼 高度 (H): "))
      (setq W  (getdist "\n請輸入 H鋼 寬度 (W): "))
      (setq tw (getdist "\n請輸入 腹板厚度 (t1/tw): "))
      (setq tf (getdist "\n請輸入 翼板厚度 (t2/tf): "))
      (setq pt (getpoint "\n請指定插入點 (斷面中心): "))
      
      (if (and H W tw tf pt)
        (progn
          ;; 依序定義 H 鋼的 12 個頂點 (以中心 0,0 為基準)
          (setq ptList (list
            (list (- (/ W 2.0)) (/ H 2.0))
            (list (/ W 2.0) (/ H 2.0))
            (list (/ W 2.0) (- (/ H 2.0) tf))
            (list (/ tw 2.0) (- (/ H 2.0) tf))
            (list (/ tw 2.0) (+ (- (/ H 2.0)) tf))
            (list (/ W 2.0) (+ (- (/ H 2.0)) tf))
            (list (/ W 2.0) (- (/ H 2.0)))
            (list (- (/ W 2.0)) (- (/ H 2.0)))
            (list (- (/ W 2.0)) (+ (- (/ H 2.0)) tf))
            (list (- (/ tw 2.0)) (+ (- (/ H 2.0)) tf))
            (list (- (/ tw 2.0)) (- (/ H 2.0) tf))
            (list (- (/ W 2.0)) (- (/ H 2.0) tf))
          ))
          (DrawPoly ptList pt)
          (princ "\n[成功] H鋼斷面已生成！")
        )
      )
    )

    ;; ==========================================
    ;; 【 方管 (Box Tube) 】
    ;; ==========================================
    ((= secType "B")
      (setq H     (getdist "\n請輸入 方管 高度 (H): "))
      (setq W     (getdist "\n請輸入 方管 寬度 (W): "))
      (setq t_thk (getdist "\n請輸入 方管 壁厚 (t): "))
      (setq pt    (getpoint "\n請指定插入點 (斷面中心): "))
      
      (if (and H W t_thk pt)
        (progn
          ;; 外框 4 個頂點
          (setq ptList1 (list
            (list (- (/ W 2.0)) (/ H 2.0))
            (list (/ W 2.0) (/ H 2.0))
            (list (/ W 2.0) (- (/ H 2.0)))
            (list (- (/ W 2.0)) (- (/ H 2.0)))
          ))
          ;; 內框 4 個頂點
          (setq ptList2 (list
            (list (+ (- (/ W 2.0)) t_thk) (- (/ H 2.0) t_thk))
            (list (- (/ W 2.0) t_thk) (- (/ H 2.0) t_thk))
            (list (- (/ W 2.0) t_thk) (+ (- (/ H 2.0)) t_thk))
            (list (+ (- (/ W 2.0)) t_thk) (+ (- (/ H 2.0)) t_thk))
          ))
          (DrawPoly ptList1 pt)
          (DrawPoly ptList2 pt)
          (princ "\n[成功] 方管斷面已生成！")
        )
      )
    )

    ;; ==========================================
    ;; 【 C 型鋼 (C-Channel) 】
    ;; ==========================================
    ((= secType "C")
      (setq H  (getdist "\n請輸入 C型鋼 高度 (H): "))
      (setq W  (getdist "\n請輸入 C型鋼 寬度 (W): "))
      (setq tw (getdist "\n請輸入 腹板厚度 (t1/tw): "))
      (setq tf (getdist "\n請輸入 翼板厚度 (t2/tf): "))
      (setq pt (getpoint "\n請指定插入點 (開口朝右，以包絡框中心為基準): "))
      
      (if (and H W tw tf pt)
        (progn
          ;; 依序定義 C 型鋼的 8 個頂點
          (setq ptList (list
            (list (- (/ W 2.0)) (/ H 2.0))
            (list (/ W 2.0) (/ H 2.0))
            (list (/ W 2.0) (- (/ H 2.0) tf))
            (list (+ (- (/ W 2.0)) tw) (- (/ H 2.0) tf))
            (list (+ (- (/ W 2.0)) tw) (+ (- (/ H 2.0)) tf))
            (list (/ W 2.0) (+ (- (/ H 2.0)) tf))
            (list (/ W 2.0) (- (/ H 2.0)))
            (list (- (/ W 2.0)) (- (/ H 2.0)))
          ))
          (DrawPoly ptList pt)
          (princ "\n[成功] C型鋼斷面已生成！")
        )
      )
    )
  )

  ;; 還原環境設定
  (command "_.undo" "_end")
  (setvar "CMDECHO" old_cmd)
  (princ)
)

(princ "\n參數化鋼構斷面生成工具已載入！請輸入指令 [ STEEL ] 開始執行。")
(princ)
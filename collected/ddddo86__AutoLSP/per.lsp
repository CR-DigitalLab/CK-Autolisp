;; ====================================================================
;; 指令名稱：per
;; 功能簡介：動態周長標註 (支援點選既有線條、繪製聚合線、單位換算與字高設定)
;; ====================================================================

(vl-load-com)

;; --- [子程式] 安全取得 64 位元 ObjectID 字串 ---
(defun Get-ObjID-Str (obj / util)
  (setq util (vla-get-Utility (vla-get-ActiveDocument (vlax-get-acad-object))))
  (if (vlax-method-applicable-p util 'GetObjectIdString)
    (vla-GetObjectIdString util obj :vlax-false)
    (itoa (vla-get-ObjectID obj))
  )
)

;; --- [子程式] 取得長度單位名稱 ---
(defun per-get-unit-name (mode)
  (cond
    ((= mode 1) "m (mm 轉公尺，除以 1000)")
    ((= mode 2) "cm (mm 轉公分，除以 10)")
    ((= mode 3) "mm (mm 原單位不換算)")
    ((= mode 4) "m (圖面原單位 1:1)")
    (t "m")
  )
)

;; --- [子程式] 單位設定選單 ---
(defun per-set-unit ( / opt)
  (princ "\n\n================ 請選擇周長/長度顯示單位 ================")
  (princ "\n [1] m   (圖面單位 mm : 長度除以 1,000)")
  (princ "\n [2] cm  (圖面單位 mm : 長度除以 10)")
  (princ "\n [3] mm  (圖面單位 mm : 1:1 不換算)")
  (princ "\n [4] m   (圖面單位 m  : 1:1 不換算)")
  (princ "\n========================================================")
  (initget "1 2 3 4")
  (setq opt (getkword "\n請選擇單位數字 [1/2/3/4] <1>: "))
  (if opt
    (setq *PER_LEN_UNIT* (atoi opt))
    (setq *PER_LEN_UNIT* 1)
  )
  (princ (strcat "\n已切換單位為: " (per-get-unit-name *PER_LEN_UNIT*)))
)

(defun c:per ( / doc space p1 ent obj textPt objID propName factorFormat suffixStr fieldCode mtextObj inputH selSS)
  (setvar "CMDECHO" 0)
  (command "._undo" "_begin")
  
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq space (vla-get-modelspace doc))

  ;; 初始化全域預設值
  (if (not *PER_LEN_UNIT*)  (setq *PER_LEN_UNIT* 1))    ; 預設 1: mm 轉 m
  (if (not *PER_TXT_HEIGHT*) (setq *PER_TXT_HEIGHT* 2.5)) ; 預設字高 2.5

  (princ (strcat "\n[PER 動態周長標註] 當前單位: " (per-get-unit-name *PER_LEN_UNIT*) " | 字高: " (rtos *PER_TXT_HEIGHT* 2 2)))
  
  (initget "U H u h")
  (setq p1 (getpoint "\n請點選既有線條 / 按 Enter 繪製新聚合線 [單位設定(U)/字高(H)] <繪製新線條>: "))
  
  (cond
    ;; 1. 開啟單位設定 (U)
    ((or (= p1 "U") (= p1 "u"))
     (per-set-unit)
     (command "._undo" "_end")
     (setvar "CMDECHO" 1)
     (c:per)
     (exit)
    )
    
    ;; 2. 設定文字高度 (H)
    ((or (= p1 "H") (= p1 "h"))
     (setq inputH (getreal (strcat "\n請輸入文字高度 <目前: " (rtos *PER_TXT_HEIGHT* 2 2) ">: ")))
     (if inputH (setq *PER_TXT_HEIGHT* inputH))
     (princ (strcat "\n✅ 文字高度已更新為: " (rtos *PER_TXT_HEIGHT* 2 2)))
     (command "._undo" "_end")
     (setvar "CMDECHO" 1)
     (c:per)
     (exit)
    )
    
    ;; 3. 點選既有線條物件
    ((and p1 (= (type p1) 'LIST))
     (setq selSS (ssget p1 '((0 . "LINE,LWPOLYLINE,POLYLINE,CIRCLE,ARC,SPLINE,ELLIPSE"))))
     (if selSS
       (progn
         (setq ent (ssname selSS 0))
         (setq obj (vlax-ename->vla-object ent))
         (setq textPt (getpoint "\n請點選放置周長數字的位置: "))
         (if textPt
           (progn
             (setq textPt (vlax-3d-point textPt))
             (setq propName (if (= (vla-get-ObjectName obj) "AcDbCircle") "Circumference" "Length"))
             (setq objID (Get-ObjID-Str obj))
             
             ;; 根據單位模式設定格式與係數
             (cond
               ((= *PER_LEN_UNIT* 1) (setq factorFormat "%lu2%pr2%ct8[0.001]") (setq suffixStr " m"))
               ((= *PER_LEN_UNIT* 2) (setq factorFormat "%lu2%pr2%ct8[0.1]")   (setq suffixStr " cm"))
               ((= *PER_LEN_UNIT* 3) (setq factorFormat "%lu2%pr2")             (setq suffixStr " mm"))
               ((= *PER_LEN_UNIT* 4) (setq factorFormat "%lu2%pr2")             (setq suffixStr " m"))
               (t (setq factorFormat "%lu2%pr2%ct8[0.001]") (setq suffixStr " m"))
             )
             
             (setq fieldCode (strcat "%<\\AcObjProp Object(%<\\_ObjId " objID ">%)." propName " \\f \"" factorFormat "\">%" suffixStr))
             
             (setq mtextObj (vla-AddMText space textPt 0.0 fieldCode))
             (vla-put-Height mtextObj *PER_TXT_HEIGHT*)
             (vla-put-attachmentPoint mtextObj acAttachmentPointMiddleCenter)
             (vla-put-insertionPoint mtextObj textPt)
             
             (command "_.UPDATEFIELD" (vlax-vla-object->ename mtextObj) "")
             (command "_.REGEN")
             (princ "\n✅ 既有線條周長動態標註已建立！")
           )
           (princ "\n⚠️ 未點選文字放置位置。")
         )
       )
       (princ "\n⚠️ 該位置沒有找到有效的線條物件。")
     )
    )
    
    ;; 4. 直接繪製新聚合線
    (t
     (princ "\n請開始繪製聚合線...")
     (command "._pline")
     (while (> (getvar "CMDACTIVE") 0)
       (command pause)
     )
     
     (setq ent (entlast))
     (if (and ent (member (cdr (assoc 0 (entget ent))) '("LWPOLYLINE" "POLYLINE" "LINE" "ARC" "SPLINE")))
       (progn
         (setq obj (vlax-ename->vla-object ent))
         (setq textPt (getpoint "\n請點選放置周長數字的位置: "))
         (if textPt
           (progn
             (setq textPt (vlax-3d-point textPt))
             (setq objID (Get-ObjID-Str obj))
             
             (cond
               ((= *PER_LEN_UNIT* 1) (setq factorFormat "%lu2%pr2%ct8[0.001]") (setq suffixStr " m"))
               ((= *PER_LEN_UNIT* 2) (setq factorFormat "%lu2%pr2%ct8[0.1]")   (setq suffixStr " cm"))
               ((= *PER_LEN_UNIT* 3) (setq factorFormat "%lu2%pr2")             (setq suffixStr " mm"))
               ((= *PER_LEN_UNIT* 4) (setq factorFormat "%lu2%pr2")             (setq suffixStr " m"))
               (t (setq factorFormat "%lu2%pr2%ct8[0.001]") (setq suffixStr " m"))
             )
             
             (setq fieldCode (strcat "%<\\AcObjProp Object(%<\\_ObjId " objID ">%).Length \\f \"" factorFormat "\">%" suffixStr))
             
             (setq mtextObj (vla-AddMText space textPt 0.0 fieldCode))
             (vla-put-Height mtextObj *PER_TXT_HEIGHT*)
             (vla-put-attachmentPoint mtextObj acAttachmentPointMiddleCenter)
             (vla-put-insertionPoint mtextObj textPt)
             
             (command "_.UPDATEFIELD" (vlax-vla-object->ename mtextObj) "")
             (command "_.REGEN")
             (princ "\n✅ 新繪製線條的周長動態標註已建立！")
           )
           (princ "\n⚠️ 未點選文字放置位置。")
         )
       )
       (princ "\n⚠️ 未檢測到新繪製的線條。")
     )
    )
  )
  
  (command "._undo" "_end")
  (setvar "CMDECHO" 1)
  (princ)
)

(princ "\n動態周長標註外掛已載入，請輸入指令：PER")
(princ)
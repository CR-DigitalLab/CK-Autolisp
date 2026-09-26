;;; =========================================================================
;;; 程式名稱: sse2.lsp (鋼構尺寸表批量圖塊生成器 - 圖層分流與材質版)
;;; 指令名稱: SSE2
;;; 操作流程: 輸入指令 sse2 ➔ 框選表格範圍 ➔ 點擊點選插入點 ➔ 批量生成所有斷面圖塊
;;; 支援類型: BOX (方管)、H (H型鋼)、C (C型鋼)
;;; 圖層規則: 斷面圖塊 (當前使用圖層) / 標註文字 (同選取文字圖層)
;;; =========================================================================

(vl-load-com)

;; --- 內部副程式: 註冊 XData 應用程式名稱 ---
(regapp "STEEL_MAT")

;; --- 內部副程式: VLA 繪製多段線 ---
(defun sse2:add-vla-poly (blkObj pts / sa pline)
  (setq sa (vlax-make-safearray vlax-vbDouble (cons 0 (1- (length pts)))))
  (vlax-safearray-fill sa pts)
  (setq pline (vla-addLightWeightPolyline blkObj sa))
  (vla-put-closed pline :vlax-true)
)

;; --- 內部副程式: VLA 繪製矩形 ---
(defun sse2:add-vla-rect (blkObj x1 y1 x2 y2 /)
  (sse2:add-vla-poly blkObj (list x1 y1  x2 y1  x2 y2  x1 y2))
)

;; --- 內部副程式: 建立/更新鋼構圖塊 ---
(defun sse2:make-steel-block (blk-name typ dims / doc blks blkObj h w tw tf x1 x2 y1 y2 pts)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq blks (vla-get-blocks doc))
  
  ;; 1. 取得或建立圖塊定義 (若已存在則先清空內部物件)
  (if (tblsearch "BLOCK" blk-name)
    (progn
      (setq blkObj (vla-item blks blk-name))
      (vlax-for ent blkObj (vla-delete ent))
    )
    (setq blkObj (vla-add blks (vlax-3d-point '(0.0 0.0 0.0)) blk-name))
  )
  
  ;; 2. 提取尺寸參數
  (setq h (float (nth 0 dims))
        w (float (nth 1 dims))
        tw (float (nth 2 dims))
        tf (if (> (length dims) 3) (float (nth 3 dims)) tw))
  
  ;; 3. 繪製鋼構斷面 (設定為 0 層，確保插入時繼承當前圖層屬性)
  (cond
    ((= typ "BOX")
     (sse2:add-vla-rect blkObj (- (/ w 2.0)) (- (/ h 2.0)) (/ w 2.0) (/ h 2.0))
     (sse2:add-vla-rect blkObj (+ (- (/ w 2.0)) tw) (+ (- (/ h 2.0)) tf) (- (/ w 2.0) tw) (- (/ h 2.0) tf))
    )
    ((= typ "H")
     (setq x1 (/ tw 2.0) x2 (/ w 2.0) y1 (- (/ h 2.0) tf) y2 (/ h 2.0))
     (setq pts (list x1 (- y1)  x2 (- y1)  x2 (- y2)  (- x2) (- y2)
                     (- x2) (- y1)  (- x1) (- y1)  (- x1) y1  (- x2) y1
                     (- x2) y2  x2 y2  x2 y1  x1 y1))
     (sse2:add-vla-poly blkObj pts)
    )
    ((= typ "C")
     (setq x1 (- (/ w 2.0)) x2 (/ w 2.0) y1 (- (/ h 2.0) tf) y2 (/ h 2.0))
     (setq pts (list x1 (- y2)  x2 (- y2)  x2 (- y1)  (+ x1 tw) (- y1)
                     (+ x1 tw) y1  x2 y1  x2 y2  x1 y2))
     (sse2:add-vla-poly blkObj pts)
    )
  )
  t
)

;; --- 內部副程式: 提取尺寸數值 ---
(defun sse2:extract-spec (str / ustr pos typ num-list tmp ch i)
  (setq ustr (strcase str))
  (while (setq pos (vl-string-search ";" ustr))
    (setq ustr (substr ustr (+ pos 2)))
  )
  (cond
    ((setq pos (vl-string-search "BOX" ustr)) (setq typ "BOX"))
    ((setq pos (vl-string-search "H" ustr)) (setq typ "H"))
    ((setq pos (vl-string-search "C" ustr)) (setq typ "C"))
    (t (setq typ nil))
  )
  (if typ
    (progn
      (setq ustr (substr ustr (1+ pos)))
      (setq ustr (vl-string-translate "X*,-/\\{}" "        " ustr))
      (setq num-list nil tmp "" i 1)
      (while (<= i (strlen ustr))
        (setq ch (substr ustr i 1))
        (if (wcmatch ch "*[0-9.]*")
          (setq tmp (strcat tmp ch))
          (if (> (strlen tmp) 0)
            (progn
              (setq num-list (append num-list (list (atof tmp))))
              (setq tmp "")
            )
          )
        )
        (setq i (1+ i))
      )
      (if (> (strlen tmp) 0)
        (setq num-list (append num-list (list (atof tmp))))
      )
      (if (>= (length num-list) 2) (list typ num-list) nil)
    )
    nil
  )
)

;; --- 內部副程式: 清洗文字內容 ---
(defun sse2:clean-str (str / pos)
  (setq str (vl-string-trim " \t\r\n{}" str))
  (while (setq pos (vl-string-search ";" str))
    (setq str (substr str (+ pos 2)))
  )
  (vl-string-trim " \t\r\n{}" str)
)

;; =========================================================================
;; 主程式
;; =========================================================================
(defun c:sse2 ( / oldEcho curLayer txtLayer ss txt-list h-list i ent ed pt txt-str tol rows curr-row last-y item sec-data row spec id mat max-dim spacing ins-pt count curr-x curr-y typ dims txtH txtPt1 txtPt2 newEnt exdata)
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "._undo" "_begin")
  
  ;; 抓取當前工作圖層 (作為結構斷面圖塊的預設圖層)
  (setq curLayer (getvar "CLAYER"))
  
  (prompt "\n請框選包含 [鋼構件尺寸表] 的表格範圍 (含名稱/尺寸/編號/材質): ")
  (if (setq ss (ssget '((0 . "*TEXT"))))
    (progn
      ;; 1. 抓取選取文字的來源圖層 (將第一個文字物件的圖層作為文字圖層)
      (setq txtLayer (cdr (assoc 8 (entget (ssname ss 0)))))
      (if (null txtLayer) (setq txtLayer curLayer))

      ;; 2. 提取所有文字物件資料
      (setq txt-list nil h-list nil i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i) ed (entget ent))
        (setq txt-str (vla-get-TextString (vlax-ename->vla-object ent)))
        (setq pt (if (= (cdr (assoc 0 ed)) "MTEXT")
                   (cdr (assoc 10 ed))
                   (if (and (= (cdr (assoc 72 ed)) 0) (= (cdr (assoc 73 ed)) 0))
                     (cdr (assoc 10 ed))
                     (cdr (assoc 11 ed)))))
        (setq txt-list (cons (list txt-str (car pt) (cadr pt)) txt-list))
        (setq h-list (cons (cdr (assoc 40 ed)) h-list))
        (setq i (1+ i))
      )

      ;; 3. 幾何 Y 軸自動分行
      (setq tol (* (car (vl-sort h-list '<)) 0.8))
      (setq txt-list (vl-sort txt-list '(lambda (a b) (> (caddr a) (caddr b)))))
      
      (setq rows nil curr-row (list (car txt-list)) last-y (caddr (car txt-list)) i 1)
      (while (< i (length txt-list))
        (setq item (nth i txt-list))
        (if (< (abs (- (caddr item) last-y)) tol)
          (setq curr-row (append curr-row (list item)))
          (progn
            (setq rows (append rows (list curr-row)))
            (setq curr-row (list item) last-y (caddr item))
          )
        )
        (setq i (1+ i))
      )
      (if curr-row (setq rows (append rows (list curr-row))))

      ;; 4. 行內 X 軸排序與尺寸、編號、材質自動配對
      (setq sec-data nil)
      (foreach row rows
        (setq row (vl-sort row '(lambda (a b) (< (cadr a) (cadr b))))) ; 由左至右排序
        (setq i 0)
        (while (< i (length row))
          (setq spec (sse2:extract-spec (car (nth i row))))
          (if spec
            (progn
              ;; 提取編號 (尺寸右側欄位)
              (setq id (if (< (1+ i) (length row))
                         (sse2:clean-str (car (nth (1+ i) row)))
                         "SECTION"))
              (if (= id "") (setq id "SECTION"))
              
              ;; 提取材質 (編號右側欄位)
              (setq mat (if (< (+ i 2) (length row))
                          (sse2:clean-str (car (nth (+ i 2) row)))
                          "N/A"))
              
              (setq sec-data (append sec-data (list (list id (car spec) (cadr spec) mat))))
            )
          )
          (setq i (1+ i))
        )
      )

      ;; 5. 批量生成圖塊與繪製 (實作圖層分流)
      (if sec-data
        (progn
          (setq max-dim 0.0)
          (foreach data sec-data
            (setq dims (caddr data))
            (if (> (car dims) max-dim) (setq max-dim (car dims)))
            (if (> (cadr dims) max-dim) (setq max-dim (cadr dims)))
          )
          (setq spacing (* max-dim 1.6))
          (if (< spacing 800.0) (setq spacing 800.0))

          (setq ins-pt (getpoint (strcat "\n成功解析 " (itoa (length sec-data)) " 組鋼構資料！請點擊畫面空白處作為 [生成排列起始點]: ")))
          (if ins-pt
            (progn
              (setq count 0)
              (foreach data sec-data
                (setq id (car data) typ (cadr data) dims (caddr data) mat (cadddr data))
                
                ;; 建立 / 更新圖塊定義
                (sse2:make-steel-block id typ dims)

                ;; 計算網格座標 (每行 5 個)
                (setq curr-x (+ (car ins-pt) (* (rem count 5) spacing)))
                (setq curr-y (- (cadr ins-pt) (* (/ count 5) spacing)))

                ;; 1. 插入圖塊 ➔ 放置於 [當前使用圖層 (curLayer)]
                (entmake (list '(0 . "INSERT")
                               (cons 2 id)
                               (cons 8 curLayer)
                               (list 10 curr-x curr-y 0.0)
                               '(41 . 1.0) '(42 . 1.0) '(43 . 1.0) '(50 . 0.0)))
                (setq newEnt (entlast))

                ;; 寫入材質至圖塊擴充屬性 (XData)
                (setq exdata (list (list -3 (list "STEEL_MAT" (cons 1000 mat)))))
                (entmod (append (entget newEnt) exdata))

                ;; 計算底部署名文字大小與位置
                (setq txtH (/ max-dim 8.0))
                (if (< txtH 15.0) (setq txtH 15.0))
                (setq txtPt1 (list curr-x (- curr-y (* max-dim 0.65)) 0.0))
                (setq txtPt2 (list curr-x (- (cadr txtPt1) (* txtH 1.4)) 0.0))

                ;; 2. 建立標註文字 ➔ 放置於 [同選取文字圖層 (txtLayer)]
                ;; 第一行: 編號
                (entmake (list '(0 . "TEXT")
                               (cons 8 txtLayer)
                               (cons 1 id)
                               (cons 10 txtPt1)
                               (cons 40 txtH)
                               '(72 . 1)
                               (cons 11 txtPt1)
                               '(73 . 2)))
                
                ;; 第二行: 材質
                (entmake (list '(0 . "TEXT")
                               (cons 8 txtLayer)
                               (cons 1 (strcat "(" mat ")"))
                               (cons 10 txtPt2)
                               (cons 40 (* txtH 0.85))
                               '(72 . 1)
                               (cons 11 txtPt2)
                               '(73 . 2)))

                (setq count (1+ count))
              )
              (vla-regen (vla-get-activedocument (vlax-get-acad-object)) acActiveViewport)
              (princ (strcat "\n[成功] 已批量生成 " (itoa count) " 組斷面！斷面放置於 [" curLayer "]，文字放置於 [" txtLayer "]。"))
            )
          )
        )
        (princ "\n[錯誤] 在選取範圍內未發現有效的鋼構尺寸資訊 (BOX / H / C)！")
      )
    )
    (princ "\n[取消] 未選取任何文字。")
  )
  
  (command "._undo" "_end")
  (setvar "CMDECHO" oldEcho)
  (princ)
)

(princ "\n[SSE2] 鋼構尺寸表批量圖塊生成器(圖層控制版) 已載入，請輸入指令：sse2")
(princ)
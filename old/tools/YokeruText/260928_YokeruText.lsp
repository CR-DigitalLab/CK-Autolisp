;;; ============================================================
;;;  YokeruText.lsp   ― 文字の重なりを自動で避ける ―
;;;
;;;  YOKERU    (ショートカット YK ) : 重なっている文字を空いている場所へ自動で逃がす
;;;  YOKERUSET (ショートカット YKS) : 設定画面
;;;
;;;  対応 : AutoCAD 2027
;;;  版   : 1.1.0  (2026-09-27)
;;;         1.1.0: 寸法の文字・マルチ引出線の文字も動かせるようにした（設定 T / U で ON）
;;;                マルチ引出線を障害物として正確に判定（引出線と文字を別々に）
;;;         1.0.1: 回転角の記録が省略された文字も対象にする
;;;                ハッチ(H)ON のとき、ハッチの内側にある文字も外へ逃がす（以前は外形線だけを判定）
;;;
;;;  ・普段は「文字を選んで Enter」だけ。細かい調整は YKS（設定）で。
;;;  ・画面のズーム状態に関係なく、図面の座標だけで判定する。
;;;  ・近くの図形だけを比べる「マス目方式」で、文字が多くても速い。
;;;  ・大きく動いた文字には引出線を自動で付ける（設定で切替）。
;;;  ・実行後に確認し、「元に戻す」または Esc で全部元通り。
;;; ============================================================

(vl-load-com)

;;; ------------------------------------------------------------
;;;  設定（キー 既定値 説明）  ※ 値は setenv でユーザーごとに記憶
;;; ------------------------------------------------------------
(setq *yk:cfgdef*
  '(("Clear"    "0.25" "余白（文字高さに対する割合）")
    ("MaxDist"  "6"    "最大移動距離（文字高さの何倍まで）")
    ("Dirs"     "16"   "探す方向の数")
    ("Leader"   "1"    "引出線を付ける")
    ("LdrDist"  "1.5"  "引出線を付ける移動距離（文字高さの何倍以上）")
    ("UseBlk"   "1"    "ブロックを障害物にする")
    ("UseDim"   "1"    "寸法を障害物にする")
    ("UseHat"   "0"    "ハッチを障害物にする（外形の四角の内側すべて）")
    ("FixLay"   ""     "動かさない画層")
    ("IgnLay"   ""     "障害物にしない画層")
    ("MaskFail" "0"    "逃げ場のないマルチテキストに背景マスク")
    ("Confirm"  "1"    "実行後に確認する")
    ("MoveDim"  "0"    "寸法の文字も動かす")
    ("MoveMld"  "0"    "マルチ引出線の文字も動かす")))

(defun yk:cfg (key / v)
  (setq v (getenv (strcat "YokeruText_" key)))
  (if (null v) (cadr (assoc key *yk:cfgdef*)) v))

(defun yk:cfgr (key vmin / s v)
  (setq s (yk:cfg key)
        v (if (and s (/= s "")) (atof s)))
  (if (and v (>= v vmin)) v (atof (cadr (assoc key *yk:cfgdef*)))))

(defun yk:cfgb (key) (= (yk:cfg key) "1"))

(defun yk:setcfg (key val) (setenv (strcat "YokeruText_" key) val))

(defun yk:load-cfg ( )
  (setq *yk:clear*   (yk:cfgr "Clear" 0.0)
        *yk:maxd*    (yk:cfgr "MaxDist" 0.5)
        *yk:ndir*    (max 4 (min 64 (fix (yk:cfgr "Dirs" 4.0))))
        *yk:ldr*     (yk:cfgb "Leader")
        *yk:ldrd*    (yk:cfgr "LdrDist" 0.0)
        *yk:useblk*  (yk:cfgb "UseBlk")
        *yk:usedim*  (yk:cfgb "UseDim")
        *yk:usehat*  (yk:cfgb "UseHat")
        *yk:fixpat*  (if (/= (yk:cfg "FixLay") "") (strcase (yk:cfg "FixLay")))
        *yk:ignpat*  (if (/= (yk:cfg "IgnLay") "") (strcase (yk:cfg "IgnLay")))
        *yk:mask*    (yk:cfgb "MaskFail")
        *yk:confirm* (yk:cfgb "Confirm")
        *yk:movdim*  (yk:cfgb "MoveDim")
        *yk:movmld*  (yk:cfgb "MoveMld")))

;;; ------------------------------------------------------------
;;;  2D の計算
;;; ------------------------------------------------------------
(defun yk:floor (x / i)
  (setq i (fix x))
  (if (and (< x 0.0) (/= x i)) (1- i) i))
(defun yk:p2 (p) (list (float (car p)) (float (cadr p))))
(defun yk:v+ (a b) (list (+ (car a) (car b)) (+ (cadr a) (cadr b))))
(defun yk:v- (a b) (list (- (car a) (car b)) (- (cadr a) (cadr b))))
(defun yk:vs (a s) (list (* (car a) s) (* (cadr a) s)))
(defun yk:dot (a b) (+ (* (car a) (car b)) (* (cadr a) (cadr b))))
(defun yk:perp (u) (list (- (cadr u)) (car u)))

;;; 回転した四角（OBB） = (中心 横方向の単位ベクトル 半幅 半高さ)
(defun yk:obb-corners (o / c u v hw hh)
  (setq c (car o) u (cadr o) v (yk:perp u) hw (caddr o) hh (cadddr o))
  (list (yk:v+ c (yk:v+ (yk:vs u hw)     (yk:vs v hh)))
        (yk:v+ c (yk:v+ (yk:vs u (- hw)) (yk:vs v hh)))
        (yk:v+ c (yk:v+ (yk:vs u (- hw)) (yk:vs v (- hh))))
        (yk:v+ c (yk:v+ (yk:vs u hw)     (yk:vs v (- hh))))))

(defun yk:obb-aabb (o / pts)
  (setq pts (yk:obb-corners o))
  (list (apply 'min (mapcar 'car pts)) (apply 'min (mapcar 'cadr pts))
        (apply 'max (mapcar 'car pts)) (apply 'max (mapcar 'cadr pts))))

(defun yk:obb-grow (o m) (list (car o) (cadr o) (+ (caddr o) m) (+ (cadddr o) m)))
(defun yk:obb-move (o d) (cons (yk:v+ (car o) d) (cdr o)))

(defun yk:bb-hit (a b)
  (and a b
       (not (or (< (caddr a) (car b)) (< (caddr b) (car a))
                (< (cadddr a) (cadr b)) (< (cadddr b) (cadr a))))))

;;; 回転した四角どうしの重なり（分離軸判定）
(defun yk:obb-hit (a b / d ok ra rb)
  (setq d (yk:v- (car b) (car a)) ok T)
  (foreach ax (list (cadr a) (yk:perp (cadr a)) (cadr b) (yk:perp (cadr b)))
    (if ok
      (progn
        (setq ra (+ (* (caddr a) (abs (yk:dot (cadr a) ax)))
                    (* (cadddr a) (abs (yk:dot (yk:perp (cadr a)) ax))))
              rb (+ (* (caddr b) (abs (yk:dot (cadr b) ax)))
                    (* (cadddr b) (abs (yk:dot (yk:perp (cadr b)) ax)))))
        (if (> (abs (yk:dot d ax)) (+ ra rb)) (setq ok nil)))))
  ok)

;;; 線分の切り取り（範囲 xmin..xmax, ymin..ymax）  交わる区間 (t0 t1) か nil
(defun yk:clip (x y dx dy xmin xmax ymin ymax / t0 t1 ok p q r)
  (setq t0 0.0 t1 1.0 ok T)
  (foreach pq (list (list (- dx) (- x xmin)) (list dx (- xmax x))
                    (list (- dy) (- y ymin)) (list dy (- ymax y)))
    (if ok
      (progn
        (setq p (car pq) q (cadr pq))
        (if (equal p 0.0 1e-12)
          (if (< q 0.0) (setq ok nil))
          (progn
            (setq r (/ q p))
            (if (< p 0.0)
              (if (> r t1) (setq ok nil) (if (> r t0) (setq t0 r)))
              (if (< r t0) (setq ok nil) (if (< r t1) (setq t1 r)))))))))
  (if ok (list t0 t1)))

;;; 線分と回転した四角の重なり
(defun yk:seg-hit (o p1 p2 / c u v hw hh x1 y1 x2 y2)
  (setq c (car o) u (cadr o) v (yk:perp u) hw (caddr o) hh (cadddr o)
        x1 (yk:dot (yk:v- p1 c) u) y1 (yk:dot (yk:v- p1 c) v)
        x2 (yk:dot (yk:v- p2 c) u) y2 (yk:dot (yk:v- p2 c) v))
  (cond ((and (<= (abs x1) hw) (<= (abs y1) hh)) T)
        ((and (<= (abs x2) hw) (<= (abs y2) hh)) T)
        (T (if (yk:clip x1 y1 (- x2 x1) (- y2 y1) (- hw) hw (- hh) hh) T))))

;;; ------------------------------------------------------------
;;;  マス目（近くの図形だけを比べるための入れ物）
;;;  セルごとにシンボルを作って中身を入れる（使い終わったら全部 nil に戻す）
;;; ------------------------------------------------------------
(defun yk:istr (i) (if (< i 0) (strcat "M" (itoa (abs i))) (itoa i)))
(defun yk:cell (pre ix iy) (read (strcat pre (yk:istr ix) "X" (yk:istr iy))))
(defun yk:ix (x) (yk:floor (/ (- x *yk:gx0*) *yk:cs*)))
(defun yk:iy (y) (yk:floor (/ (- y *yk:gy0*) *yk:cs*)))

(defun yk:gadd (pre bb item / ix iy ix1 iy0 iy1 s)
  (setq ix (yk:ix (car bb)) ix1 (yk:ix (caddr bb))
        iy0 (yk:iy (cadr bb)) iy1 (yk:iy (cadddr bb)))
  (while (<= ix ix1)
    (setq iy iy0)
    (while (<= iy iy1)
      (setq s (yk:cell pre ix iy))
      (if (null (eval s)) (setq *yk:syms* (cons s *yk:syms*)))
      (set s (cons item (eval s)))
      (setq iy (1+ iy)))
    (setq ix (1+ ix))))

(defun yk:gget (pre bb / ix iy ix1 iy0 iy1 res)
  (setq ix (yk:ix (car bb)) ix1 (yk:ix (caddr bb))
        iy0 (yk:iy (cadr bb)) iy1 (yk:iy (cadddr bb)))
  (while (<= ix ix1)
    (setq iy iy0)
    (while (<= iy iy1)
      (setq res (append (eval (yk:cell pre ix iy)) res)
            iy (1+ iy)))
    (setq ix (1+ ix)))
  res)

(defun yk:gdel (pre bb idx / ix iy ix1 iy0 iy1 s)
  (setq ix (yk:ix (car bb)) ix1 (yk:ix (caddr bb))
        iy0 (yk:iy (cadr bb)) iy1 (yk:iy (cadddr bb)))
  (while (<= ix ix1)
    (setq iy iy0)
    (while (<= iy iy1)
      (setq s (yk:cell pre ix iy))
      (set s (vl-remove-if '(lambda (r) (= (car r) idx)) (eval s)))
      (setq iy (1+ iy)))
    (setq ix (1+ ix))))

;;; 対象の印（文字＝T、寸法・マルチ引出線＝番号。番号のものは障害物としても登録する）
(defun yk:mark (e val / s)
  (setq s (read (strcat "YKH" (cdr (assoc 5 (entget e))))))
  (setq *yk:syms* (cons s *yk:syms*))
  (set s val))

(defun yk:marked-p (ed / h)
  (and (setq h (cdr (assoc 5 ed))) (eval (read (strcat "YKH" h)))))

(defun yk:cleanup ( )
  (foreach s *yk:syms* (set s nil))
  (setq *yk:syms* nil *yk:own* nil))

;;; ------------------------------------------------------------
;;;  障害物の登録
;;; ------------------------------------------------------------
;;; 線分（処理範囲で切り取り、マス目の大きさごとに分けて登録）
(defun yk:add-seg (p1 p2 / tt d a b len n i q1 q2 item)
  (if (setq tt (yk:clip (car p1) (cadr p1) (- (car p2) (car p1)) (- (cadr p2) (cadr p1))
                        (car *yk:reg*) (caddr *yk:reg*) (cadr *yk:reg*) (cadddr *yk:reg*)))
    (progn
      (setq d    (yk:v- p2 p1)
            a    (yk:v+ p1 (yk:vs d (car tt)))
            b    (yk:v+ p1 (yk:vs d (cadr tt)))
            len  (distance a b)
            n    (1+ (fix (/ len *yk:cs*)))
            item (list 'S a b *yk:own*)
            i    0)
      (repeat n
        (setq q1 (yk:v+ a (yk:vs (yk:v- b a) (/ (float i) n)))
              q2 (yk:v+ a (yk:vs (yk:v- b a) (/ (float (1+ i)) n))))
        (yk:gadd "YKS" (list (min (car q1) (car q2)) (min (cadr q1) (cadr q2))
                             (max (car q1) (car q2)) (max (cadr q1) (cadr q2)))
                 item)
        (setq i (1+ i))))))

(defun yk:add-box (o / bb)
  (if (yk:bb-hit (setq bb (yk:obb-aabb o)) *yk:reg*)
    ;; マス目への登録は処理範囲の中だけ（大きなハッチなどで遅くならないように）
    (yk:gadd "YKS"
             (list (max (car bb) (car *yk:reg*)) (max (cadr bb) (cadr *yk:reg*))
                   (min (caddr bb) (caddr *yk:reg*)) (min (cadddr bb) (cadddr *yk:reg*)))
             (list 'B o *yk:own*))))

;;; 外形の四角を「中身ありの四角」として登録
(defun yk:add-bb-box (bb)
  (yk:add-box (list (list (/ (+ (car bb) (caddr bb)) 2.0) (/ (+ (cadr bb) (cadddr bb)) 2.0))
                    '(1.0 0.0) (/ (- (caddr bb) (car bb)) 2.0) (/ (- (cadddr bb) (cadr bb)) 2.0))))

(defun yk:add-pts (pts closed / prev)
  (setq pts (mapcar 'yk:p2 (vl-remove nil pts)))
  (if (and closed pts) (setq pts (append pts (list (car pts)))))
  (foreach p pts
    (if prev (yk:add-seg prev p))
    (setq prev p)))

(defun yk:add-rect-outline (bb / p1 p2 p3 p4)
  (setq p1 (list (car bb) (cadr bb))   p2 (list (caddr bb) (cadr bb))
        p3 (list (caddr bb) (cadddr bb)) p4 (list (car bb) (cadddr bb)))
  (yk:add-seg p1 p2) (yk:add-seg p2 p3) (yk:add-seg p3 p4) (yk:add-seg p4 p1))

(defun yk:bbox (e / o mn mx r)
  (setq o (vlax-ename->vla-object e)
        r (vl-catch-all-apply 'vla-getboundingbox (list o 'mn 'mx)))
  (if (and (not (vl-catch-all-error-p r)) mn mx)
    (progn
      (setq mn (vlax-safearray->list mn) mx (vlax-safearray->list mx))
      (list (car mn) (cadr mn) (car mx) (cadr mx)))))

;;; 形が複雑なもの：小さければ四角（中身あり）、大きければ外形線だけ
;;; （図枠ブロックなどが「全面の障害物」にならないように）
(defun yk:add-generic (e / bb w h)
  (if (and (setq bb (yk:bbox e)) (yk:bb-hit bb *yk:reg*))
    (progn
      (setq w (- (caddr bb) (car bb)) h (- (cadddr bb) (cadr bb)))
      (if (<= (max w h) (* 8.0 *yk:hav*))
        (yk:add-bb-box bb)
        (yk:add-rect-outline bb)))))

;;; 曲線を細かい線分に分けて登録
(defun yk:add-sampled (e d0 d1 / sp n i pa pb pp dd)
  (setq sp (* 0.25 *yk:cs*)
        n  (min 500 (max 4 (fix (/ (- d1 d0) sp))))
        i  0
        pp (vlax-curve-getPointAtDist e d0))
  (if pp
    (progn
      (setq pa (yk:p2 pp))
      (repeat n
        (setq i  (1+ i)
              dd (+ d0 (* (- d1 d0) (/ (float i) n)))
              pp (vlax-curve-getPointAtDist e dd))
        (if (null pp) (setq pp (vlax-curve-getPointAtDist e (- dd (* 1e-9 (max 1.0 dd))))))
        (if pp
          (progn
            (setq pb (yk:p2 pp))
            (yk:add-seg pa pb)
            (setq pa pb)))))))

(defun yk:add-curve (e / len)
  (if (yk:bb-hit (yk:bbox e) *yk:reg*)
    (progn
      (setq len (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e)))
      (if (and len (> len 0.0)) (yk:add-sampled e 0.0 len)))))

;;; ポリライン：直線区間はそのまま、円弧区間だけ細かく分ける
(defun yk:add-poly (e / ep k pa pb m)
  (if (yk:bb-hit (yk:bbox e) *yk:reg*)
    (progn
      (setq ep (fix (+ 0.5 (vlax-curve-getEndParam e))) k 0)
      (while (< k ep)
        (setq pa (yk:p2 (vlax-curve-getPointAtParam e k))
              pb (yk:p2 (vlax-curve-getPointAtParam e (1+ k)))
              m  (yk:p2 (vlax-curve-getPointAtParam e (+ k 0.5))))
        (if (< (distance m (yk:vs (yk:v+ pa pb) 0.5)) (* 1e-6 (max 1.0 (distance pa pb))))
          (yk:add-seg pa pb)
          (yk:add-sampled e (vlax-curve-getDistAtParam e k) (vlax-curve-getDistAtParam e (1+ k))))
        (setq k (1+ k))))))

;;; 寸法：寸法の中身（線・矢印・寸法値）を個別に登録。座標が合わなければ外形で代用
(defun yk:dim-ok (bh bb / be sub pts tol)
  (setq be  (entnext bh)
        tol (+ (if (numberp *yk:hav*) *yk:hav* 0.0)
               (* 0.1 (max (- (caddr bb) (car bb)) (- (cadddr bb) (cadr bb))))))
  (while (and be (/= "ENDBLK" (cdr (assoc 0 (setq sub (entget be))))))
    (if (= "LINE" (cdr (assoc 0 sub)))
      (setq pts (cons (cdr (assoc 10 sub)) (cons (cdr (assoc 11 sub)) pts))))
    (setq be (entnext be)))
  (and pts
       (vl-every '(lambda (p)
                    (and (>= (car p) (- (car bb) tol)) (<= (car p) (+ (caddr bb) tol))
                         (>= (cadr p) (- (cadr bb) tol)) (<= (cadr p) (+ (cadddr bb) tol))))
                 pts)))

(defun yk:add-dimsub (be sub / typ o)
  (setq typ (cdr (assoc 0 sub)))
  (cond ((= typ "LINE") (yk:add-seg (yk:p2 (cdr (assoc 10 sub))) (yk:p2 (cdr (assoc 11 sub)))))
        ((= typ "SOLID") (yk:add-pts (mapcar '(lambda (c) (cdr (assoc c sub))) '(10 11 13 12)) T))
        ((member typ '("MTEXT" "TEXT"))            ; 動かす寸法の文字は障害物にしない
         (if (and (not *yk:own*) (setq o (yk:text-obb sub))) (yk:add-box o)))
        ((member typ '("ARC" "CIRCLE")) (yk:add-curve be))
        ((= typ "INSERT") (yk:add-generic be))))  ; 矢印ブロック

(defun yk:add-dim (e ed / bn bh be sub bb)
  (setq bb (yk:bbox e) bn (cdr (assoc 2 ed)))
  (if (yk:bb-hit bb *yk:reg*)
    (if (and (yk:zup ed) bn (setq bh (tblobjname "BLOCK" bn)) (yk:dim-ok bh bb))
      (progn
        (setq be (entnext bh))
        (while (and be (/= "ENDBLK" (cdr (assoc 0 (setq sub (entget be))))))
          (vl-catch-all-apply 'yk:add-dimsub (list be sub))
          (setq be (entnext be))))
      (yk:add-generic e))))

(defun yk:codes (code ed)
  (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) code)) ed)))

(defun yk:add-entity (e ed / typ o bb)
  (setq typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "LINE")
     (yk:add-seg (yk:p2 (cdr (assoc 10 ed))) (yk:p2 (cdr (assoc 11 ed)))))
    ((member typ '("LWPOLYLINE" "POLYLINE"))
     (if (vl-catch-all-error-p (vl-catch-all-apply 'yk:add-poly (list e))) (yk:add-generic e)))
    ((member typ '("ARC" "CIRCLE" "ELLIPSE" "SPLINE"))
     (if (vl-catch-all-error-p (vl-catch-all-apply 'yk:add-curve (list e))) (yk:add-generic e)))
    ((member typ '("TEXT" "MTEXT"))
     (if (and (yk:zup ed) (setq o (yk:text-obb ed))) (yk:add-box o) (yk:add-generic e)))
    ((= typ "DIMENSION") (if *yk:usedim* (yk:add-dim e ed)))
    ((= typ "MULTILEADER")
     (if (and (vl-catch-all-error-p (vl-catch-all-apply 'yk:add-mld (list e ed))) (not *yk:own*))
       (yk:add-generic e)))
    ((= typ "LEADER") (yk:add-pts (yk:codes 10 ed) nil))
    ((member typ '("SOLID" "TRACE"))
     (yk:add-pts (mapcar '(lambda (c) (cdr (assoc c ed))) '(10 11 13 12)) T))
    ((= typ "HATCH")
     (if (and *yk:usehat* (setq bb (yk:bbox e)) (yk:bb-hit bb *yk:reg*)) (yk:add-bb-box bb)))
    ((= typ "INSERT") (if *yk:useblk* (yk:add-generic e)))
    ((member typ '("XLINE" "RAY" "VIEWPORT" "POINT")) nil)
    (T (yk:add-generic e))))

;;; ------------------------------------------------------------
;;;  文字の四角
;;; ------------------------------------------------------------
(defun yk:zup (ed / n)
  (or (null (setq n (cdr (assoc 210 ed)))) (equal n '(0.0 0.0 1.0) 1e-8)))

(defun yk:text-obb (ed / typ p a tb x1 y1 x2 y2 fl u v lc w h att col row x0 y0)
  (setq typ (cdr (assoc 0 ed)) p (yk:p2 (cdr (assoc 10 ed))))
  (cond
    ((= typ "TEXT")
     (setq a  (cond ((cdr (assoc 50 ed))) (0.0))   ; 回転角が無ければ 0 度
           tb (textbox ed))
     (if (and tb a)
       (progn
         (setq x1 (car (car tb)) y1 (cadr (car tb)) x2 (car (cadr tb)) y2 (cadr (cadr tb))
               fl (cdr (assoc 71 ed)))
         (if (and fl (= 2 (logand fl 2))) (setq x1 (- x1) x2 (- x2)))
         (if (and fl (= 4 (logand fl 4))) (setq y1 (- y1) y2 (- y2)))
         (setq u  (list (cos a) (sin a)) v (yk:perp u)
               lc (list (/ (+ x1 x2) 2.0) (/ (+ y1 y2) 2.0)))
         (if (> (abs (- x2 x1)) 0.0)
           (list (yk:v+ p (yk:v+ (yk:vs u (car lc)) (yk:vs v (cadr lc))))
                 u (/ (abs (- x2 x1)) 2.0) (/ (abs (- y2 y1)) 2.0))))))
    ((= typ "MTEXT")
     (setq w (cdr (assoc 42 ed)) h (cdr (assoc 43 ed)) att (cdr (assoc 71 ed)))
     (if (and w h att (> w 0.0) (> h 0.0))
       (progn
         (setq a   (cond ((assoc 11 ed) (angle '(0.0 0.0) (cdr (assoc 11 ed))))
                         ((assoc 50 ed) (cdr (assoc 50 ed)))
                         (T 0.0))
               col (rem (1- att) 3)
               row (/ (1- att) 3)
               x0  (- (* col w 0.5))
               y0  (cond ((= row 0) (- h)) ((= row 1) (- (* h 0.5))) (T 0.0))
               u   (list (cos a) (sin a)) v (yk:perp u)
               lc  (list (+ x0 (* w 0.5)) (+ y0 (* h 0.5))))
         (list (yk:v+ p (yk:v+ (yk:vs u (car lc)) (yk:vs v (cadr lc))))
               u (* w 0.5) (* h 0.5)))))))

;;; 寸法の文字：寸法ブロックの中の文字から求める  → (四角 高さ) か nil
(defun yk:dim-text (e ed / bn bh be sub bb o h res)
  (setq bn (cdr (assoc 2 ed)))
  (if (and (yk:zup ed) bn (setq bh (tblobjname "BLOCK" bn))
           (setq bb (yk:bbox e)) (yk:dim-ok bh bb))
    (progn
      (setq be (entnext bh))
      (while (and be (not res) (/= "ENDBLK" (cdr (assoc 0 (setq sub (entget be))))))
        (if (and (member (cdr (assoc 0 sub)) '("MTEXT" "TEXT"))
                 (setq h (cdr (assoc 40 sub))) (> h 0.0)
                 (setq o (yk:text-obb sub)))
          (setq res (list o h)))
        (setq be (entnext be)))))
  res)

;;; マルチ引出線：平面が図面と平行か（最初の 11 = 文字の法線）
(defun yk:mld-zup (ed / n)
  (or (null (setq n (cdr (assoc 11 ed)))) (equal n '(0.0 0.0 1.0) 1e-8)))

;;; 長い文字を 250 文字ずつに分ける（MTEXT の 3 / 1 用）
(defun yk:str-codes (str / res)
  (while (> (strlen str) 250)
    (setq res (cons (cons 3 (substr str 1 250)) res) str (substr str 251)))
  (reverse (cons (cons 1 str) res)))

;;; マルチ引出線の文字：同じ内容の一時的なマルチテキストを作って大きさを測る → (四角 高さ) か nil
(defun yk:mld-text (obj ed / str h w att ins dir sty tmp o)
  (setq str (vl-catch-all-apply 'vla-get-TextString (list obj)))
  (if (vl-catch-all-error-p str) (setq str (cdr (assoc 304 ed))))
  (setq h   (cdr (assoc 41 ed))
        w   (cdr (assoc 43 ed))
        att (cdr (assoc 171 ed))
        ins (cdr (assoc 12 ed))
        dir (cdr (assoc 13 ed))
        sty (cdr (assoc 340 ed)))
  (if (and str (/= str "") h (> h 0.0) ins)
    (progn
      (setq tmp (entmakex
                  (append
                    (list '(0 . "MTEXT") '(100 . "AcDbEntity") (cons 8 (cdr (assoc 8 ed)))
                          '(100 . "AcDbMText") (cons 10 ins) (cons 40 h)
                          (cons 41 (if (and w (> w 0.0)) w 0.0))
                          (cons 71 (if (and att (<= 1 att 9)) att 1)))
                    (if (and sty (= (type sty) 'ENAME))
                      (list (cons 7 (cdr (assoc 2 (entget sty))))))
                    (if dir (list (cons 11 dir)))
                    (yk:str-codes str))))
      (if tmp
        (progn
          (setq o (yk:text-obb (entget tmp)))
          (entdel tmp)))
      (if o (list o h)))))

;;; マルチ引出線の引出線 → ((線番号 . 頂点の並び x y z x y z ...) ...)
(defun yk:mld-lines (obj / n li found idxs res)
  (setq n (vla-get-LeaderCount obj) li 0 found 0)
  (while (and (< found n) (< li (+ n 20)))
    (setq idxs (vl-catch-all-apply 'vlax-invoke (list obj 'GetLeaderLineIndexes li)))
    (if (not (vl-catch-all-error-p idxs))
      (progn
        (setq found (1+ found))
        (foreach k idxs
          (setq res (cons (cons k (vlax-invoke obj 'GetLeaderLineVertices k)) res)))))
    (setq li (1+ li)))
  (reverse res))

(defun yk:flat->pts (l / res)
  (while (>= (length l) 3)
    (setq res (cons (list (car l) (cadr l) (caddr l)) res) l (cdddr l)))
  (reverse res))

;;; マルチ引出線を障害物に：引出線は線、文字は四角（動かす対象なら文字は登録しない）
(defun yk:add-mld (e ed / obj o)
  (setq obj (vlax-ename->vla-object e))
  (if (and (yk:mld-zup ed) (yk:bb-hit (yk:bbox e) *yk:reg*))
    (progn
      (foreach ln (yk:mld-lines obj) (yk:add-pts (yk:flat->pts (cdr ln)) nil))
      (if (and (not *yk:own*)
               (equal 2 (vl-catch-all-apply 'vla-get-ContentType (list obj)))
               (setq o (car (yk:mld-text obj ed))))
        (yk:add-box o)))))

;;; 動かす対象の情報 → (種類 四角 高さ Z 補足) か nil   種類：T=文字 D=寸法 M=マルチ引出線
(defun yk:target-info (e ed / typ obj dt pos h o)
  (setq typ (cdr (assoc 0 ed)) obj (vlax-ename->vla-object e))
  (cond
    ((= typ "DIMENSION")
     (if (and (setq dt (yk:dim-text e ed))
              (setq pos (vlax-get obj 'TextPosition)))
       (list 'D (car dt) (cadr dt) (caddr pos) (list pos (cdr (assoc 70 ed))))))
    ((= typ "MULTILEADER")
     (if (and (yk:mld-zup ed)
              (equal 2 (vl-catch-all-apply 'vla-get-ContentType (list obj)))
              (setq dt (yk:mld-text obj ed)))
       (list 'M (car dt) (cadr dt) (caddr (cdr (assoc 12 ed))) (yk:mld-lines obj))))
    ((and (yk:zup ed) (setq h (cdr (assoc 40 ed))) (> h 0.0) (setq o (yk:text-obb ed)))
     (list 'T o h (caddr (cdr (assoc 10 ed))) nil))))

;;; ------------------------------------------------------------
;;;  判定と探索
;;; ------------------------------------------------------------
;;; 障害物の持ち主（寸法・マルチ引出線の番号）
(defun yk:owner (it) (if (eq (car it) 'S) (cadddr it) (caddr it)))

(defun yk:hits (o idx / bb)
  (setq bb (yk:obb-aabb o))
  (or (vl-some '(lambda (it)
                  (and (not (equal (yk:owner it) idx))
                       (if (eq (car it) 'S)
                         (yk:seg-hit o (cadr it) (caddr it))
                         (yk:obb-hit o (cadr it)))))
               (yk:gget "YKS" bb))
      (vl-some '(lambda (r) (and (/= (car r) idx) (yk:obb-hit o (cdr r))))
               (yk:gget "YKT" bb))))

;;; 元の位置のまわりを輪状に探し、点数（移動距離＋方向による減点）の良い所を選ぶ
;;; 文字：文字の並ぶ方向への移動を少し減点（上下に逃がす）
;;; 寸法：寸法線と直角方向への移動を大きく減点（寸法線に沿って横にずらす）
;;; 点数は移動距離以上になるので、「これ以上遠くでは今の最良を超えられない」所で探索を終える
(defun yk:search (idx obb h kind / m step kmax u base k j r ang dir dvec cand sc best bestsc)
  (setq m    (* *yk:clear* h)
        step (* 0.5 h)
        kmax (max 1 (fix (+ 0.999 (/ (* *yk:maxd* h) step))))
        u    (cadr obb)
        base (+ (angle '(0.0 0.0) u) (/ pi 2.0))
        k    1)
  (while (and (<= k kmax) (not (and bestsc (>= (* k step) bestsc))))
    (setq r (* k step) j 0)
    (repeat *yk:ndir*
      (setq ang  (+ base (/ (* 2.0 pi j) *yk:ndir*))
            dir  (list (cos ang) (sin ang))
            dvec (yk:vs dir r)
            cand (yk:obb-move obb dvec))
      (if (not (yk:hits (yk:obb-grow cand m) idx))
        (progn
          (setq sc (* r (+ 1.0 (if (eq kind 'D)
                                   (* 3.0 (abs (yk:dot dir (yk:perp u))))
                                   (* 0.25 (abs (yk:dot dir u)))))))
          (if (or (null bestsc) (< sc bestsc))
            (setq bestsc sc best (list dvec cand)))))
      (setq j (1+ j)))
    (setq k (1+ k)))
  best)

;;; ------------------------------------------------------------
;;;  図面の情報
;;; ------------------------------------------------------------
(defun yk:space ( )
  (if (and (= 0 (getvar "TILEMODE")) (/= 1 (getvar "CVPORT"))) "Model" (getvar "CTAB")))

(defun yk:hidden-layers ( / d res)
  (while (setq d (tblnext "LAYER" (null d)))
    (if (or (minusp (cdr (assoc 62 d))) (= 1 (logand 1 (cdr (assoc 70 d)))))
      (setq res (cons (strcase (cdr (assoc 2 d))) res))))
  res)

(defun yk:locked-p (lay / d)
  (and (setq d (tblsearch "LAYER" lay)) (= 4 (logand 4 (cdr (assoc 70 d))))))

(defun yk:leader-pt (o p / c u v lx ly)
  (setq c  (car o) u (cadr o) v (yk:perp u)
        lx (max (- (caddr o)) (min (caddr o) (yk:dot (yk:v- p c) u)))
        ly (max (- (cadddr o)) (min (cadddr o) (yk:dot (yk:v- p c) v))))
  (yk:v+ c (yk:v+ (yk:vs u lx) (yk:vs v ly))))

;;; ------------------------------------------------------------
;;;  選択
;;; ------------------------------------------------------------
(defun yk:types ( )
  (strcat "TEXT,MTEXT" (if *yk:movdim* ",DIMENSION" "") (if *yk:movmld* ",MULTILEADER" "")))

(defun yk:select (space / ss ans)
  (cond
    ((setq ss (ssget "_I" (list (cons 0 (yk:types)))))
     (sssetfirst nil nil)
     ss)
    (T
     (princ "\n逃がす文字を選択（何も選ばず Enter で他の選択肢）")
     (setq ss (ssget (list (cons 0 (yk:types)))))
     (if ss
       ss
       (progn
         (initget "All Settings eXit")
         (setq ans (getkword "\n選択なし [図面全体(A)/設定(S)/終了(X)] <終了>: "))
         (cond ((= ans "All")
                (ssget "_X" (list (cons 0 (yk:types)) (cons 410 space))))
               ((= ans "Settings")
                (yk:settings)
                (yk:load-cfg)
                (yk:select space))
               (T nil)))))))

;;; ------------------------------------------------------------
;;;  元に戻す（確認で「元に戻す」、または Esc・エラーのとき）
;;; ------------------------------------------------------------
;;; 動かした量を記録  yk-moved の中身 = (番号 オブジェクト 合計dx 合計dy 対象の情報)
(defun yk:rec-move (r d / old)
  (if (setq old (assoc (car r) yk-moved))
    (setq yk-moved (subst (list (car r) (nth 6 r) (+ (caddr old) (car d)) (+ (cadddr old) (cadr d)) r)
                          old yk-moved))
    (setq yk-moved (cons (list (car r) (nth 6 r) (car d) (cadr d) r) yk-moved))))

;;; マルチ引出線：矢印の先（各引出線の最初の点）を元の位置へ戻す
(defun yk:mld-fix-arrows (obj lines / cur org)
  (foreach ln lines
    (setq org (cdr ln)
          cur (vl-catch-all-apply 'vlax-invoke (list obj 'GetLeaderLineVertices (car ln))))
    (if (and (not (vl-catch-all-error-p cur)) (>= (length cur) 3) (>= (length org) 3))
      (vl-catch-all-apply 'vlax-invoke
        (list obj 'SetLeaderLineVertices (car ln)
              (append (list (car org) (cadr org) (caddr org)) (cdddr cur)))))))

;;; 1つ動かす（d = 今回の移動量）
(defun yk:apply-move (r d / mv p obj)
  (yk:rec-move r d)
  (setq mv (assoc (car r) yk-moved) obj (nth 6 r))
  (cond
    ((eq (nth 7 r) 'D)                     ; 寸法：文字の位置を指定（寸法の仕組みで動かす）
     (setq p (car (nth 8 r)))
     (vlax-put obj 'TextPosition (list (+ (car p) (caddr mv)) (+ (cadr p) (cadddr mv)) (caddr p))))
    ((eq (nth 7 r) 'M)                     ; マルチ引出線：全体を動かし、矢印の先だけ戻す
     (vla-move obj (vlax-3d-point '(0.0 0.0 0.0)) (vlax-3d-point (list (car d) (cadr d) 0.0)))
     (yk:mld-fix-arrows obj (nth 8 r)))
    (T
     (vla-move obj (vlax-3d-point '(0.0 0.0 0.0)) (vlax-3d-point (list (car d) (cadr d) 0.0))))))

;;; 1つ元に戻す
(defun yk:undo-one (r dx dy / obj e ed)
  (setq obj (nth 6 r))
  (cond
    ((eq (nth 7 r) 'D)
     (vlax-put obj 'TextPosition (car (nth 8 r)))
     ;; 元が「標準の位置」だった寸法は、その状態（ユーザー指定位置の印なし）に戻す
     (if (and (setq e (vlax-vla-object->ename obj)) (setq ed (entget e))
              (/= (cdr (assoc 70 ed)) (cadr (nth 8 r))))
       (progn
         (entmod (subst (cons 70 (cadr (nth 8 r))) (assoc 70 ed) ed))
         (entupd e))))
    ((eq (nth 7 r) 'M)
     (vla-move obj (vlax-3d-point (list dx dy 0.0)) (vlax-3d-point '(0.0 0.0 0.0)))
     (foreach ln (nth 8 r)
       (vl-catch-all-apply 'vlax-invoke (list obj 'SetLeaderLineVertices (car ln) (cdr ln)))))
    (T
     (vla-move obj (vlax-3d-point (list dx dy 0.0)) (vlax-3d-point '(0.0 0.0 0.0))))))

(defun yk:revert ( )
  (foreach mv yk-moved
    (vl-catch-all-apply 'yk:undo-one (list (nth 4 mv) (caddr mv) (cadddr mv))))
  (foreach e yk-leaders (if (entget e) (entdel e)))
  (foreach mk yk-masks
    (vl-catch-all-apply 'vla-put-BackgroundFill (list (car mk) (cdr mk))))
  (setq yk-moved nil yk-leaders nil yk-masks nil yk-pending nil))

;;; ------------------------------------------------------------
;;;  メイン
;;; ------------------------------------------------------------
(defun c:YOKERU ( / *error* doc undo space ss i n e ed lay o h z idx recs
                    hidden nlock nfix nskip hmax hsum bb reg ext rw rh ss2 cnt
                    yk-cur yk-moved yk-leaders yk-masks yk-pending
                    r cur pend res m pass fails d tot anchor p1 le vecs ans
                    ssf nmoved nhit t0 inf ndim nmld mk)

  (defun *error* (msg / reverted)
    (if yk-pending (progn (vl-catch-all-apply 'yk:revert nil) (setq reverted T)))
    (redraw)
    (yk:cleanup)
    (if (and doc undo) (progn (vla-EndUndoMark doc) (setq undo nil)))
    (cond ((and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
           (princ (strcat "\n[YOKERU] エラー: " msg
                          (if reverted "（変更は元に戻しました）" ""))))
          (reverted (princ "\n[YOKERU] 中止しました。変更は元に戻しました。"))
          (T (princ "\n[YOKERU] 中止しました。")))
    (princ))

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)) *yk:hav* nil)
  (yk:cleanup)
  (yk:load-cfg)
  (setq space (yk:space))

  (if (setq ss (yk:select space))
    (progn
      (yk:load-cfg)                       ; 選択中に設定を変えた場合に備えて読み直す
      (vla-StartUndoMark doc)
      (setq undo T t0 (getvar "MILLISECS"))

      ;; ---- 1. 対象の文字 ----
      (setq hidden (yk:hidden-layers)
            nlock 0 nfix 0 nskip 0 ndim 0 nmld 0 idx 0 hmax 0.0 hsum 0.0 i 0 n (sslength ss))
      (repeat n
        (setq e (ssname ss i) ed (entget e) lay (cdr (assoc 8 ed)) i (1+ i))
        (cond
          ((member (strcase lay) hidden) (setq nskip (1+ nskip)))
          ((yk:locked-p lay) (setq nlock (1+ nlock)))
          ((and *yk:fixpat* (wcmatch (strcase lay) *yk:fixpat*)) (setq nfix (1+ nfix)))
          ((or (vl-catch-all-error-p (setq inf (vl-catch-all-apply 'yk:target-info (list e ed))))
               (null inf))
           (setq nskip (1+ nskip)))
          (T
           ;; recs の中身 = (番号 図形名 高さ 四角 Z 画層 オブジェクト 種類 補足)
           (setq idx  (1+ idx)
                 h    (nth 2 inf)
                 recs (cons (list idx e h (nth 1 inf) (nth 3 inf) lay (vlax-ename->vla-object e)
                                  (car inf) (nth 4 inf))
                            recs)
                 hmax (max hmax h)
                 hsum (+ hsum h))
           (cond ((eq (car inf) 'D) (setq ndim (1+ ndim)))
                 ((eq (car inf) 'M) (setq nmld (1+ nmld))))
           (yk:mark e (if (eq (car inf) 'T) T idx)))))
      (setq recs (reverse recs))

      (if (null recs)
        (princ (strcat "\n[YOKERU] 動かせる文字がありません"
                       "（ロック " (itoa nlock) "・固定 " (itoa nfix) "・対象外 " (itoa nskip) "）。"))
        (progn
          ;; ---- 2. 処理範囲とマス目 ----
          (setq *yk:hav* (/ hsum (length recs)))
          (foreach r recs
            (setq bb (yk:obb-aabb (nth 3 r))
                  reg (if reg
                        (list (min (car reg) (car bb)) (min (cadr reg) (cadr bb))
                              (max (caddr reg) (caddr bb)) (max (cadddr reg) (cadddr bb)))
                        bb)))
          (setq ext (+ (* (+ *yk:maxd* *yk:clear* 1.0) hmax) (* 2.0 *yk:hav*))
                reg (list (- (car reg) ext) (- (cadr reg) ext) (+ (caddr reg) ext) (+ (cadddr reg) ext))
                rw  (- (caddr reg) (car reg))
                rh  (- (cadddr reg) (cadr reg))
                *yk:reg* reg
                *yk:gx0* (car reg)
                *yk:gy0* (cadr reg)
                *yk:cs*  (max (* 2.0 *yk:hav*) (/ (max rw rh) 3000.0)))

          ;; ---- 3. 障害物を読み込む（画面のズームに関係なく図面全体から）----
          (princ "\n[YOKERU] 周りの図形を読み込み中...")
          (if (setq ss2 (ssget "_X" (list (cons 410 space))))
            (progn
              (setq i 0)
              (repeat (sslength ss2)
                (setq e (ssname ss2 i) ed (entget e) lay (cdr (assoc 8 ed)) i (1+ i)
                      mk (yk:marked-p ed))
                (if (not (or (eq mk T)          ; 動かす文字そのものは別に扱う
                             (member (strcase lay) hidden)
                             (and *yk:ignpat* (wcmatch (strcase lay) *yk:ignpat*))))
                  (progn
                    ;; 動かす寸法・マルチ引出線の線は、自分の文字以外の障害物として登録
                    (setq *yk:own* (if (numberp mk) mk))
                    (vl-catch-all-apply 'yk:add-entity (list e ed))
                    (setq *yk:own* nil))))))

          ;; ---- 4. 文字をマス目へ ----
          (foreach r recs
            (yk:gadd "YKT" (yk:obb-aabb (nth 3 r)) (cons (car r) (nth 3 r)))
            (setq yk-cur (cons (cons (car r) (nth 3 r)) yk-cur)))

          ;; ---- 5. 重なっている文字を探し、込み合っている順に並べる ----
          (foreach r recs
            (setq o (nth 3 r) m (* *yk:clear* (nth 2 r)))
            (if (yk:hits (yk:obb-grow o m) (car r))
              (setq pend (cons (cons (length (append (yk:gget "YKS" (yk:obb-aabb o))
                                                     (yk:gget "YKT" (yk:obb-aabb o))))
                                     r)
                               pend))))
          (setq nhit (length pend)
                pend (mapcar 'cdr (vl-sort pend '(lambda (a b) (> (car a) (car b))))))

          ;; ---- 6. 逃がす（最大3周。逃げられなかった文字は周りが動いた後にもう一度）----
          (setq pass 1 yk-pending T)
          (while (and pend (<= pass 3))
            (setq fails nil)
            (foreach r pend
              (setq cur (cdr (assoc (car r) yk-cur))
                    m   (* *yk:clear* (nth 2 r)))
              (if (yk:hits (yk:obb-grow cur m) (car r))
                (if (setq res (yk:search (car r) cur (nth 2 r) (nth 7 r)))
                  (progn
                    (setq d (car res))
                    (yk:apply-move r d)
                    (yk:gdel "YKT" (yk:obb-aabb cur) (car r))
                    (yk:gadd "YKT" (yk:obb-aabb (cadr res)) (cons (car r) (cadr res)))
                    (setq yk-cur (subst (cons (car r) (cadr res)) (assoc (car r) yk-cur) yk-cur)))
                  (setq fails (cons r fails)))))
            (setq pend (reverse fails) pass (1+ pass)))

          ;; ---- 7. 引出線（文字だけ。寸法・マルチ引出線は自分の仕組みで線が付く）----
          (if *yk:ldr*
            (foreach mv yk-moved
              (setq r   (assoc (car mv) recs)
                    tot (list (caddr mv) (cadddr mv)))
              (if (and (eq (nth 7 r) 'T)
                       (>= (distance '(0.0 0.0) tot) (* *yk:ldrd* (nth 2 r))))
                (progn
                  (setq anchor (car (nth 3 r))
                        o      (yk:obb-grow (cdr (assoc (car r) yk-cur)) (* 0.5 *yk:clear* (nth 2 r)))
                        p1     (yk:leader-pt o anchor))
                  (if (> (distance anchor p1) (* 0.25 (nth 2 r)))
                    (if (setq le (entmakex (list '(0 . "LINE")
                                                 (cons 8 (nth 5 r))
                                                 (list 10 (car anchor) (cadr anchor) (nth 4 r))
                                                 (list 11 (car p1) (cadr p1) (nth 4 r)))))
                      (setq yk-leaders (cons le yk-leaders))))))))

          ;; ---- 8. 逃げ場がなかったマルチテキストに背景マスク（設定時のみ）----
          (if *yk:mask*
            (foreach r pend
              (if (and (eq (nth 7 r) 'T) (= "MTEXT" (cdr (assoc 0 (entget (nth 1 r))))))
                (if (not (vl-catch-all-error-p
                           (setq o (vl-catch-all-apply 'vla-get-BackgroundFill (list (nth 6 r))))))
                  (progn
                    (setq yk-masks (cons (cons (nth 6 r) o) yk-masks))
                    (vl-catch-all-apply 'vla-put-BackgroundFill (list (nth 6 r) :vlax-true)))))))

          (setq nmoved (length yk-moved))

          ;; ---- 9. 確認（動いた文字＝緑の矢印、逃げ場なし＝赤枠）----
          (if (and *yk:confirm* (or yk-moved pend))
            (progn
              (foreach mv yk-moved
                (setq r (assoc (car mv) recs)
                      z (nth 4 r))
                (setq vecs (append vecs
                                   (list 3 (trans (list (car (car (nth 3 r))) (cadr (car (nth 3 r))) z) 0 1)
                                           (trans (list (car (car (cdr (assoc (car r) yk-cur))))
                                                        (cadr (car (cdr (assoc (car r) yk-cur)))) z) 0 1)))))
              (foreach r pend
                (setq z (nth 4 r) cnt (yk:obb-corners (cdr (assoc (car r) yk-cur))))
                (setq cnt (append cnt (list (car cnt))))
                (while (cdr cnt)
                  (setq vecs (append vecs (list 1 (trans (list (car (car cnt)) (cadr (car cnt)) z) 0 1)
                                                  (trans (list (car (cadr cnt)) (cadr (cadr cnt)) z) 0 1)))
                        cnt (cdr cnt))))
              (if vecs (grvecs vecs))
              (princ (strcat "\n[YOKERU] 移動 " (itoa nmoved) " 個（緑の矢印）"
                             (if pend (strcat "・逃げ場なし " (itoa (length pend)) " 個（赤枠）") "")))
              (initget "Yes Undo")
              (setq ans (getkword "\n確定しますか？ [確定(Y)/元に戻す(U)] <確定>: "))
              (redraw)
              (if (= ans "Undo")
                (progn
                  (yk:revert)
                  (setq nmoved -1)))))
          (setq yk-pending nil)

          ;; ---- 10. 結果の通知 ----
          (if (= nmoved -1)
            (princ "\n[YOKERU] 元に戻しました。")
            (progn
              (princ (strcat "\n[YOKERU] 完了：対象 " (itoa (length recs)) " 個"
                             (if (> (+ ndim nmld) 0)
                               (strcat "（うち寸法 " (itoa ndim) "・マルチ引出線 " (itoa nmld) "）")
                               "")
                             " / 重なり " (itoa nhit)
                             " 個 → 移動 " (itoa nmoved)
                             " 個（引出線 " (itoa (length yk-leaders)) " 本）"))
              (if pend
                (princ (strcat "\n          逃げ場なし " (itoa (length pend)) " 個"
                               (if yk-masks (strcat "（うち " (itoa (length yk-masks)) " 個に背景マスク）") "")
                               " → 選択状態にしました")))
              (if (> (+ nlock nfix nskip) 0)
                (princ (strcat "\n          対象外：ロック画層 " (itoa nlock)
                               "・固定画層 " (itoa nfix) "・非表示/3D/その他 " (itoa nskip))))
              (princ (strcat "\n          処理時間 "
                             (rtos (/ (- (getvar "MILLISECS") t0) 1000.0) 2 2) " 秒"))))

          (yk:cleanup)
          (vla-EndUndoMark doc)
          (setq undo nil)

          ;; 逃げ場がなかった文字を選択状態に（確認・手直し用）
          (if (and pend (/= nmoved -1))
            (progn
              (setq ssf (ssadd))
              (foreach r pend (ssadd (nth 1 r) ssf))
              (sssetfirst nil ssf)))))
      (if undo (progn (vla-EndUndoMark doc) (setq undo nil)))))
  (yk:cleanup)
  (princ))

(defun c:YK ( ) (c:YOKERU))

;;; ------------------------------------------------------------
;;;  設定画面
;;; ------------------------------------------------------------
(defun yk:onoff (key) (if (yk:cfgb key) "する" "しない"))

(defun yk:show-settings ( )
  (princ "\n──────── YOKERU 設定 ────────")
  (princ (strcat "\n 余白(C)       : 文字高さ × " (yk:cfg "Clear")))
  (princ (strcat "\n 距離(D)       : 最大 文字高さ × " (yk:cfg "MaxDist") " まで動かす"))
  (princ (strcat "\n 方向数(N)     : " (yk:cfg "Dirs") " 方向を探す"))
  (princ (strcat "\n 引出線(L)     : " (yk:onoff "Leader")))
  (princ (strcat "\n 引出線距離(E) : 文字高さ × " (yk:cfg "LdrDist") " 以上動いたら引出線"))
  (princ (strcat "\n ブロック(B)   : 障害物に" (yk:onoff "UseBlk")))
  (princ (strcat "\n 寸法(M)       : 障害物に" (yk:onoff "UseDim")))
  (princ (strcat "\n ハッチ(H)     : 障害物に" (yk:onoff "UseHat")))
  (princ (strcat "\n 固定画層(F)   : " (if (= (yk:cfg "FixLay") "") "（なし）" (yk:cfg "FixLay"))))
  (princ (strcat "\n 無視画層(I)   : " (if (= (yk:cfg "IgnLay") "") "（なし）" (yk:cfg "IgnLay"))))
  (princ (strcat "\n マスク(K)     : 逃げ場のないマルチテキストに背景マスクを" (yk:onoff "MaskFail")))
  (princ (strcat "\n 確認(O)       : 実行後に確認" (yk:onoff "Confirm")))
  (princ (strcat "\n 寸法の文字(T) : 動かす対象に" (yk:onoff "MoveDim")))
  (princ (strcat "\n マルチ引出線(U): 動かす対象に" (yk:onoff "MoveMld")))
  (princ "\n──────────────────────────"))

(defun yk:ask-real (key msg bits / v)
  (initget bits)
  (setq v (getreal (strcat "\n" msg " <" (yk:cfg key) ">: ")))
  (if v (yk:setcfg key (rtos v 2 3))))

(defun yk:toggle (key) (yk:setcfg key (if (yk:cfgb key) "0" "1")))

(defun yk:ask-layers (key msg / s)
  (setq s (getstring T (strcat "\n" msg "（ワイルドカード可・カンマ区切り、「.」で空に） <"
                               (if (= (yk:cfg key) "") "なし" (yk:cfg key)) ">: ")))
  (cond ((= s "") nil)
        ((= s ".") (yk:setcfg key ""))
        (T (yk:setcfg key s))))

(defun yk:settings ( / k done v)
  (while (not done)
    (yk:show-settings)
    (initget "Clear Dist Ndir Leader lEngth Block diMension Hatch Fix Ignore masK cOnfirm dimText mUltileader Reset eXit")
    (setq k (getkword (strcat "\n変更する項目 [余白(C)/距離(D)/方向数(N)/引出線(L)/引出線距離(E)/"
                              "ブロック(B)/寸法(M)/ハッチ(H)/固定画層(F)/無視画層(I)/マスク(K)/"
                              "確認(O)/寸法の文字(T)/マルチ引出線(U)/初期値(R)/終了(X)] <終了>: ")))
    (cond
      ((or (null k) (= k "eXit")) (setq done T))
      ((= k "Clear")     (yk:ask-real "Clear" "余白（文字高さに対する割合、例 0.25）" 4))
      ((= k "Dist")      (yk:ask-real "MaxDist" "最大移動距離（文字高さの何倍、例 6）" 6))
      ((= k "Ndir")
       (initget 6)
       (if (setq v (getint (strcat "\n探す方向の数（4〜64） <" (yk:cfg "Dirs") ">: ")))
         (yk:setcfg "Dirs" (itoa (max 4 (min 64 v))))))
      ((= k "Leader")    (yk:toggle "Leader"))
      ((= k "lEngth")    (yk:ask-real "LdrDist" "引出線を付ける移動距離（文字高さの何倍以上）" 4))
      ((= k "Block")     (yk:toggle "UseBlk"))
      ((= k "diMension") (yk:toggle "UseDim"))
      ((= k "Hatch")     (yk:toggle "UseHat"))
      ((= k "Fix")       (yk:ask-layers "FixLay" "動かさない画層"))
      ((= k "Ignore")    (yk:ask-layers "IgnLay" "障害物にしない画層"))
      ((= k "masK")      (yk:toggle "MaskFail"))
      ((= k "cOnfirm")   (yk:toggle "Confirm"))
      ((= k "dimText")   (yk:toggle "MoveDim"))
      ((= k "mUltileader") (yk:toggle "MoveMld"))
      ((= k "Reset")
       (foreach c *yk:cfgdef* (yk:setcfg (car c) (cadr c)))
       (princ "\n初期値に戻しました。"))))
  (princ))

(defun c:YOKERUSET ( / *error*)
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\n[YOKERU] エラー: " msg)))
    (princ))
  (yk:settings)
  (princ "\n[YOKERU] 設定を保存しました。")
  (princ))

(defun c:YKS ( ) (c:YOKERUSET))

(princ "\n[YokeruText 1.1.0] 読み込み完了  YOKERU(YK)=文字の重なりを避ける / YOKERUSET(YKS)=設定")
(princ)

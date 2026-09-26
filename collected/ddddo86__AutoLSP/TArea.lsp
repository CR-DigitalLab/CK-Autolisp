;;; TArea.lsp
;;; 指令: TAREA
;;; 功能: 選取閉合聚合線，計算面積並在指定位置建立平方公尺文字

(defun _TArea-UnitFactor (/ unit)
	(setq unit (getvar "INSUNITS"))
	(cond
		((= unit 1) 0.00064516)       ; inch -> square metre
		((= unit 2) 0.09290304)       ; foot
		((= unit 4) 0.000001)         ; millimetre
		((= unit 5) 0.0001)            ; centimetre
		((= unit 6) 1.0)               ; metre
		((= unit 7) 1000000.0)         ; kilometre
		((= unit 10) 0.83612736)       ; yard
		((= unit 14) 0.01)             ; decimetre
		((= unit 15) 100.0)             ; decametre
		(T 0.000001)                  ; unitless drawings default to mm
	)
)

(defun _TArea-ClosedPolylineP (ename / data type flags)
	(setq data  (entget ename)
				type  (cdr (assoc 0 data))
				flags (cdr (assoc 70 data)))
	(and (member type '("LWPOLYLINE" "POLYLINE"))
			 flags
			 (= 1 (logand 1 flags)))
)

(defun _TArea-PreparePolyline (ename / object closeResult)
	(if (_TArea-ClosedPolylineP ename)
		(vlax-ename->vla-object ename)
		(progn
			(setq object     (vlax-ename->vla-object ename)
					 closeResult (vl-catch-all-apply 'vla-put-Closed (list object :vlax-true)))
			(if (or (vl-catch-all-error-p closeResult)
					(not (vla-get-Closed object)))
				(progn
					(prompt "\n錯誤：開放聚合線無法封閉，TAREA 已結束。")
					(setq *TArea-Stop* T)
					nil
				)
				(progn
					(prompt "\n開放聚合線已自動封閉。")
					object
				)
			)
		)
)
)

(defun _TArea-GetTextSettings (/ selection object objectName)
	(setq selection (entsel "\n選取文字樣板(Enter使用記憶): "))
	(cond
		((null selection)
		 (if (and *TArea-TextHeight* *TArea-TextStyle*)
			 (list *TArea-TextHeight* *TArea-TextStyle*)
			 (progn
				 (prompt "\n尚未有文字樣板記憶，請選取 TEXT 或 MTEXT。")
				 nil
			 )
		 )
		)
		(T
		 (setq object     (vlax-ename->vla-object (car selection))
					 objectName (vla-get-ObjectName object))
		 (if (member objectName '("AcDbText" "AcDbMText"))
			 (progn
				 (setq *TArea-TextHeight* (vla-get-Height object)
						 *TArea-TextStyle* (vla-get-StyleName object))
				 (list *TArea-TextHeight* *TArea-TextStyle*)
			 )
			 (progn
				 (prompt "\n選取的物件不是 TEXT 或 MTEXT。")
				 nil
			 )
		 )
		)
	)
)

(defun _TArea-UCSAngle (/ origin xaxis)
	(setq origin (trans '(0.0 0.0 0.0) 1 0 T)
			xaxis  (trans '(1.0 0.0 0.0) 1 0 T))
	(angle origin xaxis)
)

(defun _TArea-MakeText (text point height style layer rotation)
	(setq point (trans point 1 0))
	(entmakex
		(list
			'(0 . "TEXT")
			'(100 . "AcDbEntity")
			'(100 . "AcDbText")
			(cons 10 point)
			(cons 11 point)
			(cons 40 height)
			(cons 1 text)
			(cons 7 style)
			(cons 8 layer)
			(cons 50 rotation)
			'(72 . 1)
			'(73 . 2)
		)
	)
)

(defun _TArea-GetPointWithPreview (text height style layer rotation / event code data point preview finished confirmed entityData)
	(prompt "\n移動游標預覽文字位置，按左鍵確定，按 Enter 或 Esc 取消: ")
	(setq finished nil
				confirmed nil)
	(while (not finished)
		(setq event (grread T 15 0)
				code  (car event)
				data  (cadr event))
		(cond
			((= code 5)
			 (setq point data)
			 (if preview
				 (progn
					(setq entityData (entget preview))
					(setq entityData (subst (cons 10 (trans point 1 0)) (assoc 10 entityData) entityData))
					(setq entityData (subst (cons 11 (trans point 1 0)) (assoc 11 entityData) entityData))
					(entmod entityData)
					(redraw preview 3)
				 )
				 (setq preview (_TArea-MakeText text point height style layer rotation))
			 )
			)
			((= code 3)
			 (if data
				 (setq point data))
			 (if (and point (null preview))
				 (setq preview (_TArea-MakeText text point height style layer rotation)))
			 (setq confirmed T
					 finished  T)
			)
			((and (= code 2) (or (= data 13) (= data 27)))
			 (if (= data 27)
				 (setq *TArea-Stop* T))
			 (setq finished T))
		)
	)
	(if (and (not confirmed) preview)
		(entdel preview))
	(if confirmed point nil)
)

(defun c:TAREA (/ *error* oldcmdecho selection ename object area areaText insertPoint textHeight textStyle textSettings textRotation)
	(vl-load-com)
	(setq oldcmdecho (getvar "CMDECHO"))

	(defun *error* (message)
		(setvar "CMDECHO" oldcmdecho)
		(if (and message
						 (not (wcmatch (strcase message) "*CANCEL*,*QUIT*")))
			(prompt (strcat "\n錯誤: " message))
		)
		(princ)
	)

	(setvar "CMDECHO" 0)
	(setq *TArea-Stop* nil)
	(setq textSettings (_TArea-GetTextSettings))
	(if textSettings
		(progn
			(setq textHeight  (car textSettings)
					 textStyle   (cadr textSettings)
					 textRotation (_TArea-UCSAngle))
			(while (not *TArea-Stop*)
				(setq selection (entsel "\n選取閉合聚合線 (Esc結束): "))
				(if selection
					(if (setq object (_TArea-PreparePolyline (car selection)))
						(progn
							(setq ename      (car selection)
										 area       (* (vla-get-Area object) (_TArea-UnitFactor))
										 areaText   (strcat (rtos area 2 2) "㎡")
										 insertPoint (_TArea-GetPointWithPreview
											 areaText
											 textHeight
											 textStyle
											 (getvar "CLAYER")
											 textRotation))
							(if insertPoint
								(progn
									(sssetfirst nil nil)
									(prompt (strcat "\n已建立文字: " areaText))
								)
								(prompt "\n未建立文字.")
							)
						)
						(prompt "\n選取的物件不是閉合聚合線。")
					)
					(prompt "\n未選取物件，請繼續選取或按 Esc 結束。")
				)
			)
		)
		(prompt "\n未取得文字樣板，未建立文字。")
	)
	(*error* nil)
)

(princ "\nTArea 已載入，輸入 TAREA 開始。")
(princ)

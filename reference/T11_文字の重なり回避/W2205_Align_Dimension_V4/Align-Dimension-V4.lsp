(defun C:AD ( / )
	(C:ALIGN_DIM)
)
-------------------------------------------------------------------------------------------------------------------
(defun C:ALIGN_DIM ( /
;	DistanceBaseGlobal
	PointBaseGlobal
	SelectionSet)

	(vl-load-com)
	(vl-catch-all-apply (function (lambda ( / )
		(while
			(or
				(not SelectionSet)
				(= (sslength SelectionSet) 0)
			)
			(progn
				(setq SelectionSet
					(ssget
						'(
							(0 . "*DIMENSION")
							(-4 . "<OR")
							(70 . 32)
							(70 . 33)
							(70 . 128)
							(70 . 129)
							(70 . 160)
							(70 . 161)
							(-4 . "OR>")
						)
					)
				)
			)
		)
	)))

	(if
		(and
			SelectionSet
			(/= (sslength SelectionSet) 0)
		)
		(ALDIM_RUN_ALIGN_DIM SelectionSet)
	)

	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_RUN_ALIGN_DIM ( SelectionSet /
	AnntativeScaleCurrent
	CheckModelSpace
	DistanceBaseGlobalTemp
	ListEnameObjectDim
	ListEnameObjectDimClassificationAngleDim
	ListEnameObjectDimClassificationDimstyle
	ListEnameObjectDimClassificationLevel
	ListEnameObjectDimClassificationLink
	ListEnameObjectDimClassificationScaleFactor
	ListTemp
	ListVarSystem_OldValue
	ListVlaLayerLock
	NumRoundAngle
	NumRoundDistance
	NumRoundScaleFactor
	TextHeight
	VlaDimstylesGroup
	VlaDrawingCurrent
	VlaLayersGroup)

	(setq NumRoundAngle 0.001)
	(setq NumRoundDistance 0.001)
	(setq NumRoundScaleFactor 0.001)
	(setq VlaDrawingCurrent (vla-get-activedocument (vlax-get-acad-object)))
	(vla-startundomark VlaDrawingCurrent)
	(ALDIM_CREATE_LISTVLALAYERLOCK)
	(ALDIM_SET_VARSYSTEM)
	(setq AnntativeScaleCurrent (getvar "CANNOSCALE"))
	(setq CheckModelSpace (= (getvar "TILEMODE") 1))

	(setq VlaDimstylesGroup (vla-get-dimstyles VlaDrawingCurrent))

	(setq ListEnameObjectDimClassificationDimstyle (ALDIM_CLASSIFICATION_DIMSTYLE SelectionSet))

	(foreach ListEnameObjectDim ListEnameObjectDimClassificationDimstyle
		(setq ListEnameObjectDimClassificationAngleDim (append (ALDIM_CLASSIFICATION_ANGLEDIM ListEnameObjectDim) ListEnameObjectDimClassificationAngleDim))
	)

	(foreach ListEnameObjectDim ListEnameObjectDimClassificationAngleDim
		(setq ListEnameObjectDimClassificationScaleFactor (append (ALDIM_CLASSIFICATION_SCALEFACTOR ListEnameObjectDim) ListEnameObjectDimClassificationScaleFactor))
	)

	(foreach ListEnameObjectDim ListEnameObjectDimClassificationScaleFactor
		(setq ListEnameObjectDimClassificationLink (append (ALDIM_CLASSIFICATION_LINK ListEnameObjectDim) ListEnameObjectDimClassificationLink))
	)

	(foreach ListEnameObjectDim ListEnameObjectDimClassificationLink
		(setq ListEnameObjectDimClassificationLevel (append (ALDIM_CLASSIFICATION_LEVEL ListEnameObjectDim) ListEnameObjectDimClassificationLevel))
	)

	(setq ListTemp (mapcar '(lambda (x) (ALDIM_GET_TEXTHEIGHT (car (car x)))) ListEnameObjectDimClassificationLevel))
	(setq TextHeight (/ (apply '+ ListTemp) (length ListTemp)))
	(if (not DistanceBaseGlobal)
		(progn
			(setq DistanceBaseGlobalTemp (vl-registry-read "HKEY_CURRENT_USER\\Software\\Align Dim" "DistanceBaseGlobal"))
			(if
				(and
					DistanceBaseGlobalTemp
					(setq DistanceBaseGlobalTemp (atof DistanceBaseGlobalTemp))
				)
				(setq DistanceBaseGlobal DistanceBaseGlobalTemp)
				(progn
					(setq ListTemp (mapcar '(lambda (x) (ALDIM_GET_DISTANCEBASE (car (car x)))) ListEnameObjectDimClassificationLevel))
					(setq DistanceBaseGlobal (/ (apply '+ ListTemp) (length ListTemp)))
				)
			)
		)
	)
	(if
		(or
			(> DistanceBaseGlobal (* TextHeight 4.0))
			(< DistanceBaseGlobal (* TextHeight 2.5))
		)
		(setq DistanceBaseGlobal (* TextHeight 3.0))
	)

	(vl-catch-all-apply (function (lambda ( / )
		(if (= (length ListEnameObjectDimClassificationLevel) 1)
			(progn
				(setq ListTemp (ALDIM_GET_BASEPOINTGLOBAL_DISTANCEBASEGLOBAL DistanceBaseGlobal TextHeight))
				(setq PointBaseGlobal (nth 0 ListTemp))
				(setq DistanceBaseGlobal (nth 1 ListTemp))
			)
			(setq DistanceBaseGlobal (ALDIM_GET_DISTANCEBASEGLOBAL DistanceBaseGlobal TextHeight))
		)

		(foreach ListEnameObjectDimGroup ListEnameObjectDimClassificationLevel
			(ALDIM_FIX_DIM_MAIN ListEnameObjectDimGroup)
		)
	)))

	(if CheckModelSpace
		(setvar "CANNOSCALE" AnntativeScaleCurrent)
	)
	(vl-registry-write "HKEY_CURRENT_USER\\Software\\Align Dim" "DistanceBaseGlobal" (rtos DistanceBaseGlobal 2))
	(ALDIM_RESET_VARSYSTEM)
	(ALDIM_RESTORE_LOCK_LAYER)
	(vla-endundomark VlaDrawingCurrent)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_BASEPOINTGLOBAL_DISTANCEBASEGLOBAL ( DistanceBaseGlobal TextHeight / 
	DistanceBaseGlobal
	PointBaseGlobal
	ListTemp
	Temp)

	(initget 32 "Baseline spacing")
	(setq Temp (getpoint "\nSpecify base point or [Baseline spacing]:"))
	(if (= Temp "Baseline")
		(progn
			(setq DistanceBaseGlobal (ALDIM_GET_DISTANCEBASEGLOBAL DistanceBaseGlobal TextHeight))
			(setq ListTemp (ALDIM_GET_BASEPOINTGLOBAL_DISTANCEBASEGLOBAL DistanceBaseGlobal TextHeight))
			(setq PointBaseGlobal (nth 0 ListTemp))
			(setq DistanceBaseGlobal (nth 1 ListTemp))
		)
		(setq PointBaseGlobal Temp)
	)
	(list PointBaseGlobal DistanceBaseGlobal)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_DISTANCEBASEGLOBAL ( DistanceBaseGlobal TextHeight / 
	DistanceBaseGlobal
	StringDistanceBaseValid
	Temp)

	(setq StringDistanceBaseValid (strcat "recommended value from " (rtos (* TextHeight 2.5) 2) " to " (rtos (* TextHeight 4.0) 2)))
	(initget 6)
	(setq Temp (getreal (strcat "\nSpecify baseline spacing for scale 1:1 (" StringDistanceBaseValid ") <" (rtos DistanceBaseGlobal 2)">:")))
	(if Temp
		(progn
			(if
				(and
					(<= Temp (* TextHeight 4.0))
					(>= Temp (* TextHeight 2.5))
				)
				(setq DistanceBaseGlobal Temp)
				(progn
					(princ "\nThe distance base is too big or too small. Please try again!")
					(ALDIM_GET_DISTANCEBASEGLOBAL DistanceBaseGlobal TextHeight)
				)
			)
        )
	)
	DistanceBaseGlobal
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CLASSIFICATION_DIMSTYLE ( SelectionSet /
	DataEnameObjectDim
	EnameObjectDim
	ListResult
	NameDimstyle
	Num
	Temp)

	(setq Num 0)
	(repeat (sslength SelectionSet)
		(setq EnameObjectDim (ssname SelectionSet Num))
		(setq DataEnameObjectDim (entget EnameObjectDim))
		(setq NameDimstyle (cdr (assoc 3 DataEnameObjectDim)))
		(if (setq Temp (assoc NameDimstyle ListResult))
			(setq ListResult (subst (cons NameDimstyle (cons EnameObjectDim (cdr Temp))) Temp ListResult))
			(setq ListResult (cons (list NameDimstyle EnameObjectDim) ListResult))
		)
		(setq Num (+ Num 1))
	)
	(setq ListResult (mapcar 'cdr ListResult))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CLASSIFICATION_ANGLEDIM ( ListEnameObjectDim /
	AngleDim
	ListResult
	Temp)

	(foreach EnameObjectDim ListEnameObjectDim
		(setq AngleDim (ALDIM_GET_ANGLEDIM EnameObjectDim))
		(setq AngleDim (ALDIM_ROUNDOFF_NUMBER AngleDim NumRoundAngle))
		(if (setq Temp (assoc AngleDim ListResult))
			(setq ListResult (subst (cons AngleDim (cons EnameObjectDim (cdr Temp))) Temp ListResult))
			(setq ListResult (cons (list AngleDim EnameObjectDim) ListResult))
		)	
	)
	(setq ListResult (mapcar 'cdr ListResult))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CLASSIFICATION_SCALEFACTOR ( ListEnameObjectDim /
	ScaleFactor
	EnameObjectDim
	ListResult
	Temp)

	(foreach EnameObjectDim ListEnameObjectDim
		(setq ScaleFactor (ALDIM_GET_SCALEFACTOR EnameObjectDim))
		(setq ScaleFactor (ALDIM_ROUNDOFF_NUMBER ScaleFactor NumRoundScaleFactor))
		(if (setq Temp (assoc ScaleFactor ListResult))
			(setq ListResult (subst (cons ScaleFactor (cons EnameObjectDim (cdr Temp))) Temp ListResult))
			(setq ListResult (cons (list ScaleFactor EnameObjectDim) ListResult))
		)	
	)

	(setq ListResult (mapcar 'cdr ListResult))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CLASSIFICATION_LINK ( ListEnameObjectDim / 
	AngleDim
	AngleDimPer
	CheckPosityDistance
	DataEnameObjectDim
	Distance1
	Distance2
	EnameObjectDim
	ListDataObjectDimClassificationLink
	ListEnameObjectDimClassificationLink
	ListDimLink1
	ListDimLink2
	ListEnameObjectDim1
	ListEnameObjectDim2
	Point0
	Point10
	Point13
	Point13Temp
	Point14
	PointTemp)

	(setq Point0 (list 0.0 0.0 0.0))
	(setq EnameObjectDim (car ListEnameObjectDim))
	(setq AngleDim (ALDIM_GET_ANGLEDIM EnameObjectDim))
	(setq AngleDimPer (+ AngleDim (* pi 0.5)))

	(foreach EnameObjectDim ListEnameObjectDim
		(setq DataEnameObjectDim (entget EnameObjectDim))
		(setq Point10 (cdr (assoc 10 DataEnameObjectDim)))
		(setq Point13 (cdr (assoc 13 DataEnameObjectDim)))
		(setq Point14 (cdr (assoc 14 DataEnameObjectDim)))
		(setq PointTemp (ALDIM_PROJECTION_TO_LINE Point0 Point10 Point14))
		(if (< (angle Point0 PointTemp) Pi)
			(setq CheckPosityDistance 1.0)
			(setq CheckPosityDistance -1.0)
		)
		(setq Distance1 (* (distance Point0 PointTemp) CheckPosityDistance))
		(setq Distance1 (ALDIM_ROUNDOFF_NUMBER Distance1 NumRoundDistance))
		(setq ListDimLink1 (ALDIM_FIND_POSISION_DIM_LINK Distance1 ListDataObjectDimClassificationLink))
		(setq ListDataObjectDimClassificationLink (vl-remove ListDimLink1 ListDataObjectDimClassificationLink))
		(setq Point13Temp (polar Point13 AngleDimPer 1000))
		(setq PointTemp (ALDIM_PROJECTION_TO_LINE Point0 Point13 Point13Temp))
		(if (< (angle Point0 PointTemp) Pi)
			(setq CheckPosityDistance 1.0)
			(setq CheckPosityDistance -1.0)
		)
		(setq Distance2 (* (distance Point0 PointTemp) CheckPosityDistance))
		(setq Distance2 (ALDIM_ROUNDOFF_NUMBER Distance2 NumRoundDistance))
		(setq ListDimLink2 (ALDIM_FIND_POSISION_DIM_LINK Distance2 ListDataObjectDimClassificationLink))
		(setq ListDataObjectDimClassificationLink (vl-remove ListDimLink2 ListDataObjectDimClassificationLink))
		(setq ListDataObjectDimClassificationLink (cons (append ListDimLink1 ListDimLink2 (list (cons Distance1 EnameObjectDim) (cons Distance2 EnameObjectDim))) ListDataObjectDimClassificationLink))
	)
	
	(foreach ListEnameObjectDim1 ListDataObjectDimClassificationLink
		(setq ListEnameObjectDim1 (mapcar 'cdr ListEnameObjectDim1))
		(setq ListEnameObjectDim2 Nil)
		(foreach EnameObjectDim ListEnameObjectDim1
			(if (not (member EnameObjectDim ListEnameObjectDim2))
				(setq ListEnameObjectDim2 (cons EnameObjectDim ListEnameObjectDim2))
			)
		)
		(setq ListEnameObjectDimClassificationLink (cons ListEnameObjectDim2 ListEnameObjectDimClassificationLink))
	)
	ListEnameObjectDimClassificationLink
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_FIND_POSISION_DIM_LINK ( DistanceValue ListDataObjectDimClassificationLink / 
	ListDimLink
	ListDimLinkTemp)

	(while
		(and
			ListDataObjectDimClassificationLink
			(not ListDimLink)
		)
		(setq ListDimLinkTemp (car ListDataObjectDimClassificationLink))
		(if (assoc DistanceValue ListDimLinkTemp)
			(setq ListDimLink ListDimLinkTemp)
		)
		(setq ListDataObjectDimClassificationLink (cdr ListDataObjectDimClassificationLink))
	)
	ListDimLink
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CLASSIFICATION_LEVEL ( ListEnameObjectDim /
	AngleDim
	CheckPosityDistance
	DataEnameObjectDim
	DistanceBase
	DistanceBaseMax
	DistanceBaseMin
	DistanceLevel
	DistanceLevelPre
	DistanceLevelTemp
	DistanceRound
	EnameObjectDim
	Point0
	Point10
	PointPer
	PointTemp
	Level
	ListDistance_ListEnameObjectDim
	ListDistanceLevel
	ListDistanceLevelGroup
	ListEnameObjectDimClassificationLevel
	ListTemp
	ListTemp1
	ListTemp2
	ListResult
	ScaleFactor
	Temp)

	(setq Point0 (list 0.0 0.0 0.0))
	(setq EnameObjectDim (car ListEnameObjectDim))
	(setq AngleDim (ALDIM_GET_ANGLEDIM EnameObjectDim))
	(setq ScaleFactor (ALDIM_GET_SCALEFACTOR EnameObjectDim))
	(setq DistanceBase (ALDIM_GET_DISTANCEBASE EnameObjectDim))
	(setq DistanceBaseMax (* ScaleFactor DistanceBase 2.0))
	(setq DistanceBaseMin (* ScaleFactor DistanceBase 0.5))
	(setq DistanceRound (* ScaleFactor DistanceBase 0.1))

	(foreach EnameObjectDim ListEnameObjectDim
		(setq DataEnameObjectDim (entget EnameObjectDim))
		(setq Point10 (cdr (assoc 10 DataEnameObjectDim)))
		(setq PointTemp (polar Point10 AngleDim 1000))
		(setq PointPer (ALDIM_PROJECTION_TO_LINE Point0 Point10 PointTemp))
		(if (< (angle Point0 PointPer) Pi)
			(setq CheckPosityDistance 1.0)
			(setq CheckPosityDistance -1.0)
		)

		(setq DistanceLevel (distance Point0 PointPer))
		(setq DistanceLevel (* (ALDIM_ROUNDOFF_NUMBER DistanceLevel DistanceRound) CheckPosityDistance))
		(if (setq Temp (assoc DistanceLevel ListDistance_ListEnameObjectDim))
			(setq ListDistance_ListEnameObjectDim (subst (cons DistanceLevel (cons EnameObjectDim (cdr Temp))) Temp ListDistance_ListEnameObjectDim))
			(setq ListDistance_ListEnameObjectDim (cons (list DistanceLevel EnameObjectDim) ListDistance_ListEnameObjectDim))
		)
	)
	
	(setq ListDistance_ListEnameObjectDim (vl-sort ListDistance_ListEnameObjectDim '(lambda (x y) (< (car x) (car y)))))
	(setq ListDistanceLevel (mapcar 'car ListDistance_ListEnameObjectDim))
	(setq DistanceLevelPre (car ListDistanceLevel))
	(setq ListTemp1 (list DistanceLevelPre))
	(foreach DistanceLevel (cdr ListDistanceLevel)
		(setq DistanceLevelTemp (- DistanceLevel DistanceLevelPre))
		(if (<= DistanceLevelTemp DistanceBaseMin)
			(progn
				(setq ListTemp1 (cons DistanceLevel ListTemp1))
			)
			(progn
				(setq ListTemp2 (cons (reverse ListTemp1) ListTemp2))
				(setq ListTemp1 (list DistanceLevel))
				(if (> DistanceLevelTemp DistanceBaseMax)
					(progn
						(setq ListDistanceLevelGroup (cons (reverse ListTemp2) ListDistanceLevelGroup))
						(setq ListTemp2 Nil)
					)
				)
			)
		)
		(setq DistanceLevelPre DistanceLevel)
	)
	(setq ListTemp2 (cons (reverse ListTemp1) ListTemp2))
	(setq ListDistanceLevelGroup (cons (reverse ListTemp2) ListDistanceLevelGroup))

	(foreach ListTemp2 ListDistanceLevelGroup
		(setq ListTemp Nil)
		(foreach ListTemp1 ListTemp2
			(setq ListTemp (cons (apply 'append (mapcar '(lambda (x) (cdr (assoc x ListDistance_ListEnameObjectDim))) ListTemp1)) ListTemp))
		)
		(setq ListTemp (ALDIM_REVERSE_LEVEL ListTemp))
		(setq ListResult (cons ListTemp ListResult))
	)

	ListResult
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_REVERSE_LEVEL ( ListEnameObjectDimGroup /
	AngleDimPer
	AngleDimPerTemp
	EnameObjectDim1
	EnameObjectDim2
	Point1
	Point2)

	(if (> (length ListEnameObjectDimGroup) 1)
		(progn
			(setq AngleDimPer (ALDIM_GET_ANGLEDIMPERMAIN (apply 'append ListEnameObjectDimGroup)))
			(setq EnameObjectDim1 (car (car ListEnameObjectDimGroup)))
			(setq EnameObjectDim2 (car (last ListEnameObjectDimGroup)))
			(setq Point1 (cdr (assoc 10 (entget EnameObjectDim1))))
			(setq Point2 (cdr (assoc 10 (entget EnameObjectDim2))))
			(setq AngleDimPerTemp (angle Point1 (ALDIM_PROJECTION_TO_LINE Point1 Point2 (polar Point2 (+ AngleDimPer (* Pi 0.5)) 1000))))
			(if (/= (ALDIM_ROUNDOFF_NUMBER AngleDimPerTemp NumRoundAngle) (ALDIM_ROUNDOFF_NUMBER AngleDimPer NumRoundAngle))
				(setq ListEnameObjectDimGroup (reverse ListEnameObjectDimGroup))
			)
		)
	)
	ListEnameObjectDimGroup
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_FIX_DIM_MAIN ( ListEnameObjectDimGroup / 
	AngleDim
	AngleDimPer
	AngleTextPer
    CheckAnnotativeScale
	DataEnameObjectDim
	DistanceBaseEffect
	DistanceText
	DistanceTextEffect
	EnameObjectDim
	ListEnameObjectDimAll
	ListNameAnnotativeScale
	NumLevel
	NumScaleFactor
	PointBase1
	PointBase2
	PointDes1
	PointDes2
	Point10
	Point10New
	Point11
	Point11Per
	Point11PerNew
	Point11New
	Point13
	Point13New
	Point14
	Point14New
	SetSectionObjectDim)

	(setq ListEnameObjectDimAll (apply 'append ListEnameObjectDimGroup))
	(setq ListNameAnnotativeScale (ALDIM_GET_LISTANNOTATIONSCALES ListEnameObjectDimAll))
	(if ListNameAnnotativeScale
		(progn
			(setq SetSectionObjectDim (ssadd))
			(foreach EnameObjectDim ListEnameObjectDimAll
				(ssadd EnameObjectDim SetSectionObjectDim)
			)
			(setq CheckAnnotativeScale T)
			(if (member AnntativeScaleCurrent ListNameAnnotativeScale)
				(setq ListNameAnnotativeScale (cons AnntativeScaleCurrent (vl-remove AnntativeScaleCurrent ListNameAnnotativeScale)))
			)
		)
		(setq ListNameAnnotativeScale (cons AnntativeScaleCurrent ListNameAnnotativeScale))
	)
	(if CheckModelSpace
		(setvar "CANNOSCALE" AnntativeScaleCurrent)
	)
	(setq AngleDimPer (ALDIM_GET_ANGLEDIMPERMAIN (apply 'append ListEnameObjectDimGroup)))
	(setq AngleDim (+ AngleDimPer (/ pi 2)))
	(while (>= AngleDim Pi)
		(setq AngleDim (- AngleDim Pi))
	)

	(setq EnameObjectDim (car (car ListEnameObjectDimGroup)))
	(setq DistanceText (ALDIM_FIND_DISTANCE_TEXT_OF_DIMMENSION EnameObjectDim))

	(if PointBaseGlobal
		(progn
			(setq PointBase1 PointBaseGlobal)
			(setq PointBase2 (polar PointBase1 AngleDim 1000))
		)
		(progn
			(setq DataEnameObjectDim (entget EnameObjectDim))
			(setq Point10 (cdr (assoc 10 DataEnameObjectDim)))
			(setq NumScaleFactor (ALDIM_GET_SCALEFACTOR EnameObjectDim))
			(setq DistanceBaseEffect (* DistanceBaseGlobal NumScaleFactor))
			(setq PointBase1 (polar Point10 (+ AngleDimPer Pi) DistanceBaseEffect))
			(setq PointBase2 (polar PointBase1 AngleDim 1000))
		)
    )

	(foreach NameAnnotativeScale ListNameAnnotativeScale
		(if (and CheckModelSpace CheckAnnotativeScale)
			(progn
				(setvar "CANNOSCALE" NameAnnotativeScale)
				(command "_AIOBJECTSCALEADD" SetSectionObjectDim "")
			)
		)
		(setq NumScaleFactor (ALDIM_GET_SCALEFACTOR EnameObjectDim))
		(setq DistanceBaseEffect (* DistanceBaseGlobal NumScaleFactor))
		(setq DistanceTextEffect (* DistanceText NumScaleFactor 1.02))

		(setq NumLevel 1)
		(foreach ListEnameObjectDim ListEnameObjectDimGroup
			(setq PointDes1 (polar PointBase1 AngleDimPer (* DistanceBaseEffect NumLevel)))
			(setq PointDes2 (polar PointBase2 AngleDimPer (* DistanceBaseEffect NumLevel)))
			(foreach EnameObjectDim ListEnameObjectDim
				(setq DataEnameObjectDim (entget EnameObjectDim))
		
				(setq Point10 (cdr (assoc 10 DataEnameObjectDim)))
				(setq Point10New (ALDIM_PROJECTION_TO_LINE Point10 PointDes1 PointDes2))
				(setq DataEnameObjectDim (subst (cons 10 Point10New) (cons 10 Point10) DataEnameObjectDim))
		
				(setq Point13 (cdr (assoc 13 DataEnameObjectDim)))
				(setq Point13New (ALDIM_PROJECTION_TO_LINE Point13 PointBase1 PointBase2))
				(setq DataEnameObjectDim (subst (cons 13 Point13New) (cons 13 Point13) DataEnameObjectDim))
		
				(setq Point14 (cdr (assoc 14 DataEnameObjectDim)))
				(setq Point14New (ALDIM_PROJECTION_TO_LINE Point14 PointBase1 PointBase2))
				(setq DataEnameObjectDim (subst (cons 14 Point14New) (cons 14 Point14) DataEnameObjectDim))

				(setq Point11 (cdr (assoc 11 DataEnameObjectDim)))
				(setq Point11Per (ALDIM_PROJECTION_TO_LINE Point11 Point10 (polar Point10 AngleDim 1000)))
				(if (ALDIM_EQUAL_TWO_POINT Point11 Point11Per 0.001)
					(setq AngleTextPer AngleDimPer)
					(setq AngleTextPer (angle Point11Per Point11))
				)
				(setq Point11PerNew (ALDIM_PROJECTION_TO_LINE Point11 PointDes1 PointDes2))
				(setq Point11New (polar Point11PerNew AngleTextPer DistanceTextEffect))
				(setq DataEnameObjectDim (subst (cons 11 Point11New) (cons 11 Point11) DataEnameObjectDim))

				(entmod DataEnameObjectDim)
			)
			(setq NumLevel (+ NumLevel 1))
		)
    )
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_ANGLEDIM ( EnameObjectDim /
	AngleDim
	DataEnameObjectDim
	ObjectType
	Point13
	Point14)

	(setq DataEnameObjectDim (entget EnameObjectDim))
	(setq ObjectType (cdr (assoc 100 (reverse DataEnameObjectDim))))
	(if (= ObjectType "AcDbRotatedDimension")
		(progn
			(setq AngleDim (cdr (assoc 50 DataEnameObjectDim)))
		)
	)
	(if (= ObjectType "AcDbAlignedDimension")
		(progn
			(setq Point13 (cdr (assoc 13 DataEnameObjectDim)))
			(setq Point14 (cdr (assoc 14 DataEnameObjectDim)))
			(if (ALDIM_EQUAL_TWO_POINT Point13 Point14 0.001)
				(setq AngleDim 0.0)
				(setq AngleDim (angle Point13 Point14))
			)
		)
	)

	(while (>= (ALDIM_ROUNDOFF_NUMBER (- AngleDim Pi) NumRoundAngle) 0.0) (setq AngleDim (- AngleDim Pi)))
	AngleDim
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_SCALEFACTOR ( EnameObjectDim /
	ListNameAnnotativeScale_ScaleFactor
	ScaleFactor
	VlaObjectDim)

	(setq VlaObjectDim (vlax-ename->vla-object EnameObjectDim))
	(setq ListNameAnnotativeScale_ScaleFactor (ALDIM_GET_ANNOTATIONSCALES VlaObjectDim))
	(setq ScaleFactor (cdr (assoc (getvar "CANNOSCALE") ListNameAnnotativeScale_ScaleFactor)))
	(if (not ScaleFactor)
		(setq ScaleFactor (vla-get-ScaleFactor VlaObjectDim))
	)
	ScaleFactor
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_ANNOTATIONSCALES ( VlaObjectDim / 
	ListTemp
	NameAnnotativeScale
	ScaleFactor
	ListNameAnnotativeScale_ScaleFactor)

	(vl-catch-all-apply (function (lambda ( / )
		(vlax-for VlaAnnotativeScale (vla-item (vla-item (vla-getextensiondictionary VlaObjectDim) "AcDbContextDataManager") "ACDB_ANNOTATIONSCALES")
			(setq ListTemp (entget (cdr (assoc 340 (member (cons 100 "AcDbAnnotScaleObjectContextData") (entget (vlax-vla-object->ename VlaAnnotativeScale)))))))
			(setq NameAnnotativeScale (cdr (assoc 300 ListTemp)))
			(setq ScaleFactor (/ (cdr (assoc 141 ListTemp)) (cdr (assoc 140 ListTemp))))
			(setq ListNameAnnotativeScale_ScaleFactor (cons (cons NameAnnotativeScale ScaleFactor) ListNameAnnotativeScale_ScaleFactor))
		)
	)))
	ListNameAnnotativeScale_ScaleFactor
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_LISTANNOTATIONSCALES ( ListEnameObjectDim /
	ListNameAnnotativeScale
	ListTemp
	ListVlaObjectDim
	NameAnnotativeScale)

	(setq ListVlaObjectDim (mapcar 'vlax-ename->vla-object ListEnameObjectDim))
	(foreach VlaObjectDim ListVlaObjectDim
		(setq ListTemp (mapcar 'car (ALDIM_GET_ANNOTATIONSCALES VlaObjectDim)))
		(foreach NameAnnotativeScale ListTemp
			(if (not (member NameAnnotativeScale ListNameAnnotativeScale))
				(setq ListNameAnnotativeScale (cons NameAnnotativeScale ListNameAnnotativeScale))
			)
		)
	)
	(setq ListNameAnnotativeScale (reverse ListNameAnnotativeScale))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_DISTANCEBASE ( EnameObjectDim /
	DataEnameDimstyle
	DistanceBase
	DistanceBaseMax
	DistanceBaseMin
	HeightText
	NameDimstyle
	VlaDimstyle)

	(setq NameDimstyle (cdr (assoc 3 (entget EnameObjectDim))))
	(setq VlaDimstyle (vla-item VlaDimstylesGroup NameDimstyle))
	(setq DataEnameDimstyle (entget (vlax-vla-object->ename VlaDimstyle)))
	(setq DistanceBase (cdr (assoc 43 DataEnameDimstyle)))
	(if (not DistanceBase) (setq DistanceBase (getvar "DIMDLI")))
	(setq HeightText (cdr (assoc 140 DataEnameDimstyle)))
	(setq DistanceBaseMax (* HeightText 4.0))
	(setq DistanceBaseMin (* HeightText 2.5))
	(if
		(not
			(and
				(<= DistanceBase DistanceBaseMax)
				(>= DistanceBase DistanceBaseMin)
			)
		)
		(setq DistanceBase (* HeightText 3.0))
	)
	DistanceBase
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_TEXTHEIGHT ( EnameObjectDim /
	DataEnameDimstyle
	NameDimstyle
	TextHeight
	VlaDimstyle)

	(setq NameDimstyle (cdr (assoc 3 (entget EnameObjectDim))))
	(setq VlaDimstyle (vla-item VlaDimstylesGroup NameDimstyle))
	(setq DataEnameDimstyle (entget (vlax-vla-object->ename VlaDimstyle)))
	(setq TextHeight (cdr (assoc 140 DataEnameDimstyle)))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_ANGLEDIMPER ( EnameObjectDim /
	DataEnameObjectDim
	Point10
	Point14
	AngleDim
	AngleDimPer)

	(setq DataEnameObjectDim (entget EnameObjectDim))
	(setq Point10 (cdr (assoc 10 DataEnameObjectDim)))
	(setq Point14 (cdr (assoc 14 DataEnameObjectDim)))
	(if (ALDIM_EQUAL_TWO_POINT Point10 Point14 0.001)
		(progn
			(setq AngleDim (ALDIM_GET_ANGLEDIM EnameObjectDim))
			(setq AngleDimPer (+ AngleDim (/ pi 2)))
		)
		(setq AngleDimPer (angle Point14 Point10))
	)
	AngleDimPer
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_GET_ANGLEDIMPERMAIN ( ListEnameObjectDim /
	AngleDimPer
	CheckAcuteAngle
	ListAngleDimPer
	Num)
	
	(setq ListAngleDimPer (mapcar 'ALDIM_GET_ANGLEDIMPER ListEnameObjectDim))
	(setq Num 0)
	(foreach AngleDimPer ListAngleDimPer
		(if (< AngleDimPer Pi)
			(setq Num (+ Num 1))
		)
	)
	(setq CheckAcuteAngle (> Num (/ (length ListAngleDimPer) 2.0)))
	(setq AngleDimPer (car ListAngleDimPer))
	(if CheckAcuteAngle
		(if (>= AngleDimPer Pi)
			(setq AngleDimPer (- AngleDimPer Pi))
		)
		(if (< AngleDimPer Pi)
			(setq AngleDimPer (+ AngleDimPer Pi))
		)
	)
	AngleDimPer
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_RADIANT_TO_DEGREE ( ValueAngle / )
	(* (/ ValueAngle pi) 180)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_ROUNDOFF_NUMBER ( Number ValueRoundOff /
	Temp1
	Temp2
	ValueResult
	NumberActive
	NumSwitchPositveActive)

	(setq NumberActive (abs (* Number 1.0)))
	(if (>= Number 0.0)
		(setq NumSwitchPositveActive 1.0)
		(setq NumSwitchPositveActive -1.0)
	)
	(setq Temp1 (/ NumberActive ValueRoundOff))
	(setq Temp2 (fix Temp1))
	(if (>= (abs (- Temp1 Temp2)) 0.4999999999)
		(setq ValueResult (* ValueRoundOff (+ Temp2 1.0)))
		(setq ValueResult (* ValueRoundOff (+ Temp2 0.0)))
	)
	(setq ValueResult (* NumSwitchPositveActive ValueResult))
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_EQUAL_TWO_POINT (Point1 Point2 RoundOff / )
	(equal
		(mapcar '(lambda (x) (ALDIM_ROUNDOFF_NUMBER x RoundOff)) Point1)
		(mapcar '(lambda (x) (ALDIM_ROUNDOFF_NUMBER x RoundOff)) Point2)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_PROJECTION_TO_LINE ( Point Point1 Point2 / Normal )
	(setq Normal (mapcar '- Point2 Point1)
		Point1 (trans Point1 0 Normal)
		Point (trans Point 0 Normal)
	)
	(trans (list (car Point1) (cadr Point1) (caddr Point)) Normal 0)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_FIND_DISTANCE_BASE_OBJECT ( EnameObjectDim DistanceBase / VlaObjectDim ScaleFactor DistanceBaseObject)
	(setq VlaObjectDim (vlax-ename->vla-object EnameObjectDim))
	(setq ScaleFactor (vla-get-ScaleFactor VlaObjectDim))
	(if
		(= ScaleFactor 0.0)
		(setq ScaleFactor (ALDIM_FIND_LISTANNOTATIVESCALE_FROM_OBJECTDIM VlaObjectDim))
	)
	(setq DistanceBaseObject (* DistanceBase ScaleFactor))
	DistanceBaseObject
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_FIND_DISTANCE_TEXT_OF_DIMMENSION ( EnameObjectDim /
	DistanceText
	TextHeight
	TextGap
	VlaObjectDim)

	(setq VlaObjectDim (vlax-ename->vla-object EnameObjectDim))
	(setq TextHeight (vla-get-TextHeight VlaObjectDim))
	(setq TextGap (vla-get-TextGap VlaObjectDim))
	(setq DistanceText (+ TextGap (/ TextHeight 2)))
	DistanceText
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_CREATE_LISTVLALAYERLOCK ( / VlaLayersGroup)
	(setq VlaLayersGroup (vla-get-layers VlaDrawingCurrent))
	(vlax-for VlaLayer VlaLayersGroup
		(if
			(= (vla-get-Lock VlaLayer) :vlax-true)
			(progn
				(vla-put-Lock VlaLayer :vlax-false)
				(setq ListVlaLayerLock (cons VlaLayer ListVlaLayerLock))
			)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_RESTORE_LOCK_LAYER ( / )
	(foreach VlaLayerLock ListVlaLayerLock
		(vl-catch-all-error-p (vl-catch-all-apply 'vla-put-Lock (list VlaLayerLock :vlax-true)))
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_SET_VARSYSTEM ( / Temp VarSystem)
	(foreach Temp (list (list "CMDECHO" 0) (list "MODEMACRO" "") (list "DIMZIN" 8))
		(setq VarSystem (car Temp))
		(setq ListVarSystem_OldValue (cons (list VarSystem (getvar VarSystem)) ListVarSystem_OldValue))
		(setvar VarSystem (cadr Temp))
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ALDIM_RESET_VARSYSTEM ( / Temp VarSystem)
	(foreach Temp ListVarSystem_OldValue
		(setvar (car Temp) (cadr Temp))
	)
)

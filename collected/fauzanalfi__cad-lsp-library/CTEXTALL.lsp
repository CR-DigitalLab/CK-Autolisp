(vl-load-com)

(defun CTA:SafeCall (fn args / result)
	(setq result (vl-catch-all-apply fn args))
	(if (vl-catch-all-error-p result)
		nil
		result
	)
)

(defun CTA:TryCall (fn args / result)
	(setq result (vl-catch-all-apply fn args))
	(not (vl-catch-all-error-p result))
)

(defun CTA:HasProperty (obj prop)
	(and obj (vlax-property-available-p obj prop))
)

(defun CTA:HasMethod (obj method)
	(and obj (vlax-method-applicable-p obj method))
)

(defun CTA:GetObjectId (vlaObj / idVal)
	(setq idVal (CTA:SafeCall 'vla-get-ObjectID32 (list vlaObj)))
	(if idVal
		idVal
		(CTA:SafeCall 'vla-get-ObjectID (list vlaObj))
	)
)

(defun CTA:GetEnameFromPick (pick)
	(if (and pick (listp pick))
		(car pick)
	)
)

(defun CTA:GetFirstInsertAttributeText (insEname / ent ed txt)
	(setq ent (entnext insEname))
	(while (and ent (null txt))
		(setq ed (entget ent))
		(cond
			((= (cdr (assoc 0 ed)) "SEQEND")
			 (setq ent nil)
			)
			((= (cdr (assoc 0 ed)) "ATTRIB")
			 (setq txt (cdr (assoc 1 ed)))
			)
		)
		(if ent
			(setq ent (entnext ent))
		)
	)
	txt
)

(defun CTA:GetMLeaderBlockAttributeText (mldObj / blkName doc blks blkObj itm oid val)
	(if (CTA:HasProperty mldObj 'ContentBlockName)
		(setq blkName (CTA:SafeCall 'vla-get-ContentBlockName (list mldObj)))
	)
	(if (and (= (type blkName) 'STR) (/= blkName ""))
		(progn
			(setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
			(setq blks (vla-get-Blocks doc))
			(setq blkObj (CTA:SafeCall 'vla-Item (list blks blkName)))
			(if blkObj
				(vlax-for itm blkObj
					(if (and (null val) (= (vla-get-ObjectName itm) "AcDbAttributeDefinition"))
						(progn
							(setq oid (CTA:GetObjectId itm))
							(if (and oid (CTA:HasMethod mldObj 'GetBlockAttributeValue))
								(setq val (CTA:SafeCall 'vla-GetBlockAttributeValue (list mldObj oid)))
							)
						)
					)
				)
			)
		)
	)
	val
)

(defun CTA:GetDxfText (ename / ed et)
	(setq ed (entget ename))
	(setq et (cdr (assoc 0 ed)))
	(cond
		((member et '("TEXT" "ATTRIB" "ATTDEF")) (cdr (assoc 1 ed)))
		((= et "MTEXT") (cdr (assoc 1 ed)))
		((= et "DIMENSION")
			(if (and (assoc 1 ed) (/= (cdr (assoc 1 ed)) "") (/= (cdr (assoc 1 ed)) "<>"))
				(cdr (assoc 1 ed))
			)
		)
		(T nil)
	)
)

(defun CTA:SetDxfText (ename newText / ed et)
	(setq ed (entget ename))
	(setq et (cdr (assoc 0 ed)))
	(cond
		((member et '("TEXT" "MTEXT" "ATTRIB" "ATTDEF" "DIMENSION"))
			(if (assoc 1 ed)
				(setq ed (subst (cons 1 newText) (assoc 1 ed) ed))
				(setq ed (append ed (list (cons 1 newText))))
			)
			(if (entmod ed)
				(progn
					(entupd ename)
					T
				)
			)
		)
		(T nil)
	)
)

(defun CTA:GetMLeaderTextString (mldObj / txt)
	(if (CTA:HasProperty mldObj 'TextString)
		(setq txt (CTA:SafeCall 'vla-get-TextString (list mldObj)))
	)
	(if (and (or (null txt) (= txt "")) (CTA:HasProperty mldObj 'Text))
		(setq txt (CTA:SafeCall 'vla-get-Text (list mldObj)))
	)
	txt
)

(defun CTA:SetMLeaderTextString (mldObj newText)
	(or
		(and (CTA:HasProperty mldObj 'TextString)
			(CTA:TryCall 'vla-put-TextString (list mldObj newText)))
		(and (CTA:HasProperty mldObj 'Text)
			(CTA:TryCall 'vla-put-Text (list mldObj newText)))
	)
)

(defun CTA:GetDimensionText (dimObj / txt)
	(setq txt (CTA:SafeCall 'vla-get-TextOverride (list dimObj)))
	(if (or (null txt) (= txt "") (= txt "<>"))
		(setq txt (rtos (vla-get-Measurement dimObj) (getvar "LUNITS") (getvar "LUPREC")))
	)
	txt
)

(defun CTA:GetTextFromBlockName (blkName visited / btr ent ed et txt nextBlk)
	(if (or (null blkName) (member (strcase blkName) visited))
		nil
		(progn
			(setq btr (tblobjname "BLOCK" blkName))
			(setq ent (and btr (entnext btr)))
			(while (and ent (null txt))
				(setq ed (entget ent))
				(setq et (cdr (assoc 0 ed)))
				(cond
					((= et "ENDBLK")
					 (setq ent nil)
					)
					((= et "INSERT")
					 (setq nextBlk (cdr (assoc 2 ed)))
					 (setq txt (CTA:GetTextFromBlockName nextBlk (cons (strcase blkName) visited)))
					)
					((member et '("TEXT" "MTEXT" "ATTRIB" "ATTDEF" "DIMENSION" "MULTILEADER"))
					 (setq txt (CTA:GetText ent))
					)
				)
				(if ent
					(setq ent (entnext ent))
				)
			)
			txt
		)
	)
)

(defun CTA:GetText (ename / et obj txt)
	(setq et (cdr (assoc 0 (entget ename))))
	(cond
		((member et '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
		 (setq obj (vlax-ename->vla-object ename))
		 (or (CTA:SafeCall 'vla-get-TextString (list obj))
				 (CTA:GetDxfText ename))
		)
		((= et "DIMENSION")
		 (setq obj (vlax-ename->vla-object ename))
		 (or (CTA:GetDimensionText obj)
				 (CTA:GetDxfText ename))
		)
		((= et "MULTILEADER")
		 (setq obj (vlax-ename->vla-object ename))
		 (setq txt (CTA:GetMLeaderTextString obj))
		 (if (or (null txt) (= txt ""))
			 (setq txt (CTA:GetMLeaderBlockAttributeText obj))
		 )
		 txt
		)
		((= et "INSERT")
		 (or (CTA:GetFirstInsertAttributeText ename)
				 (CTA:GetTextFromBlockName (cdr (assoc 2 (entget ename))) nil))
		)
		(T nil)
	)
)

(defun CTA:SetMLeaderBlockAttributes (mldObj newText / blkName doc blks blkObj itm oid changed)
	(if (CTA:HasProperty mldObj 'ContentBlockName)
		(setq blkName (CTA:SafeCall 'vla-get-ContentBlockName (list mldObj)))
	)
	(if (and (= (type blkName) 'STR) (/= blkName ""))
		(progn
			(setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
			(setq blks (vla-get-Blocks doc))
			(setq blkObj (CTA:SafeCall 'vla-Item (list blks blkName)))
			(if blkObj
				(vlax-for itm blkObj
					(if (= (vla-get-ObjectName itm) "AcDbAttributeDefinition")
						(progn
							(setq oid (CTA:GetObjectId itm))
							(if (and oid (CTA:HasMethod mldObj 'SetBlockAttributeValue))
								(if (CTA:TryCall 'vla-SetBlockAttributeValue (list mldObj oid newText))
									(setq changed T)
								)
							)
						)
					)
				)
			)
		)
	)
	changed
)

(defun CTA:SetInsertAttributes (insEname newText / ent ed obj changed)
	(setq ent (entnext insEname))
	(while ent
		(setq ed (entget ent))
		(cond
			((= (cdr (assoc 0 ed)) "SEQEND")
			 (setq ent nil)
			)
			((= (cdr (assoc 0 ed)) "ATTRIB")
			 (setq obj (vlax-ename->vla-object ent))
				 (if (CTA:TryCall 'vla-put-TextString (list obj newText))
				 (setq changed T)
			 )
			)
		)
		(if ent
			(setq ent (entnext ent))
		)
	)
	changed
)

(defun CTA:SetText (ename newText / et obj changed)
	(setq et (cdr (assoc 0 (entget ename))))
	(cond
		((member et '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
		 (setq obj (vlax-ename->vla-object ename))
		 (if (or (CTA:TryCall 'vla-put-TextString (list obj newText))
					 (CTA:SetDxfText ename newText))
			 T
		 )
		)
		((= et "DIMENSION")
		 (setq obj (vlax-ename->vla-object ename))
		 (if (or (CTA:TryCall 'vla-put-TextOverride (list obj newText))
					 (CTA:SetDxfText ename newText))
			 T
		 )
		)
		((= et "MULTILEADER")
		 (setq obj (vlax-ename->vla-object ename))
		 (if (CTA:SetMLeaderTextString obj newText)
			 T
			 (CTA:SetMLeaderBlockAttributes obj newText)
		 )
		)
		((= et "INSERT")
		 (CTA:SetInsertAttributes ename newText)
		)
		(T nil)
	)
)

(defun CTA:UpdatePick (pick / ent path)
	(setq ent (CTA:GetEnameFromPick pick))
	(if ent
		(entupd ent)
	)
	(if (and (listp pick) (> (length pick) 3) (listp (nth 3 pick)))
		(progn
			(setq path (nth 3 pick))
			(foreach e path
				(if e (entupd e))
			)
		)
	)
)

(defun c:CTEXTALL (/ *error* doc oldCmdecho inputText sourceText pick ename changed)
	(setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
	(setq oldCmdecho (getvar "CMDECHO"))

	(defun *error* (msg)
		(setvar "CMDECHO" oldCmdecho)
		(if doc
			(CTA:SafeCall 'vla-EndUndoMark (list doc))
		)
		(if (and msg (/= msg "Function cancelled"))
			(prompt (strcat "\nError: " msg))
		)
		(princ)
	)

	(setvar "CMDECHO" 0)
	(CTA:SafeCall 'vla-StartUndoMark (list doc))

	(setq inputText (getstring T "\nEnter new text: "))

	(if (and inputText (= inputText ""))
		(progn
			(setq sourceText nil)
			(while (null sourceText)
				(setq pick (nentsel "\nPick up source text to copy from: "))
				(cond
					((null pick)
					 (prompt "\nNo source selected.")
					 (setq sourceText :cancel)
					)
					(T
					 (setq ename (CTA:GetEnameFromPick pick))
					 (setq sourceText (and ename (CTA:GetText ename)))
					 (if (null sourceText)
						 (prompt "\nSelected source has no readable text content.")
					 )
					)
				)
			)
			(if (eq sourceText :cancel)
				(setq inputText nil)
				(setq inputText sourceText)
			)
		)
	)

	(if inputText
		(progn
			(setq changed 0)
			(while (setq pick (nentsel "\nPick up text/attribute to change: "))
				(setq ename (CTA:GetEnameFromPick pick))
				(if (and ename (CTA:SetText ename inputText))
					(progn
						(setq changed (1+ changed))
						(CTA:UpdatePick pick)
					)
					(prompt "\nSelected object has no editable text content.")
				)
			)
			(prompt (strcat "\n" (itoa changed) " object(s) updated."))
		)
	)

	(setvar "CMDECHO" oldCmdecho)
	(CTA:SafeCall 'vla-EndUndoMark (list doc))
	(princ)
)

(princ "\nType CTEXTALL to run.")
(princ)

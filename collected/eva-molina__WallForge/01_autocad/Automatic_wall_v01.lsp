;;; ========================================================
;;; FILE:        Automatic_wall_v01.lsp
;;; COMMAND:     c:Wand
;;; DESCRIPTION: Automatic wall plan generation for AutoCAD
;;; AUTHOR:      Eva Rodríguez Molina
;;; CREATED:     2026-04-16
;;; VERSION:     1.0.0
;;; REQUIRES:    AutoCAD 2025+
;;; ========================================================

(vl-load-com)

;;;================================================
;;; 1 INITIALIZATION
;;;================================================
;;; CONTEXT CREATION, FILE LOADING, INITIAL STATE
;;;------------------------------------------------

(defun wall-init (/ ctx doc ms filePath file tbfilePath tbfile)

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq ms  (vla-get-ModelSpace doc))

  (setq filePath   (getfiled "CSV Wände auswählen"   "" "csv" 0))
  (setq file       (open filePath "r"))

  (setq tbfilePath (getfiled "CSV Plankopf auswählen" "" "csv" 0))
  (setq tbfile     (open tbfilePath "r"))

  (setq ctx (list

    ;; ── AutoCAD objects ──────────────────────────
    (cons 'doc        doc)
    (cons 'modelSpace ms)

    ;; ── Input files ──────────────────────────────
    (cons 'dataFile       file)
    (cons 'titleBlockFile tbfile)

    ;; ── Counters / indices ───────────────────────
    (cons 'wallIndex       0)
    (cons 'designplotIndex 0)

    ;; ── Insertion cursor ─────────────────────────
    (cons 'x       0)
    (cons 'y       0)
    (cons 'insertX 0)
    (cons 'insertY 0)

    ;; ── CSV: wall data ────────────────────────────
    (cons 'dataheaders    nil)
    (cons 'currentdataRow nil)

    ;; ── CSV: title block ─────────────────────────
    (cons 'tbheaders  nil)
    (cons 'wallTBRows nil)   ;; row WAND
    (cons 'plotTBRows nil)   ;; row DRUCKLAYOUT

    ;; ── Calculated wall data ─────────────────────
    (cons 'wallData     nil)
    (cons 'parts        nil)
    (cons 'partsGrouped nil)
    (cons 'wallHeight   nil)
    (cons 'wallMeta     nil)

    ;; ── Active block tracking ────────────────────
    (cons 'currentBlock   nil)
    (cons 'insertedBlocks nil)
    (cons 'dlBlocks       nil)
    (cons 'currentDLBlock nil)

    ;; ── Layout / viewport state ──────────────────
    (cons 'currentLayout  nil)
    (cons 'currentVpScale nil)
    (cons 'wallScale      nil)
    (cons 'titleScale     nil)
    (cons 'lastViewport   nil)
    (cons 'lastText       nil)

    ;; ── DL layout registry ───────────────────────
    (cons 'dlLayouts           nil)
    (cons 'designplotMaterials nil)
  ))

  ctx
)


;;;================================================
;;; 2 CONFIGURATION
;;;================================================
;;; STATIC DATA AND SYSTEM CONFIGURATION
;;;------------------------------------------------

;;------------------------------------------------
;; 2.1 Variables
;;------------------------------------------------

(setq fixedBlocks '("BLK_WAND_GR" "BLK_WAND_AN_UK" "BLK_WAND_SC" "BLK_WAND_AN_1"))

(setq lrBlocks '("BLK_WAND_GR" "BLK_WAND_AN_UK"))

(setq dtBlocks '("BLK_WAND_DT_G_V" "BLK_WAND_DT_G_H" "BLK_WAND_DT_K_V" "BLK_WAND_DT_K_H"))

(setq materialDB '(

  (ALUDIBOND
    (MATDB-NAME . "Aluverbundplatte (DIBOND)")
    (MATDB-TYP  . PLATE)
    (MATDB-LENGTH . 3050)
    (MATDB-WIDTH  . 1500)
    (ROTATE . nil)
  )

  (ALULISENE
    (MATDB-NAME . "Alulisene")
    (MATDB-TYP  . PLATE)
    (MATDB-LENGTH . 6000)
    (MATDB-WIDTH  . 50)
    (ROTATE . nil)
  )

  (AUFSATZRAHMEN
    (MATDB-NAME . "Aufsatzrahmen aus Theaterlatte")
    (MATDB-TYP  . PIECE)
    (THICK . 55)
    (ROTATE . nil)
  )

  (GEHWEGPLATTE_300
    (MATDB-NAME . "Beton Gehwegplatte 300")
    (MATDB-TYP  . PIECE)
    (MATDB-LENGTH . 300)
    (MATDB-WIDTH  . 300)
    (ROTATE . T)
  )

  (GEHWEGPLATTE_400
    (MATDB-NAME . "Beton Gehwegplatte 400")
    (MATDB-TYP  . PIECE)
    (MATDB-LENGTH . 400)
    (MATDB-WIDTH  . 400)
    (ROTATE . T)
  )

  (DEKORSPAN_2500
    (MATDB-NAME . "Dekorspan Standard")
    (MATDB-TYP  . PLATE)
    (MATDB-LENGTH . 2500)
    (MATDB-WIDTH  . 1000)
    (ROTATE . T)
  )

  (DEKORSPAN_2800
    (MATDB-NAME . "Dekorspan 2800")
    (MATDB-TYP  . PLATE)
    (MATDB-LENGTH . 2800)
    (MATDB-WIDTH  . 2070)
    (ROTATE . T)
  )

  (ETL_1024
    (MATDB-NAME . "Leiterrahmen, klein")
    (MATDB-TYP  . PIECE)
    (MATDB-LENGTH . 350)
    (MATDB-WIDTH  . 1982)
    (THICK . 55)
    (ROTATE . nil)
  )

  (ETL_1025
    (MATDB-NAME . "Leiterrahmen, groß")
    (MATDB-TYP  . PIECE)
    (MATDB-LENGTH . 500)
    (MATDB-WIDTH  . 3482)
    (THICK . 55)
    (ROTATE . nil)
  )

  (LEITERRAHMEN
    (MATDB-NAME . "Leiterrahmen aus Theaterlatte")
    (MATDB-TYP  . PIECE)
    (THICK . 55)
    (ROTATE . nil)
  )

  (FOREX
    (MATDB-NAME . "Hartschaumplatte (Forex)")
    (MATDB-TYP  . PLATE)
    (MATDB-LENGTH . 3050)
    (MATDB-WIDTH  . 1500)
    (ROTATE . T)
  )

  (THEATERLATTE
    (MATDB-NAME . "Theaterlatte Kiefer natur")
    (MATDB-TYP  . STRIP)
    (MATDB-LENGTH . 35)
    (MATDB-WIDTH  . 6000)
    (THICK . 55)
    (ROTATE . nil)
  )

  (WISA_STR
    (MATDB-NAME . "WISA-Streifen")
    (MATDB-TYP  . STRIP)
    (MATDB-LENGTH . 2050)
    (MATDB-WIDTH  . 100)
    (THICK . 18)
    (ROTATE . T)
  )

  (BLACKBACK
    (MATDB-NAME . "Blackback")
    (MATDB-TYP  . CLADDING)
  )

  (WHITEBACK
    (MATDB-NAME . "Whiteback")
    (MATDB-TYP  . CLADDING)
  )

  (MOLTON
    (MATDB-NAME . "Molton")
    (MATDB-TYP  . CLADDING)
  )

  (SATINMOL
    (MATDB-NAME . "Satinmol")
    (MATDB-TYP  . CLADDING)
  )

  (SATINMOLTON
    (MATDB-NAME . "Satinmolton")
    (MATDB-TYP  . CLADDING)
  )

  (DD_BLACKBACK
    (MATDB-NAME . "Digitaldruck auf Blackback")
    (MATDB-TYP  . CLADDING)
  )

  (DD_WHITEBACK
    (MATDB-NAME . "Digitaldruck auf Whiteback")
    (MATDB-TYP  . CLADDING)
  )

  (DD_DEKOLUX
    (MATDB-NAME . "Digitaldruck auf Dekolux")
    (MATDB-TYP  . CLADDING)
  )
))

(setq vpConfig '(
  ("BLK_WAND_GR"     450 522 460 100)
  ("BLK_WAND_AN_UK"  450 357 460 220)
  ("BLK_WAND_SC"     178 357  84 220)
  ("BLK_WAND_AN_1"   450 132 460 220)
  ("BLK_WAND_AN_2"   178 132  84 220)
  ("BLK_WAND_DT_G_V"  76 357 120 220)
  ("BLK_WAND_DT_G_H"  76 132 120 220)
  ("BLK_WAND_DT_K_V"  76 357 120 220)
  ("BLK_WAND_DT_K_H"  76 132 120 220)
))

(setq textVpConfig       '(768.5 154 135 200))
(setq designplotVpConfig '(215 187 380 190))
(setq dp-text-VpConfig   '(370 62.5 90 59))

;;------------------------------------------------
;; 2.2 Configuration helpers
;;------------------------------------------------

(defun besp-offset (bespID)
  (cond
    ((= bespID 1) 18)
    ((= bespID 2) 35)
    ((= bespID 3) 36)
    ((= bespID 4) 70)
    ((= bespID 5) 53)
    (T 0)
  )
)


;;;================================================
;;; 3 CONTEXT API
;;;================================================
;;; LOW-LEVEL OPERATIONS: CTX MANIPULATION,
;;; AUTOCAD PRIMITIVES, BLOCK/VIEWPORT OPERATIONS
;;;------------------------------------------------

;;------------------------------------------------
;; 3.1 Context manipulation
;;------------------------------------------------

(defun update-ctx (ctx key val)
  (subst (cons key val) (assoc key ctx) ctx)
)

;;------------------------------------------------
;; 3.2 AutoCAD primitives
;;------------------------------------------------

(defun makePoint (x y z)
  (vlax-3d-point (list x y z))
)

(defun ctx-cmd (args / oldEcho)
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (apply 'command args)
  (setvar "CMDECHO" oldEcho)
)

(defun ctx-has-attribute (blk searchedTag)
  (and blk
       (vlax-method-applicable-p blk 'GetAttributes)
       (vl-some
         '(lambda (att)
            (= (strcase (vla-get-tagstring att))
               (strcase searchedTag))
          )
         (vlax-invoke blk 'GetAttributes)
       )
  )
)

(defun set-attr (blk searchedTag value / att tag written)
  (setq written nil)
  (if (and blk (vlax-method-applicable-p blk 'GetAttributes))
    (foreach att (vlax-invoke blk 'GetAttributes)
      (setq tag (strcase (vla-get-TagString att)))
      (if (= tag (strcase searchedTag))
        (progn
          (vla-put-TextString att value)
          (setq written T)
        )
      )
    )
  )
  written
)

(defun setDyn (obj tag val / props p pname)
  (if obj
    (progn
      (setq props (vlax-invoke obj 'GetDynamicBlockProperties))
      (if props
        (foreach p props
          (setq pname (vlax-get p 'PropertyName))
          (if (= (strcase pname) (strcase tag))
            (vl-catch-all-apply
              'vlax-put
              (list p 'Value val)
            )
          )
        )
      )
    )
  )
)

(defun setDynMove (obj paramName value / props p)
  (setq props (vlax-invoke obj 'GetDynamicBlockProperties))
  (if props
    (vl-some
      '(lambda (p)
         (if (= (strcase (vlax-get p 'PropertyName))
                (strcase paramName))
           (progn
             (vlax-put p 'Value value)
             T
           )
         )
       )
      props
    )
  )
)


;;------------------------------------------------
;; 3.3 Block operations
;;------------------------------------------------

(defun ctx-insert-block (ctx name x y z / ms pt obj)

  (setq ms (cdr (assoc 'modelSpace ctx)))

  (if (and name (tblsearch "BLOCK" name))
    (progn
      (setq pt  (makePoint x y z))
      (setq obj (vla-InsertBlock ms pt name 1.0 1.0 1.0 0.0))
    )
    (setq obj nil)
  )

  obj
)

(defun ctx-insert-and-configure (ctx blockName x y / obj)

  (setq obj (ctx-insert-block ctx blockName x y 0))

  (if obj
    (progn
      (ctx-apply-props ctx obj)
      (ctx-apply-dim-visibility ctx obj)
      (ctx-apply-frames obj ctx)
    )
  )

  obj
)

(defun ctx-apply-frames (blk ctx / name txt)

  (setq name (strcase (vla-get-effectivename blk)))

  (if (and
        (member name lrBlocks)
        (ctx-has-attribute blk "LR_NR")
      )
    (progn
      (setq txt (ctx-format-frames-text ctx))
      (set-attr blk "LR_NR" txt)
    )
  )
)

(defun ctx-format-frames-text (ctx / width count dist rest)

  (setq width (distof (getCtxVal ctx "BREITE_UK") 2))

  (if width
    (progn
      (setq count     (+ 1 (fix (/ width 1000.0))))
      (setq dist (- count 1))
      (setq width     (- width 55))
      (setq rest      (- width (* (- dist 1) 1000.0)))

      (strcat
        (itoa (- dist 1))
        " Stk. @ 1000 + Rest "
        (rtos rest 2 0)
        " mm"
      )
    )
    "ERROR_CSV"
  )
)

(defun ctx-apply-dt-materials (ctx / parts blk blkName attrValues)

  (setq parts (cdr (assoc 'parts ctx)))

  (setq attrValues
    (vl-remove nil
      (mapcar
        '(lambda (p)
           (setq name (vl-symbol-name (part-get p 'part)))
           (setq mat (part-get p 'MATDB-NAME))
           (if (and mat (= (type mat) 'STR))
             (cons name mat)
           )
         )
        parts
      )
    )
  )

  (foreach blk (cdr (assoc 'insertedBlocks ctx))
    (setq blkName (strcase (vla-get-effectivename blk)))
    (if (member blkName dtBlocks)
      (setBlockAttributes blk attrValues)
    )
  )

  ctx
)

(defun ctx-apply-dim-visibility (ctx obj /
                                 sbL sbR wisa arH dcD slV)

  (setq sbL (getCtxValParsed ctx "SB_DICKE_L"))
  (setq sbR (getCtxValParsed ctx "SB_DICKE_R"))
  (setq wisa (getCtxValParsed ctx "WISA_OBEN"))
  (setq arH (getCtxValParsed ctx "AR_HOEHE"))
  (setq dcD (getCtxValParsed ctx "DC_DICKE"))
  (setq slV (getCtxValParsed ctx "SL_DICKE_V"))

  ;; 0.0 = base position of block, hidden behind wipeout
  (if (or (not sbL) (= sbL 0)) (setDynMove obj "SB_DIM_L" 0.0))
  (if (or (not sbR) (= sbR 0)) (setDynMove obj "SB_DIM_R" 0.0))
  (if (and (or (not sbL) (= sbL 0))
           (or (not sbR) (= sbR 0)))
                                  (setDynMove obj "SB_DIMS" 0.0))
  (if (or (not wisa) (= wisa 0)) (setDynMove obj "WISA_DIM_OBEN" 0.0))
  (if (or (not arH) (= arH 0)) (setDynMove obj "AR_HOEHE_DIM" 0.0))
  (if (or (not dcD) (= dcD 0)) (setDynMove obj "DC_DIM" 0.0))
  (if (or (not slV) (= slV 0)) (setDynMove obj "SL_DIM_V" 0.0))

  obj
)

(defun ctx-add-inserted-block (ctx obj / allBlocks)

  (setq allBlocks (cdr (assoc 'insertedBlocks ctx)))
  (if (not allBlocks) (setq allBlocks '()))

  (setq allBlocks (cons obj allBlocks))
  (setq ctx (update-ctx ctx 'insertedBlocks allBlocks))
  ctx
)

(defun ctx-find-block (ctx name / blocks x tol)

  (setq blocks (cdr (assoc 'insertedBlocks ctx)))
  (setq x      (cdr (assoc 'x ctx)))
  (setq tol    50000)

  (vl-some
    '(lambda (b / pt)
       (if (= (strcase (vla-get-effectivename b))
              (strcase name))
         (progn
           (setq pt (vlax-safearray->list
                      (vlax-variant-value
                        (vla-get-insertionpoint b)
                      )
                    )
           )
           (if (< (abs (- (car pt) x)) tol)
             b
           )
         )
       )
     )
    blocks
  )
)

;;------------------------------------------------
;; 3.4 Viewport primitives
;;------------------------------------------------

(defun ctx-create-viewport (ctx lay target px py w h / vp)

  (setq ctx (ctx-create-viewport-entity ctx lay px py w h))
  (setq vp  (cdr (assoc 'lastViewport ctx)))

  (setq ctx (ctx-focus-viewport ctx vp target))
  (setq ctx (ctx-compute-viewport-scale ctx target w h))
  (setq ctx (ctx-apply-viewport-scale ctx vp))
  
  

  ctx
)

(defun ctx-create-viewport-entity (ctx lay px py w h / doc ps vp)

  (setq doc (cdr (assoc 'doc ctx)))

  (vla-put-ActiveLayout doc lay)
  (setq ps (vla-get-PaperSpace doc))

  (setq vp
    (vla-AddPViewport
      ps
      (vlax-3d-point (list px py 0))
      w
      h
    )
  )

  (vla-put-Visible    vp :vlax-true)
  (vla-put-ViewportOn vp :vlax-true)
  (vla-put-Layer      vp "Defpoints")

  (setq ctx (update-ctx ctx 'lastViewport vp))

  ctx
)

(defun ctx-focus-viewport (ctx vp target / doc vpEnt ent)

  (setq doc (cdr (assoc 'doc ctx)))

  (setq vpEnt (vlax-vla-object->ename vp))
  (ctx-cmd (list "SELECT" vpEnt ""))
  (ctx-cmd (list "MSPACE"))

  (setq ent (vlax-vla-object->ename target))
  (ctx-cmd (list "ZOOM" "O" ent ""))
  (ctx-cmd (list "ZOOM" "0.9X"))

  ctx
)

(defun ctx-compute-viewport-scale (ctx target w h / blkName wallHeight vsize ratio
                                   width scalePlan scaleElev finalScale vpScale)

  (setq blkName    (strcase (vla-get-effectivename target)))
  (setq wallHeight (cdr (assoc 'wallHeight ctx)))

  ;; default
  (setq vpScale (cdr (assoc 'wallScale ctx)))

  ;; details
  (if (wcmatch blkName "*DT*")
    (setq vpScale "1/2XP")
  )

  ;; main view: compute scale from geometry
  (if (wcmatch blkName "*BLK_WAND_GR*")
    (progn
      (setq vsize (getvar "VIEWSIZE"))
      (setq ratio (/ w h))
      (setq width (* vsize ratio))

      (cond
        ((< width  6000) (setq scalePlan 20))
        ((< width  8000) (setq scalePlan 25))
        ((< width 10000) (setq scalePlan 30))
        ((< width 15000) (setq scalePlan 40))
        ((< width 20000) (setq scalePlan 50))
        (T               (setq scalePlan 100))
      )

      (cond
        ((< wallHeight 3000) (setq scaleElev 20))
        ((< wallHeight 4000) (setq scaleElev 25))
        ((< wallHeight 5100) (setq scaleElev 30))
        ((< wallHeight 6000) (setq scaleElev 40))
        (T                   (setq scaleElev 100))
      )

      (setq finalScale (max scalePlan scaleElev))
      (setq vpScale    (strcat "1/" (itoa finalScale) "XP"))

      (setq ctx (update-ctx ctx 'wallScale vpScale))
      (setq ctx (update-ctx
                  ctx
                  'titleScale
                  (vl-string-subst ":" "/" (vl-string-right-trim "XP" vpScale))
                )
      )
    )
  )

  (setq ctx (update-ctx ctx 'currentVpScale vpScale))
  ctx
)

(defun ctx-apply-viewport-scale (ctx vp / scale annoScale vpEnt)

  (setq scale (cdr (assoc 'currentVpScale ctx)))
  (setq vpEnt (vlax-vla-object->ename vp))

  (ctx-cmd (list "SELECT" vpEnt ""))
  (ctx-cmd (list "MSPACE"))
  (ctx-cmd (list "ZOOM" scale))

  (setq annoScale (vl-string-subst ":" "/" scale))
  (setq annoScale (vl-string-right-trim "XP" annoScale))
  (setvar "CANNOSCALE" annoScale)

  (ctx-cmd (list "PSPACE"))
  (vla-put-DisplayLocked vp :vlax-true)

  ctx
)

(defun ctx-apply-annotative-scale (ctx / scale blk att en blkName doc)

  (setq scale (cdr (assoc 'titleScale ctx)))
  (setq doc (cdr (assoc 'doc ctx)))

  (if (not scale)
    ctx

    (progn
      (vla-put-ActiveSpace doc 1)

      (foreach blk (cdr (assoc 'insertedBlocks ctx))
        (setq blkName (strcase (vla-get-effectivename blk)))
        (if (member blkName lrBlocks)
          (foreach att (vlax-invoke blk 'GetAttributes)
            (if (= (strcase (vla-get-tagstring att)) "LR_NR")
              (progn
                (setq en (vlax-vla-object->ename att))
                (ctx-cmd (list "_OBJECTSCALE" en "" "A" scale ""))
              )
            )
          )
        )
      )

      ctx
    )
  )
)


;;;================================================
;;; 4 DATA ACCESS (CSV / INPUT)
;;;================================================
;;; READING AND PARSING EXTERNAL DATA
;;;------------------------------------------------

(defun split (str sep / pos lst)
  (while (setq pos (vl-string-search sep str))
    (setq lst (cons (substr str 1 pos) lst))
    (setq str (substr str (+ pos (strlen sep) 1)))
  )
  (reverse (cons str lst))
)

(defun parse-value (v / num)
  (cond
    ((or (null v) (= v "")) nil)
    ((setq num (distof v 2)) num)
    (T v)
  )
)

(defun getCtxVal (ctx tag / headers row idx val)

  (setq headers (cdr (assoc 'dataheaders    ctx)))
  (setq row     (cdr (assoc 'currentdataRow ctx)))

  (if (or (not headers) (not row))
    nil
  )

  (setq idx (vl-position
              (strcase tag)
              (mapcar 'strcase headers)
            )
  )

  (if (not idx)
    nil
    (progn
      (setq val (nth idx row))
      (setq val (vl-string-trim " " val))
      (if (= val "") nil val)
    )
  )
)

(defun getCtxVal! (ctx tag / val)
  (setq val (getCtxVal ctx tag))
  (if (not val)
    (prompt (strcat "\nFehlender Wert für: " tag))
  )
  val
)

(defun getCtxValParsed (ctx tag)
  (parse-value (getCtxVal ctx tag))
)

(defun wall-read-titleblock (ctx / tbfile tbHeaders tbLine tbValues tbRow planType
                             wallTbRows plotTbRows)

  (setq tbfile (cdr (assoc 'titleBlockFile ctx)))

  (setq tbHeaders (split (read-line tbfile) ";"))

  (setq wallTbRows '())
  (setq plotTbRows '())

  (while (setq tbLine (read-line tbfile))

    (setq tbValues (split tbLine ";"))

    (setq tbRow (mapcar
                  '(lambda (tag val)
                     (cons (strcase tag) val)
                   )
                  tbHeaders
                  tbValues
                )
    )

    (setq planType (if (assoc "PLAN_TYP" tbRow)
                     (strcase (vl-string-trim " " (cdr (assoc "PLAN_TYP" tbRow))))
                     ""
                   )
    )

    (cond
      ((= planType "WAND")
       (setq wallTbRows (cons tbRow wallTbRows))
      )
      ((= planType "DRUCKLAYOUT")
       (setq plotTbRows (cons tbRow plotTbRows))
      )
    )
  )

  (setq ctx (update-ctx ctx 'wallTBRows  (reverse wallTbRows)))
  (setq ctx (update-ctx ctx 'plotTBRows  (reverse plotTbRows)))
  (setq ctx (update-ctx ctx 'tbHeaders   tbHeaders))

  ctx
)


;;;================================================
;;; 5 PROCESSING PIPELINE
;;;================================================
;;; HIGH-LEVEL ORCHESTRATION ONLY (NO LOGIC)
;;;------------------------------------------------

(defun wall-process-all (ctx / dataFile dataline currentdataRow)

  (setq dataFile (cdr (assoc 'dataFile ctx)))

  (if (not dataFile)
    (progn
      (prompt "\nFehler: CSV-Datei nicht gefunden.")
      (exit)
    )
  )

  ;; read headers
  (setq ctx (update-ctx
              ctx
              'dataheaders
              (split (read-line dataFile) ";")
            )
  )

  ;; iterate rows
  (while (setq dataline (read-line dataFile))

    (setq currentdataRow (split dataline ";"))
    (setq ctx (update-ctx ctx 'currentdataRow currentdataRow))

    (setq ctx (wall-process-row ctx))

    (setq ctx (update-ctx ctx 'x (+ (cdr (assoc 'x ctx)) 70000)))
    (setq ctx (update-ctx ctx 'y 0))

    (setq ctx (update-ctx
                ctx
                'wallIndex
                (1+ (cdr (assoc 'wallIndex ctx)))
              )
    )
  )

  ctx
)

(defun ctx-reset-wall (ctx)
  (setq ctx (update-ctx ctx 'dlBlocks      nil))
  (setq ctx (update-ctx ctx 'insertedBlocks nil))
  (setq ctx (update-ctx ctx 'currentBlock  nil))
  (setq ctx (update-ctx ctx 'lastViewport  nil))
  ctx
)

(defun wall-process-row (ctx)

  (setq ctx (ctx-reset-wall ctx))

  (setq ctx (update-ctx
              ctx
              'wallHeight
              (getCtxValParsed ctx "WAND_HOEHE")
            )
  )

  (setq ctx (wall-insert-blocks ctx))
  (setq ctx (wall-materials ctx))
  (setq ctx (ctx-apply-dt-materials ctx))
  (setq ctx (wall-create-text ctx))
  (setq ctx (wall-create-layouts ctx))
  (setq ctx (drucklayout-create-layouts ctx))
  (setq ctx (ctx-apply-annotative-scale ctx))
  
  ctx
)


;;;================================================
;;; 6 DOMAIN LOGIC (CORE BUSINESS)
;;;================================================
;;; PURE LOGIC — NO AUTOCAD CALLS
;;;------------------------------------------------

;;------------------------------------------------
;; 6.1 Data construction
;;------------------------------------------------

(defun ctx-build-wall-data (ctx / headers wall val)

  (setq headers (cdr (assoc 'dataheaders ctx)))

  (setq wall (vl-remove nil
                        (mapcar
                          '(lambda (tag)
                             (setq val (getCtxValParsed ctx tag))
                             (if val
                               (cons (read (strcase tag)) val)
                             )
                           )
                          headers
                        )
             )
  )

  ;; normalize: float → int where applicable
  (setq wall (mapcar
               '(lambda (p)
                  (if (numberp (cdr p))
                    (cons (car p) (fix (cdr p)))
                    p
                  )
                )
               wall
             )
  )

  (setq ctx (update-ctx ctx 'wallData wall))
  ctx
)

;;------------------------------------------------
;; 6.2 Material computation
;;------------------------------------------------

(defun wall-materials (ctx / wallData parts partsGrouped)

  (setq ctx      (ctx-build-wall-data ctx))
  (setq wallData (cdr (assoc 'wallData ctx)))

  (setq parts (calc-wall-materials wallData))
  (setq parts (mapcar 'piece-add-material-info parts))
  (setq parts (apply 'append (mapcar 'split-piece-if-needed parts)))

  (setq partsGrouped (group-pieces parts))

  (setq ctx (update-ctx ctx 'parts        parts))
  (setq ctx (update-ctx ctx 'partsGrouped partsGrouped))

  ctx
)

(defun calc-wall-materials (wall)
  (vl-remove nil
             (list
               (calc-ladder-frame   wall)
               (calc-top-frame      wall)
               (calc-wisa-strips    wall)
               (calc-base-plates    wall)
               (calc-wood-slats     wall)
               (calc-cladding-front wall)
               (calc-cladding-back  wall)
               (calc-side-panel-left  wall)
               (calc-side-panel-right wall)
               (calc-top-panel      wall)
               (calc-baseboard-front wall)
               (calc-baseboard-back  wall)
             )
  )
)

;;------------------------------------------------
;; 6.3 Component calculations
;;------------------------------------------------

(defun calc-ladder-frame (wall / material depth height count)
  (setq material (w wall 'UK_ID))
  (setq depth    (w wall 'TIEFE_UK))
  (setq height   (w wall 'HOEHE_UK))
  (setq count    (calc-number-of-frames wall))
  (make-part 'LADDER_FRAME material count depth height)
)

(defun calc-top-frame (wall / depth height count)
  (setq depth  (w wall 'TIEFE_UK))
  (setq height (w wall 'AR_HOEHE))
  (setq count  (calc-number-of-frames wall))
  (make-part 'TOP_FRAME 'AUFSATZRAHMEN count depth height)
)

(defun calc-wisa-strips (wall / width height arHeight bespID dc_vh H L count)

  (setq width    (w wall 'BREITE_UK))
  (setq height   (w wall 'HOEHE_UK))
  (setq arHeight (w wall 'AR_HOEHE))
  (setq bespID   (w wall 'BESP_ID))
  (setq dc_vh    (w wall 'DC_VH))

  (setq H (- (+ height arHeight) 200))

  (setq L (cond
             ((= bespID 1) (+ (* 3 width) (* 2 H)))
             ((= bespID 2) (+ (* (if (= dc_vh 1) 3 2) width) (* 2 H)))
             ((= bespID 3) (+ (* 6 width) (* 4 H)))
             ((= bespID 4) (+ (* (if (= dc_vh 1) 6 4) width) (* 4 H)))
             ((= bespID 5) (+ (* 6 width) (* 4 H)))
             (T 0)
           )
  )

  (setq count (fix (1+ (/ (- L 1) 2500.0))))

  (make-part 'WISA_STRIP 'WISA_STR count nil nil)
)

(defun calc-base-plates (wall / depth count material)

  (setq depth (w wall 'TIEFE_UK))
  (setq count (* 2 (calc-number-of-frames wall)))

  (setq material (if (<= depth 350)
                   'GEHWEGPLATTE_300
                   'GEHWEGPLATTE_400
                 )
  )

  (make-part 'BASE_PLATE material count nil nil)
)

(defun calc-wood-slats (wall / width count)
  (setq width (w wall 'BREITE_UK))
  (setq count (1+ (fix (/ (- width 1) 6000.0))))
  (make-part 'WOOD_SLAT 'THEATERLATTE count nil nil)
)

(defun calc-cladding-front (wall / width height thick claddingid dimX dimY material)

  (setq width      (w wall 'BREITE_UK))
  (setq height     (w wall 'WAND_HOEHE))
  (setq thick      (w wall 'DC_DICKE))
  (setq claddingid (w wall 'BESP_ID))
  (setq material   (w wall 'BESP_MAT_V))

  (cond
    ((member claddingid '(1 3 5))
     (setq dimX (+ width 300)
           dimY (+ (- height thick) 250)
     )
    )
    ((member claddingid '(2 4))
     (setq dimX (+ width 40)
           dimY (+ (- height thick) 40)
     )
    )
  )

  (make-part 'CLADDING_FRONT material 1 dimX dimY)
)

(defun calc-cladding-back (wall / width height claddingid thick dimX dimY material)

  (setq width      (w wall 'BREITE_UK))
  (setq height     (w wall 'WAND_HOEHE))
  (setq thick      (w wall 'DC_DICKE))
  (setq claddingid (w wall 'BESP_ID))
  (setq material   (w wall 'BESP_MAT_H))

  (cond
    ((member claddingid '(3))
     (setq dimX (+ width 300)
           dimY (+ (- height thick) 250)
     )
    )
    ((member claddingid '(4 5))
     (setq dimX (+ width 40)
           dimY (+ (- height thick) 40)
     )
    )
  )

  (if dimX (make-part 'CLADDING_BACK material 1 dimX dimY))
)

(defun calc-side-panel-left  (wall) (calc-side-panel wall 'LEFT))
(defun calc-side-panel-right (wall) (calc-side-panel wall 'RIGHT))

(defun calc-top-panel (wall / dc_vh bespID depth width thickL thickR dimX dimY)

  (setq dc_vh  (w wall 'DC_VH))
  (setq bespID (w wall 'BESP_ID))
  (setq depth  (w wall 'TIEFE_UK))
  (setq width  (w wall 'BREITE_UK))
  (setq thickL (w wall 'SB_DICKE_L))
  (setq thickR (w wall 'SB_DICKE_R))

  (if (= dc_vh 1)
    (progn
      (setq dimX (+ width thickL thickR))
      (setq dimY (+ depth (besp-offset bespID)))

      (append
        (make-part 'TOP_PANEL (w wall 'DC_MAT) 1 dimX dimY)
        (list
          (cons 'color (w wall 'DC_FARBE))
          (cons 'thick (w wall 'DC_DICKE))
        )
      )
    )
  )
)

(defun calc-baseboard-front (wall) (calc-baseboard wall 'FRONT))
(defun calc-baseboard-back  (wall) (calc-baseboard wall 'BACK))

;;------------------------------------------------
;; 6.4 Calculation helpers
;;------------------------------------------------

(defun w (wall key / val)
  (setq val (cdr (assoc key wall)))
  (if (null val)
    (princ (strcat "\n[ERROR] Missing key: " (vl-symbol-name key)))
  )
  val
)

(defun make-part (name material count dimX dimY / result)

  (setq result (list
                 (cons 'part  name)
                 (cons 'count count)
               )
  )

  (if material (setq result (cons (cons 'material material) result)))
  (if dimX     (setq result (cons (cons 'dimX dimX) result)))
  (if dimY     (setq result (cons (cons 'dimY dimY) result)))

  result
)

(defun calc-number-of-frames (wall)
  (+ 1 (fix (/ (w wall 'BREITE_UK) 1000.0)))
)

(defun calc-side-panel (wall side / sbId dims material color thick partName validIds)

  (setq sbId (w wall 'SB_ID))

  (cond
    ((eq side 'LEFT)
     (setq validIds '(1 3))
     (setq material (w wall 'SB_L_MAT))
     (setq color    (w wall 'SB_L_FARBE))
     (setq thick    (w wall 'SB_DICKE_L))
     (setq partName 'SIDE_PANEL_LEFT)
    )
    ((eq side 'RIGHT)
     (setq validIds '(2 3))
     (setq material (w wall 'SB_R_MAT))
     (setq color    (w wall 'SB_R_FARBE))
     (setq thick    (w wall 'SB_DICKE_R))
     (setq partName 'SIDE_PANEL_RIGHT)
    )
  )

  (if (member sbId validIds)
    (progn
      (setq dims (calc-side-panel-dimensions wall))
      (append
        (make-part partName material 1 (car dims) (cadr dims))
        (list
          (cons 'color color)
          (cons 'thick thick)
        )
      )
    )
  )
)

(defun calc-side-panel-dimensions (wall / depth height dcThick bespID offset dimX dimY)

  (setq depth   (w wall 'TIEFE_UK))
  (setq height  (w wall 'WAND_HOEHE))
  (setq dcThick (w wall 'DC_DICKE))
  (setq bespID  (w wall 'BESP_ID))

  (setq dimY   (- height dcThick))
  (setq offset (besp-offset bespID))
  (setq dimX   (+ depth offset))

  (list dimX dimY)
)

(defun calc-baseboard (wall side / thick width thickL thickR dimX material color partName)

  (setq width  (w wall 'BREITE_UK))
  (setq thickL (w wall 'SB_DICKE_L))
  (setq thickR (w wall 'SB_DICKE_R))

  (cond
    ((eq side 'FRONT)
     (setq thick    (w wall 'SL_DICKE_V))
     (setq material (w wall 'SL_V_MAT))
     (setq color    (w wall 'SL_V_FARBE))
     (setq partName 'BASEBOARD_FRONT)
    )
    ((eq side 'BACK)
     (setq thick    (w wall 'SL_DICKE_H))
     (setq material (w wall 'SL_H_MAT))
     (setq color    (w wall 'SL_H_FARBE))
     (setq partName 'BASEBOARD_BACK)
    )
  )

  (setq dimX (+ width thickL thickR))

  (if (/= thick 0)
    (append
      (make-part partName material 1 dimX 50)
      (list
        (cons 'color color)
        (cons 'thick thick)
      )
    )
  )
)


;;;================================================
;;; 7 MATERIAL SYSTEM
;;;================================================
;;; MATERIAL LOOKUP AND ENRICHMENT
;;;------------------------------------------------

(defun mat-get (piece / matname)
  (setq matname (cdr (assoc 'material piece)))
  (cond
    ((null matname)           nil)
    ((= (type matname) 'STR) (read (strcase matname)))
    ((= (type matname) 'SYM) matname)
    (T nil)
  )
)

(defun material-lookup (matKey / entry)
  (setq entry (assoc matKey materialDB))
  (if entry (cdr entry) nil)
)

(defun piece-add-material-info (piece / matKey matData)
  (setq matKey  (mat-get piece))
  (setq matData (material-lookup matKey))
  (if matData
    (append piece matData)
    piece
  )
)


;;;================================================
;;; 8 GEOMETRY PROCESSING
;;;================================================
;;; SPLITTING AND GROUPING OF PARTS
;;;------------------------------------------------

(defun split-piece-if-needed (piece / part px py mx my canRotate bestPiece bx by)

  (setq part (cdr (assoc 'part piece)))

  (if (not (member part '(SIDE_PANEL_LEFT SIDE_PANEL_RIGHT TOP_PANEL
                          BASEBOARD_FRONT BASEBOARD_BACK)))
    (list piece)

    (progn
      (setq px       (cdr (assoc 'dimX piece)))
      (setq py       (cdr (assoc 'dimY piece)))
      (setq mx       (cdr (assoc 'MATDB-LENGTH piece)))
      (setq my       (cdr (assoc 'MATDB-WIDTH  piece)))
      (setq canRotate (cdr (assoc 'ROTATE piece)))

      (if (or (not px) (not py) (not mx) (not my))
        (list piece)

        (progn
          (setq bestPiece (choose-best-orientation piece px py mx my canRotate))
          (setq bx (cdr (assoc 'dimX bestPiece)))
          (setq by (cdr (assoc 'dimY bestPiece)))

          (if (piece-fits bx by mx my)
            (list bestPiece)
            (piece-split-2d bestPiece mx my)
          )
        )
      )
    )
  )
)

(defun piece-split-x (piece px maxX / n remainder result)

  (if (or (not (numberp px)) (not (numberp maxX)) (<= maxX 0))
    (list piece)

    (progn
      (setq n         (fix (/ px maxX)))
      (setq remainder (- px (* n maxX)))
      (setq result    '())

      (repeat n
        (setq result (cons
                       (subst (cons 'dimX maxX) (assoc 'dimX piece) piece)
                       result
                     )
        )
      )

      (if (> remainder 0)
        (setq result (cons
                       (subst (cons 'dimX remainder) (assoc 'dimX piece) piece)
                       result
                     )
        )
      )

      (reverse result)
    )
  )
)

(defun piece-split-y (piece py maxY / n remainder result)

  (if (or (not (numberp py)) (not (numberp maxY)) (<= maxY 0))
    (list piece)

    (progn
      (setq n         (fix (/ py maxY)))
      (setq remainder (- py (* n maxY)))
      (setq result    '())

      (repeat n
        (setq result (cons
                       (subst (cons 'dimY maxY) (assoc 'dimY piece) piece)
                       result
                     )
        )
      )

      (if (> remainder 0)
        (setq result (cons
                       (subst (cons 'dimY remainder) (assoc 'dimY piece) piece)
                       result
                     )
        )
      )

      (reverse result)
    )
  )
)

(defun piece-split-2d (piece mx my / xParts finalParts)

  (setq xParts (piece-split-x piece (cdr (assoc 'dimX piece)) mx))

  (setq finalParts '())

  (foreach p xParts
    (setq finalParts (append finalParts
                             (piece-split-y p (cdr (assoc 'dimY p)) my)
                     )
    )
  )

  finalParts
)

(defun piece-rotate (piece / dimX dimY)

  (setq dimX (cdr (assoc 'dimX piece)))
  (setq dimY (cdr (assoc 'dimY piece)))

  (if (and dimX dimY)
    (mapcar
      '(lambda (p)
         (cond
           ((eq (car p) 'dimX) (cons 'dimX dimY))
           ((eq (car p) 'dimY) (cons 'dimY dimX))
           (T p)
         )
       )
      piece
    )
    piece
  )
)

(defun piece-fits (px py mx my)
  (and (<= px mx) (<= py my))
)

(defun choose-best-orientation (piece px py mx my canRotate / countNormal countRotated)

  (setq countNormal  (estimate-piece-count px py mx my))
  (setq countRotated (if canRotate (estimate-piece-count py px mx my) nil))

  (cond
    ((not canRotate) piece)
    ((and countRotated (< countRotated countNormal)) (piece-rotate piece))
    (T piece)
  )
)

(defun estimate-piece-count (px py mx my / nx ny)
  (setq nx (int-ceil px mx))
  (setq ny (int-ceil py my))
  (* nx ny)
)

(defun int-ceil (a b)
  (fix (1+ (/ (- a 1) b)))
)

(defun group-pieces (pieces / result key existing dx dy canRotate normX normY)

  (setq result '())

  (foreach piece pieces

    (setq dx        (cdr (assoc 'dimX   piece)))
    (setq dy        (cdr (assoc 'dimY   piece)))
    (setq canRotate (cdr (assoc 'ROTATE piece)))

    (if (and canRotate dx dy (> dy dx))
      (progn (setq normX dy) (setq normY dx))
      (progn (setq normX dx) (setq normY dy))
    )

    (setq piece (subst (cons 'dimX normX) (assoc 'dimX piece) piece))
    (setq piece (subst (cons 'dimY normY) (assoc 'dimY piece) piece))

    (setq key (list
                (cdr (assoc 'material piece))
                (cdr (assoc 'color    piece))
                (cdr (assoc 'thick    piece))
                normX
                normY
              )
    )

    (setq existing (vl-some
                     '(lambda (p)
                        (if (equal (cdr (assoc 'key p)) key) p)
                      )
                     result
                   )
    )

    (if existing
      (setq result (subst
                     (subst
                       (cons 'count (+ (cdr (assoc 'count existing)) 1))
                       (assoc 'count existing)
                       existing
                     )
                     existing
                     result
                   )
      )
      (setq result (cons
                     (append piece (list (cons 'count 1) (cons 'key key)))
                     result
                   )
      )
    )
  )

  (reverse
    (mapcar
      '(lambda (p) (vl-remove (assoc 'key p) p))
      result
    )
  )
)


;;;================================================
;;; 9 DRAWING GENERATION
;;;================================================
;;; TRANSLATE DATA → AUTOCAD GEOMETRY
;;;------------------------------------------------

;;------------------------------------------------
;; 9.1 Block insertion
;;------------------------------------------------

(defun wall-insert-blocks (ctx)
  (setq ctx (wall-insert-fixed-blocks ctx))
  (setq ctx (wall-insert-sideView ctx))
  (setq ctx (wall-insert-dependent-blocks ctx))
  ctx
)

(defun wall-insert-fixed-blocks (ctx)
  (setq ctx (wall-start-insert ctx))
  (foreach b fixedBlocks
    (setq ctx (wall-insert-one-block ctx b))
  )
  ctx
)

(defun wall-insert-sideView (ctx / blockName x y obj)

  (setq blockName (wall-get-side-block ctx))

  (if blockName
    (progn
      (setq x (cdr (assoc 'x ctx)))
      (setq y (cdr (assoc 'insertY ctx)))

      (setq obj (ctx-insert-and-configure ctx blockName x y))

      (setq ctx (update-ctx ctx 'currentBlock obj))
      (setq ctx (ctx-add-inserted-block ctx obj))

      (setq ctx (update-ctx ctx 'insertY (+ y 10000)))
    )
  )

  ctx
)

(defun wall-insert-dependent-blocks (ctx / blocks)
  (setq blocks (wall-get-dependent-blocks ctx))
  (foreach block blocks
    (setq ctx (wall-insert-one-block ctx block))
  )
  ctx
)

(defun wall-insert-one-block (ctx blockName / x y obj dlList)

  (setq x (cdr (assoc 'x ctx)))
  (setq y (cdr (assoc 'insertY ctx)))

  (setq obj (ctx-insert-and-configure ctx blockName x y))

  (setq ctx (update-ctx ctx 'currentBlock obj))

  ;; register in insertedBlocks
  (if obj
    (setq ctx (ctx-add-inserted-block ctx obj))
  )

  ;; track DL blocks separately
  (if (and obj (wall-is-dl-block blockName))
    (progn
      (setq dlList (cdr (assoc 'dlBlocks ctx)))
      (if (not dlList) (setq dlList '()))
      (setq dlList (cons obj dlList))
      (setq ctx (update-ctx ctx 'dlBlocks dlList))
    )
  )

  (setq ctx (update-ctx ctx 'insertY (+ y 10000)))

  ctx
)

(defun wall-start-insert (ctx)
  (setq ctx (update-ctx ctx 'insertY (cdr (assoc 'y ctx))))
)

;;------------------------------------------------
;; 9.2 Block selection logic
;;------------------------------------------------

(defun wall-get-side-block (ctx / side)
  (setq side (atoi (getCtxVal ctx "SB_ID")))
  (cond
    ((member side '(1 2 3)) "BLK_WAND_AN_2")
    (T nil)
  )
)

(defun valid-mat (v)
  (and
    (= (type v) 'STR)
    (wcmatch (strcase v) "DD_*")
  )
)

(defun wall-get-dependent-blocks (ctx / besp matV matH)

  (setq besp (fix (getCtxValParsed ctx "BESP_ID")))
  (setq matV (getCtxVal ctx "BESP_MAT_V"))
  (setq matH (getCtxVal ctx "BESP_MAT_H"))

  (cond
    ;; 1 Einseitig getackert
    ((= besp 1)
     (append
       '("BLK_WAND_DT_G_V")
       (if (valid-mat matV) '("BLK_WAND_DL_G_V"))
     )
    )
    ;; 2 Einseitig Kederrahmen
    ((= besp 2)
     (append
       '("BLK_WAND_DT_K_V")
       (if (valid-mat matV) '("BLK_WAND_DL_K_V"))
     )
    )
    ;; 3 Beidseitig getackert
    ((= besp 3)
     (append
       '("BLK_WAND_DT_G_V" "BLK_WAND_DT_G_H")
       (if (valid-mat matV) '("BLK_WAND_DL_G_V"))
       (if (valid-mat matH) '("BLK_WAND_DL_G_H"))
     )
    )
    ;; 4 Beidseitig Kederrahmen
    ((= besp 4)
     (append
       '("BLK_WAND_DT_K_V" "BLK_WAND_DT_K_H")
       (if (valid-mat matV) '("BLK_WAND_DL_K_V"))
       (if (valid-mat matH) '("BLK_WAND_DL_K_H"))
     )
    )
    ;; 5 Gemischt
    ((= besp 5)
     (append
       '("BLK_WAND_DT_G_V" "BLK_WAND_DT_K_H")
       (if (valid-mat matV) '("BLK_WAND_DL_G_V"))
       (if (valid-mat matH) '("BLK_WAND_DL_K_H"))
     )
    )
    (T nil)
  )
)

(defun wall-is-dl-block (blockName)
  (wcmatch blockName "*DL*")
)

;;------------------------------------------------
;; 9.3 Block property application
;;------------------------------------------------

(defun ctx-apply-props (ctx obj / headers tag val mapped num)

  (foreach tag (cdr (assoc 'dataheaders ctx))

    (setq val (getCtxVal ctx tag))

    (if val
      (progn
        (setq mapped (mapCsvValue tag val))

        (cond
          (mapped
           (setDyn obj (car mapped) (cadr mapped))
          )
          ((= (strcase tag) "BESP_ID")
           (setDyn obj tag val)
          )
          (T
           (setq num (parse-value val))
           (if (numberp num)
             (setDyn obj tag num)
             (setDyn obj tag val)
           )
          )
        )
      )
    )
  )

  obj
)

(defun mapCsvValue (tag val)
  (cond
    ((= (strcase tag) "DC_VH")
     (cond
       ((= val "0") (list "DC_VH" 0.0))
       ((= val "1") (list "DC_VH" 18.0))
       (T nil)
     )
    )
    ((= (strcase tag) "SL_DICKE_V")
     (if (= val "0")
       (list "SL_DICKE_V1" 0.0)
     )
    )
    (T nil)
  )
)


;;;================================================
;;; 10 TEXT GENERATION
;;;================================================
;;; GENERATE ANNOTATIONS (MTEXT)
;;;------------------------------------------------

(defun wall-create-text (ctx / text insPt)

  (setq text  (text-build-full ctx))
  (setq insPt (list (cdr (assoc 'x ctx)) -5000 0))

  (setq ctx (ctx-insert-text ctx insPt text))

  ctx
)

(defun ctx-insert-text (ctx pt text / ms obj)

  (setq ms (cdr (assoc 'modelSpace ctx)))

  (setq obj (vla-addmtext
              ms
              (vlax-3d-point pt)
              3000
              text
            )
  )

  (vla-put-height obj 2)
  (vla-put-StyleName obj "Standard")

  (setq ctx (update-ctx ctx 'lastText obj))

  ctx
)

(defun text-build-full (ctx / parts partsGrouped wall header materials desc dims)

  (setq parts        (cdr (assoc 'parts        ctx)))
  (setq partsGrouped (cdr (assoc 'partsGrouped ctx)))
  (setq wall         (cdr (assoc 'wallData     ctx)))

  (setq ctx (ctx-extract-wall-meta ctx))

  (setq header    (text-build-header ctx))
  (setq materials (text-build-materials partsGrouped))
  (setq desc      (text-build-description parts))
  (setq dims      (text-build-dimensions wall))

  (if (not materials) (setq materials ""))
  (if (not desc)      (setq desc ""))
  (if (not dims)      (setq dims ""))

  (strcat header
          "\\LMaterial:\\l\\b \\P\\P"    materials "\\P\\P"
          "\\LBeschreibung:\\l\\b \\P\\P" desc      "\\P\\P"
          "\\LMaße:\\l\\b \\P\\P"         dims      "\\P\\P"
          "\\LStückzahl:\\l\\b \\P\\P1"
  )
)

(defun text-build-header (ctx / meta pos title)

  (setq meta  (cdr (assoc 'wallMeta ctx)))
  (setq pos   (cdr (assoc 'position meta)))
  (setq title (cdr (assoc 'title    meta)))

  (if (not pos)   (setq pos ""))
  (if (not title) (setq title ""))

  (strcat "\\B" "POS. " pos " - " title "\\b" "\\P\\P\\P")
)

(defun text-build-materials (parts)
  (apply 'strcat
         (mapcar
           '(lambda (p) (strcat (piece->text p) "\\P"))
           parts
         )
  )
)

(defun text-build-description (parts / front back left right top baseF baseB)

  (foreach p parts
    (cond
      ((eq (part-get p 'part) 'CLADDING_FRONT)  (setq front (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'CLADDING_BACK)   (setq back  (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'SIDE_PANEL_LEFT)  (setq left  (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'SIDE_PANEL_RIGHT) (setq right (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'TOP_PANEL)        (setq top   (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'BASEBOARD_FRONT)  (setq baseF (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'BASEBOARD_BACK)   (setq baseB (part-get p 'MATDB-NAME)))
    )
  )

  (strcat
    "Wandkonstruktion mit Unterkonstruktion aus Leiterrahmen,\\P"
    "Theaterlatten zur Aussteifung,\\P"
    "Gehwegplatten zur Ballastierung,\\P"
    "WISA-Streifen als UK für Beplankung,\\P"
    (if (and front (= (type front) 'STR)) (strcat "Wand vorne vollflächig mit " front " bespannt,\\P") "")
    (if (and back  (= (type back)  'STR)) (strcat "Wand hinten vollflächig mit " back  " bespannt,\\P") "")
    (if (and left  (= (type left)  'STR)) (strcat left  " als Seitenblenden links,\\P")  "")
    (if (and right (= (type right) 'STR)) (strcat right " als Seitenblenden rechts,\\P") "")
    (if (and baseF (= (type baseF) 'STR)) (strcat baseF " als Sockelleiste vorne,\\P")   "")
    (if (and baseB (= (type baseB) 'STR)) (strcat baseB " als Sockelleiste hinten,\\P")  "")
    (if (and top   (= (type top)   'STR)) (strcat top   " als Deckel,\\P") "")
  )
)

(defun text-build-dimensions (wall / dims)

  (setq dims (wall-get-dimensions wall))

  (strcat
    "B " (rtos (car   dims) 2 0)
    " x T " (rtos (cadr  dims) 2 0)
    " x H " (rtos (caddr dims) 2 0)
    " mm."
  )
)

(defun wall-get-dimensions (wall / width depth height bespID thickL thickR offset
                            dimX dimY dimZ)

  (setq width  (w wall 'BREITE_UK))
  (setq depth  (w wall 'TIEFE_UK))
  (setq height (w wall 'WAND_HOEHE))
  (setq bespID (w wall 'BESP_ID))
  (setq thickL (w wall 'SB_DICKE_L))
  (setq thickR (w wall 'SB_DICKE_R))
  (setq offset (besp-offset bespID))

  (setq dimX (+ width thickL thickR))
  (setq dimY (+ depth offset))
  (setq dimZ height)

  (list dimX dimY dimZ)
)

(defun ctx-extract-wall-meta (ctx / rows idx row)

  (setq rows (cdr (assoc 'wallTBRows ctx)))
  (setq idx  (cdr (assoc 'wallIndex  ctx)))

  (if (not (numberp idx)) (setq idx 0))
  (if (not rows)          (setq rows '()))
  (if (>= idx (length rows)) (setq idx 0))

  (setq row (nth idx rows))

  (setq ctx (update-ctx
              ctx
              'wallMeta
              (list
                (cons 'position (cdr (assoc "POSITION_NR" row)))
                (cons 'title    (cdr (assoc "PLAN_TITEL"  row)))
              )
            )
  )
  ctx
)

;;------------------------------------------------
;; 10.1 Piece formatting helpers
;;------------------------------------------------

(defun piece->text (p / count name dimStr extras)

  (setq count (if (numberp (cdr (assoc 'count p)))
                (cdr (assoc 'count p))
              )
  )

  (setq name   (piece-get-material-name p))
  (setq dimStr (piece-format-dimensions p))
  (setq extras (piece-format-extras p))

  (strcat
    (itoa count)
    " Stk. "
    (if name name "UNKNOWN")
    ", "
    (if (and extras (= (type extras) 'STR)) extras "")
    (if dimStr dimStr "")
  )
)

(defun piece-get-material-name (p / name mat)

  (setq name (part-get p 'MATDB-NAME))

  (cond
    ((and name (= (type name) 'STR)) name)
    ((setq mat (part-get p 'material))
     (cond
       ((= (type mat) 'SYM) (vl-symbol-name mat))
       ((= (type mat) 'STR) mat)
       (T "UNKNOWN")
     )
    )
    (T "UNKNOWN")
  )
)

(defun piece-format-dimensions (p)
  (cond
    ((and (numberp (part-get p 'dimX)) (numberp (part-get p 'dimY)))
     (strcat "B " (rtos (part-get p 'dimX) 2 0)
             " x H " (rtos (part-get p 'dimY) 2 0) " mm")
    )
    ((and (numberp (part-get p 'MATDB-LENGTH)) (numberp (part-get p 'MATDB-WIDTH)))
     (strcat "B " (rtos (part-get p 'MATDB-LENGTH) 2 0)
             " x H " (rtos (part-get p 'MATDB-WIDTH) 2 0) " mm")
    )
  )
)

(defun piece-format-extras (p / items)

  (setq items (vl-remove nil
                         (list
                           (if (and (part-get p 'color) (= (type (part-get p 'color)) 'STR))
                             (part-get p 'color)
                           )
                           (if (numberp (part-get p 'thick))
                             (strcat "T " (rtos (part-get p 'thick) 2 0) " x")
                           )
                         )
              )
  )

  (if (not items)
    nil
    (strcat " " (piece-join-with-separator items ", ") " ")
  )
)

(defun piece-join-with-separator (lst sep / result)
  (if lst
    (progn
      (setq result (car lst))
      (foreach item (cdr lst)
        (setq result (strcat result sep item))
      )
      result
    )
  )
)

(defun part-get (p key)
  (cdr (assoc key p))
)


;;;================================================
;;; 11 LAYOUT MANAGEMENT
;;;================================================
;;; PAPER SPACE, LAYOUTS, VIEWPORTS, TITLEBLOCKS
;;;------------------------------------------------

;;------------------------------------------------
;; 11.1 WAND layouts
;;------------------------------------------------

(defun wall-create-layouts (ctx)
  (setq ctx (create-layout ctx))
  (setq ctx (create-viewports ctx))
  (setq ctx (wall-create-text-viewport ctx))
  (setq ctx (wall-fill-titleblock ctx))
  ctx
)

(defun create-layout (ctx / doc wallIndex layoutName lay pos)

  (setq doc       (cdr (assoc 'doc       ctx)))
  (setq wallIndex (cdr (assoc 'wallIndex ctx)))

  (setq layoutName (strcat "WAND_"
                           (substr (strcat "000" (itoa (1+ wallIndex)))
                                   (- (strlen (strcat "000" (itoa (1+ wallIndex)))) 2)
                           )
                   )
  )

  (ctx-cmd (list "-layout" "copy" "A1" layoutName))

  (setq pos (vla-get-count (vla-get-layouts doc)))
  (ctx-cmd (list "-layout" "move" layoutName pos))

  (setq lay (vla-item (vla-get-Layouts doc) layoutName))
  (vla-put-ActiveLayout doc lay)

  (setq ctx (update-ctx ctx 'currentLayout lay))

  ctx
)

(defun create-viewports (ctx / lay)

  (setq lay (cdr (assoc 'currentLayout ctx)))

  (if (not lay)
    (progn
      (prompt "\n[ERROR] No layout in ctx")
      ctx
    )
  )

  (setq ctx (create-viewports-from-blocks ctx))

  ctx
)

(defun create-viewports-from-blocks (ctx / lay cfg blk px py w h target)

  (setq lay (cdr (assoc 'currentLayout ctx)))

  (foreach cfg vpConfig
    (if (= (length cfg) 5)
      (progn
        (setq blk (nth 0 cfg))
        (setq px  (nth 1 cfg))
        (setq py  (nth 2 cfg))
        (setq w   (nth 3 cfg))
        (setq h   (nth 4 cfg))

        (setq target (ctx-find-block ctx blk))

        (if target
          (setq ctx (ctx-create-viewport ctx lay target px py w h))
        )
      )
    )
  )

  ctx
)

(defun wall-create-text-viewport (ctx / txtObj)
  (setq txtObj (cdr (assoc 'lastText ctx)))
  (if txtObj
    (setq ctx (ctx-create-text-viewport ctx))
  )
  ctx
)

(defun ctx-create-text-viewport (ctx / txtObj lay cfg px py w h vp)

  (setq txtObj (cdr (assoc 'lastText       ctx)))
  (setq lay    (cdr (assoc 'currentLayout  ctx)))
  (setq cfg    textVpConfig)

  (if (or (not txtObj) (not lay) (not cfg))
    ctx

    (progn
      (setq px (nth 0 cfg))
      (setq py (nth 1 cfg))
      (setq w  (nth 2 cfg))
      (setq h  (nth 3 cfg))

      (setq ctx (ctx-create-viewport-entity ctx lay px py w h))
      (setq vp  (cdr (assoc 'lastViewport ctx)))

      (setq ctx (ctx-focus-scale-text-viewport ctx vp))

      ctx
    )
  )
)

(defun ctx-focus-scale-text-viewport (ctx vp / en txtObj)

  (setq txtObj (cdr (assoc 'lastText ctx)))

  (if (not txtObj)
    ctx
    (progn
      (setq en (vlax-vla-object->ename txtObj))

      (sssetfirst nil (ssadd en))
      (ctx-cmd (list "MSPACE"))
      (ctx-cmd (list "ZOOM" "OBJECT" en ""))
      (ctx-cmd (list "ZOOM" "1/1XP"))
      (ctx-cmd (list "PSPACE"))

      (vla-put-DisplayLocked vp :vlax-true)

      ctx
    )
  )
)

(defun wall-fill-titleblock (ctx / lay titleBlock rows idx attrValues titleScale)

  (setq lay  (cdr (assoc 'currentLayout ctx)))
  (setq rows (cdr (assoc 'wallTBRows    ctx)))
  (setq idx  (cdr (assoc 'wallIndex     ctx)))

  (if (not lay)
    (progn (prompt "\n[ERROR] No layout") ctx)

    (progn
      (if (or (not rows) (>= idx (length rows)))
        (setq idx 0)
      )

      (setq titleBlock (findBlockInLayout lay "BLK_LAYOUT_A1"))

      (if (not titleBlock)
        (prompt "\n[ERROR] Titleblock not found")
      )

      (setq attrValues (nth idx rows))

      (if (and titleBlock attrValues)
        (setBlockAttributes titleBlock attrValues)
      )

      (setq titleScale (cdr (assoc 'titleScale ctx)))
      (if (not titleScale) (setq titleScale "oM"))

      (if titleBlock
        (foreach att (vlax-invoke titleBlock 'GetAttributes)
          (if (= (strcase (vla-get-tagstring att)) "MASSSTAB")
            (vla-put-textstring att titleScale)
          )
        )
      )

      ctx
    )
  )
)

;;------------------------------------------------
;; 11.2 Layout utilities
;;------------------------------------------------

(defun findBlockInLayout (lay blkName / btr obj res)
  (setq btr (vla-get-block lay))
  (vlax-for obj btr
    (if (and
          (= (vla-get-objectname obj) "AcDbBlockReference")
          (= (strcase (vla-get-effectivename obj)) (strcase blkName))
        )
      (setq res obj)
    )
  )
  res
)

(defun setBlockAttributes (blk attrList / att tag)
  (foreach att (vlax-invoke blk 'GetAttributes)
    (setq tag (strcase (vla-get-tagstring att)))
    (if (assoc tag attrList)
      (vla-put-textstring att (cdr (assoc tag attrList)))
    )
  )
)

;;------------------------------------------------
;; 11.3 Drucklayout (DL) layouts
;;------------------------------------------------

(defun drucklayout-create-layouts (ctx / dlBlocks)

  (setq dlBlocks (cdr (assoc 'dlBlocks ctx)))

  (if (not dlBlocks)
    ctx

    (progn
      (setq dlBlocks (reverse dlBlocks))

      (foreach blkObj dlBlocks

        (setq ctx (update-ctx ctx 'currentDLBlock blkObj))

        (setq ctx (dl-create-text ctx blkObj))
        (setq ctx (dl-create-layout ctx blkObj))
        (setq ctx (dl-create-viewports ctx blkObj))
        (setq ctx (dl-create-text-viewport ctx))
        (setq ctx (dl-fill-titleblock ctx))

        (setq ctx (update-ctx
                    ctx
                    'designplotIndex
                    (1+ (cdr (assoc 'designplotIndex ctx)))
                  )
        )
      )
    )
  )

  ctx
)

(defun dl-create-text (ctx blkObj / text insPt insx idx blkName)

  (setq insx    (cdr (assoc 'x ctx)))
  (setq idx     (cdr (assoc 'designplotIndex ctx)))
  (setq blkName (strcase (vla-get-effectivename blkObj)))

  (setq text  (designplot-text-build-full ctx blkName))
  (setq insPt (list insx (- -10000 (* idx 500)) 0))

  (setq ctx (ctx-insert-text ctx insPt text))

  ctx
)

(defun designplot-text-build-full (ctx blk / drucklayoutData pos titel parts material
                                   header dims vX vY cX cY idx rows)

  ;; safe index access
  (setq rows (cdr (assoc 'plotTBRows      ctx)))
  (setq idx  (cdr (assoc 'designplotIndex ctx)))

  (if (or (not rows) (not (numberp idx)) (>= idx (length rows)))
    (setq idx 0)
  )

  (setq drucklayoutData (if rows (nth idx rows) nil))

  (setq pos   (if drucklayoutData (cdr (assoc "POSITION_NR" drucklayoutData)) ""))
  (setq titel (if drucklayoutData (cdr (assoc "PLAN_TITEL"  drucklayoutData)) ""))
  (if (not pos)   (setq pos ""))
  (if (not titel) (setq titel ""))

  (setq parts (cdr (assoc 'parts ctx)))
  (setq dims  (designplot-text-build-dimensions ctx blk))
  (setq vX    (nth 0 dims))
  (setq vY    (nth 1 dims))
  (setq cX    (nth 2 dims))
  (setq cY    (nth 3 dims))

  (setq material (car (dl-get-materials parts)))
  (if (not material) (setq material "UNKNOWN"))

  (setq header (strcat "\\BPOS. " pos " - " titel "\\B\\P\\P"))

  (strcat
    header
    "\\L\\BMaterial:\\l\\b \\P"
    material
    (if (wcmatch blk "*_K_*") ", umlaufend Gummilippe" "")
    "\\P\\P"
    "\\L\\BSichtbarer Bereich:\\l\\b \\P"
    (rtos vX 2 0) " x " (rtos vY 2 0) " mm"
    "\\P"
    "umlaufend auslaufend!"
    "\\P\\P"
    "\\L\\Banzulegende Druckfläche:\\l\\b\\P"
    (rtos cX 2 0) " x " (rtos cY 2 0) " mm"
    "\\P\\P"
    "\\L\\BStückzahl:\\l\\b \\P"
    "1"
  )
)

(defun dl-get-materials (parts / front back)
  
  (setq front nil  back nil)
  (foreach p parts
    (cond
      ((eq (part-get p 'part) 'CLADDING_FRONT) (setq front (part-get p 'MATDB-NAME)))
      ((eq (part-get p 'part) 'CLADDING_BACK)  (setq back  (part-get p 'MATDB-NAME)))
    )
  )
  (list front back)
)

(defun designplot-text-build-dimensions (ctx blk / wall dl vX vY cX cY)

  (setq wall (cdr (assoc 'wallData ctx)))
  (setq dl   (dl-get-dimensions wall blk))

  (if (or (not dl) (< (length dl) 2))
    (setq dl '(0 0))
  )

  (setq vX (car  dl))
  (setq vY (cadr dl))

  (cond
    ((and blk (wcmatch blk "*_G_*"))
     (setq cX (+ vX 300))
     (setq cY (+ vY 250))
    )
    ((and blk (wcmatch blk "*_K_*"))
     (setq cX (+ vX 40))
     (setq cY (+ vY 40))
    )
    (T
     (setq cX vX)
     (setq cY vY)
    )
  )

  (list vX vY cX cY)
)

(defun dl-get-dimensions (wall blk / width height thickT dimX dimY)

  (setq width (w wall 'BREITE_UK))
  (setq height (w wall 'WAND_HOEHE))
  (setq thickT (w wall 'DC_DICKE))

  (setq dimX width)
  (setq dimY (- height thickT))

  ;; Kederrahmen blocks have a 20mm offset at the base
  (if (and blk (wcmatch blk "*_K_*"))
    (setq dimY (- dimY 20))
  )

  (list dimX dimY)
)


(defun dl-create-layout (ctx blkObj / doc idx layoutName lay pos blkName)

  (setq doc     (cdr (assoc 'doc ctx)))
  (setq idx     (cdr (assoc 'designplotIndex ctx)))
  (setq blkName (strcase (vla-get-effectivename blkObj)))

  (setq layoutName
    (strcat "DL_"
            (substr (strcat "000" (itoa (1+ idx)))
                    (- (strlen (strcat "000" (itoa (1+ idx)))) 2))
    )
  )

  (ctx-cmd (list "-layout" "copy" "A3" layoutName))

  (setq pos (vla-get-count (vla-get-layouts doc)))
  (ctx-cmd (list "-layout" "move" layoutName pos))

  (setq lay (vla-item (vla-get-Layouts doc) layoutName))
  (vla-put-ActiveLayout doc lay)

  (setq ctx (update-ctx ctx 'currentLayout lay))
  (setq ctx (ctx-add-dl-layout ctx lay))

  ctx
)

(defun dl-create-viewports (ctx blkObj / lay cfg px py w h)

  (setq lay (cdr (assoc 'currentLayout ctx)))
  (setq cfg designplotVpConfig)

  (if (and lay cfg blkObj)
    (progn
      (setq px (nth 0 cfg))
      (setq py (nth 1 cfg))
      (setq w  (nth 2 cfg))
      (setq h  (nth 3 cfg))

      (setq ctx (ctx-create-viewport ctx lay blkObj px py w h))
    )
  )

  ctx
)

(defun dl-create-text-viewport (ctx / txtObj lay cfg px py w h vp)

  (setq txtObj (cdr (assoc 'lastText      ctx)))
  (setq lay    (cdr (assoc 'currentLayout ctx)))
  (setq cfg    dp-text-VpConfig)

  (if (or (not txtObj) (not lay) (not cfg))
    ctx

    (progn
      (setq px (nth 0 cfg))
      (setq py (nth 1 cfg))
      (setq w  (nth 2 cfg))
      (setq h  (nth 3 cfg))

      (setq ctx (ctx-create-viewport-entity ctx lay px py w h))
      (setq vp  (cdr (assoc 'lastViewport ctx)))  

      (setq ctx (ctx-focus-scale-text-viewport ctx vp))

      ctx
    )
  )
)

(defun dl-fill-titleblock (ctx / lay rows idx titleBlock attrValues titleScale)

  (setq lay  (cdr (assoc 'currentLayout  ctx)))
  (setq rows (cdr (assoc 'plotTBRows     ctx)))
  (setq idx  (cdr (assoc 'designplotIndex ctx)))

  (if (and lay rows)
    (progn
      (if (>= idx (length rows))
        (setq idx 0)
      )

      (setq titleBlock  (findBlockInLayout lay "BLK_LAYOUT_A3"))
      (setq attrValues  (nth idx rows))

      (if (and titleBlock attrValues)
        (setBlockAttributes titleBlock attrValues)
      )

      (setq titleScale (cdr (assoc 'titleScale ctx)))
      (if (not titleScale) (setq titleScale "oM"))

      (if titleBlock
        (foreach att (vlax-invoke titleBlock 'GetAttributes)
          (if (= (strcase (vla-get-tagstring att)) "MASSSTAB")
            (vla-put-textstring att titleScale)
          )
        )
      )
    )
  )

  ctx
)

(defun ctx-add-dl-layout (ctx lay / lst)
  (setq lst (cdr (assoc 'dlLayouts ctx)))
  (if (not lst) (setq lst '()))
  (setq ctx (update-ctx ctx 'dlLayouts (cons lay lst)))
)


;;;================================================
;;; 12 PDF EXPORT
;;;================================================
;;; EXPORTS EACH LAYOUT AS AN INDIVIDUAL PDF
;;; USING PUBLISH + DSD FILE.
;;;------------------------------------------------

;;------------------------------------------------
;; 12.1 Orchestrator
;;------------------------------------------------

(defun wall-export-pdfs (ctx / layouts dsdPath)

  ;; collect layouts to export (excludes A1, A3, Model)
  (setq layouts (pdf-get-layouts ctx))

  (if (not layouts)
    (prompt "\n[PDF] Es wurden keine Layouts zum Exportieren gefunden.")

    (progn
      ;; build and run
      (setq dsdPath (pdf-build-dsd-path))
      (pdf-write-dsd layouts dsdPath)
      (pdf-publish-dsd dsdPath)
      (pdf-cleanup-dsd dsdPath)

    )
  )

  ctx
)

;;------------------------------------------------
;; 12.2 Layout collection
;;------------------------------------------------

(defun pdf-get-layouts (ctx / doc layouts lst)

  (setq doc (cdr (assoc 'doc ctx)))
  (setq layouts (vla-get-Layouts doc))

  (vlax-for lay layouts
    (if (/= (strcase (vla-get-Name lay)) "MODEL")
      (setq lst
        (cons
          (list (vla-get-TabOrder lay) (vla-get-Name lay))
          lst
        )
      )
    )
  )

  (setq lst (vl-sort lst '(lambda (a b) (< (car a) (car b)))))
  (setq lst (mapcar 'cadr lst))
  (setq lst
    (vl-remove-if
      '(lambda (x) (member x '("A1" "A3")))
      lst
    )
  )

  (mapcar
    '(lambda (layName)
       (cons layName (pdf-build-pdf-name ctx layName))
     )
    lst
  )
)

;;------------------------------------------------
;; 12.2.1 PDF filename construction
;;------------------------------------------------

(defun pdf-build-pdf-name (ctx layName / rows row datum pos titel projekt idx)

  ;; select the right row list and parse index from layout name
  (cond
    ((wcmatch (strcase layName) "WAND_*")
     (setq rows (cdr (assoc 'wallTBRows ctx)))
     (setq idx (pdf-layout-index layName "WAND_"))
    )
    ((wcmatch (strcase layName) "DL_*")
     (setq rows (cdr (assoc 'plotTBRows ctx)))
     (setq idx (pdf-layout-index layName "DL_"))
    )
    (T
     (setq rows nil)
     (setq idx 0)
    )
  )

  ;; clamp index
  (if (or (not rows) (not (numberp idx)) (>= idx (length rows)))
    (setq idx 0)
  )

  (setq row (nth idx rows))

  ;; extract fields, fallback to empty string if missing
  (setq datum (pdf-reformat-date (pdf-safe-field row "DATUM_PLAN")))
  (setq pos (pdf-safe-field row "POSITION_NR"))
  (setq titel (pdf-safe-field row "PLAN_TITEL"))
  (setq projekt (pdf-safe-field row "PROJEKT_NR"))

  ;; build and sanitize filename
  (pdf-sanitize-filename
    (strcat datum "_Pos. " pos "_" titel "_" projekt)
  )
)

(defun pdf-layout-index (layName prefix / numStr)
  ;; extract the trailing zero-padded number and convert to 0-based index
  (setq numStr (substr layName (1+ (strlen prefix))))
  (if (and numStr (/= numStr ""))
    (1- (atoi numStr))
    0
  )
)

(defun pdf-safe-field (row fieldName / val)
  (setq val (cdr (assoc fieldName row)))
  (if (and val (/= (vl-string-trim " " val) ""))
    (vl-string-trim " " val)
    ""
  )
)

(defun pdf-sanitize-filename (name / result)
  ;; replace characters not allowed in Windows filenames
  (setq result name)
  (foreach pair '(("/" . "-") ("\\" . "-") (":" . "-")
                  ("*" . "-") ("?" . "-") ("\"" . "")
                  ("<" . "") (">" . "") ("|" . "-"))
    (setq result (vl-string-subst (cdr pair) (car pair) result))
  )
  ;; collapse multiple spaces or dashes
  result
)

(defun pdf-reformat-date (datum / parts)
  (setq parts (split datum "."))
  
  (if (= (length parts) 3)
    (progn
      (strcat
        (substr (nth 2 parts) 3)
        (nth 1 parts)
        (nth 0 parts)
      )
    )
    datum
  )
)

;;------------------------------------------------
;; 12.3 DSD file construction
;;------------------------------------------------

(defun pdf-build-dsd-path ( / dwgPath)
  (setq dwgPath (getvar "DWGPREFIX"))
  (strcat dwgPath "~wand_export_temp.dsd")
)

(defun pdf-build-output-path ( / dwgPath)
  (setq dwgPath (getvar "DWGPREFIX"))
  (strcat dwgPath "*.pdf")
)

(defun pdf-write-dsd (layouts dsdPath / dwgPath dwgName dwgFullPath f lay outPath)

  (setq dwgPath (getvar "DWGPREFIX"))
  (setq dwgName (getvar "DWGNAME"))
  (setq dwgFullPath (strcat dwgPath dwgName))

  (setq f (open dsdPath "w"))

  (if (not f)
    (progn
      (prompt (strcat "\n[PDF] ERROR: cannot write DSD file: " dsdPath))
      (exit)
    )
  )

  (setq outPath (pdf-build-output-path))

  ;; DSD header
  (write-line "[DWF6Version]"                     f)
  (write-line "Ver=1"                             f)
  (write-line "[DWF6MinorVersion]"                f)
  (write-line "MinorVer=1"                        f)

  ;; one section per layout
  (foreach lay layouts

    (setq layName (car lay))
    (setq pdfName (cdr lay))

    (write-line (strcat "[DWF6Sheet:" pdfName "]")        f)
    (write-line (strcat "DWG=" dwgFullPath)               f)
    (write-line (strcat "Layout=" layName)                f)
    (write-line "Setup="                                  f)
    (write-line (strcat "OriginalSheetPath=" dwgFullPath) f)
    (write-line "Has Plot Port=0"                         f)
    (write-line "Has3DDWF=0"                              f)
    
  )
  
  ; DSD file Properties Bottom
  (write-line "[Target]"                          f)
  (write-line "Type=5"                            f)
  (write-line (strcat "DWF=" outPath)             f)
  (write-line (strcat "OUT=" dwgPath )            f)
  (write-line "PWD="                              f)
  (write-line "MRU Local]"                        f)
  (write-line "MRU=2"                             f)
  (write-line (strcat "File0=" dwgPath)           f)
  (write-line (strcat "File1=" dwgPath)           f)
  (write-line "[MRU Sheet List]"                  f)
  (write-line "MRU=1"                             f)
  (write-line (strcat "File0=" dsdPath)           f)
  (write-line "[PdfOptions]"                      f)
  (write-line "IncludeHyperlinks=TRUE"            f)
  (write-line "CreateBookmarks=TRUE"              f)
  (write-line "CaptureFontsInDrawing=TRUE"        f)
  (write-line "ConvertTextToGeometry=FALSE"       f)
  (write-line "VectorResolution=1200"             f)
  (write-line "RasterResolution=400"              f)
  (write-line "[AutoCAD Block Data]"              f)
  (write-line "IncludeBlockInfo=0"                f)
  (write-line "BlockTmplFilePath="                f)
  (write-line "[SheetSet Properties]"             f)
  (write-line "IsSheetSet=FALSE"                  f)
  (write-line "IsHomogeneous=FALSE"               f)
  (write-line "SheetSet Name="                    f)
  (write-line "NoOfCopies=1"                      f)
  (write-line "PlotStampOn=FALSE"                 f)
  (write-line "ViewFile=FALSE"                    f)
  (write-line "JobID=0"                           f)
  (write-line "SelectionSetName="                 f)
  (write-line "AcadProfile=<<Unnamed Profile>>"   f)
  (write-line "CategoryName="                     f)
  (write-line "LogFilePath="                      f)
  (write-line "IncludeLayer=TRUE"                 f)
  (write-line "LineMerge=FALSE"                   f)
  (write-line "CurrentPrecision="                 f)
  (write-line "PromptForDwfName=FALSE"            f)
  (write-line "PwdProtectPublishedDWF=FALSE"      f)
  (write-line "PromptForPwd=FALSE"                f)
  (write-line "RepublishingMarkups=FALSE"         f)
  (write-line "PublishSheetSetMetadata=FALSE"     f)
  (write-line "PublishSheetMetadata=FALSE"        f)
  (write-line "3DDWFOptions=0 "                   f)  
  (write-line ""                                  f)

  (close f)
)

;;------------------------------------------------
;; 12.4 Publish execution
;;------------------------------------------------

(defun pdf-publish-dsd (dsdPath / oldBg)

  ;; BACKGROUNDPLOT=0: publish synchronously so the
  ;; script waits for completion before continuing.
  ;; Without this, AutoCAD would publish in the background
  ;; and the DSD file could be deleted too early.
  (setq oldBg (getvar "BACKGROUNDPLOT"))
  (setvar "BACKGROUNDPLOT" 0)
  
  (prompt "\n[PDF] Bitte wählen Sie eine DSD-Datei aus:")

  (ctx-cmd (list "_.-PUBLISH"))
  
  (setvar "BACKGROUNDPLOT" oldBg)
)

;;------------------------------------------------
;; 12.5 Cleanup
;;------------------------------------------------

(defun pdf-cleanup-dsd (dsdPath)
  (if (findfile dsdPath)
    (vl-file-delete dsdPath)
  )
)


;;;================================================
;;; 13 ENTRY POINT
;;;================================================
;;; USER COMMAND
;;;------------------------------------------------

(defun c:WAND (/ ctx)

  (setq ctx (wall-init))
  (setq ctx (wall-read-titleblock ctx))
  (setq ctx (wall-process-all ctx))  
  (setq ctx (wall-export-pdfs ctx))

  (if (cdr (assoc 'dataFile ctx))
    (close (cdr (assoc 'dataFile ctx)))
  )

  (if (cdr (assoc 'titleBlockFile ctx))
    (close (cdr (assoc 'titleBlockFile ctx)))
  )

  (princ)
)

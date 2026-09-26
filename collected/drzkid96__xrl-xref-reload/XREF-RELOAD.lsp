;;; ===========================================================
;;;   X R L  —  Xref Reload Tool for AutoCAD
;;;   Version 2.7  |  Author: Adrian Ayala
;;;
;;;   Commands:
;;;     XRL        — Reload xrefs (current config)
;;;     XRLCONFIG  — Configure and optionally run
;;;     XRL_VER    — Version info
;;;
;;;   Selection: 1,3,5-8  |  * (all)  |  0 (cancel)
;;;
;;;   Saved set auto-saves to <drawing>.xrl beside the .dwg
;;;   and auto-loads when the in-memory set is empty.
;;; ===========================================================

(setq *xrl-version* "2.7")

(setq *xrl-mode*    "V")     ; always reset to Saved on load
(setq *xrl-saveall* T)       ; always reset to ON on load
(if (not *xrl-saved*) (setq *xrl-saved* nil))

;;; ===========================================================
;;;   U T I L I T I E S
;;; ===========================================================

(defun xrl:get-xref-list ( / blk flags xlist)
  (setq xlist nil blk (tblnext "BLOCK" T))
  (while blk
    (setq flags (cdr (assoc 70 blk)))
    (if (and flags (= (logand flags 4) 4))
      (setq xlist (cons (cdr (assoc 2 blk)) xlist))
    )
    (setq blk (tblnext "BLOCK"))
  )
  (reverse xlist)
)

(defun xrl:trim (str / lo hi)
  (setq lo 1 hi (strlen str))
  (while (and (<= lo hi) (= (substr str lo 1) " ")) (setq lo (1+ lo)))
  (while (and (>= hi lo) (= (substr str hi 1) " ")) (setq hi (1- hi)))
  (if (< hi lo) "" (substr str lo (- hi lo -1)))
)

(defun xrl:split-string (str delim / pos parts)
  (setq parts nil)
  (while (setq pos (vl-string-search delim str))
    (setq parts (cons (substr str 1 pos) parts)
          str   (substr str (+ pos 2)))
  )
  (reverse (cons str parts))
)

(defun xrl:parse-range (str / seg dashpos lo hi n result)
  (setq result nil)
  (foreach seg (xrl:split-string str ",")
    (setq seg (xrl:trim seg))
    (if (/= seg "")
      (progn
        (setq dashpos (vl-string-search "-" seg))
        (if dashpos
          (progn
            (setq lo (atoi (substr seg 1 dashpos))
                  hi (atoi (substr seg (+ dashpos 2))))
            (if (and (> lo 0) (> hi 0) (<= lo hi))
              (progn
                (setq n lo)
                (while (<= n hi)
                  (if (not (member n result)) (setq result (cons n result)))
                  (setq n (1+ n))
                )
              )
            )
          )
          (progn
            (setq n (atoi seg))
            (if (and (> n 0) (not (member n result)))
              (setq result (cons n result))
            )
          )
        )
      )
    )
  )
  (reverse result)
)

(defun xrl:mode-name (code)
  (cond ((= code "Q") "Quick")
        ((= code "E") "Select")
        ((= code "V") "Saved")
        (T            "Quick"))
)

(defun xrl:pick-xrefs-range (xlist show-all / i xname input nums picked)
  (princ "\n  ┌─────────────────────────────────────")
  (setq i 1)
  (foreach xname xlist
    (princ (strcat "\n  │ " (itoa i) ". " xname))
    (setq i (1+ i))
  )
  (if show-all (princ "\n  │ *  All"))
  (princ "\n  │ 0  Cancel")
  (princ "\n  └─────────────────────────────────────")
  (setq input (xrl:trim (getstring T "\n  Select (1,3,5-8 or *): ")))
  (cond
    ((or (= input "") (= input "0")) nil)
    ((and show-all (= input "*"))    xlist)
    (T
     (setq nums (xrl:parse-range input) picked nil)
     (foreach n nums
       (if (and (>= n 1) (<= n (length xlist)))
         (progn
           (setq xname (nth (1- n) xlist))
           (if (not (member xname picked))
             (setq picked (cons xname picked))
           )
         )
         (princ (strcat "\n  [!] Invalid #" (itoa n)))
       )
     )
     (reverse picked)
    )
  )
)

;;; ===========================================================
;;;   S A V E D   S E T   P E R S I S T E N C E
;;; ===========================================================

(defun xrl:set-filepath ( / prefix sep)
  (setq prefix (getvar "DWGPREFIX"))
  (if (and prefix (/= prefix ""))
    (progn
      (setq sep (substr prefix (strlen prefix) 1))
      (if (and (/= sep "\\") (/= sep "/"))
        (setq prefix (strcat prefix "\\"))
      )
      (strcat prefix (vl-filename-base (getvar "DWGNAME")) ".xrl")
    )
    nil
  )
)

(defun xrl:set-write ( / fpath f xname)
  (setq fpath (xrl:set-filepath))
  (if (and fpath *xrl-saved*)
    (progn
      (setq f (open fpath "w"))
      (if f
        (progn
          (foreach xname *xrl-saved* (write-line xname f))
          (close f)
        )
      )
    )
  )
)

(defun xrl:set-read ( / fpath f line names)
  (setq fpath (xrl:set-filepath))
  (if (and fpath (vl-file-size fpath))
    (progn
      (setq f (open fpath "r") names nil)
      (if f
        (progn
          (while (setq line (read-line f))
            (setq line (xrl:trim line))
            (if (and (/= line "") (not (member line names)))
              (setq names (cons line names))
            )
          )
          (close f)
          (setq *xrl-saved* (reverse names))
        )
      )
    )
  )
)

(defun xrl:set-autoload ()
  (if (and (null *xrl-saved*)
           (xrl:set-filepath)
           (vl-file-size (xrl:set-filepath)))
    (xrl:set-read)
  )
)

;;; ===========================================================
;;;   S A V E A L L
;;; ===========================================================

(defun xrl:saveall-targets (target-names / acad active active-path docs doc docpath i basename modified saveerr saved)
  (if *xrl-saveall*
    (progn
      (setq acad         (vlax-get-acad-object)
            active       (vla-get-activedocument acad)
            docs         (vla-get-documents acad)
            i            0
            saved        0
            target-names (mapcar 'strcase target-names))
      (setq active-path (strcase (vla-get-fullname active)))
      (repeat (vla-get-count docs)
        (setq doc (vl-catch-all-apply 'vla-item (list docs i)))
        (if (vl-catch-all-error-p doc)
          (setq docpath nil)
          (setq docpath (vl-catch-all-apply 'vla-get-fullname (list doc)))
        )
        (if (and (not (vl-catch-all-error-p docpath))
                 (/= (strcase docpath) active-path))
          (progn
            (setq basename (vl-filename-base docpath))
            (if (member (strcase basename) target-names)
              (progn
                (setq modified (vl-catch-all-apply 'vla-get-saved (list doc)))
                (if (and (not (vl-catch-all-error-p modified))
                         (= modified :vlax-false))
                  (progn
                    (princ (strcat "\n  [SAVE] " basename))
                    (setq saveerr (vl-catch-all-apply 'vla-save (list doc)))
                    (if (vl-catch-all-error-p saveerr)
                      (princ (strcat "\n  [!] Save failed: " (vl-catch-all-error-message saveerr)))
                      (setq saved (1+ saved))
                    )
                  )
                )
              )
            )
          )
        )
        (setq i (1+ i))
      )
      (if (> saved 0)
        (princ (strcat "\n  " (itoa saved) " drawing(s) saved.\n"))
      )
    )
  )
)

;;; ===========================================================
;;;   R E L O A D
;;; ===========================================================

(defun xrl:reload-and-report (names xlist / count xname)
  (setq count 0)
  (foreach xname names
    (if (member xname xlist)
      (progn
        (command "._-XREF" "_Reload" xname)
        (setq count (1+ count))
        (princ (strcat "\n  [OK] " xname))
      )
      (princ (strcat "\n  [--] Not found: " xname))
    )
  )
  (princ (strcat "\n\n  " (itoa count) " of " (itoa (length names)) " xref(s) reloaded."))
  count
)

;;; ===========================================================
;;;   M O D E S
;;; ===========================================================

(defun xrl:quick-mode ( / xlist)
  (setq xlist (xrl:get-xref-list))
  (if xlist
    (progn (xrl:saveall-targets xlist) (xrl:reload-and-report xlist xlist))
    (princ "\n  No xrefs found.")
  )
)

(defun xrl:select-mode ( / xlist picked)
  (setq xlist (xrl:get-xref-list))
  (if (null xlist)
    (princ "\n  No xrefs found.")
    (progn
      (setq picked (xrl:pick-xrefs-range xlist T))
      (if picked
        (progn (xrl:saveall-targets picked) (xrl:reload-and-report picked xlist))
        (princ "\n  Cancelled.")
      )
    )
  )
)

(defun xrl:saved-mode ( / xlist)
  (setq xlist (xrl:get-xref-list))
  (cond
    ((null xlist)
     (princ "\n  No xrefs in this drawing.")
    )
    ((null *xrl-saved*)
     (princ "\n  Saved set is empty — opening XRLCONFIG to build one...")
     (c:XRLCONFIG)
    )
    (T
     (xrl:saveall-targets *xrl-saved*)
     (xrl:reload-and-report *xrl-saved* xlist)
    )
  )
)

;;; ===========================================================
;;;   C O N F I G   S U B C O M M A N D S
;;; ===========================================================

(defun xrlconfig:mode ( / input)
  (initget "Quick sElect saVed")
  (setq input (getkword "\n  Mode [Quick/sElect/saVed] <Saved>: "))
  (cond
    ((= input "Quick")  (setq *xrl-mode* "Q"))
    ((= input "sElect") (setq *xrl-mode* "E"))
    (T                  (setq *xrl-mode* "V"))
  )
  (princ (strcat "\n  Mode: " (xrl:mode-name *xrl-mode*)))
)

(defun xrlconfig:set ( / input xlist picked)
  (initget "Add Remove Clear")
  (setq input (getkword "\n  Saved set [Add/Remove/Clear] <Add>: "))
  (if (null input) (setq input "Add"))
  (cond
    ((= input "Add")
     (setq xlist (xrl:get-xref-list))
     (if (null xlist)
       (princ "\n  No xrefs in this drawing.")
       (progn
         (setq picked (xrl:pick-xrefs-range xlist nil))
         (if picked
           (progn
             (foreach xname picked
               (if (not (member xname *xrl-saved*))
                 (setq *xrl-saved* (cons xname *xrl-saved*))
               )
             )
             (setq *xrl-saved* (reverse *xrl-saved*))
             (xrl:set-write)
           )
           (princ "\n  Nothing added.")
         )
       )
     )
    )
    ((= input "Remove")
     (if (null *xrl-saved*)
       (princ "\n  Saved set is already empty.")
       (progn
         (setq picked (xrl:pick-xrefs-range *xrl-saved* nil))
         (if picked
           (progn
             (foreach xname picked
               (setq *xrl-saved* (vl-remove xname *xrl-saved*))
             )
             (xrl:set-write)
           )
           (princ "\n  Nothing removed.")
         )
       )
     )
    )
    ((= input "Clear")
     (setq *xrl-saved* nil)
     (xrl:set-write)
     (princ "\n  Saved set cleared.")
    )
  )
)

(defun xrlconfig:saveall ( / input)
  (initget "On Off")
  (setq input (getkword (strcat "\n  SaveAll [On/Off] <"
                                (if *xrl-saveall* "On" "Off") ">: ")))
  (if (null input) (setq input (if *xrl-saveall* "On" "Off")))
  (cond
    ((= input "On")  (setq *xrl-saveall* T)   (princ "\n  SaveAll: ON"))
    ((= input "Off") (setq *xrl-saveall* nil) (princ "\n  SaveAll: OFF"))
  )
)

(defun xrlconfig:print-status ( / xname)
  (princ (strcat
    "\n  ┌─── XRL Config ──────────────────────────"
    "\n  │  Mode:    " (xrl:mode-name *xrl-mode*)
    "\n  │  SaveAll: " (if *xrl-saveall* "ON" "OFF")
    "\n  │  Saved set:"
  ))
  (if *xrl-saved*
    (foreach xname *xrl-saved*
      (princ (strcat "\n  │    " xname))
    )
    (princ "\n  │    (empty)")
  )
  (princ "\n  └─────────────────────────────────────────")
)

;;; ===========================================================
;;;   X R L C O N F I G
;;; ===========================================================
(defun c:XRLCONFIG ( / *error* old-cmdecho old-filedia input)

  (defun *error* (msg)
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if old-filedia (setvar "FILEDIA" old-filedia))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\n  [!] XRLCONFIG error: " msg))
    )
    (princ)
  )

  (setq old-cmdecho (getvar "CMDECHO")
        old-filedia (getvar "FILEDIA"))
  (setvar "CMDECHO" 0)
  (setvar "FILEDIA" 0)

  (xrl:set-autoload)
  (xrlconfig:print-status)

  (initget "Mode Set saveAll")
  (setq input (getkword "\n  [Mode/Set/saveAll] <Set>: "))
  (if (null input) (setq input "Set"))
  (cond
    ((= input "Mode")    (xrlconfig:mode))
    ((= input "Set")     (xrlconfig:set))
    ((= input "saveAll") (xrlconfig:saveall))
  )

  (xrlconfig:print-status)

  (initget "Yes No")
  (setq input (getkword "\n  Run XRL now? [Yes/No] <Yes>: "))
  (if (or (null input) (= input "Yes"))
    (progn
      (setvar "CMDECHO" old-cmdecho)
      (setvar "FILEDIA" old-filedia)
      (c:XRL)
      (princ)
      (exit)
    )
  )

  (setvar "CMDECHO" old-cmdecho)
  (setvar "FILEDIA" old-filedia)
  (princ)
)

;;; ===========================================================
;;;   X R L
;;; ===========================================================
(defun c:XRL ( / *error* old-cmdecho old-filedia)

  (defun *error* (msg)
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if old-filedia (setvar "FILEDIA" old-filedia))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\n  [!] XRL error: " msg))
    )
    (princ)
  )

  (setq old-cmdecho (getvar "CMDECHO")
        old-filedia (getvar "FILEDIA"))
  (setvar "CMDECHO" 0)
  (setvar "FILEDIA" 0)

  (xrl:set-autoload)

  (princ (strcat "\n  XRL  " (xrl:mode-name *xrl-mode*)
                 "  |  SaveAll: " (if *xrl-saveall* "ON" "OFF")))

  (cond
    ((= *xrl-mode* "E") (xrl:select-mode))
    ((= *xrl-mode* "V") (xrl:saved-mode))
    (T                   (xrl:quick-mode))
  )

  (setvar "CMDECHO" old-cmdecho)
  (setvar "FILEDIA" old-filedia)
  (princ)
)

;;; ===========================================================
;;;   X R L _ V E R
;;; ===========================================================
(defun c:XRL_VER ()
  (princ (strcat "\n  XRL v" *xrl-version* "  —  Adrian Ayala\n"))
  (princ)
)

(princ (strcat "\n  XRL v" *xrl-version* " loaded.  XRL = reload  |  XRLCONFIG = settings"))
(princ)

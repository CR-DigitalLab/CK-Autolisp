;;; ============================================================
;;; EXPLODETOTAL.lsp
;;; Explode semua Block dan XRef di gambar AutoCAD tanpa terkecuali
;;; Cara pakai: Load file ini lalu ketik EXPLODETOTAL di command line
;;; ============================================================

;;; ============================================================
;;; Metode utama menggunakan vla-object (ActiveX)
;;; ============================================================

(defun c:EXPLODETOTAL
  (/ *error* doc blk totalXref xrefIdx bindOk bindFail bindRes expRes obj
  ss ent i retry loopCount maxRetry loopExploded)

  (defun *error* (msg)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (setvar "CMDECHO" 1)
    (if doc
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (princ)
  )

  (vl-load-com)
  (setvar "CMDECHO" 0)

  (princ "\n=== EXPLODETOTAL (ActiveX Method) ===")
  (princ "\nMemproses dengan metode ActiveX... harap tunggu.\n")

  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (vla-startundomark doc)

  ;; Hitung dulu XRef top-level (tanpa nested xref berkarakter "|")
  ;; agar progress n/total bisa ditampilkan dengan jelas.
  (setq totalXref 0)
  (vlax-for blk (vla-get-blocks doc)
    (if (and (= (vla-get-isxref blk) :vlax-true)
             (not (wcmatch (vla-get-name blk) "*|*")))
      (progn
        (setq totalXref (1+ totalXref))
      )
    )
  )

  ;; Bind XRef via ActiveX per objek xref
  (setq xrefIdx 0
        bindOk 0
        bindFail 0)

  (if (> totalXref 0)
    (progn
      (princ (strcat "\nDitemukan " (itoa totalXref) " XRef top-level untuk diproses."))
      (vlax-for blk (vla-get-blocks doc)
        (if (and (= (vla-get-isxref blk) :vlax-true)
                 (not (wcmatch (vla-get-name blk) "*|*")))
          (progn
            (setq xrefIdx (1+ xrefIdx))
            (princ (strcat "\n[" (itoa xrefIdx) "/" (itoa totalXref) "] Binding XRef: " (vla-get-name blk)))
            ;; Argumen kedua = :vlax-true agar nama simbol diprefix saat bind
            (setq bindRes (vl-catch-all-apply 'vla-bind (list blk :vlax-true)))
            (if (vl-catch-all-error-p bindRes)
              (progn
                (setq bindFail (1+ bindFail))
                (princ " -> gagal (skip)")
              )
              (progn
                (setq bindOk (1+ bindOk))
                (princ " -> sukses")
              )
            )
          )
        )
      )
      (princ (strcat "\nRingkasan bind: sukses " (itoa bindOk)
                     ", gagal " (itoa bindFail) "."))
    )
    (princ "\nTidak ada XRef ditemukan.")
  )

  ;; Unlock semua layer sekali di awal agar objek bisa diproses
  (command "_.LAYER" "_Unlock" "*" "")

  ;; Loop explode nested blocks di seluruh drawing.
  ;; Diproses via ActiveX (bukan command EXPLODE) supaya aman lintas Model/Paper Space.
  (setq maxRetry 50)
  (setq loopCount 0)
  (setq retry T)

  (while (and retry (< loopCount maxRetry))
    (setq loopCount (1+ loopCount))
    (setq retry nil)
    (setq loopExploded 0)

    (setq ss (ssget "_X" '((0 . "INSERT"))))
    (if ss
      (progn
        (princ (strcat "\nLoop ke-" (itoa loopCount)
                       ": Ditemukan " (itoa (sslength ss)) " INSERT untuk di-explode..."))
        (setq i 0)
        (while (< i (sslength ss))
          (setq ent (ssname ss i))
          (if (and ent (entget ent))
            (progn
              (setq obj (vlax-ename->vla-object ent))
              (if (and obj (vlax-method-applicable-p obj 'Explode))
                (progn
                  (setq expRes (vl-catch-all-apply 'vla-explode (list obj)))
                  (if (not (vl-catch-all-error-p expRes))
                    (progn
                      (vl-catch-all-apply 'vla-delete (list obj))
                      (setq loopExploded (1+ loopExploded))
                    )
                  )
                )
              )
            )
          )
          (setq i (1+ i))
        )

        (if (> loopExploded 0)
          (setq retry T)
          (princ "\nTidak ada INSERT yang bisa di-explode pada loop ini.")
        )
      )
    )

    (if retry
      (princ (strcat "\nLoop ke-" (itoa loopCount) " selesai, memeriksa ulang..."))
    )
  )

  ;; Purge block definitions
  (princ "\nMembersihkan definisi block...")
  (command "_.PURGE" "_All" "*" "_No")

  (vla-endundomark doc)
  (setvar "CMDECHO" 1)

  (princ (strcat "\n\n=== Selesai! Total loop: " (itoa loopCount) " ==="))
  (princ "\nSemua Block dan XRef telah berhasil di-explode.")
  (princ)
)

;;; ============================================================
;;; Mode aman: bind + explode tanpa purge agresif
;;; ============================================================

(defun c:EXPLODETOTALSAFE
  (/ *error* doc blk totalXref xrefIdx bindOk bindFail bindRes expRes obj
  ss ent entData i retry loopCount maxRetry loopExploded
  isAnno hasAttr isPaper skipAnno skipAttr skipPaper)

  (defun *error* (msg)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (setvar "CMDECHO" 1)
    (if doc
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (princ)
  )

  (vl-load-com)
  (setvar "CMDECHO" 0)

  (princ "\n=== EXPLODETOTALSAFE (Safe Mode) ===")
  (princ "\nMemproses bind + explode tanpa purge agresif (preserve annotation)... harap tunggu.\n")

  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (vla-startundomark doc)

  ;; Hitung dulu XRef top-level (tanpa nested xref berkarakter "|")
  (setq totalXref 0)
  (vlax-for blk (vla-get-blocks doc)
    (if (and (= (vla-get-isxref blk) :vlax-true)
             (not (wcmatch (vla-get-name blk) "*|*")))
      (progn
        (setq totalXref (1+ totalXref))
      )
    )
  )

  ;; Bind XRef via ActiveX per objek xref
  (setq xrefIdx 0
        bindOk 0
        bindFail 0)

  (if (> totalXref 0)
    (progn
      (princ (strcat "\nDitemukan " (itoa totalXref) " XRef top-level untuk diproses."))
      (vlax-for blk (vla-get-blocks doc)
        (if (and (= (vla-get-isxref blk) :vlax-true)
                 (not (wcmatch (vla-get-name blk) "*|*")))
          (progn
            (setq xrefIdx (1+ xrefIdx))
            (princ (strcat "\n[" (itoa xrefIdx) "/" (itoa totalXref) "] Binding XRef: " (vla-get-name blk)))
            (setq bindRes (vl-catch-all-apply 'vla-bind (list blk :vlax-true)))
            (if (vl-catch-all-error-p bindRes)
              (progn
                (setq bindFail (1+ bindFail))
                (princ " -> gagal (skip)")
              )
              (progn
                (setq bindOk (1+ bindOk))
                (princ " -> sukses")
              )
            )
          )
        )
      )
      (princ (strcat "\nRingkasan bind: sukses " (itoa bindOk)
                     ", gagal " (itoa bindFail) "."))
    )
    (princ "\nTidak ada XRef ditemukan.")
  )

  ;; Unlock semua layer sekali di awal agar objek bisa diproses
  (command "_.LAYER" "_Unlock" "*" "")

  ;; Loop explode nested blocks via ActiveX (aman lintas Model/Paper Space)
  (setq maxRetry 50)
  (setq loopCount 0)
  (setq retry T)
  (setq skipAnno 0)
  (setq skipAttr 0)
  (setq skipPaper 0)

  (while (and retry (< loopCount maxRetry))
    (setq loopCount (1+ loopCount))
    (setq retry nil)
    (setq loopExploded 0)

    (setq ss (ssget "_X" '((0 . "INSERT"))))
    (if ss
      (progn
        (princ (strcat "\nLoop ke-" (itoa loopCount)
                       ": Ditemukan " (itoa (sslength ss)) " INSERT untuk di-explode..."))
        (setq i 0)
        (while (< i (sslength ss))
          (setq ent (ssname ss i))
          (if (and ent (entget ent))
            (progn
              (setq entData (entget ent))
              (setq obj (vlax-ename->vla-object ent))
              (setq isPaper (= 1 (cdr (assoc 67 entData))))
              (setq hasAttr
                (and obj
                     (vlax-property-available-p obj 'HasAttributes)
                     (= :vlax-true (vla-get-hasattributes obj))))
              (setq isAnno
                (and obj
                     (vlax-property-available-p obj 'Annotative)
                     (not (vl-catch-all-error-p
                            (vl-catch-all-apply 'vla-get-annotative (list obj))))
                     (/= 0 (vla-get-annotative obj))))

              ;; SAFE mode: jangan explode objek yang berpotensi merusak tampilan annotation.
              (cond
                (isPaper
                  (setq skipPaper (1+ skipPaper)))
                (hasAttr
                  (setq skipAttr (1+ skipAttr)))
                (isAnno
                  (setq skipAnno (1+ skipAnno)))
                ((and obj (vlax-method-applicable-p obj 'Explode))
                (progn
                  (setq expRes (vl-catch-all-apply 'vla-explode (list obj)))
                  (if (not (vl-catch-all-error-p expRes))
                    (progn
                      (vl-catch-all-apply 'vla-delete (list obj))
                      (setq loopExploded (1+ loopExploded))
                    )
                  )
                )
                )
              )
            )
          )
          (setq i (1+ i))
        )

        (if (> loopExploded 0)
          (setq retry T)
          (princ "\nTidak ada INSERT yang bisa di-explode pada loop ini.")
        )
      )
    )

    (if retry
      (princ (strcat "\nLoop ke-" (itoa loopCount) " selesai, memeriksa ulang..."))
    )
  )

  ;; Mode aman: hanya purge definisi block, tanpa purge style/objek lain
  (princ "\nMode aman: membersihkan definisi block yang tidak terpakai...")
  (command "_.PURGE" "_Blocks" "*" "_No")

  (princ (strcat "\nSAFE summary - skip annotative: " (itoa skipAnno)
                 ", skip attributed: " (itoa skipAttr)
                 ", skip paperspace: " (itoa skipPaper)))

  (vla-endundomark doc)
  (setvar "CMDECHO" 1)

  (princ (strcat "\n\n=== Selesai (SAFE)! Total loop: " (itoa loopCount) " ==="))
  (princ "\nSemua Block dan XRef telah berhasil di-bind/explode (mode aman).")
  (princ)
)

(princ "\nEXPLODETOTAL.lsp berhasil di-load.")
(princ "\nKetik EXPLODETOTAL - metode ActiveX (utama)")
(princ "\nKetik EXPLODETOTALSAFE - mode aman (tanpa purge agresif)")
(princ)

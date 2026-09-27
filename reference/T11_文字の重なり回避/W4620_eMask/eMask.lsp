(defun c:MaskMLeader (/ ss i ent obj)
  (princ "version 0.0.2")
  (vl-load-com)
  
  ; (setq scale (getreal "\nMasukkan border offset factor (contoh 1.2): "))
  ; (setq scale nil) ;; kalau tidak set
  (princ "\nSelect MLeaders to add background mask: ")

  (if (setq ss (ssget '((0 . "MULTILEADER"))))
    (repeat (setq i (sslength ss))
      (setq ent (ssname ss (setq i (1- i))))
      (setq obj (vlax-ename->vla-object ent))

      ;; Property yang BENAR
      (vla-put-TextBackgroundFill obj :vlax-true)
      
      (setq offsetValue 1.05) ; Set desired offset (e.g., 1.25)
      (set-mtext-offset (vlax-vla-object->ename obj) offsetValue)
    )
    (princ "\nNo MLeaders selected.")
  )
  
  ; (if (setq ss (ssget '((0 . "MULTILEADER"))))
  ;   (repeat (setq i (sslength ss))
  ;     (setq ent (ssname ss (setq i (1- i))))

  ;     ;; Aktifkan mask
  ;     (setpropertyvalue ent "MText/BackgroundFill" 1)

  ;     ;; Set border offset factor
  ;     (setpropertyvalue ent "MText/BackgroundScaleFactor" 1.2)
  ;   )
  ;   (princ "\nNo MLeader selected.")
  ; )
  ; (princ)
)


; (defun c:MLMASK ( / ss i ent obj scale optScale success total )

;   (vl-load-com)

;   ;; =========================
;   ;; OPTION: BORDER OFFSET
;   ;; =========================
;   (initget "Yes No")
;   (setq optScale (getkword "\nAtur border offset factor? [Yes/No] <No>: "))
;   (if (null optScale) (setq optScale "No"))

;   (if (= optScale "Yes")
;     (setq scale (getreal "\nMasukkan border offset factor (contoh 1.2): "))
;     (setq scale nil) ;; kalau tidak set
;   )

;   ;; =========================
;   ;; SELECTION (langsung filter)
;   ;; =========================
;   (prompt "\nPilih MLeader: ")
;   (setq ss (ssget '((0 . "MULTILEADER"))))

;   (if (not ss)
;     (progn
;       (princ "\n❌ Tidak ada MLeader dipilih.")
;       (exit)
;     )
;   )

;   ;; =========================
;   ;; PROCESS
;   ;; =========================
;   (setq i 0)
;   (setq success 0)
;   (setq total (sslength ss))

;   (while (< i total)
;     (setq ent (ssname ss i))
;     (setq obj (vlax-ename->vla-object ent))

;     ;; Aktifkan mask (ini selalu aman)
;     (vla-put-TextBackgroundFill obj :vlax-true)

;     ;; Set scale jika tersedia
;     (if scale
;       (vl-catch-all-apply
;         'vla-put-TextBackgroundScaleFactor
;         (list obj scale)
;       )
;     )

;     (setq success (1+ success))
;     (setq i (1+ i))
;   )

;   ;; =========================
;   ;; REPORT
;   ;; =========================
;   (princ
;     (strcat
;       "\n✅ Mask applied: "
;       (itoa success)
;       " MLeader."
;     )
;   )

;   (princ)
; )
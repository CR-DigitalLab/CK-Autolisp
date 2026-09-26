;; ***  IsX64 1.0         2009-12-12  ***
;;
;; This software may be freely modified, 
;; distributed, or used for any purpose.
;;
;; ******************************
;; ****  Owen Wengerd        ****
;; ****  ManuSoft            ****
;; ****  www.manusoft.com    ****
;; ******************************
;;
;;
;; This code demonstrates how to detect
;; whether AutoLISP is running inside
;; a 64-bit AutoCAD host.

(defun ISX64 (/ proc_arch)
  (and
    (setq proc_arch (getenv "PROCESSOR_ARCHITECTURE"))
    (< 1 (strlen proc_arch))
    (eq "64" (substr proc_arch (1- (strlen proc_arch))))
  )
)

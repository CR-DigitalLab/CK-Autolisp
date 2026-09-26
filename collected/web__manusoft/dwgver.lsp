;; ***  DwgVer 3.0         2012-10-30  ***
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
;; This code demonstrates how to read the
;; file version from an AutoCAD .dwg file.
;;
;; Thanks to Craig Black and David Doane
;; for suggesting improvements.


;; return the file version string
(defun DWGVer (filename / fh cnt dv inp)
  (setq cnt 10 dv "")
  (if (setq fh (open filename "r"))
    (progn
      (while
        (and
          (> (setq cnt (1- cnt)) 0)
          (setq inp (read-char fh))
          (> inp 0)
        )
        (setq dv (strcat dv (chr inp)))
      )
      (close fh)
    )
  )
  (if (and (> cnt 0) (> (strlen dv) 0)) dv)
)

;; return the corresponding AutoCAD version
(defun DWGtoACAD (dwgver)
  (cdr
    (assoc dwgver
      '(
        ("MC0.0"   . "AutoCAD 1.1")
        ("AC1.2"   . "AutoCAD 1.2")
        ("AC1.4"   . "AutoCAD 1.4")
        ("AC1.50"  . "AutoCAD 2.0")
        ("AC2.10"  . "AutoCAD 2.10")
        ("AC1002"  . "AutoCAD 2.5")
        ("AC1003"  . "AutoCAD 2.6")
        ("AC1004"  . "AutoCAD R9")
        ("AC1006"  . "AutoCAD R10")
        ("AC1009"  . "AutoCAD R11/R12")
        ("AC1012"  . "AutoCAD R13")
        ("AC1014"  . "AutoCAD R14")
        ("AC1015"  . "AutoCAD R2000/2000i/2002")
        ("AC1018"  . "AutoCAD R2004/2005/2006")
        ("AC1021"  . "AutoCAD R2007/2008/2009")
        ("AC1024"  . "AutoCAD R2010")
        ("AC1027"  . "AutoCAD R2013")
       )
    )
  )
)

;; examples
(defun IsR13 (filename)
  (= "AC1012" (DWGVer filename))
)

(defun CurrentFileVersion ()
  (if (= 1 (getvar "DWGTITLED"))
    (DWGtoACAD (DWGVer (strcat (getvar "DWGPREFIX") (getvar "DWGNAME"))))
  )
)

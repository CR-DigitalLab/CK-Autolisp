; ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
; A/E Automation Systems          ²² ²² ²²²²²  °°°°°°°°°°°°°°°°°°°°°°°°°
;                               ²²²  ²²
;                             ²²²    ²² ²²²       32 Gould Avenue
;                           ²²²   ²² ²²           Paterson, N.J.  07503
; °°°°°°°°°°°°°°°°°°°°°°  ²²²        ²² ²²²²²     (201) 523-7944
;
; ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
; d e s i g n         a u t o m a t i o n          c o n s u l t a n t s
;
; ----------------------------------------------------------------------
; ESLIDE.LSP
;
; AutoCAD enhancement software
;
; Released to the public as ShareWare on 1/22/89
;
; Engineered by:
;
; Tony Tanzillo,
; A/E Automation Systems,
; Design Automation Consulting Services           (all rights reserved).
;
; NOT PUBLIC DOMAIN
;
; Any commercial use of this software or any use that is in a commercial
; environment that is not non-profit in nature requires registration and
; payment to the author, in the amount indicated below.
;
; Permission is granted to distribute this file free of charge ONLY
; in its original form as distributed by the author.  You may not in
; any way offer for sale, and/or accept payment in exchange for this
; file or it's contents regardless of form or medium of exchange.
;
;                   >>>>>> ATTENTION SYSOPS <<<<<<<
;
; If this file appears on your system, and you choose to post it for
; downloading, you have permission to do so provided that the author
; is granted access to your system on a regular basis should he decide
; to seek same, without requiring any charge or subscription fees.
;
; If it is you intent to levy any charges, donations, membership, or
; subscription fees on the author if he requests access to your system,
; then this file may not appear on that same system under any circum-
; stances whatsoever. The same also applies to any shareware release
; by this author released on or after the date at the top of this file.
;
; Disclaimer.
;
; In no way is A/E Automation Systems or Tony Tanzillo responsible in
; any way for the contents of this file, including fitness for any
; specific purpose, or damadges resulting directly or indirectly from
; the use of same.  All use of this information is strictly at your own
; risk.
;
; Any incorporation of the information (or any portions thereof) as it
; appears in this file into any commercial products and/or services
; requires the prior expressed WRITTEN consent of the author (except
; as specifically provided for). Anyone who wishes to solicit same,
; may do so by contacting the author at the address at the top of this
; file. It is unlikely that any consent will be granted via telephone.
;
; Permission is specifically granted to Autodesk Inc. to distribute
; this file and/or make it available to the public as it see's fit,
; provided that due credit is given to the author.
;
; This is not FREEware, don't abuse us, or you may loose us!
;
; Considerable time and money have been invested in this software in
; order to make it the highest quality AutoCAD enhancement products
; available anywhere.  We would like to continue this policy.
;
; If you are using this program any commercial environment,  Please
; register it, and send the specifed registration fee, to help underwrite
; the cost of developing more HIGH PERFORMANCE AutoLISP applications
; and utilities for the public distribution (you never know what unknown
; BonusWARE you might recieve as a thank you for supporting our efforts
; to provide many useful high-performance, low-cost AutoCAD enhancements).
;
; Registration fee for ESLIDE is $15.00.
;
; Make all checks payable to:  Tony Tanzillo
;                              32 Gould Ave.
;                              Paterson, N.J. 07503
;
;
; To register your copy of ESLIDE for commercial use, send $15.00 in check
; or money order to A/E Automation Systems at the address listed above.
; Include your name, affiliation, mailing address, and telephone number so
; that you can be notified of future releases of this and other products.
;
; ------------------------------------------------------------------------
; ESLIDE.LSP
;
; 11/14/88
;
; AutoLISP based Command
;
; Selective slide creation facility
;
; Permits user create a slide and selectively include or exclude
; any object(s) visible on the display.
;
; Format:
;
; |
; | Command: ESLIDE
; | Slide filespec:  [enter filespec for slide, no extension]
; | Select objects:  [select objects to include in/exclude from slide]
; | Include/Exclude selected objects <Include>:  [see below]
; | Command:
; |
;
; If you select the Include option, the resulting slide file will
; contain ONLY the objects visible on the display that were selected.
;
; If you select the Exclude option, the resulting slide file will
; contain all objects visible on the display EXCEPT the objects that
; were selected.
;
; Note: As is the case with AutoCAD's MSLIDE command, ESLIDE
;       will also unconditionally overwrite an existing slide
;       file without warning!
;
; ----------------------------------------------------------------
; Closures
; ----------------------------------------------------------------
;
; ----------------------------------------------------------------
; UNDO: Backs up to the point where (group) was last
;       issued (see below).
;

(defun undo ()
  (cond (*undo* (setq *undo* (command "undo" "b"))))
)

; ----------------------------------------------------------------
; GROUP: Marks the start of an undo group for subsequent
;        use of (undo), and sets the undo-pending flag
;        *UNDO*, for use by the *ERROR* function.
;

(defun group ()
  (command "undo" "g")
  (setq *undo* t)
)

; ----------------------------------------------------------------
; DELTA
;
; 3D delta function (flatland must be 0!)
;
; (delta <basepoint> <x offset> <y offset> <z offset | NIL> )
;
; If <Z offset> is NIL, then 0.0 is substituted.
;

(defun delta (p x y z)
  (mapcar '+ p (list x y (cond (z) (t 0.0))))
)

; ----------------------------------------------------------------
; STRING?
;
; Returns <string>, if <string> is:
;
;  1. Non-NIL
;  2. A STRING data type
;  3. Has a string length of > 0
;

(defun string? (s)
  (cond  ( (and s (eq (type s) 'str) (> (strlen s) 0)) s))
)

; ----------------------------------------------------------------
; C:ESLIDE
;
; Front end command/main program function.
;

(defun C:ESLIDE ( / err fs fh sset vh vc )

  (setq err *error*
        *error* '( (msg)
                   (princ (strcat "\nError [ESLIDE]: " msg))
                   (undo)
                   (setq *error* err)
                   (prin1)
                 )
  )

  (cond (  (and (string? (setq fs (getstring "\nSlide file: ")))
                (cond (  (not (setq fh (open (strcat fs ".SLD") "w")))
                         (prompt "\nInvalid slide filespec.")
                      )
                      (t (close fh) t)
                )
                (cond (  (setq sset (ssget)))
                      (t (prompt "\nNo objects selected."))
                )
           )
           (setq vh (getvar "viewsize")
                 vc (getvar "viewctr")
           )
           (group)
           (mapcar '(lambda (x) (setvar x 0))
                   '("cmdecho" "flatland" "highlight")
           )
           (command "erase")
           (initget "Include Exclude")
           (cond (  (eq (getkword
                          "\nInclude/Exclude selected objects <Include>: "
                        )
                        "Exclude"
                    )
                    (command sset "")
                 )
                 (t (ssget "c" (delta vc (- vh) (- vh) nil)
                               (delta vc vh vh nil)
                    )
                    (command "r" sset "")
                 )
           )
           (command "mslide" fs)
           (undo)
        )
  )
  (setq *error* err)
  (prin1)
)


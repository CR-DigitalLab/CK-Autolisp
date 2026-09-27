;-------------------------------------------------------------------------------
; Program Name: DL.lsp
; Created By:   Terry Miller (Email: terrycadd@yahoo.com)
;               (URL: https://autolisp-exchange.com)
; Date Created: 1-1-01
; Function:     The Dimension Leader function includes the option of horizontal
;               or vertical Mtext, and is justified as upper right or upper left
;               based upon the users choice of text direction.  The user picks
;               the leader from and to points, the direction of text, and then
;               fills in the Mtext information.  The function adjusts the leader
;               to align with the top line of the Mtext, using the user's
;               selected points.  The user may easily add or delete Mtext lines
;               without affecting the location of the leader.
; Note:         Edit the lines ending with "<--Change to your Dim layer info"
;               as required.  The leader and Mtext are not grouped because of
;               the text justification.  To move the Mtext, stretch a crossing
;               of the upper Mtext insertion point and the two endpoints of the
;               line aligning with top line of the Mtext.  Use the same method
;               to lengthen the line with ortho on, by stretching the endpoint
;               closest to the Mtext and the Mtext insertion point.
;-------------------------------------------------------------------------------
; Revision History
; Rev  By     Date    Description
;-------------------------------------------------------------------------------
; 1   TM    1-1-01    Initial version
; 2   TM    6-1-05    Revised for AutoCAD 2005, and included direction of text.
; 3   TM    7-1-05    Added the option of horizontal or vertical text.  Also
;                     included the c:LO, Leader Only function.
;-------------------------------------------------------------------------------
; c:LO - Leader Only
;-------------------------------------------------------------------------------
(defun c:LO (/ Clayer$ DimBlk$ OrthoMode# Pt1@ Pt2@)
  (setvar "CMDECHO" 0)
  (setq Clayer$ (getvar "CLAYER"))
  (command "LAYER" "M" "DimText" "C" "2" "" "");<--Change to your Dim layer info
  (setq OrthoMode# (getvar "ORTHOMODE"))
  (setvar "ORTHOMODE" 0)
  (if (= (getvar "DIMBLK") "")
    (setq DimBlk$ ".")
    (setq DimBlk$ (getvar "DIMBLK"))
  );if
  (setvar "DIMBLK" ".")
  (princ "\nLeader Onlys")
  (if (setq Pt1@ (getpoint "\nFrom point: "))
    (setq Pt2@ (getpoint "\nTo point: " Pt1@))
  );if
  (if (and Pt1@ Pt2@)
    (command "LEADER" Pt1@ Pt2@ "" "" "N")
  );if
  (command "LAYER" "S" Clayer$ "")
  (setvar "ORTHOMODE" OrthoMode#)
  (setvar "DIMBLK" DimBlk$)
  (princ)
);defun c:LO
;-------------------------------------------------------------------------------
; c:DL - Dim Leader
;-------------------------------------------------------------------------------
(defun c:DL (/ Assoc10@ Assoc50@ Assoc71@ Clayer$ DimBlk$ DimScale~ DimTad#
  EntFirst^ EntLast^ EntLeader^ EntList@ EntMtext^ Mirror OrthoMode# OsMode# Pt@
  Pt1@ Pt2@ Pt3@ Rotation SS& X1~ X2~)
  (setvar "CMDECHO" 0)
  (setq Clayer$ (getvar "CLAYER"))
  (command "LAYER" "M" "DimText" "C" "2" "" "");<--Change to your Dim layer info
  (setq OsMode# (getvar "OSMODE"))
  (setvar "OSMODE" 0)
  (setq OrthoMode# (getvar "ORTHOMODE"))
  (setvar "ORTHOMODE" 0)
  (if (= (getvar "DIMBLK") "")
    (setq DimBlk$ ".")
    (setq DimBlk$ (getvar "DIMBLK"))
  );if
  (setvar "DIMBLK" ".")
  (setq DimTad# (getvar "DIMTAD"))
  (princ "\nDIM Leader")
  (if (= (getvar "DIMSCALE") 0)
    (setq DimScale~ 1)
    (setq DimScale~ (getvar "DIMSCALE"))
  );if
  (if (setq Pt1@ (getpoint "\nFrom point: "))
    (progn
      (princ "\nTo point: ")
      (command "LEADER" Pt1@ pause ^c)
    );progn
    (exit)
  );if
  (setq Pt2@ (getvar "LASTPOINT"))
  (princ "\nDirection of leader text: ")
  (setvar "ORTHOMODE" 1)
  (command "LEADER" Pt1@ Pt2@ pause ^c)
  (setq Pt3@ (getvar "LASTPOINT"))
  (command "LEADER" Pt1@ Pt2@ "" "" "N")
  (setq EntFirst^ (entlast))
  (cond
    ((or (<= (angle Pt1@ Pt2@) (* pi 0.5))(>= (angle Pt1@ Pt2@) (* pi 1.5)))  ; 0 degrees
      (setq Pt@ (polar Pt2@ 0 (* (getvar "DIMASZ") DimScale~)))
    );case
    ((<= (angle Pt1@ Pt2@) (* pi 1.5))                                        ; 180 degrees
      (setq Pt@ (polar Pt2@ pi (* (getvar "DIMASZ") DimScale~)))
    );case
  );cond
  (cond
    ((or (<= (angle Pt2@ Pt3@) (* pi 0.25))(>= (angle Pt2@ Pt3@) (* pi 1.75))); 0 degrees
      (setq Pt3@ (polar Pt2@ 0 (* (getvar "DIMASZ") DimScale~)))
      (setq Assoc10@ (polar Pt3@ 0 (* (getvar "DIMGAP") DimScale~)))
      (setq Assoc10@ (cons 10 (polar Assoc10@ (* pi 0.5) (/ (* (getvar "DIMTXT") DimScale~) 2.0))))
      (setq Assoc50@ (cons 50 0))
      (setq Assoc71@ (cons 71 1))
      (setq Rotation 0)
    );case
    ((<= (angle Pt2@ Pt3@) (* pi 0.75))                                       ; 90 degrees
      (setq Pt3@ (polar Pt2@ (* pi 0.5) (* (getvar "DIMASZ") DimScale~)))
      (setq Assoc10@ (polar Pt3@ (* pi 0.5) (* (getvar "DIMGAP") DimScale~)))
      (setq Assoc10@ (cons 10 (polar Assoc10@ pi (/ (* (getvar "DIMTXT") DimScale~) 2.0))))
      (setq Assoc50@ (cons 50 (* pi 0.5)))
      (setq Assoc71@ (cons 71 1))
      (setq Rotation -90)
    );case
    ((<= (angle Pt2@ Pt3@) (* pi 1.25))                                       ; 180 degrees
      (setq Pt3@ (polar Pt2@ pi (* (getvar "DIMASZ") DimScale~)))
      (setq Assoc10@ (polar Pt3@ pi (* (getvar "DIMGAP") DimScale~)))
      (setq Assoc10@ (cons 10 (polar Assoc10@ (* pi 0.5) (/ (* (getvar "DIMTXT") DimScale~) 2.0))))
      (setq Assoc50@ (cons 50 0))
      (setq Assoc71@ (cons 71 3))
      (setq Rotation 0)
    );case
    ((<= (angle Pt2@ Pt3@) (* pi 1.75))                                       ; 270 degrees
      (setq Pt3@ (polar Pt2@ (* pi 1.5) (* (getvar "DIMASZ") DimScale~)))
      (setq Assoc10@ (polar Pt3@ (* pi 1.5) (* (getvar "DIMGAP") DimScale~)))
      (setq Assoc10@ (cons 10 (polar Assoc10@ pi (/ (* (getvar "DIMTXT") DimScale~) 2.0))))
      (setq Assoc50@ (cons 50 (* pi 0.5)))
      (setq Assoc71@ (cons 71 3))
      (setq Rotation -90)
    );case
  );cond
  (setvar "DIMTAD" 0)
  (setq EntLast^ (entlast))
  (if (>= (atoi (getvar "ACADVER")) 15)
    (command "LEADER" Pt1@ Pt2@ Pt@ "" "" "" "")
    (command "LEADER" Pt1@ Pt2@ Pt@ "" "" "")
  );if
  (entdel (entnext EntLast^))
  (if (setq SS& (ssget "L" '((0 . "MTEXT"))))
    (progn
      (setq EntMtext^ (ssname SS& 0))
      (setq EntList@ (entget EntMtext^))
      (setq EntList@ (entmod (subst Assoc10@ (assoc 10 EntList@) EntList@)));Insertion
      (setq EntList@ (entmod (subst Assoc50@ (assoc 50 EntList@) EntList@)));Angle
      (setq EntList@ (entmod (subst Assoc71@ (assoc 71 EntList@) EntList@)));Justification
      (entupd EntMtext^)
    );progn
  );if
  (if (= Rotation -90)
    (progn
      (setq Pt1@ (polar Pt2@ (+ (angle Pt2@ Pt1@) (* pi 0.5)) (distance Pt2@ Pt1@)))
      (setq Pt3@ (polar Pt2@ (+ (angle Pt2@ Pt3@) (* pi 0.5)) (distance Pt2@ Pt3@)))
    );progn
  );if
  (setq X1~ (car Pt1@))
  (setq X2~ (car Pt2@))
  (if (and (or  (< (angle Pt1@ Pt2@) (* pi 0.5))(> (angle Pt1@ Pt2@) (* pi 1.5)))
           (and (> (angle Pt2@ Pt3@) (* pi 0.5))(< (angle Pt2@ Pt3@) (* pi 1.5))))
    (setq Mirror t)
  );if
  (if (and (and (> (angle Pt1@ Pt2@) (* pi 0.5))(< (angle Pt1@ Pt2@) (* pi 1.5)))
           (or  (< (angle Pt2@ Pt3@) (* pi 0.5))(> (angle Pt2@ Pt3@) (* pi 1.5))))
    (setq Mirror t)
  );if
  (if (and (or  (= (angle Pt1@ Pt2@) (* pi 0.5))(= (angle Pt1@ Pt2@) (* pi 1.5)))
           (and (> (angle Pt2@ Pt3@) (* pi 0.5))(< (angle Pt2@ Pt3@) (* pi 1.5))))
    (setq Mirror t)
  );if
  (if Mirror
    (progn
      (if (< X2~ X1~)
        (setq Pt3@ (polar Pt2@ 0 (* (getvar "DIMASZ") DimScale~)))
        (setq Pt3@ (polar Pt2@ pi (* (getvar "DIMASZ") DimScale~)))
      );if
      (if (equal X2~ X1~ 0.000001)
        (setq Pt3@ (polar Pt2@ pi (* (getvar "DIMASZ") DimScale~)))
      );if
    );progn
    (progn
      (if (< X2~ X1~)
        (setq Pt3@ (polar Pt2@ pi (* (getvar "DIMASZ") DimScale~)))
        (setq Pt3@ (polar Pt2@ 0 (* (getvar "DIMASZ") DimScale~)))
      );if
      (if (equal X2~ X1~ 0.000001)
        (setq Pt3@ (polar Pt2@ 0 (* (getvar "DIMASZ") DimScale~)))
      );if
    );progn
  );if
  (setq EntLast^ (entlast))
  (entdel EntFirst^)
  (command "LEADER" Pt1@ Pt2@ Pt3@ "" "" "N")
  (if (entnext EntLast^)
    (progn
      (setq EntLeader^ (entnext EntLast^))
      (command "ROTATE" EntLeader^ "" Pt2@ Rotation)
    );progn
  );if
  (command "LAYER" "S" Clayer$ "")
  (setvar "DIMBLK" DimBlk$)
  (setvar "DIMTAD" DimTad#)
  (setvar "ORTHOMODE" OrthoMode#)
  (setvar "OSMODE" OsMode#)
  (princ)
);defun c:DL
;-------------------------------------------------------------------------------
(princ);End of DL.lsp

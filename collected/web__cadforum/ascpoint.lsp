; ASCPOINT.LSP  Copyright 1990-97 Tony Tanzillo  All Rights Reserved.
; 
;;    Author: Tony Tanzillo,
;;            Design Automation Consulting
;;            http://ourworld.compuserve.com/homepages/tonyt
;;            tony.tanzillo@worldnet.att.net
;;   Block and GPS extension by V.Michl, CAD Studio/ARKANCE, 2012/2013/2025:
;;            https://www.cadstudio.cz  https://arkance.world  https://www.cadforum.cz 
;;            
;;    Permission to use, copy, modify, and distribute this software
;;    for any purpose and without fee is hereby granted, provided
;;    that the above copyright notice appears in all copies and
;;    that both that copyright notice and the limited warranty and
;;    restricted rights notice below appear in all copies and all
;;    supporting documentation, and that there is no charge or fee
;;    charged in return for distribution or duplication.
;;
;;    This SOFTWARE and documentation are provided with RESTRICTED
;;    RIGHTS.
;;
;;    Use, duplication, or disclosure by the Government is subject
;;    to restrictions as set forth in subparagraph (c)(1)(ii) of
;;    the Rights in Technical Data and Computer Software clause at
;;    DFARS 252.227-7013 or subparagraphs (c)(1) and (2) of the
;;    Commercial Computer Software Restricted Rights at 48 CFR
;;    52.227-19, as applicable. The manufacturer of this SOFTWARE
;;    is Tony Tanzillo, Design Automation Consulting.
;;
;;    NO WARRANTY
;;
;;    ANY USE OF THIS SOFTWARE IS AT YOUR OWN RISK. THE SOFTWARE
;;    IS PROVIDED FOR USE "AS IS" AND WITHOUT WARRANTY OF ANY KIND.
;;    TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE AUTHOR
;;    DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT
;;    NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND
;;    FITNESS FOR A PARTICULAR PURPOSE, WITH REGARD TO THE SOFTWARE.
;;
;;    NO LIABILITY FOR CONSEQUENTIAL DAMAGES. TO THE MAXIMUM
;;    EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL
;;    THE AUTHOR OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL,
;;    INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER
;;    (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
;;    BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS
;;    INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF
;;    THE USE OF OR INABILITY TO USE THE SOFTWARE PRODUCT, EVEN
;;    IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
;;    DAMAGES.  BECAUSE SOME JURISDICTIONS DO NOT ALLOW EXCLUSION
;;    OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL
;;    DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.
;;
;
; ASCPOINT.LSP is a utility for use with AutoCAD Release 10 or later,
; which reads coordinate data from ASCII files in CDF or SDF format,
; and generates AutoCAD geometry from the imported coordinates.
;
; The ASCPOINT command will read coordinate data from an ASCII file,
; and generate either a continuous string of LINES, a POLYLINE, a
; 3DPOLYline, multiple copies of a selected group of objects, or
; AutoCAD POINT entities.
;
;  Format:
;
;    Command: ASCPOINT
;    File to read: MYFILE.TXT                           <- ASCII input file
;    Comma/Space delimited <Comma>: Comma               <- data format
;    Generate Copies/Lines/Nodes/3Dpoly/<Pline>: Nodes  <- entity to create
;    Process coordinates: 
;    Reading coordinate data...
;
; If you selected "Copies", then ASCPOINT will prompt you to select the
; objects that are to be copied.  The basepoint for all copies is the
; current UCS origin (0,0,0).  One copy of the selected objects will be
; created for each incoming coordinate, using each coordinate as the
; displacement relative to the origin.
;
; A comma-delimited (CDF) ascii file contains one coordinate per line,
; with each component seperated by a comma, like this:
;
;    2.333,4.23,8.0
;    -4.33,0.0,6.3
;    0.322,5.32,0.0,attribute1,attribute2
;    etc....
;
; There should be no spaces or blank lines in a CDF coordinate data file.
;
; A space-delimited (SDF) ascii file contains one coordinate per line,
; with each component seperated by one or more spaces, like this:
;
;    2.333  4.23   8.0
;   -4.33   0.0    6.3
;    0.322  5.32   0.0  attribute1 attribute2
;    ...
;
; Coordinate data can be 2D or 3D.
;
; Note that all numeric values must have at least one digit to the left
; and the right of the decimal point (values less than one must have a
; leading 0), and a leading minus sign indicates negative values.  This
; applys to both CDF and SDF formats.
;
; ASCPOINT can generate a continuous chain of LINE entities from your
; coordinate data, where each pair of adjacent lines share a coordinate
; from the file.
;
; ASCPOINT can also generate a polyline or 3DPOLYline from the coordinate
; data, where each point in the file becomes a vertice of the polyline.
; If the input file contains 3D coordinates, and you specify a polyline,
; then the Z component is ignored and the default of 0.0 is used.
;
; ASCPOINT will also COPY a selected group of objects, creating one copy
; for each incoming coordinate, and using the coordinate as the absolute
; copy displacement from the CURRENT UCS origin (0,0,0).
;
; Finally, ASCPOINT will generate AutoCAD POINT entities from the data in
; the file.  Specify the point size and type prior to invoking ASCPOINT.
;
; Writing POINT coordinates to file:
;
; The WPOINT command also included in this file, will export the
; coordinates of selected POINT entities to a comma-delimited CSV
; file that can be read into Excel, and imported using ASCPOINT.
;
; Good luck,
;
; Tony Tanzillo

(defun C:ASCPOINT ( / f bm hi os cmde format input line plist ss makepoint blname pt i oldatt cproc coordproc)
   (cond (  (not (setq f (getfiled "Import ASCII Coordinate Data"
                                   "" "" 0))))
         (  (not (setq f (open f "r")))
            (princ "\nCan't open file for input."))
         (t (initget "Space Comma Semicolon")
            (setq format
              (cond ((getkword "\n[Comma/Space/Semicolon] delimited <Comma>: "))
                    (t "Comma")))
            (initget "Copies Inserts Lines Nodes 3Dpoly Pline")
            (setq input
              (cdr (assoc
                (cond
                   (  (getkword
                         "\nGenerate [Copies/Inserts/Lines/Nodes/3Dpoly/Pline] <Pline>: "))
                   (t "Pline"))
                  '(("Lines"   . "._LINE")
                    ("Copies"  . "._COPY")
                    ("Inserts"  . "._-INSERT")
                    ("Nodes"   . "._POINT")
                    ("3Dpoly"  . "._3DPOLY")
                    ("Pline"   . "._PLINE"))))
            )
			(setq cproc T  coordproc '("None"))
			(while cproc
			 (initget "None Offset nEgative swapXy Coord1st Gps") ; new 7/2025
			 (setq cproc (getkword (strcat "\nProcess coordinates [None/Offset/nEgative/swapXy/Coord1st/Gps] (" (lst->str coordproc ",") ") <apply>: "))) ; MULTIPLE!
			 (cond
			  ((= cproc "None")(setq coordproc '("None")))
			  (T (if (member cproc coordproc)(setq coordproc (vl-remove cproc coordproc))(setq coordproc (append coordproc (list cproc))))
				 (setq coordproc (vl-remove "None" coordproc)))
			 )
			)
;start
            (setq read-point
               (if (eq format "Comma") cdf sdf) ; disabled
            )
            (setq makepoint 
               anypoint ; (if (eq input "._PLINE") 2dpoint (if (eq input "._-INSERT") anypoint 3Dpoint)) ; VM disabled
            )
			(setq cmde (getvar "cmdecho"))
            (setvar "cmdecho" 0)
            (command "._UNDO" "_Begin")
            (setq bm (getvar "blipmode"))
            (setq hi (getvar "highlight"))
            (setvar "blipmode" 0)
            (setq os (getvar "osmode"))
            (setvar "osmode" 0)
            (princ "\nReading coordinate data...")
            (while (setq line (read-line f))
                (cond 
                    (  (and (setq line (strtrim line))
                            (/= line "")
							(/= (ascii line) 59) ; ";"
;                            (setq line (makepoint (read-point line)))) ; changed VM 1/2013
                            (setq line (makepoint (sparser line (if (eq format "Comma") "," (if (eq format "Semicolon") ";" " ")))))) ; ("X" "Y" "Z" "attr")
                      (setq plist (cons line plist))))) ; while
            (close f)
            (setq plist (reverse plist))
;(PRINT PLIST) ; may be strings
			(setq plist (processcoords plist coordproc))
;(PRINT PLIST) ; must be reals
            (cond (  (eq input "._POINT")
                     (setvar "highlight" 0)
                     (command "._POINT" "0,0,0"
                              "._COPY" (setq ss (entlast)) "" "_m" "0,0,0")
                     ;(apply 'command plist)
;					 (mapcar '(lambda(x)(princ " moving to ")(princ x)) plist)
					 (mapcar '(lambda(x)(command (list (car x)(cadr x)(caddr x)))) plist)
                     (command)
                     (entdel ss))
                     
                  (  (eq input "._COPY")
                     (princ "\nSelect objects to copy (relatively): ")
                     (while (not (setq ss (ssget)))
                            (princ "\nNo objects selected,")
                            (princ " select objects to copy: "))
                     (setvar "HIGHLIGHT" 0)
                     (command "._COPY" ss "" "_m" "0,0,0")
                     ;(apply 'command plist)
					 (mapcar '(lambda(x)(command (list (car x)(cadr x)(caddr x)))) plist)
                     (command))

				  (  (eq input "._-INSERT")
					 (setq ss (entsel "\nSelect the block to insert (may have attributes) <name it>: "))
					 (if ss (progn
							 (setq blname (cdr (assoc 2 (entget (car ss)))))
							 (princ blname)
							);else
							(setq blname (getstring T "\nBlock name: "))
					 )
					 (if blname (progn
						(setq oldatt (getvar "ATTDIA"))(setvar "ATTDIA" 0)
						(foreach pt plist
;						 (command "._-INSERT" blname (3dpoint pt) 1 0) ; or older INSERTs: ) 1 1 0)
						 (command "._-INSERT" blname "_Sca" 1 (list (car pt)(cadr pt)(caddr pt)) 0) ; scale, point, rot
;						 (setq i 3)(while (> (getvar "CMDACTIVE") 0)(command (toSym (nth i pt)))(setq i (1+ i))) ; attributes changed VM 1/2013
						 (setq i 3)(while (> (getvar "CMDACTIVE") 0)(if (nth i pt)(command (nth i pt))(command ""))(setq i (1+ i))) ;  any No. of attributes 8/2013
						)
						(setvar "ATTDIA" oldatt)
					 ));if
                     )

                  (  (eq input "._PLINE")
					 (command input)
					 (mapcar '(lambda(x)(command (list (car x)(cadr x)))) plist)
					 (command)
				  )

                  (t (command input)
                     ;(apply 'command plist)
					 (mapcar '(lambda(x)(command (list (car x)(cadr x)(caddr x)))) plist)
                     (command)))

			(princ (strcat "\nImported " (itoa (length plist)) " coordinates."))
            (command "._UNDO" "_en")
			(setvar "cmdecho" cmde)
            (setvar "highlight" hi)
            (setvar "osmode" os)
            (setvar "blipmode" bm)))
   (princ)
)

(defun lst->str ( lst del / str )
    (setq str (car lst))
    (foreach itm (cdr lst) (setq str (strcat str del itm)))
    (if str str "")
)

(defun sparser (str delim / ptr lst) ; string parser - VM 1/2013
(while (setq ptr (vl-string-search delim str))
(setq lst (cons (substr str 1 ptr) lst))
(setq str (substr str (+ ptr 2)))
)
(reverse (cons str lst))
)

(defun processcoords (points mode / pt pts offX offY offC cmde txte gpt gpts i) ; new 7/2025
 (defun offs (pt / pto i)
  (setq pto (mapcar '+ pt (list offX offY)))
  (setq i 2)(while (nth i pt)(setq pto (append pto (list (nth i pt)))  i (1+ i))) ; corr atts
  pto
 )
 (defun neg (pt / pto i)
  (setq pto (mapcar '* pt (list -1 -1)))
  (setq i 2)(while (nth i pt)(setq pto (append pto (list (nth i pt)))  i (1+ i))) ; corr atts
  pto
 )
 (defun swp (pt / pto i)
  (setq pto (list (cadr pt) (car pt)))
  (setq i 2)(while (nth i pt)(setq pto (append pto (list (nth i pt)))  i (1+ i))) ; corr atts
  pto
 )
 (defun swpC (pt / pto i) ; NumPt X Y --> X Y NumPt
  (setq pto (list))
  (setq i (1- offC))(while (nth i pt)(setq pto (append pto (list (nth i pt))) i (1+ i))) ; corr atts
  (setq i 0)(while (< i (1- offC))(setq pto (append pto (list (nth i pt))) i (1+ i))) ; corr atts
  pto
 )
 (defun cnv (pt / pto i) ; "12.3" --> 12.3; always 3D
  (setq pto (list))
  (setq pto (append pto (list (if (= (type (car pt)) 'STR)(read (car pt))(car pt))))) ; X
  (setq pto (append pto (list (if (= (type (cadr pt)) 'STR)(read (cadr pt))(cadr pt))))) ; Y
  (setq pto (append pto (list (if (caddr pt)
									(if (= (type (caddr pt)) 'STR)(read (caddr pt))(caddr pt))
									0.0)))) ; Z
  (setq i (length pto))(while (nth i pt)(setq pto (append pto (list (nth i pt))) i (1+ i))) ; corr atts
  pto
 )

; coords may be strings
  (setq pts points) ; NOP ; else
; None Offset nEgative swapXy Gps
  (if (member "Coord1st" mode)(progn
    (initget 6)
    (setq offC (getint "\nXY coords start at column (move skipped to end) <1>: "))
	(if (not offC)(setq offC 1))
    (setq pts (mapcar 'swpC pts))
  ))
  ; now XYZ should be reals
  (setq pts (mapcar 'cnv pts)) ; normalize !
;(PRINT pts)
  (if (member "swapXy" mode)(setq pts (mapcar 'swp pts)))
  (if (member "Offset" mode)(progn
    (setq offX (getdist "\nSpecify X-offset <0>: ")) (if (not offX)(setq offX 0))
    (setq offY (getdist "\nSpecify Y-offset <0>: ")) (if (not offY)(setq offY 0))
    (setq pts (mapcar 'offs pts))
  ))
  (if (member "nEgative" mode)(setq pts (mapcar 'neg pts)))
  (if (member "Gps" mode)(progn
		 (if (and (not ade_projptforward)(= (getvar "CGEOCS") ""))
			(progn (princ "\nFirst use _GEOGRAPHICLOCATION to set location (e.g. WGS84)! ")(vlr-beep-reaction)(exit)))
		 (setq txte (getvar "TEXTEVAL"))
		 (setvar "TEXTEVAL" 0)
		 (setq gpts (list))
		 (foreach pt pts
		  (initcommandversion 1)
		  (command "_geomarklatlong" (car pt) (cadr pt) "PT")
		  (if (= (cdr (assoc 0 (entget (entlast)))) "POSITIONMARKER")(progn
		  	(setq gpt (cdr (assoc 10 (entget (entlast)))))
			(setq gpt (list (car gpt)(cadr gpt))) ; 2D
			(setq i 2)(while (nth i pt)(setq gpt (append gpt (list (nth i pt)))  i (1+ i))) ; corr atts
			(entdel (entlast)) ;!!!!
		  );else
		  (progn
			(setq gpt (list (car pt)(cadr pt))) ; 2D
			(setq i 2)(while (nth i pt)(setq gpt (append gpt (list (nth i pt)))  i (1+ i))) ; corr atts
		  )
		  );if
		  (setq gpts (cons gpt gpts))
		 );for
		 (setq pts (reverse gpts))
		 (setvar "TEXTEVAL" txte)
  ))
;(PRINT pts)
 pts
) ; processcoords

(defun cdf (l / s)
;  (command "._LASTPOINT" l)
;  (getvar "lastpoint")
; VM:
 (setq s (vl-string-translate "," " " l)); maybe also ";"
 (read (strcat "(" s ")"))
)

(defun sdf (l)
   (read (strcat "(" l ")"))
)

(defun 3dpoint (p / p0) 
   (setq p0 (list (car p) (cadr p) (cond ((caddr p)) (t "0.0"))))
   (mapcar 'read p0)
)

(defun 2dpoint (p / p0)
   (setq p0 (list (car p) (cadr p)))
   (mapcar 'read p0)
)

(defun anypoint (p)
 p
)

(defun toSym (s) ; VM
 (if (eq (type s) 'SYM)
  (vl-symbol-name s)
  (if s s "")
 )
)

(defun noz (p)
   (list (car p) (cadr p))
)

;; ================================================================
;; (Strtrim <string>)
;; 
;; Trims leading and trailing spaces from <string>

(defun strtrim (s)
   (Strltrim (Strrtrim s))
)

;; ================================================================
;; (StrLtrim <string>)
;; 
;; Trims leading spaces from <string>

(defun Strltrim (s / l)
   (if (wcmatch s " *")
      (progn 
         (setq l (1+ (strlen s)) i 1)
         (while 
            (and (eq (substr s i 1) " ")
                 (/= l i))
            (setq i (1+ i))
         )
         (substr s i)
      )
      s
   )
)

;; ================================================================
;; (StrRtrim <string>)
;; 
;; Trims trailing spaces from <string>

(defun Strrtrim (s / i)
   (if (wcmatch s "* ")
      (progn
         (setq i (strlen s))
         (while 
            (and (> i 0)
                 (eq (substr s i 1) " "))
            (setq i (1- i))
         )
         (substr s 1 i)
      )
      s
   )
)

(defun C:WPOINT ( / ss fd file)
   (cond
      (  (not (setq ss (ssget '((0 . "POINT"))))))
      (  (not (setq file (getfiled "Export Points" "" "csv" 1))))
      (  (not (setq fd (open file "w")))
         (alert "Unable to open file for output"))
      (t (repeat (setq i (sslength ss))
            (write-point
               (ssname ss (setq i (1- i)))
               fd
               6
            )
         )
         (close fd)
      )
   )
   (princ)
)        


(defun write-point (e fd prec / p)
  (setq p (cdr (assoc 10 (entget e))))
  (write-line
     (strcat (rtos (car p) 2 prec) ","
             (rtos (cadr p) 2 prec) ","
             (rtos (caddr p) 2 prec)
     )
     fd
  )
)



(princ "\nASCPOINT.LSP (C)1990-1997 Tony Tanzillo, mods by ARKANCE/CAD Studio")
(princ "\nUse ASCPOINT to import coordinates.")
(princ "\nUse WPOINT to export POINT coordinates.")
(princ)

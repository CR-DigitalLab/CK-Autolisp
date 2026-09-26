; written by Anil Gupte, (AutoCAD/AutoLISP Consultant)
; Compuserve ID 72537,3660
; May 5, 1989
; donated to the Public Domain
; this and "other fine programs" also available on 
; ARCHINFO (414) 276-3013, 300/1200/2400 N-8-1
;
; draws an "infinite" Horizontal or Vertical line 
; i.e. to the drawing extents.  If you have added "stuff"
; beyond the previuos extents, you may need a "REGEN" or "ZOOM E"
; for the drawing extents to be updated *before* you use this routine
;
; In reply to "Horizontal/<Vertical> ?: " you may type "H" for
; Horizontal or just press enter for Vertical

(defun C:INFINIT()
     (command "LAYER" "M" "$CONSTRUCTION" "")
     (initget 1)
     (setq pt (getpoint "\nPick a point passing thru the line : "))
     (initget "Horizontal Vertical")
     (if (= (getkword "\nHorizontal/<Vertical> ?: ") "Horizontal")
         (setq p1 (list (car (getvar "EXTMAX")) (cadr pt))
               p2 (list (car (getvar "EXTMIN")) (cadr pt)))
         (setq p1 (list (car pt) (cadr (getvar "EXTMAX")))
               p2 (list (car pt) (cadr (getvar "EXTMIN"))))
     )
     (command ".LINE" p1 p2 "")
(prin1)
)


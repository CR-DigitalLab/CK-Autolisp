; FILE NAME: RAFTERS.LSP
; Written by: Bob Thomas                
;             Thomas Enterprises, ltd.  
;             1030 "B" Street, Suite 201
;             San Rafael, CA 94901   
;             415/453-8712
;
; This file and its accompanying drawing file, RAFTERS.DWG, may be freely 
; copied provided that the two files remain together and this header remains
; intact, so that people know what the program does and I can get a free 
; plug in. Thank you.  Use and enjoy...
;
; This file contains two parametric programs that create a rafter and a
; roof truss (double rafter). All variables are local except those used to 
; set and retain defaults, as follows:
;
; In RAFTER:                              In RTRUSS:
; rw   = default rafter width             rw    = default rafter width             
; rh   = default rafter height            rh    = default rafter height            
; rise = default rise                     rise1 = default upper rise
; run  = default run                      run1  = default upper run
; sth  = default seat height              rise2 = default lower rise
; oh   = default overhang                 run2  = default lower run
;                                         oh    = default overhang
; AutoCAD Commands:
;
; RAFTER - Creates rafters
;
;    Command Prompt Sequence:
;
;     Rafter width:
;     Height:
;     Rise:
;     Run:
;     Seat height:
;     Overhang length:
;     Freeze blocking? <Y>
;     Mirrored? <Y>
;     Starting point:
;     Ending point:
;
;
; RTRUSS - Creates truss rafter
;
;    Command Prompt Sequence:
;
;     Component width:
;     Component height:
;     Top cord rise:
;     Top cord run:
;     Bottom cord rise:
;     Bottom cord run <" (rtos run2) ">: ")))
;     Overhang length:
;     Freeze blocking? <Y>
;     Mirrored? <Y>
;     Starting point:
;     Ending point:
;
;
;
; Respond to prompts with the appropriate value. Refer to accompanying
; AutoCAD drawing file, RAFTERS.DWG, for a diagram illustrating the meaning
; of the various options.
;
; PROGRAM:
;
(prompt "\nLoading RAFTERS.LSP...")

; Pythagorean Theorem

(defun pyth(x y) (sqrt (+ (expt x 2.0) (expt y 2.0))))

; Acute angle (in radians) from hypotenuse and adjacent side. 

(defun ahas(h s)
   (if (> h s) (- 1.5707955 (angle '(0 0) (list (sqrt (-
                    (+ 100 (expt (* (/ (float s) (float h)) 10) 2))
                    (* (* (* (/ (float s) (float h)) 100) 2) 
                       (/ (float s) (float h)))))
              (* (/ (float s) (float h)) 10))))))

; Length of adjacent side from angle and opposite side. 

(defun asos(s a) (/ s (/ (cadr (polar '(0 0) a 1)) (car (polar '(0 0) a 1)))))

; standard rafter

(defun C:RAFTER( / oldblp cmdech oldort xrh xrw xrise xrun xsth xoh sp ep bp1 
                   bp2 bp3 bp4 bp5 tp1 tp2 ohep1 ohep2 ang m_opt ss1 b_opt
                   rafter)
   (if (= rw nil) (setq rw 2))
   (if (= rh nil) (setq rh 12))
   (if (= rise nil) (setq rise 6))
   (if (= run nil) (setq run 12))
   (if (= sth nil) (setq sth 1))
   (if (= oh nil) (setq oh 24))
   (setq oldblp (getvar "BLIPMODE") cmdech (getvar "CMDECHO")
         oldort (getvar "ORTHOMODE") rafter "Rafter "
         xrh rh xrw rw xsth sth xoh oh xrise rise xrun run)
   (setvar "BLIPMODE" 0)
   (setvar "CMDECHO" 0)

; enter rafter width:

   (setq xrw (getdist (strcat "\n" rafter "width <" (rtos rw) ">: ")))
   (if (or (= xrw nil) (= xrw "")) (eval nil) (setq rw xrw))

; enter rafter height

   (setq xrh (getdist (strcat "\nHeight <" (rtos rh) ">: ")))
   (if (or (= xrh nil) (= xrh "")) (eval nil) (setq rh xrh))

; enter rise

   (setq xrise (getdist (strcat "\nRise <" (rtos rise) ">: ")))
   (if (or (= xrise nil) (= xrise "")) (eval nil) (setq rise xrise))

; enter run

   (setq xrun (getdist (strcat "\nRun <" (rtos run) ">: ")))
   (if (or (= xrun nil) (= xrun "")) (eval nil) (setq run xrun))

; enter height of seat

   (setq xsth (getdist (strcat "\nSeat height <" (rtos sth) ">: ")))
   (if (or (= xsth nil) (= xsth "")) (eval nil) (setq sth xsth))

; enter overhang length

   (setq xoh (getdist (strcat "\nOverhang length <" (rtos oh) ">: ")))
   (if (or (= xoh nil) (= xoh "")) (eval nil) (setq oh xoh))

; prompt for blocking option:

  (while (and (not (equal b_opt "N")) (not (equal b_opt "Y")))
    (setq b_opt (substr (strcase (getstring "\nFreeze blocking? <Y>: ")) 1 1))
          (if (or (equal b_opt nil) (equal b_opt "")) (setq b_opt "Y")))

; prompt for mirror option:

   (while (and (not (equal m_opt "N")) (not (equal m_opt "Y")))
          (setq m_opt (substr (strcase (getstring "\nMirrored? <Y>: ")) 1 1))
          (if (or (equal m_opt nil) (equal m_opt "")) (setq m_opt "Y")))

; enter baseline:

   (setq sp '(0 0) ep '(0 1))
   (setvar "ORTHOMODE" 1)
   (while (/= (cadr sp) (cadr ep))
     (setq sp (getpoint "\n<ortho on>\nStarting point: "))
     (setq ep (getpoint sp "\nEnding point: "))
     (if (/= (cadr sp) (cadr ep))
         (progn (prompt "\nError: Line must be horizontal. <ortho on>")
                (setvar "ORTHOMODE" 1))
         (setvar "ORTHOMODE" 0)))
   (setq ang (ahas (pyth (float rise) (float run)) (float run)))
   (if (= (angle sp ep) pi) (setq ang (- pi ang)))
   (setq tp2 (polar ep 1.5707955 1)
         bp1 (polar sp (angle sp ep) (* 2 sth))
         tp1 (polar bp1 ang 1)
         bp2 (polar sp 4.71239 sth))
   (if (= (angle sp ep) pi)
       (setq bp3 (polar bp2 (- ang 1.5707955) rh)
             bp4 (polar bp2 (- ang pi) rw)
             bp5 (polar bp4 (- ang 1.5707955) rh)
             ohep1 (polar bp2 (- ang pi) oh)
             ohep2 (polar ohep1 1.5707955
                          (pyth (asos rh (- 1.5707955 ang)) rh)))
       (setq bp3 (polar bp2 (+ ang 1.5707955) rh)
             bp4 (polar bp2 (+ ang pi) rw)
             bp5 (polar bp4 (+ ang 1.5707955) rh)
             ohep1 (polar bp2 (+ ang pi) oh)
             ohep2 (polar ohep1 1.5707955
                          (pyth (asos rh (- 1.5707955 ang)) rh))))
   (command "pline" ohep1 "w" 0 0 bp2 sp bp1 (inters bp1 tp1 ep tp2 nil) "")
   (setq ss1 (ssadd (entlast)))
   (command "line" ohep2 (inters ohep2 bp3 ep tp2 nil) "")
   (setq ss1 (ssadd (entlast) ss1))
   (if (= b_opt "Y")
       (progn (command "pline" bp2 bp3 bp4 bp5 "c")
              (setq ss1 (ssadd (entlast) ss1))))
    (if (= m_opt "Y") (command "mirror" ss1 "" ep tp2 "N"))
    (setvar "BLIPMODE" oldblp)
    (setvar "CMDECHO" cmdech)
    (setvar "ORTHOMODE" oldort)
    (prompt "\nRafter complete.")
    (princ)
) ; end defun RAFTER

; double-cord rafter

(defun C:RTRUSS( / oldblp cmdech oldort xrh xrw xrise1 xrun1 xrise2 xrun2 xoh
                   sp ep bp1 bp2 bp3 bp4 bp5 tp1 tp2 ohep1 ohep2 ang1 ang2
                   m_opt ss1 b_opt)
   (if (= rw nil) (setq rw 2))
   (if (= rh nil) (setq rh 4))
   (if (= rise1 nil) (setq rise1 6))
   (if (= run1 nil) (setq run1 12))
   (if (= rise2 nil) (setq rise2 0))
   (if (= run2 nil) (setq run2 0))
   (if (= oh nil) (setq oh 24))
   (setq oldblp (getvar "BLIPMODE")
         cmdech (getvar "CMDECHO")
         oldort (getvar "ORTHOMODE")
         xrh rh xrw rw xsth sth xoh oh xrise rise xrun run)
   (setvar "BLIPMODE" 0)
   (setvar "CMDECHO" 0)

; enter rafter width:

   (setq xrw (getdist (strcat "\nComponent width <" (rtos rw) ">: ")))
   (if (or (= xrw nil) (= xrw "")) (eval nil) (setq rw xrw))

; enter rafter height

   (setq xrh (getdist (strcat "\nComponent height <" (rtos rh) ">: ")))
   (if (or (= xrh nil) (= xrh "")) (eval nil) (setq rh xrh))

; enter top rise

   (setq xrise1 (getdist (strcat "\nTop cord rise <" (rtos rise1) ">: ")))
   (if (or (= xrise1 nil) (= xrise1 "")) (eval nil) (setq rise1 xrise1))

; enter top run

   (setq xrun1 (getdist (strcat "\nTop cord run <" (rtos run1) ">: ")))
   (if (or (= xrun1 nil) (= xrun1 "")) (eval nil) (setq run1 xrun1))

; enter bottom rise

   (setq xrise2 (getdist (strcat "\nBottom cord rise <" (rtos rise2) ">: ")))
   (if (or (= xrise2 nil) (= xrise2 "")) (eval nil) (setq rise2 xrise2))

; enter bottom run

   (setq xrun2 (getdist (strcat "\nBottom cord run <" (rtos run2) ">: ")))
   (if (or (= xrun2 nil) (= xrun2 "")) (eval nil) (setq run2 xrun2))

; enter overhang length

   (setq xoh (getdist (strcat "\nOverhang length <" (rtos oh) ">: ")))
   (if (or (= xoh nil) (= xoh "")) (eval nil) (setq oh xoh))

; prompt for blocking option:

   (while (and (not (equal b_opt "N")) (not (equal b_opt "Y")))
    (setq b_opt (substr (strcase (getstring "\nFreeze blocking? <Y>: ")) 1 1))
          (if (or (equal b_opt nil) (equal b_opt "")) (setq b_opt "Y")))

; prompt for mirror option:

   (while (and (not (equal m_opt "N")) (not (equal m_opt "Y")))
          (setq m_opt (substr (strcase (getstring "\nMirrored? <Y>: ")) 1 1))
          (if (or (equal m_opt nil) (equal m_opt "")) (setq m_opt "Y")))

; enter baseline:

   (setq sp '(0 0) ep '(0 1))
   (setvar "ORTHOMODE" 1)
   (while (/= (cadr sp) (cadr ep))
     (setq sp (getpoint "\nStarting point: "))
     (setq ep (getpoint sp "\nEnding point: "))
     (if (/= (cadr sp) (cadr ep))
         (progn (prompt "\nError: Line must be horizontal. <ortho on>")
                (setvar "ORTHOMODE" 1))
         (setvar "ORTHOMODE" 0)))
   (setq ang1 (ahas (pyth (float rise1) (float run1)) (float run1)))
   (if (and (/= rise2 0) (/= run2 0))
       (setq ang2 (ahas (pyth (float rise2) (float run2)) (float run2)))
       (setq ang2 0))
   (if (= (angle sp ep) pi) (setq ang1 (- pi ang1) ang2 (- pi ang2)))
   (setq tp1 (polar ep 1.5707955 1)
         bp1 (polar sp ang2 1)
         bp4 (polar sp ang1 1)
         bp6 (polar sp (+ ang1 pi) rw)
         ohep1 (polar sp (+ ang1 pi) oh))
   (if (= (angle sp ep) 0)
       (setq bp2 (polar bp1 (+ ang2 1.5707955) rh)
             bp3 (polar bp2 ang2 1)
             bp5 (polar sp (+ ang1 1.5707955) rh)
             bp7 (polar bp6 (+ ang1 1.5707955) rh)
             ohep2 (polar ohep1 1.5707955
                          (pyth (asos rh (- 1.5707955 ang1)) rh)))
       (setq bp2 (polar bp1 (- ang2 1.5707955) rh)
             bp3 (polar bp2 ang2 1)
             bp5 (polar sp (- ang1 1.5707955) rh)
             bp7 (polar bp6 (- ang1 1.5707955) rh)
             ohep2 (polar ohep1 1.5707955
                          (pyth (asos rh (- 1.5707955 ang1)) rh))))
   (command "pline" ohep1 "w" 0 0 sp (inters sp bp1 ep tp1 nil) "")
   (setq ss1 (ssadd (entlast)))
   (command "pline" (inters bp2 bp3 ep tp1 nil) (inters bp2 bp3 sp bp4 nil)
                    (inters ep tp1 sp bp4 nil) "")
   (setq ss1 (ssadd (entlast) ss1))
   (command "pline" ohep2 (inters ohep2 bp5 ep tp1 nil) "")
   (setq ss1 (ssadd (entlast) ss1))
   (if (= b_opt "Y") (progn (command "pline" sp bp5 bp6 bp7 "c")
                            (setq ss1 (ssadd (entlast) ss1))))
  (if (= m_opt "Y") (command "mirror" ss1 "" ep tp1 "N"))
   (setvar "BLIPMODE" oldblp)
  (setvar "CMDECHO" cmdech)
  (setvar "ORTHOMODE" oldort)
  (prompt "\nRafter complete.")
  (princ)
) ; end defun RTRUSS
(prompt "loaded.")
(princ)
; EOF RAFTERS.LSP   308 lines   Bob Thomas

; FILE NAME: TRUSS.LSP
; Written by: Bob Thomas                
;             Thomas Enterprises, ltd.  
;             1030 "B" Street, Suite 201
;             San Rafael, CA 94901   
;             415/453-8712
;
; This file and its accompanying drawing file, TRUSS.DWG, may be freely 
; copied provided that the two files remain together and this header remains
; intact, so that people know what the program does and I can get a free 
; plug in. Thank you.  Use and enjoy...
;
; This file contains a parametric program that creates elevation drawings of 
; floor trusses. All variables are local except those used to carry defaults,
; as follows:
;
; th = default truss height
; cw = default component width
; ch = default component height
; ws = default web spacing
;
;
; AutoCAD Command:
; TRUSS - Create floor truss
; 
; Command Prompt Sequence:
;
;    Truss height:
;    Component Width:
;    Component Height:
;    Webbed? <Y>:
;      Web Spacing:
;
; Respond to prompts with the appropriate value. Refer to accompanying
; AutoCAD drawing file, TRUSS.DWG, for a diagram illustrating the meaning
; of the various options.
;
; PROGRAM:
;
(prompt "\nLoading TRUSS.LSP...")

; webfinishing functions:

(defun sfin()
    (if (= cycle 1)
        (progn (setq fp1 (polar iop2 (- (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp2 (polar ip1 (- (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp3 (polar iop2 (+ (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp4 (polar ip1 (+ (angle iop2 ip1) 1.57079) (/ ws 2.0)))
              (command "line" (inters fp3 fp4 iop1 iop2 nil)
                              (inters fp3 fp4 cp1 cp2 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp1 fp2 cp3 cp4 nil)
                              (inters fp1 fp2 ip1 ip2 nil) "")
              (setq ss1 (ssadd (entlast) ss1)))
        (progn (setq fp1 (polar tp1 (- (angle tp1 ip2) 1.57079) (/ ws 2.0))
                    fp2 (polar ip2 (- (angle tp1 ip2) 1.57079) (/ ws 2.0))
                    fp3 (polar tp1 (+ (angle tp1 ip2) 1.57079) (/ ws 2.0))
                    fp4 (polar ip2 (+ (angle tp1 ip2) 1.57079) (/ ws 2.0)))
              (command "line" (inters fp3 fp4 cp1 cp2 nil)
                              (inters fp3 fp4 ip1 ip2 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp1 fp2 tp1 tp2 nil)
                              (inters fp1 fp2 cp3 cp4 nil) "")
              (setq ss1 (ssadd (entlast) ss1)))))
(defun cfin()
    (if (= cycle 1)
        (progn (setq fp1 (polar iop2 (- (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp2 (polar ip1 (- (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp3 (polar iop2 (+ (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp4 (polar ip1 (+ (angle iop2 ip1) 1.57079) (/ ws 2.0))
                    fp5 (inters (inters op3 op4 fp3 fp4 nil) 
                                (polar (inters op3 op4 fp3 fp4 nil)
                                       1.57079 ws ) cp3 cp4 nil))
              (command erase oss3 oss2 ""
                       "line"  (inters op3 op4 cp1 cp2 nil)
                               (inters op3 op4 fp3 fp4 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command  "line" (inters op3 op4 fp3 fp4 nil) fp5 "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp3 fp4 op3 op4 nil)
                              (inters fp3 fp4 cp1 cp2 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp1 fp2 cp3 cp4 nil)
                              (inters fp1 fp2 ip1 ip2 nil) "")
              (setq ss1 (ssadd (entlast) ss1)))
        (progn (setq fp1 (polar tp1 (- (angle tp1 ip2) 1.57079) (/ ws 2.0))
                     fp2 (polar ip2 (- (angle tp1 ip2) 1.57079) (/ ws 2.0))
                     fp3 (polar tp1 (+ (angle tp1 ip2) 1.57079) (/ ws 2.0))
                     fp4 (polar ip2 (+ (angle tp1 ip2) 1.57079) (/ ws 2.0))
                     fp5 (inters (inters op1 op2 fp1 fp2 nil) 
                                (polar (inters op1 op2 fp1 fp2 nil)
                                       4.71239 ws ) cp1 cp2 nil))
              (command erase oss1 oss2 ""
                       "line"  (inters op1 op2 cp3 cp4 nil)
                               (inters op1 op2 fp1 fp2 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters op1 op2 fp1 fp2 nil) fp5 "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp1 fp2 op1 op2 nil)
                              (inters fp1 fp2 cp3 cp4 nil) "")
              (setq ss1 (ssadd (entlast) ss1))
              (command "line" (inters fp3 fp4 cp1 cp2 nil)
                              (inters fp3 fp4 ip1 ip2 nil) "")
              (setq ss1 (ssadd (entlast) ss1)))))

(defun C:TRUSS ( / oldblp cmdech oldort olderr usp xth xcw xch xws ss1 ip1 ip2 
                   iop1 iop2 w_opt cycle tp1 tp2 ih cp1 cp2 cp3 cp4 sp ep 
                   fp1 fp2 fp3 fp4 fp5 oss1 oss2 oss3 line erase lp bm om ce)
   (if (not cw) (setq cw 2))
   (if (not ch) (setq ch 4))
   (if (not th) (setq th 24))
   (setq bm "BLIPMODE" om "ORTHOMODE" ce "CMDECHO" lp "LASTPOINT" line "LINE" 
         erase "ERASE" ss1 (ssadd) olderr *error* xth th xcw cw xch ch xws ws 
         oldort (getvar om) oldblp (getvar bm) cmdech (getvar ce)
   )
   (defun *error* (msg)
           (terpri) (princ msg)
           (setvar ce oldcmd) (setvar bm oldblp) (setvar om oldort)
           (setq *error* olderr) (princ))
   (setvar bm 0) (setvar ce 0)

; enter truss height

   (setq xth (getdist (strcat "\nTruss height <" (rtos th) ">: ")))
   (if (not xth) (eval nil) (setq th xth))

; enter width:

   (setq xcw (getdist (strcat "\nComponent width <" (rtos cw) ">: ")))
   (if (not xcw) (eval nil) (setq cw xcw))

; enter height:

   (setq xch (getdist (strcat "\nComponent height <" (rtos ch) ">: ")))
   (if (not xch) (eval nil) (setq ch xch))

; prompt for webbed option:

   (if (not ws) (setq ws ch))
   (while (and (not (equal w_opt "N")) (not (equal w_opt "Y")))
          (setq w_opt (substr (strcase 
                   (getstring "\nWebbed? <Y>: ")) 1 1))
          (if (or (not w_opt) (equal w_opt "")) (setq w_opt "Y")))
   (if (equal w_opt "Y") (progn
       (setq xws (getdist (strcat "\nWeb spacing <" (rtos ws) ">: ")))
       (if (not xws) (eval nil) (setq ws xws))))

; enter baseline:

   (setq sp (getpoint "\nStarting point: ")) (setvar om 1)
   (setq ep (getpoint sp "\nEnding point: ")) (setvar om 0)


; draw rectangular offset lines:

   (command "pline" sp ep (polar ep 1.57079 th)
     (setq usp (polar (getvar lp) (angle ep sp) (distance sp ep))) "c")
   (command line (setq cp1 (polar sp 1.57079 cw))
                   (setq cp2 (polar ep 1.57079 cw)) "")
   (command line (setq ip (polar (polar sp (angle sp ep) cw) 1.57079 cw))
                   (polar (getvar lp) 1.57079 (- th cw)) "")
   (setq ss1 (ssadd (entlast) ss1))
   (command line (setq ip1 (polar ip (angle sp ep) cw))
     (setq ip2 (polar (getvar lp) 1.57079 (- th (* cw 2.0)))) "")
   (setq ss1 (ssadd (entlast) ss1))
   (command line (polar sp 1.57079 (- th ch))
            (polar (getvar lp) (angle sp ep) cw) "")
   (setq ss1 (ssadd (entlast) ss1))
   (command line (getvar lp) usp "")
   (setq ss1 (ssadd (entlast) ss1))
   (command line (polar sp 1.57079 (- th ch)) (polar usp (angle sp ep) cw) "")
   (setq ss1 (ssadd (entlast) ss1))
   (command line (setq cp3 (polar (polar sp 1.57079 (- th cw))(angle sp ep)cw))
     (setq cp4 (polar (getvar lp) (angle sp ep)(- (distance sp ep)(* cw 2))))"")
   (command "mirror" ss1 "" (polar sp (angle sp ep) (/ (distance sp ep) 2))
     (polar (polar sp (angle sp ep) (/ (distance sp ep) 2)) 1.57079 1) "N")
   (if (equal w_opt "Y")
       (progn
         (setq iop1 (polar (polar (polar sp (angle sp ep)(/ (distance sp ep) 2))
                    1.57079 cw) (angle ep sp) (/ cw 2))
               iop2 (polar iop1 1.57079 (- th (* cw 2)))
               cycle 1 ss1 (ssadd) ih (distance iop1 iop2) valid T)
         (if (or (= iop1 nil) (= iop2 nil) (<= (distance iop1 iop2) ws))
             (prompt "\nWebbing impossible.")
             (progn (command line iop1 iop2 ""
                  "copy" "L" "" iop1 (polar iop1 (angle sp ep) cw))
                 (if (or (equal (rtos (distance iop1 ip1)) (rtos (* ih 2.0)))
                        (<= (distance iop1 ip1) (* ih 2.0)))

; then draw single web

             (sfin)

; else draw complex web

             (progn (while (= valid T)
                 (setq tp1 (polar iop1 (angle cp2 cp1) (* ih 2))
                       tp2 (polar iop2 (angle cp2 cp1) (* ih 2))
                       op1 (polar iop2 (- (angle iop2 tp1) 1.57079) (/ ws 2.0))
                       op2 (polar tp1 (- (angle iop2 ip1) 1.57079) (/ ws 2.0))
                       op3 (polar iop2 (+ (angle iop2 tp1) 1.57079) (/ ws 2.0))
                       op4 (polar tp1 (+ (angle iop2 tp1) 1.57079) (/ ws 2.0)))
                 (command line (inters op1 op2 cp3 cp4)
                                 (inters op1 op2 tp1 tp2) "")
                 (setq ss1 (ssadd (entlast) ss1) oss1 (entlast))
                 (command line (inters op1 op2 tp1 tp2) tp1 "")
                 (setq ss1 (ssadd (entlast) ss1) oss2 (entlast))
                 (command line (inters op3 op4 iop1 iop2)
                                 (inters op3 op4 cp1 cp2) "")
                 (setq ss1 (ssadd (entlast) ss1) oss3 (entlast))
                 (if (or (equal (rtos (distance tp1 ip1)) (rtos (* ih 2.0)))
                         (<= (distance tp1 ip1) (* ih 2.0)))
                         (setq valid nil))
                 (setq cycle 2)
                 (if (= valid T)
                   (progn
                     (setq iop1 (polar tp1 (angle cp2 cp1) (* ih 2))
                       iop2 (polar tp2 (angle cp2 cp1) (* ih 2))
                       op1 (polar tp1 (- (angle tp1 iop2) 1.57079) (/ ws 2.0))
                       op2 (polar iop2 (- (angle tp1 iop2) 1.57079) (/ ws 2.0))
                       op3 (polar tp1 (+ (angle tp1 iop2) 1.57079) (/ ws 2.0))
                       op4 (polar iop2 (+ (angle tp1 iop2) 1.57079) (/ ws 2.0)))
                     (command line (inters op1 op2 tp1 tp2)
                                     (inters op1 op2 cp3 cp4) "")
                     (setq ss1 (ssadd (entlast) ss1) oss1 (entlast))
                     (command line (inters op3 op4 cp1 cp2)
                                     (inters op3 op4 iop1 iop2) "")
                     (setq ss1 (ssadd (entlast) ss1) oss3 (entlast))
                     (command line (inters op3 op4 iop1 iop2) iop2 "")
                     (setq ss1 (ssadd (entlast) ss1) oss2 (entlast))
                     (if (<= (distance iop1 ip1) (* ih 2.0)) (setq valid nil))
                     (setq cycle 1))))
                (if (= cycle 1)
                  (if (<= (distance iop1 ip1) ws)
                      (progn (command erase oss1 oss2 oss3 "")
                             (setq cycle 2)
                             (sfin))
                      (if (equal (rtos (distance iop1 ip1)) (rtos (* ih 2.0)))
                          (sfin)
                          (cfin)))
                  (if (<= (distance tp1 ip1) ws)
                      (progn (command erase oss1 oss2 oss3 "")
                             (setq cycle 1)
                             (sfin))
                      (if (equal (rtos (distance tp1 ip1)) (rtos (* ih 2.0)))
                          (sfin) (cfin))))))
         (command "mirror" ss1 "" 
                        (polar sp  (angle sp ep) (/ (distance sp ep) 2.0))
                        (polar cp1 (angle sp ep) (/ (distance sp ep) 2.0)) 
                        "N" )))))
   (setvar bm oldblp)
   (setvar ce cmdech)
   (setvar om oldort)
   (setq *error* olderr)
   (prompt "\nTruss complete.")
   (princ)
) ; end DEFUN C:TRUSS
(Prompt "loaded.")
(princ)
;; EOF TRUSS.LSP       261 lines           Bob Thomas

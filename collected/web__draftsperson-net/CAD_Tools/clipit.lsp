;;;    CLIPIT.LSP - Written by Randy Kintzley
;;;
;;;    Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;    Permission to use, copy, modify, and distribute this software
;;;    for any purpose and without fee is hereby granted, provided
;;;    that the above copyright notice appears in all copies and
;;;    that both that copyright notice and the limited warranty and
;;;    restricted rights notice below appear in all supporting
;;;    documentation.
;;;
;;;    AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.
;;;    AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
;;;    MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC.
;;;    DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
;;;    UNINTERRUPTED OR ERROR FREE.
;;;
;;;    Use, duplication, or disclosure by the U.S. Government is subject to
;;;    restrictions set forth in FAR 52.227-19 (Commercial Computer
;;;    Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
;;;    (Rights in Technical Data and Computer Software), as applicable.
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;GLOBAL INFO.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions created as result of loading file: clipit.lsp
; C_CLIPIT
; IN_BOUNDS
; TRANS_I_2_UCS
; WIPEOUT_CLIPIT
;
;Variables created as result of loading file: clipit.lsp
;
;Functions created as a result of executing the commands in: clipit.lsp
;
;Variables created as a result of executing the commands in: clipit.lsp
; BONUS_ALIVE
; BONUS_OLD_ERROR
; IMAGEADJUST
; #CLIPIT_RES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;GLOBAL INFO.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;
;;; ===========================================================================
;;; ===================== load-time error checking ============================
;;;

  (defun ai_abort (app msg) 
     (defun *error* (s)
      (if old_error (setq *error* old_error))
      (princ)
     );defun
     (if msg
       (alert (strcat " Application error: "
                      app
                      " \n\n  "
                      msg
                      "  \n"
              )
       );alert
     );if
     ;(*error* msg)
     (exit)
  );defun ai_abort

;;; Check to see if AI_UTILS is loaded, If not, try to find it,
;;; and then try to load it.
;;;
;;; If it can't be found or it can't be loaded, then abort the
;;; loading of this file immediately, preserving the (autoload)
;;; stub function.

;runs at load time - rk.
(cond
 (  (and ai_dcl (listp ai_dcl)))          ; it's already loaded.
 (  (not (findfile "ai_utils.lsp"))                     ; find it
    (ai_abort "CLIPIT"
              (strcat "Can't locate file AI_UTILS.LSP."
                      "\n Check support directory.")
    );ai_abort
 )
 (  (eq "failed" (load "ai_utils" "failed"))            ; load it
    (ai_abort "CLIPIT" "Can't load file AI_UTILS.LSP")
 )
);cond close

(if (not (ai_acadapp))               ; defined in AI_UTILS.LSP
    (ai_abort "CLIPIT" nil)          ; a Nil <msg> supresses
);if                                 ; ai_abort's alert box dialog.

;;; ==================== end load-time operations ===========================

(defun c:clipit ( / la dxf na na2 e1 e2 p1 a n lst lst2 zflag redraw_it)

(if (and (not init_bonus_error) 
         (equal -1 (load "ac_bonus.lsp"  -1)) 
    );and
    (progn (alert "Error:\n     Cannot find AC_BONUS.LSP.")(exit))
);if
(init_bonus_error (list
                   (list   "cmdecho" 0 
                         "highlight" 0
                         "regenmode" 1
                            "osmode" 0
                         "orthomode" 0
                   )
                   T     ;flag. True means use undo for error clean up.  
                  '(while redraw_it 
                     (redraw (car redraw_it) 4) 
                     (setq redraw_it (cdr redraw_it))
                   ) 
                  );list  
);init_bonus_error


 ;local function
 (defun dxf (a b / ) (cdr (assoc a b)));defun

(princ "\nPick a POLYLINE/CIRCLE/ARC for clipping edge.. ")
(setq na (single_select '((-4 . "<OR") 
                           (0 . "*POLYLINE")
                           (0 . "ARC")
                           (0 . "CIRCLE")
                          (-4 . "OR>") 
                         )
                         T ;enable locked layer selection for boundary
         );single_select 
);setq
(if na 
    (progn

     (setq e1 (entget na))
     (setq redraw_it (list na))
     (redraw na 3)
     (princ "\nPick an IMAGE, a WIPEOUT, or an XREF/BLOCK to clip... ")
     (setq na2 (single_select '((-4 . "<OR") 
                               (0 . "IMAGE")
                               (0 . "INSERT")
                               (0 . "WIPEOUT")
                               (-4 . "OR>") 
                              )
                              nil ;dis-allow locked layer selection for object to be clipped 
              );single_select 
     );setq
     (setq redraw_it nil)
     (redraw na 4)
  (if na2
      (progn  
       (setq e2 (entget na2))
       (setvar "cmdecho" 0)
       (setvar "highlight" 1)
       (command "_.select" na na2)

       (if (not #clipitres)
           (setq #clipitres (pixel_unit)
                 #clipitres (rtos #clipitres 2 
                                             (fix (/ (getvar "luprec") 2.0))
                            )
                 ;#clipitres (substr #clipitres 1 5)
                 #clipitres (atof #clipitres)
           )
       );if
       (initget 2)
       (setq  a (getdist 
                 (strcat "\nEnter max error distance for resolution of arcs <"
                         (ai_rtos #clipitres) ">: "
                 );strcat
                );getdist
       );setq
       (command "")
       (if (not a) 
           (setq a #clipitres)
           (setq #clipitres a) 
       );if
       (entupd na)
       (setq lst (ep_list na a))
       (if (or (not (equal "INSERT" (dxf 0 e2)))
               (not (p_isect lst nil))
           );or
           (progn
            (if (equal (car lst) (last lst) 0.001)
                (setq lst (cdr lst))
            );if
            (if (or (equal "INSERT" (dxf 0 e2))
                    (equal "IMAGE"  (dxf 0 e2))
                );or 
                (progn 
                 (if (setq zflag (zoom_4_select lst))
                     (command "_.zoom" "_w" (car zflag) (cadr zflag))
                 );if
                 (c_clipit na2 lst)
                 (if zflag (command "_.zoom" "_p"))
                );progn then
                (wipeout_clipit na2 lst)
            );if
           );progn then valid boundary selected
           (princ "\nInvalid. Bounding entity cannot self intersect for xclip.")
       );if     
      );progn then got na2
  );if
   );progn then got na
);if
(restore_old_error)
(princ)
);defun c:clipit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c_clipit ( na lst / e1 a b c d n lst2 lst3 )
 (setq e1 (entget na))
 (if (equal "INSERT" (cdr (assoc 0 e1)))
     (command "_.xclip" na "" "_n") 
     (progn
      (setq lst2 (image_bounds na));setq
      (setq  
             lst (append lst (list (car lst)))
               a (car lst)
            lst3 (list a)
      );setq
      (setq n 1);setq
      (repeat (max 0 (- (length lst) 1))
      (setq b (nth n lst));setq
       (setq d nil)
       (if (setq c (inters a b (nth 0 lst2) (nth 1 lst2)))
           (setq d (append d (list c)))
       );if
       (if (setq c (inters a b (nth 1 lst2) (nth 2 lst2)))
           (setq d (append d (list c)))
       );if
       (if (setq c (inters a b (nth 2 lst2) (nth 3 lst2)))
           (setq d (append d (list c)))
       );if
       (if (setq c (inters a b (nth 3 lst2) (nth 4 lst2)))
           (setq d (append d (list c)))
       );if
      (if d
          (progn
           (if (> (length d) 1)
               (progn
                ;find the closest intersection and append that one first 
                (if (< (distance (car d) a) (distance (cadr d) a))
                    (setq lst3 (append lst3 d))
                    (setq lst3 (append lst3 (reverse d)))
                );if 
               );progn
               (setq lst3 (append lst3 (list (car d))));setq
           );if
          );progn
      );if
      (setq lst3 (append lst3 (list b)));setq
      (setq a b)
      (setq n (+ n 1));setq 
      );repeat
      (setq  lst lst3
            lst2 nil
            lst3 nil
      );setq
      (command "_.imageclip" na "_n") 
     );progn else
 );if
 (if (or (and (equal "{ACAD_XDICTIONARY" (cdr (assoc 102 e1)))
              (assoc 360 e1)
         );and
         (and (equal 4 
                     (logand 4 (dxf 70 e1))
              );equal
              (equal 1 (dxf 280 e1))
         );and 
     );or
     (command "_y")
 );if
 (command "_p")
 (setq n 0);setq
 (repeat (length lst)
  (setq a (nth n lst))
  (if (and (not (member a lst2))
           (or (not lst2)
               (not (equal (nth n lst) (last lst2) 0.000001))
           );or
      );and
      (progn
       (command a)
       (setq lst2 (append lst2 (list a)))
      );progn
  );if
  (setq n (+ n 1));setq
 );repeat
 (command "")

);defun c_clipit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun in_bounds ( p1 lst / n a b c)
 (setq b (car lst)
       b (list (car b) (cadr b))
       c (caddr lst)
       c (list (car c) (cadr c)) 
       a (angle b (cadr lst))
 );setq
 (if (< a 0) (setq a (+ a (* 2.0 pi))))
 (setq  a (* -1.0 a)
        c (rotate_pnt c b a)
       p1 (rotate_pnt p1 b a)
      lst (maxminpnt (list b c p1)) 
 );setq
 (and (equal (car lst) b 0.000001)
      (equal (cadr lst) c 0.000001)
 );and 
);defun in_bounds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes: lst  - a list of 2d points obtained from an image entity.
;       na   - entity name of an image 
;       code - 0, 1 or 2 (same as trans 
;                         world coords, current ucs, or screen respectively)
;Returns a list of translated coords.
;
(defun trans_i_2_ucs ( lst na code / p1 p2 p3 p4 c d x y ang e1 lst2 n)
 (setq e1 (entget na)
       p1 (cdr (assoc 10 e1)) ;insert point
       p2 (cdr (assoc 11 e1)) ;x vector
       p3 (cdr (assoc 12 e1)) ;y vector
       p4 (cdr (assoc 13 e1))
      ang (atan (/ (cadr p2) (car p2)))
        x (sqrt (+ (expt (car p2) 2) (expt (cadr p2) 2)))
        y (sqrt (+ (expt (car p3) 2) (expt (cadr p3) 2)))
        c (list (+ (* x (car p4))  (car p1)) 
                (+ (* y (cadr p4)) (cadr p1)) 
                (caddr p1)
          )
 );setq
 (setq n 0);setq
 (repeat (length lst)
  (setq d (nth n lst)
        d (list (+ (car p1)  
                   (* x (car d)) 
                )
                (- (cadr c)
                   (* y (cadr d))
                )
                (caddr p1)
          );list
        d (rotate_pnt d p1 ang)
        ;d (trans d na code)
     lst2 (append lst2 (list d))
  );setq
  (setq n (+ n 1));setq
 );repeat
 lst2
);defun trans_i_2_ucs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun wipeout_clipit ( na lst / la)

(entdel na)
(if (setq la (b_layer_locked (getvar "clayer")))
    (command "_.layer" "_un" (getvar "clayer") "")
);if 
(pline (list lst))
(command "_.pedit" (entlast) "_cl" "_x")
(command "_.wipeout" "_n" (entlast) "_y")
(if la
    (command "_.layer" "_lock" (getvar "clayer") "")
);if

);defun wipeout_clipit

(princ "\nCLIPIT")
(princ (strcat
"\nWith CLIPIT you can use ARCS, CIRCLES or POLYLINES "
"\nto define \"clipping boundaries\" for BLOCKS, XREFS, "
 "\nIMAGES and WIPEOUTS."
))
(princ)






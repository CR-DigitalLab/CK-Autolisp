;;;     AC_BONUS.LSP
;;;     Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;     Created 2/21/97 by Randy Kintzley and Dominic Panholzer
;;;                   
;;;
;;;     Permission to use, copy, modify, and distribute this software
;;;     for any purpose and without fee is hereby granted, provided
;;;     that the above copyright notice appears in all copies and 
;;;     that both that copyright notice and the limited warranty and 
;;;     restricted rights notice below appear in all supporting 
;;;     documentation.
;;;
;;;     AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.  
;;;     AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF 
;;;     MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC. 
;;;     DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE 
;;;     UNINTERRUPTED OR ERROR FREE.
;;;
;;;     Use, duplication, or disclosure by the U.S. Government is subject to 
;;;     restrictions set forth in FAR 52.227-19 (Commercial Computer 
;;;     Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii) 
;;;     (Rights in Technical Data and Computer Software), as applicable. 
;;;
;;;   ----------------------------------------------------------------
;;;
;;;    This file is called from ACADR14.LSP. It defines autoloading functions
;;;    as well as library functions used by AutoCAD bonus lisp routines.
;;;
; ------------------------- GLOBAL INFO --------------------------
; Functions created as result of loading file: ac_bonus.lsp
; ----------------------------------------------------------------
; B_LAYER_LOCKED
; B_RESTORE_SYSVARS
; B_RESTORE_UNDO
; B_SET_SYSVARS
; BONUS_ERROR
; C:ALIASEDIT
; C:ARCTEXT
; C:ASCPOINT
; C:ATEXT
; C:ATTLST
; C:BEXTEND
; C:BLKLST
; C:BLKTBL
; C:BLOCK?
; C:BONUSMENU
; C:BTRIM
; C:BURST
; C:CATTL
; C:CHGTEXT
; C:CHT
; C:CLIPIT
; C:CONVERTPLINES
; C:COUNT
; C:CROSSREF
; C:DATE
; C:DIMEX
; C:DIMIM
; C:EXCHPROP
; C:EXTRIM
; C:FIND
; C:FLIPEM
; C:GATTE
; C:GETSEL
; C:KILLSVP
; C:LAYCUR
; C:LAYFRZ
; C:LAYISO
; C:LAYLCK
; C:LAYMCH
; C:LAYOFF
; C:LAYON
; C:LAYTHW
; C:LAYULK
; C:LMAN
; C:LSP
; C:MOCORO
; C:MPEDIT
; C:MSTRETCH
; C:NCOPY
; C:PACK
; C:PQCHECK
; C:QLATTACH
; C:QLATTACHSET
; C:QLDETACHSET
; C:QLEADER
; C:REVCLOUD
; C:SSX
; C:SYSVDLG
; C:TEXTFIT
; C:TEXTMASK
; C:TXTEXP
; C:WIPEOUT
; C:XDATA
; C:XDLIST
; C:XLIST
; DELTA_ANG
; EP_LIST
; GET_ARC_POINTS
; IMAGE_BOUNDS
; INIT_BNSMENU
; INIT_BONUS_ERROR
; LSTTRANS
; M_ASSOC
; MAXMINPNT
; MPOPLST
; P_ISECT
; PIXEL_UNIT
; PL_ARC_INFO
; PL_POINT_LIST
; PLINE
; POSITION
; RESTORE_OLD_ERROR
; ROTATE_PNT
; SINGLE_SELECT
; SS_VISIBLE
; TNLIST
; UCS_2_ENT
; VIEWPNTS
; VTLIST
; ZOOM_4_SELECT
;
; ----------------------------------------------------------------
; Variables created as result of loading file: ac_bonus.lsp
; ----------------------------------------------------------------
; -
; ----------------------------------------------------------------
; Functions created as a result of executing the commands
; in: ac_bonus.lsp
; ----------------------------------------------------------------
; -

; ----------------------------------------------------------------
; Variables created as a result of executing the commands
; in: ac_bonus.lsp
; ----------------------------------------------------------------
; -


; ----------------- LAUNCHING EXTERNAL PROGRAMS ------------------
; Individual functions for running external programs
; ----------------------------------------------------------------

(defun c:aliasedit ()                         ; Alias Editor
  (startapp (findfile "alias.exe"))
  (princ)
)


; ------------------ FIRST TIME MENU LOADING ---------------------
; This program is called from ACAD.MNL. It assures that the bonus
; menu will be loaded the first time AutoCAD is run.
; ----------------------------------------------------------------

(defun init_bnsmenu ()
  (and
    (not (= (getenv "BNS_MenuLoad") "1"))
    (setenv "BNS_MenuLoad" "1")
    (c:bonusmenu)
  )
)


; -------------------- MENU LOADING FUNCTION ---------------------
; Command line routine for loading bonus menu
; ----------------------------------------------------------------

(defun c:bonusmenu ()

  (init_bonus_error 
    (list
      (list "cmdecho" 0
      )

      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (and
    (if (menucmd "Gac_bonus.id_mnbnslayr=?")
      (prompt "\nAutoCAD Bonus Menu already loaded.")
      T
    )
    (if (not (or (findfile "ac_bonus.mnu")
                 (findfile "ac_bonus.mnc")
             )
        )
      (prompt "\nAutoCAD Bonus Menu not found.")
      T
    )
    (command "_.menuload" "ac_bonus")
  )

  (restore_old_error)
  (princ)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;FLIPEM and KILLSVP utility commands;;;;;;;;;;;;;;;;;;;;;;
; FLIPEM.LSP
;
; Flips the ECS of all arcs with negative WCS normals.
;
(defun C:FLIPEM ( / ss n)
 (init_bonus_error (list (list "cmdecho" 0 "highlight" 0) 
                         T
                   )
 );
 (cond 
    ((not (setq ss (ssget "_x" '((0 . "ARC") (210 0.0 0.0 -1.0)))))
     (princ "\nNo arcs with negative normals were found.")
    ) 
    (T 
     (setq n 0)  
     (repeat (sslength ss)
      (entmod
       (list
        (cons -1 (ssname ss n))
        '(210 0.0 0.0 1.0)
       )
      );entmod
      (setq n (1+ n))
     );repeat
     (command "_.mirror" ss "" "0,0" "0,1" "_y")
    )
 );cond
 (restore_old_error)
 (princ)
);defun c:flipem
      
;;;
;;;
;;;   C.Bethea 5 May 94
;;;
;;;   DESCRIPTION: killsvp Deletes single vertex polylines
;;;
;;;
;--- c:killsvp ----------------------------------------------
; delete single vertex polylines
;
(defun c:killsvp (/ dxf ent i ss1 hdr )

 (defun dxf (x ent) (cdr (assoc x (entget ent))))

 (setq i 0)
 (if (setq ss1 (ssget "_x" '((0 . "POLYLINE"))))
     (while (< 0 (sslength ss1))
        (setq hdr (ssname ss1 0)        ; get first pline
              ent hdr
        )
        (ssdel hdr ss1)                 ; remove it from select set
        (setq ent (entnext ent))        ; 1st vertex
        (setq ent (entnext ent))        ; 2nd vertex or seqend
        (if (= "SEQEND" (dxf 0 ent))
            (progn
               (entdel hdr)             ; single vertex pline
               (setq i (1+ i))
            )
        )
     );while
 );if
 (if (> i 0)
     (princ (strcat "\nFound and killed " (itoa i) " single vertex plines."))
     (princ "\nNo single vertex polylines found.")
 );if
 (princ)
);defun c:killsvp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --------------------- BONUS ERROR HANDLER ----------------------
; Error handler for bonus lisp routines.
; INIT_BONUS_ERROR initializes error routine. RESTORE_OLD_ERROR
; resets environment.
; ----------------------------------------------------------------
;
;INIT_BONUS_ERROR
;This routine initializes the error handler
;It should be called at the top of your lisp routine 
;
;Arguments:
;  init_err Takes a list as an argument. 
;This list can be nil or can contain the following elements:
;(list ("sysvar" value "sysvar" value ...)
;      undo_enable
;      (additional specialized clean up function)
;);list
;  The arguments explained:
;  1. - The first element of the argument list:
;       This is a list of system variables paired with
;       the values you want to set them to. 
;  2. - The second element of the list is a flag
;       If it is true, then in the event of an error 
;       the custom *error* routine will utilize UNDO 
;       as a cleanup mechanism.
;  3. - The third element is a quoted function call.
;       You pass a quoted call to the function you
;       wish to execute if an error occurs. 
;        i.e. '(my_special_stuff arg1 arg2...)
;       Use this arg if you want to do some specialized clean up 
;       things that are not already done by the standard bonus_error 
;       function.
;        
;The reason a list is provided as the argument is for upward
;compatability. Other arguments can be placed in the list at a later
;time and not affect previous versions.
;
(defun init_bonus_error ( lst / ss undo_init)
 
  ;;;;;;;local function;;;;;;;;;;;;;;;;;;;;
  (defun undo_init ( / undo_ctl)
   (b_set_sysvars (list "cmdecho" 0))
   (setq undo_ctl (getvar "undoctl")) 
   (if (equal 0 (getvar "UNDOCTL")) ;Make sure undo is fully enabled.
       (command "_.undo" "_all")
   )
   (if (or (not (equal 1 (logand 1 (getvar "UNDOCTL"))))  
           (equal 2 (logand 2 (getvar "UNDOCTL")))
       );or
       (command "_.undo" "_control" "_all") 
   )
    
   ;Ensure undo auto is off
   (if (equal 4 (logand 4 (getvar "undoctl")))
       (command "_.undo" "_Auto" "_off")
   )
   
   ;Place an end mark down if needed.
   (while (equal 8 (logand 8 (getvar "undoctl")))
        (command "_.undo" "_end")
   );while         
   (while (not (equal 8 (logand 8 (getvar "undoctl"))))
    (command "_.undo" "_begin")                 
   );while
   (b_restore_sysvars) 
   ;return original value of undoctl
   undo_ctl
  );defun undo_init

    ;;;;;;;;;;;;;begin the work of init_bonus error;;;;;;;;;;;;;
 (setq ss (ssgetfirst))
 (while (not (equal (getvar "cmdnames") "")) 
  (command nil)
 );while rk added 6:45 PM 8/10/97
 (if (not bonus_alive)
     (setq bonus_alive 0)
 );if
 (setq bonus_alive (1+ bonus_alive))
 
 (if (and (> bonus_alive 1)                              ;do some double checking to make sure 
          (or (not (equal 'LIST (type *error*)))         ;our error handler is still active.
              (not (equal "bonus_error" (cadr *error*))) ;for nested this call.
          );or
     );and
     (progn
      (princ "\nNested Error trapping is being used incorrectly.")
      (princ "\nResetting the nested index to 1.")
      (setq     *error* bonus_error
            bonus_alive 0
      );setq
      (restore_old_error);quietly restore undo status
      (setq bonus_alive 1)
     );progn then things need to be re-adjusted.
 );if
 (if (<= bonus_alive 0)   
     (progn 
      (setq bonus_alive 0);undo settings will be restored 
                          ;along with setting *error* back to bonus_old_error.
                          ;No call to b_restore_sysvars will be made.
                          ;If it is decided, this thing should do variable clean 
                          ;up also then set bonus_alive to 1 before calling
                          ;restore_old_error
      (restore_old_error);quietly restore bonus_old_error and undo status.
      (setq bonus_alive 1)
     );progn then
 );if
 (if (= bonus_alive 1)
     (progn
      (if (and *error*
               (or (not (equal 'LIST (type *error*)))
                   (not (equal "bonus_error" (cadr *error*)))
               );or 
          );and 
          (setq bonus_old_error *error*);save the *error* only if it 
                                        ;looks like the standard one or is some other 
                                        ;user defined one. Don't want to save it if 
                                        ;it's ours because we already have it.
      );if
      (if (cadr lst)
          (setq bonus_undoctl (undo_init)) 
          (setq bonus_undoctl nil)
      );if
    );progn then this is a top level call, or in other words, the first time through.
 );if
 (b_set_sysvars (car lst))
 (if (= bonus_alive 1)
     (progn
      (setq *error* bonus_error);setq
      (if (caddr lst)
          (setq *error* (append (reverse (cdr (reverse *error*))) 
                                (list (caddr lst)
                                      (last *error*)
                                );list
                        );append
          );setq ;then add additional routine name to the error function.
      );if
     );progn
     (progn
      (if (and (> bonus_alive 1)
               (or (not (equal 'LIST (type *error*)))
                   (not (equal "bonus_error" (cadr *error*)))
               );or
          );and
          (setq *error* bonus_error);setq
      );if
     );progn else double check to make sure the bonus_error is in effect.
 );if
 (if (and ss
          (equal 1 (logand 1 (getvar "pickfirst")))
     );and
     (sssetfirst (car ss) (cadr ss))
 );if
);defun init_bonus_error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bonus_error ( msg / )

"bonus_error"

(setq bonus_alive -1)
(print msg)

;;Get out of any active command.
(while (not (equal (getvar "cmdnames") ""))
 (command nil)
)

;If undo global variable flag is set then use undo as a cleanup helper.
(if bonus_undoctl
    (progn
     (setvar "cmdecho" 0)

     (while (not (wcmatch (getvar "cmdnames") "*UNDO*"))
            (command "_.undo")
     );while
     (command "_end")  ;The routine that just failed created an undo 
                       ;begin mark, so we need to close it off with 
                       ;and "end" mark.

     (command "_.undo" "1")   ;now back up to the begining.
     (while (not (equal (getvar "cmdnames") "")) 
      (command nil)
     );while

    );progn
);if

(b_restore_sysvars)
(b_restore_undo)

;Restore original error handler
(if bonus_old_error
    (setq *error* bonus_old_error)
);if

(setq bonus_alive 0)

(princ)
);defun bonus_error

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Restore_old_error
;This function should be the last thing called in a lisp 
;defined command. It does a (princ) at the end for a quiet 
;finish.
(defun restore_old_error ( / )


(setq bonus_alive (- bonus_alive 1))
(if (>= bonus_alive 0)
    (b_restore_sysvars)
    (setq bonus_varlist nil)
);if
(if (<= bonus_alive 0)
    (progn
     (while (not (equal (getvar "cmdnames") "")) 
      (command nil)
     );while rk 
     (b_restore_undo)
     (if bonus_old_error
         (setq *error* bonus_old_error);put the old error routine back.
     );if
    );progn then
);if

(princ)
);defun restore_old_error



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun b_restore_undo ()

(if bonus_undoctl
    (progn
      (b_set_sysvars (list "cmdecho" 0))

      (while (equal 8 (logand 8 (getvar "undoctl")))
         (command "_.undo" "_end")
      );while

      (if (not (equal bonus_undoctl (getvar "undoctl")))
          (progn
           (cond 
            ((equal 0 bonus_undoctl) 
             (command "_.undo" "_control" "_none")
            )
            ((equal 2 (logand 2 bonus_undoctl))
             (command "_.undo" "_control" "_one")
            )	
           );;cond 
           (if (equal 4 (logand 4 bonus_undoctl))
               (command "_.undo" "_auto" "_on") 
           );if 

         );progn then restore undoctl to the status the user had it set to. 
      );if
      (if (not (equal 2 (logand 2 (getvar "undoctl"))))
          (b_restore_sysvars)
      );if
    );progn then restore undo to it's original setting
);if
(setq bonus_undoctl nil)

);defun b_restore_undo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This has no error checking. You must
;provide a list of even length in the 
;following form
;( "sysvar1" value
;  "sysvar2" value2
;)
(defun b_set_sysvars (lst / lst2 lst3 a b n)

(setq lst3 (car bonus_varlist));setq

(setq n 0)
(repeat (/ (length lst) 2)
 (setq a (strcase (nth n lst))
       b (nth (+ n 1) lst)
 );setq
 (setq lst2 (append lst2
                    (list (list a (getvar a)))
            );append
 );setq 
 (if (and bonus_varlist 
          (not (assoc a lst3))
     );and
     (setq lst3 (append lst3 
                        (list (list a (getvar a)))
                );append
     );setq 
 );if

 (setvar a b)

(setq n (+ n 2));setq
);repeat
(if bonus_varlist
    (setq bonus_varlist (append (list lst3) 
                                (cdr bonus_varlist)
                                (list lst2) 
                        );append
    );setq
    (setq bonus_varlist (list lst2))
);if
);defun b_set_sysvars

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun b_restore_sysvars ( / lst n a b)

 (if (<= bonus_alive 0)
     (setq           lst (car bonus_varlist)
           bonus_varlist (list lst)
     );setq 
     (setq lst (last bonus_varlist)) 
 );if

 (setq n 0);setq
 (repeat (length lst)
 (setq a (nth n lst)
       b (cadr a)
       a (car a)
 )
 (setvar a b)
 (setq n (+ n 1));setq
 );repeat
 (setq bonus_varlist (reverse (cdr (reverse bonus_varlist))))

);defun b_restore_sysvars

;;;;;;;;;;;;;;;;;;;;;;;;;end error handler functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;P_ISECT
;Poly-InterSECT
;takes a list of points and and a flag
;returns true if the 
; segments intersect on themselves.
;If the flag argument is true 
;then error strings will be printed to the command line
;if an intersection is found.
;
(defun p_isect ( lst flag2 / flag lst2 lst3 a b c d n j)

(setq n 0);setq
(repeat (length lst)
(setq    a (nth n lst)
      lst2 (append lst2 (list a))
);setq
(if (equal 2 (length lst2))
    (setq lst3 (append lst3 (list lst2))
          lst2 (list (cadr lst2))
    );setq
);if    
(setq n (+ n 1));setq
);repeat

(if (equal 2 (length lst2))
    (setq lst3 (append lst3 (list lst2)));setq
);if    

(setq n 0);setq
(while (and (< n (length lst3))
            (not flag)
       );and
(setq a (nth n lst3)
      b (cadr a)
      a (car a)
);setq
 (setq j (+ n 1))
 (while (and (< j (length lst3)) 
             (not flag)
        );and 
 (setq c (nth j lst3)
       d (cadr c)
       c (car c) 
 );setq
 (if (and (not (equal b c 0.000001))
          (not (equal a d 0.000001))
     );and
     (progn
      (setq flag (inters a b c d))
      (if (and flag 
               flag2
          );and
          (progn
           (princ "\nInvalid. Crossing polygon cannot self intersect.")
           (princ flag2)
          );progn
      );if
     );progn
 );if
 
 (setq j (+ j 1));setq
 );while

(setq n (+ n 1));setq
);while

flag
);defun p_isect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;zoom_4_select
;Takes - a list of coordinates. If all coords do not lie in
;the current view, zoom_4_select will return two points within a list
;that can be used with zoom window to ensure that all points will be 
;on screen.
;Returns - True in the form of two corners points if a zoom operation needs 
;          to be performed and returns nil if not. 
;
(defun zoom_4_select ( lst / a b)

 (setq  lst (lsttrans lst 1 2) 
          a (maxminpnt (lsttrans (viewpnts) 1 2))
          b (maxminpnt (append a lst))
 );setq 

 (if (not (equal a b))
     (progn
      (setq b (list (trans (append (car b) '(0.0))  2 1)
                    (trans (append (cadr b) '(0.0)) 2 1)
              )
      );setq
     );progn
     (setq b nil)
 );if

 b
);defun zoom_4_select


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;maxminpnt
;takes: a list of points
;returns: a list of 2 points the lower left and the upper right
;
;	maxminpnt	 
(defun maxminpnt ( lst / x n a b c d)

(setq x (car lst)
      a (car x)
      b (cadr x)
      c (car x)
      d (cadr x)
      n 1
);setq
(repeat (max (- (length lst) 1) 0)
(setq x (nth n lst));setq
(setq a (min a (car x))
      b (min b (cadr x))
      c (max c (car x))
      d (max d (cadr x))
);setq
(setq n (+ n 1));setq
);repeat
(list (list a b)
      (list c d)
);list
);defun maxminpnt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;viewpnts
;returns lower left and upper right coords of current view
(defun viewpnts ( / a b c d x)

(setq b (getvar "viewsize")
      c (car (getvar "screensize"))
      d (cadr (getvar "screensize"))
      a (* b (/ c d))
      x (setq x (getvar "viewctr"))
      x (trans x 1 2)
      c (list (- (car x)  (/ a 2.0))
              (- (cadr x) (/ b 2.0))
              0.0
        );list
      d (list (+ (car x)  (/ a 2.0))
              (+ (cadr x) (/ b 2.0))
              0.0
        );list
      c (trans c 2 1)
      d (trans d 2 1) 
);setq

(list c d)
);defun viewpnts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pixel_unit
;returns the size of a single pixel in drawing units.
;value depends on current zoom factor.
;
;pixunit/viewsize = one pixel/yscreensize
;
;pixunit=viewsize/yscreensize 
;
(defun pixel_unit ( / x y x1 y1)
 (setq  y (getvar "viewsize")
       x1 (car (getvar "screensize"))
       y1 (cadr (getvar "screensize"))
        x (* y (/ x1 y1))
 );setq
 (max (abs (/ y y1))
      (abs (/ x x1))
 );max
);defun pixel_unit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**PLINE** function takes a list and creates a polyline entity
;the list contains a list of coords.
;and optionaly other lists such as (8 . "LAYER")
;				   (40 . WIDTH)
;				   (62 . COLOR)
;	pline	     n a b flag
(defun pline ( lst / n a b flag)


(if (> (length lst) 1)
    (progn
     (if (setq b (assoc 8 lst));setq
	 (setq a (append a (list b)));setq then
     );if
     (if (setq b (assoc 40 lst));setq
	 (setq a (append a (list b)
			    (list (cons 41 (cdr b))
			    );list
		 );append
	 );setq then
     );if
     (if (setq b (assoc 62 lst));setq
	 (setq a (append a (list b)));setq then
     );if

    );progn then
    (setq flag T
	     b (car lst)
    );setq else only a coord list was provided
);if

(setq n 0)
(while (and (not flag)
	    (< n (length lst))
       );and

(if (not (member (nth n lst) a))
    (setq    b (nth n lst)
	  flag T
    );setq then
);if

(setq n (+ n 1));setq
);while

(entmake (append (list '(0 . "POLYLINE")) a));entmake

(setq n 0)
(repeat (length b)

(entmake (list '(0 . "VERTEX")
	       (append (list 10) (nth n b))
	 );list
);entmake

(setq n (+ n 1));setq
);repeat

(entmake '((0 . "SEQEND")));entmake

(princ)
);defun pline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**VTLIST** takes a list or a polyline ent name
;RETURNS a list of vertecies in
; WORLD if a list is provided '(na code) and code=0
; CURRENT UCS coords are returned if only na is provided as an argument
;or if a lst is provided and code=1
;
;	
(defun vtlist ( na / dxf e1 lst lst2 code n flag a z)

 ;local function
 (defun dxf (a b / ) (cdr (assoc a b)));defun

(if (equal (type na)
	     (type (list 1))
    );equal
    (setq code (cadr na)
            na (car na)
    );setq then
    (setq code 1);setq else
);if
(setq e1 (entget na));setq
(if (equal 1 (logand 1 (dxf 70 e1)))
    (setq flag 1)
    (setq flag nil)
);if
(if (equal (dxf 0 e1) "POLYLINE")
    (progn
     (setq na (entnext na)
           e1 (entget na)
     );setq
     (while (/= "SEQEND" (dxf 0 e1))    
      (setq lst (append lst 
                        (list (trans (dxf 10 e1) na code));list 
                );append
             na (entnext na)
             e1 (entget na)
      );setq
     );while
    );progn then old polyline
    (progn
     (setq lst e1
             z (dxf 38 e1)
     );setq
     (if (not z) (setq z 0.0)) 
     (setq n 0);setq
     (repeat (length lst)
     (setq    a (nth n lst))
     (if (equal (car a) 10)
         (setq   a (cdr a)
                 a (list (car a) (cadr a) z)
              lst2 (append lst2 
                           (list (trans a na code))
                   );append
         );setq then
     );if
     (setq n (+ n 1));setq 
     );repeat
     (setq  lst lst2 
           lst2 nil
     );setq
    );progn else lwpolyline
);if 
(if (and flag lst)
    (setq lst (append lst (list (car lst))));setq
);if
lst
);defun vtlist

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ep_list
;returns entity point list
;returns a list of points on the entity
;args
; na -is a polyline 'pl_point_list' is called
; alt -is an arc segmant error tolerance (altitude)
;
(defun ep_list ( na alt / dxf a b c d n e1 lst)

 ;local function
 (defun dxf (a b / ) (cdr (assoc a b)));defun

(setq e1 (entget na));setq
(cond
 ((or (equal (dxf 0 e1) "POLYLINE")
      (equal (dxf 0 e1) "LWPOLYLINE")
  );or
  (setq lst (pl_point_list na alt));setq
 );cond #1
 ((equal (dxf 0 e1) "LINE")
  (setq lst (list (trans (dxf 10 e1) na 1)
                  (trans (dxf 11 e1) na 1)
            );list
  );setq
 );cond #2
 ((or (equal (dxf 0 e1) "ARC") 
      (equal (dxf 0 e1) "CIRCLE")
  );or
  (progn
   (setq a (dxf 10 e1)             ;the center point
         b (dxf 40 e1)             ;the radius
         n (dxf 50 e1)             ;the start angle
         c (dxf 51 e1)             ;the end angle
   );setq
   (if (not n)
       (setq n 0
             c (* 2.0 pi)
       );setq then it's a circle
       (if (> n c)
           (setq c (+ c (* 2.0 pi)));setq then
       );if else it's an arc
   );if
   (setq lst (append lst 
                     (get_arc_points a 
                                     (polar a n b) 
                                     (polar a c b)
                                     (- c n) 
                                     alt
                     );get_arc_points
             );append
   );setq
   (setq lst (lsttrans lst na 1))
  );progn
 );cond #3
 ((or (equal "TEXT" (dxf 0 e1))
      (equal "ATTDEF" (dxf 0 e1))
  );or
  (command "_.ucs" "_ob" na)
  (setq a (textbox e1)
        b (cadr a)
        a (car a)
        c (* 0.2 (dxf 40 e1));extra room factor
        a (list (- (car a) c) (- (cadr a) c) 0.0)
        b (list (+ (car b) c) (+ (cadr b) c) 0.0)
        a (list a
                (list (car b) (cadr a) 0.0)
                b
                (list (car a) (cadr b) 0.0)
                a
          );list
        a (lsttrans a 1 0)
  );setq
  (command "_.ucs" "_p")
  (setq lst (lsttrans a 0 1));setq
 );cond #4
 ((equal "MTEXT" (dxf 0 e1))
  (bns_ucs_2_mtext na)
  (setq lst (bns_mtextbox e1)
          c (* 0.2 (dxf 40 e1));extra room factor
          a (car lst)
          b (caddr lst)
          a (list (- (car a) c) (- (cadr a) c) 0.0)
          b (list (+ (car b) c) (+ (cadr b) c) 0.0)
        lst (list a
                  (list (car b) (cadr a) 0.0)
                  b
                  (list (car a) (cadr b) 0.0)
                  a
            );list
        lst (lsttrans lst 1 0)
  );setq
  (command "_.ucs" "_p")
  (setq lst (lsttrans lst 0 1));setq
 );cond #5
 ((equal "ELLIPSE" (dxf 0 e1))
  (setq lst (get_ellipse_points na alt)) 
 );cond #6
 ((equal "IMAGE" (dxf 0 e1))
  (setq lst (image_clip_list na))
 );cond #7
);cond close

lst
);defun ep_list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pl_point_list ( na alt / dxf na2 a b c z p1 p2 p3 e1 lst lst2 code n flag )

 ;local function
 (defun dxf (a b / ) (cdr (assoc a b)));defun

 (if (equal (type na)
            (type (list 1))
     );equal
     (setq code (cadr na)
             na (car na)
     );setq then
     (setq code 1);setq else
 );if
 (setq e1 (entget na));setq
 (if (equal 1 (logand 1 (dxf 70 e1)))
     (setq flag 1)
     (setq flag nil)
 );if
 (setq na2 na)
 (if (equal (dxf 0 e1) "POLYLINE")
     (progn
      (setq na (entnext na)
            e1 (entget na)
            p1 (dxf 10 e1) 
             b (dxf 42 e1) 
      );setq
      (if (not (equal 16 (logand 16 (dxf 70 e1))))
          (setq lst (list p1))
          (setq lst nil)
      );if     
      (setq na (entnext na)
            e1 (entget na)
      );setq
      (while (/= "SEQEND" (dxf 0 e1 ))    
       (setq p2 (dxf 10 e1));setq
       (if (not (equal 16 (logand 16 (dxf 70 e1))))
           (progn 
            (if (and b 
                     (not (equal b 0)) 
                     ;added below for cloud problems
                     p1
                     (not (equal p1 p2))
                );and
                (setq  p3 (pl_arc_info p1 p2 b)
                      lst (append lst 
                                  (get_arc_points (car p3) p1 p2 (caddr p3) alt)
                          );append
                );setq then
                (setq lst (append lst (list p2)));setq else
            );if
           );progn then not a spline control point
       );if
       (setq  b (dxf 42 e1)
             na (entnext na)
             e1 (entget na)
             p1 p2
       );setq
      );while
     
       (if flag
           (progn
            (setq p2 (car lst))
            (if (and b 
                     (not (equal b 0)) 
                     ;added below for cloud problems
                     p1
                     (not (equal p1 p2))
                );and
                (setq  p3 (pl_arc_info p1 p2 b)
                      lst (append lst 
                                  (get_arc_points (car p3) p1 p2 (caddr p3) alt)
                          );append
                );setq then
                (setq lst (append lst (list p2)));setq else
            );if
            (setq flag nil)
           );progn then it's closed
      );if
     );progn then old polyline
     (progn
      (setq   z (dxf 38 e1)
            lst (member (assoc 10 e1) e1)
      );setq 
      (if (not z) (setq z 0.0))
      (setq n 0);setq
      (repeat (length lst)
       (setq a (nth n lst))
       (if (equal 10 (car a))
           (setq    a (cons 10 (append (cdr a) (list z)))
                 lst2 (append lst2 (list a))
           );setq
           (progn
            (if (equal 42 (car a))
                (setq lst2 (append lst2 (list a)));setq then
            );if
           );progn
       );if 
      (setq n (+ n 1));setq
      );repeat
      
      (setq  b (car lst2)
           lst (list (cdr b))
      );setq
      
      (if flag 
          (setq lst2 (append lst2 (list (car lst2)))
                flag nil 
          );setq
      );if

      (setq n 1);setq
      (repeat (- (length lst2) 1)
      (setq a (nth n lst2));setq
      (if (and (equal 10 (car a))
               (equal 42 (car b))
               (not (equal 0.0 (cdr b)))
               ;added below for cloud problems
               c
               (not (equal (cdr a) (cdr c)))
          );and  
          (progn   
           (setq  p3 (pl_arc_info (cdr c) (cdr a) (cdr b))
                 lst (append lst 
                             (get_arc_points (car p3) (cdr c) (cdr a) (caddr p3) alt)
                     );append  
           );setq
          );progn then get the arc points
          (progn
           (if (equal 10 (car a))
               (setq lst (append lst (list (cdr a)));append
               );setq then
           );if 
          );progn
      );if
      (setq c b
            b a
      );setq
      (setq n (+ n 1));setq 
      );repeat
      (setq lst2 nil);setq
     );progn else lwpolyline
 );if 

 (lsttrans lst na2 code)
);defun pl_point_list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;get_arc_points
;returns a list of points that lie along an arc described 
;by the following arguments:
;takes: 
;  p1 - start point
;  p2 - end point
;  p3 - center point
; ang - delta angle of the arc
; alt - altitude (max error tolerance)
;
(defun get_arc_points ( p1 p2 p3 ang alt / sa ea lst b c d)

 (setq  b (distance p1 p2)       ;the radius
       sa (angle p1 p2)          ;the start angle
       ea (+ sa ang)             ;the end angle
 );setq
 (setq d (- ea sa));setq full delta angle of the arc in radians
 (if (not alt)
     (setq c (/ (* 2.0 pi) 9.0));then use default resolution
     (setq c (delta_ang b alt));setq else use altitute specified. 
 );if
 (setq  c (* c (/ d (abs d))));setq the delta angle increment of the loop
 
 (if (< (abs (/ d c)) 4.0)
     (setq c (/ d 4.0)
     );setq then reset c, the delta angle increment of the loop so 
                          ;at least 4 segments are used
 );if

 (repeat (+ (fix (+ (abs (/ d c))
                    0.000001
                 );plus
            );fix
            1
         );plus
 (if (not (equal (polar p1 sa b) (last lst)))
     (setq lst (append lst
                       (list (polar p1 sa b))
               );append
     );setq then
 );if
 (setq sa (+ sa c));setq
 );repeat

 (if (not (equal p3 (last lst)))
     (setq lst (append lst (list p3)));setq
 );if
 lst
);defun get_arc_points

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;takes endpoints of an arc and bulge
;returns a list containing:
; Center point
; radius
; Delta angle
; distance (arc length)
; altitude
;
(defun pl_arc_info ( p1 p2 bulge / a b c r ang s)

 (setq b bulge 
       c (distance p1 p2)
       a (abs (/ (* c b) 2.0))
       r (/ (+ (expt (/ c 2.0)
                     2.0
               );expt
               (expt a 2.0)
            );plus
            (* 2.0 a)
         );div
     ang (* 2.0 (atan (/ c 2.0)
                      (- r a)
                );atan
         );mult delta angle
       s (* ang r);the length of the arc
     ang (* ang (/ b (abs b)))
      p3 (polar p1 (angle p1 p2) (/ c 2.0))
      p3 (polar p3 
                (+ (angle p1 p2) (/ pi 2.0)) 
                (* (- r a) 
                   (/ b (abs b))
                );mult
         );polar
 );setq
 (list p3 r ang s a)
);defun pl_arc_info

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;delta_ang
;returns the delta angle of an arc with
;the specified altitude and radius
(defun delta_ang ( r a / c ang)
 (setq c (* 2.0
            (sqrt 
              (abs (- (* 2.0 r a)
                      (expt a 2.0)
                   )
              )
            )
         )
     ang (* 2.0 (atan (/ c 2.0)
                      (- r a)
                );atan
         );mult delta angle
 );setq
 ang
);defun delta_ang

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;takes center point,
;      quad point of major axis
;      quad point of minor axis
;      an angle
; returns a point on the ellipse at the specified angle
;Note: This function assumes that points a, b, and c all have the same z 
;      coord.
;
(defun calc_ellipse ( a b c a1 / d1 d2)
 ;p(u)=c+a*cos(u)+b*sin(u)
 ;p(u)=(Cx+a*cos(u))*i+(Cy+a*sin(u))*j
 (setq d1 (+ (car a)
             (* (* -1.0 (distance a b))
                (cos a1)
             )
          );plus
       d2 (+ (cadr a) 
             (* (* -1.0 (distance a c))
                (sin a1)
             )
          );plus
 );setq
 (list d1 d2 (caddr a))
);defun calc_ellipse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;takes an entity name of an ellipse and a max allowable error distance.
(defun get_ellipse_points ( na alt / sa da x a1 a2 ang e1 a b c p1 p2 p3 lst)

(setq  e1 (entget na)
        a (cdr (assoc 10 e1))
        b (cdr (assoc 11 e1))
        b (list (- (car a) (car b))
                (- (cadr a) (cadr b))
                (- (caddr a) (caddr b))
          );list
        x (cdr (assoc 210 e1))
        a (trans a na x)
        b (trans b na x)
      ang (angle a b)
       a1 (cdr (assoc 41 e1))
       a2 (cdr (assoc 42 e1))
       sa a1
);setq
(if (>= a1 a2) ;do some error checking
    (setq a2 (+ a2 pi pi))
    (progn
     (if (> (- a2 a1) (* 2.0 pi))
         (setq a2 (- a2 (* 2.0 pi)));setq then
     );if
    );progn
);if
(if alt      ;get the delta_angle for the loop below
    (setq da (abs (delta_ang (distance a b) alt)));setq
    (setq da (/ pi 4.0))
);if
(setq  b (rotate_pnt b a (* -1.0 ang))
       c (polar a
                (/ pi 2.0)
                (* (cdr (assoc 40 e1)) (distance a b))
         );polar
);setq

(while (<= sa a2)
(setq  p3 (calc_ellipse a b c sa) 
       p3 (rotate_pnt p3 a ang)
       p3 (trans p3 x 1)
      lst (append lst (list p3))
);setq
(setq sa (+ sa da))
);while
(if (not (equal sa a2))
    (setq  p3 (calc_ellipse a b c a2) 
           p3 (rotate_pnt p3 a ang)
           p3 (trans p3 x 1)
          lst (append lst (list p3))
    );setq then
);if

lst
);defun get_ellipse_points 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**M_ASSOC** Multiple-ASSOC
;TAKES:
;a  - search value for assoc
;lst- a list of sub-lists
;RETURNS: a list of all of the sublists that have 'a' as their first element
;
;	m_assoc b lst2
(defun m_assoc ( a lst / b lst2)

(while (setq b (assoc a lst));setq
(setq  lst (cdr (member b lst))
      lst2 (append lst2 (list b))
);setq
);while

lst2
);defun m_assoc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;lsttrans
;is like standard autolisp trans but takes a 
;LIST of points and returns a list of translated 
;points.
;
(defun lsttrans ( lst a b / lst2 c n)

(setq n 0);setq
(repeat (length lst)
(setq	 c (nth n lst)
	 c (trans c a b)
      lst2 (append lst2 (list c))
);setq
(setq n (+ n 1));setq
);repeat

lst2
);defun lsttrans

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TNLIST
;returns a list of the symbol names found
;in the specified table
;	
(defun tnlist ( tbna / a lst)
(if (and (equal (type tbna) 'LIST) 
         (equal (cadr tbna) 16)          
    );and
    (progn
     (setq tbna (car tbna));setq
     (while (setq a (tblnext tbna (not a))); a acts as a rewind first time
      (if (not (equal 16 (logand 16 (cdr (assoc 70 a)))))
          (setq lst (append lst 
                            (list (cdr (assoc 2 a)))
                    );append
          );setq
      );if
     );while
    );progn then local only
    (progn
     (while (setq a (tblnext tbna (not a))); a acts as a rewind first time
      (setq lst (append lst 
                       (list (cdr (assoc 2 a)))
                );append
      );setq
     );while
    );progn else
);if 
 lst
);defun tnlist

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sets current ucs to be parallel to the extrusion vector 
;specified by p1
;
;This function is used by extrim and exchprop
;
(defun ucs_2_ent ( p1 / )
 (setq p1 (strcat "*"
                  (rtos (car p1) 2 8) ","
                  (rtos (cadr p1) 2 8) ","
                  (rtos (caddr p1) 2 8)
          );strcat
 );setq
 (command "_.ucs" "_za" "*0.0,0.0,0.0" p1)
);defun ucs_2_ent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes a layer name and returns 
;True if the layer is locked, and nil if unlocked.
;
(defun b_layer_locked ( la / na e1)
 (setq na (tblobjname "layer" la)
       e1 (entget na)
 );setq
 (equal 4 
        (logand 4 (cdr (assoc 70 e1)))
 );equal
);defun b_layer_locked

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;takes an element and a list
;if the element is contained in the list
;   then position of the first occurrance is returned (integer)
;   else nil is returned
;
;      position b
(defun position ( a lst / b)
 (if (setq b (member a lst));setq
     (progn
      (setq b (- (length lst) (length b)));setq
     );progn then
 );if
 b
);defun position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**MPOPLST Make-POPup-LST takes the key of a dcl tile 
;and a list of strings
;
(defun mpoplst ( a lst / n )
 (start_list a 3)
 (setq n 0);setq
 (repeat (length lst)
  (add_list (nth n lst))
  (setq n (+ n 1));setq
 );repeat
 (end_list)
);defun mpoplst

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Just a little util to see what lisp commands are loaded into memory.
;also has an option that calls appload.
;
(defun c:lsp ( / lst n a b wc)
 (initget "Commands Functions Variables Load") 
 (setq a (getkword "\nCommands/Functions/Variables/Load: "))
 (if (and a
          (not (equal a "Load"))
     );and
     (setq wc (getstring (strcat "\n" a " to list <*>: "))) 
 );if
 (if (or (not wc) 
         (equal wc "")
     );or 
     (setq wc "*")
     (setq wc (strcase wc));setq
 );if
 (cond 
   ((equal a "Commands")
    (progn  
     (setq lst (atoms-family 1)
           lst (acad_strlsort lst)
     );setq
     (setq n 0);setq
     (repeat (length lst)
      (setq a (strcase (nth n lst)));setq
      (if (and (equal "C:" (substr a 1 2))
               (wcmatch (substr a 3) wc)
          );and
          (princ (strcat "\n" (substr a 3)))
      );if
     (setq n (+ n 1));setq
     );repeat
    );progn then
   );cond 1 
   ((equal a "Functions")
    (progn  
     (setq lst (atoms-family 1)
           lst (acad_strlsort lst)
     );setq
     (setq n 0);setq
     (repeat (length lst)
      (setq a (strcase (nth n lst))
            b (eval (read a))
      );setq
      (if (and (wcmatch a wc)
               b
               (equal 'LIST (type b))
               (equal 'LIST (type (cdr b)));make sure it's not a dotted pair.
               (> (length b) 1)
               (or (equal 'LIST (type (car b)))
                   (not (car b))
               );or
          );and
          (princ (strcat "\n" a))
      );if
     (setq n (+ n 1));setq
     );repeat
    );progn then
   );cond 2 
   ((equal a "Variables")
    (progn  
     (setq lst (atoms-family 1)
           lst (acad_strlsort lst)
     );setq
     (setq n 0);setq
     (repeat (length lst)
      (setq a (strcase (nth n lst))
            b (eval (read a))
      );setq    
      (if (and 
           (not (and (equal "C:" (substr a 1 2))
                     (wcmatch (substr a 3) wc)
                );and
           );not a command
           (not (and (wcmatch a wc)
                     (equal 'LIST (type b))
                     (equal 'LIST (type (cdr b)));make sure it's not a dotted pair.
                     (> (length b) 1)
                     (or (equal 'LIST (type (car b)))
                         (not (car b))
                     );or
                );and 
           );not a function
           (wcmatch a wc)
           (not (equal 'SUBR (type b)))
          );and
          (princ (strcat "\n" a))
      );if
     (setq n (+ n 1));setq
     );repeat
    );progn then
   );cond 4 
   ((equal a "Load") 
    (c:appload)
   );cond 5
 );cond close
 (princ)
);defun c:lsp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;clear_prev_ss - Clears the previous selection set in AutoCAD by
;executing the select command and then performing an undo 1.
; NOTE: This function does not verify that undo is enabled and will
;           fail if undo is disabled.
(defun clear_prev_ss ()

(if (entnext)
    (progn
     (command "_.select" (entlast) (entnext))
     (while (not (equal (getvar "cmdnames") "")) (command ""))
     (command "_.undo" "1");clear any selection sets
    );progn then
);if


);defun clear_prev_ss

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes: A ssget type of filter list and a flag.
;If the flag is true then locked layer selection is allowed. 
;
;Returns: A single entity name that matches the filter list
;
(defun single_select ( flt flag / a p1 p2 ss ss2 flag2 glst)

(setq glst (bns_groups_unsel));turn off group selection and save a list 
                              ;of group names that were modified. 
(while (not flag2)
(setvar "highlight" 0)
(clear_prev_ss)
(setvar "highlight" 1)
(command "_.select" "_si")
(setvar "cmdecho" 1)
(command pause)

(setq ss2 (ssget "_p")
       p1 (getvar "lastpoint")
       p1 (trans p1 1 (getvar "viewdir"))
        a (* (getvar "pickbox") (pixel_unit))
       p2 (list (- (car p1) a) (- (cadr p1) a) 0.0)
       p1 (list (+ (car p1) a) (+ (cadr p1) a) 0.0)
       p1 (trans p1 (getvar "viewdir") 1)    
       p2 (trans p2 (getvar "viewdir") 1)    
);setq
(if (and ss2
         (or (setq ss (ssget "_p" flt))
             (setq ss (ssget "_c" p1 p2 flt))   
         );or
    );and 
    (progn
     (setq ss (ssname ss 0))
     (if flag
         (setq flag2 T)
         (progn
          (if (b_layer_locked (cdr (assoc 8 (entget ss))))
              (progn
               (setq flag2 nil) 
               (princ "\nThat object is on a locked layer!")
              );progn
              (setq flag2 T);else got something and its on an UN-locked layer
          );if
         );progn else locked layer selection is not allowed
     );if
    );progn
    (progn
     (if ss2
         (princ "\nInvalid selection.")
         (setq flag2 T
                  ss nil
         );they just exited with enter
     );if
    );progn 
);if
(setvar "cmdecho" 0)
);while

(bns_groups_sel glst);restore group selection.


ss
);defun single_select

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ss_visible ( ss code / na e1 n)
 (if ss
     (progn
      (setq n 0)
      (repeat (sslength ss)
       (setq na (ssname ss n)
             e1 (entget na)
       );setq
       (if (not (assoc 60 e1))
           (setq e1 (append e1 (list (cons 60 code))));setq then
           (setq e1 (subst (cons 60 code) (assoc 60 e1) e1));setq else
       );if
       (entmod e1) 
       (entupd na)
       (setq n (+ n 1));setq
      );repeat 
     );progn
 );if
);defun ss_visible


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rotate 'pnt' from a base point of 'p1' and through an angle 
;of 'ang' (in radians)
(defun rotate_pnt ( pnt p1 ang / )
 (polar p1 
        (+ (angle p1 pnt) ang) 
        (distance p1 pnt) 
 );polar
);defun rotate_pnt 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;scale 'pnt' from a base point of 'p1' by a factor of fact 
(defun scale_pnt ( pnt p1 fact / )
 (polar p1
        (angle p1 pnt)
        (* fact (distance p1 pnt))
 );polar
);defun scale_pnt 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**PSTRIP** function that strips the path off of file name string
(defun pstrip ( a / b)
 (cond
  ((setq b (strsea "\\" a));setq
   (setq b b);setq
  );cond #1
  ((setq b (strsea "/" a));setq
   (setq b b);setq
  );cond #2
  (T
   (setq b (list 0));setq
  );cond #3
 );cond close
 (setq a (substr a (+ (last b) 1) (strlen a)));setq
);defun pstrip

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**XSTRIP** function that strips the extention off of any
; file name provided as a string if the filename provided does not
; have an extention then it is returned as is
;
;       xstrip st
(defun xstrip ( fna / st)
 (if (and (setq st (strsea "." fna));setq test if there is an extension
          (<= (- (strlen fna) 3) (last st))
     );and
     (setq fna (substr fna
                       1
                       (- (last st) 1)
               );substr
     );setq
 );if
 fna
);defun xstrip

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun strsea (a b / c n)
 (cond
  ((equal "" a)
   (setq c nil)
  );cond #1
  ((not (equal (type b) (type "1")))
   (progn (print "ARGUMENT NOT A STRING!!!!")
          (print b)
          (setq c nil)
   );progn
  );cond #2
  ( T
    (progn
     (setq n 1);setq
     (while (>=
               (+ (- (strlen b) n) 1)
                (strlen a)
            );test while arg.
     (if (equal
                (substr b n (strlen a))
                a
         );equal
         (setq c (append c (list n))
               n (-
                    (+ n
                       (strlen a)
                    );plus
                    1
                 );minus
         );setq
     );if
     (setq n (+ n 1));setq
     );while
    );progn
  );cond #3
 );cond close
 c
);defun strsea

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;StrReplace function
;takes three string arguments:
;i.e. (strreplace "old" "new" "the old car is cool!")
;returns "the new car is cool!"
;
(defun StrReplace ( b a c / d n )
(setq d (strsea b c)
      n 0
);setq
(repeat (length d)
(setq c (strcat
	 (substr c
		 1
		 (+
		    (*
		       (- (strlen a) (strlen b))
		       n
		    );mult
		    (- (nth n d) 1)
		 );plus
	 );substr
	 a
	 (substr c
		 (+ (nth n d)
		    (*
		       (- (strlen a) (strlen b))
		       n
		    );mult
		    (strlen b)
		 );plus
	 );substr
	);strcat
);setq
(setq n (+ n 1));setq
);repeat
 c
);defun StrReplace

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Makes a selection set from all entities after na
;	newsel ss
(defun newsel ( na / ss e1)

(if na 
    (setq na (entnext na));setq
    (setq na (entnext));setq
);if
(setq ss (ssadd))
(while na 
(setq e1 (entget na));setq
(if (and (not (equal "VERTEX" (cdr (assoc 0 e1))
	 )    );not equal
	 (not (equal "SEQEND" (cdr (assoc 0 e1))
	 )    );not equal
    );and
    (setq ss (ssadd na ss));setq
);if
(setq na (entnext na));setq
);while

ss
);defun newsel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun b_purge (bna / )
(if (and bna
         (tblobjname "block" bna)
    );and
    (progn
     (command "_.purge" "_block" bna)
     (while (wcmatch (getvar "cmdnames") "*PURGE*")
      (command "_y")
     );while
    );progn
);if
);defun b_purge

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun vp_on_screen ( na / vp e1 a b c p1 p2 p3 p4)
 (if (setq vp (not (equal (getvar "cvport") 1)))
     (command "_.pspace")
 );if
 (setq e1 (entget na)
        a (cdr (assoc 40 e1))
        b (cdr (assoc 41 e1))
       p1 (cdr (assoc 10 e1))
       p1 (list (- (car p1) (/ a 2.0))
                (- (cadr p1) (/ b 2.0))
                (caddr p1)
          );list
       p2 (list (+ (car p1) a)
                (+ (cadr p1) b)
                (caddr p1)
          );list
       p1 (trans p1 na 1)
       p2 (trans p2 na 2)
       p3 (viewpnts)
        c (* 0.0095 (distance (car p3) (cadr p3)))
       p4 (cadr p3)
       p3 (car p3)
       p3 (list (+ (car p3) c) (+ (cadr p3) c) (caddr p3))
       p4 (list (- (car p4) c) (- (cadr p4) c) (caddr p4))
 );setq
 (if vp
     (command "_.mspace")
 );if
 (or 
     (and (>= (car p1) (car p3))
          (>= (cadr p1) (cadr p3))
          (<= (car p1) (car p4))
          (<= (cadr p1) (cadr p4))
     );and
     (and (>= (car p2) (car p3))
          (>= (cadr p2) (cadr p3))
          (<= (car p2) (car p4))
          (<= (cadr p2) (cadr p4))
     );and
     (inters p1 (list (car p2) (cadr p1) (caddr p1)) ;bottom hor
             p3 (list (car p3) (cadr p4) (caddr p1)) ;left vert
     )
     (inters p1 (list (car p2) (cadr p1) (caddr p1)) ;bottom hor
             (list (car p4) (cadr p3) (caddr p3)) p4 ;right vert
     )
     (inters (list (car p1) (cadr p2) (caddr p1)) p2 ;top hor
             p3 (list (car p3) (cadr p4) (caddr p3)) ;left vert
     )
     (inters (list (car p1) (cadr p2) (caddr p1)) p2 ;top hor
             (list (car p4) (cadr p3) (caddr p3)) p4 ;right vert
     )
      (inters p3 (list (car p4) (cadr p3) (caddr p3)) ;bottom hor
             p1 (list (car p1) (cadr p2) (caddr p1)) ;left vert
     )
     (inters p3 (list (car p4) (cadr p3) (caddr p3)) ;bottom hor
             (list (car p2) (cadr p1) (caddr p1)) p2 ;right vert
     )
     (inters (list (car p3) (cadr p4) (caddr p3)) p4 ;top hor
             p2 (list (car p1) (cadr p2) (caddr p1)) ;left vert
     )
     (inters (list (car p3) (cadr p4) (caddr p3)) p4 ;top hor
             (list (car p2) (cadr p1) (caddr p1)) p2 ;right vert
     )
 );or
);defun vp_on_screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;returns a list of two elements:
;(vportnumber nil)
;or
;(nil "error msg")
;Where vportnumber is the next available active viewport 
;with perspective turned off.
;                         
(defun mspace_pick_ok ( / alt_viewport ss3 ss na e1 a na2 flag msg)

(setq ss3 (ssget "_p"))

 ;local function definition
 (defun alt_viewport ( ss na2 / n na e1 a msg flag)
  (setq n 0)
  (while (< n (sslength ss))
   (setq na (ssname ss n)
         e1 (entget na '("ACAD"))
          a (cdr (car (cdr (assoc -3 e1))))
          a (cdr (member (assoc 1070 a) a))
          a (cdr (assoc 1070 a))
   );setq
   (if (and (not (equal 1 (logand 1 a)))
            (not (equal na na2))
            (not (equal 1 (cdr (assoc 69 e1))))
            (>= (cdr (assoc 68 e1)) 2)
            (vp_on_screen na) 
       );and
       (setq flag (cdr (assoc 69 e1))
                n (sslength ss)
       );setq then
   );if
   (setq n (+ n 1));setq                
  );while
  (if (not flag)  
      (setq msg
            "** No non-perspective model space viewports available **"
      );setq
  );if
  (list flag msg)
 );defun alt_viewport

(if (equal 0 (getvar "tilemode"))
    (progn
     (setq ss (ssget "_x" (list '(0 . "VIEWPORT") '(67 . 1) 
                               (cons 69 (getvar "cvport"))
                         );list
              );ssget
           na (ssname ss 0)
           e1 (entget na '("*"))
            a (cdr (assoc 68 e1))
           ;p1 (viewpnts)
           ;p2 (cadr p1)
           ;p1 (car p1)
     );setq
     (if (equal 1 (getvar "cvport"))
         (setq a (+ a 1));setq
     );if
     (if (<= a 1)
         (setq a 2)
     );if 
     (setq ss (ssget "_x" 
                          (list '(0 . "VIEWPORT") '(67 . 1) 
                               '(-4 . ">=") (cons 68 2)
                          );list
              );ssget
     );setq
     (if (and ss
              (setq na2 (ssget "_p" (list '(0 . "VIEWPORT") '(67 . 1) 
                                          (cons 68 a)
                                    );list
                        );ssget
              );setq
         );and
         (setq na2 (ssname na2 0)) 
     );if
    );progn then 
);if 
(if (and (not (equal 1 (logand 1 (getvar "viewmode"))))
         (or (equal 1 (getvar "tilemode"))
             (not (equal 1 (getvar "cvport")))  
         );or
    );and
    (setq flag (getvar "cvport"));then
    (progn
     (if (equal 1 (getvar "cvport"))
         (progn
          (if na2
              (progn
               ;Check the viewport for viewmode=perspective
               (setq na na2
                     e1 (entget na '("ACAD"))
                      a (cdr (car (cdr (assoc -3 e1))))
                      a (cdr (member (assoc 1070 a) a))
                      a (cdr (assoc 1070 a))
               );setq
               (if (or (equal 1 (logand 1 a))
                       (<= (cdr (assoc 68 e1)) 1)
                       (not (vp_on_screen na))
                   );or
                   (progn
                    (setq flag (alt_viewport ss na2)
                           msg (cadr flag)
                          flag (car flag)
                    );setq
                   );progn then this one has perspective turned on so loop through 
                    ; ss to see if there are any others that are on with perspective off
                   (progn
                    (setq flag (cdr (assoc 69 e1)));else    
                   );progn else
               );if 
              );progn then there is at least one other viewport that is on
              (setq msg "\n** There are no active Model space viewports **");setq
          );if
         );progn then in paper space so check to see if
          ;there is a valid viewport available
         (progn
          (if (equal 1 (getvar "tilemode"))
              (setq msg "\n** That command may not be invoked in a perspective view **")
              (progn
               (setq flag (alt_viewport ss na2)
                      msg (cadr flag)
                     flag (car flag)
               );setq
              );progn else
          );if
         );progn else in mspace and current viewport has perspective on
     );if
    );progn else 
);if
(if ss3
    (command "_.select" ss3 "")
);if
(list flag msg)
);defun mspace_pick_ok


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;takes a point and a list of points that form a closed boundary
;returns true if the point is within the closed loop.
;        nil if not or if the point is directly on the boundary
(defun point_inside ( p1 lst dst / s s2 p2 n a b c d x)

(setq p2 (polar p1 
                (+ (angle p1 (car lst)) (/ pi 2.0)) ;0.0 
                dst
         )
);setq

(setq x 0)
(if (not (member p1 lst))
    (progn
     (setq  a (car lst)
            s (what_side a p1 p2)
           s2 s
     );setq
     (setq n 1)
     (while (< n (length lst))
     (setq  b (nth n lst)
            d (what_side b p1 p2)
     );setq
     (if (and (not (equal 0.0 d))
              (not (equal a b 0.0001))
         );and
         (setq s2 d)
     );if    
     (if (and (not (equal a b 0.0001))
              (setq c (inters p1 p2 a b))
              (not (equal p1 c 0.0001))
              (/= s s2)
              (not (equal s 0.0))
         );and
         (setq x (+ x 1));setq
         (progn
          (if (equal p1 c 0.0001)
              (progn
               (setq n (length lst)
                     x 2
               );jump out cuz point p1 is on the boundary, so return nil
              );progn 
          );if
         );progn
     );if
     (setq a b
           s s2
     );setq
     (setq n (+ n 1));setq
     );while
    );progn then
);if

;if x is even or 0 then p1 is outside
(not (equal x (* 2 (/ x 2))))
);defun point_inside

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p1 is a point
;p2 and p3 are points that form a line segment
;returns  1 is p1 is on one side 
;        -1 if on the other side
;         0 if on the line
;
(defun what_side ( p1 p2 p3 / a dx dx1 dy dy1)
(setq  dx (- (car p3) (car p2))
       dy (- (cadr p3) (cadr p2))
      dx1 (- (car p1) (car p2))
      dy1 (- (cadr p1) (cadr p2))
);setq
(setq a (- (* dx dy1) (* dy dx1))
      a (rtos a 2 6)
      a (atof a)
);setq
(if (not (equal 0.0 a))
    (setq a (/ a (abs a)));setq
);if
a
);defun what_side

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**SSTRIP** function that strips the spaces off of the begining and 
;end of any string
 (defun sstrip ( a / )
  (while (and (not (equal "" a))
              (equal (substr a (strlen a));substr
                     " "
              );equal
         );and
   (setq a (substr a
                   1
                   (- (strlen a) 1)
           );substr
   );setq
  );while
  (while (and (not (equal "" a))
              (equal (substr a 1 1) " ")
         );and
   (setq a (substr a 2));setq
  );while
  a
 );defun sstrip

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getfile is pretty much like getfiled.
;getfile takes the same arguments as getfiled, but it 
;also has a command line interface allowing script access.
;NOTE: One difference between this function and the 
;getfiled function is: The "full path" to the file is 
;always returned when specifying an existing file.
;
(defun getfile ( str def ext flag / p f x a n fna lst)

(if (not ext)
    (setq ext "*") 
);if
(if (not def);default file name.
    (setq def (xstrip (getvar "dwgname")));setq
);if
(if (not (strsea "*" ext))
    (setq lst (str2lst ";" (strcase ext)))
);if
(if (or (equal 4 (logand 4 (getvar "cmdactive")))
        (equal 0 (getvar "filedia"))
    );or
    (progn
     (while (not fna)
      (setq fna (getstring T (strcat "\n" str " <" def ">: "))
            fna (sstrip fna)
      );setq 
      (if (equal "" fna)
          (setq fna def)
      );if
      (setq f (xstrip (pstrip fna))
            p (substr fna 1 
                      (- (strlen fna) (strlen (pstrip fna)))
              );substr
            x (substr fna (+ 1 (strlen (xstrip fna)))) 
      );setq 
      (if (and lst
               (equal x "")
               (not (equal fna "~"))
          );and
          (setq fna (strcat fna 
                            "." (strcase (car lst) T)
                    );strcat
          );setq
          (progn
           (if (and (not (equal x ""))
                    (not (equal ext "*"))
                    (not (member (strcase (substr x 2)) lst));not
               );and
               (progn
                (princ "\nInvalid filename")
                (setq fna nil)
               );progn
           );if
          );progn 
      );if
      (if (and fna
               (not (equal 1 (logand 1 flag)))
          );and
          (progn
           (setq a (findfile fna));setq
           (if (and (not (equal fna "~"))
                    (not a)
                    (equal x "")
                    lst
               );and
               (progn 
                (setq n 0)
                (while (and (not a)
                            (< n (length lst))
                       );and
                (setq a (strcat (xstrip fna) "." (strcase (nth n lst) T))
                      a (findfile a)
                );setq
                (setq n (+ n 1));setq
                );while
                (if (not a)
                    (progn
                     (princ (strcat "\nCannot find file: " fna))
                     (setq fna nil)
                    );progn
                    (setq fna a)
                );if 
               );progn then check for exist with other provided file extentions
               (progn
                (cond
                 ((equal fna "~")
                  (setq fna (getfiled str def ext flag))
                  (if fna
                      (setq fna (findfile fna));setq
                  );if 
                 )  
                 (a
                  (setq fna a)
                 )
                 (T
                  (princ (strcat "\nCannot find file: " fna))
                  (setq fna nil)
                 )
                );cond
               );progn else
           );if
          );progn then force entry of an existing file name. 
          (progn
           (if (and fna
                    (equal fna "~")
               );and
               (setq fna (getfiled str def ext flag));setq
               (progn
                (cond 
                 ((and fna
                       (not (equal ext "*"))
                       x
                       (> (strlen x) 0)
                       (not (member (strcase (substr x 2)) lst));not
                  );and
                  (princ "\nInvalid filename")
                  (setq fna nil)
                 );cond #1
                 ((and fna
                       (findfile fna)
                  );and 
                  (initget "Yes No")
                  (setq a (getkword "\nThat file already exists! Overwrite? <N>: "))
                  (if (not (equal a "Yes"))
                      (setq fna nil)
                  );if
                 );cond #2 
                );cond close
               );progn
           );if
          );progn else ask for a new file name and give overwrite warnings.
       );if
      );while
    );progn then command line mode
    (progn
     (setq fna (getfiled str def ext flag))
     (if fna 
         (setq fna (findfile fna));setq 
     );if
    );progn else
);if

fna
);defun getfile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Str2lst - string to list
;Takes two string arguments. A delimiter or token and the main string.
;Returns a list of sub-strings from the main string.
;
(defun str2lst ( a b / n c lst lst2 leng)

(setq lst (strsea a b)
        n 0
);setq
(if lst
    (progn
     (setq c (substr b
		     1
		     (-
			(nth 0 lst)
			1
		     );minus
	     );substr
     );setq
     (setq lst2 (append lst2 (list c)));setq
     (repeat (- (length lst) 1)
     (setq leng (-
		   (nth (+ n 1) lst)
		   (nth n lst)
		   (strlen a)
		);minus
	     c	(substr b
			(+
			   (nth n lst)
			   (strlen a)
			);plus
			leng
		);substr
     );setq
     (setq lst2 (append lst2 (list c)));setq
     (setq n (+ 1 n));setq
     );repeat
     (setq c (substr b
		     (+
			(nth n lst)
			(strlen a)
		     );plus
	     );substr
     );setq
     (setq lst2 (append lst2 (list c)));setq
    );progn then
    (setq lst2 (append lst2 (list b)));setq else
);if

lst2
);defun str2lst

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;cross_prod returns the cross product (or normal) of two vectors.
(defun cross_prod (p1 p2)
 (list
  (-
     (* (cadr p1) (caddr p2))
     (* (cadr p2) (caddr p1))
  )
  (* -1
      (-
         (* (car p1) (caddr p2))
         (* (car p2) (caddr p1))
      )
  )
  (-
     (* (car p1) (cadr p2))
     (* (car p2) (cadr p1))
  )
 )
);defun cross_prod

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sets the ucs such that the origin is at the upper left corner of the 
;mtext object and the x axis is aligned with the mtext rotation.
;
(defun bns_ucs_2_mtext ( na / e1 p1 p2 p3 p4 )
 (setq e1 (entget na)
       p1 (cdr (assoc 10 e1))
       p2 (cdr (assoc 210 e1))
       p3 (cdr (assoc 11 e1))
       p1 (trans p1 na 1)
       p2 (trans p2 na 1 T)
       p3 (trans p3 na 1 T)
       p4 (cross_prod p2 p3)
       p2 (list (+ (car p1) (car p2))
                (+ (cadr p1) (cadr p2))
                (+ (caddr p1) (caddr p2))
          );list
       p3 (list (+ (car p1) (car p3))
                (+ (cadr p1) (cadr p3))
                (+ (caddr p1) (caddr p3))
          );list
       p4 (list (+ (car p1) (car p4))
                (+ (cadr p1) (cadr p4))
                (+ (caddr p1) (caddr p4))
          );list
 );setq
 (command "_.ucs" "_3p" p1 p3 p4)
);defun bns_ucs_2_mtext

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --------------------- MTEXTBOX FUNCTION ------------------------
;   This function returns a list of four points describing the 
;   bounding box of the mtext (MTXT).
; ----------------------------------------------------------------
(defun bns_mtextbox (MTXT / na WDTH HGHT INS JUST ANG P1 P2 P3 P4)
  (if (and (listp MTXT) (= "MTEXT" (cdr (assoc 0 MTXT))))
    (progn
      (setq WDTH (cdr (assoc 42 MTXT))
            HGHT (cdr (assoc 43 MTXT))
              na (cdr (assoc -1 mtxt)) 
             INS (trans (cdr (assoc 10 MTXT)) 
                        na ;changed by rk from 0
                        1
                 );trans
            JUST (cdr (assoc 71 MTXT))
            ANG  0.0 ;changed by rk from (cdr (assoc 50 MTXT)) because ucs_2_mtext
                     ;always aligns the rotation such that it is 0.
      )
      (cond
        ((= JUST 1)
          (setq P1 (polar INS (- ANG (* Pi 0.5)) HGHT) ; lower-left
                P2 (polar P1 ANG WDTH)                 ; lower-right
                P3 (polar INS ANG WDTH)                ; upper-right
                p4 INS                                 ; upper-left
          )
        )
        ((= JUST 2)
          (setq P3 (polar INS ANG (/ WDTH 2))
                P4 (polar INS (+ ANG Pi) (/ WDTH 2))
                P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                P2 (polar P1 ANG WDTH)
          )
        )
        ((= JUST 3)
          (setq P3 INS
                P4 (polar INS (+ ANG Pi) WDTH)
                P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                P2 (polar P1 ANG WDTH)
          )
        )
        ((= JUST 4)
          (setq P4 (polar INS (+ ANG (* Pi 0.5)) (/ HGHT 2))
                P3 (polar P4 ANG WDTH)
                P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                P2 (polar P1 ANG WDTH)
          )
        )
        ((= JUST 5)
          (setq P4 (polar INS (- ANG Pi) (/ WDTH 2))
                P4 (polar P4 (+ ANG (* Pi 0.5)) (/ HGHT 2))
                P3 (polar P4 ANG WDTH)
                P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                P2 (polar P1 ANG WDTH)
          )
        )
        ((= JUST 6)
          (setq P3 (polar INS (+ ANG (* Pi 0.5)) (/ HGHT 2))
                P4 (polar P3 (+ ANG Pi) WDTH)
                P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                P2 (polar P1 ANG WDTH)
          )
        )
        ((= JUST 7)
          (setq P1 INS
                P2 (polar P1 ANG WDTH)
                P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
          )
        )
        ((= JUST 8)
          (setq P1 (polar INS (+ ANG Pi) (/ WDTH 2))
                P2 (polar P1 ANG WDTH)
                P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
          )
        )
        ((= JUST 9)
          (setq P2 INS
                P1 (polar INS (+ ANG Pi) WDTH)
                P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
          )
        )
      );cond close
    );progn then it's metxt
    (prompt "\nEntity Not Mtext!")
  );if
  (list P1 P2 P3 P4)
);defun bns_mtextbox

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;---------------------------------------------------------------
;mk_nobody defines an anonymous block.
;Takes a selection set of entities and a block name.
;If the block name (bna) is nil then a new anonymous block 
; will be created. Otherwise the block will be re-defined.
;Also note that the bna argument can be passed in a list that has 
;a two elements (bna flag), where a non-nil 'flag' will tell mk_nobody 
;to delete the entities found in ss after they are placed in the 
;block table.
; 
;RETURNS an anonymous block name.
(defun mk_nobody ( ss bna / bylayer_fx flag n na e1)

 ;local function
 (defun bylayer_fx ( e1 / )
  (if (not (assoc 62 e1)) ;add color and linetype info if bylayer
      (setq e1 (append e1 (list '(62 . 256))));setq then force bylayer
  );if
  (if (not (assoc 6 e1))
      (setq e1 (append e1 (list '(6 . "BYLAYER"))));setq then force bylayer
  );if
  e1
 );defun bylayer_fx

(if (equal (type bna) 'LIST)
    (setq flag (cadr bna)
           bna (car bna)
    );setq then
);if
(if (not bna)
    (setq bna "*T999")
);if
     
(entmake nil)
(setq bna (entmake (list '(0 . "BLOCK")
                         (cons 2 bna)
                         '(10 0.0 0.0 0.0)
                         '(70 . 1)
                         (cons 3 bna)
                   );list
          );entmake
);setq
(setq n 0);setq
(repeat (sslength ss)
 (setq na (ssname ss n)
       e1 (entget na '("*"))
       e1 (rem_group -1 e1)
       e1 (rem_group 5 e1)
       e1 (bylayer_fx e1)
 );setq
 (if flag
     (entdel na);remove the entity
 );if
 (entmake e1)
 (if (equal '(66 . 1) (assoc 66 e1))
     (progn
      (setq na (entnext na)
            e1 (entget na)
            e1 (rem_group -1 e1)
            e1 (rem_group 5 e1)
            e1 (bylayer_fx e1)
      );setq 
      (while (and na
                  (not (wcmatch (cdr (assoc 0 e1)) "*END*"))
             );and 
       (entmake e1)
       (setq na (entnext na)
             e1 (entget na)
             e1 (rem_group -1 e1)
             e1 (rem_group 5 e1)
             e1 (bylayer_fx e1)
       );setq 
      );while           
      (entmake e1)
     );progn then
 );if
(setq n (+ n 1));setq
);repeat
(setq bna (entmake (list (cons 0 "ENDBLK"))));setq

bna
);defun mk_nobody

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun rem_group ( a e1 / n e2 b) 
 (setq n 0)
 (repeat (length e1)
 (setq b (nth n e1))
 (if (not (equal a (car b)))
     (setq e2 (append e2 (list b)));setq
 );if
 (setq n (+ n 1));setq
 );repeat
 e2
);defun rem_group

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ---------------------- MAKGROUP FUNCTION -----------------------
;   This will create a selectable unnamed group using the entities 
;   in the list LST, and give it the description DESC. 
;
;  It takes a list of entity names or selection sets.
;
; ----------------------------------------------------------------
  (defun bns_makgrp (LST DESC / EN)
    (command "_.-group" "_create" "*" DESC)
    (foreach EN LST (command EN))
    (command "")
  );defun bns_makgrp

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun spinner ( / )
  (if (not #spin)
      (setq #spin "-")
  );if
  (cond 
   ((equal #spin "-") (setq #spin "\\"))
   ((equal #spin "\\") (setq #spin "|"))
   ((equal #spin "|") (setq #spin "/"))
   (T (setq #spin "-"))
  );cond close
  (princ (strcat (chr 8) #spin))
 );defun spinner

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bns_AUTOLOAD - Autoloads a specified file and registers the specified 
;function with the AutoCAD help engine. bns_autoload can handle the 
;following file types: lsp, mnl, arx and exe.
;
;Takes a single argument that is a list of arguments.
;i.e. (bns_autoload (list "myfilename" 
;                         "(myfunction arg1 arg2...)" 
;                         "helpfile" 
;                         "topic"
;                   );list
;     );bns_autoload
;
;NOTES: 1. You must specify your function name and its arguments as a STRING! 
;          (as shown above)
;       2. If the filename specified has no extention then the file type is 
;          assumed to be "lsp".
;       3. If a lisp file is specified and the function specified is 
;          non-nil then the file is assumed to be already loaded and no 
;          autoloading stub function will defined.
;
(defun bns_autoload ( lst / flag len funcna ext a n lst2 fna func hlp topic)

;extract the arguments from lst
(setq lst2 (list 'fna 'func 'hlp 'topic))
(setq n 0)
(repeat (min (length lst) (length lst2))
 (set (nth n lst2) (nth n lst))
(setq n (+ n 1));setq
);repeat

(if (and fna func                   ;be sure the arguments are cool cuz we're flying
         (equal 'STR (type fna))    ;without a net
         (equal 'STR (type func))
         (equal (substr func 1 1) (chr 40))
    );and
    (progn

     (setq len (strlen func));setq
     (setq n 2)
     (while (and (< n len)  ;loop through func to get the function name.
                 (setq a (substr func n 1))
                 (not (equal a " "))
                 (not (equal a (chr 9)))
                 (not (equal a (chr 41)))
            );and
      (setq n (+ n 1));setq
     );while
     (setq funcna (substr func 2 (- n 2)));setq
     (if (and (setq flag (not (eval (read funcna))))
              (setq flag (not (member (strcase funcna T) (arx))));setq
         );and
         (progn 
          (setq  fna (strcase fna)
                 ext (substr fna (+ 1 (strlen (xstrip fna))));get the file extention
                func (strcase func)
          );setq 
          (if (equal ext "")
              (setq ext ".LSP"
                    fna (strcat fna ".LSP")
              );setq then if no extention then assume it's a lisp file
          );if
          (if (or (not (equal "C:" (substr funcna 1 2)))
                  (equal hlp "")
                  (equal topic "")
              );or 
              (setq   hlp nil
                    topic nil
              );setq
          );if

          (cond
           ((or (equal ext ".LSP") (equal ext ".MNL"))
            (bns_lsp_autoload fna func funcna)
           );cond #1 load lisp file
           ((equal ext ".ARX")  
            (bns_arx_autoload fna func funcna)
           );cond #2 arxload an app
           ((equal ext ".EXE")
            ;(bns_startapp);;;to be added.
           );cond #3 start an app
          );cond close   
         
          (if (and hlp topic)
              (setfunhelp funcna hlp topic)
          );if
         );progn then it's not already loaded.
     );if 
    );progn then got the min number of args with proper type
    (progn
     (if (not flag) 
         (princ "\nIncorrect call to bns_autoload.");then 
         ;else flag is true then the function is already present
     );if
     
     (if (not (equal (substr func 1 1) (chr 40)))
         (princ "\nNeed parenthesies around function name and arguments.")
     );if 
     
    );progn else do not create a defun for the function
);if
(princ)
);defun bns_autoload

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bns_lsp_autoload ( fna func funcna / args tmp)

(setq func (read func)
      args (append (cdr func)
                   (list '/ 'rs 'stub 'ret)
           );append
       tmp (list args
                 (list 'if
                       (list 'and
                             (list '>= 
                                   (list 'strlen funcna) 
                                   2
                             );list
                             (list 'equal "C:"
                                   (list 'strcase 
                                         (list 'substr funcna 1 2) 
                                   );list
                             );list
                       );list
                       '(princ "\nInitializing...\n")
                 );list
                 (list 'setq 'stub (car func))
                 (list 'setq 'rs
                       (list 'load fna "Failed")
                 );list
                 (list 'if 
                       (list 'and
                             (list 'not 
                                   (list 'equal 'rs "Failed")
                             );list  
                             (list 'not 
                                   (list 'equal 
                                         (car func)
                                         'stub
                                   )
                             )
                       );list 
                       (list 'setq 'ret
                              func           ;then run it
                       );list
                       (list 'progn
                        (list 'if 
                              (list 'equal 'rs "Failed")
                              (list 'princ 
                                    (list 'strcat "\nError loading file: " fna)
                              );list
                              (list 'princ 
                                    (list 'strcat "\nError. Function \"" 
                                                  funcna 
                                                  "\" not defined in : \"" 
                                                  fna "\"."
                                    )
                              )
                        );list
                        '(setq ret (princ)) 
                       );list else describe the error
                 );list
                 'ret
           );list
);setq
(set (car func) tmp)

);defun bns_lsp_autoload

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun bns_arx_autoload ( fna func funcna / args tmp)

(setq func (read func)
      args (append (cdr func)
                   (list '/ 'rs 'stub 'ret)
           );append
       tmp (list args
                 (list 'if
                       (list 'and
                             (list '>= 
                                   (list 'strlen funcna) 
                                   2
                             );list
                             (list 'equal "C:"
                                   (list 'strcase 
                                         (list 'substr funcna 1 2) 
                                   );list
                             );list
                       );list
                       '(princ "\nInitializing...\n")
                 );list
                 (list 'setq 'stub (car func))
                 (list 'setq 'rs
                       (list 'arxload fna "Failed")
                 );list
                 (list 'if 
                       (list 'not 
                             (list 'equal 'rs "Failed")
                       );list
                       (list 'progn
                         (list 'if
                               (list 'equal "C:"
                                     (list 'strcase 
                                           (list 'substr funcna 1 2) 
                                     );list
                               );list
                               (list 'progn
                                     (list 'command (substr funcna 3))
                                     '(setq ret (princ))
                               );list
                               (list 'setq 'ret
                                      func           ;else run it
                               );list
                         );list
                       );list
                       (list 'progn
                        (list 'if 
                              (list 'equal 'rs "Failed")
                              (list 'princ 
                                    (list 'strcat "\nError loading file: " fna)
                              );list
                              (list 'princ 
                                    (list 'strcat "\nError. Function \"" 
                                                  funcna 
                                                  "\" not defined in : \"" 
                                                  fna "\"."
                                    )
                              )
                        );list
                        '(setq ret (princ))
                       );list else describe the error
                 );list
                 'ret
           );list
);setq
(set (car func) tmp)

);defun bns_arx_autoload

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pre_sel ( lst / lst2 n a)

(setq n 0)
(repeat (length lst)
(setq a (nth n lst))
(if (not (equal a (last lst2) 0.0001))
    (setq lst2 (append lst2 (list a)));setq
);fi
(setq n (+ n 1));setq
);repeat
lst2
);defun pre_sel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Taken from exchprop.lsp and updated!
;returns only entities in ss that are in the current space. 
(defun ss_in_current_space ( ss / flag ss2)

 (if ss
     (progn
      (if (and (equal (getvar "tilemode") 0)
               (equal (getvar "cvport") 1)
          );and 
          (setq flag 1);then paper space is where we are.
          (setq flag 0);else model space.
      );if
      (command "_.select" ss "")
      (setq ss2 (ssget "_p" (list (cons 67 flag))));setq       
      (cond                              ;;;;;tell the user what's going on.
       ((not ss2)
        (princ "\nNo objects found in current space.")
       )
       ((not (equal (sslength ss) (sslength ss2)))
        (princ (strcat "\n" (itoa (- (sslength ss) (sslength ss2)))
                       " object(s) were not in current space."
               )
        )
       ) 
      );cond 
     );progn then
 );if  
 ss2
);defun ss_in_current_space

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes an entity name of an image.  
;Returns a list clip_boundary points (current UCS). If the image is not clipped
;or has clipping turned off then the image_bounds or max size will 
;be returned.
;  
(defun image_clip_list ( na / e1 e2 lst a )
 (setq e1 (entget na)
       e2 e1
 );setq 
 (while (setq a (assoc 14 e1))
  (setq  e1 (cdr (member a e1))
          a (cdr a)
        lst (append lst (list a))
  );setq
 );while
 
 (if (and (equal (cdr (assoc 280 e2)) 1)
          (equal 4 (logand 4 (cdr (assoc 70 e2))))
     );and
     (progn
      (if (equal 1 (cdr (assoc 71 e2)))
          (setq lst (list (car lst)
                          (list (car (cadr lst)) (cadr (car lst)))
                          (cadr lst)
                          (list (car (car lst)) (cadr (cadr lst)))
                          (car lst)
                    );list
          );setq then the image has a rectangular clip
      );if
      (setq lst (trans_i_2_ucs lst na 1)) 
     );progn 
     (progn
      (setq lst (image_bounds na))
     );progn else the image is not clipped
 );if
 lst
);defun image_clip_list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes: lst  - a list of 2d points obtained from an image entity.
;       na   - entity name of an image 
;       code - 0, 1 or 2 (same as trans 
;                         world coords, current ucs, or screen respectively)
;Returns a list of translated coords.
;
(defun trans_i_2_ucs ( lst na code / dxf e1 p1 p2 p3 p4 p5 a b pnt n lst2 )
 (defun dxf ( a b ) (cdr (assoc a b)))
 (setq e1 (entget na)
       p1 (dxf 10 e1);insert point
       p2 (dxf 11 e1)
       p3 (dxf 12 e1)
       p4 (dxf 13 e1)
       p5 (list 
                (+ (car p1)   (* (cadr p4) (car p3)))
                (+ (cadr p1)  (* (cadr p4) (cadr p3)))
                (+ (caddr p1) (* (cadr p4) (caddr p3)))
          );list
 );setq

 (setq n 0)
 (repeat (length lst)
 (setq pnt (nth n lst)
         a (list 
                 (* (car pnt) (car p2))
                 (* (car pnt) (cadr p2))
                 (* (car pnt) (caddr p2))
           );list
         a (list (+ (car a) (/ (car p2) 2.0))   ;added 1:48 PM 8/20/97
                 (+ (cadr a) (/ (cadr p2) 2.0))
                 (+ (caddr a) (/ (caddr p2) 2.0))
           );list                                  
         b (list (* -1.0 (cadr pnt) (car p3))
                 (* -1.0 (cadr pnt) (cadr p3))
                 (* -1.0 (cadr pnt) (caddr p3))
           );list
         b (list (- (car b) (/ (car p3) 2.0))   ;added 1:48 PM 8/20/97
                 (- (cadr b) (/ (cadr p3) 2.0))
                 (- (caddr b) (/ (caddr p3) 2.0))
           );list 
       pnt (add_delta_xyz p5 a)
       pnt (add_delta_xyz pnt b)
       pnt (trans pnt 
                  0 ;na 
                  code
           )
      lst2 (append lst2 (list pnt))
 );setq
 (setq n (+ n 1));setq
 );repeat
 lst2
);defun trans_i_2_ucs




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun image_bounds ( na / dxf e1 p1 p2 p3 p4 p5 p6 p7 lst)
 (defun dxf ( a b ) (cdr (assoc a b)))
 (setq e1 (entget na)
       p1 (dxf 10 e1);insert point
       p2 (dxf 11 e1)
       p3 (dxf 12 e1)
       p4 (dxf 13 e1)
       p5 (list 
                (+ (car p1)   (* (car p4) (car p2)))
                (+ (cadr p1)  (* (car p4) (cadr p2)))
                (+ (caddr p1) (* (car p4) (caddr p2)))
          );list
       p6 (list 
                (+ (car p5)   (* (cadr p4) (car p3)))
                (+ (cadr p5)  (* (cadr p4) (cadr p3)))
                (+ (caddr p5) (* (cadr p4) (caddr p3)))
          );list
       p7 (list 
                (+ (car p1)   (* (cadr p4) (car p3)))
                (+ (cadr p1)  (* (cadr p4) (cadr p3)))
                (+ (caddr p1) (* (cadr p4) (caddr p3)))
          );list
 );setq
 ;(setq   x (cross_prod p2 ;(delta_xyz p1 p5) ;
 ;                      p3 ;(delta_xyz p1 p7) ;
 ;          );cross_prod
 ;        x (unitv '(0.0 0.0 0.0) x)
 ;);setq
 (setq lst (lsttrans (list p1 p5 p6 p7 p1) 
                     0 ;x ;@rk was na 6:28 PM 8/12/97
                     1
           );lsttrans
 );setq
 lst
);defun image_bounds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**UNITV unit vector function, takes two points as arguments
;and returns a unit vector in that direction
(defun unitv ( p1 p2 / )
 (setq p1 (list (/ (car (delta_xyz p1 p2))   (distance p1 p2))
                (/ (cadr (delta_xyz p1 p2))  (distance p1 p2))
                (/ (caddr (delta_xyz p1 p2)) (distance p1 p2))
          );list
 );setq
);defun unitv

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Delta_XYZ is the change in x y and z from one point to another
;takes two points and returns what can be considered to be a vector 
;from point "a" to point "b".
;if "b" is nil, delta_xyz asssumes that the points needed are contained 
;in a list stored in the variable "a"
(defun delta_xyz (a b)
 (if (= b nil)
     (setq b (cadr a)
           a (car a)
     );setq
 );if
 (if (and (equal (length a) 3)
          (equal (length b) 3)
     );and
     (setq a (list (- (car b) (car a))
                   (- (cadr b) (cadr a))
                   (- (caddr b) (caddr a))
             );list
     );setq then
     (setq a (list (- (car b) (car a))
                   (- (cadr b) (cadr a))
             );list
     );setq else
 );if
 a
);defun delta_xyz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;add_delta_xyz - Add an offset vector to a point to form a new point.
;Takes a point 'a and an offset vector 'b
;Returns a point that is 'b from a.
;
(defun add_delta_xyz ( a b /  c)
(if (and (equal (length a) 3)
         (equal (length b) 3)
    );and
    (setq c (list (+ (car b) (car a))
                  (+ (cadr b) (cadr a))
                  (+ (caddr b) (caddr a))
            );list
    );setq then
    (setq c (list (+ (car b) (car a))
                  (+ (cadr b) (cadr a))
            );list
    );setq else
 );if
 c
);defun add_delta_xyz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bns_groups_unsel - Turns off selection of all groups.
;Returns a list of group names that had selection turned on. This 
;list can be used for restoring group selection later using 
;bns_groups_sel.
(defun bns_groups_unsel ( / na e1 a n lst lst2 lst3 )

(setq  lst (dictsearch (namedobjdict) "ACAD_GROUP")
      lst2 (m_assoc 3 lst)
);setq

(setq n 0)
(repeat (length lst2)
(setq  a (nth n lst2)
      na (cdr (car (cdr (member a lst))))
      e1 (entget na)
);setq
(if (member '(71 . 1) e1)
    (progn
     ;(command "_.-group" "_sel" (cdr a) "_y")
     (setq e1 (subst '(71 . 0) '(71 . 1) e1))
     (entmod e1)
     (setq lst3 (append lst3 (list na)));setq 
    );progn
);if
(setq n (+ n 1));setq
);repeat
lst3
);defun bns_groups_unsel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bns_groups_sel - Take a list of group names and turns ON selection 
;for each group
(defun bns_groups_sel ( lst  / n na e1)

(setq n 0)
(repeat (length lst)
(setq na (nth n lst)
      e1 (entget na)
);setq
(setq e1 (subst '(71 . 1) '(71 . 0) e1))
(entmod e1)
(setq n (+ n 1));setq
);repeat

);defun bns_groups_sel

(bns_autoload '("LMAN.LSP" "(C:LMAN)"))                                       ; Layer Manager
(bns_autoload '("EXTRIM.LSP" "(C:EXTRIM)" "AC_BONUS.HLP" "EXTRIM"))           ; Trim Around
(bns_autoload '("MSTRETCH.LSP" "(C:MSTRETCH)"  "AC_BONUS.HLP" "MSTRETCH"))    ; Multiple Stretch
(bns_autoload '("EXCHPROP.LSP" "(C:EXCHPROP)" "AC_BONUS.HLP" "EXCHPROP"))     ; Extended Ddchprop
(bns_autoload '("CLIPIT" "(C:CLIPIT)" "AC_BONUS.HLP" "CLIPIT"))               ; Extended Xclip
(bns_autoload '("CHTEXT.LSP" "(C:CHT)" "AC_BONUS.HLP" "CHT"))                 ; Change Text
(bns_autoload '("CHTEXT.LSP" "(C:CHGTEXT)" "AC_BONUS.HLP" "CHT"))             ; Change Text
(bns_autoload '("MPEDIT.LSP" "(C:MPEDIT)" "AC_BONUS.HLP" "MPEDIT"))           ; Multiple Pline Edit
(bns_autoload '("XLIST.LSP" "(C:XLIST)" "AC_BONUS.HLP" "XLIST"))              ; List Xref Objects
(bns_autoload '("XLIST.LSP" "(C:-XLIST)" "AC_BONUS.HLP" "XLIST"))             ; List Xref Objects w/out dialog
(bns_autoload '("BNSLAYER.LSP" "(C:LAYISO)" "AC_BONUS.HLP" "LAYISO"))         ; Isolate Layer
(bns_autoload '("BNSLAYER.LSP" "(C:LAYFRZ)" "AC_BONUS.HLP" "LAYFRZ"))         ; Freeze Layers
(bns_autoload '("BNSLAYER.LSP" "(C:LAYOFF)" "AC_BONUS.HLP" "LAYOFF"))         ; Turn Off Layers
(bns_autoload '("BNSLAYER.LSP" "(C:LAYLCK)" "AC_BONUS.HLP" "LAYLCK"))         ; Lock Layer
(bns_autoload '("BNSLAYER.LSP" "(C:LAYULK)" "AC_BONUS.HLP" "LAYULK"))         ; Unlock Layer
(bns_autoload '("BNSLAYER.LSP" "(C:LAYON)"))                                  ; Turn On All Layers
(bns_autoload '("BNSLAYER.LSP" "(C:LAYTHW)"))                                 ; Thaw All Layers
(bns_autoload '("BNSLAYER.LSP" "(C:LAYMCH)" "AC_BONUS.HLP" "LAYMCH"))         ; Match Layer
(bns_autoload '("BNSLAYER.LSP" "(C:LAYCUR)" "AC_BONUS.HLP" "LAYCUR"))         ; Change Object to Current Layer
(bns_autoload '("TEXTMASK.LSP" "(C:TEXTMASK)" "AC_BONUS.HLP" "TEXTMASK"))     ; Mask Behind Text
(bns_autoload '("TEXTFIT.LSP" "(C:TEXTFIT)" "AC_BONUS.HLP" "TEXTFIT"))        ; Fit Text Between Points
(bns_autoload '("BURST.LSP" "(C:BURST)" "AC_BONUS.HLP" "BURST"))              ; Explode Attributes to Text
(bns_autoload '("GATTE.LSP" "(C:GATTE)" "AC_BONUS.HLP" "GATTE"))              ; Global Attribute Edit
(bns_autoload '("FIND.LSP" "(C:FIND)"))                                       ; Text Search and Replace
(bns_autoload '("REVCLOUD.LSP" "(C:REVCLOUD)" "AC_BONUS.HLP" "REVCLOUD"))     ; Revision Cloud
(bns_autoload '("XPLODE.LSP" "(C:XPLODE)" "AC_BONUS.HLP" "XPLODE"))           ; Extended Explode
(bns_autoload '("XPLODE.LSP" "(C:XP)" "AC_BONUS.HLP" "XPLODE"))               ; Extended Explode
(bns_autoload '("XDATA.LSP" "(C:XDATA)" "AC_BONUS.HLP" "XDATA"))              ; Xdata Creation Tool
(bns_autoload '("XDATA.LSP" "(C:XDLIST)" "AC_BONUS.HLP" "XDATA"))             ; Xdata Listing Tool
(bns_autoload '("TXTEXP.LSP" "(C:TXTEXP)" "AC_BONUS.HLP" "TXTEXP"))           ; Explode Text
(bns_autoload '("TREXBLK.LSP" "(C:BTRIM)" "AC_BONUS.HLP" "BTRIM"))            ; Trim to Block Entities
(bns_autoload '("TREXBLK.LSP" "(C:BEXTEND)" "AC_BONUS.HLP" "BEXTEND"))        ; Extend to Block Entities
(bns_autoload '("TREXBLK.LSP" "(C:NCOPY)" "AC_BONUS.HLP" "NCOPY"))            ; Copy Nested Entities
(bns_autoload '("GETSEL.LSP" "(C:GETSEL)" "AC_BONUS.HLP" "GETSEL"))           ; Get Selection Set
(bns_autoload '("SSX.LSP" "(C:SSX)" "AC_BONUS.HLP" "SSX"))                    ; Selection Set Filter
(bns_autoload '("ASCPOINT.LSP" "(C:ASCPOINT)" "AC_BONUS.HLP" "ASCPOINT"))     ; Read Points From File
(bns_autoload '("BLK_LST.LSP" "(C:BLKTBL)" "AC_BONUS.HLP" "BLK_LST.LSP"))     ; Lists the Block Table
(bns_autoload '("BLK_LST.LSP" "(C:BLKLST)" "AC_BONUS.HLP" "BLK_LST.LSP"))     ; Lists User-Selected Block.
(bns_autoload '("BLK_LST.LSP" "(C:CATTL)" "AC_BONUS.HLP" "BLK_LST.LSP"))      ; List the attributes of a user-selected block
(bns_autoload '("BLK_LST.LSP" "(C:ATTLST)" "AC_BONUS.HLP" "BLK_LST.LSP"))     ; Lists all attributes in a block insertion
(bns_autoload '("COUNT.LSP" "(C:COUNT)" "AC_BONUS.HLP" "COUNT"))              ; Block Counting
(bns_autoload '("BLOCKQ.LSP" "(C:BLOCK?)"  "AC_BONUS.HLP" "BLOCK63"))         ; Block Query
(bns_autoload '("CROSSREF.LSP" "(C:CROSSREF)" "AC_BONUS.HLP" "CROSSREF"))     ; Block Definition Query
(bns_autoload '("JULIAN.LSP" "(C:DATE)"))                                     ; Date Function Library
(bns_autoload '("PQCHECK.LSP" "(C:PQCHECK)" "AC_BONUS.HLP" "PQCHECK"))        ; LISP File Checker
(bns_autoload '("ARCTEXT.ARX" "(C:ARCTEXT)" "AC_BONUS.HLP" "ARCTEXT"))        ; Text Along an Arc
(bns_autoload '("ARCTEXT.ARX"  "(C:ATEXT)" "AC_BONUS.HLP" "ARCTEXT"))         ; Text Along an Arc
(bns_autoload '("PACKNGO.ARX" "(C:PACK)"))                                    ; Pack 'n Go Drawing Resource Packager
(bns_autoload '("PLCONVRT.ARX" "(C:CONVERTPLINES)" "AC_BONUS.HLP" "CONVERTPLINES"))     ; Convert Old Plines to Lwplines
(bns_autoload '("WIPEOUT.ARX" "(C:WIPEOUT)" "AC_BONUS.HLP" "WIPEOUT"))        ; Entity Masking
(bns_autoload '("DIMSIO.ARX" "(C:DIMEX)"))                                    ; Dimstyle Export
(bns_autoload '("DIMSIO.ARX" "(C:DIMIM)"))                                    ; Dimstyle Import
(bns_autoload '("LEADEREX.ARX" "(C:QLEADER)"))                                ; Quick Leader
(bns_autoload '("LEADEREX.ARX"  "(C:QLATTACH)"))                              ; Attach Leader Globally
(bns_autoload '("LEADEREX.ARX" "(C:QLDETACHSET)"))                            ; Dettach Leader to Set
(bns_autoload '("LEADEREX.ARX" "(C:QLATTACHSET)"))                            ; Attach Leader to Set
(bns_autoload '("MOCORO.ARX" "(C:MOCORO)" "AC_BONUS.HLP" "MOCORO"))           ; Move, Copy, Rotate, and Scale
(bns_autoload '("SYSVDLG.ARX" "(C:SYSVDLG)"))                                 ; System Variable Editor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(princ "\nAutoCAD bonus utilities loaded.\n")
(princ)

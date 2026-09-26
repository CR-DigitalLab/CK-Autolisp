;;;
;;;    LAYC.LSP - AKS 11/00
;;;	 LAYC uses modified copies of proceedures from LMAN.LSP to
;;;	 allow for command line control of Layermanager layerstates.
;;;	 Added commands are:
;;;	 slx  -- saves a layerstate
;;;	 rlx  -- restores a layerstate
;;;	 slag -- saves a layerstate with filename embedded with name
;;;	 rlag -- restores a layerstate with filename embedded with name
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:slx ( / lst lst2 n ss na a vp clayer)

(if (= laycaks nil) (load "lman"))  ;runs lman at least once
(setq laycaks 1)
(setq lstate(getstring "\nSave as what layerstate? : "))
(setq lstate (strcase lstate))    ;all caps

;;; the rest is verbatim from lman's sl proceedure
   
  (if (and (equal (getvar "tilemode") 0)
           (setq  a (getvar "cvport") 
                 ss (ssget "_x" (list '(0 . "VIEWPORT") 
                                     '(67 . 1)
                                     (cons 69 a)
                               );list
                    );ssget
           );setq
      );and
      (progn 
       (setq   na (ssname ss 0)
               ss nil 
             lst2 (get_f_vp na)
       );setq
      );progn then need to add the data to the viewports
  );if
  (setq clayer (getvar "clayer"));setq
  (setq lst (tnlist "layer"))
  (setq n 0);setq
  (repeat (length lst)
   (setq a (nth n lst));setq
   (if (member a lst2)
       (setq vp a)
       (setq vp nil)
   );if 
   (add_layerstate (entget (TBLOBJNAME "layer" a) '("RAK")) 
                   lstate
                   clayer
                   vp
                   nil
   );add_layerstate
   ;(spinner)
   (setq n (+ n 1));setq
  );repeat
  (setq #last_restore (list lstate (get_la_status))
          #incomplete nil
  );setq
 );defun slx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun C:slag (  / na ss lst lst2 lst3 lst4 a b n clayer)

(if (= laycaks nil) (load "lman")) ;; runs lman at least once
(setq laycaks 1)
(setq lstate(getstring "\nSave layerstate as <what>-dwgname? : "))

(setq lstate (strcat lstate "-" (xstrip (getvar "dwgname")) ))
(setq lstate (strcase lstate))    ;all caps

;;; the rest is verbatim from lman's sl proceedure
   
  (if (and (equal (getvar "tilemode") 0)
           (setq  a (getvar "cvport") 
                 ss (ssget "_x" (list '(0 . "VIEWPORT") 
                                     '(67 . 1)
                                     (cons 69 a)
                               );list
                    );ssget
           );setq
      );and
      (progn 
       (setq   na (ssname ss 0)
               ss nil 
             lst2 (get_f_vp na)
       );setq
      );progn then need to add the data to the viewports
  );if
  (setq clayer (getvar "clayer"));setq
  (setq lst (tnlist "layer"))
  (setq n 0);setq
  (repeat (length lst)
   (setq a (nth n lst));setq
   (if (member a lst2)
       (setq vp a)
       (setq vp nil)
   );if 
   (add_layerstate (entget (TBLOBJNAME "layer" a) '("RAK")) 
                   lstate
                   clayer
                   vp
                   nil
   );add_layerstate
   ;(spinner)
   (setq n (+ n 1));setq
  );repeat
  (setq #last_restore (list lstate (get_la_status))
          #incomplete nil
  );setq
 );defun slag


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun C:rlx ( / na ss lst lst2 lst3 lst4 a b n clayer)

(if (= laycaks nil) (load "lman")) ;; runs lman at least once
(setq laycaks 1)
(setq lstate(getstring "\nRestore to what layerstate? : "))
(setq lstate (strcase lstate))    ;all caps

;; The rest is vertabim from lman's rl proceedure
 
 (if (and (equal (getvar "tilemode") 0)
           (setq  a (getvar "cvport") 
                 ss (ssget "_x" (list '(0 . "VIEWPORT") 
                                     '(67 . 1)
                                     (cons 69 a)
                               );list
                    );ssget
           );setq
      );and
      (progn 
       (setq na (ssname ss 0)
             ss nil 
       );setq
      );progn then need to add the data to the viewports
  );if
  (if (not (equal #last_restore (list lstate (get_la_status))))
      (progn
       (setq #incomplete nil
                  clayer (getvar "clayer")
                     lst (tnlist "layer")
       );setq
       (setq n 0);setq
       (repeat (length lst)
        (setq lst2 (r_layerstate (nth n lst) lstate lst2 na lst4)
              lst4 (cadr lst2)
              lst2 (car lst2)
        );setq 
        (setq n (+ n 1));setq
       );repeat  

       (if (and na lst4)
           (progn
            (command "_.vplayer" "_T" "*" "")
            (setq n 0);setq
            (repeat (length lst4)
             (command (nth n lst4)) 
            (setq n (+ n 1));setq 
            );repeat
            (command "")
           );progn then do the vport thang
       );if
       (command "_.layer")
       (setq n 0);setq
       (repeat (length lst2)
        (setq lst3 (nth n lst2)
                 a (car lst3)
              lst3 (cdr lst3)   
        );setq

        (while lst3
         (setq b (car lst3));setq 
         (if (or (equal "_C" b)
                 (equal "_LT" b)
             );or
             (progn 
              (command b (cadr lst3) a)
              (setq lst3 (cdr lst3));setq
             );progn
             (progn
              (if (and (or (equal b "_F")
                           (equal b "_OFF")
                       );or           
                       (equal a (getvar "clayer"))
                  );and       
                  (progn
                   (if (equal b "_OFF")
                       (command b a "_Y")
                       (princ "\nCan't freeze the current layer.")
                   );if
                  );progn then
                  (progn
                   (command b a)
                  );progn else
              );if
             );progn
         );if 
         (setq lst3 (cdr lst3));setq
        );while  
       
       (setq n (+ 1 n));setq
       );repeat  
       (command "")
       (if (not #incomplete)  
           (setq #last_restore (list lstate (get_la_status)));setq
       );if
      );progn then need to perform a restore
  );if
 
  (princ)
 );defun rlX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun C:rlag ( / na ss lst lst2 lst3 lst4 a b n clayer)

(if (= laycaks nil) (load "lman")) ;; runs lman at least once
(setq laycaks 1)
(setq lstate(getstring "\nRestore layerstate <what>-dwgname? : "))

(setq lstate (strcat lstate "-" (xstrip (getvar "dwgname")) ))
(setq lstate (strcase lstate))    ;all caps

;; The rest is vertabim from lman's rl proceedure
 
 (if (and (equal (getvar "tilemode") 0)
           (setq  a (getvar "cvport") 
                 ss (ssget "_x" (list '(0 . "VIEWPORT") 
                                     '(67 . 1)
                                     (cons 69 a)
                               );list
                    );ssget
           );setq
      );and
      (progn 
       (setq na (ssname ss 0)
             ss nil 
       );setq
      );progn then need to add the data to the viewports
  );if
  (if (not (equal #last_restore (list lstate (get_la_status))))
      (progn
       (setq #incomplete nil
                  clayer (getvar "clayer")
                     lst (tnlist "layer")
       );setq
       (setq n 0);setq
       (repeat (length lst)
        (setq lst2 (r_layerstate (nth n lst) lstate lst2 na lst4)
              lst4 (cadr lst2)
              lst2 (car lst2)
        );setq 
        (setq n (+ n 1));setq
       );repeat  

       (if (and na lst4)
           (progn
            (command "_.vplayer" "_T" "*" "")
            (setq n 0);setq
            (repeat (length lst4)
             (command (nth n lst4)) 
            (setq n (+ n 1));setq 
            );repeat
            (command "")
           );progn then do the vport thang
       );if
       (command "_.layer")
       (setq n 0);setq
       (repeat (length lst2)
        (setq lst3 (nth n lst2)
                 a (car lst3)
              lst3 (cdr lst3)   
        );setq

        (while lst3
         (setq b (car lst3));setq 
         (if (or (equal "_C" b)
                 (equal "_LT" b)
             );or
             (progn 
              (command b (cadr lst3) a)
              (setq lst3 (cdr lst3));setq
             );progn
             (progn
              (if (and (or (equal b "_F")
                           (equal b "_OFF")
                       );or           
                       (equal a (getvar "clayer"))
                  );and       
                  (progn
                   (if (equal b "_OFF")
                       (command b a "_Y")
                       (princ "\nCan't freeze the current layer.")
                   );if
                  );progn then
                  (progn
                   (command b a)
                  );progn else
              );if
             );progn
         );if 
         (setq lst3 (cdr lst3));setq
        );while  
       
       (setq n (+ 1 n));setq
       );repeat  
       (command "")
       (if (not #incomplete)  
           (setq #last_restore (list lstate (get_la_status)));setq
       );if
      );progn then need to perform a restore
  );if
 
  (princ)
 );defun rlX



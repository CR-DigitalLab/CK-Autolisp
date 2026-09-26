;
;                  Circle to Ellipse       Ver. 1.07-94
;
;  C2E provides a quick means to change a circle into an ellipse.    
;  C2E first evaluates the circle to determine the center, radious,  
;  color and layer.  A new ellipse is then created with the same     
;  specifications, and the old circle is erased.                     
;                                                                    
;  C2E is freeware and can be freely used, altered, or distributed   
;  as you see fit.                                                   
;                                                                    
;  I do not accept any responsibility for any thing that might go    
;  wrong.                                                            
;                                                                    
;  Jim Lloyd - Richmond, VA CIS 73353,2235                           
;
(defun c:c2e (/ c1 cp c2cp la co)
;   
   (while (= c1 'nil)
      (prompt "\nSelect Circle to Convert to Ellipse: ")
      (setq c1 (entsel))
   )
;
(while (= (cdr (assoc 0 (entget (car c1)
                        )
               )
          )
       "POLYLINE"
       )
      (prompt "\nOOOPs!  That is already an Ellipse of Polyline, Try again: ")
      (setq c1 (entsel))
)
;
(setq cp (cdr (assoc 10 (entget (car c1)
                        )
              )
         )
)
;
(setq c2cp (subst (+ (car cp)(cdr (assoc 40 (entget (car c1))))) 
           (car cp) cp)
)
;
(setq la (cdr (assoc 8 (entget (car c1)))))
(setq co (cdr (assoc 62 (entget (car c1)))))
   (if (= co 0)
      (setq co "BYBLOCK")
   )
;
(command "ellipse" "c" cp c2cp c2cp)
(command "chprop" "l" "" "c" co "la" la "")
;
(command "erase" c1 "")
;
(princ)
)

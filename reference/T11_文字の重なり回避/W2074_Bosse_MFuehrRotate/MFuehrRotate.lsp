;;;Bosse-engineering                                                                                       
;;;Dipl.-Ing. Jörn Bosse                                                                                   
;;;Am Klei 5                                                                                               
;;;38458 Velpke                                                                                            
;;;Tel. 05364 / 989 677                                                                                    
;;;mobil. 0176 / 282 323 51                                                                                
;;;bosse@bosse-engineering.com                                                                             
;;;                                                                                                        
;;;--------------------------------------------------------------------------------------------------------
;;;Funktion c:MFuehrRotate										   
;;;Kürzel: MFROT											   
;;;Es werden alle ausgewählten Multiführungen (mit exakt einem Leader) um einen festen Winkel gedreht,     
;;;wobei der Drehpunkt der erste Leaderpunkt ist.							   
;;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;globale Variablen:										   	   
;;;                                                                              Jörn Bosse, 23.11.20      
;;;--------------------------------------------------------------------------------------------------------

(setq JB_MFROT$$AboutList
      '(( "1.0"
          (( "" ( "23.11.20"
                   
                 )
           )
             
          )
        )
       )
)

(defun JB_MFROT:Intro (MsgString / )
  (princ "\nerstellt durch Bosse-engineering - www.bosse-engineering.com\n")
  (princ (strcat "\n---------------------MFROT(1.0"
           (car(last(cadr(car JB_MFROT$$AboutList))))
           "), "
           (car(cadr(last(cadr(car JB_MFROT$$AboutList)))))
           "--------------------"))
  (princ "\nMultiführungen drehen.")
  
  (if msgString
    (princ msgString)
    )
  (princ "\n-------------------------------------------------------------")
  )

(defun c:MFROT ( / )
  (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
  (JB_MFROT:Intro nil)
  (JB_MFROT:exe)

  (princ "\nEnde.")
  
  (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
  (princ)
  )

;;;Ausführung
(defun JB_MFROT:exe (  / AWS N P P1 P2 P3 VLA-OBJ)
  (if (and (setq p1 (getpoint "\nErster Richtungspunkt:"))
           (setq p2 (getpoint p1 "\nZweiter Richtungspunkt alt:"))
           (setq p3 (getpoint p1 "\nZweiter Richtungspunkt neu:"))
           (princ "\nWählen Sie Multiführungen:")
           (setq aws (ssget (list (cons 0 "MULTILEADER")))))
    (progn      
      (setq n 0)
      (repeat (sslength aws)
        (setq vla-obj (vlax-ename->vla-object (ssname aws n)))
        (if (=(vla-get-leadercount vla-obj)1)
          (progn
            (setq p (vlax-safearray->list (vlax-variant-value (vla-GetLeaderLineVertices vla-obj 0)))
                  p (vlax-3D-Point(list (car p)(cadr p)(caddr p))))
            (vla-rotate vla-obj p
              (-(angle (trans p1 1 0)(trans p3 1 0))(angle (trans p1 1 0)(trans p2 1 0))))
            (vla-update vla-obj)))
        (setq n (+ n 1))))
    )
  )

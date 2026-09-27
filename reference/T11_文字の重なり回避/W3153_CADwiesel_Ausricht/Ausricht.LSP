(defun c:Ausricht (/ aw nea winkel winkel_elem basispunkt belems rotor)
  
(defun F:GET_PLINE_SEG
                       (obj kpunkt / input vlaObj segp ap ep id bf erg)
  (if (and obj
           kpunkt
           (or (= (cdr (assoc 0 (entget obj))) "LWPOLYLINE")
               (and (= (cdr (assoc 0 (entget obj))) "POLYLINE")
                    (= (logand (cdr (assoc 70 (entget obj))) 2) 0)
                    (= (logand (cdr (assoc 70 (entget obj))) 4) 0)
                    (= (logand (cdr (assoc 70 (entget obj))) 8) 0)
                    (= (logand (cdr (assoc 70 (entget obj))) 16) 0)
                    (= (logand (cdr (assoc 70 (entget obj))) 32) 0)
                    (= (logand (cdr (assoc 70 (entget obj))) 64) 0)
                    ) ;_ end of and
               ) ;_ end of or
           ) ;_ end of and
    (progn
      (setq vlaObj (vlax-ename->vla-object obj))
      (setq kpunkt (vlax-curve-getClosestPointTo vlaObj kpunkt))
      (setq segp (vlax-curve-getParamAtPoint vlaObj kpunkt))
      (if (= (vla-get-Closed vlaObj) :vlax-true)
        (setq endp (- (vlax-curve-getEndParam vlaObj) 1.0))
        (setq endp (vlax-curve-getEndParam vlaObj))
        ) ;_ end of if
      (if (> segp endp)
        (setq ap (vlax-curve-getPointAtParam vlaObj 0.0)
              ep (vlax-curve-getPointAtParam vlaObj endp)
              id endp
              ) ;_ end of setq
        (setq id (rtoi segp)
              ap (vlax-curve-getPointAtParam vlaObj id)
              ep (vlax-curve-getPointAtParam vlaObj (1+ id))
              ) ;_ end of setq
        ) ;_ end of if
      (setq bf (vla-GetBulge vlaObj id))
      (setq
        erg (list ap ep)
        ) ;_ end of setq
      ) ;_ end of progn
    ) ;_ end of if
  (if (= (cdr (assoc 0 (entget obj))) "LINE")
    (setq
      erg (list (cdr (assoc 10 (entget obj)))
                (cdr (assoc 11 (entget obj)))
                ) ;_ end of list
      ) ;_ end of setq
    ) ;_ end of if
  erg
  ) ;_ end of defun

(defun RTOI (zahl / z s erg zahls)
  (setq zahls (rtos zahl 2 10))
  (setq z   1
        s   (substr zahls 1 1)
        erg ""
        ) ;_ end of setq
  (while (and (/= s ".") (<= z (strlen zahls)))
    (setq erg (strcat erg s))
    (setq z (1+ z)
          s (substr zahls z 1)
          ) ;_ end of setq
    ) ;_ end of while
  (setq erg (atoi erg))
  ) ;_ end of defun

(defun MITTEL-PKT? (ENAME /)
  (vlax-curve-getpointatdist
    ENAME
    (/ (vlax-curve-getdistatparam
         ENAME
         (vlax-curve-getendparam ENAME)
         ) ;_ end of vlax-curve-getdistatparam
       2.0
       ) ;_ end of /
    ) ;_ end of
  ) ;_ end of defun

(defun bau_elemli (asatz / n elemli)
  (setq n 0)
  (repeat (sslength asatz)
    (setq elemli (cons (ssname asatz n) elemli)
          n      (1+ n)
          ) ;_ end of setq
    ) ;_ end of repeat
  elemli
  ) ;_ end of defun

(vl-load-com)
(vla-endundomark
         (vla-get-activedocument (vlax-get-acad-object))
         ) ;_ end of vla-endundomark
       (vla-startundomark
         (vla-get-activedocument (vlax-get-acad-object))
         ) ;_ end of vla-startundomark
  (prompt "\nZeigen sie das Winkel-Bezugselement: ")
  (if (and (setq aw (entsel))
           (not(redraw(car aw)3))
           (progn (prompt "\nObjekte wählen zum Ausrichten: ") 'T)
           (setq belems (ssget))
           ) ;_ end of and
    (progn
      (cond
        ((= (strcase
              (vla-get-ObjectName (vlax-ename->vla-object (car aw)))
              ) ;_ end of strcase
            "ACDBLINE"
            ) ;_ end of =
         (setq winkel (vlax-get-property
                        (vlax-ename->vla-object (car aw))
                        'ANGLE
                        ) ;_ end of vlax-get-property
               ) ;_ end of setq
         )
        ((= (strcase
              (vla-get-ObjectName (vlax-ename->vla-object (car aw)))
              ) ;_ end of strcase
            "ACDBPOLYLINE"
            ) ;_ end of =
         (if (setq nea (F:GET_PLINE_SEG (car aw) (cadr aw)))
           (setq winkel (angle (car nea) (cadr nea)))
           ) ;_ end of if
         )
        ) ;_ end of cond
      (mapcar
        '(lambda (x)
           (cond
             ((vlax-property-available-p
                (vlax-ename->vla-object x)
                'ROTATION
                ) ;_ end of vlax-property-available-p
              (vla-put-Rotation
                (vlax-ename->vla-object x)
                (if (> winkel pi)(- winkel pi) winkel)
                ) ;_ end of vla-put-Rotation
              (setq rotor nil)
              )
             ((vlax-property-available-p
                (vlax-ename->vla-object x)
                'Angle
                ) ;_ end of vlax-property-available-p
              (if (> (setq winkel_elem
                            (vlax-get-property
                              (vlax-ename->vla-object
                                x
                                ) ;_ end of vlax-ename->vla-object
                              'ANGLE
                              ) ;_ end of vlax-get-property
                           ) ;_ end of setq
                     winkel
                     ) ;_ end of >
                (setq rotor (* -1 (- winkel_elem winkel)))
                (setq rotor (- winkel winkel_elem))
                ) ;_ end of if
              )
             ((= (strcase
                   (vla-get-ObjectName (vlax-ename->vla-object x))
                   ) ;_ end of strcase
                 "ACDBPOLYLINE"
                 ) ;_ end of =
              (if (> (setq winkel_elem
                            (angle (vlax-curve-getStartPoint
                                     (vlax-ename->vla-object x)
                                     ) ;_ end of vlax-curve-getStartPoint
                                   (vlax-curve-getEndPoint
                                     (vlax-ename->vla-object x)
                                     ) ;_ end of vlax-curve-getEndPoint
                                   ) ;_ end of angle
                           ) ;_ end of setq
                     winkel
                     ) ;_ end of >
                (setq rotor (* -1 (- winkel_elem winkel)))
                (setq rotor (- winkel winkel_elem))
                ) ;_ end of if
              )
             ) ;_ end of cond
           (if rotor
             (command "_rotate"
                      x
                      ""
                      (MITTEL-PKT?
                        (vlax-ename->vla-object x)
                        ) ;_ end of MITTEL-PKT?
                      (angtos rotor 0 8)
                      ) ;_ end of command
             ) ;_ end of if
           ) ;_ end of lambda
        (bau_elemli belems)
        ) ;_ end of mapcar
      (if aw (redraw(car aw)4))
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark
         (vla-get-activedocument (vlax-get-acad-object))
         )
  (PRINC)
  )
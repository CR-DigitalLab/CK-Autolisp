;;;
;;;  3d furniture construction.                                        ;
;;;  Student - Mark Williamson  9-23-92                                ;
;;;  Instructor - Tim Urbaniak / Drafting dept.  76264,2273            ;
;;;  Creates basic 3d cabinets, tables, and two types of chairs        ;
;;;  based on user supplied input. Program allows for the creation     ;
;;;  of multiple objects.                                              ;
;;;                                                                    ;
;;;  Another Billings Vocational Technical Center lab project...       ;
;;;      Your tax dollars at work...support education in your area.    ;
;;;            Public Domain                                           ;
;;;
;;;This part of the program will draw a 3d chair without arms
;;;based on the user supplied input.
(defun c:chair ()                    ;get input for variables
  (textscr) 
  (setq sw (getdist "\nWidth of the seat (on the X): "))
  (setq sl (getdist "\nLength of the seat (on the Y): "))
  (setq sh (getdist "\nThickness of the seat (on the Z): "))
  (setq bl (getdist "\nThickness of the back (on the Y): "))
  (setq bh (getdist "\nHeight of the back (on the Z): "))
  (setq lw (getdist "\nWidth of the leg (on the X): "))
  (setq ll (getdist "\nLength of the leg (on the Y): "))
  (setq lh (getdist "\nHeight of the leg (on the Z): "))
  (setq nc (getint "\nNumber of chairs to build ?: "))
  (graphscr) 
  (setvar "blipmode" 0)
  (setvar "cmdecho" 0)               ;set points for base of first leg
  (setq tp (getvar "thickness"))     ;set up for multiple chairs
  (repeat nc 
    (setq sp (getpoint "\nLower left point for construction: ")) ;create the-
                                     ; chair legs
    (setq l1 sp)
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- sl ll)))
    ) 
    (setq l1 sp)
    (setq l1 (polar l1 (dtr 90) (- sw lw)))
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- sl ll)))
    )                                ;set points for top of first leg
    (setq l1 sp)
    (setq l5 (list (car l1) (cadr l1) (+ (caddr l1) lh)))
    (setq l6 (list (car l2) (cadr l2) (+ (caddr l2) lh)))
    (setq l7 (list (car l3) (cadr l3) (+ (caddr l3) lh)))
    (setq l8 (list (car l4) (cadr l4) (+ (caddr l4) lh))) ;set points for seat
    (setq s1 l5)
    (setq s2 (polar s1 (dtr 0.0) sl))
    (setq s3 (polar s2 (dtr 90) sw))
    (setq s4 (polar s3 (dtr 180) sl)) ;set points for top of seat
    (setq s5 (list (car s1) (cadr s1) (+ (caddr s1) sh)))
    (setq s6 (list (car s2) (cadr s2) (+ (caddr s2) sh)))
    (setq s7 (list (car s3) (cadr s3) (+ (caddr s3) sh)))
    (setq s8 (list (car s4) (cadr s4) (+ (caddr s4) sh))) ;set points for back
    (setq b2 s6)
    (setq b1 (polar b2 (dtr 180) bl))
    (setq b4 (polar b1 (dtr 90) sw))
    (setq b3 s7)                     ;set points for the top of the back
    (setq b5 (list (car b1) (cadr b1) (+ (caddr b1) bh)))
    (setq b6 (list (car b2) (cadr b2) (+ (caddr b2) bh)))
    (setq b7 (list (car b3) (cadr b3) (+ (caddr b3) bh)))
    (setq b8 (list (car b4) (cadr b4) (+ (caddr b4) bh))) ;create the chair bas-
                                     ;e
    (setvar "thickness" sh)
    (command "line" s1 s2 s3 s4 "c") 
    (setvar "thickness" tp)
    (command "3dface" s1 s2 s3 s4 "") 
    (command "3dface" s5 b1 b4 s8 "") ;create the chair back
    (setvar "thickness" bh)
    (command "line" b1 b2 b3 b4 "c") 
    (setvar "thickness" tp)
    (command "3dface" b5 b6 b7 b8 "")
  )
) 
;;;
;;;This part of the program will draw a 3d table
;;;based on user specified input.
(defun c:table ()                    ;get input for variables
  (textscr) 
  (setq tw (getdist "\nWidth of the table (on the X): "))
  (setq tl (getdist "\nLength of the table (on the Y): "))
  (setq th (getdist "\nThickness of the table (on the Z): "))
  (setq lw (getdist "\nWidth of the leg (on the X): "))
  (setq ll (getdist "\nLength of the leg (on the Y): "))
  (setq lh (getdist "\nHeight of the leg (on the Z): "))
  (setq nt (getint "\nNumber of tables to build ?: "))
  (graphscr) 
  (setvar "blipmode" 0)
  (setvar "cmdecho" 0)
  (setq tp (getvar "thickness"))     ;set up for multiple tables
  (repeat nt                         ;set points for base of first leg
    (setq sp (getpoint "\nLower left point for construction: ")) ;create the-
                                     ; chair legs
    (setq l1 sp)
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- tl ll)))
    ) 
    (setq l1 sp)
    (setq l1 (polar l1 (dtr 90) (- tw lw)))
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- tl ll)))
    )                                ;set points for top of first leg
    (setq l1 sp)
    (setq l5 (list (car l1) (cadr l1) (+ (caddr l1) lh)))
    (setq l6 (list (car l2) (cadr l2) (+ (caddr l2) lh)))
    (setq l7 (list (car l3) (cadr l3) (+ (caddr l3) lh)))
    (setq l8 (list (car l4) (cadr l4) (+ (caddr l4) lh))) ;set points for table
    (setq t1 l5)
    (setq t2 (polar t1 (dtr 0.0) tl))
    (setq t3 (polar t2 (dtr 90) tw))
    (setq t4 (polar t3 (dtr 180) tl)) ;set points for top of table
    (setq t5 (list (car t1) (cadr t1) (+ (caddr t1) th)))
    (setq t6 (list (car t2) (cadr t2) (+ (caddr t2) th)))
    (setq t7 (list (car t3) (cadr t3) (+ (caddr t3) th)))
    (setq t8 (list (car t4) (cadr t4) (+ (caddr t4) th))) ;create the table top
    (setvar "thickness" th)
    (command "line" t1 t2 t3 t4 "c") 
    (setvar "thickness" tp)
    (command "3dface" t1 t2 t3 t4 "") 
    (command "3dface" t5 t6 t7 t8 "")
  )
) 
;;;
;;;This part of the program will draw 3d cabinets with one shelf
;;;inserted at the half way point.
(defun c:3dcab ()                    ;get input for variables
  (textscr) 
  (setq w (getdist "\nWidth of cabinet (on the x): "))
  (setq l (getdist "\nLength of the cabinet (on the y): "))
  (setq h (getdist "\nHeight of the cabinet (on the z): "))
  (setq t (getdist "\nThickness of the cabinets (exp 1/4, 1/8): "))
  (setq nc (getint "\nNumber of cabinets to build ?: ")) ;set points for the-
                                     ; base 
  (graphscr) 
  (setvar "blipmode" 0)
  (setvar "cmdecho" 0)
  (setq tp (getvar "thickness"))
  (setq sh (- h t))                  ;set up for multiple cabinets
  (repeat nc 
    (setq sp (getpoint "\nLower left point for construction: "))
    (setq b1 sp)
    (setq b2 (polar b1 (dtr 0.0) w))
    (setq b3 (polar b2 (dtr 90) l))
    (setq b4 (polar b3 (dtr 180) w)) ;set points for the top 
    (setq t1 (list (car b1) (cadr b1) (+ (caddr b1) h)))
    (setq t2 (list (car b2) (cadr b2) (+ (caddr b2) h)))
    (setq t3 (list (car b3) (cadr b3) (+ (caddr b3) h)))
    (setq t4 (list (car b4) (cadr b4) (+ (caddr b4) h))) ;set points for-
                                     ; thickness of cabinets
    ;;left side walls
    (setq l1 (polar b1 (dtr 0.0) t))
    (setq l2 (polar t1 (dtr 0.0) t))
    (setq l3 (polar t4 (dtr 0.0) t))
    (setq l4 (polar b4 (dtr 0.0) t)) ;right side walls
    (setq r1 (polar b2 (dtr 180) t))
    (setq r2 (polar t2 (dtr 180) t))
    (setq r3 (polar t3 (dtr 180) t))
    (setq r4 (polar b3 (dtr 180) t)) ;inside of back
    (setq bk1 (polar l4 (dtr 270) t))
    (setq bk2 (polar r4 (dtr 270) t))
    (setq bk3 (polar r3 (dtr 270) t))
    (setq bk4 (polar l3 (dtr 270) t)) ;inside bottom
    (setq bt1 (list (car l1) (cadr l1) (+ (caddr l1) t)))
    (setq bt2 (list (car r1) (cadr r1) (+ (caddr r1) t)))
    (setq bt3 (list (car bk2) (cadr bk2) (+ (caddr bk2) t)))
    (setq bt4 (list (car bk1) (cadr bk1) (+ (caddr bk1) t))) ;inside top
    (setq tb1 (list (car l2) (cadr l2) (- (caddr l2) t)))
    (setq tb2 (list (car r2) (cadr r2) (- (caddr r2) t)))
    (setq tb3 (list (car bk3) (cadr bk3) (- (caddr bk3) t)))
    (setq tb4 (list (car bk4) (cadr bk4) (- (caddr bk4) t))) ;set points for the-
                                     ; bottom of the shelf
    (setq th (/ t 2))
    (setq sd (- (/ (- (caddr t1) (caddr b1)) 2) th))
    (setq s1 (list (car l1) (cadr l1) sd))
    (setq s2 (list (car r1) (cadr r1) sd))
    (setq s3 (list (car bk2) (cadr bk2) sd))
    (setq s4 (list (car bk1) (cadr bk1) sd)) ;top of the shelf
    (setq s5 (list (car s1) (cadr s1) (+ (caddr s1) t)))
    (setq s6 (list (car s2) (cadr s2) (+ (caddr s2) t)))
    (setq s7 (list (car s3) (cadr s3) (+ (caddr s3) t)))
    (setq s8 (list (car s4) (cadr s4) (+ (caddr s4) t))) ;begin entity creation
    (setvar "thickness" h)
    (command "line" b1 b4 b3 b2 "") 
    (setvar "thickness" sh)
    (command "line" l1 bk1 bk2 r1 "") 
    (setvar "thickness" tp)
    (command "3dface" b1 b2 b3 b4 "") 
    (command "3dface" bt1 bt2 bt3 bt4 "") 
    (command "3dface" tb1 tb2 tb3 tb4 "") 
    (command "3dface" s1 s2 s3 s4 "") 
    (command "3dface" s5 s6 s7 s8 "") 
    (command "3dface" s1 s2 s6 s5 "") 
    (command "3dface" t1 t2 t3 t4 "") 
    (command "3dface" b1 t1 l2 l1 "") 
    (command "3dface" b2 r1 r2 t2 "") 
    (command "3dface" l1 r1 bt2 bt1 "") 
    (command "3dface" tb1 tb2 r2 l2 "") 
    (command "zoom" "e")
  )
) 
;;;
;;;This part of the program will build a 3d chair with arms. 
(defun c:armchr ()                   ;get input for variables
  (textscr) 
  (setq sw (getdist "\nWidth of the seat (on the X): "))
  (setq sl (getdist "\nLength of the seat (on the Y): "))
  (setq sh (getdist "\nThickness of the seat (on the Z): "))
  (setq bl (getdist "\nThickness of the back (on the Y): "))
  (setq bh (getdist "\nHeight of the back (on the Z): "))
  (setq lw (getdist "\nWidth of the leg (on the X): "))
  (setq ll (getdist "\nLength of the leg (on the Y): "))
  (setq lh (getdist "\nHeight of the leg (on the Z): "))
  (setq nc (getint "\nNumber of chairs to build ?: "))
  (setq ad (- sl bl))
  (setq aw lw)
  (setq al (/ ll 2))
  (setq at al)
  (setq hat (/ at 2))
  (setq ah (- (/ bh 2) hat))
  (graphscr) 
  (setvar "blipmode" 0)
  (setvar "cmdecho" 0)               ;set points for base of first leg
  (setq tp (getvar "thickness"))     ;set up for multiple chairs
  (repeat nc 
    (setq sp (getpoint "\nLower left point for construction: ")) ;create the-
                                     ; chair legs
    (setq l1 sp)
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- sl ll)))
    ) 
    (setq l1 sp)
    (setq l1 (polar l1 (dtr 90) (- sw lw)))
    (repeat 2 
      (setq l2 (polar l1 (dtr 0.0) ll))
      (setq l3 (polar l2 (dtr 90) lw))
      (setq l4 (polar l3 (dtr 180) ll))
      (setvar "thickness" lh)
      (command "line" l1 l2 l3 l4 "c") 
      (setvar "thickness" tp)
      (command "3dface" l1 l2 l3 l4 "") 
      (setq l1 (polar l1 (dtr 0.0) (- sl ll)))
    )                                ;set points for top of first leg
    (setq l1 sp)
    (setq l5 (list (car l1) (cadr l1) (+ (caddr l1) lh)))
    (setq l6 (list (car l2) (cadr l2) (+ (caddr l2) lh)))
    (setq l7 (list (car l3) (cadr l3) (+ (caddr l3) lh)))
    (setq l8 (list (car l4) (cadr l4) (+ (caddr l4) lh))) ;set points for seat
    (setq s1 l5)
    (setq s2 (polar s1 (dtr 0.0) sl))
    (setq s3 (polar s2 (dtr 90) sw))
    (setq s4 (polar s3 (dtr 180) sl)) ;set points for top of seat
    (setq s5 (list (car s1) (cadr s1) (+ (caddr s1) sh)))
    (setq s6 (list (car s2) (cadr s2) (+ (caddr s2) sh)))
    (setq s7 (list (car s3) (cadr s3) (+ (caddr s3) sh)))
    (setq s8 (list (car s4) (cadr s4) (+ (caddr s4) sh))) ;set points for arm-
                                     ; base
    (setq a1 s5)
    (repeat 2 
      (setq a2 (polar a1 (dtr 0.0) al))
      (setq a3 (polar a2 (dtr 90) aw))
      (setq a4 (polar a3 (dtr 180) al)) ;set points for the armrests
      (setq a5 (list (car a1) (cadr a1) (+ (caddr a1) ah)))
      (setq a6 (polar a5 (dtr 0.0) (- sl bl)))
      (setq a7 (polar a6 (dtr 90) aw))
      (setq a8 (list (car a4) (cadr a4) (+ (caddr a4) ah)))
      (setq a9 (list (car a5) (cadr a5) (+ (caddr a5) at)))
      (setq a10 (list (car a6) (cadr a6) (+ (caddr a6) at)))
      (setq a11 (list (car a7) (cadr a7) (+ (caddr a7) at)))
      (setq a12 (list (car a8) (cadr a8) (+ (caddr a8) at)))
      (setq a13 (polar a5 (dtr 0.0) al))
      (setq a14 (polar a8 (dtr 0.0) al)) ;create the arms
      (setvar "thickness" ah)
      (command "line" a1 a2 a3 a4 "c") 
      (setvar "thickness" at)
      (command "line" a6 a5 a8 a7 "") 
      (setvar "thickness" tp)
      (command "3dface" a9 a10 a11 a12 "") 
      (command "3dface" a13 a6 a7 a14 "") 
      (setq a1 (polar s5 (dtr 90) (- sw aw)))
    )                                ;set points for back
    (setq b2 s6)
    (setq b1 (polar b2 (dtr 180) bl))
    (setq b4 (polar b1 (dtr 90) sw))
    (setq b3 s7)                     ;set points for the top of the back
    (setq b5 (list (car b1) (cadr b1) (+ (caddr b1) bh)))
    (setq b6 (list (car b2) (cadr b2) (+ (caddr b2) bh)))
    (setq b7 (list (car b3) (cadr b3) (+ (caddr b3) bh)))
    (setq b8 (list (car b4) (cadr b4) (+ (caddr b4) bh))) ;create the chair bas-
                                     ;e
    (setvar "thickness" sh)
    (command "line" s1 s2 s3 s4 "c") 
    (setvar "thickness" tp)
    (command "3dface" s1 s2 s3 s4 "") 
    (command "3dface" s5 b1 b4 s8 "") ;create the chair back
    (setvar "thickness" bh)
    (command "line" b1 b2 b3 b4 "c") 
    (setvar "thickness" tp)
    (command "3dface" b5 b6 b7 b8 "")
  )
) 
;;;
;;;end of program - start of dtr/rtd conversions
(defun dtr (a) 
  (* pi (/ a 180.0))
) 
(defun rtd (a) 
  (/ (* a 180.0) pi)
) 
;;;  
(princ "\nThis program contains the commands: ") 
(princ "\nTable, 3dcab, Chair, and Armchr.") 
(princ) 
;;;


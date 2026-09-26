
  ; SPRAYPAINT: apply text to an entity.
  ; By SW for Rocket Software  Copyright 1991
  ; A program of a thousand uses; all but numbers 232-234, 237, and 916
  ; are strictly for your amusement.  Numbers 615-628 are illegal in some
  ; areas but who really cares?

  ; ******************** first, the error handler ********************
  (DEFUN GNAG (shk)
     (if (/= shk "Function cancelled")
         (if (= shk "insufficient string space")
             (write-line (strcat "Overload: > " (itoa (strlen tt))
                                 " characters at time of crash"))
             (print shk))
         (write-line "Suit yourself"))
     (setq *error* prev)
     (princ))
  ; **************** easy enough, now the main event: ****************

 (defun C:SPRAY ( / nn tt aa ntt ffx cc tx a max rr fn pa tp div nnn spc ttn
                    up aaa ch ss re decu)
   (setvar "cmdecho" 0)
   (setq prev *error*)
   (setq *error* gnag)

  ; The next section gets a string of text (tt) from a file (ff1), a text
  ; entity or the keyboard.  The file line number is saved as nxn,
  ; if nxn = 0 then the whole file is read into a string,
  ; if nxn > 0 then the appropriate line is read.

   (setq tx T)                  ; tentative "don't read a file: get text" flag
   (if ff1
       (setq tt (strcat "Filename <" ff1 "> or T to enter text: "))
       (setq tt "Filename or T to enter text: "))
   (setq ffx (getstring tt))
   (cond ((or (= ffx "T") (= ffx "t"))
              (setq tt (getstring t "Text or <Return> to select: "))
              (if (= tt "")
                  (setq tt (cdr (assoc 1 (entget (car (entsel)))))))
              (setq tx ()))           ; set text flag nil: read a file
         ((/= ffx "") (setq ff1 ffx)))
   (if tx                             ; if OK to read a file
       (progn
             (if (and ff1 (setq fn (Open ff1 "r")))
                 (progn
                       (if (null nxn) (setq nxn 1))
                       (setq cc (getint (strcat "Line to read <" (itoa nxn) 
                                                "> or 0 for entire file: ")))
                       (if cc (setq nxn cc))

  ; ************** whole file to string converter ***********
  ; If line number NXN = 0 then this section reads the file
  ; (name variable ff1) and makes the whole schmear into a text
  ; string: tt.  If the file isn't found, then tt = nil.
   (if (= nxn 0)
       (progn
       (setq tt "")
       (setq spc "")
       (setq aa (getint "Place how many spaces between lines? <1>: "))
       (if (null aa) (setq aa 1))
       (repeat aa (setq spc (strcat spc " ")))
       (while (setq ttn (read-line fn))
              (setq tt (strcat tt spc ttn)))
       (if aa (setq tt (substr tt (1+ aa))))
       (if tt (write-line (strcat (itoa (strlen tt)) " characters in " ff1)))
       (if fn (Close fn))))
  ; ************** end of whole file to string converter *************

  ; ****************** line to string converter **********************
  ; If NXN (line number to read) exists and is not 0 then find line NXN
  ; in specified file (FF1) and read it into variable tt.
   (if (and nxn (/= nxn 0))
       (progn
             (setq tt ())
             (setq nnn nxn)
             (while (> nnn 1) (read-line fn) (setq nnn (1- nnn)))
             (if fn 
                   (progn
                         (setq tt (read-line fn))
                         (if tt
                               (write-line (strcat (itoa (strlen tt))
                                                   " characters in line."))
                               (write-line "End of file. "))))
             (if nxn (setq nxn (1+ nxn)) (setq nxn 1))
             (if fn (Close fn)))))
  ;********************** end of line to string converter *******************

   (progn
         (setq tt ())
         (if ff1 (write-line (strcat "Can't find the file: " ff1))
                 (write-line "No file specified."))))))  ; end of "if tx"

  ; ******************** end of text string acquisition area ****************

  ; ************************* start of entity selection *********************
   (if (= tt "")                            ; if tt exists but is empty: ""
       (progn                               ; set tt nil: no further action.
             (setq tt ())))
   (if tt (progn                            ; if tt contains a text string:
   (setq nnn (strlen tt))                   ; get string length
   (setq spc ())                            ; set spaces added flag to nil
   (setq ntt (entsel "Entity to divide or <Return> to draw circle:\n"))
   (if (null ntt)
       (progn
  ; ************************ circle constructor ************************
  ; If NTT = () (i.e. no entity is selected for division) then this bit
  ; constructs a circle large enough to hold the text string tt.
  ; If the divide pick point is off the screen then it is panned back on -
  ; assuming that acad knows the height/width ratio of your monitor...
  ; which is right now by no means certain.

        (setq pa ())
        (setq tp "CIRCLE")
        (setq pa (getpoint "Pick centre of circle: "))
        (while (null pa)
               (setq pa (getpoint "Keep trying, Einstein: ")))
        (if (null aa) (setq aa 1))
        (setq spc (getint (strcat 
                    "\nAdd how many spaces between ends? <" (itoa aa) ">: ")))
        (if (null spc) (setq spc aa))
        (repeat (/ spc 2) (setq tt (strcat " " tt " ")))
        (if (= (rem spc 2) 1)
            (setq tt (strcat tt " ")))
        (setq nnn (strlen tt))
        (command "circle" pa (setq rr (/ (* 1.5 nnn) pi)))
        (setq pa (polar pa 0 rr))
        (setq a (getvar "screensize"))                    ; view height
        (setq a (/ (car a) (cadr a)))                     ; view width/height
        (setq a (* (getvar "viewsize") a 0.5))            ; view half width
        (setq max (+ a (car (getvar "viewctr"))))         ; view max x coord
        (if (> (car pa) max)                              ; if pa offscreen
            (progn
                  (setq a (getvar "regenmode"))
                  (setvar "regenmode" 1)
                  (command "pan" pa (getvar "viewctr"))  ; pan pa to viewctr
                  (setvar "regenmode" a))))
  ; *********************** circle constructor end **************************

   (progn                               ; if an entity to divide WAS selected
         (setq nn (entget (car ntt)))   ; get its information
         (setq tp (cdr (assoc 0 nn)))   ; get entity type
         (setq pa (cadr ntt))))         ; get pick point
  ; ************************ entity selection end **************************

  ; ******************** assign variables by entity type ********************
  ; The variable DIV contains the number to divide with as opposed to the 
  ; actual number of characters - if an open entity: a line, arc, or open
  ; polyline is divided into n spaces then only n-1 character insertions are
  ; allowed, so these entities must be divided into n+1 sections.

   (setq re ())  ; if re is not set to CW or CCW then entity can't be divided
   (if (= tp "LINE")
       (progn
             (setq div (1+ nnn))
             (setq up (getstring "\nPlace text string right way up? <Y>: "))
             (if (> (cadr (assoc 11 nn)) (cadr (assoc 10 nn)))
                 (if (or (= up "") (= up "y") (= up "Y"))
                     (setq re "CCW")
                     (setq re "CW"))
                 (if (or (= up "") (= up "y") (= up "Y"))
                     (setq re "CW")
                     (setq re "CCW")))))

   (if (= tp "ARC")
       (progn 
             (setq div (1+ nnn))
             (setq up (getstring "Place text string right way up? <Y>: "))
             (if (or (= up "Y")(= up "y")(= up ""))
                 (setq re "CW")
                 (setq re "CCW"))))

   (if (= tp "CIRCLE")
       (progn
             (setq re (getstring "\nWrap clockwise? <Y>: "))
             (if (or (= re "") (= re "y") (= re "Y"))
                 (setq re "CW")
                 (setq re "CCW"))
             (if (null spc)
                (progn
                (if (null aa) (setq aa 1))
                (setq spc (getint (strcat 
                     "\nAdd how many spaces between ends? <" (itoa aa) ">: ")))
                (if (null spc) (setq spc aa))
                (repeat (/ spc 2) (setq tt (strcat " " tt " ")))
                (if (= (rem spc 2) 1)
                    (setq tt (strcat tt " ")))))
             (setq div (setq nnn (strlen tt)))))

   (if (= tp "POLYLINE")
       (progn
             (setq re (getstring "Wrap from polyline start? <Y>: "))
             (if (or (= re "") (= re "y") (= re "Y"))
                 (setq re "CW")
                 (setq re "CCW"))
             (if (= (rem (cdr (assoc 70 nn)) 2) 1)    ; if a closed polyline
              (progn
                (if (null aa) (setq aa 1))
                (setq spc (getint (strcat 
                     "\nAdd how many spaces between ends? <" (itoa aa) ">: ")))
                (if (null spc) (setq spc aa))
                (repeat (/ spc 2) (setq tt (strcat " " tt " ")))
                (if (= (rem spc 2) 1)
                    (setq tt (strcat tt " ")))
                (setq div (setq nnn (strlen tt))))
              (setq div (1+ nnn)))                 ; if not closed
       ))                                             ; progn end, if end

   (if re (progn          ; if re is set: entity can be divided
   (if (= nnn 1) (setq tt (strcat tt " ") nnn 2 div 2)) ; can't div. into 1

  ; ******************** prompt for letter rotate ***********************
   (setq decu (getstring "Rotate letters 180ø? (E=Explain) <N>: "))
   (if (or (= decu "") (= decu "n") (= decu "N"))
       (setq decu ())
       (progn
             (if (or (= decu "E") (= decu "e"))
                 (progn
                       (textscr)
(write-line "\n\nThe direction in which the text string is placed onto the")
(write-line "selected entity also controls which way up the text is placed.")
(write-line "If you want to write the text upside down with respect to the")
(write-line "order of placement, as may be required when dealing with oddly")
(write-line "structured polylines or conditions of dangerous boredom, then")
(write-line "you might want to try this option.\n")
                       (if (getstring "<Return> to continue.\n")
                           (graphscr))
                       (setq decu (getstring "So: Rotate? <N>: "))
                       (if (or (= decu "") (= decu "n") (= decu "N"))
                           (setq decu ())
                           (setq decu t)))
                 (if (or (= decu "Y") (= decu "y"))
                     (setq decu t)
                     (progn
                           (write-line "Invalid. Letters not rotated.")
                           (setq decu ())))
             )))
  ; ********************** letter rotate prompt end ************************
  ; ********************** variable assignment end *************************

  ; ************************* divide mechanism *****************************
  ; This part is what you see. It divides the chosen entity with the correct
  ; block, explodes the blocks, and changes the resulting letters into the
  ; characters from tt. If the character is a space the letter is deleted
  ; so as to avoid creating invisible text entities.

    (setq ccc (setq aaa (entlast)))
    (while (entnext aaa)
           (setq aaa (entnext aaa)))   ; find the last entity in the drawing

  ; ******************** Subroutine "Block find/insert" ******************
  ; This part searches the block table for either CCW or CW, as specified
  ; by RE.  If the appropriate block is not found, acad is forced to add
  ; it to the block table.
    (setq ch ())
    (setq ss (tblnext "block" t))
    (if (= (cdr (assoc 2 ss)) re)
        (setq ch t)
        (progn
              (while (and (setq ss (tblnext "block")) (null ch))
                     (if (= (cdr (assoc 2 ss)) re)
                         (setq ch t)))))
    (if (null ch)
        (progn
              (command "insert" re )
              (command)))
  ;********************** end of block find/insert ***********************

    (if decu
        (if (= re "CW")
            (setq re "CCW")
            (setq re "CW")))
    (command "divide" pa "b" re "y" div)
    (if decu
        (if (= re "CW")
            (setq re "CCW")
            (setq re "CW")))

  ;-------------------Find blocks from divide command---------------------
    (while (/= (cdr (assoc 0 (entget aaa))) "INSERT")
           (setq aaa (entnext aaa)))
  ;--------------------------Explode blocks ------------------------------
    (while (= (cdr (assoc 0 (entget aaa))) "INSERT")
           (command "explode" aaa)
           (setq aaa (entnext aaa)))
  ;--------------------Change to desired characters-----------------------
    (if (= re "CW")
        (progn
              (while aaa
                     (setq dig (substr tt nnn 1))
                     (setq lln (entget aaa))
                     (setq zz (cdr (assoc 1 lln)))
                     (if (= dig " ")
                         (entdel aaa)
                         (entmod (subst (cons 1 dig) (cons 1 zz) lln)))
                     (setq aaa (entnext aaa))
                     (setq nnn (1- nnn))))

        (progn
              (setq nnn 1)
              (while aaa
                     (setq dig (substr tt nnn 1))
                     (setq lln (entget aaa))
                     (setq zz (cdr (assoc 1 lln)))
                     (if (= dig " ")
                         (entdel aaa)
                         (entmod (subst (cons 1 dig) (cons 1 zz) lln)))
                     (setq aaa (entnext aaa))
                     (setq nnn (1+ nnn)))))
       ) (write-line "Cannot divide that entity. Grab a brain."))
       ))
    (setq *error* prev)
        (princ))
;
;  MISC.LSP  (MISCLISP.ARC)
;  by Tony Tanzillo, A/E Automation Systems
;  8/24/87
;  Public domain software for non-commercial use
;  Miscellaneous AutoLISP programs and tips
;
;  The contents of this file were contributed to CADalyst Magazine
;  by Tony Tanzillo, founder & president of A/E Automation Systems,
;  Design Automation Consultants. Excerpts from this file have been
;  published in CADalyst Volume 4, #3 & #4. They are the sole
;  property of CADalyst. The contents of this file is being donated
;  to the public domain for NON-COMMERCIAL use and un-altered
;  distribution.
;
;  A/E Automation Systems is a group of dedicated professionals who
;  are experts in both CADD/Computers/Programming, and thier
;  respective disciplines to which they apply AutoCAD to. Currently,
;  these include Archicture/Engineering/Construction, electronics
;  engineering, mechanical & electro-mechanical engineering, civil
;  engineering, and space planning and interior design.
;
;  The firm offers professional CADD/Design Automation consulting
;  services on an hourly or contract basis. The following is a brief
;  summary of the products and services available.
;
;     New installation/pre-purchase services:
;
;       - CADD productivity analysis/profit cycle/feasability studies.
;
;       - Product research, evaluation, and specification.
;
;       - Installation supervision and management.
;
;     Post/existing installation services:
;
;       - Training (AutoCAD/LISP/SHADE/SKETCH, introductory thru advanced).
;
;       - AutoLISP programming
;
;       - Independent phone-based user support (by contract)
;         (including interactive support via modem).
;
;       - CADD management (via modem or onsite)
;
;     Other products & services available:
;
;       - Extensive AutoCAD customization/programming to optimize
;         system to specific disciplines.
;
;       - Professional AutoLISP programming (contract & hourly)
;         Including complete development, testing, installation,
;         training, and support of turnkey applications.
;
;       - Custom symbol libraries, electronic product catalogs and
;         templates (generic and manufacturer specific).
;
;     AutoCAD Application Software
;
;       - Developers of commercial AutoCAD add-in applications
;         Including AutoLISP programming tools and utilities,
;         function libraries for application developers, user
;         customization tools, And descipline-specific application
;         software products.
;
;
;  For more information on products and services available from
;  A/E Automation Systems, call during business hours, or write to;
;
;  A/E Automation Systems
;  32 Gould Ave.
;  Paterson N. J. O7503
;  Att: Tony Tanzillo
;
;  Phone: (201) 523-7944 (business hours only, M-F)
;
;  AutoCAD, AutoLISP, AutoSHADE, AutoSKETCH, and ADI are registered
;  trademarks of Autodesk inc.
;
; --------------------------------------------------------------------
; TXF.LSP   AutoCAD TEXT IMPORT/EXPORT FACILITY
;
; By Tony Tanzillo, A/E Automation Systems
;
; EXPORT & IMPORT are user-defined lisp commands that permit you to
; EXPORT all text in your drawing to an ascii text file, where you
; can easily spell-check and edit the text with a word processor or
; text editor on a line-by-line basis, and then IMPORT the text
; back into your drawing returning each text entity to its original
; location.
;
; This system can be especially useful to those using Sidekick,
; or another resident text editor, or even an ONLINE spelling-checker
; /thesaurus because the entire process may be accomplished without
; ever leaving the drawing editor.
;
; EXPORT will export ALL text in the drawing file to the file
; specified by the user. Each text entity in the drawing will occupy
; one line in the file in the order that the text appears in the
; drawing database. The text entities that are written out to disk
; will be replaced with null strings ("") so that they can be put
; back in thier proper sequence when they are imported back into the
; drawing. Once exported, the text entities will appear to have been
; deleted, but don't panic, they are still there, only thier values
; have been changed to null strings. You will not be able to edit or
; erase them in any way until the text has been imported back into
; the drawing.
;
; To use the text IMPORT/EXPORT facilities provided here, simply
; add the functions to your ACAD.lsp, or (LOAD"TXF.LSP") once you
; are in the drawing editor.
;
; To export the text in the drawing you are working on, simply
; enter "EXPORT" <cr> at the AutoCAD command prompt. You will then
; be asked for an OUTPUT filespec, which can be any legal DOS file
; specification including drive, directory path, filename and
; extension (I always use an extension of .TIF for Text Interchange
; File).
;
; If the OUTPUT filespec already exists, you will be notified of
; such, and told to start over and use another filespec. Once you
; specify the filespec and it is accepted, the drawing database is
; scanned and all text is exported to the specified file on an
; entity-by-line basis (one line of text is written for each text
; entity in the drawing, in the logical order in which they appear
; in the database).
;
; Once the process is completed, All text from the drawing will
; be in the output text file. You can then save your drawing, exit
; from AutoCAD, and use your favorite word processor, spelling
; checker, or text editor (word processors such as Wordstar must be
; used in the NON-DOCUMENT MODE) to check spelling and edit the text
; output file. Once satisfied with the edited text file, you can
; then run AutoCAD and edit the same drawing again, and IMPORT the
; edited text file back into your drawing, corrections and all.
;
; To import the text back into the drawing, simply enter "IMPORT" <CR>
; at the AutoCAD command prompt. You will then be prompted for the
; input file specification which should be the name of the file you
; edited with your word processor. The text from the specified input
; file will be read line-by-line and will replace each EXPORTED text
; entity in the drawing.
;
; Words of caution
;
; When you are editing the EXPORTted text file, you should be extra
; careful to make sure you do not MOVE, COPY, ADD, DELETE, JOIN or
; SPLIT any LINES of text from it (or change the number of lines in
; the file). When importing the finished text file, every line of
; text must be in precisely the EXACT sequence they were in when
; they were EXPORTed, or text will not be returned to the places
; from which they originated. It is also advised that you make a
; backup copy of the EXPORTed file to play it safe (since that
; is the only place that your text will exist while it is in the
; process of being edited)

(defun C:EXPORT( / outfile)
  (if
    (and
       (not (eq "" (setq outfile (getstring "\nText output file: "))))
       (if (filep outfile)
         (prompt
           (strcat "\nFile " (strcase outfile)
             " already exists, try again."))T)
       (setq outfile (open outfile "w")))
    (progn
      (global 'object
        '(if (eq (get object 0) "TEXT")
           (progn
             (write-line (get object 1) outfile)
             (entput object 1 ""))) t)
      (close outfile))
      (if (not (filep outfile)) (prompt "\nInvalid filespec, try again."))) (prin1))


(defun C:IMPORT( / infile line) ; replaces text in drawing with
  (if                            ; with text from file.
    (and
      (not (eq "" (setq infile (getstring "\nText input file: "))))
      (setq infile (open infile "r")))
    (progn
      (global 'object
        '(if
           (and
             (eq (get object 0) "TEXT")
             (eq (get object 1) "")
             (setq line (read-line infile)))
         (entput object 1 line)) t )
      (close infile))
    (prompt "\nInvalid filespec, try again."))
  (prin1))


; support functions

; (entput <ename> <groupcode> <value> )
; Replaces or adds the specified <value> to the property specified
; by <groupcode> for the entity specified by <ename>.

(defun entput(e p v / pr o)
  (setq pr (entget e))
    (entmod (if (setq o (assoc p pr))
      (subst (cons p v) o pr) (append pr (cons p v)))))

; (filep <"filespec">)
; returns it's argument (a string) if a file with that name exists,
; and NIL otherwise.

(defun filep(f / p) (cond ((setq p (open f "r")) (close p) f)))

; (global <alias> <procedure> <count>)
;
; Global will take <procedure> (any valid lisp expression) and apply
; it sequentially to each entity in the drawing, assigning each
; entity name to <alias>.
;
; If <count> is NON-NIL, then the message "Processing drawing database..."
; is printed on the display along the number of each entity as
; it is processed.
;
; Note: this procedure is very powerful (and should be used with caution).
;       It can be employed for many different purposes in the sense
;       that it can take the entire drawing entity-by-entity and
;       apply an "if-then-else" test for each entity and branch on
;       the result. You can use any valid LISP expression regardless
;       of the complexity (memory permitting) as the <procedure> argument,
;       and it will be applied to each entity in the drawing database.


(defun global (smb expr count / i)
  (set smb (entnext))
  (setq i (if count 0))
  (prompt "\nProcessing drawing database... \n")
  (while
    (progn
      (if i (prompt (strcat "\rEntity " (itoa (setq i (1+ i))))))
      (eval expr)
      (set smb (entnext (eval smb))))))


; (get <ename> <property>)
;
; Returns the value of the specified <property> (which must be the
; group code of the desired property) from the entity specified by <ename>.


(defun get(e g) (cdr (assoc g (entget e))))

;-------------------------------------------------------------------
; Miscellaneous AutoLISP commands, functions, and tips.
;
; XPLODE command
;
; This is a COMMAND that uses the GLOBAL function above to EXPLODE
; every POLYLINE in the drawing with one command. To use it, simply
; enter "XPLODE" at the AutoCAD command prompt. It also requires the
; GET function above. As you can see, the function is quite small
; considering what it does, mainly because it takes advantage of the
; flexibility provided by the GLOBAL function.

  (defun C:XPLODE( / pline)
    (setvar "cmdecho" 0)
    (global 'pline
      '(if (eq (get pline 0) "POLYLINE")
         (command "explode" pline)) t
    )
    (prin1)
  )

;-------------------------------------------------------------------
;
; DELETE command
;
; This command, which also exploits the power of the GLOBAL function
; will DELETE all insertions of the specified block. It also requires
; the GET function.

  (defun C:DELETE( / blk object)
    (setvar "cmdecho" 0)
    (if
      (not
        (eq "" (setq blk  (getstring "\nEnter name of block to delete: "))))

      (global 'object                            ; repeat once for each
        '(if                                     ; entity in the drawing
           (and
             (eq (get object 0) "INSERT")        ; block insertion?
             (eq (get object 2) (strcase blk)))  ; the one we are after?

           (entdel object)                       ; yes, delete insertion
         ) t
      )
    )
    (prin1)
  )


; TOP function
;
; This is a handy little function that will permit you to specify
; the elevation at the TOP of a 3 dimensional object (the object's
; elevation PLUS it's thickness).
;
; This function can be used as a reply whenever AutoCAD is requesting an
; ELEVATION. For example, Assuming we were to draw a round column (a
; circle with thickness), the base of which was at elevation 6'-0" and
; it's thickness was 12'-6". This would put the TOP of the column at an
; elevation of approximately 18'-6". Lets suppose for a second that we
; need to place a beam across the top of the column which was to span to
; another similar column (a la Stonehenge). In order to do this we must
; first SET our elevation to the TOP of the column, this would normally
; require us to LIST the object, add it's elevation to it's thickness,
; and then reply with the resulting value when setting our new drawing
; elevation.
;
; With the use of the TOP function, we can simply point to the
; column, and the function will return the sum of the column's
; elevation and thickness and pass it directly to AutoCAD which
; will gladly accept it in liew of a user-entered distance, and
; continue just as if you had entered it from the keyboard
; (with all 16 significant decimal places!)
;
; First lets draw the columns for our Stonehenge after first setting
; the appropriate elevation and thickness;
;
; Command: ELEV
;
; New current elevation <0'-0">: 6'0"    ; the elevation of the column
;
; New current thickness <0'-0">: 12'6"   ; the thickness (height)
;                                        ; of the column
;
; Command: CIRCLE
;
; 3P/2P/TTR/<Center point>: Diameter/<Radius>: 9" <18" diameter>
;
; Now, we must set the appropriate elevation and thickness for our
; beam. In this situation, it is easy to remember that our column is
; at an elevation of 6', and it is 12'-6" high. and therefore,
; simple arithmetic reveals that our beam must have a bearing
; elevation of approximately 18'-6".
;
; But let's assume for a moment that we didn't know exactly what the
; elevation and thickness of the column was. Obviously we must seek
; out that information in order to draw the beam at the proper
; elevation right?
;
; Absolutely not! We can use the TOP function defined here to not
; only find and calucuate the new elevation from the object in
; question, but it can also "tell AutoCAD" exactly what the required
; new elevation must be (and maintain the 16 decimal place numeric
; accuracy which is inherent to AutoCAD!).
;
; To set our new drawing elevation to the TOP of the columns, we
; start out as usual when setting a new elevation and thickness;
;
; Command: ELEV
;
; New current elevation <6'-0">: (TOP) ; reply with the name of the function
;
; Top of object: <select one of the columns>
;
; New current thickness <12'-6">: 2'   ; the thickness of our beam
;
; At this point the new current drawing elevation should be approx.
; 18'-6", you can enter the ELEV command again just to make sure.
; You should now be able to draw a beam across the 2 circular
; columns (using a wide polyline if you wish) and it should be at
; just the right height. View the object in 3d to verify this.

  (defun TOP( / e)
    (cond ((setq e (car (entsel "Top of object: ")))
             (+ (cond ((get e 38)) (T 0.0))
                (cond ((get e 39)) (T 0.0)))
          )
    )
  )

;  TOP also requires the GET function from above.
;
;------------------------------------------------------------------
;
;  RELEV function
;
;  Here is a similar function that will permit you to set the
;  current drawing elevation, or change the existing elevation of an
;  object relative to it's current elevation or the elevation of
;  another specified object. Again, it is valid response to any
;  AutoCAD-generated elevatoin prompt (for example, the ELEV
;  command, or the CHANGE P<roperties> E<levation> command). The
;  example shows it as it can be used with the CHANGE command.
;
;  The new elevation of the object will be equal to the elevation of
;  the selected reference object (which could be the same object
;  that is being changed, or another) PLUS the distance you specify
;  (can be positive or negative).
;
;  Example of a typical use would be to raise or lower an object
;  from it's existing elevation without having to determine that
;  value, but rather, just the distance which the object is to be
;  raised or lowered. To lower the object, enter a negative value,
;  and to raise it, a positive one.
;
;  For example, let's say we have a flat surface which represents a
;  table top that is currently at 30" above a floor (the elevation
;  of the floor may not necessarily be 0.0"). If we wanted to raise
;  that counter top approximately 4 inches from it's current height
;  regardless of what it's current elevation value is, we could use
;  RELEV thusly;
;
;  Command: CHANGE
;  Select objects: <select the counter top>
;  Properties/<Change point>: P
;  Change what property (Color/Elev/LAyer/LType/Thickness) ? E
;  New elevation <2'-6">: (RELEV)
;  Select reference object: <select the counter top again>
;  Relative elevation: 4"
;  Change what property (Color/Elev/LAyer/LType/Thickness) ? <CR>
;  Command:
;
;  In effect what we just did was RAISE the counter top by 4". We
;  also could have LOWERED the counter top by 6" by simply
;  responding to Relative elevation: with -6".
;
;  RTHICK function
;
;  Now, unless you believe in levitation and other spooky things, a
;  table must have legs RIGHT! So obviously, we must also change the
;  HEIGHT (thickness) of the legs and make them 4" higher right!
;
;  Here is another function which operates on an objects thickness
;  just like RELEV works with it's elevation. This one has a
;  reporting facility which tells you the current thickness, and
;  displays and accepts a default distance value. To avoid confusion
;  of prompts, it also uses a special type of prompt that tells the
;  user that he/she has temporarily exited the change command, and
;  is using the RTHICK function. This is simply to tell the user
;  that he or she has temporarily exited from the current command
;  sequence.
;
;  Here goes.....
;
;  Command: CHANGE
;  Select objects: <select all of the table's legs>
;  Properties/<Change point>: P
;  Change what property (Color/Elev/LAyer/LType/Thickness) ? T
;  New thickness <2'-6">: (RTHICK)
;  RTHICK > Select object: <select one of the table legs>
;  RTHICK > Current height/thickness is 2'-6",
;  RTHICK > Relative height/thickness: 4"
;  <Resuming AutoCAD command>
;  Change what property (Color/Elev/LAyer/LType/Thickness) ? <CR>
;  Command:
;
;

(defun RTHICK ( / e h)
  (setq *sp*
    (strcat
      (cond (*sp*) (t "\n"))
      "RTHICK > "
    )
  )
  (cond
    ((setq e (car (entsel (strcat *sp* "Select object: "))))
      (prompt
        (strcat *sp* "Current height/thickness is "
                (rtos
                  (setq h
                    (cond ((get e 39))
                          (t 0.0)
                    )
                  )
                )
                ", "
        )
      )
      (prompt
        (strcat *sp*
          "New height/thickness = "
          (rtos
            (setq res
              (+ h
                (cond
                  ( (getdist
                      (strcat *sp*
                        "Relative height/thickness <"
                        (rtos 0.0)
                        ">: "
                      )
                    )
                  )
                  (t 0.0)
                )
              )
            )
          )
        )
      )
    )
  )
  (setq *sp* (prompt "\n<resuming AutoCAD command>"))
  res
)


(defun relev ( / e)
  (setq e (car (entsel "\nSelect reference object: ")))
  (+ (cond ((get e 38)) (t 0.0))
     (getdist "Relative elevation: ")))

;-------------------------------------------------------------------
;
;  Dynamic PICKBOX / APERTURE size control
;
;  Here is a way to DYNAMICALLY change the size of the
;  pickbox/aperture target when either is visible on the display. It
;  is intended to be used at any AutoCAD-generated Select object(s):
;  prompt, or point prompt when the pickbox and/or aperture target
;  is visible.
;
;  When you are at any AutoCAD-generated Select object(s) prompt,
;  enter (PICKBOX). Then, tapping the + or - key on your numeric
;  keypad will cause the pickbox to be enlarged or reduced in size
;  by one pixel respectively. You can size the boxes by eye since
;  you can see the size of the box change as you tap the +/-keys.
;  Because reentry is not permitted, you can only use these
;  functions at AutoCAD prompts, and not those generated by other
;  AutoLISP programs.
;
;  Example usage of (pickbox):
;
;  Command: TRIM
;  Select boundary edges(s),
;  Select objects: <select boundary objects>
;  Select object to trim: (pickbox) +/-/Select object:
;
;    Key + or - until the pickbox is the desired size, then simply
;    continue object selection when the pickbox is the desired size
;    (selecting an object causes the sizing function to terminate
;    and the selection point is passed to AutoCAD and used as a
;    response to the pending Select objects: prompt).
;
;  Example usage of (aperture):
;
;  Command: OSNAP
;  New object snap modes: END
;  Command: LINE
;  From point: (aperture) +/-/Point:
;
;    Key + or - until the aperture is the desired size, then select
;    a point to terminate sizing (the point has is passed to AutoCAD
;    and used as the response to the "From point: " prompt, and a
;    rubber-band cursor is attached to that point.

(defun pickbox() (prompt "+/-/Select object: ") (size "pickbox"))

(defun aperture() (prompt "+/-/Point: ") (size "aperture"))

(defun size(p)
  (while
    (if (member (setq k (cadr (grread))) '(43 45))
      (setvar p (+ (getvar p) (cadr (assoc k '((43 1) (45 -1))))))))
  (cond ((listp k) k)
        ((prin1))))

;--------------------------------------------------------------------
;
;  AutoTIPS (do not LOAD)
;
;  AutoTIP #0001
;
;  You can prevent a lisp expression from returning a result to the
;  AutoCAD command line simply by placing (prin1) as the last TOP-
;  LEVEL expression in the function.
;
;  For example;
;
; (defun C:DRAWLINE( / from to)               ; a simple example
;   (setvar "cmdecho" 0)                      ; of the use of (prin1),
;   (setq a (getpoint "From point: "))        ; get 2 points from user
;   (setq b (getpoint "To point: "))          ; and draw a line between
;   (if (and a b) (command "line" a b ""))    ; them.
;   (prin1)                                   ; (prin1) will prevent the
; )                                           ; result of (c:drawline)
;                                            ; from being echoed back
;                                            ; to the AutoCAD command line.
;
;--------------------------------------------------------------------
;
; AutoTIP #0002
;
; Tip: Here is a function that act's just like basic's LPRINT.
;      You can print any string value to your printer with it,
;      for example;
;
; (lprint "Hello!") ; should print Hello! on your printer.
;
; Caution: THIS function should be used with extreme caution since
;          it can cause AutoCAD to HANG if the printer is OFF,
;          NOT READY, or there is none connected to the system at all.
;          There appears to be no way to verify if printer is ready
;          with AutoLISP, so BE CAREFUL!
;
;
;          (defun lprint(s / prn)
;            (setq prn (open "PRN" "w"))
;            (write-line s prn)
;            (close prn)
;          )
;
;------------------------------------------------------------------
;
; AutoTIP #0003
;
; When you erase the LAST object in the drawing with ERASE L, you
; also destroy the <P>revious selection set. but sometimes there is
; a way to preserve it when erasing the last object.
;
; If you use ERASE L, That last object will become the <P>revious
; selection set via the object selection mechanisim. and therefore,
; you no longer have a <P>revious selection set.
;
; The tip:
;
; If you have just drawn something, and decide to can it, you can
; preserve the <P>revious selection set (provided that it and the
; last object are not one one and the same) by creating a tiny
; AutoLISP function that will "ZAP" (erase) the last object drawn
; unconditionally.
;
; (defun C:ZAP()           ; Call it what you wish, I like this name.
;   (entdel (entlast))     ; delete the last object in the database.
;   (prin1)
; )
;
;
; Note however, that the object selected by L during an object
; selection, and the object erased by this ZAP command will not
; always be one and the same. The object selection <L>ast will
; select the LAST object in the database that IS VISIBLE ON THE
; DISPLAY. The object that is erased by ZAP is the ABSOLUTE last
; object added to the drawing regardless of it is visible on the
; display or not.
;
; ------------------------------------------------------------------
;
; AutoTIP #0004
;
; You can avoid the annoying 2nd regen due to change in drawing extents
; (which is not always needed) when you Zoom Extents with the following
; lisp function;
;
; (defun EXTENTS()
;   (command "w" (getvar "extmin") (getvar "extmax"))
;   (prin1))
;
;
; Here is another ZOOM option that can be used with AutoCAD version
; 2.6. This one permits you to zoom out to the largest view that
; would be permitted without requiring a regen.
;
; (defun VSCREEN ()
;   (command "w" (getvar "vsmin") (getvar "vsmax"))
;   (prin1))
;
; Here's how to use them;
;
; Command: ZOOM
; All/Center/Dynamic/Extents/Left/Previous/Window/<Scale(X)>: (VSCREEN)
;
;   <AutoCAD zooms to the virtual screen>
;
; The extents function is used in precisely the same manner.
;
;
;-----------------------<End of file MISC.LSP>----------------------------

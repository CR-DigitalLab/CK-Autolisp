;;;Reformat and reposition/reinsert multiline text notes (not MTEXT).
;;;Copies text and attributes from Xrefs to format new notes.
;;;
;;;          AUTHOR: HENRY C. FRANCIS
;;;                  425 N. Ashe Street
;;;                  Southern Pines, NC 28387
;;;              
;;;          All rights reserved without prejudice.
;;;
;;;       Copyright:     1999
;;;       Edited:        11-24-2006
;;;
;;;When Text size is specified, it is in Leroy template sizes.  Leroy template
;;;sizes are in 1000ths. Leroy 100 template is 100/1000ths or 0.10" high at a
;;;dimscale of 1.  It is 3.00" high at a dimscale of 30.
;;;
;;;The following are required:
;;;GETSTYLE.LSP, MKLAYR.LSP, UUTILS.LSP, TXTSIZE.LSP
;;;
;;;
;;;****************************************************************************
(DEFUN reattr_error (msg /)
  (princ (strcat "\nError: " msg))
  (IF old_reattrosmode
    (SETVAR "OSMODE" old_reattrosmode)
  ) ;_ end of IF
  (SETQ *error* orig_reattrerror)
  (PRINC)
) ;_ end of DEFUN
;;;****************************************************************************
(defun c:reattr (/ cntr nostr txtent)
  (SETQ orig_reattrerror
         *error*
        *error* reattr_error
  ) ;_ end of SETQ
  (SETQ old_reattrosmode (GETVAR "OSMODE"))
  (SETVAR "OSMODE" 66)
  (if c:mklayr
    nil
    (load "mklayr" "\nMKLAYR.LSP not found")
  ) ;_ end of if
  (if (AND upoint ukword)
    nil
    (load "uutils" "\nUUTILS.LSP not found")
  ) ;_ end of if
  (if dimscl
    nil
    (load "dimscl" "\nDIMSCL.LSP not found")
  ) ;_ end of if
  (setq mycmdname "C:REATTR")
  (dimscl)
  (c:svlayr)
  (if gvpno
    nil
    (load "gvpno" "\nGVPNO.LSP not found")
  ) ;_ end of if
  (gvpno)
  (setq cntr 0)
  (if getstyle
    (getstyle "A")
    (progn (load "getstyle") (getstyle "A"))
  ) ;_ end of if
  (if txtsize
    nil
    (load "txtsize" "\nFile TXTSIZE.LSP not found!")
  ) ;_ end of if
  (setq how_to_do "Reposition")
  (IF tnjst
    (SETQ tnjst (strcase tnjst))
  ) ;_ end of IF
  (PRINC "\n  reattr_txth = ")
  (PRINC reattr_txth)
  (PRINC "\n  reattr_txth TYPE = ")
  (PRINC (TYPE reattr_txth))
  (princ)
  (if reattr_txth
    NIL
    (SETQ reattr_txth "110")
  ) ;_ end of if
  (princ (strcat "\nCurrent settings: ht="
                 (IF reattr_txth
                   reattr_txth
                   "nil"
                 ) ;_ end of IF
                 "; just="
                 (if (eq (type tnjst) 'STR)
                   tnjst
                   "nil"
                 ) ;_ end of if
                 ".  Select ATTRIB or TEXT: "
         ) ;_ end of strcat
  ) ;_ end of princ
  (setq txtent_lst nil)
  (setq txtent (ssadd))
  (setq my_nselp T)
  (while my_nselp
    (while
      (setq my_nselp (nentselp ""))
       (setq txtsel (entget (car my_nselp)))
       (princ "\n  (CDR (ASSOC 0 TXTSEL)) = ")
       (PRINC (CDR (ASSOC 0 TXTSEL)))
       (if
         (or
           (eq (cdr (assoc 0 txtsel)) "TEXT")
           (eq (cdr (assoc 0 txtsel)) "ATTRIB")
         ) ;_ end of or
          (progn
            (princ (strcat "\n    " (cdr (assoc 1 txtsel))))
            (redraw (cdr (assoc -1 txtsel)) 3)
            (if txtent_lst
              (setq txtent_lst (append txtent_lst (list txtsel)))
              (setq txtent_lst (list txtsel))
            ) ;_ end of if
            (if txtent
              (setq txtent (ssadd (cdr (assoc -1 txtsel)) txtent))
              (setq txtent (ssadd (cdr (assoc -1 txtsel))))
            ) ;_ end of if
          ) ;_ end of progn
       ) ;_ end of if
    ) ;_ end of while
    (while txtent_lst
      (setq newtxtss (ssadd))
      (setq nostr (length txtent_lst))
      (setq cntr 0)
      (cond
        ((eq tnjst "Center") (setq tnjst "C"))
        ((eq tnjst "Middle") (setq tnjst "M"))
      )                                 ;cond
      (setq old_reattr_osmode (GETVAR "osmode"))
      (SETVAR "OSMODE" 0)
      (while
        (or
          (not (eq (type
                     (setq txtpt
                            (upoint
                              1
                              "Options"
                              "Point for first line of text OR <O>ptions"
                              nil
                              nil
                             ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
                     ) ;_ end of setq
                   ) ;_ end of type
                   'LIST
               ) ;_ end of eq
          ) ;_ end of not
          (not tnjst)
          (not reattr_txth)
        ) ;_ end of or
         (if (or (eq txtpt "Options") (not tnjst))
           (setq tnjst
                  (ukword 1
                          "Left Center Middle Right TL TC TR ML MC MR BL BC BR"
                          "Left/Center/Middle/Right/TL/TC/TR/ML/MC/MR/BL/BC/BR"
                          (if tnjst
                            tnjst
                            "L"
                          ) ;_ end of if
                  ) ;_ end of ukword
           ) ;_ end of setq
         ) ;_ end of if
         (if (or (eq txtpt "Options") (not reattr_txth))
           (PROGN
             (txtsize nil)
             (SETQ reattr_txth thts)
           ) ;_ end of PROGN
           (PROGN
             (txtsize reattr_txth)
             (SETQ reattr_txth thts)
           ) ;_ end of PROGN
         ) ;_ end of if
      ) ;_ end of while
      (COND
        ((EQ (SUBSTR tnjst 1 1) "L")
         (SETQ assoc_72 0
               assoc_73 0
         ) ;_ end of SETQ
        )
        ((EQ (SUBSTR tnjst 1 1) "C")
         (SETQ assoc_72 1
               assoc_73 0
         ) ;_ end of SETQ
        )
        ((EQ (SUBSTR tnjst 1 1) "M")
         (SETQ assoc_72 4
               assoc_73 0
         ) ;_ end of SETQ
        )
        ((EQ (SUBSTR tnjst 1 1) "R")
         (SETQ assoc_72 2
               assoc_73 0
         ) ;_ end of SETQ
        )
        ((EQ tnjst "TL")
         (SETQ assoc_72 0
               assoc_73 3
         ) ;_ end of SETQ
        )
        ((EQ tnjst "TC")
         (SETQ assoc_72 1
               assoc_73 3
         ) ;_ end of SETQ
        )
        ((EQ tnjst "TR")
         (SETQ assoc_72 2
               assoc_73 3
         ) ;_ end of SETQ
        )
        ((EQ tnjst "ML")
         (SETQ assoc_72 0
               assoc_73 2
         ) ;_ end of SETQ
        )
        ((EQ tnjst "MC")
         (SETQ assoc_72 1
               assoc_73 2
         ) ;_ end of SETQ
        )
        ((EQ tnjst "MR")
         (SETQ assoc_72 2
               assoc_73 2
         ) ;_ end of SETQ
        )
        ((EQ tnjst "BL")
         (SETQ assoc_72 0
               assoc_73 1
         ) ;_ end of SETQ
        )
        ((EQ tnjst "BC")
         (SETQ assoc_72 1
               assoc_73 1
         ) ;_ end of SETQ
        )
        ((EQ tnjst "BR")
         (SETQ assoc_72 2
               assoc_73 1
         ) ;_ end of SETQ
        )
        (T
         (SETQ assoc_72 0
               assoc_73 0
         ) ;_ end of SETQ
        )
      ) ;_ end of COND
      (SETVAR "OSMODE" old_reattr_osmode)
      (if (not reattr_txth)
        (txtsize nil)
        (PROGN
          (txtsize reattr_txth)
          (SETQ reattr_txth thts)
        ) ;_ end of PROGN
      ) ;_ end of if
      (if uangle
        nil
        (load "uangle" "\nFile UANGLE.LSP not found!")
      ) ;_ end of if
      (setq noteang
             (uangle
               1
               "View Text"
               "Enter text angle, match <T>ext, or horizontal to <V>iew"
               "View"
               txtpt
              ) ;_ end of uangle
 ;_ end of uangle
 ;_ end of uangle
 ;_ end of uangle
 ;_ end of uangle
      ) ;_ end of setq
      (cond
        ((eq noteang "View")
         (setq txrot (- 0 (getvar "viewtwist")))
        )
        ((eq noteang "Text")
         (setq txrot (cdr (assoc 50 (entget ent))))
        )
        (T (setq txrot noteang))
      ) ;_ end of cond
      (setq colr "1")                   ;txcolr
      (c:mklayr)
      (setq txtobl (* PI (/ 15.0 180.0)))
                                        ;(assoc 51 (nth 0 txtent_lst))
      (while (< cntr nostr)
        (setq ent   (cdr (assoc -1 (nth cntr txtent_lst)))
              txstr (cdr (assoc 1 (entget ent)))
        )                               ;setq
        (while (eq (substr txstr 1 1) " ") ;this while loop strips off
          (setq txstr (substr txstr 2)) ;leading spaces, true text 
        )                               ;while                                   ;justification requires it
        (while (eq (substr txstr (strlen txstr) 1) " ")
                                        ;this while loop strips off
          (setq txstr (substr txstr 1 (1- (strlen txstr))))
                                        ;trailing spaces, true text 
        )                               ;while                                         ;justification requires it
;;;	(if (eq cntr nostr)
;;;	  (if (eq (substr tnjst 1 1) "L")
;;;	    (command ".text" txtpt txtht txrot txstr)
;;;	    (command ".text" tnjst txtpt txtht txrot txstr)
;;;	  )				;if
;;;	  (command ".text" "" txstr)
;;;	)				;if
        (if (eq txstr "BOOK")
          (SETQ txstr "DEED BOOK:")
        ) ;_ end of if
        (if
          (and
            (eq txstr "DEED BOOK:")
            (< cntr nostr)
            (eq
              (type
                (read
                  (substr
                    (cdr
                      (assoc
                        1
                        (entget (cdr (assoc -1 (nth (1+ cntr) txtent_lst))))
                      ) ;_ end of assoc
                    ) ;_ end allof cdr
                    1
                    (1-
                      (strlen 
                        (cdr
                          (assoc
                            1
                            (entget (cdr (assoc -1 (nth (1+ cntr) txtent_lst))))
                          ) ;_ end of assoc
                        ) ;_ end allof cdr
                      )
                    )
                  )
                ) ;_ end of read
              ) ;_ end of type
              'INT
            ) ;_ end of eq
          ) ;_ end of and
           (SETQ txstr
                  (STRCAT
                    txstr
                    " "
                    (cdr (assoc
                           1
                           (entget
                             (cdr (assoc -1 (nth (1+ cntr) txtent_lst)))
                           ) ;_ end of entget
                         ) ;_ end of assoc
                    ) ;_ end of cdr
                  ) ;_ end of STRCAT
           ) ;_ end of SETQ
        ) ;_ end of if
        (if (eq txstr "PAGE")
          (SETQ txstr "PAGE:")
        ) ;_ end of if
        (if
          (and
            (eq txstr "PAGE:")
            (< cntr nostr)
            (eq
              (type
                (read
                  (cdr
                    (assoc
                      1
                      (entget (cdr (assoc -1 (nth (1+ cntr) txtent_lst)))
                      ) ;_ end of entget
                    ) ;_ end of assoc
                  ) ;_ end of cdr
                ) ;_ end of read
              ) ;_ end of type
              'INT
            ) ;_ end of eq
          ) ;_ end of and
           (SETQ txstr
                  (STRCAT
                    txstr
                    " "
                    (cdr (assoc
                           1
                           (entget
                             (cdr (assoc -1 (nth (1+ cntr) txtent_lst)))
                           ) ;_ end of entget
                         ) ;_ end of assoc
                    ) ;_ end of cdr
                  ) ;_ end of STRCAT
           ) ;_ end of SETQ
        ) ;_ end of if
        (if (wcmatch txstr "#### ## ## ####")
          (SETQ txstr (STRCAT "PIN: " txstr))
        ) ;_ end of if
        (if (and
              prev_txstr
              (or (wcmatch prev_txstr "DEED BOOK: #*")
                  (wcmatch prev_txstr "PAGE: #*")
              ) ;_ end of or
            ) ;_ end of and
          NIL
          (PROGN
            (setq newtxtdef
                   (list
                     (cons 0 "TEXT")
                     (cons 1 txstr)
                     (cons 10 txtpt)
                     (cons 11 txtpt)
                     (cons 40 txtht)
                     (cons 50 txrot)
                     (cons 51 txtobl)
                     (assoc 71 (entget ent))
                     (cons 72 assoc_72)
                     (cons 73 assoc_73)
                   ) ;_ end of list
            ) ;_ end of setq
;;;	    (princ "\n")
;;;	    (princ newtxtdef)
;;;	    (princ "\n")
;;;	    (princ)
            (entmake newtxtdef)
;;;	(setq newtxtss (ssadd (entlast) newtxtss))
            (SETQ
              txtpt
               (POLAR txtpt
                      (+ (* PI 1.5)
                         txrot
                      ) ;_ end of +
                      (* txtht 1.5)
               ) ;_ end of POLAR
            ) ;_ end of SETQ
          ) ;_ end of PROGN
        ) ;_ end of if
        (setq cntr (1+ cntr))
        (setq prev_txstr txstr)
      )                                 ;while
;;;      (command ".erase" txtent "")
      (setq cntr 0)
      (setq txtent_lst nil)
      (setq my_nselp T)
    ) ;_ end of while
    (princ "\nSelect ATTRIB or TEXT: ")
    (setq txtent_lst nil)
    (setq txtent (ssadd))
  ) ;_ end of while
  (IF old_reattrosmode
    (SETVAR "OSMODE" old_reattrosmode)
  ) ;_ end of IF
  (getstyle "")
  (c:rslayr)
)                                       ;defun
;|«Visual LISP© Format Options»
(72 2 40 2 T "end of " 60 9 0 0 0 nil T nil T)
;*** DO NOT add text below the comment! ***|;

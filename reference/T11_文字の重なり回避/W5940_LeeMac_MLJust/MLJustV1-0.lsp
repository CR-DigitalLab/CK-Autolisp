;;--------------------=={ Multiline Justification }==-------------------;;
;;                                                                      ;;
;;  This program enables the user to change the justification of a      ;;
;;  selection of multilines, without changing their position.           ;;
;;                                                                      ;;
;;  This is analogous to the Express Tools' 'TJUST' command, however    ;;
;;  targeting mlines instead of text.                                   ;;
;;                                                                      ;;
;;  On issuing the command syntax 'MLJUST' at the AutoCAD command-line, ;;
;;  the user is first prompted to specify the new mline justification,  ;;
;;  with the choice of Top, Zero, or Bottom, per the options offered by ;;
;;  the standard 'MLINE' command.                                       ;;
;;                                                                      ;;
;;  The user may then select multiple mlines to be modified, with the   ;;
;;  program changing the justification of each selected multiline to    ;;
;;  that specified by the user, without changing the visual position    ;;
;;  of the multiline in the drawing.                                    ;;
;;                                                                      ;;
;;  The program will perform successfully under all UCS & View          ;;
;;  settings, and is compatible with multilines drawn in any UCS        ;;
;;  construction plane, using any multiline style, and with any         ;;
;;  multiline scale.                                                    ;;
;;----------------------------------------------------------------------;;
;;  Author:  Lee Mac, Copyright © 2018  -  www.lee-mac.com              ;;
;;----------------------------------------------------------------------;;
;;  Version 1.0    -    2018-10-17                                      ;;
;;                                                                      ;;
;;  - First release.                                                    ;;
;;----------------------------------------------------------------------;;

(defun c:mljust ( / *error* an1 an2 dic enx idx itm jus mlj ocs off rtn sel stl sty )

    (defun *error* ( msg )
        (mljust:endundo (mljust:acdoc))
        (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
            (princ (strcat "\nError: " msg))
        )
        (princ)
    )

    (initget "Top Zero Bottom")
    (setq jus (vl-position (cond ((getkword "\nSpecify new justification [Top/Zero/Bottom] <Zero>: ")) ("Zero")) '("Top" "Zero" "Bottom")))
    
    (if (setq sel (ssget "_:L" (list '(0 . "MLINE") '(-4 . "<>") (cons 70 jus))))
        (progn
            (if (setq dic (cdr (assoc -1 (dictsearch (namedobjdict) "acad_mlinestyle"))))
                (while (setq sty (dictnext dic (not sty)))
                    (setq off (mapcar 'cdr (vl-remove-if-not '(lambda ( x ) (= 49 (car x))) sty))
                          stl (cons (list (cdr (assoc 2 sty)) (apply 'max off) (apply 'min off)) stl)
                    )
                )
            )
            (mljust:startundo (mljust:acdoc))
            (repeat (setq idx (sslength sel))
                (setq rtn nil
                      idx (1- idx)
                      enx (entget (ssname sel idx))
                      mlj (cdr (assoc 070 enx))
                      ocs (cdr (assoc 210 enx))
                      off (cdr (assoc (cdr (assoc 2 enx)) stl))
                      off (* (cdr (assoc 040 enx))
                          (cond
                              (   (= 0 jus) (if (= 1 mlj)    (car  off)  (- (car  off) (cadr off))))
                              (   (= 1 jus) (if (= 0 mlj) (- (car  off)) (- (cadr off))))
                              (   (= 2 jus) (if (= 1 mlj)    (cadr off)  (- (cadr off) (car  off))))
                          )
                    )
                )
                (while (setq itm (car enx))
                    (if (= 11 (car itm))
                        (setq an1 (angle '(0 0) (trans (cdr (assoc 13 enx)) 0 ocs t))
                              an2 (angle '(0 0) (trans (cdr (assoc 12 enx)) 0 ocs t))
                              rtn (cons (cons 11 (trans (polar (trans (cdr itm) 0 ocs) an1 (/ off (sin (- an1 an2)))) ocs 0)) rtn)
                        )
                        (setq rtn (cons itm rtn))
                    )
                    (setq enx (cdr enx))
                )
                (entmod (reverse rtn))
                (vla-put-justification (vlax-ename->vla-object (cdr (assoc -1 rtn))) jus)
            )
            (mljust:endundo (mljust:acdoc))
        )
    )
    (princ)
)

;;----------------------------------------------------------------------;;

(defun mljust:startundo ( doc )
    (mljust:endundo doc)
    (vla-startundomark doc)
)

;;----------------------------------------------------------------------;;

(defun mljust:endundo ( doc )
    (while (= 8 (logand 8 (getvar 'undoctl)))
        (vla-endundomark doc)
    )
)

;;----------------------------------------------------------------------;;

(defun mljust:acdoc nil
    (eval (list 'defun 'mljust:acdoc 'nil (vla-get-activedocument (vlax-get-acad-object))))
    (mljust:acdoc)
)

;;----------------------------------------------------------------------;;

(vl-load-com)
(princ
    (strcat
        "\n:: MLJust.lsp | Version 1.0 | \\U+00A9 Lee Mac "
        ((lambda ( y ) (if (= y (menucmd "m=$(edtime,0,yyyy)")) y (strcat y "-" (menucmd "m=$(edtime,0,yyyy)")))) "2018")
        " www.lee-mac.com ::"
        "\n:: Type \"mljust\" to Invoke ::"
    )
)
(princ)

;;----------------------------------------------------------------------;;
;;                             End of File                              ;;
;;----------------------------------------------------------------------;;
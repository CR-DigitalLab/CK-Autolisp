;;------------------------------=={ Mask }==----------------------------;;
;;                                                                      ;;
;;  This program allows the user to manipulate all available properties ;;
;;  of the background mask for a selection of Multiline Text (MText),   ;;
;;  Multileader (MLeader), and Dimension objects.                       ;;
;;                                                                      ;;
;;  Upon calling the program with the syntax 'bmask', the user is       ;;
;;  prompted to make a selection of MText, MLeaders and/or Dimensions   ;;
;;  for which to alter the background mask settings.                    ;;
;;                                                                      ;;
;;  Following a valid selection, the user is presented with a dialog    ;;
;;  interface, enabling the user to toggle the use of a background      ;;
;;  mask, change the mask offset (not applicable to dimensions), and    ;;
;;  change the mask colour for all objects in the selection             ;;
;;  simultaneously.                                                     ;;
;;                                                                      ;;
;;  The background mask for dimensions will be applied as a dimension   ;;
;;  style override unless the settings held by the dimension style      ;;
;;  associated with the dimension match those selected by the user.     ;;
;;                                                                      ;;
;;  The background mask offset is only applicable to MText & MLeader    ;;
;;  objects and will therefore have no effect on selected Dimensions.   ;;
;;                                                                      ;;
;;----------------------------------------------------------------------;;
;;  Author:  Lee Mac, Copyright © 2012  -  www.lee-mac.com              ;;
;;----------------------------------------------------------------------;;
;;  Version 1.0    -    2012-04-16                                      ;;
;;                                                                      ;;
;;  - First release.                                                    ;;
;;----------------------------------------------------------------------;;
;;  Version 1.1    -    2013-02-06                                      ;;
;;                                                                      ;;
;;  - Changed command syntax to 'bmask' since 'mask' is an existing     ;;
;;    command in AutoCAD Civil 3D.                                      ;;
;;----------------------------------------------------------------------;;
;;  Version 1.2    -    2016-05-22                                      ;;
;;                                                                      ;;
;;  - Program restructured to enable dialog bypass.                     ;;
;;  - Added ability to mask dimensions.                                 ;;
;;----------------------------------------------------------------------;;
;;  Version 1.3    -    2016-05-23                                      ;;
;;                                                                      ;;
;;  - Defined dedicated mask:selection function to facilitate the       ;;
;;    creation of custom programs which bypass the program dialog.      ;;
;;----------------------------------------------------------------------;;
;;  Version 1.4    -    2017-04-17                                      ;;
;;                                                                      ;;
;;  - Fixed a bug causing the program to crash when modifying the       ;;
;;    background mask of dimensions with dimension style overrides.     ;;
;;----------------------------------------------------------------------;;
;;  Version 1.5    -    2018-11-10                                      ;;
;;                                                                      ;;
;;  - Added code to account for a bug in AutoCAD in which multileader   ;;
;;    text spacing is altered after modifying the background mask.      ;;
;;----------------------------------------------------------------------;;

(defun c:bmask ( / *error* key sel tmp )
    
    (defun *error* ( msg )
        (if (< 0 dch)
            (setq dch (unload_dialog dch))
        )
        (if (= 'file (type des))
            (close des)
        )
        (if (and (= 'str (type dcl)) (findfile dcl))
            (vl-file-delete dcl)
        )
        (mask:endundo (mask:acdoc))
        (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
            (princ (strcat "\nError: " msg))
        )
        (princ)
    )

    (setq key "LMac\\mask")
    (if (and (setq sel (mask:selection "\nSelect mtext, mleaders or dimensions: "))
             (setq tmp (mask:settings (mask:getdefaults key)))
        )
        (progn
            (mask:setdefaults key tmp)
            (apply 'mask:main (cons sel tmp))
        )
    )
    (princ)
)

;;----------------------------------------------------------------------;;

(defun mask:getdefaults ( key / tmp )
    (if
        (not
            (and
                (setq tmp (getenv key))
                (= 'list (type (setq tmp (read tmp))))
                (= 4 (length tmp))
            )
        )
        (mask:setdefaults key '("0" 1.5 "0" ((62 . 1))))
        tmp
    )
)

;;----------------------------------------------------------------------;;

(defun mask:setdefaults ( key val )
    (if (apply 'and val)
        (setenv key (vl-prin1-to-string val))
    )
    val
)

;;----------------------------------------------------------------------;;

(defun mask:settings ( arg / col dcf dch dcl des dis fn1 fn2 fn3 img msk off rtn trn )
    (mapcar 'set '(msk off trn col) arg)
    (cond
        (   (not
                (and
                    (setq dcl (vl-filename-mktemp nil nil ".dcl"))
                    (setq des (open dcl "w"))
                    (progn
                        (foreach str
                           '(
                                "imgbox : image_button"
                                "{"
                                "    alignment = centered;"
                                "    height = 1.5;"
                                "    aspect_ratio = 1;"
                                "    fixed_width = true;"
                                "    fixed_height = true;"
                                "    color = 1;"
                                "}"
                                "mask : dialog"
                                "{"
                                "    label = \"Background Mask\";"
                                "    spacer;"
                                "    : toggle"
                                "    {"
                                "        label = \"Use Background Mask\";"
                                "        key = \"msk\";"
                                "    }"
                                "    spacer;"
                                "    : boxed_column"
                                "    {"
                                "        label = \"Mask Offset\";"
                                "        : row"
                                "        {"
                                "            alignment = centered;"
                                "            : edit_box"
                                "            {"
                                "                key = \"off\";"
                                "            }"
                                "            : button"
                                "            {"
                                "                label = \">>\";"
                                "                key = \"pik\";"
                                "                fixed_width = true;"
                                "            }"
                                "        }"
                                "        spacer;"
                                "    }"
                                "    spacer;"
                                "    : boxed_column"
                                "    {"
                                "        label = \"Fill Color\";"
                                "        : row"
                                "        {"
                                "            alignment = centered;"
                                "            fixed_width = true;"
                                "            : toggle"
                                "            {"
                                "                key = \"trn\";"
                                "                label = \"Transparent\";"
                                "            }"
                                "            : imgbox"
                                "            {"
                                "                key = \"col\";"
                                "            }"
                                "        }"
                                "        spacer;"
                                "    }"
                                "    spacer;"
                                "    ok_cancel;"
                                "}"
                            )
                            (write-line str des)
                        )
                        (setq des (close des))
                        (< 0 (setq dch (load_dialog dcl)))
                    )
                )
            )
            (prompt "\nUnable to write and/or load Mask dialog.")
        )
        (   (progn
                (while (not (member dcf '(0 1)))
                    (cond
                        (   (null (new_dialog "mask" dch))
                            (princ "\nMask dialog not defined.")
                            (setq dcf 0)
                        )
                        (   t
                            (setq img
                                (lambda ( key aci )
                                    (start_image key)
                                    (fill_image 0 0 (dimx_tile key) (dimy_tile key) aci)
                                    (end_image)
                                )
                            )
                            (   (setq fn1
                                    (lambda ( )
                                        (img "col"
                                            (cond
                                                (   (= "0" msk) -15)
                                                (   (= "1" trn)   0)
                                                (   (cdr (assoc 62 col)))
                                                (   -15   )
                                            )
                                        )
                                    )
                                )
                            )
                            (   (setq fn2
                                    (lambda ( val )
                                        (fn1) (mode_tile "col" (atoi val))
                                    )
                                )
                                (set_tile "trn" trn)
                            )
                            (   (setq fn3
                                    (lambda ( val )
                                        (setq val (- 1 (atoi val)))
                                        (foreach key  '("off" "pik" "trn" "col")
                                            (mode_tile key val)
                                        )
                                        (fn2 (if (= "0" msk) "1" trn))
                                    )
                                )
                                (set_tile "msk" msk)
                            )
                            (action_tile "trn" "(fn2 (setq trn $value))")
                            (action_tile "msk" "(fn3 (setq msk $value))")
                        
                            (set_tile    "off" (rtos off 2))
                            (action_tile "off"
                                (vl-prin1-to-string
                                   '(if
                                        (or
                                            (null (setq dis (distof $value)))
                                            (< 5.0 dis)
                                            (< dis 1.0)
                                        )
                                        (progn
                                            (alert "Please provide a value between 1 and 5.")
                                            (set_tile "off" (rtos off 2))
                                            (mode_tile "off" 2)
                                        )
                                        (set_tile "off" (rtos (setq off dis) 2))
                                    )
                                )
                            )

                            (action_tile "col"
                                (vl-prin1-to-string
                                   '(if (setq tmp (acad_truecolordlg (vl-some '(lambda ( x ) (assoc x col)) '(430 420 62)) nil))
                                        (img "col" (cdr (assoc 62 (setq col tmp))))
                                    )
                                )
                            )
                            (action_tile "pik" "(done_dialog 2)")
                         
                            (setq dcf (start_dialog))
                        )
                    )
                    (if
                        (and (= 2 dcf)
                            (progn
                                (while
                                    (not
                                        (or (null (setq dis (getdist (strcat "\nPick Mask Offset Factor <" (rtos off 2) ">: "))))
                                            (<= 1.0 dis 5.0)
                                        )
                                    )
                                    (princ "\nOffset must be between 1 and 5.")
                                )
                                dis
                            )
                        )
                        (setq off dis)
                    )
                )
                (zerop dcf)
            )
            (prompt "\n*Cancel*")
        )
        (   (setq rtn (list msk off trn col)))
    )
    (if (< 0 dch)
        (setq dch (unload_dialog dch))
    )
    (if (and dcl (findfile dcl))
        (vl-file-delete dcl)
    )
    rtn
)

;;----------------------------------------------------------------------;;

(defun mask:selection ( msg )
    (mask:ssget msg
       '("_:L" ((0 . "*DIMENSION,MTEXT,MULTILEADER")))
    )
)

;;----------------------------------------------------------------------;;

(defun mask:main ( sel msk off trn col )
    (mask:maskselection sel (= "1" msk) off (= "1" trn) col)
)

;;----------------------------------------------------------------------;;

(defun mask:maskselection ( sel msk off trn col / idx )
    (if (= 'pickset (type sel))
        (repeat (setq idx (sslength sel))
            (mask:maskentity (ssname sel (setq idx (1- idx))) msk off trn col)
        )
    )
)

;;----------------------------------------------------------------------;;

(defun mask:maskentity ( ent msk off trn col / enx typ )
    (setq enx (entget ent)
          typ (cdr (assoc 0 enx))
    )
    (cond
        (   (= "MTEXT" typ)
            (if msk
                (entmod
                    (append (vl-remove-if '(lambda ( x ) (member (car x) '(45 63 90 421 431 441))) enx)
                        (if trn
                           '((90 . 3) (63 . 256))
                            (cons '(90 . 1) (mapcar '(lambda ( x ) (cons (1+ (car x)) (cdr x))) col))
                        )
                        (list (cons 45 off) '(441 . 0))
                    )
                )
                (vla-put-backgroundfill (vlax-ename->vla-object (cdr (assoc -1 enx))) :vlax-false)
            )
        )
        (   (= "MULTILEADER" typ)
            (entmod
                (mask:substonce enx
                    (if msk
                        (list
                            (cons 091 (mask:color->mleadercolor (if trn '((62 . 256)) col)))
                            (cons 141 off)
                            (if trn '(291 . 1) '(291 . 0))
                           '(292 . 1)
                        )
                       '((292 . 0))
                    )
                )
            )
            (vla-put-textlinespacingfactor (vlax-ename->vla-object ent) (cdr (assoc 045 enx))) ;; AutoCAD bug
        )
        (   (wcmatch typ "*DIMENSION")
            (setq sty (mask:dimstylefill (cdr (assoc 3 enx)))
                  ovr (vl-remove-if '(lambda ( x ) (< 68 (cdar x) 71)) (mask:getdimxdata ent))
            )
            (cond
                (   (not msk)
                    (if (assoc 69 sty)
                        (mask:setdimxdata ent (append ovr '(((1070 . 70) (1070 . 0)) ((1070 . 69) (1070 . 0)))))
                        (mask:setdimxdata ent ovr)
                    )
                )
                (   trn
                    (if (= 1 (cdr (assoc 69 sty)))
                        (mask:setdimxdata ent ovr)
                        (mask:setdimxdata ent (append ovr '(((1070 . 69) (1070 . 1)))))
                    )
                )
                (   (and (= 2 (cdr (assoc 69 sty)))
                         (=   (cdr (assoc 62 col)) (cdr (assoc 70 sty)))
                    )
                    (mask:setdimxdata ent ovr)
                )
                (   (mask:setdimxdata ent (append ovr (list (list '(1070 . 70) (cons 1070 (cdr (assoc 62 col)))) '((1070 . 69) (1070 . 2))))))
            )
        )
    )
)

;;----------------------------------------------------------------------;;

(defun mask:dimstylefill ( sty / tmp )
    (if
        (and
            (setq sty (tblobjname "dimstyle" sty))
            (setq sty (entget sty))
            (setq tmp (assoc 69 sty))
        )
        (list tmp (assoc 70 (member tmp sty)))
    )
)

;;----------------------------------------------------------------------;;

(defun mask:getdimxdata ( dim / lst ovr )
    (setq lst (cddr (member '(1000 . "DSTYLE") (cdadr (assoc -3 (entget dim '("acad")))))))
    (while (and lst (not (equal '(1002 . "}") (car lst))))
        (setq ovr (cons (list (car lst) (cadr lst)) ovr)
              lst (cddr lst)
        )
    )
    (reverse ovr)
)

;;----------------------------------------------------------------------;;

(defun mask:setdimxdata ( dim ovr / lst tmp )
    (if ovr
        (setq ovr
           (append
               '(
                    (1000 . "DSTYLE")
                    (1002 . "{")
                )
                (apply 'append ovr)
               '(
                    (1002 . "}")
                )
            )
        )
    )
    (cond
        (   (not (setq lst (cdadr (assoc -3 (entget dim '("acad"))))))
            (regapp "acad")
            (entmod (append (entget dim) (list (list -3 (cons "acad" ovr)))))
        )
        (   (setq tmp (member '(1000 . "DSTYLE") lst))
            (entmod
                (append (entget dim)
                    (list
                        (list -3
                            (cons "acad"
                                (append
                                    (reverse (cdr (member '(1000 . "DSTYLE") (reverse lst))))
                                    ovr
                                    (cdr (member '(1002 . "}") tmp))
                                )
                            )
                        )
                    )
                )
            )
        )
        (   (entmod (append (entget dim) (list (list -3 (cons "acad" (append lst ovr)))))))
    )
)

;;----------------------------------------------------------------------;;

(defun mask:ssget ( msg arg / sel )
    (princ msg)
    (setvar 'nomutt 1)
    (setq sel (vl-catch-all-apply 'ssget arg))
    (setvar 'nomutt 0)
    (if (not (vl-catch-all-error-p sel)) sel)
)

;;----------------------------------------------------------------------;;

(defun mask:substonce ( enx lst )
    (mapcar
       '(lambda ( dxf / itm )
            (cond
                (   (setq itm (assoc (car dxf) lst))
                    (setq lst (vl-remove itm lst))
                    itm
                )
                (   dxf   )
            )
        )
        enx
    )
)

;;----------------------------------------------------------------------;;

(defun mask:color->mleadercolor ( c / x )
    (cond
        (   (setq x (cdr (assoc 420 c))) (+ -1040187392 x))
        (   (zerop (setq x (cdr (assoc 62 c)))) -1056964608)
        (   (= 256 x) -1073741824)
        (   (< 0 x 256) (+ -1023410176 x))
    )
)

;;----------------------------------------------------------------------;;

(defun mask:startundo ( doc )
    (mask:endundo doc)
    (vla-startundomark doc)
)

;;----------------------------------------------------------------------;;

(defun mask:endundo ( doc )
    (while (= 8 (logand 8 (getvar 'undoctl)))
        (vla-endundomark doc)
    )
)

;;----------------------------------------------------------------------;;

(defun mask:acdoc nil
    (eval (list 'defun 'mask:acdoc 'nil (vla-get-activedocument (vlax-get-acad-object))))
    (mask:acdoc)
)

;;----------------------------------------------------------------------;;

(vl-load-com)
(princ
    (strcat
        "\n:: Mask.lsp | Version 1.5 | \\U+00A9 Lee Mac "
        ((lambda ( y ) (if (= y (menucmd "m=$(edtime,0,yyyy)")) y (strcat y "-" (menucmd "m=$(edtime,0,yyyy)")))) "2012")
        " www.lee-mac.com ::"
        "\n:: Type \"bmask\" to Invoke ::"
    )
)
(princ)

;;----------------------------------------------------------------------;;
;;                             End of File                              ;;
;;----------------------------------------------------------------------;;
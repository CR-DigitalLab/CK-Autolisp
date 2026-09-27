;;;Place "masking" objects under text, mtext and dimensions.
;;;Adjust margin spacing via dialog interface.
;;;
;;;Added exclusion of text with thickness = 1.0
;;;(to always exclude certain text from processing give it a thickness of 1.0)
;;;
;;;	AUTHOR: HENRY C. FRANCIS
;;;		425 N. ASHE ST.
;;;		SOUTHERN PINES, NC 28387
;;;		All rights reserved without prejudice.
;;;
;;;	Copyright:      1-26-96
;;;	Edited:		12-28-12
;;;
;;;	removed creation of 3Dfaces - now makes HDBOX inserts only.
;;;	requires image 1x1.bmp and block HDBOX.
;;;
;;;(DEFUN PMASK_ERROR ()
;;;  (princ "\nParaMASK encountered and error!\nERROR: ")
;;;  (princ msg)
;;;  (princ)
;;;  (UNLOAD_DIALOG ddhtext_dlg#)
;;;  (IF oldpmask_regenmode
;;;    (SETVAR "REGENMODE" oldpmask_regenmode)
;;;  )
;;;  (IF oldpmask_expert
;;;    (SETVAR "EXPERT" oldpmask_expert)
;;;  )
;;;  (IF oldpmask_osmode
;;;    (SETVAR "OSMODE" oldpmask_osmode)
;;;  )
;;;  (IF oldpmask_error
;;;    (SETQ *error* oldpmask_error)
;;;    (SETQ *error* NIL)
;;;  )
;;;  (PRINC)
;;;)
(DEFUN c:pmask (/      ss     sslen  count  oldss  delold ntz    tname
                tent   tp1    tang   tbang  tp2    bxp1   bxp2   bxp3
                bxp4
               )
  (vl-load-com)
  (PROGN
;;;    (SETQ oldpmask_error *error*
;;;	  *error* pmask_error
;;;    )
    (SETQ oldpmask_pickstyle (GETVAR "pickstyle"))
    (SETQ oldpmask_tilemode (GETVAR "tilemode"))
    (SETQ oldpmask_regenmode (GETVAR "regenmode"))
    (SETQ oldpmask_osmode (GETVAR "osmode"))
    (SETQ oldpmask_expert (GETVAR "expert"))
    (SETQ prehdtext_ss (SSGET "P"))
    (PROGN
      (pmskgvpno)
      (SETQ oldpmask_cvport viewno)
    ) ;_ end of PROGN
    (SETVAR "PICKSTYLE" 0)
    (SETVAR "OSMODE" 0)
    (SETVAR "REGENMODE" 0)
    (SETVAR "EXPERT" 5)
    (SETQ ddhtext_dlg# (LOAD_DIALOG "ddhtext"))
    (SETQ newdlg_hdtext
           (NEW_DIALOG
             "ddhtext"
             ddhtext_dlg#
             (IF defact_ddhtext
               defact_ddhtext
               ""
             ) ;_ end of IF
             (IF ddhtext_loc
               ddhtext_loc
               '(-1 -1)
             ) ;_ end of IF
           ) ;_ end of NEW_DIALOG
    ) ;_ end of SETQ
    (IF space_opt
      (SET_TILE "space_opt" space_opt)
      (SET_TILE "space_opt" "model_space")
    ) ;_ end of IF
    (IF select_opt
      (SET_TILE "select_opt" select_opt)
      (SET_TILE "select_opt" "select_all")
    ) ;_ end of IF
    (IF custom_margin
      (PROGN
        (SET_TILE "custom_margin" custom_margin)
        (IF (EQ custom_margin "0")
          (PROGN
            (MODE_TILE "margin_width" 1)
            (MODE_TILE "x_text" 1)
            (SET_TILE "margin_width" "0.25")
          ) ;_ end of PROGN
          (PROGN
            (MODE_TILE "margin_width" 0)
            (MODE_TILE "x_text" 0)
            (IF margin_width
              (SET_TILE "margin_width" margin_width)
              (SET_TILE "margin_width" "0.2")
            ) ;_ end of IF
          ) ;_ end of PROGN
        ) ;_ end of IF
      ) ;_ end of PROGN
      (PROGN
        (MODE_TILE "margin_width" 1)
        (MODE_TILE "x_text" 1)
        (SET_TILE "margin_width" "0.25")
      ) ;_ end of PROGN
    ) ;_ end of IF
    (IF apply_text
      (SET_TILE "apply_text" apply_text)
      (SET_TILE "apply_text" "1")
    ) ;_ end of IF
    (IF apply_mtext
      (SET_TILE "apply_mtext" apply_mtext)
      (SET_TILE "apply_mtext" "1")
    ) ;_ end of IF
    (IF apply_dims
      (SET_TILE "apply_dims" apply_dims)
      (SET_TILE "apply_dims" "1")
    ) ;_ end of IF
    (IF existhd_opt
      (SET_TILE "existhd_opt" existhd_opt)
      (PROGN
        (SETQ existhd_opt "existhd_erase")
        (SET_TILE "existhd_opt" existhd_opt)
      ) ;_ end of PROGN
    ) ;_ end of IF
    (IF hd_opt_type      
      (SET_TILE "hd_opt_type" hd_opt_type)
      (PROGN
        (SETQ hd_opt_type "hd_type_image")
        (SET_TILE "hd_opt_type" hd_opt_type)
      ) ;_ end of PROGN
    ) ;_ end of IF
    (ACTION_TILE "space_opt" "(setq space_opt $value)")
    (ACTION_TILE
      "paper_space"
      "(setq space_opt (get_tile\"space_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "model_space"
      "(setq space_opt (get_tile\"space_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "select_opt" "(setq select_opt $value)")
    (ACTION_TILE
      "custom_margin"
      "(setq custom_margin $value)(set_margin)"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "margin_width" "(setq margin_width $value)")
    (ACTION_TILE
      "apply_text"
      "(setq apply_text (get_tile\"apply_text\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "apply_mtext"
      "(setq apply_mtext (get_tile\"apply_mtext\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "apply_dims"
      "(setq apply_dims (get_tile\"apply_dims\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "existhd_opt" "(setq existhd_opt $value)")
    (ACTION_TILE "hd_opt_type" "(setq hd_opt_type $value)")
    (ACTION_TILE
      "existhd_erase"
      "(setq existhd_opt (get_tile\"existhd_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "existhd_keep"
      "(setq existhd_opt (get_tile\"existhd_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "accept"
      "(hdtext_values)(setq ddhtext_loc(done_dialog 1))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "cancel" "(setq ddhtext_loc(done_dialog 0))")
;;;DON'T ENABLE HELP BUTTON UNTIL THERE IS A HELP FILE "paramask_help.htm"
;;;    (ACTION_TILE "help" "(if browser_help nil (load \"browser_help\"))(browser_help \"paramask_help.htm\")")
    (SETQ exit_no (START_DIALOG))
    (IF (EQ exit_no 1)
      (makepmasks)
      (PROGN
        (PRINC "\nFunction cancelled, nothing to do! ")
      ) ;_ end of progn
    ) ;_ end of IF
    (UNLOAD_DIALOG ddhtext_dlg#)
    (SETVAR "REGENMODE" oldpmask_regenmode)
    (IF (AND oldpmask_cvport paravpset)
      (PROGN
        (IF debug_paramask
          (PROGN
            (PRINC "\noldpmask_cvport = ")
            (PRINC oldpmask_cvport)
            (PRINC)
          )
        )
        (paravpset oldpmask_cvport)
      )
    ) ;_ end of IF
    (SETVAR "EXPERT" oldpmask_expert)
    (SETVAR "OSMODE" oldpmask_osmode)
    (SETVAR "PICKSTYLE" oldpmask_pickstyle)
;;;    (IF oldpmask_error
;;;      (SETQ *ERROR* oldpmask_error)
;;;    )
    (PRINC)
  ) ;_ end of PROGN
) ;_ end of DEFUN
(DEFUN c:paramask () (c:pmask))
;;;*********************************************************************
(DEFUN pmask (/      ss     sslen  count  oldss  delold ntz    tname
                tent   tp1    tang   tbang  tp2    bxp1   bxp2   bxp3
                bxp4
               )
  (vl-load-com)
  (PROGN
    (SETQ oldpmask_pickstyle (GETVAR "pickstyle"))
    (SETQ oldpmask_tilemode (GETVAR "tilemode"))
    (SETQ oldpmask_regenmode (GETVAR "regenmode"))
    (SETQ oldpmask_osmode (GETVAR "osmode"))
    (SETQ oldpmask_expert (GETVAR "expert"))
    (SETQ prehdtext_ss (SSGET "P"))
    (PROGN
      (pmskgvpno)
      (SETQ oldpmask_cvport viewno)
    ) ;_ end of PROGN
    (SETVAR "PICKSTYLE" 0)
    (SETVAR "OSMODE" 0)
    (SETVAR "REGENMODE" 0)
    (SETVAR "EXPERT" 5)
    (SETQ space_opt "model_space")
    (SETQ select_opt "select_all")
    (SETQ margin_width "0.25")
    (SETQ apply_text "1")
    (SETQ apply_mtext "1")
    (SETQ apply_dims "1")
    (SETQ existhd_opt "existhd_erase")
    (SETQ hd_opt_type "hd_type_image")
    (makepmasks)
    (SETVAR "REGENMODE" oldpmask_regenmode)
    (IF (AND oldpmask_cvport paravpset)
      (PROGN
        (IF debug_paramask
          (PROGN
            (PRINC "\noldpmask_cvport = ")
            (PRINC oldpmask_cvport)
            (PRINC)
          )
        )
        (paravpset oldpmask_cvport)
      )
    ) ;_ end of IF
    (SETVAR "EXPERT" oldpmask_expert)
    (SETVAR "OSMODE" oldpmask_osmode)
    (SETVAR "PICKSTYLE" oldpmask_pickstyle)
    (PRINC)
  ) ;_ end of PROGN
) ;_ end of DEFUN
;;;*********************************************************************
(DEFUN set_margin ()
  (MODE_TILE "margin_width" (ABS (1- (READ custom_margin))))
  (MODE_TILE "x_text" (ABS (1- (READ custom_margin))))
  (IF (EQ custom_margin "0")
    (PROGN
      (SETQ margin_width "0.2")
      (SET_TILE "margin_width" margin_width)
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun
;;;*********************************************************************
(DEFUN hdtext_values ()
  (SETQ space_opt (GET_TILE "space_opt"))
  (SETQ select_opt (GET_TILE "select_opt"))
  (SETQ custom_margin (GET_TILE "custom_margin"))
  (SETQ margin_width (GET_TILE "margin_width"))
  (SETQ apply_text (GET_TILE "apply_text"))
  (SETQ apply_mtext (GET_TILE "apply_mtext"))
  (SETQ apply_dims (GET_TILE "apply_dims"))
  (SETQ existhd_opt (GET_TILE "existhd_opt"))
  (SETQ hd_opt_type (GET_TILE "hd_opt_type"))
) ;_ end of defun
;;;*********************************************************************
(DEFUN makepmasks ()
  (SETVAR "cmdecho" 0)
  (IF (AND
        margin_width
        (NOT (EQ margin_width "0.2"))
        (OR
          (EQ (TYPE (READ margin_width)) 'REAL)
          (EQ (TYPE (READ margin_width)) 'INT)
        ) ;_ end of OR
      ) ;_ end of and
    (SETQ sp_size (READ margin_width))
    (SETQ sp_size 0.2)
  ) ;_ end of IF
  (IF (AND
        margin_width
        (NOT (EQ margin_width "0.2"))
        (OR
          (EQ (TYPE (READ margin_width)) 'REAL)
          (EQ (TYPE (READ margin_width)) 'INT)
        ) ;_ end of OR
      ) ;_ end of and
    (SETQ hd_size (READ margin_width))
    (SETQ hd_size 0.2)
  ) ;_ end of IF
  (IF hd_wcstr
    NIL
    (SETQ hd_wcstr "")
  ) ;_ end of IF
  (IF (/= "BYLAYER" (GETVAR "cecolor"))
    (SETVAR "CECOLOR" "BYLAYER")
  ) ;_ end of IF
  (SETQ cr    (LIST "w"   "o"   "r"   "y"   "d"   "u"   "e"   "t"
                    "h"   "f"   "a"   "g"   "n"   "c"   "i"   "p"
                    "r"   "s"   "j"   "l"   "v"   "b"
                   ) ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
        wrd1  (STRCAT                   ;Copyright
                (STRCASE (NTH 13 cr))
                (NTH 1 cr)
                (NTH 15 cr)
                (NTH 3 cr)
                (NTH 2 cr)
                (NTH 14 cr)
                (NTH 11 cr)
                (NTH 8 cr)
                (NTH 7 cr)
              ) ;_ end of strcat
        wrd2  " "
        wrd3  (STRCAT (ITOA 1996) "-" (ITOA 2015))
        wrd4  ", "
        wrd4b (STRCAT                   ;by
                (NTH 21 cr)
                (NTH 3 cr)
              ) ;_ end of strcat
        wrd5  (STRCAT                   ;Paraglide
                (STRCASE (NTH 15 cr))
                (NTH 10 cr)
                (NTH 2 cr)
                (NTH 10 cr)
                (NTH 11 cr)
                (NTH 19 cr)
                (NTH 14 cr)
                (NTH 4 cr)
                (NTH 6 cr)
              ) ;_ end of strcat
        wrd6  (STRCASE (NTH 13 cr))     ;C
        wrd6a ". "
        wrd7  (STRCAT                   ;Francis
                (STRCASE (NTH 9 cr))
                (NTH 2 cr)
                (NTH 10 cr)
                (NTH 12 cr)
                (NTH 13 cr)
                (NTH 14 cr)
                (NTH 17 cr)
              ) ;_ end of strcat
        wrd8  (STRCAT                   ;without
                (NTH 0 cr)
                (NTH 14 cr)
                (NTH 7 cr)
                (NTH 8 cr)
                (NTH 1 cr)
                (NTH 5 cr)
                (NTH 7 cr)
              ) ;_ end of strcat
        wrd9  (STRCAT                   ;prejudice
                (NTH 15 cr)
                (NTH 2 cr)
                (NTH 6 cr)
                (NTH 18 cr)
                (NTH 5 cr)
                (NTH 4 cr)
                (NTH 14 cr)
                (NTH 13 cr)
                (NTH 6 cr)
              ) ;_ end of strcat
        wrd10 (STRCAT                   ;All
                (STRCASE (NTH 10 cr))
                (NTH 19 cr)
                (NTH 19 cr)
              ) ;_ end of strcat
        wrd11 (STRCAT                   ;rights
                (NTH 2 cr)
                (NTH 14 cr)
                (NTH 11 cr)
                (NTH 8 cr)
                (NTH 7 cr)
                (NTH 17 cr)
              ) ;_ end of strcat
        wrd12 (STRCAT                   ;reserved
                (NTH 2 cr)
                (NTH 6 cr)
                (NTH 17 cr)
                (NTH 6 cr)
                (NTH 2 cr)
                (NTH 20 cr)
                (NTH 6 cr)
                (NTH 4 cr)
              ) ;_ end of strcat
  ) ;_ end of setq
  (IF
    (NOT (EQ (STRCAT (NTH 3 cr) (NTH 6 cr) (NTH 17 cr)) "yes"))
     (PRINC "Copyright has been violated! ")
     (PROGN
       (SETQ curvpn (GETVAR "cvport"))
       (IF space_opt
         (IF (EQ space_opt "model_space")
           (SETQ mp_space "Model")
           (SETQ mp_space "Paper")
         ) ;_ end of if
         (SETQ space_opt "model_space"
               mp_space  "Model"
         ) ;_ end of SETQ
       ) ;_ end of IF
       (IF (EQ select_opt "select_all")
         (SETQ one_all "All")
         (SETQ one_all "Select")
       ) ;_ end of IF
       (COND
         ((EQ mp_space "Model")
          (IF (EQ one_all "Select")
            (PROGN
              (SETQ this_select
                     (ukword 1
                             "Previous New"
                             "Selection Type [Previous/New]?"
                             this_select
                     ) ;_ end of ukword
              ) ;_ end of SETQ
              (IF (EQ this_select "Previous")
                (IF prehdtext_ss
                  (SETQ pmask_ss prehdtext_ss)
                  (SETQ pmask_ss (SSGET "P"))
                ) ;_ end of IF
                (SETQ pmask_ss (SSGET
                                 (APPEND
                                   (LIST
                                     (CONS -4 "<NOT")
                                     (CONS 67 1)
                                     (CONS -4 "NOT>")
                                   ) ;_ end of LIST
                                   (COND
                                     ((AND (EQ APPLY_TEXT "1")
                                           (EQ APPLY_MTEXT "1")
                                           (EQ APPLY_DIMS "1")
                                      ) ;_ end of AND
                                      (LIST (CONS -4 "<OR")
                                            (CONS 0 "TEXT")
                                            (CONS 0 "MTEXT")
                                            (CONS 0 "DIMENSION")
                                            (CONS -4 "OR>")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      ) ;_ end of LIST
                                     )
                                     ((AND (EQ APPLY_TEXT "1")
                                           (EQ APPLY_DIMS "1")
                                      ) ;_ end of AND
                                      (LIST (CONS -4 "<OR")
                                            (CONS 0 "TEXT")
                                            (CONS 0 "DIMENSION")
                                            (CONS -4 "OR>")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      ) ;_ end of LIST
                                     )
                                     ((AND (EQ APPLY_MTEXT "1")
                                           (EQ APPLY_DIMS "1")
                                      ) ;_ end of AND
                                      (LIST (CONS -4 "<OR")
                                            (CONS 0 "MTEXT")
                                            (CONS 0 "DIMENSION")
                                            (CONS -4 "OR>")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      ) ;_ end of LIST
                                     )
                                     ((AND (EQ APPLY_TEXT "1")
                                           (EQ APPLY_MTEXT "1")
                                      ) ;_ end of AND
                                      (LIST (CONS -4 "<OR")
                                            (CONS 0 "TEXT")
                                            (CONS 0 "MTEXT")
                                            (CONS -4 "OR>")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      ) ;_ end of LIST
                                     )
                                     ((EQ APPLY_TEXT "1")
                                      (LIST (CONS 0 "TEXT")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      )
                                     )
                                     ((EQ APPLY_MTEXT "1")
                                      (LIST (CONS 0 "MTEXT")
                                            (CONS -4 "<NOT")
                                            (CONS 8 "*NHID*")
                                            (CONS -4 "NOT>")
                                      )
                                     )
                                     (T
                                      (LIST (CONS 0 "NOTHING-AT-ALL"))
                                     )
                                   ) ;_ end of COND
                                 ) ;_ end of APPEND
                               ) ;_ end of ssget
                      dim_ss_p pmask_ss
                      as_67    0
                ) ;_ end of setq
              ) ;_ end of IF
            ) ;_ end of PROGN
            (SETQ pmask_ss (SSGET
                             "x"
                             (APPEND
                               (LIST
                                 (CONS -4 "<NOT")
                                 (CONS 67 1)
                                 (CONS -4 "NOT>")
                               ) ;_ end of LIST
                               (COND
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_MTEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "MTEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_MTEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "MTEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_MTEXT "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "MTEXT")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((EQ APPLY_TEXT "1")
                                  (LIST (CONS 0 "TEXT")
                                  )
                                 )
                                 ((EQ APPLY_MTEXT "1")
                                  (LIST (CONS 0 "MTEXT")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  )
                                 )
                               ) ;_ end of COND
                             ) ;_ end of APPEND
                           ) ;_ end of ssget
                  as_67    0
            ) ;_ end of setq
          ) ;_ end of if
          (IF (EQ (GETVAR "tilemode") 0)
            (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;            (COMMAND "_.mspace")
          ) ;_ end of if
         )
         ((EQ mp_space "Paper")
          (IF (EQ one_all "Select")
            (SETQ as_67    1
                  pmask_ss (SSGET
                             (APPEND
                               (LIST
                                 (CONS 410 (GETVAR "CTAB"))
                                 (CONS 67 1)
                               ) ;_ end of LIST
                               (COND
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_MTEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "MTEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_MTEXT "1")
                                       (EQ APPLY_DIMS "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "MTEXT")
                                        (CONS 0 "DIMENSION")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((AND (EQ APPLY_TEXT "1")
                                       (EQ APPLY_MTEXT "1")
                                  ) ;_ end of AND
                                  (LIST (CONS -4 "<OR")
                                        (CONS 0 "TEXT")
                                        (CONS 0 "MTEXT")
                                        (CONS -4 "OR>")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  ) ;_ end of LIST
                                 )
                                 ((EQ APPLY_TEXT "1")
                                  (LIST (CONS 0 "TEXT")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  )
                                 )
                                 ((EQ APPLY_MTEXT "1")
                                  (LIST (CONS 0 "MTEXT")
                                        (CONS -4 "<NOT")
                                        (CONS 8 "*NHID*")
                                        (CONS -4 "NOT>")
                                  )
                                 )
                                 (T
                                  (LIST (CONS 0 "NOTHING-AT-ALL"))
                                 )
                               ) ;_ end of COND
                             ) ;_ end of APPEND
                           ) ;_ end of ssget
                  dim_ss_p pmask_ss
            ) ;_ end of setq
            (SETQ pmask_ss (SSGET "x"
                                  (APPEND
                                    (LIST
                                      (CONS 410 (GETVAR "CTAB"))
                                      (CONS 67 1)
                                    ) ;_ end of LIST
                                    (COND
                                      ((AND (EQ APPLY_TEXT "1")
                                            (EQ APPLY_MTEXT "1")
                                            (EQ APPLY_DIMS "1")
                                       ) ;_ end of AND
                                       (LIST (CONS -4 "<OR")
                                             (CONS 0 "TEXT")
                                             (CONS 0 "MTEXT")
                                             (CONS 0 "DIMENSION")
                                             (CONS -4 "OR>")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       ) ;_ end of LIST
                                      )
                                      ((AND (EQ APPLY_TEXT "1")
                                            (EQ APPLY_DIMS "1")
                                       ) ;_ end of AND
                                       (LIST (CONS -4 "<OR")
                                             (CONS 0 "TEXT")
                                             (CONS 0 "DIMENSION")
                                             (CONS -4 "OR>")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       ) ;_ end of LIST
                                      )
                                      ((AND (EQ APPLY_MTEXT "1")
                                            (EQ APPLY_DIMS "1")
                                       ) ;_ end of AND
                                       (LIST (CONS -4 "<OR")
                                             (CONS 0 "MTEXT")
                                             (CONS 0 "DIMENSION")
                                             (CONS -4 "OR>")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       ) ;_ end of LIST
                                      )
                                      ((AND (EQ APPLY_TEXT "1")
                                            (EQ APPLY_MTEXT "1")
                                       ) ;_ end of AND
                                       (LIST (CONS -4 "<OR")
                                             (CONS 0 "TEXT")
                                             (CONS 0 "MTEXT")
                                             (CONS -4 "OR>")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       ) ;_ end of LIST
                                      )
                                      ((EQ APPLY_TEXT "1")
                                       (LIST (CONS 0 "TEXT")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       )
                                      )
                                      ((EQ APPLY_MTEXT "1")
                                       (LIST (CONS 0 "MTEXT")
                                             (CONS -4 "<NOT")
                                             (CONS 8 "*NHID*")
                                             (CONS -4 "NOT>")
                                       )
                                      )
                                      (T
                                       (LIST (CONS 0 "NOTHING-AT-ALL"))
                                      )
                                    ) ;_ end of COND
                                  ) ;_ end of APPEND
                           ) ;_ end of ssget
                  as_67    1
            ) ;_ end of setq
          ) ;_ end of if
          (IF (NOT (EQ (SETQ cvport_no (GETVAR "cvport")) 1))
            (IF (EQ (GETVAR "tilemode") 1)
              (PROGN
                (SETVAR "tilemode" 0)
                (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;                (COMMAND "_.pspace")
              ) ;_ end of PROGN
              (PROGN
                (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;                (COMMAND "_.pspace")
              )
            ) ;_ end of IF
          ) ;_ end of IF
         )
       ) ;_ end of cond
;;;       (IF (TBLOBJNAME "block" "hdbox")
;;;         (PROGN
       (COND
         ((EQ hd_opt_type "hd_type_image")
          (IF (TBLSEARCH "BLOCK" "hdbox")
            NIL
           (IF (FINDFILE "hdbox.dwg")
             (PROGN
               (COMMAND "-insert" "hdbox=" "y")
               (COMMAND)
             )
           )))
         ((EQ hd_opt_type "hd_type_wipeout")
           (IF (FINDFILE "hdboxw.dwg")
             (PROGN
               (COMMAND "-insert" "hdbox=hdboxw.dwg" "y")
               (COMMAND)
             )
           ))
         ((EQ hd_opt_type "hd_type_3dface")
           (IF (FINDFILE "hdbox3.dwg")
             (PROGN
               (COMMAND "-insert" "hdbox=hdbox3.dwg" "y")
               (COMMAND)
             )
           ))
         ((EQ hd_opt_type "hd_type_solid")
           (IF (FINDFILE "hdboxs.dwg")
             (PROGN
               (COMMAND "-insert" "hdbox=hdboxs.dwg" "y")
               (COMMAND)
             )
           ))
       )
;;;         ) ;_ end of progn
;;;         (PROGN
;;;           (COMMAND "-insert" "hdbox")
;;;           (COMMAND)
;;;         ) ;_ end of progn
;;;       ) ;_ end of IF
       (IF (OR (AND
                 (COND
                   ((EQ hd_opt_type "hd_type_image")(SETQ dwgfound (FINDFILE "hdbox.dwg")))
                   ((EQ hd_opt_type "hd_type_wipeout")(SETQ dwgfound (FINDFILE "hdboxw.dwg")))
                   ((EQ hd_opt_type "hd_type_3dface")(SETQ dwgfound (FINDFILE "hdbox3.dwg")))
                   ((EQ hd_opt_type "hd_type_solid")(SETQ dwgfound (FINDFILE "hdboxs.dwg")))
                 )
                 (SETQ bmpfound (FINDFILE "1x1.bmp"))
                 (EQ mp_space "Paper")
               ) ;_ end of and
               (EQ mp_space "Model")
           ) ;_ end of or
         (PROGN
           (IF (AND
                 (EQUAL (GETVAR "UCSORG") (LIST 0.0 0.0 0.0) 0.0001)
                 (EQUAL (GETVAR "UCSXDIR") (LIST 1.0 0.0 0.0) 0.0001)
                 (EQUAL (GETVAR "UCSYDIR") (LIST 0.0 1.0 0.0) 0.0001)
               ) ;_ end of AND
             (PROGN
               (SETQ ddht_ucsname NIL)
             ) ;_ end of PROGN
             (PROGN
               (pmskgvpno)
               (IF viewno
                 (PROGN
                   (SETQ ddht_vpno viewno)
                 ) ;_ end of PROGN
               ) ;_ end of IF
               (IF (EQUAL (GETVAR "UCSNAME") "")
                 (SETQ ddht_ucsname "DDHT-TEMP-UCS")
                 (SETQ ddht_ucsname (GETVAR "UCSNAME"))
               ) ;_ end of IF
               (COMMAND ".UCS" "SAVE" ddht_ucsname)
               (COMMAND ".UCS" "WORLD")
             ) ;_ end of PROGN
           ) ;_ end of IF
           (c:demask)
           (IF (AND (OR (EQ mp_space "Model") (EQ mp_space "Paper"))
                    pmask_ss
                    (EQ apply_text "1")
               ) ;_ end of AND
             (PROGN
               (SETQ sslen (SSLENGTH pmask_ss)
                     count 0
                     ntz   0
                     colr  "1"
               ) ;_ end of setq
;;;               (WHILE
;;;                 (NOT (EQ count sslen))
;;;                  (IF
;;;                    (EQ "TEXT"
;;;                        (CDR (ASSOC 0 (ENTGET (SSNAME pmask_ss count))))
;;;                    ) ;_ end of EQ
;;;                     (PROGN
;;;                       (IF (= (CDR (ASSOC 71 tent)) 2)
;;;                         (SETQ ntz (- 0 (ABS ntz)))
;;;                         (SETQ ntz (ABS ntz))
;;;                       ) ;_ end of if
;;;                       (SETQ tname  (SSNAME pmask_ss count)
;;;                             10a    (ASSOC 10 (ENTGET tname))
;;;                             11a    (ASSOC 11 (ENTGET tname))
;;;                             10b    (LIST (CAR 10a) (CADR 10a) (CADDR 10a) 0.0)
;;;                                        ;(CADDDR 10a)
;;;                             11b    (LIST (CAR 11a) (CADR 11a) (CADDR 11a) 0.0)
;;;                                        ;(CADDDR 11a)
;;;                             tname  (ENTGET tname)
;;;                             nohide (ENTGET
;;;                                      (TBLOBJNAME
;;;                                        "layer"
;;;                                        (CDR (ASSOC 8 tname))
;;;                                      ) ;_ end of TBLOBJNAME
;;;                                    ) ;_ end of ENTGET
;;;                             tname  (SUBST 10b 10a tname)
;;;                             tname  (SUBST 11b 11a tname)
;;;                       ) ;_ end of setq
;;;                       (IF (AND (ASSOC 12 tname) (ASSOC 13 tname))
;;;                         (SETQ 12a   (ASSOC 12 tname)
;;;                               13a   (ASSOC 13 tname)
;;;                               12b   (LIST (CAR 12a) (CADR 12a) (CADDR 12a) 0.0)
;;;                                        ;(CADDDR 12a)
;;;                               13b   (LIST (CAR 13a) (CADR 13a) (CADDR 13a) 0.0)
;;;                                        ;(CADDDR 13a)
;;;                               tname (SUBST 12b 12a tname)
;;;                               tname (SUBST 13b 13a tname)
;;;                         ) ;_ end of setq
;;;                       ) ;_ end of if
;;;                       (IF (OR (> (CDR (ASSOC 70 nohide)) 0)
;;;                               (< (CDR (ASSOC 62 nohide)) 0)
;;;                           ) ;_ end of OR
;;;                         NIL
;;;                         (ENTMOD tname)
;;;                       ) ;_ end of IF
;;;                       (SETQ count (1+ count))
;;;                     ) ;_ end of PROGN
;;;                     (SETQ count (1+ count))
;;;                  ) ;_ end of IF
;;;               ) ;_ end of while
               (SETQ count 0)
               (WHILE (NOT (EQ sslen count))
                 (IF
                   (EQ "TEXT"
                       (CDR (ASSOC 0 (ENTGET (SSNAME pmask_ss count))))
                   ) ;_ end of EQ
                    (PROGN
                      (SETQ tname  (SSNAME pmask_ss count)
                            tent   (ENTGET tname)
                            tenthk (ASSOC 39 tent)
                            tval   (CDR (ASSOC 1 tent))
                            tbox   (TEXTBOX tent)
                            nohide (ENTGET
                                     (TBLOBJNAME "layer" (CDR (ASSOC 8 tent)))
                                   ) ;_ end of ENTGET
                      ) ;_ end of SETQ
                      (SETQ tbox (LIST
                                   (LIST (CAAR tbox) 0.0 0.0)
                                   (LIST (CAADR tbox)
                                         (CDR (ASSOC 40 tent))
                                         0.0
                                   ) ;_ end of LIST
                                 ) ;_ end of LIST
                            txht (CDR (ASSOC 40 tent))
                            tdis (- (CAR (NTH 1 tbox)) (CAR (NTH 0 tbox)))
                            tp1  (POLAR
                                   (POLAR (CDR (ASSOC 10 tent))
                                          (CDR (ASSOC 50 tent))
                                          (CAR (NTH 0 tbox))
                                   ) ;_ end of POLAR
                                   (+ (CDR (ASSOC 50 tent)) (* PI 0.5))
                                   (CADR (NTH 0 tbox))
                                 ) ;_ end of POLAR
                      ) ;_ end of setq
                      (IF (AND
                            (NOT (WCMATCH tval (STRCAT (CHR 34) "*")))
                            (NOT (WCMATCH tval (STRCAT (CHR 40) "*")))
                            (NOT (WCMATCH tval (STRCAT (CHR 41) "*")))
                            (NOT (WCMATCH tval (STRCAT (CHR 46) "*")))
                          ) ;_ end of AND
                        (IF (AND (OR (EQUAL (TYPE (READ tval)) 'INT)
                                     (EQUAL (TYPE (READ tval)) 'REAL)
                                 ) ;_ end of OR
                                 (NOT (WCMATCH tval "*@*"))
                            ) ;_ end of AND
                          (SETQ txtsp_fact (/ 1.0 sp_size))
                                        ; TXTSP_FACT was hard coded at 2.10
                          (SETQ txtsp_fact (/ 1.0 0.2))
                        ) ;_ end of IF
                        (SETQ txtsp_fact (/ 1.0 0.2))
                      ) ;_ end of IF
                      (COND
                        ((AND
                           (NOT (WCMATCH tval (STRCAT (CHR 34) "*")))
                           (NOT (WCMATCH tval (STRCAT (CHR 40) "*")))
                           (NOT (WCMATCH tval (STRCAT (CHR 41) "*")))
                           (NOT (WCMATCH tval (STRCAT (CHR 46) "*")))
                         ) ;_ end of AND
                         (IF (AND
                               (OR (EQUAL (TYPE (READ tval)) 'INT)
                                   (EQUAL (TYPE (READ tval)) 'REAL)
                               ) ;_ end of OR
                               (NOT (WCMATCH tval "*@*"))
                             ) ;_ end of AND
                           (SETQ hd_sp sp_size)
                           (SETQ hd_sp hd_size)
                         ) ;_ end of IF
                        )
                        (T
                         (IF sp_size
                           (SETQ hd_sp sp_size)
                           (IF hd_size
                             (SETQ hd_sp hd_size)
                             (SETQ hd_sp 0.2)
                           ) ;_ end of IF
                         ) ;_ end of IF
                        )
                      ) ;_ end of COND
                      (IF (< (NTH 1 (NTH 1 tbox)) txht)
                        (SETQ txht (NTH 1 (NTH 1 tbox)))
                      ) ;_ end of IF
                      (SETQ tang  (CDR (ASSOC 50 tent))
                            tlayr (CDR (ASSOC 8 tent))
                            tp2   (POLAR
                                    (POLAR tp1 tang tdis)
                                    (+ tang (* PI 0.5))
                                    (- (CADR (NTH 1 tbox)) (CADR (NTH 0 tbox)))
                                  ) ;_ end of POLAR
                      ) ;_ end of setq
                      (SETQ bxp1 (POLAR
                                   (POLAR tp1
                                        ;Set 3DFace points for normal text
                                          (- tang (* PI 0.5))
                                          (* txht hd_sp)
                                   ) ;_ end of POLAR
                                   (- tang PI)
                                   (* txht hd_sp)
                                 ) ;_ end of polar
                            bxp2 (POLAR bxp1
                                        (+ tang (* PI 0.50))
                                        (+ (* 2.00 txht hd_sp)
                                           (CADR (NTH 1 tbox))
                                           (- (CADR (NTH 0 tbox)))
                                        ) ;_ end of +
                                 ) ;_ end of polar
                            bxp4 (POLAR
                                   (POLAR tp2
                                          (+ tang (* PI 0.5))
                                          (* txht hd_sp)
                                   ) ;_ end of polar
                                   tang
                                   (* txht hd_sp)
                                 ) ;_ end of POLAR
                            bxp3 (POLAR bxp4
                                        (- tang (* PI 0.50))
                                        (+ (* 2.00 txht hd_sp)
                                           (CADR (NTH 1 tbox))
                                           (- (CADR (NTH 0 tbox)))
                                        ) ;_ end of +
                                 ) ;_ end of polar
                      ) ;_ end of setq
                      (IF (= (CDR (ASSOC 71 tent)) 2)
                                        ;if its backward (mirrored in x)
                        (SETQ ntz (- 0 (ABS ntz))) ;reverse the Z
                        (SETQ ntz (ABS ntz))
                      ) ;_ end of if
                      (SETQ bxp1 (TRANS (LIST (CAR bxp1) (CADR bxp1) ntz) 0 1)
                            bxp2 (TRANS (LIST (CAR bxp2) (CADR bxp2) ntz) 0 1)
                            bxp3 (TRANS (LIST (CAR bxp3) (CADR bxp3) ntz) 0 1)
                            bxp4 (TRANS (LIST (CAR bxp4) (CADR bxp4) ntz) 0 1)
                      ) ;_ end of setq
                      (IF (>= 11 (STRLEN tlayr))
                        (SETQ modf (SUBSTR tlayr 8 4))
                        (SETQ modf "NOTE")
                      ) ;_ end of if
                      (IF (AND (>= (STRLEN tlayr) 6)
                               (WCMATCH (STRCASE tlayr) "*VI##*")
                          ) ;_ end of AND
                        (SETQ hsvno (SUBSTR tlayr 3 4))
                        (SETQ hsvno "PMSK")
                      ) ;_ end of if
                      (SETQ clayr tlayr)
                      (IF clnmstd
                        NIL
                        (LOAD "mklayr" "\nFile MKLAYR.LSP not loaded! ")
                      ) ;_ end of IF
                      (IF (AND clnmstd (clnmstd))
                        (SETQ tlayr (STRCAT tlayr "-MASK"))
                        (SETQ tlayr (STRCAT "G-"
                                            hsvno
                                            "7TEXT-MASK"
                                            (IF (EQ mp_space "Paper")
                                              ""
                                              (IF (> (STRLEN tlayr) 11)
                                                (SUBSTR tlayr 12)
                                                ""
                                              ) ;_ end of if
                                            ) ;_ end of IF
                                            ""
                                    ) ;_ end of strcat
                        ) ;_ end of setq
                      ) ;_ end of IF
                      (IF (OR (> (CDR (ASSOC 70 nohide)) 0)
                              (< (CDR (ASSOC 62 nohide)) 0)
                          ) ;_ end of OR
                        NIL
                        (IF (AND (> tdis 0)
                                 (OR (NOT tenthk) (/= (CDR tenthk) 1.0))
                            ) ;_ end of AND
                          (PROGN
                            (SETQ box_angle   (ANGLE bxp1 bxp3)
                                  box_x_scale (DISTANCE bxp1 bxp3)
                                  box_y_scale (DISTANCE bxp1 bxp2)
                            ) ;_ end of SETQ
                            (IF T       ;(EQ mp_space "Paper")
                              (PROGN
                                (SETQ hdboxlst
                                       (LIST
                                         (CONS 0 "INSERT")
                                         (CONS 2 "HDBOX")
                                         (CONS 10 bxp1)
                                         (CONS 8 tlayr)
                                         (CONS 41 box_x_scale)
                                         (CONS 42 box_y_scale)
                                         (CONS 43 1.0)
                                         (CONS 50 box_angle)
                                         (CONS 67 as_67)
;;;                                         (CONS 70 1)
;;;                                         (CONS 71 1)
                                       ) ;_ end of LIST
                                ) ;_ end of SETQ
                                (ENTMAKE hdboxlst)
                              ) ;_ end of PROGN
                              (PROGN
                                (SETQ 3dflst
                                       (LIST
                                         (CONS 0 "3DFACE")
                                         (CONS 8 tlayr)
                                         (CONS 10 bxp1)
                                         (CONS 11 bxp2)
                                         (CONS 12 bxp4)
                                         (CONS 13 bxp3)
                                         (CONS 62 255)
                                         (CONS 67 as_67)
                                         (CONS 70 15)
                                       ) ;_ end of list
                                ) ;_ end of setq
                                (ENTMAKE 3dflst)
                              ) ;_ end of PROGN
                            ) ;_ end of IF
                          ) ;_ end of progn
                        ) ;_ end of if
                      ) ;_ end of IF
                      (SETQ count (1+ count))
                    ) ;_ end of PROGN
                    (SETQ count (1+ count))
                 ) ;_ end of IF
               ) ;_ end of while

               (IF (OR (EQ (SUBSTR (GETVAR "clayer") 3 4) "NPLT")
                       (EQ (SUBSTR (GETVAR "clayer") 8 4) "NPLT")
                   ) ;_ end of or
                 (COMMAND ".layer" "m" "TEMP" "")
               ) ;_ end of if
             ) ;_ end of progn
           ) ;_ end of if



;;;Setq debugpts T to enable placement of text at the points "bxp#"
;;;	   (IF debugpts
;;;	     (IF pttxt
;;;	       NIL
;;;	       (LOAD "pttxt" "\nFile PTXT.LSP not loaded!")
;;;	     ) ;_ end of IF
;;;	   ) ;_ end of if
;;;	   (IF (AND debugpts pttxt)
;;;	     (PROGN (IF	fthk
;;;		      nil
;;;		      (SETQ fthk 5.0)
;;;		    ) ;_ end of IF
;;;		    (pttxt "HDBOX_" "bxp" 1 5)
;;;	     ) ;_ end of PROGN
;;;	   ) ;_ end of if
;;;Use the above to graphically identify and debug the defined points.

           (IF
             (EQ apply_dims "1")
              (SETQ hide_dims "Yes")
              (SETQ hide_dims "No")
           ) ;_ end of IF
           (IF
             (EQ apply_mtext "1")
              (SETQ hide_mtext "Yes")
              (SETQ hide_mtext "No")
           ) ;_ end of IF
           (IF (OR (EQ hide_dims "Yes") (EQ hide_mtext "Yes"))
             (maskdims)
           ) ;_ end of IF
           (COND
             ((EQ mp_space "Model")
;;;	      (IF (EQ one_all "Select")
;;;		(SETQ hdbox_ss
;;;		       (SSGET "x"
;;;			      '((-4 . "<AND")
;;;				(0 . "INSERT")
;;;				(2 . "HDBOX")
;;;				(8 . "~*AREA*")
;;;				(8 . "~*@@##P-[HM][IA][DS][EK]*")
;;;				(8 . "~*@@##P-[HM][IA][DS][EK]*")
;;;				(-4 . "<NOT")
;;;				(67 . 1)
;;;				(-4 . "NOT>")
;;;				(-4 . "AND>")
;;;			       )
;;;		       ) ;_ end of ssget
;;;		      as_67 0
;;;		) ;_ end of setq
              (SETQ as_67 0
                    hdbox_ss
                     (SSGET "x"
                            '((-4 . "<OR")
                                (-4 . "<AND")
                                  (0 . "INSERT")
                                  (2 . "HDBOX")
                                  (8 . "~*AREA*")
                                  (8 . "~*@@##P[HM][IA][DS][EK]*")
                                  (8 . "~*@@##P-[HM][IA][DS][EK]*")
;;;                                  (-4 . "<NOT")
;;;    	                               (67 . 1)
;;;                                  (-4 . "NOT>")
                                (-4 . "AND>")
                                (-4 . "<AND")
                                  (0 . "IMAGE")
                                  (8 . "*[HM][IA][DS][EK]*")
                                (-4 . "AND>")
                              (-4 . "OR>")
                             )
                     ) ;_ end of ssget
              ) ;_ end of setq
;;;	      ) ;_ end of if
;;;	      (IF (EQ one_all "Select")
;;;		(SETQ txdim_ss (SSGET
;;;				 '((-4 . "<AND")
;;;				   (-4 . "<OR")
;;;				   (0 . "TEXT")
;;;				   (0 . "DIMENSION")
;;;				   (0 . "MTEXT")
;;;				   (-4 . "OR>")
;;;				   (-4 . "<NOT")
;;;				   (67 . 1)
;;;				   (-4 . "NOT>")
;;;				   (-4 . "AND>")
;;;				  )
;;;			       ) ;_ end of ssget
;;;		      as_67    0
;;;		) ;_ end of setq
;;;		(SETQ txdim_ss (SSGET "x"
;;;				      '((-4 . "<AND")
;;;					(-4 . "<OR")
;;;					(0 . "TEXT")
;;;					(0 . "DIMENSION")
;;;					(0 . "MTEXT")
;;;					(-4 . "OR>")
;;;					(-4 . "<NOT")
;;;					(67 . 1)
;;;					(-4 . "NOT>")
;;;					(-4 . "AND>")
;;;				       )
;;;			       ) ;_ end of ssget
;;;		      as_67    0
;;;		) ;_ end of setq
;;;	      ) ;_ end of if
              (IF (EQ (GETVAR "tilemode") 0)
                (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;                (COMMAND "_.mspace")
              ) ;_ end of if
             )
             ((EQ mp_space "Paper")
              (SETQ hdbox_ss
                     (SSGET "x"
                            (LIST
                              '(-4 . "<OR")
                                '(-4 . "<AND")
                                  '(0 . "INSERT")
                                  '(2 . "HDBOX")
                                  '(8 . "~*AREA*")
                                  '(8 . "~*@@##P[HM][IA][DS][EK]*")
                                  '(8 . "~*@@##P-[HM][IA][DS][EK]*")
                                  (CONS 410 (GETVAR "CTAB"))
                                  '(67 . 1)
                                '(-4 . "AND>")
                                '(-4 . "<AND")
                                  '(0 . "IMAGE")
                                  '(8 . "*[HM][IA][DS][EK]*")
                                '(-4 . "AND>")
                              '(-4 . "OR>")
                            ) ;_ end of LIST
                     ) ;_ end of ssget
                    as_67 1
              ) ;_ end of setq
              (IF (EQ one_all "Select")
                (SETQ txdim_ss (SSGET "P")
;;;				 (LIST
;;;				   '(-4 . "<AND")
;;;				   '(-4 . "<OR")
;;;				   '(0 . "TEXT")
;;;				   '(0 . "DIMENSION")
;;;				   '(0 . "MTEXT")
;;;				   '(-4 . "OR>")
;;;				   (CONS 410 (GETVAR "CTAB"))
;;;				   '(67 . 1)
;;;				   '(-4 . "AND>")
;;;				  )
;;;			       ) ;_ end of ssget
                      as_67    1
                ) ;_ end of setq
                (SETQ txdim_ss (SSGET "x"
                                      (LIST
                                        '(-4 . "<AND")
                                        '(-4 . "<OR")
                                        '(0 . "TEXT")
                                        '(0 . "DIMENSION")
                                        '(0 . "MULTILEADER")
                                        '(0 . "MTEXT")
                                        '(-4 . "OR>")
                                        (CONS 410 (GETVAR "CTAB"))
                                        '(67 . 1)
                                        '(-4 . "AND>")
                                      ) ;_ end of LIST
                               ) ;_ end of ssget
                      as_67    1
                ) ;_ end of setq
              ) ;_ end of if
              (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;              (COMMAND "_.pspace")
             )
           ) ;_ end of cond
           (IF (AND hdbox_ss txdim_ss)  ;(EQ mp_space "Paper")
             (PROGN
               (C:HDUPD)
             ) ;_ end of PROGN
             (COND
               ((EQ mp_space "Model") (C:HDUPD))
               ((AND (NOT hdbox_ss) (NOT txdim_ss))
                (PRINC
                  "\nNo text, mtext, dimensions or masking objects found! "
                ) ;_ end of PRINC
                (PRINC)
               )
               ((NOT hdbox_ss)
                (PRINC "\nNo masking objects found! ")
                (PRINC)
               )
               ((NOT txdim_ss)
                (PRINC "\nNo text, mtext or dimensions found! ")
                (PRINC)
               )
             ) ;_ end of COND
           ) ;_ end of IF
           (IF (AND ddht_vpno ddht_ucsname)
             (PROGN
               (IF debug_paramask
                 (PROGN
                   (PRINC "\nddht_vpno = ")
                   (PRINC ddht_vpno)
                   (PRINC)
                 )
               )
               (paravpset ddht_vpno)
               (COMMAND ".UCS" "RESTORE" ddht_ucsname)
               (SETQ ddht_ucsname NIL)
             ) ;_ end of progn
           ) ;_ end of IF
           (IF (EQ oldpmask_tilemode 1)
             (SETVAR "tilemode" oldpmask_tilemode)
             (IF (NOT (EQ (GETVAR "cvport") 1))
               (PROGN
                 (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;                 (COMMAND "_.pspace")
               )
             ) ;_ end of IF
           ) ;_ end of if
           (PRINC wrd1)
           (PRINC wrd2)
           (PRINC wrd3)
           (PRINC wrd2)
           (PRINC wrd4b)
           (PRINC wrd2)
           (PRINC wrd5)
;;;	   (PRINC wrd2)
;;;	   (PRINC wrd6)
;;;	   (PRINC wrd6a)
;;;	   (PRINC wrd7)
           (PRINC wrd4)
           (PRINC wrd10)
           (PRINC wrd2)
           (PRINC wrd11)
           (PRINC wrd2)
           (PRINC wrd12)
           (PRINC wrd2)
           (PRINC wrd8)
           (PRINC wrd2)
           (PRINC wrd9)
           (PRINC wrd6a)
           (IF prehdtext_ss
             (COMMAND ".select" prehdtext_ss "")
           ) ;_ end of IF
         ) ;_ end of progn
         (PROGN
           (IF (NOT dwgfound)
             (PROGN (PRINC "\nRequired file HDBOX.DWG not found! ")
                    (PRINC)
             ) ;_ end of PROGN
           ) ;_ end of IF
           (IF (NOT bmpfound)
             (PROGN (PRINC "\nRequired file 1X1.BMP not found! ")
                    (PRINC)
             ) ;_ end of PROGN
           ) ;_ end of IF
           (IF (AND dwgfound bmpfound)
             (SETQ bmpfound NIL
                   dwgfound NIL
             ) ;_ end of SETQ
             (PROGN (PRINC "\nFunction cancelled! ") (PRINC))
           ) ;_ end of IF
         ) ;_ end of PROGN
       ) ;_ end of if
     ) ;_ end of progn
  ) ;_ end of if
  (IF (EQ (BOOLE 1 (GETVAR "CMDACTIVE") 4) 4)
    (COMMAND "'RESUME")
  ) ;_ end of IF
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN pmskgvpno (/ curvno cvpss cvpent cvpename cvplay lnccnt)
  (IF ukword
    NIL
    (LOAD "ukword" "\nFile UKWORD.LSP not loaded! ")
  ) ;_ end of IF
;;;  (IF (OR (NOT LAYOUTLIST) (IF LAYOUTLIST (=(LENGTH(LAYOUTLIST))1)))
  (PROGN
    (SETQ viewno nil)
    (SETQ curvno (GETVAR "cvport"))
    (IF (AND (> curvno 1) (EQ (GETVAR "tilemode") 0))
      (PROGN
        (SETQ as_67 0)
        (SETQ cvpss
               (SSGET "X"
                      (LIST (CONS 410 (GETVAR "CTAB")) (CONS 69 curvno))
               ) ;_ end of SSGET
        ) ;_ end of SETQ
        (SETQ cvpent (ENTGET (SSNAME cvpss 0)))
        (SETQ cvpename (CDR (ASSOC -1 cvpent)))
        (SETQ cvplay (CDR (ASSOC 8 cvpent)))
        (IF (WCMATCH (STRCASE cvplay) "??VI##*")
          (PROGN
            (SETQ lnccnt 1)
            (WHILE
              (NOT
                (WCMATCH (SETQ vp_str (STRCASE (SUBSTR cvplay lnccnt)))
                         "VI##*"
                ) ;_ end of WCMATCH
              ) ;_ end of NOT
               (SETQ lnccnt (1+ lnccnt))
            ) ;_ end of while
            (SETQ prod (SUBSTR vp_str 1 4))
            (SETQ viewno (ATOI (SUBSTR vp_str 3 2)))
          ) ;_ end of progn
          (PROGN
            (IF uint NIL (LOAD "uint" "\nFile UINT.LSP not loaded! "))
            (SETQ viewno (uint 1 "" "View number? " viewno))
            (IF (< viewno 10)
              (SETQ prod (STRCAT "VI0" (ITOA viewno)))
              (SETQ prod (STRCAT "VI" (ITOA viewno)))
            ) ;_ end of if
            (IF (WCMATCH (STRCASE (SUBSTR (GETVAR "dwgname") 1 1))
                         "[ACEFGILMOPQSTZ]"
                ) ;_ end of WCMATCH
              (SETQ vplmjr (STRCASE (SUBSTR (GETVAR "dwgname") 1 1)))
              (SETQ vplmjr "G")
            ) ;_ end of if
            (SETQ fixvpl (ukword 1
                                 "Yes No"
                                 (STRCAT "Change viewport layer to "
                                         vplmjr
                                         "-"
                                         prod
                                         "7NPLT"
                                        ) ;_ end of STRCAT
 ;_ end of STRCAT
                                 "Yes"
                         ) ;_ end of ukword
            ) ;_ end of SETQ
            (IF (EQ fixvpl "Yes")
              (PROGN (COMMAND "-layer"
                              "m"
                              (STRCAT vplmjr "-" prod "7nplt")
                              ""
                     ) ;_ end of COMMAND
                     (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;                     (COMMAND ".pspace")
                     (COMMAND ".chprop"
                              cvpename
                              ""
                              "la"
                              (STRCAT vplmjr "-" prod "7nplt")
                              ""
                     ) ;_ end of COMMAND
                     (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;                     (COMMAND ".mspace")
              ) ;_ end of progn
            ) ;_ end of if
          ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of progn
      (PROGN (SETQ as_67 1)
;;;      (if (eq(getvar"tilemode")0)
;;;        (princ "\nYou are in Paper space.  Please put viewport annotation in model space.")
;;;        (princ "\nYou are in Model space, Paper space is not active")
;;;      )
      ) ;_ end of progn
    )                                   ;if
                                        ;  (if prod nil
                                        ;    (setq prod "PLAN")
                                        ;  )
  ) ;_ end of PROGN
;;;    (PROGN (PRINC "\nMore than one layout present. Viewport layer checking aborted.")(PRINC))
;;;  ) ;_ end of if
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN maskdims (/)
  (SETVAR "cmdecho" 0)
  (IF debug_pmask
    (PROGN
      (PRINC "\n\t\tENTERING MASKDIMS! ")
      (PRINC)
    ) ;_ end of PROGN
  ) ;_ end of IF
  (IF
    (COND
      ((EQ one_all "Select") (SETQ dimss dim_ss_p))
      ((AND (EQ apply_dims "1") (EQ apply_mtext "1"))
       (IF (EQ mp_space "Model")
         (SETQ dimss (SSGET "x"
                            '((-4 . "<OR")
                              (0 . "DIMENSION")
                              (0 . "MTEXT")
                              (-4 . "OR>")
                              (-4 . "<NOT")
                              (8 . "*NHID*")
                              (-4 . "NOT>")
                             )
                     ) ;_ end of SSGET
         ) ;_ end of SETQ
         (SETQ dimss (SSGET "x"
                            (LIST
                              (CONS 410 (GETVAR "CTAB"))
                              '(-4 . "<OR")
                              '(0 . "DIMENSION")
                              '(0 . "MTEXT")
                              '(-4 . "OR>")
                              '(-4 . "<NOT")
                              '(8 . "*NHID*")
                              '(-4 . "NOT>")
                            ) ;_ end of LIST
                     ) ;_ end of SSGET
         ) ;_ end of SETQ
       ) ;_ end of IF
      )
      ((EQ apply_dims "1")
       (IF (EQ mp_space "Model")
         (SETQ dimss (SSGET "x" '((0 . "DIMENSION")
                                  (-4 . "<NOT")
                                  (8 . "*NHID*")
                                  (-4 . "NOT>")
                                 )
                     )
         )
         (SETQ dimss
                (SSGET
                  "x"
                  (LIST (CONS 410 (GETVAR "CTAB"))
                        (CONS 0 "DIMENSION")
                        (CONS -4 "<NOT")
                        (CONS 8 "*NHID*")
                        (CONS -4 "NOT>")
                  )
                ) ;_ end of SSGET
         ) ;_ end of SETQ
       ) ;_ end of IF
      )
      ((EQ apply_mtext "1")
       (IF (EQ mp_space "Model")
         (SETQ dimss (SSGET "x" '((0 . "MTEXT")
                                  (-4 . "<NOT")
                                  (8 . "*NHID*")
                                  (-4 . "NOT>")
                                 )
                     )
         )
         (SETQ dimss
                (SSGET "x"
                       (LIST (CONS 410 (GETVAR "CTAB"))
                             (CONS 0 "MTEXT")
                             (CONS -4 "<NOT")
                             (CONS 8 "*NHID*")
                             (CONS -4 "NOT>")
                       )
                ) ;_ end of SSGET
         ) ;_ end of SETQ
       ) ;_ end of IF
      )
    ) ;_ end of COND
     (PROGN
       (SETQ dss_len (SSLENGTH dimss))
       (SETQ dss_indx 0)
       (SETQ ntz  0
             llt  "-"
             colr "1"
       ) ;_ end of setq
       (WHILE (< dss_indx dss_len)
         (IF (OR (EQ "MTEXT"
                     (CDR (ASSOC 0 (ENTGET (SSNAME dimss dss_indx))))
                 ) ;_ end of EQ
                 (EQ "DIMENSION"
                     (CDR (ASSOC 0 (ENTGET (SSNAME dimss dss_indx))))
                 ) ;_ end of EQ
             ) ;_ end of OR
           (PROGN
             (SETQ dim_ent (ENTGET (SSNAME dimss dss_indx)))
             (IF
               (OR (AND (EQ mp_space "Paper")
                        (EQ (CDR (ASSOC 67 dim_ent)) 0)
                   ) ;_ end of AND
                   (AND (EQ mp_space "Model")
                        (EQ (CDR (ASSOC 67 dim_ent)) 1)
                   ) ;_ end of AND
               ) ;_ end of or
                nil
                (PROGN
                  (SETQ dblk_name (CDR (ASSOC 2 dim_ent)))
                  (IF dblk_name
                    (PROGN
                      (SETQ dblk_ent (TBLSEARCH "block" dblk_name))
                      (SETQ dim1_ename (CDR (ASSOC -2 dblk_ent)))
                      (SETQ dim1_ent (ENTGET dim1_ename))
                      (WHILE (AND (ENTNEXT (CDR (ASSOC -1 dim1_ent)))(/= (CDR (ASSOC 0 dim1_ent)) "MTEXT")(/= (CDR (ASSOC 0 dim1_ent)) "SEQEND"))
                        (SETQ dim1_ent (ENTGET (ENTNEXT (CDR (ASSOC -1 dim1_ent)))))
                      )
                      (SETQ dim1_ename (CDR (ASSOC -1 dim1_ent)))
                    ) ;_ end of PROGN
                    (PROGN
                      (SETQ dim1_ename (CDR (ASSOC -1 dim_ent)))
                    ) ;_ end of PROGN
                  ) ;_ end of IF
                  (SETQ dlayr (CDR (ASSOC 8 dim_ent)))
                  (IF
                    (AND
                      (>= (STRLEN dlayr) 6)
                      (WCMATCH (STRCASE (CDR (ASSOC 8 dim_ent))) "*VI##*")
                    ) ;_ end of AND
                     (SETQ hsvno (SUBSTR dlayr 3 4))
                     (SETQ hsvno "PMSK")
                  ) ;_ end of if
                  (IF (EQ (CDR (ASSOC 0 (ENTGET dim1_ename))) "MTEXT")
                    (SETQ maskobjtype "MTXT")
                    (SETQ maskobjtype "DIMS")
                  ) ;_ end of IF
                  (SETQ clayr dlayr)
                  (IF clnmstd
                    NIL
                    (LOAD "mklayr" "\nFile MKLAYR.LSP not loaded! ")
                  ) ;_ end of IF
                  (IF (AND clnmstd (clnmstd))
                    (SETQ dlayr (STRCAT dlayr "-MASK"))
                    (SETQ dlayr
                           (STRCAT (IF mjrg
                                     mjrg
                                     "G"
                                   ) ;_ end of if
                                   "-"
                                   hsvno
                                   "1"
                                   maskobjtype
                                   "-MASK"
                           ) ;_ end of strcat
                    ) ;_ end of setq
                  ) ;_ end of IF
                  (IF dim1_ename
                    (PROGN
                      (SETQ dim1_ent (ENTGET dim1_ename))
                      (hddimmtext dim1_ent)
                    )
		  ) ;_ end of while
                ) ;_ end of PROGN
             ) ;_ end of IF
             (SETQ dss_indx (1+ dss_indx))
           ) ;_ end of PROGN
           (SETQ dss_indx (1+ dss_indx))
         ) ;_ end of IF
       ) ;_ end of while
       (SETQ HDLADEF (TBLOBJNAME "LAYER" "G-NPLT7HDBX"))
       (IF HDLADEF
         (PROGN
           (SETQ HDLADEF (ENTGET HDLADEF))
           (IF (EQ (CDR (ASSOC 62 HDLADEF)) 250)
             NIL
             (PROGN
               (SETQ HDLADEF
                      (SUBST (CONS 62 250) (ASSOC 62 HDLADEF) HDLADEF)
               ) ;_ end of SETQ
               (ENTMOD HDLADEF)
             ) ;_ end of PROGN
           ) ;_ end of IF
         ) ;_ end of PROGN
       ) ;_ end of IF
     ) ;_ end of progn
  ) ;_ end of if
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN hddimmtext (this_ent / )
  (IF (EQ (CDR (ASSOC 0 this_ent)) "MTEXT")
    (PROGN
      (SETQ txt_ent this_ent)
      (IF (EQ mp_space "Paper")
        (SETQ as_67 1)
        (SETQ as_67 0)
      ) ;_ end of if
      (SETQ
        dim_tbox
         (LIST
           (LIST
             (- 0 (/ (CDR (ASSOC 42 txt_ent)) 2.0))
             (- 0 (/ (CDR (ASSOC 43 txt_ent)) 2.0))
             0
           ) ;_ end of list
           (LIST (/ (CDR (ASSOC 42 txt_ent)) 2.0)
                 (/ (CDR (ASSOC 43 txt_ent)) 2.0)
                 0
           ) ;_ end of list
         ) ;_ end of list
      ) ;_ end of setq
      (SETQ dim_ht (CDR (ASSOC 40 txt_ent)))
      (SETQ dim_ang (CDR (ASSOC 50 txt_ent))
            ntz     (ABS ntz)
      ) ;_ end of setq
      (SETQ dim_txt_diag
             (DISTANCE (CAR dim_tbox) (CADR dim_tbox))
      ) ;_ end of setq
      (SETQ dim_txt_len
             (- (CAADR dim_tbox) (CAAR dim_tbox))
      ) ;_ end of setq
      (SETQ dim_txt_ht
             (- (CADADR dim_tbox) (CADAR dim_tbox))
      ) ;_ end of SETQ
      (SETQ dim_base (CDR (ASSOC 10 txt_ent))
            dim_base (TRANS
                       (LIST (CAR dim_base)
                             (CADR dim_base)
                             0.0
                       ) ;_ end of LIST
                       0
                       1
                     ) ;_ end of trans
      ) ;_ end of setq
      (COND
        ((= (CDR (ASSOC 71 txt_ent)) 1)
         (SETQ
           dimpt_ll (POLAR
                      (POLAR
                        dim_base
                        (+ dim_ang (* 1.5 PI))
                        (+ dim_txt_ht
                           (* sp_size dim_ht)
                        ) ;_ end of +
                      ) ;_ end of polar
                      (+ dim_ang PI)
                      (* sp_size dim_ht)
                    ) ;_ end of POLAR
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 2)
         (SETQ
           dimpt_ll
            (POLAR
              (POLAR
                dim_base
                (+ dim_ang PI)
                (+ (/ dim_txt_len 2)
                   (* sp_size dim_ht)
                ) ;_ end of +
              ) ;_ end of polar
              (+ dim_ang (* 1.5 PI))
              (+ dim_txt_ht (* sp_size dim_ht))
            ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 3)
         (SETQ
           dimpt_ll
            (POLAR
              (POLAR
                dim_base
                (+ dim_ang PI)
                (+ dim_txt_len
                   (* sp_size dim_ht)
                ) ;_ end of +
              ) ;_ end of polar
              (+ dim_ang (* 1.5 PI))
              (+ dim_txt_ht (* sp_size dim_ht))
            ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 4)
         (SETQ dimpt_ll (POLAR
                          (POLAR
                            dim_base
                            (+ dim_ang (* 1.5 PI))
                            (+ (/ dim_txt_ht 2.0)
                               (* sp_size dim_ht)
                            ) ;_ end of +
                          ) ;_ end of polar
                          (+ dim_ang PI)
                          (* sp_size dim_ht)
                        ) ;_ end of POLAR
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 5)
         (SETQ dimpt_ll (POLAR
                          (POLAR
                            dim_base
                            (+ dim_ang PI)
                            (+ (/ dim_txt_len 2)
                               (* sp_size dim_ht)
                            ) ;_ end of +
                          ) ;_ end of polar
                          (+ dim_ang (* 1.5 PI))
                          (+ (/ dim_txt_ht 2.0)
                             (* sp_size dim_ht)
                          ) ;_ end of +
                        ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 6)
         (SETQ
           dimpt_ll (POLAR
                      (POLAR
                        dim_base
                        (+ dim_ang PI)
                        (+ dim_txt_len
                           (* sp_size dim_ht)
                        ) ;_ end of +
                      ) ;_ end of polar
                      (+ dim_ang (* 1.5 PI))
                      (+ (/ dim_txt_ht 2.0)
                         (* sp_size dim_ht)
                      ) ;_ end of +
                    ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 7)
         (SETQ dimpt_ll (POLAR
                          (POLAR
                            dim_base
                            (+ dim_ang PI)
                            (* sp_size dim_ht)
                          ) ;_ end of polar
                          (+ dim_ang (* 1.5 PI))
                          (* sp_size dim_ht)
                        ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 8)
         (SETQ dimpt_ll (POLAR
                          (POLAR
                            dim_base
                            (+ dim_ang PI)
                            (+ (/ dim_txt_len 2.0)
                               (* sp_size dim_ht)
                            ) ;_ end of +
                          ) ;_ end of polar
                          (+ dim_ang (* 1.5 PI))
                          (* sp_size dim_ht)
                        ) ;_ end of polar
         ) ;_ end of SETQ
        )
        ((= (CDR (ASSOC 71 txt_ent)) 9)
         (SETQ
           dimpt_ll (POLAR
                      (POLAR
                        dim_base
                        (+ dim_ang PI)
                        (+ dim_txt_len
                           (* sp_size dim_ht)
                        ) ;_ end of +
                      ) ;_ end of polar
                      (+ dim_ang (* 1.5 PI))
                      (* sp_size dim_ht)
                    ) ;_ end of polar
         ) ;_ end of SETQ
        )
      ) ;_ end of COND
      (SETQ
;;;			    dimpt_ll (mapcar '(lambda (a b) (+ b a))(car dim_tbox) dim_base)
;;;			    dimpt_ur (mapcar '(lambda (a b) (+ b a))(cadr dim_tbox) dim_base)
        dimpt_lr (POLAR
                   dimpt_ll
                   dim_ang
                   (+ dim_txt_len
                      (* sp_size dim_ht 2.0)
                   ) ;_ end of +
                 ) ;_ end of polar
        dimpt_ul (POLAR
                   dimpt_ll
                   (+ dim_ang (* PI 1.5))
                   (+ dim_txt_ht
                      (* sp_size dim_ht 2.0)
                   ) ;_ end of +
                 ) ;_ end of polar
        dimpt_ur (POLAR
                   dimpt_ul
                   dim_ang
                   (+ dim_txt_len
                      (* sp_size dim_ht 2.0)
                   ) ;_ end of +
                 ) ;_ end of polar
      ) ;_ end of setq
      (PROGN
        (SETQ box_angle dim_ang
                                        ;(ANGLE dimpt_ll dimpt_lr)
              box_x_scale
               (+ dim_txt_len (* sp_size dim_ht 2.0))
              box_y_scale
               (+ dim_txt_ht (* sp_size dim_ht 2.0))
        ) ;_ end of SETQ
        (IF T                           ;(EQ mp_space "Paper")
          (PROGN
            (SETQ hdboxlst
                   (LIST
                     (CONS 0 "INSERT")
                     (CONS 2 "HDBOX")
                     (CONS 10 dimpt_ll)
                     (CONS 8 dlayr)
                     (CONS 41 box_x_scale)
                     (CONS 42 box_y_scale)
                     (CONS 43 1.0)
                     (CONS 50 box_angle)
                     (CONS 67 as_67)
;;;                     (CONS 70 1)
;;;                     (CONS 71 1)
                   ) ;_ end of LIST
            ) ;_ end of SETQ
            (ENTMAKE hdboxlst)
          ) ;_ end of PROGN
          (PROGN
            (SETQ 3dflst
                   (LIST
                     (CONS 0 "3DFACE")
                     (CONS 8 dlayr)
                     (CONS 10 dimpt_ll)
                     (CONS 11 dimpt_lr)
                     (CONS 12 dimpt_ur)
                     (CONS 13 dimpt_ul)
                     (CONS 67 as_67)
                     (CONS 70 15)
                   ) ;_ end of list
            ) ;_ end of setq
            (ENTMAKE 3dflst)
          ) ;_ end of PROGN
        ) ;_ end of IF
      ) ;_ end of progn
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of DEFUN
;;;*********************************************************************
(DEFUN paravpset (uvport / curvno vportss vpsslen cnt vpdat vpfini)
  (vl-load-com)
  (SETQ curvno (GETVAR "cvport"))
  (IF (AND (= curvno 1) (EQ (GETVAR "tilemode") 0))
    (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;    (COMMAND ".mspace")
  ) ;_ end of if
  (SETQ vportss
         (SSGET "x"
                (LIST (CONS 410 (GETVAR "CTAB")) (CONS 0 "VIEWPORT"))
         ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ vpsslen (SSLENGTH vportss))
  (SETQ cnt 0)
  (SETQ vpdatlst nil)
  (WHILE (< cnt vpsslen)
    (SETQ vpdat (ENTGET (SSNAME vportss cnt)))
    (IF (/= (CDR (ASSOC 8 vpdat)) "0")
      (IF vpdatlst
        (SETQ
          vpdatlst (APPEND
                     (LIST
                       (CONS (READ (SUBSTR (CDR (ASSOC 8 vpdat)) 5 2))
                             (CDR (ASSOC 69 vpdat))
                       ) ;_ end of CONS
                     ) ;_ end of LIST
                     vpdatlst
                   ) ;_ end of APPEND
        ) ;_ end of SETQ
        (SETQ vpdatlst
               (LIST (CONS (READ (SUBSTR (CDR (ASSOC 8 vpdat)) 5 2))
                           (CDR (ASSOC 69 vpdat))
                     ) ;_ end of CONS
               ) ;_ end of LIST
        ) ;_ end of SETQ
      ) ;_ end of if
    ) ;_ end of if
    (SETQ cnt (1+ cnt))
  ) ;_ end of while
  (WHILE (NOT vpfini)
    (IF (ASSOC uvport vpdatlst)
      (PROGN
        (SETQ
          cvp_ss (SSGET "X"
                        (LIST (CONS 0 "VIEWPORT")
                              (CONS 69 (CDR (ASSOC uvport vpdatlst)))
                        ) ;_ end of LIST
                 ) ;_ end of SSGET
        ) ;_ end of SETQ
        (SETQ cvpentdata (ENTGET (SSNAME cvp_ss 0)))
        (IF (> (CDR (ASSOC 68 cvpentdata)) 0)
          (SETVAR "cvport" (CDR (ASSOC uvport vpdatlst)))
          (PRINC (STRCAT "\nViewport #"
                         (ITOA (CDR (ASSOC 69 cvpentdata)))
                         " is not active! "
                 ) ;_ end of STRCAT
          ) ;_ end of PRINC
        ) ;_ end of IF
        (SETQ vpfini T)
      ) ;_ end of PROGN
      (SETQ vpfini T)
    ) ;_ end of if
  ) ;_ end of while
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
;;;(DEFUN paramask_help (hfnam)
;;;  (IF (SETQ help_file (FINDFILE (STRCAT hfnam "_help.htm")))
;;;    nil
;;;    (PROGN
;;;      (ALERT
;;;        (STRCAT "Unable to find the help file!\n"
;;;                "Please browse to the folder\n"
;;;                "where "
;;;                (STRCASE hfnam)
;;;                " is and get the file."
;;;        ) ;_ end of strcat
;;;      ) ;_ end of alert
;;;      (SETQ help_file
;;;             (GETFILED (STRCAT "Open " (STRCASE hfnam) " help file")
;;;                       (STRCAT "C:" hfnam "_help.htm")
;;;                       "htm"
;;;                       0
;;;             ) ;_ end of getfiled
;;;      ) ;_ end of setq
;;;    ) ;_ end of progn
;;;  ) ;_ end of if
;;;  (COND
;;;    ((AND
;;;       (FINDFILE "c:/program files/internet explorer/iexplore.exe")
;;;       help_file
;;;     ) ;_ end of and
;;;     (STARTAPP
;;;       (STRCAT "c:/program files/internet explorer/iexplore.exe "
;;;               help_file
;;;       ) ;_ end of strcat
;;;     ) ;_ end of startapp
;;;    )
;;;    ((AND
;;;       (FINDFILE
;;;         "c:/program files/netscape/communicator/program/netscape.exe"
;;;       ) ;_ end of findfile
;;;       help_file
;;;     ) ;_ end of and
;;;     (STARTAPP
;;;       (STRCAT
;;;         "c:/program files/netscape/communicator/program/netscape.exe "
;;;         help_file
;;;       ) ;_ end of strcat
;;;     ) ;_ end of startapp
;;;    )
;;;    (help_file
;;;     (ALERT
;;;       (STRCAT "Unable to determine your browser!\n"
;;;               "Please find its location and\n"
;;;               "select your browser program file."
;;;       ) ;_ end of strcat
;;;     ) ;_ end of alert
;;;     (SETQ the_brwsr (GETFILED "Select internet browser program"
;;;                               "C:"
;;;                               "exe"
;;;                               0
;;;                     ) ;_ end of getfiled
;;;     ) ;_ end of setq
;;;     (IF the_brwsr
;;;       (STARTAPP (STRCAT the_brwsr " " help_file))
;;;       (ALERT
;;;         (STRCAT "Unable to display help file!\n"
;;;                 "No browser found!"
;;;         ) ;_ end of strcat
;;;       ) ;_ end of alert
;;;     ) ;_ end of if
;;;    )
;;;  ) ;_ end of cond
;;;  (PRINC)
;;;) ;_ end of DEFUN
;;;*********************************************************************
(DEFUN c:hdspace ()
  (IF ureal
    NIL
    (LOAD "ureal" "\nFile UREAL.LSP not loaded! ")
  ) ;_ end of IF
  (SETQ sp_size
         (ureal
           1
           ""
           "ParaMASK spacing for numeric text (fraction of text height, normal=0.2):"
           (IF sp_size
             sp_size
             0.2
           ) ;_ end of if
         ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:hdmatch ()
  (IF ureal
    NIL
    (LOAD "ureal" "\nFile UREAL.LSP not loaded! ")
  ) ;_ end of IF
  (SETQ hd_wcstr
                 (ustr 0 "Wildcard to match for special spacing" "" T)
        hd_size
                 (ureal
                   1
                   ""
                   "ParaMASK spacing for all matched text (fraction of text height, normal=0.2):"
                   (IF hd_size
                     hd_size
                     0.2
                   ) ;_ end of if
                 ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:demask ()
  (IF (OR (NOT existhd_opt) (EQ existhd_opt "existhd_erase"))
    (PROGN
      (IF (EQ mp_space "Paper")
        (SETQ oldss (SSGET "X"
                           (LIST
                             '(-4 . "<and")
                             '(-4 . "<or")
                             '(8 . "*DIMS-[HM][IA][DS][EK]*")
                             '(8 . "*MASK*")
                             '(8 . "*TEXT-[HM][IA][DS][EK]*")
                             '(8 . "*TEXT-[HM][IA][DS][EK]-*")
                             (CONS 410 (GETVAR "CTAB"))
                             '(-4 . "or>")
                             '(-4 . "<not")
                             '(8 . "*|*")
                             '(-4 . "not>")
                             '(0 . "INSERT")
                             '(2 . "HDBOX")
                             '(-4 . "and>")
                           ) ;_ end of LIST
                    ) ;_ end of ssget
        ) ;_ end of setq
        (SETQ oldss (SSGET "X"
                           '((-4 . "<and")
                             (-4 . "<or")
                             (8 . "*NPLTHS")
                             (8 . "*NPLT*HS")
                             (8 . "*DIMS-[HM][IA][DS][EK]*")
                             (8 . "*MASK*")
                             (8 . "*TEXT-[HM][IA][DS][EK]*")
                             (8 . "*TEXT-[HM][IA][DS][EK]-*")
                             (-4 . "or>")
                             (-4 . "<not")
                             (8 . "*|*")
                             (-4 . "not>")
                             (-4 . "<or")
                             (-4 . "<and")
                             (0 . "INSERT")
                             (2 . "HDBOX")
                             (-4 . "and>")
                             (0 . "3DFACE")
                             (-4 . "or>")
                             (-4 . "and>")
                            )
                    ) ;_ end of ssget
        ) ;_ end of setq
      ) ;_ end of IF
      (IF oldss
        (COMMAND ".erase" oldss "")
      ) ;_ end of if
      (SETQ oldss NIL)
    ) ;_ end of PROGN
  ) ;_ end of IF
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:hdupd ()
  (vl-load-com)
  (SETQ oldhdupd_cmdecho (GETVAR "cmdecho"))
  (SETQ oldhdupd_tilemode (GETVAR "tilemode"))
  (SETVAR "cmdecho" 0)
  (IF (EQ mp_space "Paper")
    (IF (NOT (EQ (SETQ cvport_no (GETVAR "cvport")) 1))
      (IF (EQ (GETVAR "tilemode") 1)
        (PROGN
          (SETVAR "tilemode" 0)
          (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;          (COMMAND "_.pspace")
        ) ;_ end of PROGN
        (PROGN
          (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;          (COMMAND "_.pspace")
        )
      ) ;_ end of IF
    ) ;_ end of IF
  ) ;_ end of IF
  (getsets mp_space)
  (dodraworder)
  (IF (EQ oldhdupd_tilemode 1)
    (SETVAR "tilemode" oldhdupd_tilemode)
    (IF (NOT (EQ cvport_no 1))
      (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;      (COMMAND "_.mspace")
    ) ;_ end of IF
  ) ;_ end of if
  (SETVAR "cmdecho" oldhdupd_cmdecho)
  (PRINC)
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN getsets (ddo_space /)
  (IF (EQ ddo_space "Paper")
    (SETQ ddo_asso67 0)
    (SETQ ddo_asso67 1)
  ) ;_ end of IF
  (COND
    ((EQ ddo_space "Paper")
     (SETQ assoc67lst (LIST '(67 . 1) (CONS 410 (GETVAR "CTAB"))))
    )
    (T
     (SETQ assoc67lst '((-4 . "<NOT") (67 . 1) (-4 . "NOT>")))
    )
  ) ;_ end of COND
  (SETQ
    hddim_ss (SSGET "x"
                    (APPEND
                      (LIST
                        (CONS -4 "<AND")
                        (CONS 0 "INSERT")
                        (CONS 2 "HDBOX")
                        (CONS -4 "<OR")
                        (CONS 8 "~*RAIL?HAND-[HM][IA][DS][EK]*")
                        (CONS 8 "*DIMS*")
;;;			       (CONS 8 "*MASK")
                        (CONS -4 "OR>")
                        (CONS -4 "AND>")
                      ) ;_ end of LIST
                      assoc67lst
                    ) ;_ end of APPEND
             ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ
    hdtxt_ss (SSGET "x"
                    (APPEND
                      (LIST
                        (CONS -4 "<OR")
                          (CONS -4 "<AND")
                            (CONS 0 "INSERT")
                            (CONS -4 "<OR")
                              (CONS 2 "PR*")
                              (CONS 2 "HDBOX")
                            (CONS -4 "OR>")
                            (CONS 2 "~*[Bb][Aa][Ss][Ee]*")
                            (CONS 2 "~*[Cc]??[Pp][RrLl][Xx]##")
                            (CONS 2 "~PRC Pipeline*")
                          (CONS -4 "AND>")
                          (CONS -4 "<AND")
                            (CONS 0 "IMAGE")
                            (CONS 8 "*UNOTE-[HM][IA][DS][EK]*")
                            (CONS 8 "~*|*")
                          (CONS -4 "AND>")
                        (CONS -4 "OR>")
                        (CONS 8 "~*RAIL?HAND-[HM][IA][DS][EK]*")
                        (CONS 8 "~*DIMS*")
;;;			  (CONS 8 "~*MTXT?MASK*")
                        (CONS 8 "~*AREA*")
                        (CONS 8 "~*@@##P[HM][IA][DS][EK]*")
                        (CONS 8 "~*@@##P-[HM][IA][DS][EK]*")
                      ) ;_ end of LIST
                      assoc67lst
                    ) ;_ end of APPEND
             ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ hddimarea_ss
         (SSGET "x"
                (APPEND
                  (LIST
                    (CONS 0 "INSERT")
                    (CONS 2 "HDBOX")
                    (CONS 8 "*DIMS*")
                  ) ;_ end of LIST
                  assoc67lst
                ) ;_ end of APPEND
         ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ
    hdcirc_ss (SSGET "x"
                     (APPEND
                       (LIST
                         (CONS 8 "*RAIL?HAND-[HM][IA][DS][EK]*")
                       ) ;_ end of LIST
                       assoc67lst
                     ) ;_ end of APPEND
              ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ hrails_ss (SSGET "X"
                         (APPEND
                           (LIST
                             (CONS 8 "*RAIL?HAND*")
                           ) ;_ end of LIST
                           assoc67lst
                         ) ;_ end of APPEND
                  ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ prtee_ss (SSGET "X"
                        (APPEND
                          (LIST
                            (CONS 0 "INSERT")
                            (CONS -4 "<OR")
                            (CONS 2 "PRTEE")
                            (CONS 2 "PRCPLG")
                            (CONS 2 "PRBLOW")
                            (CONS 2 "PRBFV")
                            (CONS 2 "PRBV")
                            (CONS 2 "PRGV")
                            (CONS 2 "PRPV")
                            (CONS 2 "PRRED")
                            (CONS 2 "PRPLUG")
                            (CONS 2 "PRWYE")
                            (CONS 2 "PRTEEB")
                            (CONS 2 "PRCROSS")
                            (CONS -4 "OR>")
                          ) ;_ end of LIST
                          assoc67lst
                        ) ;_ end of APPEND
                 ) ;_ end of SSGET
  ) ;_ end of SETQ
  (IF prtee_ss
    (PROGN
      (SETQ prtpnts nil)
      (SETQ ell10lst nil)
      (SETQ prtcnt 0)
      (WHILE (< prtcnt (SSLENGTH prtee_ss))
        (SETQ prtpnts
               (APPEND
                 prtpnts
                 (LIST
                   (CDR (ASSOC 10 (ENTGET (SSNAME prtee_ss prtcnt))))
                 ) ;_ end of LIST
               ) ;_ end of APPEND
        ) ;_ end of SETQ
        (SETQ prtcnt (1+ prtcnt))
      ) ;_ end of WHILE
      (FOREACH n prtpnts
;;;	(SETQ ell10lst (APPEND ell10lst (LIST (CONS -4 "<AND")(CONS -4 "<")(CONS 10 (MAPCAR '+ n '(1 1 1)))(CONS -4 ">")(CONS 10 (MAPCAR '- n '(1 1 1)))(CONS -4 "AND>"))))
        (SETQ ell10lst (APPEND ell10lst (LIST (CONS 10 n))))
      ) ;_ end of foreach
      (SETQ ell10lst (APPEND (LIST (CONS -4 "<OR"))
                             ell10lst
                             (LIST (CONS -4 "OR>"))
                     ) ;_ end of append
      ) ;_ end of setq
    ) ;_ end of PROGN
  ) ;_ end of IF
;;;  (PRINC "\nell10lst=")
;;;  (PRINC ell10lst)
;;;  (princ)
  (SETQ txt_ss (SSGET "x"
                      (APPEND
                        (LIST
                          (CONS -4 "<OR")
                          (CONS 8 "*0ARV[VW]*")
                          (CONS 0 "TEXT")
                          (CONS 0 "MTEXT")
                          (CONS 0 "ARCALIGNEDTEXT")
                          (CONS 0 "*LEADER")
                          (CONS -4 "<AND")
                          (CONS 0 "ELLIPSE")
                        ) ;_ end of LIST
                        ell10lst
                        (LIST
                          (CONS -4 "AND>")
                          (CONS 2 "*TTBAT")
                          (CONS 2 "B1")
                          (CONS 2 "*#BARS")
                          (CONS 2 "NORTHA*")
                          (CONS 2 "I-B-##")
                          (CONS 2 "GTB????#")
                          (CONS 8 "*NO[HM][IA][DS][EK]*")
                          (CONS 8 "*N[HM][IS][DK]*")
                          (CONS -4 "OR>")
                        ) ;_ end of LIST
                        assoc67lst
                      ) ;_ end of APPEND
               ) ;_ end of ssget
  ) ;_ end of SETQ
  (SETQ bub_ss (SSGET "x"
                       (APPEND
                         (LIST
                           (CONS -4 "<OR")
                           (CONS 8 "*0ARV[1-9]*")
                           (CONS -4 "<OR")
                           (CONS 2 "B")
                           (CONS 2 "B1")
                           (CONS 2 "*#BARS")
                           (CONS 2 "NORTHA*")
                           (CONS 2 "I-B-##")
                           (CONS 2 "B_TAG")
                           (CONS 2 "D_TAG")
                           (CONS 2 "H_TAG")
                           (CONS -4 "OR>")
                           (CONS -4 "OR>")
                         ) ;_ end of LIST
                         assoc67lst
                       ) ;_ end of APPEND
                ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ dim_ss (SSGET "x"
                      (APPEND
                        (LIST
                          (CONS -4 "<OR")
                          (CONS 0 "DIMENSION")
                          (CONS 0 "MTEXT")
                          (CONS -4 "OR>")
                        ) ;_ end of LIST
                        assoc67lst
                      ) ;_ end of APPEND
               ) ;_ end of ssget
  ) ;_ end of setq
) ;_ end of defun
;;;*********************************************************************
(DEFUN dodraworder ()
  (IF (AND hrails_ss ;handrails (on layer *RAIL?HAND*)
           hdcirc_ss ;handrail circles (on layer *RAIL?HAND-[HM][IA][DS][EK]*)
           (> (SSLENGTH hrails_ss) 0)
           (> (SSLENGTH hdcirc_ss) 0)
      ) ;_ end of AND
    (PROGN
      (IF (AND hdcirc_ss (>(SSLENGTH hdcirc_ss)0))
        (COMMAND "_.draworder" hdcirc_ss "" "f")
      )
      (IF (AND hrail_ss (>(SSLENGTH hrail_ss)0))
        (COMMAND "_.draworder" hrails_ss "" "f")
      )
      (IF (AND hdcirc_ss (>(SSLENGTH hdcirc_ss)0))
        (COMMAND "_.move" hdcirc_ss "" "0,0" "")
      )
      (IF (AND hrail_ss (>(SSLENGTH hrail_ss)0))
        (COMMAND "_.move" hrails_ss "" "0,0" "")
      )
;;;      (setq ctr -1)
;;;      (repeat (sslength pmask_ss) (entupd (ssname pmask_ss (setq ctr (1+ ctr)))))
      ;or
;;;      (repeat (sslength pmask_ss) (COMMAND "_.move" (ssname pmask_ss (setq ctr (1+ ctr))) "" "0,0" ""))
    ) ;_ end of PROGN
  ) ;_ end of IF
  (IF (AND hddim_ss ;hdbox blocks on layer *DIMS* and not on layer *RAIL?HAND-[HM][IA][DS][EK]*
           dim_ss   ;dimension or Mtext entities
      )
    (IF (OR
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X*.DWG")
          (= (ATOF (SUBSTR (GETVAR "ACADVER") 1 4)) 17.0)
        )
      (PROGN
        (COND
          ((AND hddimarea_ss
                hddim_ss
                (> (SSLENGTH hddim_ss) 0)
                (> (SSLENGTH hddimarea_ss) 0)
           ) ;_ end of AND
           (IF debug_paramask
             (PROGN
               (PRINC "\nCOND (1) ")
               (princ)
             )
           )
           (COMMAND "_.COPY" hddim_ss hddimarea_ss "" "0,0" "")
           (COMMAND "_.ERASE" hddim_ss hddimarea_ss "")
           (SETQ hddim_ss NIL hddimarea_ss NIL was_hddim_ss T was_hddimarea_ss T)
          )
          ((AND hddim_ss (> (SSLENGTH hddim_ss) 0))
           (IF debug_paramask
             (PROGN
               (PRINC "\nCOND (2) ")
               (princ)
             )
           )
           (COMMAND "_.COPY" hddim_ss "" "0,0" "")
           (COMMAND "_.ERASE" hddim_ss "")
           (SETQ hddim_ss NIL was_hddim_ss T was_hddim_ss T)
          )
          ((AND hddimarea_ss (> (SSLENGTH hddimarea_ss) 0))
           (IF debug_paramask
             (PROGN
               (PRINC "\nCOND (3) ")
               (princ)
             )
           )
           (COMMAND "_.COPY" hddimarea_ss "" "0,0" "")
           (COMMAND "_.ERASE" hddimarea_ss "")
           (SETQ hddimarea_ss NIL was_hddimarea_ss T)
          )
        ) ;_ end of COND
        (COND
          ((AND dim_ss (> (SSLENGTH dim_ss) 0))
           (IF debug_paramask
             (PROGN
               (PRINC "\nCOND (4) ")
               (princ)
             )
           )
           (COMMAND "_.COPY" dim_ss "" "0,0" "")
           (COMMAND "_.ERASE" dim_ss "")
           (SETQ dim_ss NIL was_dim_ss T)
          )
        ) ;_ end of COND
      ) ;_ end of PROGN
;;;THE PROBLEM IS IN THE FOLLOWING PROGN.  IT IS BRINGING HIDE STUFF TO FRONT
      (PROGN
        (IF (AND hddimarea_ss hddim_ss)
          (PROGN
            (IF debug_paramask
              (PROGN
                (PRINC "\nIF (5) ")
                (princ)
              )
            )
            (COMMAND "_.draworder" hddim_ss hddimarea_ss "" "f")
          ) ;_ end of PROGN
          (IF (AND hddim_ss (>(SSLENGTH hddim_ss)0))
            (PROGN
              (IF debug_paramask
                (PROGN
                  (PRINC "\nIF (6) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" hddim_ss "" "f")
            ) ;_ end of PROGN
            (PROGN
              (IF debug_paramask
                (PROGN
                  (PRINC "\nIF (6a) ")
                  (princ)
                )
              )
            ) ;_ end of PROGN
          )
        ) ;_ end of if
;;;	(COMMAND "_.draworder" dim_ss "" "f")
        (IF (AND hddimarea_ss hddim_ss (>(SSLENGTH hddimarea_ss)0)(>(SSLENGTH hddim_ss)0))
          (PROGN
            (IF debug_paramask
              (PROGN
                (PRINC "\nIF (7) ")
                (princ)
              )
            )
            (COMMAND "_.move" hddim_ss hddimarea_ss "" "0,0" "")
          ) ;_ end of PROGN
          (IF (AND hddim_ss (>(SSLENGTH hddim_ss)0))
            (PROGN
              (IF debug_paramask
                (PROGN
                  (PRINC "\nIF (8) ")
                  (princ)
                )
              )
              (COMMAND "_.move" hddim_ss "" "0,0" "")
            ) ;_ end of PROGN
            (PROGN
              (IF debug_paramask
                (PROGN
                  (PRINC "\nIF (8a) ")
                  (princ)
                )
              )
            ) ;_ end of PROGN
          )
        ) ;_ end of if
      ) ;_ end of PROGN
    ) ;_ end of IF
  ) ;_ end of IF
  (IF (AND hdtxt_ss txt_ss)
    (IF (OR
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X?#*.DWG")
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X-*.DWG")
          (= (ATOF (SUBSTR (GETVAR "ACADVER") 1 4)) 17.0)
        )
      (PROGN
        (COND
          ((AND hdtxt_ss txt_ss (> (SSLENGTH hdtxt_ss) 0) (> (SSLENGTH txt_ss) 0))
            (IF debug_paramask
              (PROGN
                (PRINC "\nCOND (9) ")
                (princ)
              )
            )
           (COMMAND "_.COPY" hdtxt_ss "" "0,0" "")
           (COMMAND "_.COPY" txt_ss "" "0,0" "")
           (COMMAND "_.ERASE" hdtxt_ss txt_ss "")
           (SETQ hdtxt_ss NIL txt_ss NIL was_hdtxt_ss T was_txt_ss T)
          )
          ((AND hdtxt_ss (> (SSLENGTH hdtxt_ss) 0))
            (IF debug_paramask
              (PROGN
                (PRINC "\ncond (10) ")
                (princ)
              )
            )
           (COMMAND "_.COPY" hdtxt_ss "" "0,0" "")
           (COMMAND "_.ERASE" hdtxt_ss "")
           (SETQ hdtxt_ss NIL)
          )
          ((AND txt_ss (> (SSLENGTH txt_ss) 0))
            (IF debug_paramask
              (PROGN
                (PRINC "\ncond (11) ")
                (princ)
              )
            )
           (COMMAND "_.COPY" txt_ss "" "0,0" "")
           (COMMAND "_.ERASE" txt_ss "")
           (SETQ txt_ss NIL)
          )
        ) ;_ end of COND
      ) ;_ end of PROGN
      (PROGN
;;; ;;;	(ALERT "YES! WE SHOULD CORRECTLY DO DRAWORDER!")
        (IF (AND hdtxt_ss (> (SSLENGTH hdtxt_ss) 0))
          (COMMAND "_.draworder" hdtxt_ss "" "f")
        )
        (COMMAND "_.draworder" txt_ss "" "f")
;;;        (COMMAND "_.move" hdtxt_ss txt_ss "" "0,0" "")
      ) ;_ end of PROGN
    ) ;_ end of IF
;;;    (ALERT "Apparently hdtxt_ss and txt_ss are NIL")
  ) ;_ end of IF
  (IF (AND bub_ss (>(SSLENGTH bub_ss)0))
    (IF (OR
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X?#*.DWG")
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X-*.DWG")
          (= (ATOF (SUBSTR (GETVAR "ACADVER") 1 4)) 17.0)
        )
      (PROGN
        (COND
          ((> (SSLENGTH bub_ss) 0)
            (IF debug_paramask
              (PROGN
                (PRINC "\ncond (12) ")
                (princ)
              )
            )
           (COMMAND "_.COPY" bub_ss "" "0,0" "")
           (COMMAND "_.ERASE" bub_ss "")
           (SETQ bub_ss NIL was_bub_ss T)
          )
        ) ;_ end of COND
      ) ;_ end of PROGN
      (PROGN
        (IF debug_paramask
          (PROGN
            (PRINC "\nif (13) ")
            (princ)
          )
        )
        (COMMAND "_.draworder" bub_ss "" "f")
        (COMMAND "_.move" bub_ss "" "0,0" "")
        (SETQ bub_ss NIL was_bub_ss T)
      ) ;_ end of PROGN
    ) ;_ end of IF
  ) ;_ end of IF
  (IF (OR (AND (NOT dim_ss) (NOT txt_ss) (NOT bub_ss))
          (AND (NOT hddim_ss) (NOT hdtxt_ss) (NOT bub_ss))
      ) ;_ end of OR
    (COND
      ((AND (NOT was_hddim_ss)
            (NOT was_hdtxt_ss)
            (NOT was_dim_ss)
            (NOT was_txt_ss)
            (NOT was_bub_ss)
       ) ;_ end of AND
       (PRINC
         "\nNo text, dimensions, bubbles, border sheets or hiding objects found! "
       ) ;_ end of PRINC
       (PRINC)
      )
      ((AND (NOT was_hdtxt_ss) (NOT was_hddim_ss))
       (PRINC "\nNo hiding objects found! ")
       (PRINC)
      )
      ((AND (NOT was_dim_ss) (NOT was_txt_ss) (NOT was_bub_ss))
       (PRINC
         "\nNo text, dimensions, bubbles or border sheets found! "
       ) ;_ end of PRINC
       (PRINC)
      )
    ) ;_ end of COND
    (PROGN
      (IF
        (OR
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X?#*.DWG")
          (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X-*.DWG")
          (= (ATOF (SUBSTR (GETVAR "ACADVER") 1 4)) 17.0)
        )
         NIL
         (PROGN
           (COND
             ((AND dim_ss
                   (> (SSLENGTH dim_ss) 0)
                   txt_ss
                   (> (SSLENGTH txt_ss) 0)
                   bub_ss
                   (> (SSLENGTH bub_ss) 0)
              ) ;_ end of AND
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (14) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" dim_ss txt_ss "" "f")
              (COMMAND "_.draworder" bub_ss "" "f")
              (COMMAND "_.move" dim_ss txt_ss bub_ss "" "0,0" "")
             )
             ((AND txt_ss
                   (> (SSLENGTH txt_ss) 0)
                   bub_ss
                   (> (SSLENGTH bub_ss) 0)
              ) ;_ end of AND
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (15) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" txt_ss "" "f")
              (COMMAND "_.draworder" bub_ss "" "f")
              (COMMAND "_.move" txt_ss bub_ss "" "0,0" "")
             )
             ((AND dim_ss
                   (> (SSLENGTH dim_ss) 0)
                   txt_ss
                   (> (SSLENGTH txt_ss) 0)
              ) ;_ end of AND
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (16) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" dim_ss txt_ss "" "f")
              (COMMAND "_.move" dim_ss txt_ss "" "0,0" "")
             )
             ((AND dim_ss
                   (> (SSLENGTH dim_ss) 0)
                   bub_ss
                   (> (SSLENGTH bub_ss) 0)
              ) ;_ end of AND
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (17) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" dim_ss "" "f")
              (COMMAND "_.draworder" bub_ss "" "f")
              (COMMAND "_.move" dim_ss bub_ss "" "0,0" "")
             )
             ((AND dim_ss (> (SSLENGTH dim_ss) 0))
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (18) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" dim_ss "" "f")
              (COMMAND "_.move" dim_ss "" "0,0" "")
             )
             ((AND txt_ss (> (SSLENGTH txt_ss) 0))
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (19) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" txt_ss "" "f")
              (COMMAND "_.move" txt_ss "" "0,0" "")
             )
             ((AND bub_ss (> (SSLENGTH bub_ss) 0))
              (IF debug_paramask
                (PROGN
                  (PRINC "\nCOND (20) ")
                  (princ)
                )
              )
              (COMMAND "_.draworder" bub_ss "" "f")
              (COMMAND "_.move" bub_ss "" "0,0" "")
             )
           ) ;_ end of COND
           (IF (SETQ aecc_ss (SSGET "X" '((0 . "AECC_GENERAL_SEGMENT_LABEL"))))
             (COMMAND "_.draworder" aecc_ss "" "f")
           )
         ) ;_ end of PROGN
      ) ;_ end of IF
      (ddhtextsof)
    ) ;_ end of PROGN
  ) ;_ end of IF
  (SETQ was_hddim_ss NIL was_hddimarea_ss NIL was_dim_ss NIL was_hdtxt_ss NIL was_txt_ss NIL was_bub_ss NIL)
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN ddhtextsof (/)
  (SETQ clayr (GETVAR "clayer"))
  (IF (WCMATCH (STRCASE clayr) "*NPLT*")
    (SETVAR "clayer" "0")
  ) ;_ end of if
  (COMMAND "_.layer" "p" "n" "*nplt*" "")
  (COMMAND "_.layer" "off" "*nplt*" "")
;;;  (IF
;;;    (AND
;;;      (TBLOBJNAME "block" "hdbox")
;;;      (SSGET "X"
;;;	     '((-4 . "<AND") (0 . "INSERT") (2 . "HDBOX") (-4 . "AND>"))
;;;      ) ;_ end of SSGET
;;;    ) ;_ end of AND
;;;     (COMMAND "_.imageframe" "off")
;;;  ) ;_ end of IF
) ;_ end of defun

(PRINC)
 ;|«Visual LISP© Format Options»
(72 2 40 2 T "end of " 60 9 2 0 0 nil T nil T)
;*** DO NOT add text below the comment! ***|;

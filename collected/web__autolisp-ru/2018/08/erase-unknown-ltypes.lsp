(vl-load-com)

(defun c:erase-unknown-ltypes (/ adoc lt_lst layer_status lt lt_def)
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (vlax-for item (vla-get-layers adoc)
    (setq layer_status (cons (list item
                                   (mapcar (function (lambda (pr / tmp)
                                                       (setq tmp (vlax-get-property item (car pr)))
                                                       (vl-catch-all-apply (function (lambda () (vlax-put-property item (car pr) (cdr pr)))))
                                                       (cons (car pr) tmp)
                                                       ) ;_ end of lambda
                                                     ) ;_ end of Function
                                           (list (cons "freeze" :vlax-false) (cons "lock" :vlax-false))
                                           ) ;_ end of mapcar
                                   ) ;_ end of list
                             layer_status
                             ) ;_ end of cons
          ) ;_ end of setq
    ) ;_ end of vlax-for
  (setq lt_def "CONTINUOUS"
        lt_lst (mapcar (function strcase)
                       '("continuous"       "bylayer"          "byblock"          "послою"           "поблоку"          "border"           "рант"             "border2"          "рант2"
                         "borderx2"         "рантx2"           "center"           "осевая"           "center2"          "осевая2"          "centerx2"         "осеваяx2"         "dashdot"
                         "штрихпунктирная"  "dashdot2"         "штрихпунктирная2" "dashdotx2"        "штрихпунктирнаяx2"                   "dashed"           "невидимаяx2"      "dashed2"
                         "невидимая"        "dashedx2"         "штриховаяx2"      "divide"           "линия_сгиба"      "divide2"          "линия_сгиба2"     "dividex2"         "линия_сгибаx2"
                         "dot"              "пунктирная"       "dot2"             "пунктирная2"      "dotx2"            "пунктирнаяx2"     "hidden"           "невидимая"        "hidden2"
                         "невидимая2"       "hiddenx2"         "невидимаяx2"      "phantom"          "фантом"           "phantom2"         "фантом2"          "phantomx2"        "фантомx2"
                         "acad_iso02w100"   "acad_iso02w100"   "acad_iso03w100"   "acad_iso03w100"   "acad_iso04w100"   "acad_iso04w100"   "acad_iso05w100"   "acad_iso05w100"   "acad_iso06w100"
                         "acad_iso06w100"   "acad_iso07w100"   "acad_iso07w100"   "acad_iso08w100"   "acad_iso08w100"   "acad_iso09w100"   "acad_iso09w100"   "acad_iso10w100"   "acad_iso10w100"
                         "acad_iso11w100"   "acad_iso11w100"   "acad_iso12w100"   "acad_iso12w100"   "acad_iso13w100"   "acad_iso13w100"   "acad_iso14w100"   "acad_iso14w100"   "acad_iso15w100"
                         "acad_iso15w100"   "fenceline1"       "ограждение1"      "fenceline2"       "ограждение2"      "tracks"           "пути"             "batting"          "изоляция"
                         "hot_water_supply" "горячая_вода"     "gas_line"         "газопровод"       "zigzag"           "зигзаг"           "jis_08_11"        "jis_08_15"        "jis_08_25"
                         "jis_08_37"        "jis_08_50"        "jis_02_0 7"       "jis_02_1 0"       "jis_02_1 2"       "jis_02_2 0"       "jis_02_4 0"       "jis_09_08"        "jis_09_15"
                         "jis_09_29"        "jis_09_50"
                         )
                       ) ;_ end of mapcar
        ) ;_ end of setq
  (foreach item layer_status
    (setq lt (strcase (vla-get-linetype (car item))))
    (if (not (member lt lt_lst))
      (vl-catch-all-apply (function (lambda () (vla-put-linetype (car item) lt_def))))
      ) ;_ end of if
    ) ;_ end of foreach
  (vlax-for blk_def (vla-get-blocks adoc)
    (if (equal (vla-get-isxref blk_def) :vlax-false)
      (progn
        (vlax-for ent blk_def (setq lt (strcase (vla-get-linetype ent))) (vla-put-linetype ent lt_def))
        ) ;_ end of progn
      ) ;_ end of if
    ) ;_ end of vlax-for
  (foreach item layer_status
    (foreach pr (cdr item)
      (vl-catch-all-apply (function (lambda () (vlax-put-property (car item) (car pr) (cdr pr)))))
      ) ;_ end of foreach
    ) ;_ end of foreach
  (vla-auditinfo adoc :vlax-true)
  (repeat 3 (vla-purgeall adoc))
  (vlax-for item (vla-get-registeredapplications adoc)
    (vl-catch-all-apply (function (lambda () (vla-delete item))))
    ) ;_ end of vlax-for
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

(vl-load-com)

 ;|
*    Программка предназначена для работы с системными переменными файла
|;

(setq *kpblc-sysvar-list*
       '("3dconversionmode"   "3ddwfprec"          "3dselectionmode"    "acadlspasdoc"       "acadprefix"
         "acadver"            "actpath"            "actrecorderstate"   "actrecpath"         "actui"
         "aflags"             "angbase"            "angdir"             "annoallvisible"     "annoautoscale"
         "annotativedwg"      "apbox"              "aperture"           "area"               "attdia"
         "attipe"             "attmode"            "attmulti"           "attreq"             "auditctl"
         "aunits"             "auprec"             "autodwfpublish"     "automaticpub"       "autosnap"
         "backgroundplot"     "backz"              "bactionbarmode"     "bactioncolor"       "bconstatusmode"
         "bdependencyhighlight"                    "bgripobjcolor"      "bgripobjsize"       "bindtype"
         "blockeditlock"      "blockeditor"        "bparametercolor"    "bparameterfont"     "bparametersize"
         "btmarkdisplay"      "bvmode"             "cameradisplay"      "cameraheight"       "cannoscale"
         "cannoscalevalue"    "capturethumbnails"  "cdate"              "cdyndisplaymode"    "cecolor"
         "celtscale"          "celtype"            "celweight"          "centermt"           "cetransparency"
         "chamfera"           "chamferb"           "chamferc"           "chamferd"           "chammode"
         "cipmode"            "circlerad"          "clayer"             "cmaterial"          "cmdactive"
         "cmddia"             "cmdecho"            "cmdinputhistorymax" "cmdnames"           "cmleaderstyle"
         "cmljust"            "cmlscale"           "cmlstyle"           "compass"            "constraintbarmode"
         "constraintnameformat"                    "constraintrelax"    "constraintsolvemode"
         "coords"             "copymode"           "cplotstyle"         "cprofile"           "crossingareacolor"
         "cshadow"            "ctab"               "ctablestyle"        "cursorsize"         "cviewdetailstyle"
         "cviewsectionstyle"  "cvport"             "datalinknotify"     "date"               "dblclkedit"
         "dbmod"              "dctcust"            "dctmain"            "defaultgizmo"       "defaultlighting"
         "defaultlightingtype"                     "deflplstyle"        "defplstyle"         "delobj"
         "demandload"         "dgnframe"           "dgnimportmax"       "dgnmappingpath"     "dgnosnap"
         "diastat"            "dimadec"            "dimalt"             "dimaltd"            "dimaltf"
         "dimaltrnd"          "dimalttd"           "dimalttz"           "dimaltu"            "dimaltz"
         "dimanno"            "dimapost"           "dimarcsym"          "dimaso"             "dimassoc"
         "dimasz"             "dimatfit"           "dimaunit"           "dimazin"            "dimblk"
         "dimblk1"            "dimblk2"            "dimcen"             "dimclrd"            "dimclre"
         "dimclrt"            "dimdec"             "dimdle"             "dimdli"             "dimdsep"
         "dimexe"             "dimexo"             "dimfit"             "dimfrac"            "dimfxl"
         "dimfxlon"           "dimgap"             "dimjogang"          "dimjust"            "dimldrblk"
         "dimlfac"            "dimlim"             "dimltex1"           "dimltex2"           "dimltype"
         "dimlunit"           "dimlwd"             "dimlwe"             "dimpost"            "dimrnd"
         "dimsah"             "dimscale"           "dimsd1"             "dimsd2"             "dimse1"
         "dimse2"             "dimsho"             "dimsoxd"            "dimstyle"           "dimtad"
         "dimtdec"            "dimtfac"            "dimtfill"           "dimtfillclr"        "dimtih"
         "dimtix"             "dimtm"              "dimtmove"           "dimtofl"            "dimtoh"
         "dimtol"             "dimtolj"            "dimtp"              "dimtsz"             "dimtvp"
         "dimtxsty"           "dimtxt"             "dimtxtdirection"    "dimtzin"            "dimunit"
         "dimupt"             "dimzin"             "dispsilh"           "distance"           "divmeshboxheight"
         "divmeshboxlength"   "divmeshboxwidth"    "divmeshconeaxis"    "divmeshconebase"    "divmeshconeheight"
         "divmeshcylaxis"     "divmeshcylbase"     "divmeshcylheight"   "divmeshpyrbase"     "divmeshpyrheight"
         "divmeshpyrlength"   "divmeshsphereaxis"  "divmeshsphereheight"                     "divmeshtoruspath"
         "divmeshtorussection"                     "divmeshwedgebase"   "divmeshwedgeheight" "divmeshwedgelength"
         "divmeshwedgeslope"  "divmeshwedgewidth"  "donutid"            "donutod"            "dragmode"
         "dragp1"             "dragp2"             "dragvs"             "draworderctl"       "dtexted"
         "dwfframe"           "dwfosnap"           "dwgcheck"           "dwgcodepage"        "dwgname"
         "dwgprefix"          "dwgtitled"          "dxeval"             "dynconstraintmode"  "dyndigrip"
         "dyndivis"           "dynmode"            "dynpicoords"        "dynpiformat"        "dynpivis"
         "dynprompt"          "dyntooltips"        "edgemode"           "elevation"          "enterprisemenu"
         "expert"             "explmode"           "extmax"             "extmin"             "extnames"
         "faceterdevnormal"   "faceterdevsurface"  "facetergridratio"   "facetermaxedgelength"
         "facetermaxgrid"     "facetermeshtype"    "faceterminugrid"    "faceterminvgrid"    "faceterprimitivemode"
         "facetersmoothlev"   "facetratio"         "facetres"           "fielddisplay"       "fieldeval"
         "filedia"            "filletrad"          "fillmode"           "fontalt"            "fontmap"
         "frontz"             "fullopen"           "fullplotpath"       "geolatlongformat"   "geomarkervisibility"
         "gfang"              "gfclr1"             "gfclr2"             "gfclrlum"           "gfclrstate"
         "gfname"             "gfshift"            "griddisplay"        "gridmajor"          "gridmode"
         "gridstyle"          "gridunit"           "gripblock"          "gripcolor"          "gripcontour"
         "gripdyncolor"       "griphot"            "griphover"          "gripobjlimit"       "grips"
         "gripsize"           "gripsubobjmode"     "griptips"           "gtauto"             "gtdefault"
         "gtlocation"         "halogap"            "handles"            "hideprecision"      "hidetext"
         "hidexrefscales"     "highlight"          "hpang"              "hpannotative"       "hpassoc"
         "hpbound"            "hpboundretain"      "hpdouble"           "hpdraworder"        "hpgaptol"
         "hpinherit"          "hpislanddetection"  "hpislanddetectionmode"                   "hpmaxlines"
         "hpname"             "hpobjwarning"       "hporigin"           "hporiginmode"       "hporiginstoreasdefault"
         "hpquickprevtimeout" "hpscale"            "hpseparate"         "hpspace"            "hyperlinkbase"
         "imagehlt"           "impliedface"        "indexctl"           "inetlocation"       "inputhistorymode"
         "insbase"            "insname"            "insunits"           "insunitsdefsource"  "insunitsdeftarget"
         "intelligentupdate"  "interferecolor"     "interfereobjvs"     "interferevpvs"      "intersectioncolor"
         "intersectiondisplay"                     "isavebak"           "isavepercent"       "isolines"
         "largeobjectsupport" "lastangle"          "lastpoint"          "lastprompt"         "latitude"
         "layerdlgmode"       "layereval"          "layerevalctl"       "layerfilteralert"   "layernotify"
         "laylockfadectl"     "layoutregenctl"     "legacyctrlpick"     "lenslength"         "lightglyphdisplay"
         "lightingunits"      "lightsinblocks"     "limcheck"           "limmax"             "limmin"
         "linearbrightness"   "linearcontrast"     "locale"             "localrootprefix"    "lockui"
         "loftang1"           "loftang2"           "loftmag1"           "loftmag2"           "loftnormals"
         "loftparam"          "logexpbrightness"   "logexpcontrast"     "logexpdaylight"     "logexpmidtones"
         "logexpphysicalscale"                     "logfilemode"        "logfilename"        "logfilepath"
         "loginname"          "longitude"          "ltscale"            "lunits"             "luprec"
         "lwdefault"          "lwdisplay"          "lwunits"            "maxactvp"           "maxsort"
         "mbuttonpan"         "measureinit"        "measurement"        "menubar"            "menuctl"
         "menuecho"           "menuname"           "mirrtext"           "mleaderscale"       "modemacro"
         "msltscale"          "msolescale"         "mtextcolumn"        "mtexted"            "mtextfixed"
         "mtexttoolbar"       "mtjigstring"        "mydocumentsprefix"  "navswheelmode"      "navswheelopacitybig"
         "navswheelopacitymini"                    "navswheelsizebig"   "navswheelsizemini"  "navvcubedisplay"
         "navvcubelocation"   "navvcubeopacity"    "navvcubeorient"     "navvcubesize"       "nomutt"
         "northdirection"     "obscuredcolor"      "obscuredltype"      "offsetdist"         "offsetgaptype"
         "oleframe"           "olehide"            "olequality"         "olestartup"         "openpartial"
         "orthomode"          "osmode"             "osnapcoord"         "osnaphatch"         "osnapz"
         "osoptions"          "paperupdate"        "pdfframe"           "pdmode"             "pdsize"
         "peditaccept"        "pellipse"           "perimeter"          "perspective"        "perspectiveclip"
         "pfacevmax"          "pickadd"            "pickauto"           "pickbox"            "pickdrag"
         "pickfirst"          "pickstyle"          "platform"           "plineconvertmode"   "plinegen"
         "plinetype"          "plinewid"           "plotoffset"         "plotrotmode"        "plquiet"
         "polaraddang"        "polarang"           "polardist"          "polarmode"          "polysides"
         "popups"             "previeweffect"      "previewfaceeffect"  "previewfilter"      "previewtype"
         "projectname"        "projmode"           "proxygraphics"      "proxynotice"        "proxyshow"
         "psltscale"          "psolheight"         "psolwidth"          "psprolog"           "psquality"
         "pstylemode"         "pstylepolicy"       "psvpscale"          "publishallsheets"   "publishcollate"
         "publishhatch"       "pucsbase"           "qplocation"         "qpmode"             "qtextmode"
         "qvdrawingpin"       "qvlayoutpin"        "rasterdpi"          "rasterpercent"      "rasterthreshold"
         "recoverymode"       "refeditname"        "regenmode"          "rememberfolders"    "renderquality"
         "renderuserlights"   "reporterror"        "roamablerootprefix" "rollovertips"       "rtdisplay"
         "savefidelity"       "savefile"           "savefilepath"       "savename"           "savetime"
         "screenboxes"        "screenmode"         "screensize"         "selectionannodisplay"
         "selectionarea"      "selectionareaopacity"                    "selectionpreview"   "setbylayermode"
         "shadedge"           "shadedif"           "shadowplanelocation"                     "shortcutmenu"
         "shortcutmenuduration"                    "showhist"           "showlayerusage"     "showmotionpin"
         "shpname"            "sigwarn"            "sketchinc"          "skpoly"             "skystatus"
         "smoothmeshgrid"     "smoothmeshmaxface"  "smoothmeshmaxlev"   "snapang"            "snapbase"
         "snapisopair"        "snapmode"           "snapstyl"           "snaptype"           "snapunit"
         "solidcheck"         "solidhist"          "sortents"           "splframe"           "splinesegs"
         "splinetype"         "ssfound"            "sslocate"           "ssmautoopen"        "ssmpolltime"
         "ssmsheetstatus"     "standardsviolation" "statusbar"          "stepsize"           "stepspersec"
         "subobjselectionmode"                     "sunstatus"          "surftab1"           "surftab2"
         "surftype"           "surfu"              "surfv"              "syscodepage"        "tableindicator"
         "tabletoolbar"       "tabmode"            "target"             "tdcreate"           "tdindwg"
         "tducreate"          "tdupdate"           "tdusrtimer"         "tduupdate"          "tempprefix"
         "texted"             "texteval"           "textfill"           "textoutputfileformat"
         "textqlty"           "textsize"           "textstyle"          "thickness"          "thumbsave"
         "thumbsize"          "tilemode"           "timezone"           "tooltipmerge"       "trackpath"
         "treedepth"          "treemax"            "trimmode"           "tspacefac"          "tspacetype"
         "tstackalign"        "tstacksize"         "ucsaxisang"         "ucsbase"            "ucsdetect"
         "ucsfollow"          "ucsicon"            "ucsname"            "ucsorg"             "ucsortho"
         "ucsview"            "ucsvp"              "ucsxdir"            "ucsydir"            "undoctl"
         "undomarks"          "unitmode"           "updatethumbnail"    "viewctr"            "viewdir"
         "viewmode"           "viewsize"           "viewtwist"          "visretain"          "vplayeroverrides"
         "vplayeroverridesmode"                    "vpmaximizedstate"   "vprotateassoc"      "vsbackgrounds"
         "vsedgecolor"        "vsedgejitter"       "vsedgelex"          "vsedgeoverhang"     "vsedges"
         "vsedgesmooth"       "vsfacecolormode"    "vsfacehighlight"    "vsfaceopacity"      "vsfacestyle"
         "vshalogap"          "vshideprecision"    "vsintersectioncolor"                     "vsintersectionedges"
         "vsintersectionltype"                     "vsisoontop"         "vslightingquality"  "vsmaterialmode"
         "vsmax"              "vsmin"              "vsmonocolor"        "vsobscuredcolor"    "vsobscurededges"
         "vsobscuredltype"    "vsoccludedcolor"    "vsoccludededges"    "vsoccludedltype"    "vsshadows"
         "vssilhedges"        "vssilhwidth"        "vtduration"         "vtenable"           "vtfps"
         "whiparc"            "windowareacolor"    "wmfbkgnd"           "wmfforegnd"         "worlducs"
         "worldview"          "writestat"          "xclipframe"         "xdwgfadectl"        "xedit"
         "xfadectl"           "xloadctl"           "xloadpath"          "xrefctl"            "xrefnotify"
         "xreftype"           "zoomfactor"         "zoomwheel"          "3dosmode"           "aec3ddwfedge"
         "aeceipinprogress"   "aecforcedefaultmodelview"                "aecforcedisplaybysizedisabled"
         "aecforceexplodetosolid"                  "aecobjectisolatemode"                    "annomonitor"
         "appautoload"        "appframeresources"  "applyglobalopacities"                    "arrayassociativity"
         "arraycreation"      "arrayeditstate"     "arraytype"          "autocompletedelay"  "autocompletemode"
         "blocktestwindow"    "bptexthorizontal"   "cachemaxfiles"      "cachemaxtotalsize"  "calcinput"
         "cbartransparency"   "cconstraintform"    "classickeys"        "cleanscreenstate"   "clipromptlines"
         "clipromptupdate"    "constraintbardisplay"                    "constraintcursordisplay"
         "constraintinfer"    "contentexplorerstate"                    "cullingobj"         "cullingobjselection"
         "defaultindex"       "dgnimportmode"      "dgnimportunitconversion"                 "digitizer"
         "dimconstrainticon"  "displayviewcubein2d"                     "dynconstraintdisplay"
         "dyninfotips"        "erhighlight"        "exporteplotformat"  "exportmodelspace"   "exportpagesetup"
         "exportpaperspace"   "fbximportlog"       "filletrad3d"        "frame"              "frameselection"
         "globalopacity"      "gripmultifunctional"                     "groupdisplaymode"   "hatchboundset"
         "hatchcreation"      "hatchtype"          "helpprefix"         "hpbackgroundcolor"  "hpcolor"
         "hpdlgmode"          "hplastpattern"      "hplayer"            "hpmaxareas"         "hpquickpreview"
         "hprelativeps"       "hptransparency"     "imageframe"         "layoutcreateviewport"
         "maxtouches"         "meshtype"           "mirrhatch"          "navbardisplay"      "nopreviewgrip"
         "nopreviewhighlight" "objectisolationmode"                     "onlineautosavepath" "onlinedocmode"
         "onlinedocuments"    "onlinefolder"       "onlinesettingssync" "onlinesyncprovider" "onlinesynctime"
         "onlineusername"     "paletteiconstate"   "paletteopaque"      "parametercopymode"  "pdfosnap"
         "plinereversewidths" "plottransparencyoverride"                "pointcloudautoupdate"
         "pointcloudboundary" "pointcloudclipframe"                     "pointclouddensity"  "pointcloudlock"
         "pointcloudpointmax" "pointcloudrtdensity"                     "previewcreationtransparency"
         "previewdelay"       "propertypreview"    "propobjlimit"       "propprevtimeout"    "rebuild2dcv"
         "rebuild2ddegree"    "rebuild2doption"    "rebuilddegreeu"     "rebuilddegreev"     "rebuildoptions"
         "rebuildu"           "rebuildv"           "recoverauto"        "ribbonbgload"       "ribboncontextselect"
         "ribboncontextsellim"                     "ribbondockedheight" "ribboniconresize"   "ribbonselectmode"
         "ribbonstate"        "rolloveropacity"    "selectioncycling"   "selectionpreviewlimit"
         "selectsimilarmode"  "showpagesetupfornewlayouts"              "sktolerance"        "smoothmeshconvert"
         "smstate"            "snapgridlegacy"     "spldegree"          "splknots"           "splmethod"
         "splperiodic"        "startup"            "suppressalerts"     "surfaceassociativity"
         "surfaceassociativitydrag"                "surfaceautotrim"    "surfacemodelingmode"
         "surfoffsetconnect"  "surftrimautoextend" "surftrimprojection" "tbshowshortcuts"    "tempoverrides"
         "texteditor"         "tooltips"           "tooltipsize"        "tooltiptransparency"
         "transparencydisplay"                     "trayicons"          "traynotify"         "traytimeout"
         "ucs2ddisplaysetting"                     "ucs3dparadisplaysetting"                 "ucs3dperpdisplaysetting"
         "ucsselectmode"      "uosnap"             "viewbackstatus"     "viewcreation"       "viewdetailcreation"
         "viewdetaileditor"   "vieweditor"         "viewfwdstatus"      "viewsectioncreation"
         "viewsectioneditor"  "viewsketchmode"     "viewupdateauto"     "vpcontrol"          "vsacurvaturehigh"
         "vsacurvaturelow"    "vsacurvaturetype"   "vsadraftanglehigh"  "vsadraftanglelow"   "vsazebracolor1"
         "vsazebracolor2"     "vsazebradirection"  "vsazebrasize"       "vsazebratype"       "wbdefaultbrowser"
         "wbhelponline"       "wbhelptype"         "wipeoutframe"       "workspacelabel"     "wsautosave"
         "wscurrent"          "autoload"           "autoloadpath"       "lispenabled"
         )
      ) ;_ end of setq

(defun _kpblc-acad-version ()
                           ;|
*    Определение номера сборки AutoCAD
*    Возвращаемое значение: Число двойной точности. Для AutoCAD 2005 вернет 16.1, для 2006 - 16.2 и т.д.
Примеры вызова:
(_kpblc-acad-version)
|;
  (atof (getvar "acadver"))
  ) ;_ end of defun

(defun _kpblc-is-acad-rus ()
                          ;|
*    Проверяет, является ли AutoCAD русским. Для версий AutoCAD до 2012 включительно возвращает t
* независимо от локализации. В версии 2013 обрабатывает язык AutoCAD'a
|;
  (or (<= (_kpblc-acad-version) 18.2)
      (= (vla-get-localeid (vlax-get-acad-object)) 1049)
      ) ;_ end of or
  ) ;_ end of defun

(defun c:sysvar-out (/ file handle err)
                    ;|
*    Экспорт текущих значений системных переменных во внешний файл
|;
  (if (setq file (getfiled (if (_kpblc-is-acad-rus)
                             "Укажите имя файла для экспорта"
                             "Enter file name to export datas"
                             ) ;_ end of if
                           (vl-filename-base (getvar "dwgname"))
                           "txt"
                           1
                           ) ;_ end of getfiled
            ) ;_ end of setq
    (if (vl-catch-all-error-p
          (setq err
                 (vl-catch-all-apply
                   (function
                     (lambda ()
                       (setq handle (open file "w"))
                       (foreach item (vl-remove 'nil
                                                (mapcar
                                                  (function
                                                    (lambda (x)
                                                      (if (getvar x)
                                                        (cons x (getvar x))
                                                        ) ;_ end of if
                                                      ) ;_ end of lambda
                                                    ) ;_ end of function
                                                  *kpblc-sysvar-list*
                                                  ) ;_ end of mapcar
                                                ) ;_ end of vl-remove
                         (write-line
                           (strcat (car item)
                                   "\t"
                                   (cond
                                     ((listp (cdr item))
                                      (apply (function strcat)
                                             (cons (rtos (cadr item) 2 14)
                                                   (mapcar
                                                     (function
                                                       (lambda (a)
                                                         (strcat "," (rtos a 2 14))
                                                         ) ;_ end of lambda
                                                       ) ;_ end of function
                                                     (cddr item)
                                                     ) ;_ end of mapcar
                                                   ) ;_ end of cons
                                             ) ;_ end of apply
                                      )
                                     (t (vl-prin1-to-string (cdr item)))
                                     ) ;_ end of cond
                                   ) ;_ end of strcat
                           handle
                           ) ;_ end of write-line
                         ) ;_ end of foreach
                       ) ;_ end of lambda
                     ) ;_ end of function
                   ) ;_ end of vl-catch-all-apply
                ) ;_ end of setq
          ) ;_ end of vl-catch-all-error-p
      (princ (strcat "\n"
                     (if (_kpblc-is-acad-rus)
                       "Экспорт не выполнен"
                       "Sysvars doesn't exported"
                       ) ;_ end of if
                     " "
                     (vl-catch-all-error-message err)
                     ) ;_ end of strcat
             ) ;_ end of princ
      ) ;_ end of if
    ) ;_ end of if
  (vl-catch-all-apply (function (lambda () (close handle))))
  (princ)
  ) ;_ end of defun

(defun c:sysvar-in (/ _kpblc-conv-string-to-list adoc file handle str lst err)
                   ;|
*    Выполняет импорт системных переменных из стороннего файла в текущий
|;

  (defun _kpblc-conv-string-to-list (string separator / i)
                                    ;|
*    Функция разбора строки. Возвращает список либо точечную пару.
*    Параметры вызова:
*	string		разбираемая строка
*	separator	символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")	;'(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")		;'(1 2)
*    За основу взяты уроки Евгения Елпанова по рекурсиям
|;
    (cond
      ((= string "") nil)
      ((vl-string-search separator string)
       ((lambda (/ pos res)
          (while (setq pos (vl-string-search separator string))
            (setq res    (cons (substr string 1 pos) res)
                  string (substr string (+ (strlen separator) 1 pos))
                  ) ;_ end of setq
            ) ;_ end of while
          (reverse (cons string res))
          ) ;_ end of lambda
        )
       )
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun

  (if (and (setq file (getfiled (if (_kpblc-is-acad-rus)
                                  "Укажите файл с сохраненными значениями переменных"
                                  "Select file with saved system variables values"
                                  ) ;_ end of if
                                ""
                                "txt"
                                4
                                ) ;_ end of getfiled
                 ) ;_ end of setq
           (setq file (findfile file))
           ) ;_ end of and
    (progn
      (setq handle (open file "r"))
      (while (setq str (read-line handle))
        (setq lst (cons str lst))
        ) ;_ end of while
      (close handle)
      (setq lst (reverse lst))
      (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
      (foreach item (mapcar
                      (function
                        (lambda (x / tmp)
                          (setq tmp (_kpblc-conv-string-to-list x "\t"))
                          (cons (car tmp) (cadr tmp))
                          ) ;_ end of lambda
                        ) ;_ end of function
                      lst
                      ) ;_ end of mapcar
        (if (vl-catch-all-error-p
              (setq err (vl-catch-all-apply
                          (function
                            (lambda ()
                              (if (getvar (car item))
                                (cond
                                  ((= (type (getvar (car item))) 'int)
                                   (setvar (car item) (atoi (cdr item)))
                                   )
                                  ((= (type (getvar (car item))) 'real)
                                   (setvar (car item) (atof (cdr item)))
                                   )
                                  ((= (type (getvar (car item))) 'str)
                                   (setvar (car item) (cdr item))
                                   )
                                  ((= (type (getvar (car item))) 'list)
                                   (setvar (car item) (_kpblc-conv-string-to-list (cdr item) ","))
                                   )
                                  ) ;_ end of cond
                                ) ;_ end of if
                              ) ;_ end of lambda
                            ) ;_ end of function
                          ) ;_ end of vl-catch-all-apply
                    ) ;_ end of setq
              ) ;_ end of vl-catch-all-error-p
          (princ (strcat "\n"
                         (if (_kpblc-is-acad-rus)
                           "Ошибка установки системной переменной "
                           "Error settings system variable "
                           ) ;_ end of if
                         (car item)
                         (if (_kpblc-is-acad-rus)
                           " в значение "
                           " to value "
                           ) ;_ end of if
                         (cdr item)
                         " :: "
                         (vl-catch-all-error-message err)
                         ) ;_ end of strcat
                 ) ;_ end of princ
          ) ;_ end of if
        ) ;_ end of foreach
      (vla-endundomark adoc)
      ) ;_ end of progn
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(vl-load-com)

(setq *global-sysvar-list* '("*_toolpalettepath"  "3dconversionmode"   "3ddwfprec"          "3dosmode"
                             "3dselectionmode"    "_pkser"             "_server"            "_toolpalettepath"
                             "_vernum"            "acadlspasdoc" ; "acadprefix" ;; Исключена
                             "acadver"            "actpath"            "actpath "           "actrecorderstate"
                             "actrecpath"         "actui"              "adcstate"           "aec3ddwfedge"
                             "aeceipinprogress"   "aecforcedefaultmodelview"
                             "aecforcedisplaybysizedisabled"           "aecforceexplodetosolid"
                             "aecobjectisolatemode"                    "aflags"             "angbase"
                             "angdir"             "annoallvisible"     "annoautoscale"      "annomonitor"
                             "annotativedwg"      "apbox"              "aperture"           "appautoload"
                             "appframeresources"  "applyglobalopacities"                    "area"
                             "arrayassociativity" "arraycreation"      "arrayeditstate"     "arraytype"
                             "assiststate"        "attdia"             "attipe"             "attmode"
                             "attmulti"           "attreq"             "auditctl"           "aunits"
                             "auprec"             "autocompletedelay"  "autocompletemode"   "autodwfpublish"
                             "autoload"           "autoloadpath"       "automaticpub"       "autosnap"
                             "auxstat"            "axisunit"           "backgroundplot"     "backz"
                             "bactionbarmode"     "bactioncolor"       "bconstatusmode"     "bdependencyhighlight"
                             "bgripobjcolor"      "bgripobjsize"       "bindtype"           "blipmode"
                             "blockeditlock"      "blockeditor"        "blocktestwindow"    "bparametercolor"
                             "bparameterfont"     "bparametersize"     "bptexthorizontal"   "btmarkdisplay"
                             "bvmode"             "cachemaxfiles"      "cachemaxtotalsize"  "calcinput"
                             "cameradisplay"      "cameraheight"       "cannoscale"         "cannoscalevalue"
                             "capturethumbnails"  "cbartransparency"   "cconstraintform" ; "cdate" ;; Исключена
                             "cdyndisplaymode"    "cecolor"            "celtscale"          "celtype"
                             "celweight"          "centermt"           "cetransparency"     "chamfera"
                             "chamferb"           "chamferc"           "chamferd"           "chammode"
                             "cipmode"            "circlerad"          "classickeys"        "clayer"
                             "clayout"            "cleanscreenstate"   "clipromptlines"     "clipromptupdate"
                             "cmaterial"          "cmdactive"          "cmddia"             "cmdecho"
                             "cmdinputhistorymax" "cmdnames"           "cmdnames "          "cmfadecolor"
                             "cmfadeopacity"      "cmleaderstyle"      "cmljust"            "cmlscale"
                             "cmlstyle"           "colortheme"         "commandpreview"     "compass"
                             "complexltpreview"   "constraintbardisplay"                    "constraintbarmode"
                             "constraintcursordisplay"                 "constraintinfer"    "constraintnameformat"
                             "constraintrelax"    "constraintsolvemode"                     "contentexplorerstate"
                             "coords"             "copymode"           "cplotstyle"         "cprofile"
                             "cputicks"           "crossingareacolor"  "cshadow"            "ctab"
                             "ctablestyle"        "cullingobj"         "cullingobjselection"
                             "currentprofile"     "currentprofile "    "cursorbadge"        "cursorsize"
                             "cviewdetailstyle"   "cviewsectionstyle"  "cvport"             "datalinknotify"
          ; "date" ;; Исключена
                             "dbcstate"           "dblclkedit"         "dbmod"              "dctcust"
                             "dctmain"            "defaultgizmo"       "defaultindex"       "defaultlighting"
                             "defaultlightingtype"                     "deflplstyle"        "defplstyle"
                             "delobj"             "demandload"         "dgnframe"           "dgnimportmax"
                             "dgnimportmode"      "dgnimportunitconversion"                 "dgnmappingpath"
                             "dgnosnap"           "diastat"            "digitizer"          "dimadec"
                             "dimalt"             "dimaltd"            "dimaltf"            "dimaltrnd"
                             "dimalttd"           "dimalttz"           "dimaltu"            "dimaltz"
                             "dimanno"            "dimapost"           "dimarcsym"          "dimaso"
                             "dimassoc"           "dimasz"             "dimatfit"           "dimaunit"
                             "dimazin"            "dimblk"             "dimblk1"            "dimblk2"
                             "dimcen"             "dimclrd"            "dimclre"            "dimclrt"
                             "dimconstrainticon"  "dimcontinuemode"    "dimdec"             "dimdle"
                             "dimdli"             "dimdsep"            "dimexe"             "dimexo"
                             "dimfit"             "dimfrac"            "dimfxl"             "dimfxlon"
                             "dimgap"             "dimjogang"          "dimjust"            "dimlayer"
                             "dimldrblk"          "dimlfac"            "dimlim"             "dimltex1"
                             "dimltex2"           "dimltype"           "dimlunit"           "dimlwd"
                             "dimlwe"             "dimpickbox"         "dimpost"            "dimrnd"
                             "dimsah"             "dimscale"           "dimsd1"             "dimsd2"
                             "dimse1"             "dimse2"             "dimsho"             "dimsoxd"
                             "dimstyle"           "dimtad"             "dimtdec"            "dimtfac"
                             "dimtfill"           "dimtfillclr"        "dimtih"             "dimtix"
                             "dimtm"              "dimtmove"           "dimtofl"            "dimtoh"
                             "dimtol"             "dimtolj"            "dimtp"              "dimtsz"
                             "dimtvp"             "dimtxsty"           "dimtxt"             "dimtxtdirection"
                             "dimtxtruler"        "dimtzin"            "dimunit"            "dimupt"
                             "dimzin"             "displayviewcubein2d"                     "dispsilh"
                             "distance"           "divmeshboxheight"   "divmeshboxlength"   "divmeshboxwidth"
                             "divmeshconeaxis"    "divmeshconebase"    "divmeshconeheight"  "divmeshcylaxis"
                             "divmeshcylbase"     "divmeshcylheight"   "divmeshpyrbase"     "divmeshpyrheight"
                             "divmeshpyrlength"   "divmeshsphereaxis"  "divmeshsphereheight"
                             "divmeshtoruspath"   "divmeshtorussection"                     "divmeshwedgebase"
                             "divmeshwedgeheight" "divmeshwedgelength" "divmeshwedgeslope"  "divmeshwedgewidth"
                             "donutid"            "donutod"            "dragmode"           "dragp1"
                             "dragp2"             "dragvs"             "draworderctl"       "drstate"
                             "dtexted"            "dwfframe"           "dwfosnap"           "dwgcheck"
                             "dwgcodepage"        "dwgname"            "dwgprefix"          "dwgtitled"
                             "dxeval"             "dynconstraintdisplay"                    "dynconstraintmode"
                             "dyndigrip"          "dyndivis"           "dyninfotips"        "dynmode"
                             "dynpicoords"        "dynpiformat"        "dynpivis"           "dynprompt"
                             "dyntooltips"        "edgemode"           "elevation"          "enterprisemenu"
                             "erhighlight"        "errno"              "expert"             "explmode"
                             "exporteplotformat"  "exportmodelspace"   "exportpagesetup"    "exportpaperspace"
                             "expvalue"           "expwhitebalance"    "extmax"             "extmin"
                             "extnames"           "faceterdevnormal"   "faceterdevsurface"  "facetergridratio"
                             "facetermaxedgelength"                    "facetermaxgrid"     "facetermeshtype"
                             "faceterminugrid"    "faceterminvgrid"    "faceterprimitivemode"
                             "facetersmoothlev"   "facetratio"         "facetres"           "fbximportlog"
                             "fielddisplay"       "fieldeval"          "filedia"            "filetabpreview"
                             "filetabthumbhover"  "filletrad"          "filletrad3d"        "fillmode"
                             "fontalt"            "fontmap"            "frame"              "frameselection"
                             "frontz"             "fullopen"           "fullplotpath"       "geolatlongformat"
                             "geomarkervisibility"                     "geomarkpositionsize"
                             "gfang"              "gfclr1"             "gfclr2"             "gfclrlum"
                             "gfclrstate"         "gfname"             "gfshift"            "globalopacity"
                             "griddisplay"        "gridmajor"          "gridmode"           "gridstyle"
                             "gridunit"           "gripblock"          "gripcolor"          "gripcontour"
                             "gripdyncolor"       "griphot"            "griphover"          "gripmultifunctional"
                             "gripobjlimit"       "grips"              "gripsize"           "gripsubobjmode"
                             "griptips"           "groupdisplaymode"   "gtauto"             "gtdefault"
                             "gtlocation"         "halogap"            "handles"            "hatchboundset"
                             "hatchcreation"      "hatchtype"          "helpprefix"         "hideprecision"
                             "hidetext"           "hidexrefscales"     "highlight"          "highlightsmoothing"
                             "hpang"              "hpannotative"       "hpassoc"            "hpbackgroundcolor"
                             "hpbound"            "hpboundretain"      "hpcolor"            "hpdlgmode"
                             "hpdouble"           "hpdraworder"        "hpgaptol"           "hpinherit"
                             "hpislanddetection"  "hpislanddetectionmode"                   "hplastpattern"
                             "hplayer"            "hplinetype"         "hpmaxareas"         "hpmaxlines"
                             "hpname"             "hpobjwarning"       "hporigin"           "hporiginmode"
                             "hporiginstoreasdefault"                  "hpquickpreview"     "hpquickprevtimeout"
                             "hprelativeps"       "hpscale"            "hpseparate"         "hpspace"
                             "hptransparency"     "hyperlinkbase"      "imageframe"         "imagehlt"
                             "impliedface"        "indexctl"           "inetlocation"       "inputhistorymode"
                             "inputsearchdelay"   "insbase"            "insname"            "insunits"
                             "insunitsdefsource"  "insunitsdeftarget"  "intelligentupdate"  "interferecolor"
                             "interfereobjvs"     "interferevpvs"      "intersectioncolor"  "intersectiondisplay"
                             "isavebak"           "isavepercent"       "isolines"           "largeobjectsupport"
                             "lastangle"          "lastpoint"          "lastprompt"         "latitude"
                             "layerdlgmode"       "layereval"          "layerevalctl"       "layerfilteralert"
                             "layernotify"        "laylockfadectl"     "layoutcreateviewport"
                             "layoutregenctl"     "layouttab"          "lazyload"           "legacyctrlpick"
                             "lenslength"         "lightglyphdisplay"  "lightingunits"      "lightsinblocks"
                             "limcheck"           "limmax"             "limmin"             "linearbrightness"
                             "linearcontrast"     "linefading"         "linefadinglevel"    "linesmoothing"
                             "lispenabled"        "lispinit"           "locale"             "localrootprefix"
                             "lockui"             "loftang1"           "loftang2"           "loftmag1"
                             "loftmag2"           "loftnormals"        "loftparam"          "logexpbrightness"
                             "logexpcontrast"     "logexpdaylight"     "logexpmidtones"     "logexpphysicalscale"
                             "logfilemode"        "logfilename"        "logfilepath"        "loginname"
                             "longitude"          "ltscale"            "lunits"             "luprec"
                             "lwdefault"          "lwdisplay"          "lwunits"            "maxactvp"
                             "maxsort"            "maxtouches"         "mbuttonpan"         "measureinit"
                             "measurement"        "menubar"            "menuctl"            "menuecho"
                             "menuname"           "meshtype"           "millisecs"          "mirrhatch"
                             "mirrtext"           "mleaderscale"       "modemacro"          "msltscale"
                             "msmstate"           "msolescale"         "mtextautostack"     "mtextcolumn"
                             "mtextdetectspace"   "mtexted"            "mtextfixed"         "mtexttoolbar"
                             "mtjigstring"        "mydocumentsprefix"  "navbardisplay"      "navswheelmode"
                             "navswheelopacitybig"                     "navswheelopacitymini"
                             "navswheelsizebig"   "navswheelsizemini"  "navvcubedisplay"    "navvcubelocation"
                             "navvcubeopacity"    "navvcubeorient"     "navvcubesize"       "nfwstate"
                             "nodename"           "nomutt"             "nopreviewgrip"      "nopreviewhighlight"
                             "northdirection"     "objectisolationmode"                     "obscuredcolor"
                             "obscuredltype"      "offsetdist"         "offsetgaptype"      "oleframe"
                             "olehide"            "olequality"         "olestartup"         "onlineautosavepath"
                             "onlinedocmode"      "onlinedocuments"    "onlinefolder"       "onlinesettingssync"
                             "onlinesyncprovider" "onlinesynctime"     "onlineusername"     "openpartial"
                             "opmstate"           "orbitautotarget"    "orthomode"          "osmode"
                             "osnapcoord"         "osnaphatch"         "osnapnodelegacy"    "osnapoverride"
                             "osnapz"             "osoptions"          "paletteiconstate"   "paletteopaque"
                             "paperupdate"        "parametercopymode"  "pdfframe"           "pdfosnap"
                             "pdmode"             "pdsize"             "peditaccept"        "pellipse"
                             "perimeter"          "perspective"        "perspectiveclip"    "pfacevmax"
                             "phandle"            "pickadd"            "pickauto"           "pickbox"
                             "pickdrag"           "pickfirst"          "pickstyle"          "platform"
                             "plineconvertmode"   "plinegen"           "plinereversewidths" "plinetype"
                             "plinewid"           "plotid"             "plotlegacy"         "plotoffset"
                             "plotrotmode"        "plotter"            "plottransparencyoverride"
                             "plquiet"            "pointcloud2dvsdisplay"                   "pointcloudautoupdate"
                             "pointcloudboundary" "pointcloudcachesize"                     "pointcloudclipframe"
                             "pointclouddensity"  "pointcloudlighting" "pointcloudlightsource"
                             "pointcloudlock"     "pointcloudlod"      "pointcloudpointmax" "pointcloudpointmaxlegacy"
                             "pointcloudpointsize"                     "pointcloudrtdensity"
                             "pointcloudshading"  "pointcloudvisretain"                     "polaraddang"
                             "polarang"           "polardist"          "polarmode"          "polysides"
                             "popups"             "preselectioneffect" "previewcreationtransparency"
                             "previewdelay"       "previeweffect"      "previewfaceeffect"  "previewfilter"
                             "previewtype"        "product"            "program"            "projectname"
                             "projmode"           "propertypreview"    "propobjlimit"       "propprevtimeout"
                             "proxygraphics"      "proxynotice"        "proxyshow"          "psltscale"
                             "psolheight"         "psolwidth"          "psprolog"           "psquality"
                             "pstylemode"         "pstylepolicy"       "psvpscale"          "publishallsheets"
                             "publishcollate"     "publishhatch"       "pucsbase"           "qplocation"
                             "qpmode"             "qtextmode"          "queuedregenmax"     "qvdrawingpin"
                             "qvlayoutpin"        "rasterdpi"          "rasterpercent"      "rasterpreview"
                             "rasterthreshold"    "re-init"            "rebuild2dcv"        "rebuild2ddegree"
                             "rebuild2doption"    "rebuilddegreeu"     "rebuilddegreev"     "rebuildoptions"
                             "rebuildu"           "rebuildv"           "recoverauto"        "recoverymode"
                             "refeditname"        "refeditname "       "regenmode"          "rememberfolders"
                             "renderlevel"        "renderlightcalc"    "renderquality"      "rendertarget"
                             "rendertime"         "renderuserlights"   "reporterror"        "revcloudcreatemode"
                             "revcloudgrips"      "ribbonbgload"       "ribboncontextselect"
                             "ribboncontextsellim"                     "ribbondockedheight" "ribboniconresize"
                             "ribbonselectmode"   "ribbonstate"        "roamablerootprefix" "rolloveropacity"
                             "rollovertips"       "rtdisplay"          "savefidelity"       "savefile"
                             "savefile "          "savefilepath"       "savename"           "savename "
                             "savetime"           "screenboxes"        "screenmode"         "screensize"
                             "sdi"                "sectionoffsetinc"   "sectionthicknessinc"
                             "secureload"         "selectionannodisplay"                    "selectionarea"
                             "selectionareaopacity"                    "selectioncycling"   "selectioneffect"
                             "selectioneffectcolor"                    "selectionpreview"   "selectionpreviewlimit"
                             "selectsimilarmode"  "setbylayermode"     "shadedge"           "shadedif"
                             "shadowplanelocation"                     "shortcutmenu"       "shortcutmenuduration"
                             "showhist"           "showlayerusage"     "showmotionpin"      "showpagesetupfornewlayouts"
                             "shpname"            "sigwarn"            "sketchinc"          "skpoly"
                             "sktolerance"        "skystatus"          "smoothmeshconvert"  "smoothmeshgrid"
                             "smoothmeshmaxface"  "smoothmeshmaxlev"   "smstate"            "snapang"
                             "snapbase"           "snapgridlegacy"     "snapisopair"        "snapmode"
                             "snapstyl"           "snaptype"           "snapunit"           "solidcheck"
                             "solidhist"          "sortents"           "sortorder"          "spaceswitch"
                             "spldegree"          "splframe"           "splinesegs"         "splinetype"
                             "splknots"           "splmethod"          "splperiodic"        "ssfound"
                             "ssfound "           "sslocate"           "ssmautoopen"        "ssmopenrefresh"
                             "ssmpolltime"        "ssmsheetstatus"     "ssmstate"           "ssmstate "
                             "standardsviolation" "startinfolder"      "startmode"          "startup"
                             "statusbar"          "stepsize"           "stepspersec"        "stylesheet"
                             "subobjselectionmode"                     "sunstatus"          "suppressalerts"
                             "surfaceassociativity"                    "surfaceassociativitydrag"
                             "surfaceautotrim"    "surfacemodelingmode"                     "surfoffsetconnect"
                             "surftab1"           "surftab2"           "surftrimautoextend" "surftrimprojection"
                             "surftype"           "surfu"              "surfv"              "syscodepage"
                             "sysmon"             "tableindicator"     "tabletoolbar"       "tabmode"
                             "target"             "tbcustomize"        "tbshowshortcuts"    "tdcreate"
                             "tdindwg"            "tducreate"          "tdupdate"           "tdusrtimer"
                             "tduupdate"          "tempoverrides"      "tempprefix"         "textalignmode"
                             "textalignspacing"   "textallcaps"        "textautocorrectcaps"
                             "texted"             "texteditor"         "texteval"           "textfill"
                             "textoutputfileformat"                    "textqlty"           "textsize"
                             "textstyle"          "thickness"          "thumbsave"          "thumbsize"
                             "tilemode"           "timezone"           "tooltipmerge"       "tooltips"
                             "tooltipsize"        "tooltiptransparency"                     "touchmode"
                             "tpstate"            "tracewid"           "trackpath"          "transparencydisplay"
                             "trayicons"          "traynotify"         "traytimeout"        "treedepth"
                             "treemax"            "trimmode"           "trusteddomains"     "trustedpaths"
                             "tspacefac"          "tspacetype"         "tstackalign"        "tstacksize"
                             "ucs2ddisplaysetting"                     "ucs3dparadisplaysetting"
                             "ucs3dperpdisplaysetting"                 "ucsaxisang"         "ucsbase"
                             "ucsdetect"          "ucsfollow"          "ucsicon"            "ucsname"
                             "ucsname "           "ucsorg"             "ucsortho"           "ucsselectmode"
                             "ucsview"            "ucsvp"              "ucsxdir"            "ucsydir"
                             "undoctl"            "undomarks"          "unitmode"           "uosnap"
                             "updatethumbnail"    "useri1"             "useri2"             "useri3"
                             "useri4"             "useri5"             "userr1"             "userr2"
                             "userr3"             "userr4"             "userr5"             "users1"
                             "users3"             "users5"             "viewbackstatus"     "viewcreation"
                             "viewctr"            "viewdetailcreation" "viewdetaileditor"   "viewdir"
                             "vieweditor"         "viewfwdstatus"      "viewmode"           "viewsectioncreation"
                             "viewsectioneditor"  "viewsize"           "viewsketchmode"     "viewtwist"
                             "viewupdateauto"     "visretain"          "vpcontrol"          "vplayeroverrides"
                             "vplayeroverridesmode"                    "vpmaximizedstate"   "vprotateassoc"
                             "vsacurvaturehigh"   "vsacurvaturelow"    "vsacurvaturetype"   "vsadraftanglehigh"
                             "vsadraftanglelow"   "vsazebracolor1"     "vsazebracolor2"     "vsazebradirection"
                             "vsazebrasize"       "vsazebratype"       "vsbackgrounds"      "vsedgecolor"
                             "vsedgejitter"       "vsedgelex"          "vsedgeoverhang"     "vsedges"
                             "vsedgesmooth"       "vsfacecolormode"    "vsfacehighlight"    "vsfaceopacity"
                             "vsfacestyle"        "vshalogap"          "vshideprecision"    "vsintersectioncolor"
                             "vsintersectionedges"                     "vsintersectionltype"
                             "vsisoontop"         "vslightingquality"  "vsmaterialmode"     "vsmax"
                             "vsmin"              "vsmonocolor"        "vsobscuredcolor"    "vsobscurededges"
                             "vsobscuredltype"    "vsoccludedcolor"    "vsoccludededges"    "vsoccludedltype"
                             "vsshadows"          "vssilhedges"        "vssilhwidth"        "vtduration"
                             "vtenable"           "vtfps"              "wbdefaultbrowser"   "wbhelponline"
                             "wbhelptype"         "whiparc"            "whipthread"         "windowareacolor"
                             "wipeoutframe"       "wmfbkgnd"           "wmfforegnd"         "workspacelabel"
                             "worlducs"           "worldview"          "writestat"          "wsautosave"
                             "wscurrent"          "xclipframe"         "xdwgfadectl"        "xedit"
                             "xfadectl"           "xloadctl"           "xloadpath"          "xrefctl"
                             "xrefnotify"         "xrefoverride"       "xreftype"           "zoomfactor"
                             "zoomwheel"
                             )
      ) ;_ end of setq

(defun _kpblc-eval-value-round (value to)
                               ;|
;; http://forum.dwg.ru/showthread.php?p=301275
*    Выполняет округление числа до указанной точности
*    Примеры вызова:
(_kpblc-eval-value-round 16.365 0.01) ; 16.37
|;
  (if (zerop to)
    value
    (* (atoi (rtos (/ (float value) to) 2 0)) to)
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-conv-value-to-string (value /)
                                   ;|
*    конвертация значения в строку.
|;
  (cond
    ((= (type value) 'str) value)
    ((= (type value) 'int) (itoa value))
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (equal value (fix value) 1e-6)
          ) ;_ end of and
     (itoa (fix value))
     )
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (not (equal value (fix value) 1e-6))
          ) ;_ end of and
     (rtos value 2)
     )
    ((= (type value) 'real) (rtos value 2 14))
    ((not value) "")
    (t (vl-princ-to-string value))
    ) ;_ end of cond
  ) ;_ end of defun

(defun c:sysvarexport (/ file handle msg)
                      ;|
*    Команда экспортирует значения всех системных переменных в отдельный файл *.txt
|;
  (if (and (setq file (getfiled "Введите имя файла для экспорта системных переменных" "" "txt" 1))
           (/= file)
           (setq handle (open file "w"))
           ) ;_ end of and
    (progn
      (foreach item *global-sysvar-list*
        (write-line (strcat (strcase item)
                            "="
                            (_kpblc-conv-value-to-string (getvar item))
                            ) ;_ end of strcat
                    handle
                    ) ;_ end of write-line
        ) ;_ end of foreach
      (close handle)
      (setq msg (cons "Данные сохранены в файле " file))
      (alert (strcat (car msg) "\n" (cdr msg)))
      (princ (strcat (car msg) " " (cdr msg)))
      ) ;_ end of progn
    ) ;_ end of if

  (princ)
  ) ;_ end of defun

(defun c:sysvardiff (/                    _kpblc-string-replace                     _kpblc-conv-list-to-string
                     _kpblc-conv-string-to-list                file                 handle
                     sysvar               str                  html_file            html_lst
                     f
                     )
                    ;|
*    Команда сравнивает имеющиеся в AutoCAD системные переменные и значения, сохраненные в стороннем
* txt-файле. Отчет выводится в виде html-страницы
|;

  (defun _kpblc-string-replace (str old new)
                               ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
  str  исходная строка
  old  старая строка
  new  новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
    (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
    ) ;_ end of defun

  (defun _kpblc-conv-list-to-string (lst sep)
                                    ;|
*    Преобразование списка в строку
*    Параметры вызова:
  lst  обрабатываемй список
  sep  разделитель. nil -> " "
|;
    (if (and lst
             (setq lst (mapcar (function _kpblc-conv-value-to-string) lst))
             (setq sep (if sep
                         sep
                         " "
                         ) ;_ end of if
                   ) ;_ end of setq
             ) ;_ end of and
      (strcat (car lst)
              (apply (function strcat)
                     (mapcar
                       (function
                         (lambda (x)
                           (strcat sep x)
                           ) ;_ end of lambda
                         ) ;_ end of function
                       (cdr lst)
                       ) ;_ end of mapcar
                     ) ;_ end of apply
              ) ;_ end of strcat
      ""
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-conv-string-to-list (string separator / i)
                                    ;|
*    Функция разбора строки. Возвращает список либо точечную пару. За основу взяты уроки Евгения Елпанова по рекурсиям
*    Параметры вызова:
*  string    разбираемая строка
*  separator  символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;-> '(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")          ;-> '(1 2)
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
      ((wcmatch (strcase string) (strcat "*" (strcase separator) "*"))
       ((lambda (/ pos res _str prev)
          (setq pos  1
                prev 1
                _str (substr string pos)
                ) ;_ end of setq
          (while (<= pos (1+ (- (strlen string) (strlen separator))))
            (if (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
              (setq res    (cons (substr string 1 (1- pos)) res)
                    string (substr string (+ (strlen separator) pos))
                    pos    0
                    ) ;_ end of setq
              ) ;_ end of if
            (setq pos (1+ pos))
            ) ;_ end of while
          (if (< (strlen string) (strlen separator))
            (setq res (cons string res))
            ) ;_ end of if
          (if (or (not res) (= _str string))
            (setq res (list string))
            (reverse res)
            ) ;_ end of if
          ) ;_ end of lambda
        )
       )
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun

  (if (and (setq file (getfiled "Введите имя файла для сверки системных переменных" "" "txt" 4))
           file
           (setq handle (open file "r"))
           ) ;_ end of and
    (progn
      (while (setq str (read-line handle))
        (setq sysvar (cons (cons (substr str 1 (vl-string-search "=" str))
                                 (substr str (+ 2 (vl-string-search "=" str)))
                                 ) ;_ end of cons
                           sysvar
                           ) ;_ end of cons
              ) ;_ end of setq
        ) ;_ end of while
      (close handle)
      (if (setq sysvar (vl-sort (vl-remove-if
                                  (function
                                    (lambda (x)
                                      (or (not (getvar (car x)))
                                          (= (cdr x) (_kpblc-conv-value-to-string (getvar (car x))))
                                          ) ;_ end of or
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                                  sysvar
                                  ) ;_ end of vl-remove-if
                                (function
                                  (lambda (a b)
                                    (< (car a) (car b))
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                                ) ;_ end of vl-sort
                ) ;_ end of setq
        (if (and (setq html_file (getfiled "Введите имя файла отчета" "" "html" 1))
                 html_file
                 (setq handle (open html_file "w"))
                 ) ;_ end of and
          (progn
            (foreach item
                     (append
                       (list
                         "<html><head><title>Результаты сверки состояния системных переменных</title></head>"
                         (strcat "<body><h1>Сверка системных переменных с файлом " file "</h1><br /><br />")
                         "<table cellspasing=\"0\" cellpadding=\"2\" width=\"100%\" border=\"1px\">"
                         "<tr style=\"text-align:center;\"><td width=\"20%\"><strong>Системная переменная</strong><td width=\"40%\"><strong>В файле txt</strong></td><td><strong>В AutoCAD</strong></td></tr>"
                         ) ;_ end of list
                       (mapcar
                         (function
                           (lambda (x)
                             (strcat "<tr"
                                     (if (setq f (not f))
                                       ""
                                       " style=\"background-color: #e5e5e5;\""
                                       ) ;_ end of if
                                     "><td>"
                                     (car x)
                                     "</td><td>"
                                     (_kpblc-string-replace (_kpblc-string-replace (cdr x) "<" "&lt;") ">" "&gt;")
                                     "</td><td  style=\"text-align:center;\">"
                                     (_kpblc-string-replace
                                       (_kpblc-string-replace (_kpblc-conv-value-to-string (getvar (car x))) "<" "&lt;")
                                       ">"
                                       "&gt;"
                                       ) ;_ end of _kpblc-string-replace
                                     "</td></tr>"
                                     ) ;_ end of strcat
                             ) ;_ end of lambda
                           ) ;_ end of function
                         sysvar
                         ) ;_ end of mapcar
                       '("</table></body></html>")
                       ) ;_ end of append
              (write-line item handle)
              ) ;_ end of foreach
            (close handle)
            (command "_.browser" html_file)
            ) ;_ end of progn
          ) ;_ end of if
        (alert "Разница не обнаружена!")
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

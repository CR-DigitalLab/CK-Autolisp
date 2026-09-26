;;;   ACADR12.LSP
;;;   Copyright (C) 1992 by Autodesk, Inc.
;;;
;;;   Permission to use, copy, modify, and distribute this software
;;;   for any purpose and without fee is hereby granted, provided
;;;   that the above copyright notice appears in all copies and that
;;;   both that copyright notice and this permission notice appear in
;;;   all supporting documentation.
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;;;   WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;;;   PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.

;;;=== General Utility Functions ===

(defun *merr* (msg)
  (setq *error* m:err m:err nil)
  (princ)
)

(defun *merrmsg* (msg)
  (princ msg)
  (setq *error* m:err m:err nil)
  (princ)
)

;;;=== AME and Region Modeler Functions ===

(defun ai_setup (len area lu mass vol)
  (setq m:err *error* *error* *merrmsg*)
  (ai_loadame)
  (if (not (not SOLUNION))
    (progn
      (sollength len)
      (solareau area)
      (setvar "lunits" lu)
      (princ "\nLength unit is set to ")(princ len)(princ ". ")
      (princ "Area unit is set to ")(princ area)(princ ".\n")
       (if (not (not SOLBOX))
         (progn
            (solmass mass)    ;don't ask for regions
            (solvolume vol)   ;don't ask for regions
            (princ "Mass unit is set to ")(princ mass)(princ ". ")
            (princ "Volume unit is set to ")(princ vol)(princ ".\n")
         )
       )
      (c:soldisplay)
      (c:solwdens)
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_upgvar ()
  (setq m:err *error* *error* *merrmsg*)
  (ai_loadame)
  (if (not (not SOLUNION))
    (progn
     (solhangle 45)
     (solhpat "U")
     (solsolidify 3)
     (princ "\nVariables Upgraded. Objects will be automatically solidified.")
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_upgprec ()
  (setq m:err *error* *error* *merrmsg*)
  (ai_loadame)
  (if (not (not SOLUNION))
    (progn
      (solupgrade 1)
      (solpurge "bfile")
      (princ "\nAME R1 solids will be converted to Double Precision.")
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_scrcomp ()
  (setq m:err *error* *error* *merrmsg*)
  (ai_loadame)
  (if (not (not SOLUNION))
    (progn
      (solamecomp "ame1")
      (princ "\nScript compatibility set to AME R1.")
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_loadame ()
  (setq m:err *error* *error* *merrmsg*)
  (if (not SOLUNION)
    (if (or (findfile "region.exp") (findfile "region"))
      (_autoxload "region")
      (_autoxload "ame")
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_unloadame ()
  (setq m:err *error* *error* *merrmsg*)
  (if (xunload "ame" nil)
    (progn
      (ai_aloadame)
      (princ "\nAME unloaded.\n")
    )
  )
  (if (xunload "region" nil)
    (progn
      (autoxload "region" '("solidify" "solint" "solsub" "solunion" "solarea"
                            "solmove" "solchp" "solsep" "sollist" "solmassp"
                            "sollength" "solvar" "solmesh" "solwire" "solfeat"
                            "solwdens" "solucs" "solpurge" "ddsolvar"
                            "ddsolmassp" "solamever" "solareau" "solaxcol"
                            "soldelent" "soldisplay" "solhangle" "solhpat"
                            "solhsize" "sollength" "solpagelen" "solrender"
                            "solservmsg" "solsolidify" "solmatcurr")
      )
      (if (or (findfile "ame.exp") (findfile "ame"))
        (ai_amegrey " ")
      )
      (princ "\nRegion unloaded.\n")
    )
  )
  (menucmd "S=X")
  (menucmd "S=S")
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_select (/ load)
  (setq m:err *error* *error* *merrmsg*)
  (if (and
        (or (findfile "ame.exp") (findfile "ame"))
        (or (findfile "region.exp") (findfile "region"))
      )
    (progn
      (princ "\nNo modeler is loaded yet. ")
      (princ "Both AME and Region Modeler are available. ")
      (initget "Ame Region" )
      (setq load (getkword "\nAutoload Region/<AME>: "))
      (if (= load "Region")
        (setq app "region")
        (setq app "ame")
      )
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_amegrey (action)
  (foreach a '(1 2 4 13 15 16 27 28 33 35 36 44 45 47 50 51)
    (menucmd (strcat "P9." (itoa a) "=" action))
  )
)

(defun ai_aloadame (/ exist_reg)
 (if (null c:solunion)
  (progn
  (setq m:err *error* *error* *merrmsg*)
  (if (or (findfile "region.exp") (findfile "region"))
    (progn
      (setq exist_reg "yes")
      (autoxload "region" '("solidify" "solint" "solsub" "solunion" "solarea"
                            "solmove" "solchp" "solsep" "sollist" "solmassp"
                            "sollength" "solvar" "solmesh" "solwire" "solfeat"
                            "solwdens" "solucs" "solpurge" "ddsolvar"
                            "ddsolmassp" "solamever" "solareau" "solaxcol"
                            "soldelent" "soldisplay" "solhangle" "solhpat"
                            "solhsize" "sollength" "solpagelen" "solrender"
                            "solservmsg" "solsolidify" "solmatcurr")
      )
      (autoxload "ame" '("solbox" "solcone" "solcyl" "solsphere" "soltorus"
                         "solwedge" "solext" "solrev" "solcham" "solfill"
                         "solcut" "solinterf" "soldecomp" "solsubdiv"
                         "solmass" "solvolume" "solsect" "solprof"
                         "solmat" "solin" "solout" "ddsolmat" "solamecomp"
                         "solmass" "solsectype" "solupgrade" "solvolume")
      )
    )
    (autoxload "ame" '("solbox" "solcone" "solcyl" "solsphere" "soltorus"
                       "solwedge" "solext" "solrev" "solidify" "solint"
                       "solsub" "solunion" "solcham" "solfill" "solcut"
                       "solmove" "solchp" "solsep" "sollist" "solmassp"
                       "solarea" "solinterf" "soldecomp" "solsubdiv"
                       "sollength" "solmass" "solvar" "solvolume" "solmesh"
                       "solwire" "solfeat" "solsect" "solprof" "solwdens"
                       "solmat" "solucs" "solin" "solout" "solpurge"
                       "ddsolvar" "ddsolmassp" "ddsolmat" "solamecomp"
                       "solamever" "solareau" "solaxcol" "soldelent"
                       "soldisplay" "solhangle" "solhpat" "solhsize"
                       "sollength" "solmass" "solmatcurr" "solpagelen"
                       "solrender" "solsectype" "solservmsg" "solsolidify"
                       "solupgrade" "solvolume" )
    )
  )
  (if (and
        (null (or (findfile "ame.exp") (findfile "ame")))
        (= exist_reg "yes")
      )
    (ai_amegrey "~")
  )
  (setq *error* m:err m:err nil)
  )
 )
 (princ)
)

;;;=== AVE Render Functions ===

(defun ai_loadaverendr ()
  (if (null c:render)
    (autoxload "averendr" '("render" "light" "scene" "finish" "rpref"
                            "stats" "replay" "saveimg" "rconfig")
    )
  )
  (princ)
)

(defun c:ai_unloadave ()
  (princ "\n")
  (if (xunload "averendr" nil)
    (progn
      (princ "\nRender unloaded.\n")
      (ai_loadaverendr)
    )
  )
  (menucmd "S=X")
  (menucmd "S=S")
  (princ)
)

;;;=== ASE Functions ===

(defun ai_asegrey (action)
  (foreach a '(11 13 14 16 17 19 20 21 23 24 26 27 28 29 30 31 32 33
               34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 50 51)
    (menucmd (strcat "P1." (itoa a) "=" action))
  )
  (if (= action "~")
    (progn
      (setq ai_aseinit_yet nil)
      (menucmd "P1.10= ")
    )
    (menucmd "P1.10=~")
  )
)

(defun ai_aseinit_chk ()
  (menucmd "S=X")
  (if ai_aseinit_yet
    (menucmd "S=ASE")
    (menucmd "S=ASEINIT0")
  )
  (princ)
)

(defun ai_aseinit ()
  (setq m:err *error* *error* *merrmsg*)
  (if (= nil c:aseinit)
    (progn
      (princ "\nAutoCAD SQL Extension")
      (if (and (or (/= nil (findfile "ase"))
                   (/= nil (findfile "ase.exp"))
                   (/= nil (findfile "ase.exe"))
               )
               (/= nil (findfile "ase.lsp"))
          )
        (progn
          (xload "ase")
          (load "ase.lsp")
          (ai_asegrey " ")
          (menucmd "S=X")
          (menucmd "S=ASE")
          (setq ai_aseinit_yet T)
          (princ " loaded.")
          (c:aseinit)
        )
        (progn
          (princ " not loaded.")
          (princ "\nThe ASE files were not found in your search path directories.")
          (princ "\nCheck the installation of the SQL Extension and try again.")
        )
      )
    )
    (progn
      (ai_asegrey " ")
      (menucmd "S=X")
      (menucmd "S=ASE")
      (if (not ai_aseinit_yet)
        (progn
          (if (findfile "ase.lsp")
            (load "ase.lsp")
            (princ "\nASE.LSP not found.  'Quick' commands not available.")
          )
          (c:aseinit)
        )
      )
      (setq ai_aseinit_yet T)
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

(defun ai_aseterm ()
  (setq m:err *error* *error* *merrmsg*)
  (if (= ase_errno 0)
    (progn
      (xunload "ase")
      (ai_asegrey "~")
      (menucmd "S=X")
      (menucmd "S=S")
      (princ "\nAutoCAD SQL Extension unloaded.")
    )
  )
  (setq *error* m:err m:err nil)
  (princ)
)

;;; ===== AutoLoad =====

(defun _autoqload (quoi app cmdliste / qapp symnam)
  (setq qapp (strcat "\"" app "\""))
  (mapcar
   '(lambda (cmd / nom_cmd)
      (progn
        (setq nom_cmd (strcat "C:" cmd))
        (if (not (eval (read nom_cmd)))
            (eval
             (read (strcat
                    "(defun " nom_cmd "( / rtn)"
                    "(setq m:err *error* *error* *merrmsg*)"
                    "(if (ai_ffile " qapp ")"
                    "(progn (princ \"\nInitializing...\")"
                    "(_auto" quoi "load " qapp ") (setq rtn (" nom_cmd ")))"
                    "(ai_nofile " qapp "))"
                    "(setq *error* m:err m:err nil)"
                    "rtn)"
                    ))))))
   cmdliste)
  nil
)

(defun autoload (app cmdliste)
  (_autoqload "" app cmdliste)
)

(defun autoxload (app cmdliste)
  (_autoqload "x" app cmdliste)
)

(defun _autoload (app)
; (princ "Auto:(load ") (princ app) (princ ")") (terpri)
  (load app)
)

(defun _autoxload (app)
; (princ "Auto:(xload ") (princ app) (princ ")") (terpri)
  (if (= app "region") (ai_select))
  (xload app)
  (if (= app "region") (ai_amegrey "~"))
)

(defun ai_ffile (app)
  (or (findfile (strcat app ".lsp"))
      (findfile (strcat app ".exp"))
      (findfile (strcat app ".exe"))
      (findfile app)
  )
)

(defun ai_nofile (filename)
  (princ
    (strcat "\nThe file "
            filename
            "(.lsp/.exp/.exe) was not found in your search path directories."
    )
  )
  (princ "\nCheck the installation of the Support Files and try again.")
  (princ)
)


;;;===== AutoLoad LISP Applications =====

(autoload "appload" '("appload"))

(autoload "filter" '("filter"))

(autoload "dline" '("dline" "dl"))

(autoload "3d" '("3d" "ai_box" "ai_pyramid" "ai_wedge" "ai_dome"
                 "ai_mesh" "ai_sphere" "ai_cone" "ai_torus" "ai_dish")
)

(autoload "ddinsert" '("ddinsert"))

(autoload "asctext" '("asctext"))

(autoload "ddattdef" '("ddattdef"))

(autoload "ddattext" '("ddattext"))

(autoload "3darray" '("3darray"))

(autoload "ddmodify" '("ddmodify"))

(autoload "ddchprop" '("ddchprop"))

(autoload "ddview" '("ddview"))

(autoload "ddvpoint" '("ddvpoint"))

(autoload "mvsetup" '("mvsetup"))

(autoload "ddosnap" '("ddosnap"))

(autoload "ddptype" '("ddptype"))

(autoload "dducsp" '("dducsp"))

(autoload "ddunits" '("ddunits"))

(autoload "ddgrips" '("ddgrips"))

(autoload "ddselect" '("ddselect"))

(autoload "ddrename" '("ddrename"))

(autoload "rman_dcl" '("rmmenu"))

(autoload "ddsolprm" '("ddsolprm"))

(autoload "plud" '("plud"))

(_autoload "rxy")

(_autoload "thk")

(_autoload "ets")

(_autoload "et")

(_autoload "leader")

(_autoload "blklog")

(_autoload "laylog")

(_autoload "macro")

(_autoload "lrestore")

(_autoload "lqpick")

(_autoload "fence")

(_autoload "matchl")

(_autoload "txtpath")

(_autoload "edsp")

(_autoload "nline")

(_autoload "join")

(_autoload "attmplt")

(_autoload "zoom12")

(_autoload "prmatch")

(_autoload "dimstr")



;;;===== AutoXLoad ADS Applications =====

(autoxload "rasterin" '("gifin" "pcxin" "riaspect" "ribackg"
                        "riedge" "rigamut" "rigrey" "rithresh" "tiffin")
)

(autoxload "geomcal" '("cal"))

(autoxload "geom3d" '("mirror3d" "rotate3d" "align"))

(princ)

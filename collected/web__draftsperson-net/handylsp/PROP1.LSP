; PROP1.LSP
; 2/11/1987
; by Tony Tanzillo, A/E Automation Systems (70307,2556)
;
; Notice
;
; The information contained herein is being donated to the public domain soley
; for the benefit of licensed AutoCAD END USERS everywhere. You are free to
; reproduce, modify and distribute the information contained herein for ANY
; NON-COMMERCIAL use, provided such reproduction/distribution is NOT FOR PROFIT,
; and the information contained herein (or any portion thereof)is NOT ALTERED
; from it's original content in ANY manner, shape, or form.
;
; You ARE NOT free to reproduce and/or distribute the information contained
; herein (regardless of medium or form of reproduction) for profit, or to
; include it or any portion thereof, as a part of any commercially marketed
; goods regardless of its intended nature, scope, or form, without the
; expressed written permission of the author.
;
; If you seek such permission, it will be granted provided you furnish
; ONE fully-functional licensed sample of the finished product(s) in final
; marketed form. In return for which you may solict and will recieve the
; author's objective opinions, advice and insight regarding any and all
; aspects of said product(s), free of charge, with appropriate and complete
; written assurance of non-disclosure.
;
; Additional information can be obtained
; by writing to:
;                   Anthony F. Tanzillo,
;                   32 Gould Ave.
;                   Paterson, N. J. 07503
;
; Or, via electronic medium thru;
;
;                   Compuserve ID: 70307,2556
;
; PROP1.LSP
;
; This file contains revised/improved versions of the functions
; contained in the files SET.LSP, PROP.LSP, and COPY.LSP.
; Main improvement concerns how the color and linetype properties of
; the selected object are interpreted and handled with respect to
; the default value of "BYLAYER". There is also an improved (layers)
; function, and an associated (prev) function that recalls the last
; set of layer names obtained by the (layers) function.
;
; Other user-defined functions called by these revised functions
; have not changed, and can be obtained from the original
; respective files.
;
;  COPY.LSP
;  -------------------------------------------------------------------
;  (copy)  - Will now cause the objects being changed to inherit all
;            properties of the selected object including "BYLAYER" for
;            color and linetype. This function will work with blocks,
;            but it is advised that you avoid them for purposes of
;            copying properties.
;
;            If the selected object's elevation and/or thickness is
;            UNDEFINED (assumed to be ZERO), then the elevation
;            and/or thickness of the object(s) being changed will
;            NOT BE MODIFIED regardless of thier current values.
;
;            You can modify (copy) to substitute 0 drawing units when
;            an object with an undefined elevation or thickness is
;            selected by replacing the "" in these 2 exprssions with 0.0;
;
;              (orr '((pfetch e 38) "")) ; elevation
;              (orr '((pfetch e 39) "")) ; thickness
;
;            Here are the same expressions modified to substitute
;            0.0 dwg. units when the default value is returned;
;
;              (orr '((pfetch e 38) 0.0))
;              (orr '((pfetch e 39) 0.0))
;
;            These same modifications can be made to the (elev) and
;            (thick) functions in PROP.LSP if desired.
;
:  SET.LSP
;  ------------------------------------------------------------------
;  SET    - Will now set the current color and/or linetype to
;           "BYLAYER" if the selected objects color/linetype
;           properties are BYLAYER. Also, will correctly detect and
;           reject the selected object if it is a block.
;
;   NOTES:  If the selected object's elevation and/or thickness is
;           UNDEFINED they will be interpreted to be ZERO, and the
;           CURRENT elevation and/or thickness will be CHANGED TO
;           0 DRAWING UNITS.
;
;           Again, you can modify the function so that the current
;           elevation and thickness will not be changed if an
;           object with undefined elev. and/or thickness is selected,
;           by reversing the modification outlined above for (copy).
;
;  PROP.LSP
;  ------------------------------------------------------------------
;  (color) - Will return "BYLAYER" if the selected object's color is
;            bylayer. If (color) is used as a response to the LAYER
;            COLOR subcommand, it will NOT WORK correctly if the
;            color property of the object selected is BYLAYER.
;
;(linetype)- Will return "BYLAYER" if the selected object's linetype is
;            bylayer. If (linetype) is used as a response to the LAYER
;            LINETYPE subcommand, it will NOT WORK if the linetype
;            property of the selected object is BYLAYER.
;
;  (layers)- Streamlined, debugged, and more efficient.
;            It will also display the list of layer names exactly
;            as they are being supplied to the layer subcommand.
;            Can be used as a response to ANY LAYER subcommand where
;            more than one layer name delimited by commas is a valid
;            response.
;
;            Also, duplicate layer names are purged from the
;            resulting command list making the function much more
;            efficient, and flexible. You can select multiple
;            objects on the same layer, but the name of that layer
;            will only appear once in the command list. Keep in mind
;            that the resulting command list-string should not
;            exceed 80 bytes. If it is larger, there may be
;            un-predictable results.
;
;  New feature
;
;  A new function has been added to facilitate subsequent use
;  of the last "set" of layer names selected via the (layers)
;  function. When you initiate the (layers) function, the
;  string containing the comma-delimited layer names of the
;  objects you select is displayed thusly;
;
;  Selected layer: layr1,layr2,layr3,layr4
;
;  These are the layer names of all the objects you selected
;  which are then passed to the AutoCAD LAYER sub-command
;  prompt.
;
;  This same string of layer names is bound to a GLOBAL
;  SYMBOL, and will remain in memory until you use the
;  (layers) function again. This means you can refer to the
;  same "set" of layer names which you selected with the
;  LAST use of the (layers) funtion in subsequent LAYER sub-
;  command prompts.
;
;  For example, you can turn off or FREEZE a group of layers
;  who's names were extracted from entities selected by the
;  (layers) function, continue editing the drawing, and then
;  be able to turn on or THAW the same set of layers selected
;  by the LAST use of the (layers) function. Another function
;  called "(PREV)" is included herein to make this easy.
;  Simply enter "(PREV)" at the appropriate LAYER sub-command
;  prompt i.e.;
;
;     First, freeze a bunch of layers, by simply pointing
;     to objects on the desired layers;
;
;  Command: LAYER ?/Make/Set/New/ON/OFF/Color/Ltype/Freeze/Thaw: FREEZE
;
;  Layer name(s) to Freeze: (LAYERS)
;
;  Select objects: <<<select an object on each layer to be frozen>>>
;
;  Selected layers: walls,floors,doors,windows,dimensions,electric
;
;  ?/Make/Set/New/ON/OFF/Color/Ltype/Freeze/Thaw: <cr>
;
;  Command: _
;
;     This sequence has caused the displayed layers to be frozen.
;     Now, you can continue to edit the drawing and when you want
;     to THAW ONLY these same layers that you had just FROZEN by
;     using the (layers) funcition, You can do this simply by using
;     another included function called "(PREV)". i.e.;
;
;  Command:  LAYER ?/Make/Set/New/ON/OFF/Color/Ltype/Freeze/Thaw: THAW
;
;  Layer name(s) to Thaw: (PREV)
;
;  Selected layers: walls,floors,doors,windows,dimensions,electric
;
;  ?/Make/Set/New/ON/OFF/Color/Ltype/Freeze/Thaw: <CR>
;
;  Command: _
;
;  This results in THAWing ONLY the same layers that were selected
;  by the LAST use of the (LAYERS) function.
;

(defun copy( / e )
  (setvar "cmdecho" 0)
  (if (setq e (entsel))
    (command
      "la" (pfetch e 8)
      "c"  (orr '((pfetch e 62) "BYLAYER"))     ; If no color, BYLAYER.
      "lt" (orr '((pfetch e 6) "BYLAYER"))      ; If no linetype, BYLAYER
      "el" (orr '((pfetch e 38) ""))            ; if no elev, no change.
      "th" (orr '((pfetch e 39) "")))) (progn)) ; if no thickness, no change.

(defun C:SET( / e)
  (if
    (and
      (setq e (entsel))
      (not
        (if (eq (pfetch e 0) "INSERT")
          (progn (prompt "\rBlocks not permitted, try again.")T))))

    (progn
      (setvar "cmdecho" 0)
      (prompt "\rNew current drawing editor properties:")
      (command
        "layer" "s" (pfetch e 8) ""
        "color" (orr '((pfetch e 62) "BYLAYER"))           ;If no color, BYLAYER
        "linetype" "s" (orr '((pfetch e 6) "BYLAYER")) ""  ;  "  linetype,   "
        "elev" (orr '((pfetch e 38) 0.0))                  ;If no elev, or
               (orr '((pfetch e 39) 0.0)))                 ;thickness, then 0.0
                                                           ;is assumed and used.
      (prompt
        (strcat
          "\nColor: " (getvar "cecolor")
          ",  Linetype: " (getvar "celtype")
          ",  Elevation: " (rtos (getvar "elevation"))
          ",  Thickness: " (rtos (getvar "thickness"))))))

  (progn))    ; returns nothing to command line,
              ; in this form, it must be the last expression
              ; to be evaluated before exiting to AutoCAD.


(defun color()
  (orr '((pfetch (entsel) 62) "BYLAYER")) ; if there is no color property,
)                                         ; then use BYLAYER instead.

(defun linetype()
  (orr '((pfetch (entsel) 6) "BYLAYER"))  ; here also.
)


(defun layers()
  (prompt
    (strcat "\nSelected layers: "
      (strcase
        (setq _lrs
          (strcat
            (car (setq _lrs (unique (mapcar '(lambda (x) (pfetch x 8))
                                      (sslist (ssget))))))
            (apply 'strcat
              (mapcar '(lambda (l) (strcat "," l)) (cdr _lrs)))))T)))

  (setvar "cmdecho" 0)
  (command _lrs)
  (progn)
)


(defun prev()
  (if (not (null _LRS))
    (progn
      (setvar "cmdecho" 0)
      (prompt (strcat "\nSelected layers: " (strcase _LRS T)))
      (command _LRS))

    (prompt "No previous layers saved."))

  (progn)
)



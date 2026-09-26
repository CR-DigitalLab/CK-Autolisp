;***	ATTWIDTH.lsp
;***	Written by Don J. Buschert (c) 1996
;
;	Email:	don.buschert@sait.ab.ca
;		buschert@spots.ab.ca
;	AutoCAD Page:	http://www.spots.ab.ca/~buschert/autocad/main.htm 
;
;	Disclaimer:
;	Permission to use, copy, modify, and distribute this software 
;	for any purpose and without fee is hereby granted, provided
;	that the above copyright notice appears in all copies and 
;	that both that copyright notice and the limited warranty and 
;	restricted rights notice below appear in all supporting 
;	documentation.
;
;	THIS PROGRAM IS PROVIDED "AS IS" AND WITH ALL FAULTS.  THE AUTHOR
;	SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY OR
;	FITNESS FOR A PARTICULAR USE.  THE AUTHOR ALSO DOES NOT WARRANT THAT
;	THE OPERATION OF THE PROGRAM WILL BE UNINTERRUPTED OR ERROR FREE.
;
;	Version 1.00	09/17/96
;
;	ATTWIDTH changes the width factor of a selected attribute by an 
;	increment.  If the increment is a negative value, the width decreases,
;	if positive, it increases.  This is great for attributes that are too
;	long and need to be compressed.  It is much easier than using the
;	ATTEDIT command.
;
(princ "\nInitial load, please wait...")
;
;***	Function ATTWIDTH
;
(defun C:ATTWIDTH ( / elis		;Enitiy data list
                    enty		;Selected entity
                    flag		;Flag
                    ;incr		;Increment
                    nlis		;New entity data list
                    nwid		;New width
                    owid		;Old width
                    sv_luprec	;"LUPREC" system variable
                )

  ;Define error routine for this command
  (defun attwidth_error (s)
    (if (/= s "Function cancelled.");if ^c occurs...
      (princ (strcat "\nError: " s))
    )
    (if olderr (setq *error* olderr))
    (setvar "LUPREC" sv_luprec)
    (princ)
  )
  (setq olderr *error*)
  (setq *error* attwidth_error)
              
  (setq sv_luprec (getvar "LUPREC"))
  (setvar "LUPREC" 2)
  (setq incr -0.1);default
  (setq flag
    (getreal (strcat "\nChange in width increment <" (rtos incr) ">: " ))
  )
  (if flag
    (setq incr flag) 
  )
  (while (setq enty (nentsel "\nSelect Attribute: "))
    (setq elis (entget (car enty)))
    (setq owid (cdr (assoc '41 elis)))
    (if (<= (+ owid incr) 0)
      (alert "Width of attribute cannot be less than 0..." )
      (progn
        (setq nwid (cons 41 (+ owid incr)))
        (setq nlis (subst nwid (assoc 41 elis) elis))
        (entmod nlis)
        (entupd (car enty))
      )
    )
  )
  (setvar "LUPREC" sv_luprec)
  (setq *error* olderr)
  (princ)
)
(princ)

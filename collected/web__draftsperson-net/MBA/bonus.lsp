;;;     BONUS.LSP
;;;     Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;     Created 4/22/97 by Randy Kintzley
;;;                   
;;;
;;;     Permission to use, copy, modify, and distribute this software
;;;     for any purpose and without fee is hereby granted, provided
;;;     that the above copyright notice appears in all copies and 
;;;     that both that copyright notice and the limited warranty and 
;;;     restricted rights notice below appear in all supporting 
;;;     documentation.
;;;
;;;     AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.  
;;;     AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF 
;;;     MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC. 
;;;     DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE 
;;;     UNINTERRUPTED OR ERROR FREE.
;;;
;;;     Use, duplication, or disclosure by the U.S. Government is subject to 
;;;     restrictions set forth in FAR 52.227-19 (Commercial Computer 
;;;     Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii) 
;;;     (Rights in Technical Data and Computer Software), as applicable. 
;;;

(defun load_ac_bonus ( / bonus_path add_path a flag flag2 cfg)

 ;Nested function, adds 'dir' argument to AutoCAD search 
 ;path if not already present. 
 ;Returns the AutoCAD search path if the dir argument was added or nil if not.
 (defun add_path ( dir / a b c)
  (if (and dir
           (setq c (getenv "ACAD"))               
      );and
      (progn
       ;prepare to look for 'dir' within the AutoCAD search path
       (setq a (strcase c)
             b (strcase dir) 
       );setq
       (if (not (equal ";" (substr a 1 1)))
           (setq a (strcat ";" a));add a ";" in front of the string if not already present 
       );if
       (if (not (equal ";" (substr a (strlen a) 1)))
           (setq a (strcat a ";")
                 c (strcat c ";");add a trailing ";" if not already present 
           );setq
       );if
       (if (not (wcmatch a (strcat "*;" b ";*"))) ;is 'dir' already present in search path? 
           (progn 
            (setq c (strcat c dir));setq
            (setenv "ACAD" c)
           );progn
           (setq c nil)
       );if   
      );progn then
      (setq c nil)
  );if
  c
 );defun add_path
 
 ;;Begin the work of load_ac_bonus.
 (if (and (wcmatch (getvar "platform") "*Windows NT*")
          (setq cfg (getenv "USERNAME")) 
     );and
     (setq cfg (strcat "AppData/AC_Bonus/" cfg "/bonus_added")) 
     (setq cfg "AppData/AC_Bonus/bonus_added")
 );if

 (setq flag (getcfg cfg))

 (setq flag2 (load "ac_bonus.lsp" "fail"))           ;Attempt to load ac_bonus.lsp.

 (if (and                                                      
      (equal flag2 "fail")                           ;The attempt to load failed and the Bonus files
      (not (equal flag "1"))                         ; have never been loaded before, so go to plan "B"

      (setq a (findfile "acad.exe"))                 ; Build the standard path to the bonus files. 
      (setq          a (substr a 1 (- (strlen a) 8)) 
            bonus_path (strcat a "bonus\\cadtools")         
      );setq
      (findfile bonus_path)                          ; see if the standard bonus directory exists 
      (add_path bonus_path)                          ; attempt to put it on the AutoCAD search path 
     );and
     (setq flag2 (load (strcat bonus_path "\\ac_bonus.lsp") "fail"));Try to load ac_bonus.lsp again.
 );if

 (if (and (not (equal flag "1"))                     ;if we have never loaded bonus files before..
          (not (equal flag2 "fail"))                 ;.. and we had success this time...
     );and
     (setcfg cfg "1")                                ;...then place a flag in the cfg file.  
 );if

(princ)
);defun load_ac_bonus

(load_ac_bonus)

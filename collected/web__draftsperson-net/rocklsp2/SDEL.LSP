  ; Sdel - selectively delete objects by type within a specified area.
  ; Copyright 1991  Rocket Software
  ; Useful even if you don't have leeches in your drawings.
 (DEFUN C:SDEL (/ hi typ are lena txx tt1 pos en)
  (setvar "cmdecho" 0)
  (setq typ ())
  (setq hi (getvar "highlight"))
  (write-line "Stuff to evaluate for deletion (<Enter> for all of one type): ")
  (setq are (ssget))                                    ; get tentative ss
  (if are (setq lena (itoa (sslength are))))
  (if (= (type ttp) 'STR)
      (setq txx (strcat "Entity type to destroy <" ttp ">: "))
      (setq txx "Entity type to destroy: "))
  (setq tt1 (strcase (getstring txx)))
  (if (/= tt1 "") (setq ttp tt1))
  (setq typ (ssget "X" (list (cons 0 ttp))))             ; get all of that type
  (if (and typ are)
      (progn
            (setq pos 0)
            (while (< pos (sslength typ))               ; get intersec. of sets
                   (if (ssmemb (ssname typ pos) are)    ; if in typ and in are
                       (setq pos (1+ pos))              ; then move to next
                       (ssdel (ssname typ pos) typ))    ; else delete from typ
                   (grtext -2 (strcat (itoa (sslength typ)) "/" lena)))))
  (if typ 
         (progn
               (if (= (sslength typ) 1)
                   (setq en " entity")
                   (setq en " entities"))
               (command "erase" typ "")
               (write-line (strcat (itoa (sslength typ))
                                   " " ttp en " eradicated.")))
         (write-line (strcat "No " ttp " entities found.")))
  (setvar "highlight" hi)
  (setq typ () are ())
 (PRINC))
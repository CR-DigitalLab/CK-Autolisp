  ; Batch and script file writer.
  ; Copyright 1991  Rocket software
  ; Requires two files:
  ;       1. A file listing each variable (i.e. drawing name) on a
  ;          separate line, and
  ;       2. a template file with ? at points at which variable names
  ;          are to be inserted.
  ; The template file will be copied into the batch (output) file once for
  ; each variable with successive variables substituted for "?"s in each
  ; repetition of the template.
  ; A line in the template file which is to remain blank must contain a space.
  (DEFUN C:BATCH (/ aa bb cc fbat fv var len ftmp lin pos nn)
   (setvar "cmdecho" 0)
   (setq aa (getstring "Variable file name <Varia.ble>: "))
   (if (= aa "") (setq aa "varia.ble"))
   (setq bb (getstring "Template file name <Template.txt>: "))
   (if (= bb "") (setq bb "template.txt"))
   (setq cc (getstring "Output file name <Fruit.bat>: "))
   (if (= cc "") (setq cc "fruit.bat"))
   (setq fbat (open cc "w"))
   (setq fv (Open aa "r"))
   (while (setq var (read-line fv))
          (setq len (strlen var))
          (setq ftmp (Open bb "r"))
          (while (setq lin (read-line ftmp))
                 (setq pos 1)
                 (while (/= (setq nn (substr lin pos 1)) "")
                        (if (= nn "?")
                            (progn
                                  (setq lin (strcat (substr lin 1 (1- pos))
                                                    var (substr lin (1+ pos))))
                                  (setq pos (+ pos len)))
                                  (setq pos (1+ pos))))
                 (write-line lin fbat))
          (close ftmp)
          (setq ftmp ()))
   (close fbat)
   (close fv)
   (if ftmp (close ftmp))
   (write-line "ok")
   (PRINC))
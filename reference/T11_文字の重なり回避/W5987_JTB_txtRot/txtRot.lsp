;;; By Jimmy Bergmark
;;; Copyright (C) 1997-2012 JTB World, All Rights Reserved
;;; Website: www.jtbworld.com
;;; E-mail: info@jtbworld.com
;;; rotate selected text objects to specified angle

(defun c:txtrot (/ sset i ed ang)
  (if (setq sset (ssget '((-4 . "<OR")
                          (0 . "MTEXT")
                          (0 . "TEXT")
                          (-4 . "OR>")
                         )
                 )
      )
    (progn
      (setq ang (getangle "Specify rotation angle <0>: "))
      (if (null ang)
        (setq ang 0)
      )
      (repeat (setq i (sslength sset))
        (setq ed (entget (ssname sset (setq i (1- i)))))
        (entmod (subst (cons 50 ang)
                       (assoc 50 ed)
                       ed
                )
        )
      )
    )
  )
  (setq sset nil)
  (princ)
)
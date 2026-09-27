;Poloprůhledná maska Mtextu  - www.cadforum.cz

(defun C:TMaskXP (/ ss x ob1 cpy)
 (vl-load-com)
 (setq ss (ssget '((0 . "MTEXT"))))
 (if ss
   (mapcar '(lambda (x)
     (setq ob1 (vlax-ename->vla-object x))
     (setq cpy (vla-copy ob1)) ; copy
     (vla-put-backgroundfill ob1 :vlax-true) ; ON
     (vla-put-backgroundfill cpy :vlax-false) ; OFF
     (vla-put-entitytransparency ob1 50) ; XP level
    )
    (vl-remove-if 'listp (mapcar 'cadr (ssnamex ss)))
   )
 )
 (prin1)
)

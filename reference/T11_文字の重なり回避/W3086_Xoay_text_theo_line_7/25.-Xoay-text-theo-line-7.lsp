(defun c:7(/ ob)(vl-load-com)
    ;Xoay text theo 1 duong dan
    ;Ketxu quick code 25/2
    (cond 
        ((and
            (setq ob (entsel "\n\U+0110\U+1ED1i t\U+01B0\U+1EE3ng d\U+1EABn : "))
            (ssget (list (cons 0 "TEXT,MTEXT")))
        )
        (setq ob (car ob))
        (vlax-for obT (vla-get-ActiveSelectionSet (vla-get-ActiveDocument (vlax-get-acad-object)))
            (vla-put-Rotation 
                obT
                ((lambda(a)(if (and (> a (/ pi 2.)) (<= a (* pi 1.5)))(+ a pi) a))
                (+ (* 0.5 pi)
                (angle     (setq a (vlax-get obT 'InsertionPoint))
                        (vlax-curve-getclosestpointto ob a T)
                )))
            )
        ))
        (T (alert "L\U+1ED7i thao t\U+00E1c!"))
    )
    (princ)
)
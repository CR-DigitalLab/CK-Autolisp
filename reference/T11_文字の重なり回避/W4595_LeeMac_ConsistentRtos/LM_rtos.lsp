;; rtos wrapper  -  Lee Mac
;; A wrapper for the rtos function to negate the effect of DIMZIN

(defun LM:rtos ( real units prec / dimzin result )
    (setq dimzin (getvar 'dimzin))
    (setvar 'dimzin 0)
    (setq result (vl-catch-all-apply 'rtos (list real units prec)))
    (setvar 'dimzin dimzin)
    (if (not (vl-catch-all-error-p result))
        result
    )
)

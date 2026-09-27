(defun c:alinearTexto (/ sset base altura)
  (princ "\nSelecciona todos los textos a alinear: ")
  (setq sset (ssget '((0 . "TEXT,MTEXT")))) ; Permite seleccionar múltiples textos.
  
  (if sset
    (progn
      (princ "\nSelecciona el texto base para la alineación: ")
      (setq base (entsel "\nHaz clic en el texto base: ")) ; Pide al usuario seleccionar el texto base.
      
      (if base
        (progn
          ; Obtiene la altura del texto base seleccionado.
          (setq altura (caDdr (assoc 10 (entget (car base)))))
          
          ; Recorre todos los textos seleccionados.
          (foreach item (vl-remove-if 'listp (mapcar 'cadr (ssnamex sset)))
            (if (not (= item (car base))) ; Evita cambiar la posición del texto base.
              (progn
                (setq ent (entget item))
                (setq pos (assoc 10 ent))
                ; Modifica la posición Y de cada texto.
                (setq newpos (subst (cons 10 (list (car (cdr pos)) altura (caddr pos))) pos ent))
                (entmod newpos)
              )
            )
          )
          (princ "\nTodos los textos han sido alineados.")
        )
        (princ "\nNo se seleccionó texto base.")
      )
    )
    (princ "\nNo se seleccionaron textos.")
  )
  (princ)
)
(princ "www.ingenieriafacil.com, created by Luis Cardenas")
(princ)
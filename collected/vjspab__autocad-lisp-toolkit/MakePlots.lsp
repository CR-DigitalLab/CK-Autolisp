(defun c:MAKEPLOTS ( / oldos pt pw pd totalPlots plotsPerRow i pt1 pt2 pt3 pt4)
  ;; Prompt user for plot dimensions and quantity
  (setq pw (getreal "\nEnter Plot Width (Frontage) [e.g., 5]: "))
  (setq pd (getreal "\nEnter Plot Depth [e.g., 10]: "))
  (setq totalPlots (getint "\nEnter Total Number of Plots [e.g., 40]: "))
  (setq pt (getpoint "\nSelect Insertion Point (Bottom-Left corner of the block): "))

  ;; Proceed only if all inputs are provided
  (if (and pw pd totalPlots pt)
    (progn
      ;; Ensure the number of plots is even for a back-to-back layout
      (if (/= (rem totalPlots 2) 0)
        (progn
          (princ "\nNote: Number of plots is odd. Adding 1 to make it even for a back-to-back layout.")
          (setq totalPlots (1+ totalPlots))
        )
      )
      
      (setq plotsPerRow (/ totalPlots 2))

      ;; Start undo group and disable Object Snaps temporarily so lines draw cleanly
      (command "_.UNDO" "_BE")
      (setq oldos (getvar "OSMODE"))
      (setvar "OSMODE" 0)

      (setq i 0)
      ;; Loop to draw the plots
      (while (< i plotsPerRow)
        ;; Draw Bottom Row Plot
        (setq pt1 (list (+ (car pt) (* i pw)) (cadr pt) 0.0))
        (setq pt2 (list (+ (car pt1) pw) (+ (cadr pt1) pd) 0.0))
        (command "_.RECTANG" pt1 pt2)

        ;; Draw Top Row Plot (Back-to-back)
        (setq pt3 (list (+ (car pt) (* i pw)) (+ (cadr pt) pd) 0.0))
        (setq pt4 (list (+ (car pt3) pw) (+ (cadr pt3) pd) 0.0))
        (command "_.RECTANG" pt3 pt4)

        (setq i (1+ i))
      )

      ;; Restore Object Snaps and end undo group
      (setvar "OSMODE" oldos)
      (command "_.UNDO" "_E")
      (princ (strcat "\nSuccessfully generated " (itoa totalPlots) " plots!"))
    )
    (princ "\nInput missing, command cancelled.")
  )
  (princ)
)
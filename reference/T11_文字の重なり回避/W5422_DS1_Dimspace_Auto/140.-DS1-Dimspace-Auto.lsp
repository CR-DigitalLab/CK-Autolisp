
;;Dimspace trường hợp người dùng nhập hoặc kéo điểm chọn kích thước
(defun c:DS1 (/ default_ratio default_space dbase dsp)
	(setq default_ratio 2) ; giá trị hệ số mặc định ban đầu (người dùng tự thay đổi giá trị này được)
	(if (/= 0.0 (getvar "dimscale"))
		(setq default_space (* (getvar "dimscale") default_ratio)) ; giá trị space mặc định ban đầu cho dim space là dimscale hiện hành nhân hệ số mặc định
		(setq default_space 500.0) ;nếu không may dimcale hiện hành = 0 thì gán tạm cho space là 500 (người dùng tự thay đổi giá trị này được)
	)
	(if (and (setq space (cond ( (getdist (strcat "\nEnter space distance: <" (rtos (setq space (cond ( space ) ( default_space )))) ">: "))) ( space )))
			(setq dbase (car (entsel "\nSelect Base Dimension: ")))
			(setq dsp (ssget "_:L" '((0 . "DIMENSION"))))
		)
		(command "dimspace" dbase dsp "" space)
		(princ "\n: --> Command cancelled ! \n")

	)
	(princ)
)
(princ "\n >> -------- Type \" DS1 \" to invoke command -------- << \n")
(princ)

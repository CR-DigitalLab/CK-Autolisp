(defun pos(mychar myline / x flag)
	(setq x 1)
	(setq flag 0)
	(while (< x (strlen myline))
		(if (and (= flag 0) (= mychar (substr myline x 1))) (setq flag x) )
		(setq x (+ x 1))
	)
	(setq flag flag)
)

(defun parse(Mydelimiter MyItemNo MyString / x)
	(setq x 1)
	(while (< x MyItemNo)
		(setq Mystring (substr Mystring (+ (pos mydelimiter mystring) 1)))
		(setq x (+ x 1))
	)
	(If (> (pos mydelimiter mystring) 0) 
	(setq Mystring (substr Mystring 1 (- (pos mydelimiter mystring) 1)))
	(setq mystring mystring)
	)

)

(defun c:graph()
	(princ "\nSuper graph program for AutoCAD by Denton, requires comma delimited file of values:")
	(princ "\nUses the line number for the X-value:")
	(setq p1 (getpoint "\nPick bottom left fcorner of graph:"))
	(setq xl (getdist p1 "\nEnter graph max length:"))
	(setq yl (getdist p1 "\nEnter graph max height:"))
	(setq gx (getdist p1 "\nEnter grid X interval:"))
	(setq gy (getdist p1 "\nEnter grid Y interval:"))
	(setq yscale (getreal "\nEnter data scaling factor:"))
	
	(setq fname (getfiled "File to Graph" "" "*" 0))
	
	(setq oldmode (getvar "osmode"))
	(setvar "osmode" 0)
	
	
	(setq passes (getint "\nNumber of columns of data? "))
	
	
	(command "-layer" "m" "Graph" "")
	(command "pline" p1 (strcat "@" (rtos xl) "<0") 
		(strcat "@" (rtos (* yl yscale)) "<90") 
		(strcat "@" (rtos xl) "<180") 
		"c")

	(command "-layer" "m" "Graph-grid" "c" "8" "" "")

	;;; produce x-grid
	(setq x gx)
	(while (< x xl)
		(command "line" (polar p1 0 x) (strcat "@" (rtos (* yl yscale)) "<90") "")
		;; add text label here...
		(setq x (+ x gx))
	)

	;;; produce y-grid
	(setq y gy)
	(while (< y yl)
		(command "line" (polar p1 (/ pi 2.0) (* y yscale)) (strcat "@" (rtos xl) "<0") "")
		;; add text label here...
		(setq y (+ y gy))
	)
	
	;;; loop for data
	(setq item 1)
	(while (<= item passes)
		(command "-layer" "m" (strcat "GraphData-" (itoa item)) "c" (itoa item) "" "")
		(setq ifile (open fname "r"))

		(command "pline")
		(setq x 0)
		(while (setq myline (read-line ifile))
			(setq x (+ x 1))
			(princ "\n")
			(princ myline)
			(setq y (atof (parse "," item myline)))
			(command (polar (polar p1 0 x) (/ pi 2.0) (* y yscale)))
		)
		(command "")
		(close ifile)
		(setq item (+ item 1))
	
	)
	
	(setvar "osmode" oldmode)
(princ)
)
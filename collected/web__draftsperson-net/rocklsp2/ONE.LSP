  ; One: convert a numeral to its English equivalent.
  ; Copyright 1992  Rocket Software
  ; Useful for convincing alien life forms that you are not edible.
 (defun C:ONE (/ cycle whole nos set2 set3 set4
                          str last3 strn one two thr lne num ok)
  (setvar "cmdecho" 0)
  (setq cycle 0)
  (setq whole "")
  (setq nos (list "" "one" "two" "three" "four"
                   "five" "six" "seven" "eight" "nine"))
  (setq set2 (list "ten" "eleven" "twelve" "thirteen" "fourteen"
                   "fifteen" "sixteen" "seventeen" "eighteen" "nineteen"))
  (setq set3 (list "" "" "twenty" "thirty" "forty" "fifty" "sixty"
                   "seventy" "eighty" "ninety"))
  (setq set4 (list "" "thousand" "million" "billion" "trillion" "quadrillion"
                   "pentillion" "hexillion" "heptillion" "octillion"
                   "nonillion" "decillion" "zillion" "bazillion"))
  (setq str (cdr (assoc 1 (entget (car (entsel "Select text:\n"))))))
  (while (> (strlen str) 0)
  (while (< (strlen str) 3) (setq str (strcat "0" str)))
  (setq last3 (substr str (- (strlen str) 2)))
  (if (> (strlen str) 3) (setq str (substr str 1 (- (strlen str) 3)))
                         (setq str ""))
; ********************* Process next three *********************
  (setq strn "")
  (setq one (substr last3 1 1))
  (setq two (substr last3 2 1))
  (setq thr (substr last3 3 1))
  (if (/= one "0") (setq strn (strcat (nth (read one) nos) " hundred")))
  (cond ((= two "1") (setq strn (strcat strn 
                                        (if (/= strn "") " and " "")
                                        (nth (read thr) set2))))
        ((= two "0"))
        (t (setq strn (strcat strn 
                              (if (= strn "") "" " and ")
                              (nth (read two) set3)))))
  (if (/= two "1")
      (setq strn (strcat strn
                   (if (and (/= strn "") (= two "0") (/= thr "0")) " and " "")
                   (if (and (/= strn "") (/= two "0") (/= two "1")) " " "")
                   (nth (read thr) nos))))
; ***** add "and" for example in one thousand and sixty two but not in 0062.
  (if (and (/= str "") (= one "0") (/= strn ""))
      (progn
            (setq lne (strlen str))
            (setq num 1)
            (setq ok ())
            (while (<= num lne)
                   (if (/= (substr str num 1) "0") (setq ok t))
                   (setq num (1+ num)))
            (if ok (setq strn (strcat "and " strn)))))
; ********************* Process three End *********************
  (setq whole (strcat strn 
                      (if (= strn "")
                          "" 
                          (strcat " " (nth cycle set4) " "))
                      whole))
  (setq cycle (1+ cycle)))
  (write-line whole)
  (princ))
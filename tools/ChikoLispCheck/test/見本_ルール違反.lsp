(defun *error* (msg) (princ msg))

(defun dtr (a) (* pi (/ a 180.0)))
(defun unused-helper () (princ "nobody calls me"))

;; TODO: あとで消す
(defun c:MOVELINE (/ ss e ed)
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  (setq ss (ssget))
  (setq e (ssname ss 0) ed (entget e))
  (entmod (subst (cons 8 "0") (assoc 8 ed) ed))
  (command "LINE" '(0 0) '(10 10) "")
  (command "_.PURGE" "_A" "*" "N")
  (setq count (sslength ss))
  (acet-ss-drag-move ss '(0 0))
  (setq f (open "C:\\Users\\taro\\Documents\\log.txt" "w" "utf8"))
  (princ "連絡先 taro@example.co.jp" f)
  (close f)
)

(defun c:CO () (command "_.COPY" pause "" pause pause))
(defun c:BOX3D () (command "_.BOX" '(0 0 0) '(10 10 10)))

(defun benchmark

;;;=================================================================
;;;
;;;  Benchmark.lsp | © 2005 Michael Puckett | All Rights Reserved
;;;
;;;=================================================================
;;;
;;;  Purpose:
;;;
;;;      Compare the performance of various statements.
;;;
;;;  Notes:
;;;
;;;      I make no claims that this is definitive benchmarking. I
;;;      wrote this utility for my own purposes and thought I'd
;;;      share it. Many considerations go into evaluating the
;;;      performance or suitability of an algorythm for a given
;;;      task. Raw performance as profiled herein is just one.
;;;
;;;      Please note that background dramatically affect results.
;;;
;;;  Disclaimer:
;;;
;;;      This program is flawed in one or more ways and is not fit
;;;      for any particular purpose, stated or implied. Use at your
;;;      own risk.
;;;
;;;=================================================================
;;;
;;;  Syntax:
;;;
;;;      (Benchmark statements)
;;;
;;;          Where statements is a quoted list of statements.
;;;
;;;=================================================================
;;;
;;;  Example:
;;;
;;;      (BenchMark
;;;         '(
;;;              (1+ 1)
;;;              (+ 1 1)
;;;              (+ 1 1.0)
;;;              (+ 1.0 1.0)
;;;          )
;;;      )
;;;
;;;=================================================================
;;;
;;;  Output:
;;;
;;;      Elapsed milliseconds / relative speed for 32768 iteration(s):
;;;
;;;          (1+ 1)..........1969 / 1.09 <fastest>
;;;          (+ 1 1).........2078 / 1.03
;;;          (+ 1 1.0).......2125 / 1.01
;;;          (+ 1.0 1.0).....2140 / 1.00 <slowest>
;;;
;;;=================================================================

                 (statements / _lset _rset _tostring _eval _princ _main)

;;;=================================================================
;;;
;;;  (_LSet text len fillChar)
;;;
;;;=================================================================

 (defun _lset (text len fillchar / padding result)
  (setq
   padding (list (ascii fillchar))
   result  (vl-string->list text)
  ) ;_  setq
  (while
   (< (length
       (setq padding
             (append padding padding)
       ) ;_  setq
      ) ;_  length
      len
   ) ;_  <
  ) ;_  while
  (while
   (< (length
       (setq result
             (append result padding)
       ) ;_  setq
      ) ;_  length
      len
   ) ;_  <
  ) ;_  while
  (substr (vl-list->string result) 1 len)
 ) ;_  defun
;;;=================================================================
;;;
;;;  (_RSet text len fillChar)
;;;
;;;=================================================================

 (defun _rset (text len fillchar / padding result)
  (setq
   padding (list (ascii fillchar))
   result  (vl-string->list text)
  ) ;_  setq
  (while
   (< (length
       (setq padding
             (append padding padding)
       ) ;_  setq
      ) ;_  length
      len
   ) ;_  <
  ) ;_  while
  (while
   (< (length
       (setq result
             (append padding result)
       ) ;_  setq
      ) ;_  length
      len
   ) ;_  <
  ) ;_  while
  (substr
   (vl-list->string result)
   (1+ (- (length result) len))
  ) ;_  substr
 ) ;_  defun

;;;=================================================================
;;;
;;;  (_ToString x)
;;;
;;;=================================================================

 (defun _tostring (x / result)
  (if
   (< (strlen
       (setq result
             (vl-prin1-to-string x)
       ) ;_  setq
      ) ;_  strlen
      40
   ) ;_  <
   result
   (strcat (substr result 1 36) "..." (chr 41))
  ) ;_  if
 ) ;_  defun
;;;=================================================================
;;;
;;;  (_Eval statement iterations)
;;;
;;;=================================================================
 (defun _eval (statement iterations / start)
  (gc)
  (setq start (getvar "millisecs"))
  (repeat iterations (eval statement))
  (- (getvar "millisecs") start)
 ) ;_  defun

;;;=================================================================
;;;
;;;  (_Princ x)
;;;
;;;=================================================================

 (defun _princ (x)
  (princ x)
  (princ)
;;; forces screen update
 ) ;_  defun
;;;=================================================================
;;;
;;;  (_Main statements)
;;;
;;;=================================================================

 (defun _main

        (statements / boundary iterations timings slowest fastest lsetlen rsetlen index count)

  (setq
   boundary 1000
   iterations 1
  ) ;_  setq
  (_princ "Benchmarking ...")
  (while
   (or
    (< (apply 'max
              (setq timings
                    (mapcar
                     '(lambda (statement)
                       (_eval statement iterations)
                      ) ;_  lambda
                     statements
                    ) ;_  mapcar
              ) ;_  setq
       ) ;_  apply
       boundary
    ) ;_  <
    (< (apply 'min timings)
       boundary
    ) ;_  <
   ) ;_  or
   (setq iterations
         (* 2 iterations)
   ) ;_  setq
   (_princ ".")
  ) ;_  while
  (_princ
   (strcat
    "\rElapsed milliseconds / relative speed for "
    (itoa iterations)
    " iteration(s):\n\n"
   ) ;_  strcat
  ) ;_  _princ
  (setq
   slowest (float (apply 'max timings))
   fastest (apply 'min timings)
  ) ;_  setq
  (setq lsetlen
        (+ 5
           (apply 'max
                  (mapcar (function strlen)
                          (setq statements
                                (mapcar (function _tostring)
                                        statements
                                ) ;_  mapcar
                          ) ;_  setq
                  ) ;_  mapcar
           ) ;_  apply
        ) ;_  +
  ) ;_  setq
  (setq rsetlen
        (apply 'max
               (mapcar
                '(lambda (ms) (strlen (itoa ms)))
                timings
               ) ;_  mapcar
        ) ;_  apply
  ) ;_  setq

  (setq
   index 0
   count (length statements)
  ) ;_  setq
  (foreach pair

                (vl-sort
                 (mapcar 'cons statements timings)
                 '(lambda (a b) (< (cdr a) (cdr b)))
                ) ;_  vl-sort
   ((lambda (pair / ms)
     (_princ
      (strcat
       "    "
       (_lset (car pair) lsetlen ".")
       (_rset
        (itoa (setq ms (cdr pair)))
        rsetlen
        "."
       ) ;_  _rset
       " / "
       (rtos (/ slowest ms) 2 2)
       (cond
        ((eq 1 (setq index (1+ index))) " <fastest>")
        ((eq index count) " <slowest>")
        ("")
       ) ;_  cond
       "\n"
      ) ;_  strcat
     ) ;_  _princ
    ) ;_  lambda
    pair
   )
  ) ;_  foreach
  (princ)
 ) ;_  defun
;;;=================================================================
;;;
;;;  Program is defined, let's rock and roll ...
;;;
;;;=================================================================

 (_main statements)

) ;_  defun
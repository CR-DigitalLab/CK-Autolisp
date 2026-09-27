;Modify the text justification of a selection set of attributes. (uses UKWORD UPOINT)
;The only input required is the desired text justification and selection of the
;attributes to modify.  There is no need to worry about selecting non-attribute
;entities because they will be automatically filtered out of the selection set.
;DO NOT select more than one "common note group".  All of the attributes selected
;are assumed to belong to such a group and they ALL will be justified to the same
;reference position.
;
;	AUTHOR: HENRY C. FRANCIS
;		425 N. ASHE ST.
;		SOUTHERN PINES, NC 28387
;              
;		All rights reserved without prejudice.
;
;	Copyright:	7-12-94
;	Edited:		11-26-95
;
(defun c:attxtj ( / tsln cntr xofbl tj10 tj11 tj72 tj74 tset tent enty entz)
(setq tjst
  (ukword 1 "Align Fit Left Center Middle Right TL TC TR ML MC MR BL BC BR" "Align/Fit/Left/Center/Middle/Right/TL/TC/TR/ML/MC/MR/BL/BC/BR" (if tjst tjst "L"))
);setq
(setq inplace (ukword 1 "In To" "In place or To line?" (if inplace inplace "T")))
(setq attr_sel (nentsel "\nSelect Attribute: "))
    (setq tsln 1)
    (cond
      ((eq (substr tjst 1 1) "A")
        (if (> tsln 1)
          (progn
            (prompt "\nSelect only one text string!")
            (setq tset nil)
          );progn
          (setq tj72 3
                tj74 0
                tj10 (upoint 1 "" "\nFirst Align point" nil nil)
                tj11 (upoint 1 "" "\nSecond Align point" nil nil)
          );setq
        );if
      )
      ((eq (substr tjst 1 1) "F")
        (if (> tsln 1)
          (progn
            (prompt "\nSelect only one text string!")
            (setq tset nil)
          );progn
          (setq tj72 5
                tj74 0
                tj10 (upoint 1 "" "\nFirst Fit point" nil nil)
                tj11 (upoint 1 "" "\nSecond Fit point" nil nil)
          );setq
        );if
      )
      ((eq (substr tjst 1 1) "L")
        (setq tj72 0
              tj74 0
              tj10 (if(eq inplace "In")T(upoint 1 "" "\nLeft justification line" nil nil))
              tj11 (list 0.0 0.0 0.0)
        );setq
      )
      ((eq (substr tjst 1 1) "C")
        (setq tj72 1
              tj74 0
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nCenter justification line" nil nil))
        );setq
      )
      ((and(eq (substr tjst 1 1) "M")(not(eq(strlen tjst)2)))
        (setq tj72 4
              tj74 0
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nMiddle justification line" nil nil))
        );setq
      )
      ((eq (substr tjst 1 1) "R")
        (setq tj72 2
              tj74 0
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nRight justification line" nil nil))
        );setq
      )
      ((eq tjst "TL")
        (setq tj72 0
              tj74 3
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nTop Left justification line" nil nil))
        );setq
      )
      ((eq tjst "ML")
        (setq tj72 0
              tj74 2
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nMiddle Left justification line" nil nil))
        );setq
      )
      ((eq tjst "BL")
        (setq tj72 0
              tj74 1
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nBottom Left justification line" nil nil))
        );setq
      )
      ((eq tjst "TC")
        (setq tj72 1
              tj74 3
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nTop Center justification line" nil nil))
        );setq
      )
      ((eq tjst "MC")
        (setq tj72 1
              tj74 2
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nMiddle Center justification line" nil nil))
        );setq
      )
      ((eq tjst "BC")
        (setq tj72 1
              tj74 1
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nBottom Center justification line" nil nil))
        );setq
      )
      ((eq tjst "TR")
        (setq tj72 2
              tj74 3
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nTop Right justification line" nil nil))
        );setq
      )
      ((eq tjst "MR")
        (setq tj72 2
              tj74 2
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nMiddle Right justification line" nil nil))
        );setq
      )
      ((eq tjst "BR")
        (setq tj72 2
              tj74 1
              tj10 nil
              tj11 (if(eq inplace "In")T(upoint 1 "" "\nBottom Right justification line" nil nil))
        );setq
      )
    );cond
  (setq tent (entget (car attr_sel)))
  (progn
    (setq edtw (entget (cdar tent)))
    (if (eq(cdr(assoc 0 edtw))"ATTRIB")
      (progn
        (setq
              ent72 (cdr (assoc 72 edtw))
              ent74 (cdr (assoc 74 edtw))
              ent0y (caddr(assoc 10 edtw))
              ent0z (cadddr(assoc 10 edtw))
        )
        (if(eq tj11 T)
          (if (equal (list 0.0 0.0) (list(cadr(assoc 11 edtw))(caddr(assoc 11 edtw)))0.1)
                (setq tj11x (cadr(assoc 10 edtw))
                      tj11y (caddr(assoc 10 edtw))
                      tj11z (cadddr(assoc 10 edtw))
                )
                (setq tj11x (cadr(assoc 11 edtw))
                      tj11y (caddr(assoc 11 edtw))
                      tj11z (cadddr(assoc 11 edtw))
                )
          )
          (setq tj11x (car (trans tj11 1 (cdar tent)))
                tj11y (cadr (trans tj11 1 (cdar tent)))
                tj11z (caddr (trans tj11 1 (cdar tent)))
          );setq
        )
        (setq edtw
          (subst (cons 72 tj72)
                 (assoc 72 edtw)
                 edtw
          )
        );setq
        (setq edtw
          (subst (cons 74 tj74)
                 (assoc 74 edtw)
                 edtw
          )
        );setq
        (cond
          ((eq (substr tjst 1 1) "L")
            (setq edtw
              (subst (list 11 0.0 0.0 0.0)
                     (assoc 11 edtw)
                     edtw
              )
            );setq
            (if(eq tj10 T)
              nil
              (progn
                (setq tj10x (car (trans tj10 1 (cdar tent)))
                      edtw
                  (subst (list 10 tj10x ent0y ent0z)
                         (assoc 10 edtw)
                         edtw
                  )
                );setq
              )
            )
          )
          ((not(or(eq (substr tjst 1 1) "A")(eq (substr tjst 1 1) "F")))
            (if (eq tj11 T)
              (progn
                (setq edtw
                  (subst (list 11 tj11x tj11y tj11z)
                         (assoc 11 edtw)
                         edtw
                  )
                );setq
              )
              (setq edtw
                (subst (list 11 tj11x ent0y ent0z)
                       (assoc 11 edtw)
                       edtw
                )
              );setq
            )
          )
          ((or(eq (substr tjst 1 1) "A")(eq (substr tjst 1 1) "F"))
            (setq edtw
              (subst (list 11 tj11x tj11y tj11z)
                     (assoc 11 edtw)
                     edtw
              )
            );setq
            (if(eq tj10 T)
              nil
              (progn
                (setq tj10x (car (trans tj10 1 (cdar tent)))
                      tj10y (cadr (trans tj10 1 (cdar tent)))
                      tj10z (caddr (trans tj10 1 (cdar tent)))
                      edtw
                  (subst (list 10 tj10x tj10y tj10z)
                         (assoc 10 edtw)
                         edtw
                  )
                );setq
              )
            )
          )
        );cond
        (entmod edtw)
	(entupd (cdar tent))
      )
      (princ (cdr(assoc 0 edtw)))
    )
  )
);defun

;/////////////////////////////////////////
;JagaimoLisp コマンド関数
;テキストチェンジ　var.20210907
;---------------------------------------

(defun c:JagaMask1 () (JagaimoLispTxMask 1))
(defun c:JagaMask2 () (JagaimoLispTxMask 2))

(defun c:JagaMask0 () (JagaimoLispTxMask 0))

(defun c:JagaMask () (JagaimoLispTxMask (getreal "Mask Size:")))


;/////////////////////////////////////////

;=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;JagaimoLisp関数 【JagaimoLispTxMask】背景マスク
;----------------------------------------------
;<引数>　MaskSize 　背景マスクサイズ (0はマスク無し）
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
(defun JagaimoLispTxMask (MaskSize / *error* OBJs ObjNum Cnt JagaTxMskEnd JagaTxMskErr OldCmdEcho OldDynMode)
  
    (setq DefError *error* *error* JagaTxMskErr)
    (setq OldCmdEcho (getvar "CMDECHO"))
    (setvar "CMDECHO" 0)
    (command-s "undo" "be")
    (setq OldDynMode (getvar "DYNMODE"))	
      (setvar "DYNMODE" 3) 
;----------------------------------------------
  (defun JagaTxMskEnd()
    (command-s "undo" "end")
    (setvar "filedia" 1)
    (setq *error* DefError)
    (setvar "CMDECHO" OldCmdEcho)
    (setvar "DYNMODE" OldDynMode)
  (princ "\n=========== JagaimoLISP.com ===========")
  (princ));defun
;----------------------------------------------
  (defun JagaTxMskErr (msg)	
    (JagaTxMskEND)
  (princ "\nJagaTxMskErr\n")
  (princ msg)
  (princ));defun	
;----------------------------------------------
  
  	(setq OBJs (ssget "I" '((0 . "TEXT,MTEXT"))))	
      (if (null OBJs)
        (setq OBJs (ssget '((0 . "TEXT,MTEXT"))))
      );if
      
	(setq ObjNum (sslength OBJs))
		(setq Cnt 0)
  
(if (= 0 MaskSize)
  (progn
    (while (< Cnt ObjNum)	

    (setq OBJ (ssname OBJs Cnt))
      (vla-put-backgroundfill (vlax-ename->vla-object OBJ) 0)

      (setq Cnt (+ Cnt 1))
    );while
  
  );progn
  (progn
  	(while (< Cnt ObjNum)
	
      (setq OBJ (ssname OBJs Cnt))
      (setq Ent (entget OBJ))
        (if (= "TEXT" (cdr(assoc 0 ENT))) 
          (progn 
            (command-s "TXT2MTXT" OBJ "")
            (setq Ent (entget (entlast)))
        ));progn if
    
        (setq Ent (append Ent (list (cons 90 3))))
        (setq Ent (append Ent (list (cons 45 MaskSize))))
      (entmod Ent)
        
      (setq Cnt (+ Cnt 1))
	 );while
 );progn
);if		
  
  
 (JagaTxMskEND) 
(princ));defun

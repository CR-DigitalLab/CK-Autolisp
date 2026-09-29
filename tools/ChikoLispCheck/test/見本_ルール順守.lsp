;;; ============================================================
;;;  GoodSample.lsp  ― ChikoLispCheck の動作確認用（ルールを守った見本）
;;;  コマンド：GOODSAMPLE（ショートカット GS）：選んだ図形を画層 0 に移し、線を1本引く
;;;  版：1.0.0（2026-09-29）
;;;  作者：チコ
;;;  利用条件：自由に使ってかまいません。再配布は禁止。使用は自己責任でお願いします。
;;; ============================================================
(vl-load-com)

(defun gs:restore (vals) (mapcar 'setvar '("CMDECHO" "OSMODE") vals))

(defun c:GOODSAMPLE ( / *error* doc old ss i e ed n)
  (defun *error* (msg)
    (if old (gs:restore old))
    (if doc (vla-EndUndoMark doc))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\n[GS] エラー: " msg)))
    (princ))
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        old (mapcar 'getvar '("CMDECHO" "OSMODE")))
  (vla-StartUndoMark doc)
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  (if (setq ss (ssget "_:L"))
    (progn
      (setq i 0 n (sslength ss))
      (repeat n
        (setq e (ssname ss i) ed (entget e) i (1+ i))
        (entmod (subst (cons 8 "0") (assoc 8 ed) ed)))
      (command "_.LINE" "_non" '(0 0) "_non" '(10 10) "")
      (princ (strcat "\n[GS] " (itoa n) " 個を画層 0 に移しました。")))
    (princ "\n[GS] 何も選ばれませんでした。"))
  (gs:restore old)
  (vla-EndUndoMark doc)
  (princ))

(defun c:GS ( ) (c:GOODSAMPLE))

(princ "\n[GoodSample 1.0.0] 読み込み完了  GOODSAMPLE(GS)")
(princ)

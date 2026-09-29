;;; ============================================================
;;;  SaveVersion.lsp  ― 図面を「今の形式のまま」上書き保存
;;;  コマンド：SAVEVERSION（ショートカット SV）
;;;  2010形式のDWGなら2010形式のDWG、DXFなら同じ版のDXFで上書き保存する。
;;;  対応：AutoCAD 2027（AutoCAD LT 2024 以降でも使える作り）
;;;  作成：チコ ／ 2026-09-29
;;; ============================================================
(vl-load-com)

(setq *sv:version* "1.0.0")

;;; 形式の一覧：(ファイルの形式コード 名前 DWGの保存番号 DXFの保存番号)
;;; 保存番号は AutoCAD の「名前を付けて保存」の形式番号（ActiveX の AcSaveAsType）
(setq *sv:types*
  '(("AC1009" "R12"  nil 1)
    ("AC1015" "2000" 12  13)
    ("AC1018" "2004" 24  25)
    ("AC1021" "2007" 36  37)
    ("AC1024" "2010" 48  49)
    ("AC1027" "2013" 60  61)
    ("AC1032" "2018" 64  65)))

;;; 保存できない古い形式の名前
(setq *sv:oldnames*
  '(("AC1006" . "R10") ("AC1009" . "R12") ("AC1012" . "R13") ("AC1014" . "R14")))

;;; 今の図面の場所（フォルダ＋ファイル名）
(defun sv:path ( )
  (strcat (getvar "DWGPREFIX") (getvar "DWGNAME")))

;;; ファイルの種類："DWG" / "DXF" / nil（テンプレートなどは nil）
(defun sv:kind (path / ext)
  (setq ext (strcase (cond ((vl-filename-extension path)) (""))))
  (cond ((= ext ".DWG") "DWG")
        ((= ext ".DXF") "DXF")))

;;; ファイルを読んで形式を調べる → "AC1024" などの形式コード / "BIN"（バイナリDXF）/ nil
(defun sv:read-format (path kind / f code line n c s)
  (if (and path kind (findfile path) (setq f (open path "r")))
    (progn
      (if (= kind "DXF")
        ;; DXF：先頭の「$ACADVER」の次の値が形式コード
        (progn
          (setq line (read-line f) n 0)
          (if (and line (wcmatch line "AutoCAD Binary DXF*"))
            (setq code "BIN")
            (while (and line (not code) (< n 5000))
              (if (= (vl-string-trim " \t" line) "$ACADVER")
                (progn
                  (read-line f)                                  ; グループコード（1）
                  (setq line (read-line f))
                  (if (and line (wcmatch (setq line (vl-string-trim " \t" line)) "AC10##"))
                    (setq code line))))
              (setq line (read-line f) n (1+ n)))))
        ;; DWG：ファイルの先頭6文字が形式コード
        (progn
          (setq s "" n 0)
          (while (and (< n 6) (setq c (read-char f)))
            (setq s (strcat s (chr c)) n (1+ n)))
          (if (wcmatch s "AC10##") (setq code s))))
      (close f)
      code)))

;;; 形式の表示名（例：「2010形式のDWG」「R12形式のDXF」）
(defun sv:label (code kind / info)
  (cond
    ((= code "BIN") "バイナリ形式のDXF")
    ((setq info (assoc code *sv:types*)) (strcat (cadr info) "形式の" kind))
    ((setq info (assoc code *sv:oldnames*)) (strcat (cdr info) "形式の" kind))
    (T (strcat code "（不明な形式）の" kind))))

;;; 開いたときの形式を覚えておく（読み込んだときに1回だけ）
;;; LISP の変数は図面ごとに別々なので、図面ごとに覚えられる
(defun sv:remember ( / path)
  (if (and (= (getvar "DWGTITLED") 1) (null *sv:open*))
    (progn
      (setq path (sv:path))
      (setq *sv:open* (cons path (sv:read-format path (sv:kind path)))))))

;;; ------------------------------------------------------------
;;;  メイン
;;; ------------------------------------------------------------
(defun c:SAVEVERSION ( / *error* path kind mem disk code info type res after note)

  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\n[SV] エラー: " msg)))
    (princ))

  (cond
    ((/= (getvar "DWGTITLED") 1)
     (princ "\n[SV] まだ一度も保存していない図面です。先に「名前を付けて保存」をしてください。"))
    ((= (getvar "WRITESTAT") 0)
     (princ "\n[SV] 読み取り専用で開いている図面のため、上書き保存できません。"))
    ((null (setq path (sv:path) kind (sv:kind path)))
     (princ "\n[SV] DWG・DXF 以外（テンプレートなど）は対象外です。"))
    (T
     ;; 形式を決める：開いたときに覚えた形式を優先。無ければ今のファイルから読む
     (setq disk (sv:read-format path kind))
     (if (and *sv:open* (= (strcase (car *sv:open*)) (strcase path)))
       (setq mem (cdr *sv:open*)))
     (setq code (cond (mem) (disk)))
     (cond
       ((null code)
        (princ "\n[SV] ファイルの形式を読み取れませんでした。保存していません。")
        (princ "\n     「名前を付けて保存」で形式を選んで保存してください。"))
       ((= code "BIN")
        (princ "\n[SV] バイナリ形式のDXFには対応していません。保存していません。")
        (princ "\n     「名前を付けて保存」で形式を選んで保存してください。"))
       ((null (setq info (assoc code *sv:types*)
                    type (if info (if (= kind "DXF") (cadddr info) (caddr info)))))
        (princ (strcat "\n[SV] " (sv:label code kind) "は、この AutoCAD では保存できない形式です。保存していません。")))
       (T
        (setq res (vl-catch-all-apply 'vla-SaveAs
                    (list (vla-get-ActiveDocument (vlax-get-acad-object)) path type)))
        (if (vl-catch-all-error-p res)
          (princ (strcat "\n[SV] 保存できませんでした：" (vl-catch-all-error-message res)
                         "\n     ほかの人が使用中・書き込み禁止の場所などの可能性があります。"))
          (progn
            (setq after (sv:read-format path kind)
                  *sv:open* (cons path code))
            (if (and mem disk (/= mem disk))
              (setq note (strcat "\n     （途中の上書き保存で" (sv:label disk kind)
                                 "に変わっていたのを、開いたときの形式に戻しました）"))
              (setq note ""))
            (if (= after code)
              (princ (strcat "\n[SV] " (sv:label code kind) "のまま上書き保存しました。" note))
              (princ (strcat "\n[SV] " (sv:label code kind) "で上書き保存しましたが、"
                             "保存後の形式を確認できませんでした。" note))))))))
    )
  (princ))

(defun c:SV ( ) (c:SAVEVERSION))

;;; 読み込んだときに、この図面の形式を覚えて表示する
(vl-catch-all-apply 'sv:remember nil)
(princ (strcat "\n[SaveVersion " *sv:version* "] 読み込み完了  SAVEVERSION(SV)＝今の形式のまま上書き保存"
               (if (and *sv:open* (cdr *sv:open*))
                 (strcat "（この図面：" (sv:label (cdr *sv:open*) (sv:kind (car *sv:open*))) "）")
                 "")))
(princ)

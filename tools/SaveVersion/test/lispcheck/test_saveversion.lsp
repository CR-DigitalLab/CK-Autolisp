;;; SaveVersion の lispcheck 用テスト
;;; 実行: python tools/lispcheck/lispcheck.py run tools/SaveVersion/SaveVersion.lsp tools/SaveVersion/test/lispcheck/test_saveversion.lsp
;;; 仮想ファイル（C:\\案件\\…）に DWG・DXF の先頭部分だけを書いて、いろいろな形式の図面を再現する

(defun t:write (path txt / f) (setq f (open path "w")) (princ txt f) (close f) path)
(defun t:dwg (path code) (t:write path (strcat code "（DWGの中身）")))
(defun t:dxf (path code)
  (t:write path (strcat "  0\nSECTION\n  2\nHEADER\n  9\n$ACADVER\n  1\n" code "\n  0\nENDSEC\n  0\nEOF\n")))
;; 図面を開いたことにする（開いたときの形式を覚える＝スタートアップで読み込んだのと同じ）
(defun t:open (path flags)
  (lc:docs (list (cons path flags)))
  (setq *sv:open* nil)
  (sv:remember))
(defun t:fmt (path) (sv:read-format path (sv:kind path)))

;;; 1. DWG の各形式 → 同じ形式で保存
(princ "\n\n===== 1. DWG の各形式 =====")
(foreach c '(("AC1015" . "2000") ("AC1018" . "2004") ("AC1021" . "2007") ("AC1024" . "2010") ("AC1027" . "2013") ("AC1032" . "2018"))
  (setq p (strcat "C:\\案件\\" (cdr c) "形式.dwg"))
  (t:dwg p (car c))
  (t:open p nil)
  (c:SV)
  (lc:assert-equal (t:fmt p) (car c) (strcat "1: " (cdr c) "形式のDWGのまま")))

;;; 2. DXF の各形式（R12 も）
(princ "\n\n===== 2. DXF の各形式 =====")
(foreach c '(("AC1009" . "R12") ("AC1015" . "2000") ("AC1024" . "2010") ("AC1032" . "2018"))
  (setq p (strcat "C:\\案件\\" (cdr c) "形式.DXF"))          ; 拡張子が大文字でもよい
  (t:dxf p (car c))
  (t:open p nil)
  (c:SV)
  (lc:assert-equal (t:fmt p) (car c) (strcat "2: " (cdr c) "形式のDXFのまま")))

;;; 3. 開いたあと Ctrl+S で最新形式に変わってしまった → 開いたときの形式に戻す
(princ "\n\n===== 3. 途中で形式が変わっていた =====")
(setq p "C:\\案件\\途中で変わった.dwg")
(t:dwg p "AC1024")
(t:open p nil)
(t:dwg p "AC1032")                                   ; 普通の上書き保存で 2018 形式になった
(c:SV)
(lc:assert-equal (t:fmt p) "AC1024" "3: 2010形式に戻る")
(setq p "C:\\案件\\途中で変わった.dxf")
(t:dxf p "AC1015")
(t:open p nil)
(t:dxf p "AC1032")
(c:SV)
(lc:assert-equal (t:fmt p) "AC1015" "3: DXF も 2000形式に戻る")

;;; 4. 保存しないで知らせる場面（ファイルは変わらない）
(princ "\n\n===== 4. 保存しない場面 =====")
(setq p "C:\\案件\\R14.dwg") (t:dwg p "AC1014") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) "AC1014" "4: R14 形式は保存しない")
(setq p "C:\\案件\\R12.dwg") (t:dwg p "AC1009") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) "AC1009" "4: R12 形式の DWG は保存しない")
(setq p "C:\\案件\\未来.dwg") (t:dwg p "AC1040") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) "AC1040" "4: 知らない新しい形式は保存しない")
(setq p "C:\\案件\\壊れた.dwg") (t:write p "XYZ") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) nil "4: 形式を読めないファイルは保存しない")
(setq p "C:\\案件\\ヘッダ無し.dxf") (t:write p "  0\nSECTION\n  2\nENTITIES\n  0\nENDSEC\n  0\nEOF\n") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) nil "4: $ACADVER の無い DXF は保存しない")
(setq p "C:\\案件\\テンプレート.dwt") (t:dwg p "AC1032") (t:open p nil) (c:SV)
(lc:assert-equal (t:fmt p) nil "4: テンプレートは対象外（形式も調べない）")
(t:open "Drawing1.dwg" '("untitled")) (c:SV)
(lc:assert (null *sv:open*) "4: 新規図面は何もしない")
(setq p "C:\\案件\\読み取り専用.dwg") (t:dwg p "AC1024") (t:open p '("readonly")) (t:dwg p "AC1015") (c:SV)
(lc:assert-equal (t:fmt p) "AC1015" "4: 読み取り専用は保存しない")

;;; 5. ほかの人が使用中 → エラーにならずに知らせる
(princ "\n\n===== 5. 使用中 =====")
(setq p "C:\\案件\\使用中.dwg") (lc:file p "locked") (t:dwg p "AC1024") (t:open p nil)
(c:SV)
(lc:assert-equal (t:fmt p) "AC1024" "5: エラーで止まらず、ファイルもそのまま")

;;; 6. ファイルが消えていても、開いたときの形式を覚えていれば保存する
(princ "\n\n===== 6. 開いたあとファイルが消えた =====")
(setq p "C:\\案件\\消えた.dwg") (t:dwg p "AC1027") (t:open p nil) (vl-file-delete p)
(c:SV)
(lc:assert-equal (t:fmt p) "AC1027" "6: 2013形式で保存し直す")

;;; 7. 読み込む前に形式が変わっていた（覚えていない）→ 今のファイルの形式で保存
(princ "\n\n===== 7. 覚えていないとき =====")
(setq p "C:\\案件\\あとから読み込み.dwg") (t:dwg p "AC1032")
(lc:docs (list (list p))) (setq *sv:open* nil)
(c:SV)
(lc:assert-equal (t:fmt p) "AC1032" "7: 今のファイルの形式（2018）で保存")

;;; 8. 名前を付けて保存で別の場所になった → 覚えていた形式は使わない
(princ "\n\n===== 8. 別名で保存したあと =====")
(setq p "C:\\案件\\元.dwg") (t:dwg p "AC1015") (t:open p nil)
(setq p2 "C:\\案件\\別名.dwg") (t:dwg p2 "AC1032") (lc:docs (list (list p2)))
(c:SV)
(lc:assert-equal (t:fmt p2) "AC1032" "8: 別名の図面は今のファイルの形式で保存")

(princ "\n\n===== テスト終了 =====")
(princ)

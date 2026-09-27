;;; KirokuTsuzuki の lispcheck 用テスト
;;; 実行: python tools/lispcheck/lispcheck.py run tools/KirokuTsuzuki/KirokuTsuzuki.lsp tools/KirokuTsuzuki/test/lispcheck/test_kiroku.lsp
;;; （図面を開く・前面にする・ファイルの読み書きは lispcheck の仮想機能で再現）

(setq A "C:\\案件\\A棟\\平面図.dwg"
      B "C:\\案件\\A棟\\立面図.dwg"
      C "C:\\案件\\B棟\\配置図.dwg")
(defun t:names (r) (mapcar 'vl-filename-base (caddr r)))

;;; 1. 記録が1つもないとき TZ → 「記録がありません」
(princ "\n\n===== 1. 記録なしで TZ =====")
(c:TZ)
(lc:assert (null (kr:records)) "1: 記録はまだ無い")

;;; 2. KR → Enter：一度も保存していない図面は記録しない。未保存の変更は知らせる
(princ "\n\n===== 2. KR（Enter で「前回」）=====")
(lc:docs (list (list A) (list B "modified") (list "Drawing1.dwg" "untitled") (list C)))
(foreach f (list A B C) (lc:file f))
(lc:input nil)
(c:KR)
(setq r (kr:read (kr:file "前回")))
(lc:assert r "2: 「前回」の記録ができる")
(lc:assert-equal (t:names r) '("平面図" "立面図" "配置図") "2: 保存済みの3枚を記録（Drawing1 は記録しない）")
(lc:assert-equal (cadr r) A "2: 前面の図面＝平面図")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "2: 最後の記録＝前回")

;;; 3. 名前を付けて記録
(princ "\n\n===== 3. KR → N → 現場A =====")
(lc:input "Name" "現場A")
(c:KR)
(lc:assert (kr:read (kr:file "現場A")) "3: 「現場A」の記録ができる")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "現場A" "3: 最後の記録＝現場A")

;;; 4. 使えない文字 → もう一度聞く → Enter で「前回」
(princ "\n\n===== 4. 名前に / を入れる =====")
(lc:input "Name" "a/b" nil)
(c:KR)
(lc:assert (null (findfile (kr:file "a/b"))) "4: 使えない名前では記録しない")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "4: Enter で「前回」に記録")

;;; 5. 既にある名前 → 上書きしない → Enter で「前回」
(princ "\n\n===== 5. 既にある名前で「いいえ」=====")
(lc:input "Name" "現場A" "No" nil)
(c:KR)
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "5: 上書きせず「前回」に記録")

;;; 6. 翌日：配置図だけ開いている。立面図はほかの人が使用中
(princ "\n\n===== 6. 翌日 TZ（Enter）=====")
(lc:docs (list (list C)))
(lc:file B "locked")
(lc:input nil)
(c:TZ)
(setq od (lc:open-docs))
(lc:assert-equal (length od) 3 "6: 3枚開いている（配置図は二重に開かない）")
(lc:assert-equal (car od) A "6: 前面は記録時の前面（平面図）")

;;; 7. 図面が見つからない（平面図が移動・削除された）
(princ "\n\n===== 7. 見つからない図面がある =====")
(vl-file-delete A)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(setenv "KirokuTsuzuki_Last" "現場A")
(lc:input nil)
(c:TZ)
(setq od (lc:open-docs))
(lc:assert-equal (length od) 3 "7: 平面図を除く2枚を開いて、元の1枚と合わせて3枚")
(lc:assert (not (member A od)) "7: 見つからない平面図は開かない")

;;; 8. 一覧から選ぶ
(princ "\n\n===== 8. TZ → L → 番号 =====")
(lc:file A)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(setq i (1+ (vl-position "前回" (mapcar 'car (kr:records)))))
(lc:input "List" i)
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 4 "8: 一覧で選んだ「前回」の3枚を開く")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "8: 最後の記録＝前回")

;;; 9. すべて開いている → 開く図面なし
(princ "\n\n===== 9. すでに全部開いている =====")
(lc:input nil)
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 4 "9: 何も開かない")

;;; 10. 設定：一覧 → 削除（最後の記録を消すと、次は新しい記録が既定になる）
(princ "\n\n===== 10. KRS 一覧・削除 =====")
(setenv "KirokuTsuzuki_Last" "現場A")
(setq i (1+ (vl-position "現場A" (mapcar 'car (kr:records)))))
(lc:input "List" "Delete" i "Yes" nil)
(c:KRS)
(lc:assert (not (member "現場A" (mapcar 'car (kr:records)))) "10: 現場A を削除")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "" "10: 最後の記録の印も消える")

;;; 11. 設定：保存先を変える → そこに記録 → 初期値に戻す
(princ "\n\n===== 11. KRS 保存先の変更 =====")
(lc:input "Folder" "D:\\共有\\記録" nil)
(c:KRS)
(lc:assert-equal (kr:folder) "D:\\共有\\記録\\" "11: 保存先が変わる")
(lc:docs (list (list A)))
(lc:input nil)
(c:KR)
(lc:assert-equal (length (kr:records)) 1 "11: 新しい保存先には1件だけ")
(lc:input "Folder" "." nil)
(c:KRS)
(lc:assert-equal (kr:folder) (kr:default-folder) "11: 初期値に戻る")
(lc:assert (member "前回" (mapcar 'car (kr:records))) "11: 元の保存先の記録が見える")

;;; 12. 保存していない図面しかない → 記録しない
(princ "\n\n===== 12. 新規図面だけ =====")
(lc:docs (list (list "Drawing1.dwg" "untitled") (list "Drawing2.dwg" "untitled")))
(setq n0 (length (kr:records)))
(c:KR)
(lc:assert-equal (length (kr:records)) n0 "12: 記録は増えない")

;;; 13. 1図面モード（SDI=1）→ 開かない
(princ "\n\n===== 13. SDI=1 =====")
(setvar "SDI" 1)
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 2 "13: 何も開かない")
(setvar "SDI" 0)

;;; 14. TZ 実行中に設定から全記録を消す → 「記録がありません」
(princ "\n\n===== 14. TZ → 設定で全部削除 =====")
(setq recs (kr:records))
(lc:input "Settings")
(foreach r recs (lc:input "Delete" 1 "Yes"))
(lc:input nil)
(c:TZ)
(lc:assert (null (kr:records)) "14: 記録は0件")
(princ "\n\n===== テスト終了 =====")
(princ)

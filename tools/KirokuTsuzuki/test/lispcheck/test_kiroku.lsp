;;; KirokuTsuzuki 1.1.0 の lispcheck 用テスト
;;; 実行: python tools/lispcheck/lispcheck.py run tools/KirokuTsuzuki/KirokuTsuzuki.lsp tools/KirokuTsuzuki/test/lispcheck/test_kiroku.lsp
;;; （図面を開く・前面にする・ファイルの読み書き・ダイアログは lispcheck の仮想機能で再現）
;;; ダイアログの操作は (lc:input '("DCL" ("set" キー 値) ("click" キー) ...)) で指定。nil＝Enter（既定のボタン）、台本なし＝Esc

(setq A "C:\\案件\\A棟\\平面図.dwg"
      B "C:\\案件\\A棟\\立面図.dwg"
      C "C:\\案件\\B棟\\配置図.dwg")
(defun t:names (r) (mapcar 'vl-filename-base (caddr r)))
(defun t:idx (name) (itoa (vl-position name (mapcar 'car (kr:records)))))

;;; ============================================================
;;;  ダイアログ版（KR / TZ / KRS）
;;; ============================================================

;;; 1. KR → Enter：「前回」に記録。一度も保存していない図面は記録しない
(princ "\n\n===== 1. KR → Enter =====")
(lc:docs (list (list A) (list B "modified") (list "Drawing1.dwg" "untitled") (list C)))
(foreach f (list A B C) (lc:file f))
(lc:input nil)
(c:KR)
(setq r (kr:read (kr:file "前回")))
(lc:assert-equal (t:names r) '("平面図" "立面図" "配置図") "1: 保存済みの3枚を記録")
(lc:assert-equal (cadr r) A "1: 前面の図面＝平面図")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "1: 最後の記録＝前回")

;;; 2. KR → 名前を入れて［記録する］
(princ "\n\n===== 2. KR → 名前「現場A」→ 記録する =====")
(lc:input '("DCL" ("set" "name" "現場A") ("click" "accept")))
(c:KR)
(lc:assert (kr:read (kr:file "現場A")) "2: 「現場A」の記録ができる")

;;; 3. 使えない文字 → ダイアログに注意が出て閉じない → Esc
(princ "\n\n===== 3. 名前に / → 注意 → Esc =====")
(lc:input '("DCL" ("set" "name" "a/b") ("click" "accept")))
(c:KR)
(lc:assert (null (findfile (kr:file "a/b"))) "3: 使えない名前では記録しない")

;;; 4. 既にある名前 → 1回目は注意、2回目で上書き
(princ "\n\n===== 4. 既にある名前 → 2回押して上書き =====")
(setenv "KirokuTsuzuki_Last" "前回")
(lc:input '("DCL" ("set" "name" "現場A") ("click" "accept") ("click" "accept")))
(c:KR)
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "現場A" "4: 上書きして最後の記録＝現場A")

;;; 5. 既にある名前 → 1回押して、名前を変えて押す → 新しい名前で記録（確認は名前ごと）
(princ "\n\n===== 5. 既にある名前 → 名前を変える =====")
(lc:input '("DCL" ("set" "name" "現場A") ("click" "accept") ("set" "name" "現場B") ("click" "accept")))
(c:KR)
(lc:assert (kr:read (kr:file "現場B")) "5: 「現場B」で記録")

;;; 6. KR → Esc
(princ "\n\n===== 6. KR → Esc =====")
(setq n0 (length (kr:records)))
(c:KR)
(lc:assert-equal (length (kr:records)) n0 "6: 記録は増えない")

;;; 7. 翌日：配置図だけ開いている。立面図はほかの人が使用中 → TZ → Enter（最後の記録＝現場B）
(princ "\n\n===== 7. 翌日 TZ → Enter =====")
(lc:docs (list (list C)))
(lc:file B "locked")
(lc:input nil)
(c:TZ)
(setq od (lc:open-docs))
(lc:assert-equal (length od) 3 "7: 3枚開いている（配置図は二重に開かない）")
(lc:assert-equal (car od) A "7: 前面は記録時の前面（平面図）")

;;; 8. 見つからない図面：平面図を削除 → 一覧で「前回」を選んで［開く］
(princ "\n\n===== 8. 見つからない図面 → 記録を選んで開く =====")
(vl-file-delete A)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input (list "DCL" (list "pick" "recs" (t:idx "前回")) (list "click" "accept")))
(c:TZ)
(setq od (lc:open-docs))
(lc:assert-equal (length od) 3 "8: 平面図を除く2枚を開く")
(lc:assert (not (member A od)) "8: 見つからない平面図は開かない")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "前回" "8: 最後の記録＝前回")

;;; 9. ダブルクリックで開く
(princ "\n\n===== 9. 記録をダブルクリック =====")
(lc:file A)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input (list "DCL" (list "dclick" "recs" (t:idx "現場A"))))
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 4 "9: 現場A の3枚を開く")

;;; 10. すべて開いている → ［開く］は使えない状態 → Esc
(princ "\n\n===== 10. すでに全部開いている → Esc =====")
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 4 "10: 何も開かない")

;;; 11. 削除：1回目は注意、2回目で削除 → Esc
(princ "\n\n===== 11. TZ → この記録を削除（2回）→ Esc =====")
(setenv "KirokuTsuzuki_Last" "現場B")
(lc:input (list "DCL" (list "pick" "recs" (t:idx "現場B")) (list "click" "del") (list "click" "del")))
(c:TZ)
(lc:assert (not (member "現場B" (mapcar 'car (kr:records)))) "11: 現場B を削除")
(lc:assert-equal (getenv "KirokuTsuzuki_Last") "" "11: 最後の記録の印も消える")

;;; 12. KRS：初期値に戻す → 閉じる
(princ "\n\n===== 12. KRS → 初期値に戻す → 閉じる =====")
(setenv "KirokuTsuzuki_Folder" "D:\\共有\\記録\\")
(lc:input '("DCL" ("click" "reset")) '("DCL" ("click" "cancel")))
(c:KRS)
(lc:assert (kr:folder-default-p) "12: 保存先が初期値に戻る")

;;; 13. 新規図面だけ → 記録しない（ダイアログも出ない）
(princ "\n\n===== 13. 新規図面だけ =====")
(lc:docs (list (list "Drawing1.dwg" "untitled")))
(setq n0 (length (kr:records)))
(c:KR)
(lc:assert-equal (length (kr:records)) n0 "13: 記録は増えない")

;;; 14. SDI=1 → 開かない
(princ "\n\n===== 14. SDI=1 =====")
(setvar "SDI" 1)
(c:TZ)
(lc:assert-equal (length (lc:open-docs)) 1 "14: 何も開かない")
(setvar "SDI" 0)

;;; ============================================================
;;;  コマンドライン版（-KIROKU / -TSUZUKI / -KIROKUSET）
;;; ============================================================

;;; 15. -KIROKU → N → 現場C
(princ "\n\n===== 15. -KIROKU → N → 現場C =====")
(lc:docs (list (list A) (list C)))
(lc:input "Name" "現場C")
(c:-KIROKU)
(lc:assert-equal (t:names (kr:read (kr:file "現場C"))) '("平面図" "配置図") "15: 現場C に2枚")

;;; 16. -TSUZUKI → L → 番号
(princ "\n\n===== 16. -TSUZUKI → L → 番号 =====")
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input "List" (1+ (atoi (t:idx "現場C"))))
(c:-TSUZUKI)
(lc:assert-equal (length (lc:open-docs)) 3 "16: 現場C の2枚を開く")

;;; 17. -KIROKUSET → 保存先変更 → 初期値に戻す
(princ "\n\n===== 17. -KIROKUSET → 保存先 =====")
(lc:input "Folder" "D:\\共有\\記録" "Folder" "." nil)
(c:-KIROKUSET)
(lc:assert (kr:folder-default-p) "17: 初期値に戻る")

;;; 18. 記録が1つもないとき TZ → ダイアログに案内 → Esc
(princ "\n\n===== 18. 記録なしで TZ =====")
(foreach r (kr:records) (vl-file-delete (nth 3 r)))
(c:TZ)
(lc:assert (null (kr:records)) "18: 記録は0件")
(princ "\n\n===== テスト終了 =====")
(princ)

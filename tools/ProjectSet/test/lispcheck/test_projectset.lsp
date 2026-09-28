;;; ProjectSet の lispcheck 用テスト
;;; 実行: python tools/lispcheck/lispcheck.py run tools/ProjectSet/ProjectSet.lsp tools/ProjectSet/test/lispcheck/test_projectset.lsp
;;; ダイアログの操作は (lc:input '("DCL" ("set" キー 値) ("click" キー) ...))。nil＝Enter（既定のボタン）、台本なし＝Esc

(setq A "C:\\案件\\A棟\\平面図.dwg"
      B "C:\\案件\\A棟\\立面図.dwg"
      C "C:\\案件\\B棟\\配置図.dwg")
(defun t:names (name) (mapcar 'vl-filename-base (caddr (pj:read (pj:file name)))))
(defun t:idx (name) (itoa (vl-position name (mapcar 'car (pj:records)))))
(defun t:sel-name ( ) (car (nth *pj:sel* *pj:recs*)))

;;; 1. 記録なし：名前の初期値（日付）のまま、名前欄で Enter → 記録してダイアログを閉じる
(princ "\n\n===== 1. 最初の記録（名前欄で Enter）=====")
(lc:docs (list (list A) (list "Drawing1.dwg" "untitled") (list B)))
(foreach f (list A B C) (lc:file f))
(lc:input '("DCL" ("click" "name")))
(c:PJ)
(setq d1 (pj:default-name))
(lc:assert-equal (t:names d1) '("平面図" "立面図") "1: 日付の名前で2枚を記録（新規図面は記録しない）")
(lc:assert-equal (getenv "ProjectSet_Last") d1 "1: 最後の記録＝日付の名前")

;;; 2. 名前を変えて［記録する］→ 閉じる
(princ "\n\n===== 2. 名前「現場A」で記録 =====")
(lc:docs (list (list A) (list C)))
(lc:input '("DCL" ("set" "name" "現場A") ("click" "btn_save")))
(c:PJ)
(lc:assert-equal (t:names "現場A") '("平面図" "配置図") "2: 現場A に2枚")

;;; 3. 選んでいる記録の名前が初期値 → そのまま［記録する］1回で上書き（確認なし）
(princ "\n\n===== 3. 選んでいる記録を更新 =====")
(lc:docs (list (list A) (list B) (list C)))
(lc:input '("DCL" ("click" "btn_save")))
(c:PJ)
(lc:assert-equal (t:names "現場A") '("平面図" "立面図" "配置図") "3: 現場A を3枚で上書き")

;;; 4. 選んでいない既存の名前 → 1回目は確認だけ（閉じない）→ Esc
(princ "\n\n===== 4. ほかの既存の名前 → 確認 → Esc =====")
(lc:docs (list (list B)))
(lc:input (list "DCL" (list "set" "name" d1) (list "click" "btn_save")))
(c:PJ)
(lc:assert-equal (t:names d1) '("平面図" "立面図") "4: 上書きされていない")

;;; 5. 【修正1の確認】R1・R2 を記録 → R1 を開く → R3 を記録 → 次は R3 が選ばれている
(princ "\n\n===== 5. 最後に使った記録が選ばれる =====")
(lc:docs (list (list A)))
(lc:input '("DCL" ("set" "name" "R1") ("click" "btn_save")))
(c:PJ)
(lc:input '("DCL" ("set" "name" "R2") ("click" "btn_save")))
(c:PJ)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input (list "DCL" (list "pick" "recs" (t:idx "R1")) (list "click" "btn_open")))
(c:PJ)
(lc:input '("DCL" ("set" "name" "R3") ("click" "btn_save")))
(c:PJ)
(c:PJ)                                    ; 開いて Esc
(lc:assert-equal (t:sel-name) "R3" "5: 次に開いたとき R3 が選ばれている")

;;; 6. Enter（既定のボタン＝開く）で最後の記録を開く
(princ "\n\n===== 6. Enter で開く =====")
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input '("DCL" ("click" "btn_open")))
(c:PJ)
(lc:assert-equal (length (lc:open-docs)) 2 "6: R3（別の図面・平面図）を開く。別の図面.dwg は二重に開かない")

;;; 7. 記録を選ぶと名前欄もその名前に
(princ "\n\n===== 7. 記録を選ぶと名前欄が変わる =====")
(lc:docs (list (list A)))
(lc:input (list "DCL" (list "pick" "recs" (t:idx "現場A")) (list "click" "btn_save")))
(c:PJ)
(lc:assert-equal (t:names "現場A") '("平面図") "7: 選んだ「現場A」を確認なしで更新")

;;; 8. 名前の変更（名前変更ダイアログ）
(princ "\n\n===== 8. 名前の変更 =====")
(lc:input (list "DCL" (list "pick" "recs" (t:idx "R2")) (list "click" "btn_ren"))
          '("DCL" ("set" "new_name" "R2改") ("click" "btn_ok")))
(c:PJ)
(lc:assert (member "R2改" (mapcar 'car (pj:records))) "8: R2改 がある")
(lc:assert (not (member "R2" (mapcar 'car (pj:records)))) "8: R2 は無い")
(lc:assert-equal (t:sel-name) "R2改" "8: 名前を変えた記録が選ばれたまま")

;;; 9. 削除（2回押す）
(princ "\n\n===== 9. 削除 =====")
(lc:input (list "DCL" (list "pick" "recs" (t:idx "R2改")) (list "click" "btn_del") (list "click" "btn_del")))
(c:PJ)
(lc:assert (not (member "R2改" (mapcar 'car (pj:records)))) "9: R2改 を削除")

;;; 10. 【修正3の確認】SDI=1 → ［開く］は使えない。ダブルクリックでも開かない
(princ "\n\n===== 10. SDI=1 =====")
(setvar "SDI" 1)
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input (list "DCL" (list "dclick" "recs" (t:idx "R3"))))
(c:PJ)
(lc:assert-equal (length (lc:open-docs)) 1 "10: 何も開かない")
(setvar "SDI" 0)

;;; 11. 見つからない図面・使用中の図面
(princ "\n\n===== 11. 見つからない・使用中 =====")
(vl-file-delete C)
(lc:file B "locked")
(lc:docs (list (list "C:\\案件\\その他\\別の図面.dwg")))
(lc:input (list "DCL" (list "pick" "recs" (t:idx d1)) (list "click" "btn_open")))
(c:PJ)
(lc:assert-equal (length (lc:open-docs)) 3 "11: 平面図と立面図（読み取り専用）を開く")

;;; 12. 新規図面しかない → ［記録する］は使えない。Esc
(princ "\n\n===== 12. 新規図面だけ =====")
(lc:docs (list (list "Drawing1.dwg" "untitled")))
(setq n0 (length (pj:records)))
(c:PJ)
(lc:assert-equal (length (pj:records)) n0 "12: 記録は増えない")
(princ "\n\n===== テスト終了 =====")
(princ)

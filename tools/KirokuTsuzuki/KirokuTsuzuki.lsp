;;; ============================================================
;;;  KirokuTsuzuki.lsp   ― 開いている図面を記録して、あとでまとめて開く ―
;;;
;;;  KIROKU    (ショートカット KR ) : 開いている図面を記録する（ダイアログ）
;;;  TSUZUKI   (ショートカット TZ ) : 記録した図面をまとめて開く（ダイアログ）
;;;  KIROKUSET (ショートカット KRS) : 保存先の設定（ダイアログ）
;;;  -KIROKU / -TSUZUKI / -KIROKUSET : 同じ操作をコマンドラインで行う版
;;;
;;;  対応 : AutoCAD 2027
;;;  版   : 1.1.0  (2026-09-28)
;;;         1.1.0: KR / TZ / KRS をダイアログにした（コマンドライン版は -KIROKU など）
;;;         1.0.0: 最初の版
;;;
;;;  ・図面そのものは保存しない（記録するのは図面の場所だけ）。
;;;  ・システム変数は変更しない。
;;;  ・ダイアログの定義（DCL）は実行時に一時ファイルへ書き出して使う（LSP 1本で動く）。
;;; ============================================================

(vl-load-com)

(setq *kr:default-name* "前回"
      *kr:ext*          ".krk")

;;; ------------------------------------------------------------
;;;  保存先
;;; ------------------------------------------------------------
(defun kr:slash (p)
  (if (and p (/= p "") (/= (substr p (strlen p)) "\\")) (strcat p "\\") p))

(defun kr:default-folder ( )
  (strcat (kr:slash (getvar "ROAMABLEROOTPREFIX")) "KirokuTsuzuki\\"))

(defun kr:folder ( / f)
  (setq f (getenv "KirokuTsuzuki_Folder"))
  (if (or (null f) (= f "")) (kr:default-folder) (kr:slash f)))

(defun kr:folder-default-p ( )
  (member (getenv "KirokuTsuzuki_Folder") '(nil "")))

;;; フォルダを奥まで作る
(defun kr:mkdirs (p / parts cur)
  (setq p (vl-string-right-trim "\\" p) cur "")
  (while (setq parts (vl-string-search "\\" p))
    (setq cur (strcat cur (substr p 1 (1+ parts))) p (substr p (+ parts 2)))
    (if (not (vl-file-directory-p cur)) (vl-mkdir cur)))
  (setq cur (strcat cur p))
  (if (not (vl-file-directory-p cur)) (vl-mkdir cur))
  (vl-file-directory-p cur))

(defun kr:file (name) (strcat (kr:folder) name *kr:ext*))

;;; ------------------------------------------------------------
;;;  記録ファイルの読み書き
;;;  1行目 KIROKU 1 / DATE 日時 / FRONT 前面の図面 / DWG 図面（複数）
;;; ------------------------------------------------------------
(defun kr:now ( / s)
  (setq s (rtos (getvar "CDATE") 2 6))       ; 例 "20260927.180512"
  (strcat (substr s 1 4) "/" (substr s 5 2) "/" (substr s 7 2) " "
          (substr s 10 2) ":" (substr s 12 2)))

;;; UTF-8 で開く（使えない環境では通常の開き方）
(defun kr:open (file mode / fh)
  (setq fh (vl-catch-all-apply 'open (list file mode "utf8")))
  (if (vl-catch-all-error-p fh) (open file mode) fh))

(defun kr:write (file date front dwgs)
  (setq *kr:fh* (kr:open file "w"))
  (if *kr:fh*
    (progn
      (write-line "KIROKU 1" *kr:fh*)
      (write-line (strcat "DATE " date) *kr:fh*)
      (write-line (strcat "FRONT " (if front front "")) *kr:fh*)
      (foreach d dwgs (write-line (strcat "DWG " d) *kr:fh*))
      (close *kr:fh*)
      (setq *kr:fh* nil)
      T)))

;;; → (日時 前面の図面 (図面 ...)) か nil
(defun kr:read (file / l ok date front dwgs)
  (if (and file (findfile file) (setq *kr:fh* (kr:open file "r")))
    (progn
      (while (setq l (read-line *kr:fh*))
        (cond ((wcmatch l "KIROKU *") (setq ok T))
              ((wcmatch l "DATE *")   (setq date (substr l 6)))
              ((wcmatch l "FRONT *")  (setq front (substr l 7)))
              ((wcmatch l "DWG *")    (setq dwgs (cons (substr l 5) dwgs)))))
      (close *kr:fh*)
      (setq *kr:fh* nil)
      (if ok (list (if date date "") (if (/= front "") front) (reverse dwgs))))))

;;; 保存先にある記録 → ((名前 日時 枚数 ファイル) ...) 新しい順
(defun kr:records ( / dir res r)
  (setq dir (kr:folder))
  (foreach f (vl-directory-files dir (strcat "*" *kr:ext*) 1)
    (if (setq r (kr:read (strcat dir f)))
      (setq res (cons (list (vl-filename-base f) (car r) (length (caddr r)) (strcat dir f)) res))))
  (vl-sort res '(lambda (a b) (> (cadr a) (cadr b)))))

;;; 最後に使った記録（無ければいちばん新しい記録）
(defun kr:last-rec (recs / lastname)
  (setq lastname (getenv "KirokuTsuzuki_Last"))
  (cond ((car (vl-remove-if-not '(lambda (x) (= (car x) lastname)) recs)))
        ((car recs))))

(defun kr:rec-label (rec)
  (strcat "「" (car rec) "」 " (cadr rec) "・" (itoa (caddr rec)) "枚"))

;;; 名前に使えない文字
(defun kr:bad-name-p (s)
  (or (= s "")
      (vl-some '(lambda (c) (vl-string-search c s)) '("\\" "/" ":" "*" "?" "\"" "<" ">" "|"))))

(defun kr:join (lst / s)
  (setq s "")
  (foreach x lst (setq s (if (= s "") x (strcat s "、" x))))
  s)

;;; ------------------------------------------------------------
;;;  共通のエラー処理
;;; ------------------------------------------------------------
(defun kr:start ( )
  (setq *kr:doc* (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark *kr:doc*)
  (setq *kr:undo* T))

(defun kr:finish ( )
  (if *kr:fh* (progn (vl-catch-all-apply 'close (list *kr:fh*)) (setq *kr:fh* nil)))
  (kr:dcl-unload)
  (if (and *kr:doc* *kr:undo*) (progn (vla-EndUndoMark *kr:doc*) (setq *kr:undo* nil))))

(defun kr:error (tag msg)
  (kr:finish)
  (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
    (princ (strcat "\n[" tag "] エラー: " msg))
    (princ (strcat "\n[" tag "] 中止しました。")))
  (princ))

;;; ------------------------------------------------------------
;;;  記録と再開の中身（ダイアログ版・コマンドライン版で共通）
;;; ------------------------------------------------------------
;;; 開いている図面 → (記録する図面 前面の図面 未保存の変更がある図面名 記録できない図面名 表示用)
;;; 表示用 = ((図面名 状態) ...)  状態：nil / "modified" / "untitled"
(defun kr:collect ( / acad active dwgs front modified untitled disp full nm)
  (setq acad (vlax-get-acad-object) active (vla-get-ActiveDocument acad))
  (vlax-for d (vla-get-Documents acad)
    (setq full (vla-get-FullName d) nm (vla-get-Name d))
    (cond
      ((or (= full "") (= 0 (vlax-invoke d 'GetVariable "DWGTITLED")))
       (setq untitled (cons nm untitled) disp (cons (list nm "untitled") disp)))
      (T
       (setq dwgs (cons full dwgs))
       (if (equal d active) (setq front full))
       (if (/= 0 (vlax-invoke d 'GetVariable "DBMOD"))
         (setq modified (cons nm modified) disp (cons (list nm "modified") disp))
         (setq disp (cons (list nm nil) disp))))))
  (list (reverse dwgs) front (reverse modified) (reverse untitled) (reverse disp)))

;;; 記録して結果を表示 → T / nil
(defun kr:save (name info / file)
  (cond
    ((not (kr:mkdirs (kr:folder)))
     (princ (strcat "\n[KIROKU] 保存先フォルダを作れませんでした：" (kr:folder)
                    "\n          KRS（設定）で保存先を確認してください。"))
     nil)
    ((not (kr:write (setq file (kr:file name)) (kr:now) (cadr info) (car info)))
     (princ (strcat "\n[KIROKU] 記録ファイルに書き込めませんでした：" file))
     nil)
    (T
     (setenv "KirokuTsuzuki_Last" name)
     (princ (strcat "\n[KIROKU] 「" name "」に図面 " (itoa (length (car info))) " 枚を記録しました。"))
     (if (caddr info)
       (princ (strcat "\n          ※保存していない変更がある図面 " (itoa (length (caddr info))) " 枚："
                      (kr:join (caddr info)) "（図面の保存は別に行ってください）")))
     (if (cadddr info)
       (princ (strcat "\n          ※一度も保存していないため記録できない図面 " (itoa (length (cadddr info))) " 枚："
                      (kr:join (cadddr info)))))
     T)))

(defun kr:open-names (docs / res)
  (vlax-for d docs
    (if (/= (vla-get-FullName d) "") (setq res (cons (strcase (vla-get-FullName d)) res))))
  res)

;;; 記録を開いて結果を表示
(defun kr:open-record (rec / docs data opened nopen nskip ro missing failed nd)
  (setq docs (vla-get-Documents (vlax-get-acad-object)))
  (if (setq data (kr:read (nth 3 rec)))
    (progn
      (setq opened (kr:open-names docs) nopen 0 nskip 0)
      (foreach f (caddr data)
        (cond
          ((member (strcase f) opened) (setq nskip (1+ nskip)))
          ((null (findfile f)) (setq missing (cons f missing)))
          (T
           ;; 通常で開く → だめなら読み取り専用で開く
           (setq nd (vl-catch-all-apply 'vla-open (list docs f :vlax-false)))
           (if (vl-catch-all-error-p nd)
             (setq nd (vl-catch-all-apply 'vla-open (list docs f :vlax-true))))
           (if (vl-catch-all-error-p nd)
             (setq failed (cons f failed))
             (progn
               (setq nopen (1+ nopen) opened (cons (strcase f) opened))
               (if (= :vlax-true (vla-get-ReadOnly nd))
                 (setq ro (cons (vl-filename-base f) ro))))))))
      ;; 記録したときに前面だった図面を前面に
      (if (cadr data)
        (vlax-for d docs
          (if (= (strcase (vla-get-FullName d)) (strcase (cadr data)))
            (vl-catch-all-apply 'vla-Activate (list d)))))
      (setenv "KirokuTsuzuki_Last" (car rec))
      (princ (strcat "\n[TSUZUKI] 「" (car rec) "」（" (car data) "）：開いた図面 " (itoa nopen)
                     " 枚 / すでに開いていた図面 " (itoa nskip) " 枚"))
      (if ro
        (princ (strcat "\n          ※ほかの人が使用中のため読み取り専用で開いた図面 " (itoa (length ro)) " 枚："
                       (kr:join (reverse ro)))))
      (if missing
        (princ (strcat "\n          ※見つからない図面 " (itoa (length missing)) " 枚（移動・削除された可能性）："
                       (kr:join (mapcar 'vl-filename-base (reverse missing))))))
      (if failed
        (princ (strcat "\n          ※開けなかった図面 " (itoa (length failed)) " 枚："
                       (kr:join (mapcar 'vl-filename-base (reverse failed)))))))
    (princ "\n[TSUZUKI] 記録ファイルを読めませんでした。")))

;;; ------------------------------------------------------------
;;;  ダイアログ（DCL を一時ファイルに書き出して読み込む）
;;; ------------------------------------------------------------
(setq *kr:dcl-lines*
  '("kr_save : dialog {"
    "  label = \"図面を記録（KIROKU）\";"
    "  : text { key = \"head\"; width = 60; }"
    "  : list_box { key = \"files\"; width = 60; height = 9; }"
    "  : edit_box { key = \"name\"; label = \"記録の名前：\"; edit_width = 36; allow_accept = true; }"
    "  : text { key = \"note\"; width = 60; }"
    "  spacer;"
    "  : row { alignment = right; fixed_width = true;"
    "    : button { key = \"accept\"; label = \"記録する\"; is_default = true; width = 14; fixed_width = true; }"
    "    : button { key = \"cancel\"; label = \"キャンセル\"; is_cancel = true; width = 14; fixed_width = true; }"
    "  }"
    "}"
    "kr_open : dialog {"
    "  label = \"図面をまとめて開く（TSUZUKI）\";"
    "  : row {"
    "    : column {"
    "      : text { label = \"記録\"; }"
    "      : list_box { key = \"recs\"; width = 36; height = 12; }"
    "      : button { key = \"del\"; label = \"この記録を削除\"; width = 18; fixed_width = true; }"
    "    }"
    "    : column {"
    "      : text { key = \"fhead\"; width = 48; }"
    "      : list_box { key = \"files\"; width = 48; height = 12; }"
    "      : text { key = \"folder\"; width = 48; }"
    "    }"
    "  }"
    "  : text { key = \"msg\"; width = 86; }"
    "  : row {"
    "    : button { key = \"chfolder\"; label = \"保存先を変更...\"; width = 18; fixed_width = true; }"
    "    : spacer { width = 30; }"
    "    : button { key = \"accept\"; label = \"開く\"; is_default = true; width = 14; fixed_width = true; }"
    "    : button { key = \"cancel\"; label = \"キャンセル\"; is_cancel = true; width = 14; fixed_width = true; }"
    "  }"
    "}"
    "kr_set : dialog {"
    "  label = \"記録の保存先（KIROKUSET）\";"
    "  : text { label = \"記録ファイルの保存先：\"; }"
    "  : text { key = \"folder\"; width = 70; }"
    "  : text { key = \"msg\"; width = 70; }"
    "  : row {"
    "    : button { key = \"change\"; label = \"変更...\"; width = 14; fixed_width = true; }"
    "    : button { key = \"reset\"; label = \"初期値に戻す\"; width = 16; fixed_width = true; }"
    "    : spacer { width = 10; }"
    "    : button { key = \"cancel\"; label = \"閉じる\"; is_cancel = true; is_default = true; width = 14; fixed_width = true; }"
    "  }"
    "}"))

;;; 読み込み → ダイアログ番号（失敗なら nil）
(defun kr:dcl-load ( / fh id)
  (if (null *kr:dcl-id*)
    (progn
      (setq *kr:dcl-file* (vl-filename-mktemp "kirokutsuzuki" nil ".dcl"))
      (if (setq fh (kr:open *kr:dcl-file* "w"))
        (progn
          (foreach l *kr:dcl-lines* (write-line l fh))
          (close fh)
          (setq id (load_dialog *kr:dcl-file*))
          (if (and id (> id 0)) (setq *kr:dcl-id* id))))))
  *kr:dcl-id*)

(defun kr:dcl-unload ( )
  (if *kr:dcl-id* (progn (vl-catch-all-apply 'unload_dialog (list *kr:dcl-id*)) (setq *kr:dcl-id* nil)))
  (if (and *kr:dcl-file* (findfile *kr:dcl-file*)) (vl-file-delete *kr:dcl-file*))
  (setq *kr:dcl-file* nil))

;;; パスからファイル名（拡張子つき）
(defun kr:fname (f) (strcat (vl-filename-base f) (cond ((vl-filename-extension f)) (""))))

(defun kr:fill-list (key items)
  (start_list key)
  (foreach it items (add_list it))
  (end_list))

;;; 行を揃えるための空白埋め（全角は2文字分として数える）
(defun kr:pad (s n / w)
  (setq w 0)
  (foreach c (vl-string->list s) (setq w (+ w (if (> c 255) 2 1))))
  (while (< w n) (setq s (strcat s " ") w (1+ w)))
  s)

;;; フォルダを選ぶ画面（Windows 標準）→ パス か nil
(defun kr:browse-folder (msg / sh f p)
  (if (setq sh (vl-catch-all-apply 'vlax-create-object (list "Shell.Application")))
    (if (not (vl-catch-all-error-p sh))
      (progn
        (setq f (vl-catch-all-apply 'vlax-invoke-method (list sh 'BrowseForFolder 0 msg 64)))
        (if (and f (not (vl-catch-all-error-p f)))
          (setq p (vl-catch-all-apply 'vlax-get-property (list (vlax-get-property f 'Self) 'Path))))
        (vlax-release-object sh))))
  (if (and p (not (vl-catch-all-error-p p)) (/= p "")) (kr:slash p)))

(defun kr:change-folder ( / p)
  (if (setq p (kr:browse-folder "記録ファイルの保存先を選んでください"))
    (if (kr:mkdirs p)
      (progn (setenv "KirokuTsuzuki_Folder" p) T))))

;;; ---- KR のダイアログ ----
(defun kr:dlg-save-accept ( / nm)
  (setq nm (vl-string-trim " \t" (get_tile "name")))
  (cond
    ((= nm "") (set_tile "note" "記録の名前を入れてください。"))
    ((kr:bad-name-p nm) (set_tile "note" "名前に次の文字は使えません： \\ / : * ? \" < > |"))
    ((and (/= nm *kr:default-name*) (findfile (kr:file nm)) (/= *kr:confirm* nm))
     (setq *kr:confirm* nm)
     (set_tile "note" (strcat "「" nm "」は既にあります。もう一度［記録する］を押すと上書きします。")))
    (T (setq *kr:dlg-name* nm) (done_dialog 1))))

(defun kr:dlg-save (info / r)
  (setq *kr:confirm* nil *kr:dlg-name* nil)
  (if (and (kr:dcl-load) (new_dialog "kr_save" *kr:dcl-id*))
    (progn
      (set_tile "head" (strcat "開いている図面を記録します（記録される図面 " (itoa (length (car info))) " 枚）"))
      (kr:fill-list "files"
        (mapcar '(lambda (x)
                   (cond ((= (cadr x) "modified") (strcat (kr:pad (car x) 34) "※保存していない変更あり"))
                         ((= (cadr x) "untitled") (strcat (kr:pad (car x) 34) "※一度も保存していないため記録されません"))
                         (T (car x))))
                (nth 4 info)))
      (set_tile "name" *kr:default-name*)
      (set_tile "note" "同じ名前の記録があると上書きされます（「前回」はいつも上書き）。")
      (action_tile "accept" "(kr:dlg-save-accept)")
      (action_tile "cancel" "(done_dialog 0)")
      (setq r (start_dialog))
      (if (= r 1) *kr:dlg-name* 'CANCEL))))

;;; ---- TZ のダイアログ ----
(defun kr:dlg-open-files ( / rec data nopen nskip nmiss items st)
  (if (setq rec (nth *kr:sel* *kr:recs*))
    (progn
      (setq data (kr:read (nth 3 rec)) nopen 0 nskip 0 nmiss 0)
      (foreach f (caddr data)
        (setq st (cond ((member (strcase f) *kr:opened*) (setq nskip (1+ nskip)) "※すでに開いています")
                       ((null (findfile f)) (setq nmiss (1+ nmiss)) "※見つかりません")
                       (T (setq nopen (1+ nopen)) nil))
              items (cons (if st (strcat (kr:pad (kr:fname f) 34) st) (kr:fname f)) items)))
      (kr:fill-list "files" (reverse items))
      (set_tile "fhead" (strcat "「" (car rec) "」の図面 " (itoa (length (caddr data))) " 枚"
                               "（開く " (itoa nopen) " 枚"
                               (if (> nskip 0) (strcat "・開いている " (itoa nskip) " 枚") "")
                               (if (> nmiss 0) (strcat "・見つからない " (itoa nmiss) " 枚") "") "）"))
      (mode_tile "accept" (if (> nopen 0) 0 1))
      (mode_tile "del" 0))
    (progn
      (kr:fill-list "files" nil)
      (set_tile "fhead" "")
      (mode_tile "accept" 1)
      (mode_tile "del" 1))))

(defun kr:dlg-open-fill ( )
  (kr:fill-list "recs"
    (mapcar '(lambda (r) (strcat (kr:pad (car r) 14) (cadr r) "  " (itoa (caddr r)) "枚")) *kr:recs*))
  (set_tile "folder" (strcat "保存先：" (kr:folder) (if (kr:folder-default-p) "（初期値）" "")))
  (if *kr:recs*
    (progn
      (set_tile "recs" (itoa *kr:sel*))
      (set_tile "msg" ""))
    (set_tile "msg" "記録がありません。先に KR で記録してください（保存先を変えた場合は［保存先を変更...］）。"))
  (kr:dlg-open-files))

(defun kr:dlg-open-pick (val reason)
  (setq *kr:sel* (atoi val) *kr:delconf* nil)
  (set_tile "msg" "")
  (kr:dlg-open-files)
  (if (and (= reason 4) (nth *kr:sel* *kr:recs*)) (done_dialog 1)))

(defun kr:dlg-open-del ( / rec)
  (if (setq rec (nth *kr:sel* *kr:recs*))
    (if (/= *kr:delconf* (car rec))
      (progn
        (setq *kr:delconf* (car rec))
        (set_tile "msg" (strcat "「" (car rec) "」を削除します。もう一度［この記録を削除］を押すと削除します。")))
      (progn
        (if (vl-file-delete (nth 3 rec))
          (progn
            (if (= (getenv "KirokuTsuzuki_Last") (car rec)) (setenv "KirokuTsuzuki_Last" ""))
            (setq *kr:recs* (kr:records) *kr:sel* (min *kr:sel* (max 0 (1- (length *kr:recs*)))) *kr:delconf* nil)
            (kr:dlg-open-fill)
            (set_tile "msg" (strcat "「" (car rec) "」を削除しました。")))
          (set_tile "msg" "削除できませんでした。"))))))

(defun kr:dlg-open-accept ( )
  (if (nth *kr:sel* *kr:recs*) (done_dialog 1) (set_tile "msg" "開く記録を選んでください。")))

;;; → 開く記録 / nil（キャンセル） / 'NODIALOG（ダイアログを出せない）
(defun kr:dlg-open ( / r done res)
  (setq *kr:recs* (kr:records)
        *kr:sel* (max 0 (cond ((vl-position (kr:last-rec *kr:recs*) *kr:recs*)) (0)))
        *kr:opened* (kr:open-names (vla-get-Documents (vlax-get-acad-object))))
  (if (not (kr:dcl-load))
    (setq res 'NODIALOG done T))
  (while (not done)
    (if (not (new_dialog "kr_open" *kr:dcl-id*))
      (setq res 'NODIALOG done T)
      (progn
        (setq *kr:delconf* nil)
        (kr:dlg-open-fill)
        (action_tile "recs" "(kr:dlg-open-pick $value $reason)")
        (action_tile "del" "(kr:dlg-open-del)")
        (action_tile "chfolder" "(done_dialog 2)")
        (action_tile "accept" "(kr:dlg-open-accept)")
        (action_tile "cancel" "(done_dialog 0)")
        (setq r (start_dialog))
        (cond
          ((= r 1) (setq res (nth *kr:sel* *kr:recs*) done T))
          ((= r 2)                              ; 保存先を変えて、ダイアログを出し直す
           (if (kr:change-folder)
             (setq *kr:recs* (kr:records) *kr:sel* (max 0 (cond ((vl-position (kr:last-rec *kr:recs*) *kr:recs*)) (0))))))
          (T (setq done T))))))
  res)

;;; ---- KRS のダイアログ ----
(defun kr:dlg-set ( / r done msg)
  (setq msg "")
  (while (not done)
    (if (not (and (kr:dcl-load) (new_dialog "kr_set" *kr:dcl-id*)))
      (setq done 'NODIALOG)
      (progn
        (set_tile "folder" (strcat (kr:folder) (if (kr:folder-default-p) "（初期値）" "")))
        (set_tile "msg" msg)
        (action_tile "change" "(done_dialog 2)")
        (action_tile "reset" "(done_dialog 3)")
        (action_tile "cancel" "(done_dialog 0)")
        (setq r (start_dialog))
        (cond
          ((= r 2) (setq msg (if (kr:change-folder) "保存先を変更しました。" "")))
          ((= r 3) (setenv "KirokuTsuzuki_Folder" "") (setq msg "初期値に戻しました。"))
          (T (setq done T))))))
  done)

;;; ------------------------------------------------------------
;;;  KIROKU（KR）
;;; ------------------------------------------------------------
(defun c:KIROKU ( / *error* info name)
  (defun *error* (msg) (kr:error "KIROKU" msg))
  (kr:start)
  (setq info (kr:collect))
  (if (null (car info))
    (princ "\n[KIROKU] 記録できる図面がありません（一度も保存していない図面は記録できません）。")
    (progn
      (setq name (kr:dlg-save info))
      (cond
        ((null name)                       ; ダイアログを出せない → コマンドラインで
         (princ "\n[KIROKU] ダイアログを表示できないため、コマンドラインで操作します。")
         (kr:dcl-unload)
         (kr:save-cmd info))
        ((eq name 'CANCEL) (princ "\n[KIROKU] 中止しました。"))
        (T (kr:save name info)))))
  (kr:finish)
  (princ))

(defun c:KR ( ) (c:KIROKU))

;;; ------------------------------------------------------------
;;;  TSUZUKI（TZ）
;;; ------------------------------------------------------------
(defun c:TSUZUKI ( / *error* rec)
  (defun *error* (msg) (kr:error "TSUZUKI" msg))
  (kr:start)
  (if (= 1 (getvar "SDI"))
    (princ "\n[TSUZUKI] 1図面だけを開くモード（SDI=1）のため、まとめて開けません。")
    (progn
      (setq rec (kr:dlg-open))
      (kr:dcl-unload)
      (cond
        ((eq rec 'NODIALOG)
         (princ "\n[TSUZUKI] ダイアログを表示できないため、コマンドラインで操作します。")
         (kr:open-cmd))
        ((null rec) (princ "\n[TSUZUKI] 中止しました。"))
        (T (kr:open-record rec)))))
  (kr:finish)
  (princ))

(defun c:TZ ( ) (c:TSUZUKI))

;;; ------------------------------------------------------------
;;;  KIROKUSET（KRS）
;;; ------------------------------------------------------------
(defun c:KIROKUSET ( / *error*)
  (defun *error* (msg) (kr:error "KIROKUSET" msg))
  (if (eq (kr:dlg-set) 'NODIALOG)
    (progn
      (princ "\n[KIROKUSET] ダイアログを表示できないため、コマンドラインで操作します。")
      (kr:dcl-unload)
      (kr:settings)))
  (kr:dcl-unload)
  (princ))

(defun c:KRS ( ) (c:KIROKUSET))

;;; ============================================================
;;;  コマンドライン版（-KIROKU / -TSUZUKI / -KIROKUSET）
;;;  ダイアログを出せないときも、これを使う
;;; ============================================================
(defun kr:show-records (recs / i)
  (setq i 0)
  (princ "\n──── 記録の一覧（新しい順）────")
  (foreach r recs
    (setq i (1+ i))
    (princ (strcat "\n " (if (< i 10) " " "") (itoa i) ". " (kr:rec-label r))))
  (princ "\n──────────────────────"))

;;; 一覧から番号で選ぶ → 記録 か nil
(defun kr:pick (recs msg / n done res)
  (kr:show-records recs)
  (while (not done)
    (initget 6)
    (setq n (getint (strcat "\n" msg "の番号 <中止>: ")))
    (cond ((null n) (setq done T))
          ((> n (length recs)) (princ "\n番号が範囲外です。"))
          (T (setq res (nth (1- n) recs) done T))))
  res)

(defun kr:save-cmd (info / ans name done)
  (while (not done)
    (initget "Name Settings")
    (setq ans (getkword (strcat "\n図面 " (itoa (length (car info))) " 枚を記録 [名前を付ける(N)/設定(S)] <「"
                                *kr:default-name* "」として記録>: ")))
    (cond
      ((null ans) (setq name *kr:default-name* done T))
      ((= ans "Settings") (kr:settings))
      ((= ans "Name")
       (setq name (vl-string-trim " \t" (getstring T "\n記録の名前 <中止>: ")))
       (cond
         ((= name "") (setq name nil done T))      ; Enter＝中止
         ((kr:bad-name-p name)
          (princ "\n名前に次の文字は使えません： \\ / : * ? \" < > |")
          (setq name nil))
         ((findfile (kr:file name))
          (initget "Yes No")
          (if (= "Yes" (getkword (strcat "\n「" name "」は既にあります。上書きしますか？ [はい(Y)/いいえ(N)] <いいえ>: ")))
            (setq done T)
            (setq name nil)))
         (T (setq done T))))))
  (if name (kr:save name info) (princ "\n[KIROKU] 中止しました。")))

(defun kr:open-cmd ( / recs rec ans done r)
  (if (null (setq recs (kr:records)))
    (princ (strcat "\n[TSUZUKI] 記録がありません（保存先：" (kr:folder) "）。先に KR で記録してください。"))
    (progn
      (setq rec (kr:last-rec recs))
      (while (not done)
        (initget "List Settings")
        (setq ans (getkword (strcat "\n続きを開く [一覧から選ぶ(L)/設定(S)] <" (kr:rec-label rec) ">: ")))
        (cond
          ((null ans) (setq done T))
          ((= ans "List")
           (if (setq r (kr:pick recs "開く記録"))
             (setq rec r done T)))
          ((= ans "Settings")
           (kr:settings)
           (if (null (setq recs (kr:records)))
             (setq rec nil done T)
             (if (not (member rec recs)) (setq rec (car recs)))))))
      (if rec (kr:open-record rec) (princ "\n[TSUZUKI] 記録がありません。")))))

(defun kr:settings ( / done k s recs rec)
  (while (not done)
    (setq recs (kr:records))
    (princ "\n──────── KIROKU / TSUZUKI 設定 ────────")
    (princ (strcat "\n 保存先(F) : " (kr:folder) (if (kr:folder-default-p) "（初期値）" "")))
    (princ (strcat "\n 記録の数  : " (itoa (length recs)) " 件"))
    (princ "\n──────────────────────────────")
    (initget "Folder List Delete eXit")
    (setq k (getkword "\n操作 [保存先(F)/一覧(L)/削除(D)/終了(X)] <終了>: "))
    (cond
      ((or (null k) (= k "eXit")) (setq done T))
      ((= k "Folder")
       (setq s (vl-string-trim " \t\"" (getstring T (strcat "\n保存先フォルダ（「.」で初期値に戻す） <" (kr:folder) ">: "))))
       (cond
         ((= s "") nil)
         ((= s ".") (setenv "KirokuTsuzuki_Folder" "") (princ "\n初期値に戻しました。"))
         ((kr:mkdirs (kr:slash s)) (setenv "KirokuTsuzuki_Folder" (kr:slash s)) (princ "\n保存先を変更しました。"))
         (T (princ "\nそのフォルダは使えません（作れませんでした）。"))))
      ((= k "List")
       (if recs (kr:show-records recs) (princ "\n記録はありません。")))
      ((= k "Delete")
       (if (null recs)
         (princ "\n記録はありません。")
         (if (setq rec (kr:pick recs "削除する記録"))
           (progn
             (initget "Yes No")
             (if (= "Yes" (getkword (strcat "\n" (kr:rec-label rec) " を削除しますか？ [はい(Y)/いいえ(N)] <いいえ>: ")))
               (if (vl-file-delete (nth 3 rec))
                 (progn
                   (if (= (getenv "KirokuTsuzuki_Last") (car rec)) (setenv "KirokuTsuzuki_Last" ""))
                   (princ (strcat "\n「" (car rec) "」を削除しました。")))
                 (princ "\n削除できませんでした。")))))))))
  (princ))

(defun c:-KIROKU ( / *error* info)
  (defun *error* (msg) (kr:error "KIROKU" msg))
  (kr:start)
  (setq info (kr:collect))
  (if (null (car info))
    (princ "\n[KIROKU] 記録できる図面がありません（一度も保存していない図面は記録できません）。")
    (kr:save-cmd info))
  (kr:finish)
  (princ))

(defun c:-TSUZUKI ( / *error*)
  (defun *error* (msg) (kr:error "TSUZUKI" msg))
  (kr:start)
  (if (= 1 (getvar "SDI"))
    (princ "\n[TSUZUKI] 1図面だけを開くモード（SDI=1）のため、まとめて開けません。")
    (kr:open-cmd))
  (kr:finish)
  (princ))

(defun c:-KIROKUSET ( / *error*)
  (defun *error* (msg) (kr:error "KIROKUSET" msg))
  (kr:settings)
  (princ))

(princ "\n[KirokuTsuzuki 1.1.0] 読み込み完了  KR=記録 / TZ=まとめて開く / KRS=保存先（コマンドライン版は -KIROKU など）")
(princ)

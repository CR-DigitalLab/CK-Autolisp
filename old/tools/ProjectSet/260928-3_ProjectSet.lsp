;;; ============================================================
;;;  ProjectSet.lsp   ― 開いている図面を記録して、あとでまとめて開く ―
;;;
;;;  PROJECTSET (ショートカット PJ) : 記録と再開を1つのダイアログで行う
;;;
;;;  対応 : AutoCAD 2027
;;;  版   : 1.1.2  (2026-09-28)
;;;         1.1.2: エラーの場所をさらに細かく表示（原因調査用）
;;;         1.1.1: エラーのときに「どこで起きたか」を表示するようにした
;;;                読めない記録ファイルがあっても止まらないようにした
;;;                同じ図面が2つ開いているときに二重に記録しないようにした
;;;         1.1.0: 2回目以降も「最後に使った記録」が選ばれるようにした
;;;                名前欄で Enter を押したら記録する（［開く］は動かない）
;;;                SDI=1 のときは［開く］を押せないようにした
;;;                記録したらダイアログを閉じる
;;;                名前の初期値を「選んでいる記録の名前」にした（その記録の更新は確認なしで上書き）
;;;         1.0.0: チコさん作の最初の版（KirokuTsuzuki をもとに1画面に統合）
;;;
;;;  ・図面そのものは保存しない（記録するのは図面の場所だけ）。
;;;  ・システム変数は変更しない。
;;;  ・このファイルとダイアログ定義（DCL）は ANSI（Shift-JIS）で扱う。
;;; ============================================================

(vl-load-com)

(setq *pj:ext* ".pjs")

;;; --- 保存先 ---
(defun pj:slash (p)
  (if (and p (/= p "") (/= (substr p (strlen p)) "\\")) (strcat p "\\") p))

(defun pj:folder ( / f)
  (setq f (getenv "ProjectSet_Folder"))
  (if (or (null f) (= f "")) 
    (strcat (pj:slash (getvar "ROAMABLEROOTPREFIX")) "ProjectSet\\")
    (pj:slash f)))

(defun pj:mkdirs (p / parts cur)
  (setq p (vl-string-right-trim "\\" p) cur "")
  (while (setq parts (vl-string-search "\\" p))
    (setq cur (strcat cur (substr p 1 (1+ parts))) p (substr p (+ parts 2)))
    (if (not (vl-file-directory-p cur)) (vl-mkdir cur)))
  (setq cur (strcat cur p))
  (if (not (vl-file-directory-p cur)) (vl-mkdir cur))
  (vl-file-directory-p cur))

(defun pj:file (name) (strcat (pj:folder) name *pj:ext*))

;;; --- ファイル読み書き ---
(defun pj:default-name ( / s )
  (setq s (rtos (getvar "CDATE") 2 6))
  (strcat (substr s 1 8) "_プロジェクトセット"))

(defun pj:now ( / s)
  (setq s (rtos (getvar "CDATE") 2 6))
  (strcat (substr s 1 4) "/" (substr s 5 2) "/" (substr s 7 2) " "
          (substr s 10 2) ":" (substr s 12 2)))

(defun pj:write (file date front dwgs / fh)
  (setq fh (vl-catch-all-apply 'open (list file "w" "utf8")))
  (if (vl-catch-all-error-p fh) (setq fh (open file "w")))
  (if fh
    (progn
      (write-line "PROJECTSET 1" fh)
      (write-line (strcat "DATE " date) fh)
      (write-line (strcat "FRONT " (if front front "")) fh)
      (foreach d dwgs (write-line (strcat "DWG " d) fh))
      (close fh)
      T)))

(defun pj:read (file / fh l ok date front dwgs)
  (setq fh (vl-catch-all-apply 'open (list file "r" "utf8")))
  (if (vl-catch-all-error-p fh) (setq fh (open file "r")))
  (if fh
    (progn
      (while (setq l (read-line fh))
        (cond ((wcmatch l "PROJECTSET *") (setq ok T))
              ((wcmatch l "DATE *")       (setq date (substr l 6)))
              ((wcmatch l "FRONT *")      (setq front (substr l 7)))
              ((and (wcmatch l "DWG *") (/= (substr l 5) "")          ; 空の行・同じ図面は1つに
                    (not (member (strcase (substr l 5)) (mapcar 'strcase dwgs))))
               (setq dwgs (cons (substr l 5) dwgs)))))
      (close fh)
      (if ok (list (if date date "") (if (/= front "") front) (reverse dwgs))))))

(defun pj:records ( / dir res r)
  (setq dir (pj:folder))
  (foreach f (vl-directory-files dir (strcat "*" *pj:ext*) 1)
    (if (and (setq r (vl-catch-all-apply 'pj:read (list (strcat dir f))))
             (not (vl-catch-all-error-p r))
             (listp r) r)
      (setq res (cons (list (vl-filename-base f) (car r) (length (caddr r)) (strcat dir f)) res))))
  ;; 新しい順。同じ日時なら名前順（並びが毎回同じになるように）
  (if res (vl-sort res '(lambda (a b) (or (> (cadr a) (cadr b))
                                          (and (= (cadr a) (cadr b)) (< (car a) (car b))))))))

(defun pj:get-last-idx (recs / name i res)
  (setq name (getenv "ProjectSet_Last") i 0 res 0)
  (if recs
    (foreach r recs
      (if (= (car r) name) (setq res i))
      (setq i (1+ i))))
  res)

(defun pj:bad-name-p (s)
  (or (= s "")
      (vl-some '(lambda (c) (vl-string-search c s)) '("\\" "/" ":" "*" "?" "\"" "<" ">" "|"))))

(defun pj:join (lst / s)
  (setq s "")
  (if lst (foreach x lst (setq s (if (= s "") x (strcat s "、" x)))))
  s)

;;; --- エラー・Undo処理 ---
(defun pj:start ( )
  (setq *pj:doc* (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark *pj:doc*)
  (setq *pj:undo* T))

(defun pj:finish ( )
  (pj:dcl-unload)
  (if (and *pj:doc* *pj:undo*) (progn (vla-EndUndoMark *pj:doc*) (setq *pj:undo* nil))))

;;; いま何をしているか（エラーのときに表示する）
(defun pj:step (s) (setq *pj:step* s))

(defun pj:error (tag msg)
  (pj:finish)
  (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*取消*,*キャンセル*")))
    (princ (strcat "\n[" tag "] エラー: " msg
                   (if *pj:step* (strcat "（場所：" *pj:step* "）") "")))
    (princ (strcat "\n[" tag "] 中止しました。")))
  (princ))

;;; --- 記録と再開 ---
(defun pj:collect ( / acad active dwgs front disp full nm)
  (setq acad (vlax-get-acad-object) active (vla-get-ActiveDocument acad))
  (vlax-for d (vla-get-Documents acad)
    (setq full (vla-get-FullName d) nm (vla-get-Name d))
    (cond
      ((or (= full "") (= 0 (vlax-invoke d 'GetVariable "DWGTITLED")))
       (setq disp (cons (list nm "untitled") disp)))
      ((member (strcase full) (mapcar 'strcase dwgs)) nil)   ; 同じ図面が2つ開いている → 1つとして記録
      (T
        (setq dwgs (cons full dwgs))
        (if (equal d active) (setq front full))
        (setq disp (cons (list nm nil) disp)))))
  (list (reverse dwgs) front (reverse disp)))

(defun pj:save (name info)
  (cond
    ((not (pj:mkdirs (pj:folder))) (princ "\n[PROJECTSET] 保存先フォルダを作れませんでした。") nil)
    ((not (pj:write (pj:file name) (pj:now) (cadr info) (car info))) (princ "\n[PROJECTSET] 記録ファイルに書き込めませんでした。") nil)
    (T (setenv "ProjectSet_Last" name) (princ (strcat "\n[PROJECTSET] 「" name "」に記録しました。")) T)))

(defun pj:open-names (docs / res)
  (vlax-for d docs
    (if (/= (vla-get-FullName d) "") (setq res (cons (strcase (vla-get-FullName d)) res))))
  res)

(defun pj:open-record (rec / docs data opened nopen nskip ro missing failed nd)
  (setq docs (vla-get-Documents (vlax-get-acad-object)))
  (if (setq data (pj:read (nth 3 rec)))
    (progn
      (setq opened (pj:open-names docs) nopen 0 nskip 0)
      (if (caddr data)
        (foreach f (caddr data)
          (cond
            ((member (strcase f) opened) (setq nskip (1+ nskip)))
            ((null (findfile f)) (setq missing (cons f missing)))
            (T
             (setq nd (vl-catch-all-apply 'vla-open (list docs f :vlax-false)))
             (if (vl-catch-all-error-p nd) (setq nd (vl-catch-all-apply 'vla-open (list docs f :vlax-true))))
             (if (vl-catch-all-error-p nd)
               (setq failed (cons f failed))
               (progn
                 (setq nopen (1+ nopen) opened (cons (strcase f) opened))
                 (if (= :vlax-true (vla-get-ReadOnly nd)) (setq ro (cons (vl-filename-base f) ro)))))))))
      (if (cadr data)
        (vlax-for d docs
          (if (= (strcase (vla-get-FullName d)) (strcase (cadr data)))
            (vl-catch-all-apply 'vla-Activate (list d)))))
      (setenv "ProjectSet_Last" (car rec))
      (princ (strcat "\n[PROJECTSET] 「" (car rec) "」：開いた図面 " (itoa nopen) " 枚 / 開いていた図面 " (itoa nskip) " 枚"))
      (if ro (princ (strcat "\n          ※読取専用 " (itoa (length ro)) " 枚：" (pj:join (reverse ro)))))
      (if missing (princ (strcat "\n          ※見つからない " (itoa (length missing)) " 枚：" (pj:join (mapcar 'vl-filename-base (reverse missing))))))
      (if failed (princ (strcat "\n          ※開けなかった " (itoa (length failed)) " 枚：" (pj:join (mapcar 'vl-filename-base (reverse failed)))))))
    (princ "\n[PROJECTSET] 記録ファイルを読めませんでした。")))

;;; --- ダイアログUI（縦長レイアウト） ---
(setq *pj:dcl-lines*
  '("pj_main : dialog {"
    "  label = \"プロジェクトの記録と再開（PROJECTSET）\";"
    "  : column {"
    "    : boxed_column {"
    "      label = \"記録する\";"
    "      : text { key = \"head\"; width = 65; }"
    "      : list_box { key = \"save_files\"; width = 65; height = 10; }"
    "      : row {"
    "        : edit_box { key = \"name\"; label = \"名前：\"; edit_width = 45; }"
    "        : button { key = \"btn_save\"; label = \"記録する\"; width = 12; fixed_width = true; }"
    "      }"
    "      : text { key = \"save_note\"; width = 65; }"
    "    }"
    "    : boxed_column {"
    "      label = \"記録から開く\";"
    "      : row {"
    "        : column {"
    "          : text { label = \"記録リスト\"; }"
    "          : list_box { key = \"recs\"; width = 30; height = 10; }"
    "          : row {"
    "            : button { key = \"btn_ren\"; label = \"名前変更\"; width = 14; fixed_width = true; }"
    "            : button { key = \"btn_del\"; label = \"削除\"; width = 14; fixed_width = true; alignment = right; }"
    "          }"
    "        }"
    "        : column {"
    "          : text { key = \"fhead\"; width = 45; }"
    "          : list_box { key = \"open_files\"; width = 45; height = 10; }"
    "          : button { key = \"btn_open\"; label = \"開く\"; width = 45; fixed_width = true; is_default = true; }"
    "        }"
    "      }"
    "      : text { key = \"open_msg\"; width = 80; }"
    "    }"
    "  }"
    "  : row {"
    "    : boxed_row {"
    "      : text { key = \"folder\"; width = 65; }"
    "      : button { key = \"chfolder\"; label = \"保存先の変更...\"; width = 16; fixed_width = true; }"
    "    }"
    "    : button { key = \"cancel\"; label = \"閉じる\"; is_cancel = true; width = 14; fixed_width = true; alignment = right; }"
    "  }"
    "}"
    "pj_ren : dialog {"
    "  label = \"名前を変更\";"
    "  : text { label = \"新しい名前を入力してください：\"; }"
    "  : edit_box { key = \"new_name\"; edit_width = 50; }"
    "  : text { key = \"ren_err\"; width = 50; }"
    "  : row {"
    "    : spacer { width = 1; }"
    "    : button { key = \"btn_ok\"; label = \"OK\"; is_default = true; width = 12; fixed_width = true; }"
    "    : button { key = \"btn_cancel\"; label = \"キャンセル\"; is_cancel = true; width = 12; fixed_width = true; }"
    "    : spacer { width = 1; }"
    "  }"
    "}"))

(defun pj:dcl-load ( / fh id)
  (if (null *pj:dcl-id*)
    (progn
      (setq *pj:dcl-file* (vl-filename-mktemp "projectset" nil ".dcl"))
      (if (setq fh (open *pj:dcl-file* "w"))
        (progn
          (foreach l *pj:dcl-lines* (write-line l fh))
          (close fh)
          (setq id (load_dialog *pj:dcl-file*))
          (if (and id (> id 0)) (setq *pj:dcl-id* id))))))
  *pj:dcl-id*)

(defun pj:dcl-unload ( )
  (if *pj:dcl-id* (progn (vl-catch-all-apply 'unload_dialog (list *pj:dcl-id*)) (setq *pj:dcl-id* nil)))
  (if (and *pj:dcl-file* (findfile *pj:dcl-file*)) (vl-file-delete *pj:dcl-file*))
  (setq *pj:dcl-file* nil))

(defun pj:fname (f) (strcat (vl-filename-base f) (cond ((vl-filename-extension f)) (""))))

(defun pj:fill-list (key items)
  (start_list key)
  (if items (foreach it items (add_list it)))
  (end_list))

(defun pj:pad (s n / w)
  (setq w 0)
  (if s (foreach c (vl-string->list s) (setq w (+ w (if (> c 255) 2 1)))))
  (while (< w n) (setq s (strcat s " ") w (1+ w)))
  s)

(defun pj:browse-folder (msg / sh f p)
  (if (setq sh (vl-catch-all-apply 'vlax-create-object (list "Shell.Application")))
    (if (not (vl-catch-all-error-p sh))
      (progn
        (setq f (vl-catch-all-apply 'vlax-invoke-method (list sh 'BrowseForFolder 0 msg 64)))
        (if (and f (not (vl-catch-all-error-p f)))
          (setq p (vl-catch-all-apply 'vlax-get-property (list (vlax-get-property f 'Self) 'Path))))
        (vlax-release-object sh))))
  (if (and p (not (vl-catch-all-error-p p)) (/= p "")) (pj:slash p)))

(defun pj:change-folder ( / p)
  (if (setq p (pj:browse-folder "記録ファイルの保存先を選んでください"))
    (if (pj:mkdirs p) (progn (setenv "ProjectSet_Folder" p) T))))

(defun pj:dlg-save-check ( / nm )
  (pj:step "記録する")
  (setq nm (vl-string-trim " \t" (get_tile "name")))
  (cond
    ((= nm "") (set_tile "save_note" "記録の名前を入れてください。"))
    ((pj:bad-name-p nm) (set_tile "save_note" "名前に次の文字は使えません： \\ / : * ? \" < > |"))
    ((and (findfile (pj:file nm)) (/= *pj:confirm* nm)
          (/= nm (car (nth *pj:sel* *pj:recs*))))      ; 選んでいる記録の更新は確認しない
     (setq *pj:confirm* nm)
     (set_tile "save_note" (strcat "「" nm "」は既にあります。もう一度［記録する］で上書きします。")))
    (T (setq *pj:dlg-name* nm) (done_dialog 3))))

(defun pj:dlg-del-check ( / rec )
  (pj:step "記録の削除")
  (if (and *pj:recs* (setq rec (nth *pj:sel* *pj:recs*)))
    (if (/= *pj:delconf* (car rec))
      (progn
        (setq *pj:delconf* (car rec))
        (set_tile "open_msg" (strcat "「" (car rec) "」を削除します。もう一度［削除］で実行します。")))
      (done_dialog 4))))

(defun pj:dlg-ren-validate ( / nm )
  (setq nm (vl-string-trim " \t" (get_tile "new_name")))
  (cond
    ((= nm "") (set_tile "ren_err" "名前を入力してください。"))
    ((pj:bad-name-p nm) (set_tile "ren_err" "名前に次の文字は使えません： \\ / : * ? \" < > |"))
    ((and (/= (strcase nm) (strcase *pj:ren-old*)) (findfile (pj:file nm)))
     (set_tile "ren_err" "その名前の記録は既に存在します。"))
    (T (setq *pj:ren-name* nm) (done_dialog 1))))

(defun pj:do-rename ( / rec oldf newf )
  (pj:step "名前の変更")
  (if (and *pj:recs* (setq rec (nth *pj:sel* *pj:recs*)))
    (progn
      (setq *pj:ren-old* (car rec))
      (if (new_dialog "pj_ren" *pj:dcl-id*)
        (progn
          (set_tile "new_name" *pj:ren-old*)
          (mode_tile "new_name" 2)
          (action_tile "btn_ok" "(pj:dlg-ren-validate)")
          (action_tile "btn_cancel" "(done_dialog 0)")
          (if (= (start_dialog) 1)
            (progn
              (setq oldf (nth 3 rec) newf (pj:file *pj:ren-name*))
              (if (not (equal (strcase oldf) (strcase newf)))
                (if (vl-file-rename oldf newf)
                  (progn
                    (if (= (getenv "ProjectSet_Last") *pj:ren-old*)
                      (setenv "ProjectSet_Last" *pj:ren-name*))
                    (setq *pj:dlg-name* *pj:ren-name* *pj:want* *pj:ren-name*)   ; 名前を変えた記録を選んだまま
                    (done_dialog 5))
                  (set_tile "open_msg" (strcat "「" *pj:ren-old* "」の名前変更に失敗しました。")))
                (done_dialog 5)))))))))

(defun pj:dlg-update-open ( / rec data nopen nskip nmiss items st old)
  (setq old *pj:step*)
  (pj:step "記録の図面の表示")
  (if (and *pj:recs* (setq rec (nth *pj:sel* *pj:recs*)))
    (progn
      (setq data (pj:read (nth 3 rec)) nopen 0 nskip 0 nmiss 0)
      (if (caddr data)
        (foreach f (caddr data)
          (setq st (cond ((member (strcase f) *pj:opened*) (setq nskip (1+ nskip)) "※すでに開いています")
                         ((null (findfile f)) (setq nmiss (1+ nmiss)) "※見つかりません")
                         (T (setq nopen (1+ nopen)) nil))
                items (cons (if st (strcat (pj:pad (pj:fname f) 45) st) (pj:fname f)) items))))
      (pj:fill-list "open_files" (reverse items))
      (set_tile "fhead" (strcat "「" (car rec) "」の図面 " (itoa (length (caddr data))) " 枚"
                               "（開く " (itoa nopen) " 枚"
                               (if (> nskip 0) (strcat "・開いている " (itoa nskip) " 枚") "")
                               (if (> nmiss 0) (strcat "・見つからない " (itoa nmiss) " 枚") "") "）"))
      (mode_tile "btn_open" (if (and (> nopen 0) (not *pj:sdi*)) 0 1))
      (if *pj:sdi* (set_tile "open_msg" "1図面だけを開くモード（SDI=1）のため、まとめて開けません（記録はできます）。"))
      (mode_tile "btn_ren" 0)
      (mode_tile "btn_del" 0))
    (progn
      (pj:fill-list "open_files" nil)
      (set_tile "fhead" "")
      (mode_tile "btn_open" 1)
      (mode_tile "btn_ren" 1)
      (mode_tile "btn_del" 1)))
  (pj:step old))

(defun pj:dlg-update-recs ( )
  (pj:fill-list "recs" (if *pj:recs* (mapcar '(lambda (r) (strcat (pj:pad (car r) 22) (itoa (caddr r)) "枚")) *pj:recs*)))
  (if *pj:recs*
    (progn (set_tile "recs" (itoa *pj:sel*)) (set_tile "open_msg" ""))
    (set_tile "open_msg" "記録がありません。上部の［記録する］で図面を記録してください。"))
  (pj:dlg-update-open))

(defun pj:dlg-open-pick (val reason)
  (pj:step "記録を選んだとき")
  (setq *pj:sel* (atoi val) *pj:delconf* nil *pj:confirm* nil)
  (set_tile "open_msg" "")
  (if (nth *pj:sel* *pj:recs*) (set_tile "name" (car (nth *pj:sel* *pj:recs*))))
  (set_tile "save_note" *pj:save-note*)
  (pj:dlg-update-open)
  (if (and (= reason 4) (not *pj:sdi*) *pj:recs* (nth *pj:sel* *pj:recs*)) (done_dialog 1)))

(defun pj:dlg-open-accept ( )
  (pj:step "［開く］を押したとき")
  (cond (*pj:sdi* nil)
        ((and *pj:recs* (nth *pj:sel* *pj:recs*)) (done_dialog 1))
        (T (set_tile "open_msg" "開く記録を選んでください。"))))

(setq *pj:save-note* "名前が同じ記録は上書きされます（新しく記録するときは名前を変えてください）。")

(defun pj:dlg-main ( / r done res info disp)
  (setq *pj:opened* (pj:open-names (vla-get-Documents (vlax-get-acad-object)))
        *pj:dlg-name* nil
        *pj:sel* nil *pj:want* nil                   ; 毎回「最後に使った記録」から
        *pj:sdi* (= 1 (getvar "SDI")))
  (pj:step "ダイアログの読み込み")
  (if (not (pj:dcl-load)) (setq done T res nil))
  
  (while (not done)
    (pj:step "開いている図面の確認")
    (setq info (pj:collect))
    (pj:step "記録の読み込み")
    (setq *pj:recs* (pj:records))
    (pj:step "記録の選択")
    
    (if (and *pj:want* (vl-position *pj:want* (mapcar 'car *pj:recs*)))
      (setq *pj:sel* (vl-position *pj:want* (mapcar 'car *pj:recs*))))
    (setq *pj:want* nil)
    (if (not *pj:recs*)
      (setq *pj:sel* 0)
      (if (or (null *pj:sel*) (>= *pj:sel* (length *pj:recs*)))
        (setq *pj:sel* (pj:get-last-idx *pj:recs*))))
          
    (pj:step "ダイアログの表示")
    (if (not (new_dialog "pj_main" *pj:dcl-id*))
      (setq done T)
      (progn
        (setq *pj:delconf* nil *pj:confirm* nil)
        
        (pj:step "ダイアログの表示（見出し）")
        (set_tile "head" (strcat "記録される図面 " (itoa (length (car info))) " 枚"))
        (pj:step "ダイアログの表示（記録する図面の一覧）")
        (setq disp (nth 2 info))
        (pj:fill-list "save_files"
          (if disp
            (mapcar '(lambda (x)
                       (if (= (cadr x) "untitled")
                         (strcat (pj:pad (car x) 45) "※一度も保存していないため記録不可")
                         (car x)))
                    disp)))
        (pj:step "ダイアログの表示（名前の初期値）")
        (set_tile "name" (cond ((car (nth *pj:sel* *pj:recs*))) ((pj:default-name))))
        (pj:step "ダイアログの表示（注意書き・ボタン）")
        (set_tile "save_note" *pj:save-note*)
        (if (null (car info)) (mode_tile "btn_save" 1))
        
        (pj:step "記録の一覧の表示")
        (pj:dlg-update-recs)
        (pj:step "ダイアログの表示（保存先）")
        (set_tile "folder" (strcat "記録の保存先：" (pj:folder)))

        (pj:step "ダイアログの表示（ボタンの動作）")
        (action_tile "btn_save" "(pj:dlg-save-check)")
        (action_tile "name" "(if (= $reason 1) (pj:dlg-save-check))")   ; 名前欄で Enter＝記録
        (action_tile "recs" "(pj:dlg-open-pick $value $reason)")
        (action_tile "btn_ren" "(pj:do-rename)")
        (action_tile "btn_del" "(pj:dlg-del-check)")
        (action_tile "btn_open" "(pj:dlg-open-accept)")
        (action_tile "chfolder" "(done_dialog 2)")
        (action_tile "cancel" "(done_dialog 0)")

        (pj:step "ダイアログの操作中")
        (setq r (start_dialog))
        (pj:step "ダイアログを閉じた後の処理")
        
        (cond
          ((= r 1) (setq res (nth *pj:sel* *pj:recs*) done T))
          ((= r 2) (if (pj:change-folder) (setq *pj:sel* nil)))
          ((= r 3)                                   ; 記録して閉じる
           (if (and *pj:dlg-name* (car info)) (pj:save *pj:dlg-name* info))
           (setq done T))
          ((= r 4)
           (if (and *pj:recs* (nth *pj:sel* *pj:recs*))
             (progn
               (vl-file-delete (nth 3 (nth *pj:sel* *pj:recs*)))
               (if (= (getenv "ProjectSet_Last") (car (nth *pj:sel* *pj:recs*))) (setenv "ProjectSet_Last" "")))))
          ((= r 5) nil) ; 名前変更によるUIリロード用
          (T (setq done T))
        )
      )
    )
  )
  res
)

;;; --- コマンド ---
(defun c:PROJECTSET ( / *error* res )
  (defun *error* (msg) (pj:error "PROJECTSET" msg))
  (pj:step "開始")
  (pj:start)
  (setq res (pj:dlg-main))
  (if (and res (listp res))
    (progn (pj:dcl-unload) (pj:step "図面を開く") (pj:open-record res)))
  (pj:step "終了")
  (pj:finish)
  (setq *pj:step* nil)
  (princ)
)

(defun c:PJ ( ) (c:PROJECTSET))
(princ)
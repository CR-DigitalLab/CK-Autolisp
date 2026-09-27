;;; ============================================================
;;;  KirokuTsuzuki.lsp   ― 開いている図面を記録して、あとでまとめて開く ―
;;;
;;;  KIROKU    (ショートカット KR ) : 開いている図面の一覧を記録する
;;;  TSUZUKI   (ショートカット TZ ) : 記録した図面をまとめて開く
;;;  KIROKUSET (ショートカット KRS) : 設定（保存先・記録の一覧・削除）
;;;
;;;  対応 : AutoCAD 2027
;;;  版   : 1.0.0  (2026-09-27)
;;;
;;;  ・KR → Enter で「前回」として記録。N で名前を付けて記録。
;;;  ・TZ → Enter で最後に記録したものを開く。L で一覧から選ぶ。
;;;  ・図面そのものは保存しない（記録するのは図面の場所だけ）。
;;;  ・システム変数は変更しない。
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

(defun kr:rec-label (rec)
  (strcat "「" (car rec) "」 " (cadr rec) "・" (itoa (caddr rec)) "枚"))

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
  (if (and *kr:doc* *kr:undo*) (progn (vla-EndUndoMark *kr:doc*) (setq *kr:undo* nil))))

(defun kr:error (tag msg)
  (kr:finish)
  (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
    (princ (strcat "\n[" tag "] エラー: " msg))
    (princ (strcat "\n[" tag "] 中止しました。")))
  (princ))

;;; ------------------------------------------------------------
;;;  KIROKU（KR）：開いている図面を記録
;;; ------------------------------------------------------------
(defun c:KIROKU ( / *error* acad active front dwgs modified untitled d full ans name file done)
  (defun *error* (msg) (kr:error "KIROKU" msg))
  (kr:start)
  (setq acad (vlax-get-acad-object)
        active (vla-get-ActiveDocument acad))

  ;; 開いている図面を集める
  (vlax-for d (vla-get-Documents acad)
    (setq full (vla-get-FullName d))
    (if (or (= full "") (= 0 (vlax-invoke d 'GetVariable "DWGTITLED")))
      (setq untitled (cons (vla-get-Name d) untitled))
      (progn
        (setq dwgs (cons full dwgs))
        (if (/= 0 (vlax-invoke d 'GetVariable "DBMOD"))
          (setq modified (cons (vla-get-Name d) modified)))
        (if (equal d active) (setq front full)))))
  (setq dwgs (reverse dwgs) modified (reverse modified) untitled (reverse untitled))

  (if (null dwgs)
    (princ "\n[KIROKU] 記録できる図面がありません（一度も保存していない図面は記録できません）。")
    (progn
      ;; 名前を決める
      (while (not done)
        (initget "Name Settings")
        (setq ans (getkword (strcat "\n図面 " (itoa (length dwgs)) " 枚を記録 [名前を付ける(N)/設定(S)] <「"
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

      (cond
        ((null name)
         (princ "\n[KIROKU] 中止しました。"))
        ((not (kr:mkdirs (kr:folder)))
         (princ (strcat "\n[KIROKU] 保存先フォルダを作れませんでした：" (kr:folder)
                        "\n          KRS（設定）で保存先を確認してください。")))
        ((not (kr:write (setq file (kr:file name)) (kr:now) front dwgs))
         (princ (strcat "\n[KIROKU] 記録ファイルに書き込めませんでした：" file)))
        (T
         (setenv "KirokuTsuzuki_Last" name)
         (princ (strcat "\n[KIROKU] 「" name "」に図面 " (itoa (length dwgs)) " 枚を記録しました。"))
         (if modified
           (princ (strcat "\n          ※保存していない変更がある図面 " (itoa (length modified)) " 枚："
                          (kr:join modified) "（図面の保存は別に行ってください）")))
         (if untitled
           (princ (strcat "\n          ※一度も保存していないため記録できない図面 " (itoa (length untitled)) " 枚："
                          (kr:join untitled))))))))
  (kr:finish)
  (princ))

(defun c:KR ( ) (c:KIROKU))

;;; ------------------------------------------------------------
;;;  TSUZUKI（TZ）：記録した図面をまとめて開く
;;; ------------------------------------------------------------
(defun kr:open-names (docs / res)
  (vlax-for d docs
    (if (/= (vla-get-FullName d) "") (setq res (cons (strcase (vla-get-FullName d)) res))))
  res)

(defun c:TSUZUKI ( / *error* acad docs recs lastname rec ans done data opened nopen nskip
                     ro missing failed nd r d)
  (defun *error* (msg) (kr:error "TSUZUKI" msg))
  (kr:start)
  (setq acad (vlax-get-acad-object) docs (vla-get-Documents acad))

  (cond
    ((= 1 (getvar "SDI"))
     (princ "\n[TSUZUKI] 1図面だけを開くモード（SDI=1）のため、まとめて開けません。"))
    ((null (setq recs (kr:records)))
     (princ (strcat "\n[TSUZUKI] 記録がありません（保存先：" (kr:folder) "）。先に KR で記録してください。")))
    (T
     ;; どの記録を開くか
     (setq lastname (getenv "KirokuTsuzuki_Last")
           rec  (cond ((car (vl-remove-if-not '(lambda (x) (= (car x) lastname)) recs)))
                      ((car recs))))
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

     (if (and rec (setq data (kr:read (nth 3 rec))))
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
       (princ (if rec "\n[TSUZUKI] 記録ファイルを読めませんでした。" "\n[TSUZUKI] 記録がありません。")))))
  (kr:finish)
  (princ))

(defun c:TZ ( ) (c:TSUZUKI))

;;; ------------------------------------------------------------
;;;  設定（KIROKUSET / KRS）
;;; ------------------------------------------------------------
(defun kr:settings ( / done k s recs rec)
  (while (not done)
    (setq recs (kr:records))
    (princ "\n──────── KIROKU / TSUZUKI 設定 ────────")
    (princ (strcat "\n 保存先(F) : " (kr:folder)
                   (if (member (getenv "KirokuTsuzuki_Folder") '(nil "")) "（初期値）" "")))
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

(defun c:KIROKUSET ( / *error*)
  (defun *error* (msg) (kr:error "KIROKUSET" msg))
  (kr:settings)
  (princ))

(defun c:KRS ( ) (c:KIROKUSET))

(princ "\n[KirokuTsuzuki 1.0.0] 読み込み完了  KIROKU(KR)=記録 / TSUZUKI(TZ)=まとめて開く / KIROKUSET(KRS)=設定")
(princ)

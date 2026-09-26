;;; gz_msgbox 各種のメッセージボックス関数 DCL不要版
;;; 関連ファイル：なし
;;; ダイアログファイルは、temp フォルダに生成する形になっています。
;;; グローバル変数： 
;;;    *ms_msgbox_chk* ： gz:lspInputBox3 用のチェック項目ラベル文字列

; バージョン
(defun gz_msgbox_ver () (princ "\nGZ_MsgBox --- ver1.6 (MIT License)"))

; グローバル変数（生成 DCLファイルのパス）
(setq *gz_msgboxdcl* (strcat (getenv "temp") "\\gz_msgbox_dclless.dcl"))
;;; ------------------------------------------------------------------
;;; ダイアログの種類      --- 対応する関数
;;; ------------------------------------------------------------------
;;; [OK]-[Cancel]         --- gz:lspOkCancel
;;; [Yes]-[No]            --- gz:lspYesNo
;;; [OK]                  --- gz:lspOkOnly
;;; [Yes]-[No]-[Cancel]   --- gz:lspYesNoCancel
;;; [OK]-[Cancel]         --- gz:lspRetryCancel
;;; 
;;; 戻り値 OK=T、キャンセル=nil、No="F"
;;; 
;;; ------------------------------------------------------------------
;;; ダイアログの種類      --- 対応する関数
;;; ------------------------------------------------------------------
;;; [パスワード入力]      --- gz:lspGetPass
;;; [Inputbox]            --- gz:lspInputBox  (ボタンが横にあるタイプ)
;;;                       --- gz:lspInputBox2 (ボタンが下にあるタイプ)
;;;                       --- gz:lspInputBox3 (ボタンが下+チェック欄が一つあるタイプ)
;;; [Combobox]            --- gz:lspComboBox
;;; [Listbox]             --- gz:lspListBox
;;; [Listbox]             --- gz:lspListBoxMlti (複数選択可)
;;;
;;; 戻り値 OK=文字列、キャンセル=nil
;;;
;;; ------------------------------------------------------------------
;;; ダイアログの種類      --- 対応する関数
;;; ------------------------------------------------------------------
;;; [フォルダ選択]        --- gz:lspbrowsefolder
;;;
;;; 戻り値 フォルダ名の文字列
;;; ------------------------------------------------------------------
;;; [popup] WSH の popup メソッドを使ったMSGボックス --- gz:popup
;;; 
;;; 戻り値 OK=1,キャンセル=2, 中止=3, 再試行=4, 無視=5, 
;;;        はい=6, いいえ=7, 再実行=10, 続行=11
;;; 
;;; ------------------------------------------------------------------
; ライセンス（MIT License）
; Copyright (c) 2021 - Hiroki Sugihara
; 
; 以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル
; （以下「ソフトウェア」）の複製を取得するすべての人に対し、ソフトウェアを
; 無制限に扱うことを無償で許可します。これには、ソフトウェアの複製を使用、複写、
; 変更、結合、掲載、頒布、サブライセンス、および/または販売する権利、および
; ソフトウェアを提供する相手に同じことを許可する権利も無制限に含まれます。

; 上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な
; 部分に記載するものとします。

; ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの
; 保証もなく提供されます。ここでいう保証とは、商品性、特定の目的への適合性、
; および権利非侵害についての保証も含みますが、それに限定されるものではありません。 
; 作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、
; ソフトウェアに起因または関連し、あるいはソフトウェアの使用またはその他の
; 扱いによって生じる一切の請求、損害、その他の義務について何らの責任も負わない
; ものとします。
;;; ------------------------------------------------------------------

(defun msgchk (m )
; メッセージの文字列チェックとリスト化。
; 単純な文字列だったらリスト化する。
; 文字列リストは、5個まで空文字追加。
  (if (and (/= 'STR  (type m)) (/= 'LIST (type m)))
    (setq m '("not strings")))
  (if (= 'STR (type m)) (setq m (list m)))
  (while (<= (length m) 4) (setq m (append m '(""))))
m)

(defun gz:LispEd (txt / dcl_id dcl state)
; シンプルな1行の文字列編集ダイアログコマンド（autocad の lisped 関数対処用）
; 入力された文字列を返す
; メッセージラベル付きがいいなら gz:lspInputBox を使いましょう。
; ex. (gz:LispEd "txt")
  (gz_msgbox_dclexport) ; DCL 生成
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspEd" dcl_id)) (exit))
  (set_tile "contents" txt)
  (mode_tile "contents" 2)
  (action_tile "contents" "(setq txt $value)")
  (action_tile "accept" "(done_dialog 1)")
  (setq state (start_dialog))
  (unload_dialog dcl_id)
  (cond
    ((= state 1) txt)
    ((= state 2) -1)
    (t 0)
  )
)

(defun gz:lspOkCancel (title msg1 / result dcl_id)
; title = ダイアログのタイトル文字列
; msg1 = メッセージ文字列または文字列のリスト ("メッセージ1" "メッセージ2" "メッセージ3")
;        3つ目以降は無視される
; 戻り値 : T or nil
; ex. (gz:lspOkCancel "文字列1" "OK-Cancel メッセージボックス")
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspOkCancel" dcl_id))  (exit))
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" title)
  (action_tile "cancel" "(done_dialog) (setq result nil)")
  (action_tile "accept" "(done_dialog) (setq result T)")
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspYesNo (main msg1 / result dcl_id)
; (gz:lspYesNo "文字列1" "Yes-No メッセージボックス")
; 戻り値 : T or "F"
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspYesNo" dcl_id))  (exit))
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" main)
  (action_tile "no"  "(done_dialog) (setq result \"F\")")
  (action_tile "yes" "(done_dialog) (setq result T)" )
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspOkOnly (main msg1 / dcl_id)
; (lspOkOnly "文字列1" "OK のみメッセージボックス")
; 戻り値 : T のみ
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspOkOnly" dcl_id)) (exit) )
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" main)
  (action_tile "yes" "(done_dialog)")
  (start_dialog)
  (unload_dialog dcl_id)
T)

(defun gz:lspYesNoCancel (main msg1 / result dcl_id)
;(gz:lspYesNoCancel "文字列1" "Yes-No-Cancel メッセージボックス")
; 戻り値 : T or nil or  "F"
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspYesNoCancel" dcl_id))    (exit)  )
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" main)
  (action_tile "no"  "(done_dialog) (setq result \"F\")")
  (action_tile "yes" "(done_dialog) (setq result T)" )
  (action_tile "cancel" "(done_dialog) (setq result nil)")
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspRetryCancel (main msg1 / result dcl_id)
; (gz:lspRetryCancel "lspRetryCancel" "lspRetryCancelボックス")
; 戻り値 : T or nil
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspRetryCancel" dcl_id))    (exit)  )
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" main)
  (action_tile "cancel" "(done_dialog) (setq result nil)")
  (action_tile "retry" "(done_dialog) (setq result T)")
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspGetPass (main msg1 / result dcl_id)
; (gz:lspGetPass "メッセージ1" "lspGetPass ボックス")
; 戻り値 : パスワードの文字列 or nil
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1 (msgchk msg1))
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspGetPass" dcl_id))    (exit)  )
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (set_tile "main" main)
  (action_tile "password" "(setq result $value)") 
  (action_tile "cancel" "(done_dialog) (setq result nil)")
  (action_tile "accept" "(done_dialog)")
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspInputBox (main msg1 / result dcl_id)
; ex. (gz:lspInputBox "なんか入力して" "インプットボックス")
; 戻り値 : テキストボックスの文字列 or nil
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1  (msgchk msg1) 
        result "")
  (while (= "" result)
    (setq dcl_id (load_dialog *gz_msgboxdcl*))
    (if (not (new_dialog "lspInputBox" dcl_id))    (exit)  )
    (set_tile "message1" (car msg1))
    (set_tile "message2" (cadr msg1))
    (set_tile "message3" (caddr msg1))
    (set_tile "message4" (nth 3 msg1))
    (set_tile "main" main)
    (action_tile "textbox" "(setq result $value)") 
    (action_tile "cancel" "(done_dialog) (setq result nil)")
    (action_tile "accept" "(done_dialog)")
    (start_dialog)
    (unload_dialog dcl_id)
  )
result)

(defun gz:lspInputBox2 (main msg1 def / result dcl_id)
; ex. (gz:lspInputBox2 "なんか入力して" "インプットボックス" "初期値")
; 戻り値 : テキストボックスの文字列 or nil
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1  (msgchk msg1) 
        result "")
  (while (= "" result)
    (setq dcl_id (load_dialog *gz_msgboxdcl*))
    (if (not (new_dialog "lspInputBox2" dcl_id))    (exit)  )
    (set_tile "message1" (car msg1))
    (set_tile "message2" (cadr msg1))
    (set_tile "message3" (caddr msg1))
    (set_tile "message4" (nth 3 msg1))
    (set_tile "textbox"  def)
    (set_tile "main" main)
    (action_tile "textbox" "(setq result $value)") 
    (action_tile "cancel" "(done_dialog) (setq result nil)")
    (action_tile "accept" "(done_dialog)")
    (start_dialog)
    (unload_dialog dcl_id)
  )
result)

(defun gz:lspInputBox3 (main msg1 def chklabel chk / dcl_id result ret_chk)
; 引数 chk
; ex. (gz:lspInputBox3 "なんか入力して" "インプットボックス" "初期値" "チェック" "1")
; 戻り値 : テキストボックスの文字列とチェック項目のON/OFF のリスト or nil
; -> ("テキストボックスの文字列" "1")
  (setq msg1    (msgchk msg1)
        result  "" 
        ret_chk ""
        *ms_msgbox_chk* chklabel)
  (gz_msgbox_dclexport) ; DCL 生成
  (if (or (= "1" chk) (= 1 chk)) ; チェックボックスの引数チェック
   (setq ret_chk "1")
   (setq ret_chk "0")
  )
  (while (= "" result)
    (setq dcl_id (load_dialog *gz_msgboxdcl*))
    (if (not (new_dialog "lspInputBox3" dcl_id))    (exit)  )
    (set_tile "message1" (car msg1))
    (set_tile "message2" (cadr msg1))
    (set_tile "message3" (caddr msg1))
    (set_tile "message4" (nth 3 msg1))
    (set_tile "chk1"     ret_chk)
    (set_tile "textbox"  def)
    (set_tile "main"     main)
    (action_tile "chk1"    "(setq ret_chk $value)")
    (action_tile "textbox" "(setq result $value)") 
    (action_tile "cancel"  "(done_dialog) (setq result nil)")
    (action_tile "accept"  "(done_dialog)")
    (start_dialog)
    (unload_dialog dcl_id)
  )

; 返り値
(if result 
  (list result ret_chk)
  nil)
)


(defun gz:lspComboBox (main msg1 lst / result dcl_id)
; ex. (gz:lspComboBox "xxxxなんで選んで" "コンボボックス" '("aaa" "AA" "あああ" "ぁぁぁ" "1234567890"))
; 戻り値 : ポップアップリストの値 or nil
  (gz_msgbox_dclexport) ; DCL 生成
  (setq msg1  (msgchk msg1) 
        result "")
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog "lspCombobox" dcl_id))    (exit)  )
  (set_tile "main" main)
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (start_list "poplist")                   ; ポップアップリストの追加
    (mapcar 'add_list lst)
  (end_list)
  (set_tile "poplist" "0")
  (action_tile "poplist" "(setq result $value)") 
  (action_tile "cancel" "(setq result nil) (done_dialog)")
  (action_tile "accept" "(setq result (get_tile \"poplist\")) (done_dialog) ")
  (start_dialog)
  (unload_dialog dcl_id)
result)

(defun gz:lspListBox (main msg1 lst / result dcl_id)
; ex. (gz:lspListBox "xxxxなんか選んで" "リスト" '("aaa" "AA" "あああ" "ぁぁぁ" "1234567890"))
; 戻り値 : 選択したリストボックスインデックス値の文字列 or nil    ex. "2"
; 引数 msg1 が "lspListbox0 の場合 "メッセージ無しタイプ" で表示
  (gz_msgbox_dclexport) ; DCL 生成
  (setq dcltype (if msg1 "lspListbox" "lspListbox0"))
  (setq msg1  (msgchk msg1) 
        result "")
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog dcltype dcl_id))  (exit))
  (set_tile "main" main)
  (set_tile "message1" (car msg1))
  (set_tile "message2" (cadr msg1))
  (set_tile "message3" (caddr msg1))
  (start_list "listbox")                   ; リストの追加
    (mapcar 'add_list lst)
  (end_list)
  (set_tile "listbox" "0")
  (action_tile "listbox" "(setq result $value)")
  (action_tile "cancel" "(setq result nil) (done_dialog)")
  (action_tile "accept" "(setq result (get_tile \"listbox\")) (done_dialog) ")
  (start_dialog) 
  (unload_dialog dcl_id)
  
result)

(defun gz:lspListBoxMulti (main msg1 lst / dcltype msg2 result dcl_id)
; msg1 = nil なら メッセージ無しタイプのダイアログを読み込み
; ex. (gz:lspListBoxMulti "何個か選んでぇ" "リスト" '("aaa" "AA" "あああ" "ぁぁぁ" "1234567890"))
; ex. (gz:lspListBoxMulti "何個か選んでぇ" nil '("aaa" "AA" "あああ" "ぁぁぁ" "1234567890"))
; 戻り値 : 選択したリストボックスインデックス値の文字列(スペース区切り) or nil
; ex. "2 3 6"

  (gz_msgbox_dclexport) ; DCL 生成
  ;"lspListboxMulti0 = メッセージ無しタイプ"
  (setq dcltype (if msg1 "lspListboxMulti" "lspListboxMulti0"))
  (setq msg2  (msgchk msg1) 
        result "")
  (setq dcl_id (load_dialog *gz_msgboxdcl*))
  (if (not (new_dialog dcltype dcl_id))  (exit))
  (set_tile "main" main)
  (if msg1 (progn
    (set_tile "message1" (car msg2))
    (set_tile "message2" (cadr msg2))
    (set_tile "message3" (caddr msg2))
  ))
  (start_list "listbox")                   ; リストの追加
 (mapcar 'add_list lst)
  (end_list)
  (action_tile "listbox" "(setq result $value)")
  (action_tile "cancel" "(setq result nil) (done_dialog)")
  (action_tile "accept" "(setq result (get_tile \"listbox\")) (done_dialog) ")
  (start_dialog) 
  (unload_dialog dcl_id)
  
  ; スペース区切りの文字列が返ってくるが、以下の形でリスト化できる
  (setq ret_list (read (strcat "(" result ")" )))
  ; 選択された項目だけのリストを返す
  (mapcar '(lambda (x) (nth x lst))  ret_list)
)

;;; ------------------------------------------------------------------
(defun gz:lspbrowsefolder (title folder / shlobj fldobj)
; フォルダ選択ダイアログの関数
; 戻り値：選択したフォルダのパス
; ex. (gz:lspbrowsefolder "○○のフォルダを選択" nil)
  (vl-load-com)
  (setq shlobj (vla-getinterfaceobject
                 (vlax-get-acad-object)  "Shell.Application")
        folder (vlax-invoke-method 
                  shlobj 
                   'browseforfolder 
                   0 
                   title 
                   (+ 4 16 64 256 32768) ; フォルダ参照の動作オプション
                   folder)
  )
  (vlax-release-object shlobj)
  (if folder
    (progn
      (setq fldobj (vlax-get-property folder 'self)
            folderName (vlax-get-property fldobj 'path) )
      (vlax-release-object folder)
      (vlax-release-object fldobj)
      folderName
)))

;;; ------------------------------------------------------------------
(defun GZ:popup ( title msg bit / wsh rtn )
; WSH のポップアップメソッドにあるメッセージボックスのラッパー。
;; title … タイトルの文字列
;; msg   … メッセージボックスの文字列
;; bit   … [INT] ビット符号化されたアイコン・ボタンの外観を示す整数
;; 戻り値：[INT] 押されたボタンを示す整数

; ex. (GZ:popup "タイトル文字列" "メッセージ文字列。" (+ 2 48 4096))
;     -> 1
;;; 'bit' のリファレンス
;;; ボタン
;;; 値  内容
;;; 0  OK ボタン表示
;;; 1  OK、Cancel ボタン表示
;;; 2  Abort、Retry、Ignore ボタン表示
;;; 3  Yes,、No、 Cancel ボタン表示
;;; 4  Yes、No ボタン表示
;;; 5  Retry、Cancel ボタン表示
;;; 6  Cancel、Try Again、Continue ボタン表示
;;;
;;; アイコン
;;; 値 内容
;;; 16  Stop アイコン表示
;;; 32  Question アイコン表示
;;; 48  Exclamation アイコン表示
;;; 64  Information アイコン表示
;;;
;;; その他
;;; 値  内容
;;; 256  第2ボタンをデフォルトに。
;;; 512  第3ボタンをデフォルトに。
;;; 4096  メッセージボックスは、システムモーダルメッセージボックスであり、一番上のウィンドウに表示されます。
;;; 524288  テキストを右寄せで表示
;;; 1048576  テキストが右流れで表示
;;; 
;;; 戻り値
;;; 関連するボタンを押してメッセージボックスを閉じるときに整数値が返される。
;;; 値  内容Description
;;; 1  OK ボタンがクリックされた。
;;; 2  Cancel（キャンセル） ボタンがクリックされた。
;;; 3  Abort（中止） ボタンがクリックされた。
;;; 4  Retry（再試行） ボタンがクリックされた。
;;; 5  Ignore(無視) ボタンがクリックされた。
;;; 6  Yes ボタンがクリックされた。
;;; 7  No ボタンがクリックされた。
;;; 10  Try Again（再実行） ボタンがクリックされた。
;;; 11  Continue（続行） ボタンがクリックされた。
;;;
;;; メモ : IJCAD だと呼び出しが正常ではないのかアイコンなし OKボタンのみの動作になる。2013～2020
  (if (setq wsh (vlax-create-object "wscript.shell"))
    (progn
      (setq rtn (vl-catch-all-apply 'vlax-invoke-method (list wsh 'popup msg 0 title bit)))
      (vlax-release-object wsh)
      (if (not (vl-catch-all-error-p rtn)) rtn)
)))


;;; DCL 生成関数 -----------------------------------------------------
(defun gz_msgbox_dclexport ()
; temp フォルダに gz_msgbox.dcl を生成する。
; 変更する場合は、*gz_msgboxdcl* のグローバル変数と合わせて変更

  ; ファイルがないまたは、変更の必要があるときに生成
  (if (or *ms_msgbox_chk*
          (not (findfile *gz_msgboxdcl*)) )
    (progn 
      (setq f (open *gz_msgboxdcl* "w")) 
      (mapcar '(lambda (x) (write-line x f)) (gz_msgbox_dclcontents)) 
      (close f) 
    )
  )
)

(defun gz_msgbox_dclcontents ()
; gz_msgbox で使用される DCLファイルの内容を文字列リストで返す関数
(if (not *ms_msgbox_chk*) (setq *ms_msgbox_chk* "check"))
(list 
  "dcl_settings : default_dcl_settings { audit_level = 3; }" ; ダイアログの監査を有効に
  (strcat
    "lspOkCancel : dialog {key = \"main\"; initial_focus = \"cancel\";"
    ": column { : text {key = \"message1\"; width = 20;}: text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;}}"
    ": spacer { width = 1; }"
    ": row {: spacer { width = 1;}"
    ": button {key = \"accept\"; label = \"OK\"; width = 12; fixed_width = true; mnemonic = \"O\"; is_default = true;}"
    ": spacer {width = 1;}"
    ": button {label = \"キャンセル (C)\"; key = \"cancel\"; width = 12; fixed_width = true;  mnemonic = \"C\";  is_cancel = true;}"
    ": spacer {width = 1;} }}"
  )
  (strcat
    "lspYesNo : dialog {key = \"main\"; initial_focus = \"no\";"
    ": column {"
    ": text {key = \"message1\"; width = 50;}: text {key = \"message2\"; width = 50;}: text {key = \"message3\"; width = 50;}"
    "}"
    ": row {: spacer { width = 1; }"
    ": button { key = \"yes\"; label = \"はい (Y)\"; width = 12; fixed_width = true; mnemonic = \"Y\";  is_default = true;}"
    ": button {  key = \"no\"; label = \"いいえ (N)\"; width = 12; fixed_width = true; mnemonic = \"N\"; is_cancel = true;}"
    ": spacer { width = 1;} }}"
  )
  (strcat
    "lspOkOnly : dialog {key = \"main\";"
    ": column {"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20; }"
    "}"
    ": row {: spacer {width = 1;}"
    ": button {key = \"accept\"; label = \"OK\"; width = 12;  fixed_width = true;  mnemonic = \"O\";  is_default = true;  alignment = centered;}"
    ": spacer {width = 1;}}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
    "lspYesNoCancel : dialog {key = \"main\"; initial_focus = \"cancel\";"
    ": column {: text {key = \"message1\";  width = 20;} : text {key = \"message2\";  width = 20;}: text {key = \"message3\";  width = 20;}}"
    ": row {: spacer { width = 1; }"
    ": button {key = \"yes\"; label = \"はい (Y)\"; width = 12; fixed_width = true;  mnemonic = \"Y\";  is_default = true;}"
    ": button {key = \"no\"; label = \"いいえ (N)\"; width = 12;  fixed_width = true;  mnemonic = \"N\";}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 12; fixed_width = true; mnemonic = \"C\"; is_cancel = true;}"
    ": spacer {width = 1;}"
    "}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspRetryCancel : dialog {key = \"main\"; initial_focus = \"retry\";"
    ": column {: text {key = \"message1\";  width = 20; }: text {key = \"message2\";  width = 20; }: text {key = \"message3\";  width = 20;}}"
    ": row {: spacer { width = 1; }"
    ": button {label = \"再試行 (R)\";  key = \"retry\";  width = 12;  fixed_width = true;  mnemonic = \"R\"; is_default = true;}"
    ": button {label = \"キャンセル (C)\";  key = \"Cancel\";  width = 12;  fixed_width = true;  mnemonic = \"C\"; is_cancel = true;}"
    ": spacer { width = 1;}"
    "}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspGetPass : dialog {key = \"main\"; initial_focus = \"password\";"
    ": column {: spacer {width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;}"
    ": spacer { width = 1; }}"
    ": edit_box {label = \"パスワード:\"; edit_width = 24; key = \"password\"; password_char = \"*\"; is_default = true; allow_accept = true;}"
    ": spacer { width = 1; }"
    ": row {: spacer {width = 1;}"
    ": button {key = \"accept\"; label = \"OK\"; width = 12; fixed_width = true;  mnemonic = \"O\";}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 12; fixed_width = true;  mnemonic = \"C\"; is_cancel = true;}"
    ": spacer {width = 1;}}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspInputBox : dialog {key = \"main\"; initial_focus = \"textbox\";"
    ": row {"
    ": column {width = 47; : spacer { width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;} : text {key = \"message4\"; width = 20;}"
    ": spacer { width = 1; }}"
    ": column {"
    ": button {key = \"accept\"; label = \"OK\"; width = 3; mnemonic = \"O\"; is_default = true;}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 3; mnemonic = \"C\"; is_cancel = true;}"
    ": spacer { width = 1; }}"
    "}"
    ": edit_box { edit_width = 60; label = \" \"; key = \"textbox\"; allow_accept = true;}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspInputBox2 : dialog {key = \"main\"; initial_focus = \"textbox\";"
    ": row { : column {width = 47; : spacer { width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;} : text {key = \"message4\";  width = 20;}"
    ": spacer { width = 1; }"
    "}}"
    ": edit_box {edit_width = 60;  label = \" \"; key = \"textbox\"; allow_accept = true;}"
    ": row {"
    ": button {key = \"accept\"; label = \"OK\"; width = 3; mnemonic = \"O\"; is_default = true;}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 3; mnemonic = \"C\"; is_cancel = true;}"
    "}"
    ": column {: text {key = \"bug_avoidance\"; width = 66;}}"
    "}"
  )
  (strcat
    "lspInputBox3 : dialog {key = \"main\";  initial_focus = \"textbox\";"
    ": row {"
    ": column {width = 47; : spacer { width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;}  : text {key = \"message4\"; width = 20;}"
    ": spacer { width = 1; }"
    ": toggle { key = \"chk1\";"
    "label =\""  *ms_msgbox_chk*  "\";"   ; ラベル名の変更
    "}"
    ": spacer { width = 1; }}}"
    ": spacer { width = 1; }"
    ": edit_box {edit_width = 60;   label = \" \";  key = \"textbox\";  allow_accept = true;  }"
    ": row {"
    ": button {key = \"accept\"; label = \"OK\"; width = 3; mnemonic = \"O\";  is_default = true; }"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 3; mnemonic = \"C\"; is_cancel = true; }"
    "}"
    ": column {: text {key = \"bug_avoidance\"; width = 66;}}"
    "}"
  )
  (strcat
    "lspCombobox : dialog {key = \"main\";  initial_focus = \"poplist\";"
    ": column {: spacer { width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text { key = \"message2\"; width = 20;} : text { key = \"message3\"; width = 20;}"
    ": spacer {width = 1;}"
    ": popup_list{key = \"poplist\"; label = \"項目\"; edit_width = 48;}: spacer { width = 1; }}"
    ": spacer {width = 1;}"
    ": row {"
    ": spacer {width = 1;}"
    ": button {key = \"accept\"; label = \"OK\";   width = 12;   fixed_width = true;   mnemonic = \"O\";}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 12; fixed_width = true; mnemonic = \"C\"; is_cancel = true;}"
    ": spacer {width = 1;}"
    "}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspListbox : dialog {key = \"main\"; initial_focus = \"listbox\";"
    ": column {: spacer {width = 1;}"
    ": text {key = \"message1\"; width = 20;} : text { key = \"message2\"; width = 20;} : text {key = \"message3\"; width = 20;}"
    ": spacer {width = 1;}"
    ": list_box{key = \"listbox\"; label = \"項目\"; edit_width = 48; allow_accept = false; }"
    ": spacer {width = 1;}}"
    ": spacer {width = 1;}"
    ": row {: spacer { width = 1; }"
    ": button {key = \"accept\"; label = \"OK\"; width = 12; fixed_width = true; mnemonic = \"O\";}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 12; fixed_width = true; mnemonic = \"C\"; is_cancel = true; }"
    ": spacer {width = 1;}}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspListboxMulti : dialog {key = \"main\"; initial_focus = \"listbox\";"
    ": column {: spacer { width = 1; }"
    ": text {key = \"message1\"; width = 20;} : text {key = \"message2\"; width = 20;} : text {key = \"message3\";   width = 20;}"
    ": spacer {width = 1;}"
    ": list_box{ key = \"listbox\"; label = \"項目\";  edit_width = 80; allow_accept = false; multiple_select = true;}"
    ": spacer {width = 1;}}"
    ": spacer {width = 1;}"
    ": row {: spacer {width = 1;}"
    ": button {key = \"accept\"; label = \"OK\";   width = 12;   fixed_width = true;   mnemonic = \"O\";}"
    ": button {key = \"cancel\"; label = \"キャンセル (C)\"; width = 12; fixed_width = true; mnemonic = \"C\"; is_cancel = true;}"
    ": spacer {width = 1;}}"
    ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
    "}"
  )
  (strcat
    "lspListboxMulti0 : dialog {key = \"main\"; initial_focus = \"listbox\";"
       ": column {width = 75;"
       ": list_box{key = \"listbox\"; edit_width = 80; allow_accept = true; multiple_select = true; }"
       ": spacer {width = 1;}"
       "}"
       ": spacer {width = 1;}"
       ": row {: spacer { width = 1; }"
       ": button {key = \"accept\"; label = \"OK\"; width = 12; fixed_width = true; mnemonic = \"O\"; }"
       ": button {label = \"キャンセル (C)\"; key = \"cancel\";  width = 12;  fixed_width = true; mnemonic = \"C\"; is_cancel = true;}"
       ": spacer { width = 1;}"
       "}"
       ": column {: text {key = \"bug_avoidance\"; width = 60;}}"
       "}"
  )
  (strcat 
        "lspEd : dialog {label = \"文字の編集\"; initial_focus = \"contents\";"
        ": edit_box {label = \"内容:\"; key = \"contents\"; edit_width = 40; edit_limit = 256; allow_accept = true;}"
        "spacer;"
        ": column {: row {fixed_width = true; alignment = centered; ok_button; : spacer {width = 2;} cancel_button; : spacer {width = 2;}}}"
        ": column {: text { key = \"bug_avoidance\"; width = 50; }}"
        "}"
  )
));_end_gz_msgbox_dclcontents



;;; ------------------------------------------------------------------
(defun gz_msgbox_test (/ result)
  ; gz_msgbox 関連関数のテスト 実行→結果表示を一通り行う
  (setq msg1 '("メッセージ1" "メッセージ2" "メッセージ3")
        lst1 '("aaa" "AA" "あああ" "ぁぁぁ" "1234567890"))

  (setq result (gz:lspOkCancel "OK-Cancel メッセージボックス" msg1))
  (alert (if (= T result) "OK" "キャンセル"))
  (setq result (gz:lspYesNo "Yes-No メッセージボックス" msg1 ))
  (alert (if (= T result) "Yes" "No"))
  (setq result (gz:lspokonly "OK Only メッセージボックス" msg1 ))
  (alert (if (= T result) "OK" "エラー"))
  (setq result (gz:lspRetryCancel "Retry-Cancel メッセージボックス" msg1 ))
  (alert (if (= T result) "リトライ" "キャンセル"))
  (setq result (gz:lspGetPass  "GetPass メッセージボックス" msg1 ))
  (alert (if (= nil result) "キャンセル" (strcat "パスワードは" result)))
  (setq result (gz:lisped "シンプル文字入力" ))
  (alert (if (= nil result) "キャンセル" result))
  (setq result (gz:lspInputBox "インプットボックス" msg1 ))
  (alert (if (= nil result) "キャンセル" result))
  (setq result (gz:lspInputBox2 "インプットボックス" msg1 "初期値"))
  (alert (if (= nil result) "キャンセル" result))
  (setq result (gz:lspInputBox3 "なんか入力して" "インプットボックス" "初期値" "私はロボットではありません" "0"))
  (if (= nil result) (prompt "\nキャンセル") (progn (apply 'strcat result)))
  (setq result (gz:lspComboBox "コンボボックス" msg1 lst1))
  (alert (if (= nil result) '("キャンセル") result))
  (setq result (gz:lspListBox "リストボックス" msg1 lst1))
  (alert (if (= nil result) "キャンセル" result))
  (setq result (gz:lspListBoxMulti "複数選択リストボックス" msg1 lst1))
  (if (= nil result) (prompt "\nキャンセル") (progn (apply 'strcat result)))
  (setq result (gz:lspListBoxMulti "複数選択リストボックス" nil lst1))
  (if (= nil result) (prompt "\nキャンセル") (progn (apply 'strcat result)))
  (setq result (gz:lspbrowsefolder "○○のフォルダを選択" nil))
  (alert (if (= nil result) "キャンセル" result))
  (setq result (GZ:popup "ポップアップメッセージ" "OK ボタン" (+ 0 16 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "OK、キャセル ボタン" (+ 1 32 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "中止、再実行、無視 ボタン" (+ 2 48 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "はい、いいえ、キャンセル ボタン" (+ 3 64 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "はい、いいえ ボタン" (+ 4 48 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "再試行 キャンセル ボタン" (+ 5 48 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (setq result (GZ:popup "ポップアップメッセージ" "キャンセル、再実行 続行 ボタン" (+ 6 48 4096)))
  (alert (if (= nil result) "キャンセル" (itoa result)))
  (princ)
)

(gz_msgbox_ver) (princ)

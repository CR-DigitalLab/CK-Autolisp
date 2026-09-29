;;----------------------------------------------------------------------------;;
;; 【ご利用についてのお願い】
;; このコードは、作業効率化を目的として開発されたものです。
;; 個人利用や業務効率化のためにご活用いただけると幸いです。
;;
;; 【著作権および利用制限について】
;; 本スクリプトはCHIKOが著作権を保有しており、著作権によって保護されています。
;; 著作権表示は削除しないでください。
;; ご購入者様の個人利用、および所属する組織内での業務利用に限りご使用いただけます。
;; 本スクリプトの全部または一部を、許可なく複製、転載、再配布、販売することを禁止します。
;;----------------------------------------------------------------------------;;
(defun c:ExportSysVars (/ date_str dwg_name default_filename save_path 
                          old_err old_qa old_logmode old_logpath old_cmdecho temp_log_path)
  (vl-load-com)
  
  ;; 1. デフォルトのファイル名を生成 (YYYYMMDDHHMM_図面名_システム変数一覧)
  (setq date_str (menucmd "m=$(edtime,$(getvar,date),YYYYMODDHHMM)"))
  (setq dwg_name (vl-filename-base (getvar "DWGNAME")))
  (setq default_filename (strcat date_str "_" dwg_name "_システム変数一覧.txt"))

  ;; 2. 保存先の指定ダイアログ
  (setq save_path (getfiled "システム変数を保存" default_filename "txt" 1))
  
  (if save_path
    (progn
      ;; --- エラーハンドリングの初期化 ---
      (setq old_err *error*) ; 元のエラー関数を退避
      (defun *error* (msg)
        (if old_qa (setvar "QAFLAGS" old_qa))
        (if old_logmode (setvar "LOGFILEMODE" old_logmode))
        (if old_logpath (setvar "LOGFILEPATH" old_logpath))
        (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
        (setq *error* old_err) ; 元のエラー関数を復元
        (princ (strcat "\nエラーまたはキャンセル: " msg))
        (princ)
      )

      ;; --- 現在の設定を保存 ---
      (setq old_qa (getvar "QAFLAGS"))
      (setq old_logmode (getvar "LOGFILEMODE"))
      (setq old_logpath (getvar "LOGFILEPATH"))
      (setq old_cmdecho (getvar "CMDECHO"))

      ;; --- 設定の変更とログ記録の開始 ---
      ;; 一時フォルダ(Temp)を直接指定（空フォルダの残留を防止）
      (setvar "LOGFILEMODE" 0)
      (setvar "LOGFILEPATH" (vl-string-translate "/" "\\" (getenv "Temp")))
      
      (setvar "CMDECHO" 0)
      
      ;; スクロール停止を無効化
      (setvar "QAFLAGS" (logior old_qa 2))
      (setvar "LOGFILEMODE" 1)
      
      ;; 一時ログファイルのパスを取得
      (setq temp_log_path (getvar "LOGFILENAME"))

      ;; システム変数をすべて出力
      (command "_.SETVAR" "?" "*")

      ;; ログ記録を終了
      (setvar "LOGFILEMODE" 0)

      ;; --- ファイルのコピーとクリーンアップ ---
      (if (findfile save_path)
        (vl-file-delete save_path) ; 既存ファイルの上書き用
      )
      (if (findfile temp_log_path)
        (progn
          (vl-file-copy temp_log_path save_path)
          (vl-file-delete temp_log_path) ; 一時ファイルの削除
        )
      )

      ;; --- AutoCADの設定を元に戻す ---
      (setvar "LOGFILEPATH" old_logpath)
      (setvar "QAFLAGS" old_qa)
      (setvar "LOGFILEMODE" old_logmode)
      (setvar "CMDECHO" old_cmdecho)
      (setq *error* old_err) ; エラー関数を元に戻す

      ;; --- 完了通知とファイルの展開 ---
      (princ (strcat "\n完了しました。保存先: " save_path))
      (startapp "notepad" save_path)
    )
    (princ "\n保存がキャンセルされました。")
  )
  (princ)
)
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
(vl-load-com)

;;; 補助プログラムの保存場所
(setq *autoime-dir* (strcat (getenv "APPDATA") "\\AutoIME"))
(setq *autoime-exe* (strcat *autoime-dir* "\\AutoIME.exe"))
(setq *autoime-cs*  (strcat *autoime-dir* "\\AutoIME.cs"))

;;; 監視対象（編集系のみ）
(setq *ime-edit-cmds* '("MTEDIT" "TEXTEDIT" "DDEDIT" "MLEADERCONTENTEDIT" "ATTEDIT" "ATTIPEDIT" "EATTEDIT" "TABLEDIT"))

;;; 補助プログラムの元になるコード
(setq *autoime-source*
  '(
    "using System;"
    "using System.Runtime.InteropServices;"
    "using System.Threading;"
    "class AutoIME {"
    "  [DllImport(\"imm32.dll\")] static extern IntPtr ImmGetDefaultIMEWnd(IntPtr h);"
    "  [DllImport(\"user32.dll\")] static extern IntPtr SendMessage(IntPtr h, int m, IntPtr w, IntPtr l);"
    "  [DllImport(\"user32.dll\")] static extern uint GetWindowThreadProcessId(IntPtr h, IntPtr p);"
    "  [DllImport(\"user32.dll\")] static extern bool GetGUIThreadInfo(uint t, ref GTI g);"
    "  [StructLayout(LayoutKind.Sequential)] struct RECT { public int l, t, r, b; }"
    "  [StructLayout(LayoutKind.Sequential)] struct GTI {"
    "    public int cbSize; public int flags;"
    "    public IntPtr hwndActive, hwndFocus, hwndCapture, hwndMenuOwner, hwndMoveSize, hwndCaret;"
    "    public RECT rc; }"
    "  static void Main(string[] a) {"
    "    try {"
    "      if (a.Length < 2) return;"
    "      IntPtr h = new IntPtr(long.Parse(a[0]));"
    "      int open = (a[1] == \"on\") ? 1 : 0;"
    "      int wait = (a.Length > 2) ? int.Parse(a[2]) : 0;"
    "      if (wait > 0) Thread.Sleep(wait);"
    "      IntPtr target = h;"
    "      GTI g = new GTI(); g.cbSize = Marshal.SizeOf(g);"
    "      uint tid = GetWindowThreadProcessId(h, IntPtr.Zero);"
    "      if (GetGUIThreadInfo(tid, ref g) && g.hwndFocus != IntPtr.Zero) target = g.hwndFocus;"
    "      IntPtr ime = ImmGetDefaultIMEWnd(target);"
    "      if (ime != IntPtr.Zero) SendMessage(ime, 0x283, new IntPtr(6), new IntPtr(open));"
    "    } catch { }"
    "  }"
    "}"
  )
)

;;; Windows標準の変換ツール（csc.exe）を探す
(defun autoime-find-csc (/ root path)
  (setq root (getenv "WINDIR"))
  (cond
    ((findfile (setq path (strcat root "\\Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe"))) path)
    ((findfile (setq path (strcat root "\\Microsoft.NET\\Framework\\v4.0.30319\\csc.exe"))) path)
    (t nil)
  )
)

;;; 補助プログラムを作成（初回のみ）
(defun autoime-build (/ csc f sh)
  (if (findfile *autoime-exe*)
    t
    (progn
      (setq csc (autoime-find-csc))
      (if (not csc)
        (progn
          (princ "\n[AutoIME] 補助プログラムを作成できませんでした（.NET Framework が見つかりません）。")
          nil
        )
        (progn
          (princ "\n[AutoIME] 初回準備中です。少しお待ちください...")
          (vl-mkdir *autoime-dir*)
          (setq f (open *autoime-cs* "w"))
          (foreach line *autoime-source* (write-line line f))
          (close f)
          (setq sh (vlax-create-object "WScript.Shell"))
          (vlax-invoke-method sh 'Run
            (strcat "\"" csc "\" /nologo /target:winexe /out:\"" *autoime-exe* "\" \"" *autoime-cs* "\"")
            0 :vlax-true)
          (vlax-release-object sh)
          (if (findfile *autoime-exe*)
            (progn (princ "\n[AutoIME] 準備が完了しました。") t)
            (progn (princ "\n[AutoIME] 補助プログラムの作成に失敗しました。") nil)
          )
        )
      )
    )
  )
)

;;; IMEをオン／オフ（mode は "on" か "off"、wait は待ち時間[ミリ秒]）
(defun autoime-set (mode wait / sh hwnd)
  (if (findfile *autoime-exe*)
    (progn
      (setq hwnd (vl-princ-to-string (vla-get-hwnd (vlax-get-acad-object))))
      (setq sh (vlax-create-object "WScript.Shell"))
      (vlax-invoke-method sh 'Run
        (strcat "\"" *autoime-exe* "\" " hwnd " " mode " " (itoa wait))
        0 :vlax-false)
      (vlax-release-object sh)
    )
  )
)

(defun c:AutoIMEStart ()
  (if (autoime-build)
    (progn
      (if (not *ime-edit-reactor*)
          (setq *ime-edit-reactor* (vlr-command-reactor nil
                  '((:vlr-commandWillStart . ime-edit-on)
                    (:vlr-commandEnded     . ime-edit-off)
                    (:vlr-commandCancelled . ime-edit-off)
                    (:vlr-commandFailed    . ime-edit-off)
                  )
                )
          )
      )
      (princ "\n[AutoIME] 文字編集時自動日本語入力を開始しました。")
    )
  )
  (princ)
)

(defun c:AutoIMEStop ()
  (if *ime-edit-reactor*
      (progn
        (vlr-remove *ime-edit-reactor*)
        (setq *ime-edit-reactor* nil)
      )
  )
  (princ "\n[AutoIME] 停止しました。")
  (princ)
)

;;; スクリプト実行中かどうかを判定
(defun is-script-active ()
  (= (logand (getvar "CMDACTIVE") 4) 4)
)

;;; 編集開始時：スクリプト中でなければ ON（編集画面が開くのを少し待つ）
(defun ime-edit-on (reactor params)
  (if (and (member (strcase (car params)) *ime-edit-cmds*)
           (not (is-script-active)))
      (autoime-set "on" 300)
  )
)

;;; 編集終了時：スクリプト中でなければ OFF
(defun ime-edit-off (reactor params)
  (if (and (member (strcase (car params)) *ime-edit-cmds*)
           (not (is-script-active)))
      (autoime-set "off" 0)
  )
)

(c:AutoIMEStart)
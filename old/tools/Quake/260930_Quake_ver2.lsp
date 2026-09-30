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
;; Quake ver2（2026-09-29）
;;   ・通信やデータの取得に失敗したときも、最後に「正常に完了しました」と出ていたのを直した（取得できたときだけ表示）
;;   ・エラー処理が、まれに自分自身のエラーになる書き方を直した
;;   ・読み込んだときにコマンド名を表示するようにした
;;   ※コマンド名・ショートカット・質問の順番・処理の結果は ver1 から変わりません。
(defun c:Quake ( / *error* old-cmdecho url httpObj sendResult status response chunks max-disp i anm at mag maxi decode-unicode get-val split-by merge-data merged-list sorted-list item ok)
  (vl-load-com)
  
  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nエラー: " msg))
      (princ "\n処理をキャンセルしました。")
    )
    (command-s "._UNDO" "_End")
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (princ)
  )

  (command "._UNDO" "_Begin")
  
  (defun decode-unicode (str / pos evalStr)
    (setq pos 0)
    (while (setq pos (vl-string-search "\\u" str pos))
      (setq str (strcat (substr str 1 pos) "\\U+" (substr str (+ pos 3))))
      (setq pos (+ pos 3))
    )
    (if (vl-string-search "\\U+" str)
      (progn
        (setq evalStr (vl-catch-all-apply 'read (list (strcat "\"" str "\""))))
        (if (vl-catch-all-error-p evalStr) str evalStr)
      )
      str
    )
  )

  (defun get-val (json key / s1 s2 start len vStart vEnd)
    (setq s1 (strcat "\"" key "\":\""))
    (setq s2 (strcat "\"" key "\": \""))
    (setq start (vl-string-search s1 json))
    (if start
      (setq len (strlen s1))
      (progn
        (setq start (vl-string-search s2 json))
        (if start (setq len (strlen s2)))
      )
    )
    (if start
      (progn
        (setq vStart (+ start len))
        (setq vEnd (vl-string-search "\"" json vStart))
        (substr json (1+ vStart) (- vEnd vStart))
      )
      "不明"
    )
  )

  (defun split-by (str delim / pos lst len)
    (setq len (strlen delim))
    (setq pos 0)
    (while (setq pos (vl-string-search delim str))
      (setq lst (cons (substr str 1 pos) lst))
      (setq str (substr str (+ pos len 1)))
    )
    (setq lst (cons str lst))
    (reverse lst)
  )

  (defun merge-data (at anm mag maxi lst / found res item)
    (setq found nil)
    (setq res
      (mapcar
        '(lambda (item / e-at e-anm e-mag e-maxi)
           (setq e-at (nth 0 item))
           (if (= e-at at)
             (progn
               (setq found t)
               (setq e-anm (nth 1 item))
               (setq e-mag (nth 2 item))
               (setq e-maxi (nth 3 item))
               (list
                 at
                 (if (or (= e-anm "") (= e-anm "---") (= e-anm "不明")) anm e-anm)
                 (if (or (= e-mag "") (= e-mag "---") (= e-mag "不明")) mag e-mag)
                 (if (or (= e-maxi "") (= e-maxi "---") (= e-maxi "不明")) maxi e-maxi)
               )
             )
             item
           )
         )
        lst
      )
    )
    (if (not found)
      (cons (list at anm mag maxi) lst)
      res
    )
  )

  (setq max-disp 10) 

  (setq url "https://www.jma.go.jp/bosai/quake/data/list.json")
  (setq httpObj (vlax-create-object "MSXML2.XMLHTTP"))
  
  (if httpObj
    (progn
      (princ "\n気象庁から最新の地震情報を取得中...")
      (vl-catch-all-apply 'vlax-invoke-method (list httpObj 'Open "GET" url :vlax-false))
      (setq sendResult (vl-catch-all-apply 'vlax-invoke-method (list httpObj 'Send)))
      
      (if (vl-catch-all-error-p sendResult)
        (princ "\nエラー: サーバーとの通信に失敗しました。")
        (progn
          (setq status (vlax-get-property httpObj 'Status))
          (if (= status 200)
            (progn
              (setq response (vlax-get-property httpObj 'ResponseText))
              
              (while (vl-string-search "}, {" response)
                (setq response (vl-string-subst "},{" "}, {" response))
              )
              (while (vl-string-search "},\n{" response)
                (setq response (vl-string-subst "},{" "},\n{" response))
              )
              
              (setq chunks (split-by response "},{"))
              
              (setq merged-list nil)
              
              (foreach chunk chunks
                (setq at (get-val chunk "at"))
                (if (and (not (= at "不明")) (not (= at "")))
                  (progn
                    (setq anm (decode-unicode (get-val chunk "anm")))
                    (setq mag (get-val chunk "mag"))
                    (setq maxi (get-val chunk "maxi"))
                    
                    (cond 
                      ((= maxi "5-") (setq maxi "5弱"))
                      ((= maxi "5+") (setq maxi "5強"))
                      ((= maxi "6-") (setq maxi "6弱"))
                      ((= maxi "6+") (setq maxi "6強"))
                    )
                    
                    (setq merged-list (merge-data at anm mag maxi merged-list))
                  )
                )
              )
              
              (setq sorted-list (vl-sort merged-list '(lambda (a b) (> (car a) (car b)))))
              
              (princ (strcat "\n\n=== 最新の地震情報 (直近" (itoa max-disp) "件) ==="))
              (setq i 1)
              
              (foreach item sorted-list
                (if (<= i max-disp)
                  (progn
                    (setq at (nth 0 item))
                    (setq anm (nth 1 item))
                    (setq mag (nth 2 item))
                    (setq maxi (nth 3 item))
                    
                    (if (or (= anm "") (= anm "不明")) (setq anm "---"))
                    (if (or (= mag "") (= mag "不明")) (setq mag "---"))
                    (if (or (= maxi "") (= maxi "不明")) (setq maxi "---"))
                    
                    (if (> (strlen at) 15)
                      (setq at (strcat 
                                 (substr at 1 4) "年" 
                                 (substr at 6 2) "月" 
                                 (substr at 9 2) "日 " 
                                 (itoa (atoi (substr at 12 2))) "時" 
                                 (substr at 15 2) "分"
                               ))
                    )
                    
                    (princ (strcat "\n [" (itoa i) "] " at " | 震央: " anm " | M" mag " | 震度" maxi))
                    (setq i (1+ i))
                  )
                )
              )
              (princ "\n========================================\n")
              (setq ok T)
            )
            (princ (strcat "\nエラー: データ取得失敗 (HTTPステータス: " (itoa status) ")"))
          )
        )
      )
      (vlax-release-object httpObj)
    )
    (princ "\nエラー: HTTP通信オブジェクトが作成できませんでした。")
  )
  
  (command "._UNDO" "_End")
  (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
  
  (if ok (princ "\n地震情報の取得が正常に完了しました。"))   ; 取得できたときだけ表示
  (princ)
)

;; JISINコマンドの定義
(defun c:JISIN ()
  (c:Quake)
  (princ)
)

(princ "\n[Quake ver2] 読み込み完了  QUAKE（JISIN）＝気象庁から直近の地震情報10件を表示")
(princ)

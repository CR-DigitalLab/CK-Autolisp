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

;; noteを開く
(defun c:NOTE ()
  (command "_.browser" "https://note.com/")
  (princ)
)

;; Yahoo! JAPANを開く
(defun c:YAHOO ()
  (command "_.browser" "https://www.yahoo.co.jp/")
  (princ)
)

;; Googleを開く
(defun c:GOOGLE ()
  (command "_.browser" "https://www.google.com/")
  (princ)
)

;; YouTubeを開く
(defun c:YOUTUBE ()
  (command "_.browser" "https://www.youtube.com/")
  (princ)
)

;; Spotify (Webプレイヤー) を開く
(defun c:SPOTIFY ()
  (command "_.browser" "https://open.spotify.com/")
  (princ)
)

;; ウーバーイーツを開く
(defun c:UBER ()
  (command "_.browser" "https://www.ubereats.com/jp")
  (princ)
)

;; Twitter (X) を開く
(defun c:TWITTER ()
  (command "_.browser" "https://x.com/")
  (princ)
)

;; 乗換案内 (Yahoo!路線情報) を開く
(defun c:NORIKAE ()
  (command "_.browser" "https://transit.yahoo.co.jp/")
  (princ)
)

;; Yahoo!ニュースを開く
(defun c:YNEWS ()
  (command "_.browser" "https://news.yahoo.co.jp/")
  (princ)
)

;; ギガファイル便を開く
(defun c:GIGAFILE ()
  (command "_.browser" "https://gigafile.nu/")
  (princ)
)

;; データ便を開く
(defun c:DATABIN ()
  (command "_.browser" "https://www.datadeliver.net/")
  (princ)
)

;; GitHubを開く
(defun c:GITHUB ()
  (command "_.browser" "https://github.com/")
  (princ)
)

;; Amazonを開く
(defun c:AMAZON ()
  (command "_.browser" "https://www.amazon.co.jp/")
  (princ)
)

;; 気象庁を開く
(defun c:KISHOCHO ()
  (command "_.browser" "https://www.jma.go.jp/jma/index.html")
  (princ)
)

(princ)
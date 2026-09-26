;;; number.lsp
;;; 指令: NUMCOPY
;;; 功能: 選取一個文字(例如 F001)，每次指定貼上點時自動遞增，並跳過尾數 9 與 0

(defun _is-digit (c)
  (and c (<= 48 c) (<= c 57))
)

(defun _pad-num (n w / s)
  (setq s (itoa n))
  (while (< (strlen s) w)
    (setq s (strcat "0" s))
  )
  s
)

(defun _split-num-token (txt / len i j prefix numstr suffix)
  (setq len (strlen txt)
        i   len)

  ;; 從尾端先略過非數字(支援像 F001A 這種尾碼)
  (while (and (> i 0)
              (not (_is-digit (ascii (substr txt i 1)))))
    (setq i (1- i))
  )

  (if (= i 0)
    nil
    (progn
      (setq j i)
      ;; 往左找出連續數字區段
      (while (and (> j 0)
                  (_is-digit (ascii (substr txt j 1))))
        (setq j (1- j))
      )
      (setq prefix (if (> j 0) (substr txt 1 j) "")
            numstr (substr txt (1+ j) (- i j))
            suffix (if (< i len) (substr txt (1+ i)) ""))
      (list prefix numstr suffix)
    )
  )
)

(defun _next-valid-num (n)
  (setq n (1+ n))
  (while (or (= (rem n 10) 9)
             (= (rem n 10) 0))
    (setq n (1+ n))
  )
  n
)

(defun _get-block-attrs (ename / obj)
  (setq obj (vlax-ename->vla-object ename))
  (if (and obj
           (= (vla-get-ObjectName obj) "AcDbBlockReference")
           (= :vlax-true (vla-get-HasAttributes obj)))
    (vlax-safearray->list (vlax-variant-value (vla-GetAttributes obj)))
    nil
  )
)

(defun _find-attr-by-tag (attrs tag / a hit uTag)
  (setq uTag (strcase tag)
        hit  nil)
  (while (and attrs (null hit))
    (setq a (car attrs))
    (if (= (strcase (vla-get-TagString a)) uTag)
      (setq hit a)
    )
    (setq attrs (cdr attrs))
  )
  hit
)

(defun _split-csv-line (line / result start i len ch inQuotes field)
  ;; 支援一般逗號分隔，以及雙引號包住的欄位
  (setq result   nil
        start    1
        i        1
        len      (strlen line)
        inQuotes nil
        field    "")
  (while (<= i len)
    (setq ch (substr line i 1))
    (cond
      ((= ch "\"")
       (setq inQuotes (not inQuotes)))
      ((and (= ch ",") (not inQuotes))
       (setq result (cons field result)
             field  ""))
      (T
       (setq field (strcat field ch)))
    )
    (setq i (1+ i))
  )
  (reverse (cons field result))
)

(defun _csv-cell (row index)
  (if (and row (<= index (length row)))
    (nth (1- index) row)
    ""
  )
)

(defun _sheet-index-value (txt / pos)
  (setq pos (vl-string-search "SHEET" (strcase txt)))
  (if pos
    (substr txt (1+ pos))
    ""
  )
)

(defun _sheet-name-value (txt / pos)
  (setq pos (vl-string-search "SHEET" (strcase txt)))
  (if pos
    (substr txt 1 pos)
    txt
  )
)

(defun _read-csv-rows (path / file line rows)
  (setq file (open path "r")
        rows nil)
  (if file
    (progn
      (while (setq line (read-line file))
        (if (/= line "")
          (setq rows (cons (_split-csv-line line) rows))
        )
      )
      (close file)
      (reverse rows)
    )
    nil
  )
)

(defun c:INSERTINDEX (/ *error* oldcmdecho path rows row ent attrs noAtt fAtt jAtt indexAtt noTag fTag jTag count skipped hasHeader source sourceEd basept pointA pointB pointC rowCount rowIndex colIndex rowStep colStep insertPt newent)
  (vl-load-com)
  (setq oldcmdecho (getvar "CMDECHO"))

  (defun *error* (msg)
    (setvar "CMDECHO" oldcmdecho)
    (if (and msg
             (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (prompt (strcat "\n錯誤: " msg))
    )
    (princ)
  )

  (setvar "CMDECHO" 0)
  (setq path (getfiled "選取 CSV 檔案" "" "csv" 0))
  (if (null path)
    (progn
      (prompt "\n未選取 CSV 檔案。")
      (*error* nil)
    )
    (progn
      (setq rows (_read-csv-rows path))
      (if (null rows)
        (progn
          (prompt "\nCSV 檔案沒有可讀取的資料。")
          (*error* nil)
        )
        (progn
          (initget "Yes No")
          (setq hasHeader (getkword "\nCSV 第一列是否為標題? [Yes/No] <Yes>: "))
          (if (or (null hasHeader) (= hasHeader "Yes"))
            (setq rows (cdr rows))
          )
          (setq source (car (entsel "\n選取要插入的圖塊樣板: ")))
          (if (null source)
            (progn
              (prompt "\n未選取圖塊樣板。")
              (*error* nil)
            )
            (progn
              (setq sourceEd (entget source)
                    attrs    (_get-block-attrs source))
              (if (or (/= (cdr (assoc 0 sourceEd)) "INSERT") (null attrs))
                (progn
                  (prompt "\n選取的物件不是含屬性的圖塊。")
                  (*error* nil)
                )
                (progn
                  (setq basept (cdr (assoc 10 sourceEd)))
                  (setq noTag (getstring T "\nNO. 屬性 TAG (直接 Enter=NO.): "))
                  (if (= noTag "") (setq noTag "NO."))
                  (setq fTag (getstring T "\nF 欄位寫入的屬性 TAG (直接 Enter=NAME): "))
                  (if (= fTag "") (setq fTag "NAME"))
                  (setq jTag (getstring T "\nJ 欄位寫入的屬性 TAG (直接 Enter=NAME-ENG): "))
                  (if (= jTag "") (setq jTag "NAME-ENG"))

                  (setq pointA (getpoint "\n指定插入點 A: "))
                  (if (null pointA)
                    (progn
                      (prompt "\n未指定插入點 A。")
                      (*error* nil)
                    )
                    (progn
                      (setq pointB (getpoint pointA "\n指定插入點 B: "))
                      (if (null pointB)
                        (progn
                          (prompt "\n未指定插入點 B。")
                          (*error* nil)
                        )
                        (progn
                          (initget 1)
                          (setq rowCount (getint "\n指定直行數量: "))
                          (if (< rowCount 1)
                            (progn
                              (prompt "\n直行數量必須大於 0。")
                              (*error* nil)
                            )
                            (progn
                              (setq pointC (getpoint pointA "\n指定插入點 C（向右決定橫向間距）: "))
                              (if (null pointC)
                                (progn
                                  (prompt "\n未指定插入點 C。")
                                  (*error* nil)
                                )
                                (progn
                                  (setq rowStep (- (cadr pointB) (cadr pointA))
                                        colStep (abs (- (car pointC) (car pointA)))
                                        count 0
                                        skipped 0
                                        colIndex 0)
                                  (if (= colStep 0.0)
                                    (prompt "\n警告：A、C 的 X 座標相同，橫向間距為 0。")
                                  )
                                  (while rows
                                    (setq rowIndex 0)
                                    (while (and rows (< rowIndex rowCount))
                                      (setq row       (car rows)
                                            rows      (cdr rows)
                                            insertPt  (list (+ (car pointA) (* colIndex colStep))
                                                            (+ (cadr pointA) (* rowIndex rowStep))
                                                            (if (caddr pointA) (caddr pointA) 0.0)))
                                      (command "_.COPY" source "" basept insertPt)
                                      (setq newent (entlast))
                                      (if newent
                                        (progn
                                          (setq attrs (_get-block-attrs newent)
                                                noAtt (_find-attr-by-tag attrs noTag)
                                                fAtt  (_find-attr-by-tag attrs fTag)
                                                jAtt  (_find-attr-by-tag attrs jTag)
                                                indexAtt (_find-attr-by-tag attrs "NAME-ENG-INDEX"))
                                          (if noAtt
                                            (progn
                                              (vla-put-TextString noAtt (strcat (_csv-cell row 2) (_csv-cell row 3)))
                                              (if fAtt (vla-put-TextString fAtt (_csv-cell row 6)))
                                              (if jAtt (vla-put-TextString jAtt (_sheet-name-value (_csv-cell row 10))))
                                              (if indexAtt
                                                (vla-put-TextString indexAtt (_sheet-index-value (_csv-cell row 10))))
                                              (setq count (1+ count))
                                            )
                                            (progn
                                              (prompt (strcat "\n找不到屬性 TAG: " noTag "，已刪除這個複製圖塊。"))
                                              (entdel newent)
                                              (setq skipped (1+ skipped))
                                            )
                                          )
                                        )
                                      )
                                      (setq rowIndex (1+ rowIndex))
                                    )
                                    (setq colIndex (1+ colIndex))
                                  )
                                  (prompt (strcat "\n完成：插入 " (itoa count) " 個圖塊，跳過 " (itoa skipped) " 列。"))
                                  (*error* nil)
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
  (princ)
)

(setq *textcsv-row-tolerance* 5.0)

(defun _textcsv-quote (txt)
  (strcat "\"" (vl-string-subst "\"\"" "\"" txt) "\"")
)

(defun _textcsv-less (a b / ay by ax bx)
  (setq ay (nth 3 a)
        by (nth 3 b)
        ax (nth 2 a)
        bx (nth 2 b))
  (if (<= (abs (- ay by)) *textcsv-row-tolerance*)
    (< ax bx)
    (> ay by)
  )
)

(defun _textcsv-y-less (a b)
  (> (nth 3 a) (nth 3 b))
)

(defun _textcsv-x-less (a b)
  (< (nth 2 a) (nth 2 b))
)

(defun c:TEXTTOCSV (/ *error* oldcmdecho ss tolerance path file i ename ed typ text point data sorted groups currentY currentItems item row rows firstItem separator)
  (setq oldcmdecho (getvar "CMDECHO"))

  (defun *error* (msg)
    (setvar "CMDECHO" oldcmdecho)
    (if (and file (not (close file)))
      nil
    )
    (if (and msg
             (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (prompt (strcat "\n錯誤: " msg))
    )
    (princ)
  )

  (setvar "CMDECHO" 0)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (prompt "\n未選取 TEXT 或 MTEXT。")
      (*error* nil)
    )
    (progn
      (initget 6)
      (setq tolerance (getdist (strcat "\n同一列判定誤差 <" (rtos *textcsv-row-tolerance* 2 2) ">: ")))
      (if tolerance
        (setq *textcsv-row-tolerance* tolerance)
      )
      (setq i 0
            data nil)
      (while (< i (sslength ss))
        (setq ename (ssname ss i)
              ed    (entget ename)
              typ   (cdr (assoc 0 ed))
              text  (cdr (assoc 1 ed))
              point (cdr (assoc 10 ed)))
        (if (and text point)
          (setq data
            (cons
              (list ename
                    text
                    (car point)
                    (cadr point)
                    (if (caddr point) (caddr point) 0.0)
                    (cdr (assoc 8 ed)))
              data)
          )
        )
        (setq i (1+ i))
      )
      (setq sorted (vl-sort data '_textcsv-y-less)
            groups nil
            currentY nil
            currentItems nil)
      (foreach item sorted
        (if (or (null currentY)
                (> (abs (- (nth 3 item) currentY)) *textcsv-row-tolerance*))
          (progn
            (if currentY
              (setq groups (cons (reverse currentItems) groups))
            )
            (setq currentY     (nth 3 item)
                  currentItems (list item))
          )
          (setq currentItems (cons item currentItems))
        )
      )
      (if currentY
        (setq groups (cons (reverse currentItems) groups))
      )
      (setq rows (reverse groups))
      (setq path (getfiled "輸出 CSV 檔案" "text_export.csv" "csv" 1))
      (if (null path)
        (progn
          (prompt "\n未指定輸出檔案。")
          (*error* nil)
        )
        (progn
          (setq file (open path "w"))
          (if (null file)
            (progn
              (prompt "\n無法建立 CSV 檔案。")
              (*error* nil)
            )
            (progn
              (foreach row rows
                (setq row (vl-sort row '_textcsv-x-less)
                      separator ""
                      text "")
                (foreach item row
                  (setq text (strcat text separator (_textcsv-quote (nth 1 item)))
                        separator ",")
                )
                (write-line text file)
              )
              (close file)
              (setq file nil)
              (prompt (strcat "\n完成：已輸出 " (itoa (length data)) " 筆文字，分成 " (itoa (length rows)) " 列至 " path))
              (*error* nil)
            )
          )
        )
      )
    )
  )
  (princ)
)

(defun c:NUMCOPY (/ *error* oldcmdecho ent ed typ txt parts prefix numstr suffix width n basept p newent newed)
  (setq oldcmdecho (getvar "CMDECHO"))

  (defun *error* (msg)
    (setvar "CMDECHO" oldcmdecho)
    (if (and msg
             (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (prompt (strcat "\n錯誤: " msg))
    )
    (princ)
  )

  (setvar "CMDECHO" 0)

  (setq ent (car (entsel "\n選取起始文字 (例如 F001): ")))
  (if (null ent)
    (progn
      (prompt "\n未選取物件。")
      (*error* nil)
    )
    (progn
      (setq ed  (entget ent)
            typ (cdr (assoc 0 ed)))

      (if (not (member typ '("TEXT" "MTEXT")))
        (progn
          (prompt "\n請選取 TEXT 或 MTEXT。")
          (*error* nil)
        )
        (progn
          (setq txt   (cdr (assoc 1 ed))
                parts (_split-num-token txt))

          (if (null parts)
            (progn
              (prompt "\n所選文字不包含數字，無法遞增。")
              (*error* nil)
            )
            (progn
              (setq prefix (nth 0 parts)
                    numstr (nth 1 parts)
                    suffix (nth 2 parts)
                    width  (strlen numstr)
                    n      (atoi numstr))

              (setq basept (getpoint "\n指定基準點: "))
              (if (null basept)
                (progn
                  (prompt "\n未指定基準點。")
                  (*error* nil)
                )
                (progn

                  (prompt "\n開始連續貼上，指定位置即可；按 Esc 結束。")

                  (while (setq p (getpoint "\n指定貼上點: "))
                    (setq n (_next-valid-num n))
                    (command "_.COPY" ent "" basept p)
                    (setq newent (entlast))
                    (if newent
                      (progn
                        (setq newed (entget newent))
                        (entmod
                          (subst
                            (cons 1 (strcat prefix (_pad-num n width) suffix))
                            (assoc 1 newed)
                            newed
                          )
                        )
                        (entupd newent)
                      )
                    )
                  )

                  (*error* nil)
                )
              )
            )
          )
        )
      )
    )
  )

  (princ)
)

(defun c:BLKNUM (/ *error* oldcmdecho s parts prefix numstr suffix width n ent ed typ attrs tagInput tagUse att val)
  (vl-load-com)
  (setq oldcmdecho (getvar "CMDECHO"))

  (defun *error* (msg)
    (setvar "CMDECHO" oldcmdecho)
    (if (and msg
             (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (prompt (strcat "\n錯誤: " msg))
    )
    (princ)
  )

  (setvar "CMDECHO" 0)

  (setq s (getstring T "\n輸入起始編號 (例如 F001): "))
  (if (or (null s) (= s ""))
    (progn
      (prompt "\n未輸入起始編號。")
      (*error* nil)
    )
    (progn
      (setq parts (_split-num-token s))
      (if (null parts)
        (progn
          (prompt "\n起始編號不包含數字，無法遞增。")
          (*error* nil)
        )
        (progn
          (setq prefix (nth 0 parts)
                numstr (nth 1 parts)
                suffix (nth 2 parts)
                width  (strlen numstr)
                n      (atoi numstr))

          (setq tagInput (getstring T "\n輸入要修改的屬性 TAG (直接 Enter=第一個屬性): "))
          (if (= tagInput "")
            (setq tagUse nil)
            (setq tagUse tagInput)
          )

          (prompt "\n開始選取圖塊，按 Enter 或 Esc 結束。")

          (while (setq ent (car (entsel "\n選取圖塊: ")))
            (setq ed  (entget ent)
                  typ (cdr (assoc 0 ed)))

            (if (/= typ "INSERT")
              (prompt "\n這不是圖塊，已跳過。")
              (progn
                (setq attrs (_get-block-attrs ent))
                (if (null attrs)
                  (prompt "\n此圖塊沒有可編輯屬性，已跳過。")
                  (progn
                    (if tagUse
                      (setq att (_find-attr-by-tag attrs tagUse))
                      (setq att (car attrs))
                    )

                    (if (null att)
                      (prompt "\n找不到指定 TAG 屬性，已跳過。")
                      (progn
                        (setq val (strcat prefix (_pad-num n width) suffix))
                        (vla-put-TextString att val)
                        (setq n (_next-valid-num n))
                      )
                    )
                  )
                )
              )
            )
          )

          (*error* nil)
        )
      )
    )
  )

  (princ)
)

(princ "\n已載入指令: NUMCOPY")
(princ "\n已載入指令: BLKNUM")
(princ "\n已載入指令: INSERTINDEX")
(princ "\n已載入指令: TEXTTOCSV")
(princ)

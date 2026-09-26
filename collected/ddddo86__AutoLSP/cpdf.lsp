(defun c:cpdf (/ wsh tempFile cmd str file files folder layoutName paperSize paperSizeStr plotStyle acadExe accoreExe tempFolder batFile fBat i pdfPath scrFile fScr)
  (vl-load-com)

  ;; 1. 偵測 AutoCAD 背景核心引擎
  (setq acadExe (vlax-get-property (vlax-get-acad-object) 'FullName))
  (setq accoreExe (strcat (vl-filename-directory acadExe) "\\accoreconsole.exe"))
  (if (not (findfile accoreExe))
    (progn (alert "找不到 AutoCAD Core Console") (quit))
  )

  (setq wsh (vlax-create-object "WScript.Shell"))

  ;; 2. 選擇檔案
  (setq tempFile (vl-filename-mktemp "cpdf_files" "" ".txt"))
  (setq cmd (strcat "powershell.exe -STA -WindowStyle Hidden -Command \"Add-Type -AssemblyName System.Windows.Forms; $ofd = New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter = 'AutoCAD Files (*.dwg)|*.dwg'; $ofd.Multiselect = $true; $ofd.Title = '請選擇要出圖的 CAD 檔案'; if ($ofd.ShowDialog() -eq 'OK') { [IO.File]::WriteAllText('" tempFile "', ($ofd.FileNames -join '|')) }\""))
  (vlax-invoke wsh 'Run cmd 0 :vlax-true)

  (setq files nil)
  (if (setq file (open tempFile "r"))
    (progn (setq str (read-line file)) (close file) (vl-file-delete tempFile) (if str (setq files (SplitString str "|"))))
  )
  (if (not files) (progn (princ "\n未選擇檔案，指令取消。") (vlax-release-object wsh) (quit)))

  ;; 3. 選擇路徑
  (setq tempFile (vl-filename-mktemp "cpdf_folder" "" ".txt"))
  (setq cmd (strcat "powershell.exe -STA -WindowStyle Hidden -Command \"Add-Type -AssemblyName System.Windows.Forms; $fbd = New-Object System.Windows.Forms.FolderBrowserDialog; $fbd.Description = '請選擇 PDF 儲存路徑'; if ($fbd.ShowDialog() -eq 'OK') { [IO.File]::WriteAllText('" tempFile "', $fbd.SelectedPath) }\""))
  (vlax-invoke wsh 'Run cmd 0 :vlax-true)

  (setq folder nil)
  (if (setq file (open tempFile "r"))
    (progn (setq str (read-line file)) (close file) (vl-file-delete tempFile) (if str (setq folder str)))
  )
  (if (not folder) (progn (princ "\n未選擇輸出路徑，指令取消。") (exit)))

  ;; 4. 輸入參數
  (setq layoutName (getstring T "\n請輸入要出圖的「圖面配置名稱」: "))
  (if (eq layoutName "") (progn (princ "\n配置名稱不可為空。") (exit)))

  (setq paperSize (getstring T "\n請輸入圖紙尺寸 (支援簡寫: A0, A1, A2, A3, A4) [直接 Enter 預設為 A1]: "))
  (if (eq paperSize "") (setq paperSize "A1"))
  (setq paperSize (strcase paperSize))
  
  ;; 💡 套用 DWG To PDF.pc3 專屬的指令列高精確圖紙名稱
  (cond
    ((= paperSize "A0") (setq paperSizeStr "ISO full bleed A0 (841.00 x 1189.00 公釐)"))
    ((= paperSize "A1") (setq paperSizeStr "ISO full bleed A1 (594.00 x 841.00 公釐)"))
    ((= paperSize "A2") (setq paperSizeStr "ISO full bleed A2 (420.00 x 594.00 公釐)"))
    ((= paperSize "A3") (setq paperSizeStr "ISO full bleed A3 (297.00 x 420.00 公釐)"))
    ((= paperSize "A4") (setq paperSizeStr "ISO full bleed A4 (210.00 x 297.00 公釐)"))
    (T (setq paperSizeStr paperSize))
  )

  (setq plotStyle (getstring T "\n請輸入出圖型式名稱 (直接 Enter 預設為 monochrome.ctb): "))
  (if (eq plotStyle "") (setq plotStyle "monochrome.ctb"))

  ;; 5. 生成暫存區批次檔
  (setq tempFolder (getenv "TEMP"))
  (setq batFile (strcat tempFolder "\\cpdf_debug_run.bat"))
  (setq fBat (open batFile "w"))
  
  (write-line "@echo off" fBat)
  (write-line "echo ========================================================" fBat)
  (write-line "echo       AutoCAD 批次出圖 (DWG To PDF) - 全自動模式" fBat)
  (write-line "echo ========================================================" fBat)

  (setq i 1)
  (foreach dwg files
    (setq pdfPath (strcat folder "\\" (vl-filename-base dwg) ".pdf"))
    
    (setq scrFile (strcat tempFolder "\\cpdf_plot_" (itoa i) ".scr"))
    (setq fScr (open scrFile "w"))

    ;; 若已有同名 PDF 則強制刪除
    (write-line (strcat "if exist \"" pdfPath "\" del /f /q \"" pdfPath "\"") fBat)

    ;; 💡 針對 DWG To PDF.pc3 精準對應的標準指令流程（無多餘問答，完美同步）
    (write-line "_.-PLOT" fScr)
    (write-line "Y" fScr)                          ;; 詳細出圖規劃
    (write-line layoutName fScr)                   ;; 配置名稱
    (write-line "DWG To PDF.pc3" fScr)             ;; 內建高效能 PDF 引擎
    (write-line paperSizeStr fScr)                 ;; 圖紙尺寸
    (write-line "M" fScr)                          ;; 單位: 公釐
    (write-line "L" fScr)                          ;; 方向: 橫向
    (write-line "N" fScr)                          ;; 上下顛倒: 否
    (write-line "L" fScr)                          ;; 出圖區域: 配置
    (write-line "1:1" fScr)                        ;; 比例
    (write-line "0.00,0.00" fScr)                  ;; 偏移
    (write-line "Y" fScr)                          ;; 套用出圖型式
    (write-line plotStyle fScr)                    ;; CTB 筆表
    (write-line "Y" fScr)                          ;; 支援線粗
    (write-line "N" fScr)                          ;; 縮放線粗
    (write-line "N" fScr)                          ;; 先出圖紙空間
    (write-line "N" fScr)                          ;; 隱藏圖紙空間物件
    
    ;; 內建 PDF 引擎直接指定輸出檔案路徑
    (write-line pdfPath fScr)      
    
    (write-line "N" fScr)                          ;; 儲存變更至頁面設置？ N
    (write-line "Y" fScr)                          ;; 繼續出圖？ Y
    (close fScr)

    (write-line "echo." fBat)
    (write-line (strcat "echo ========================================================") fBat)
    (write-line (strcat "echo [進度 " (itoa i) "/" (itoa (length files)) "] 正在處理圖檔: " (vl-filename-base dwg) ".dwg") fBat)
    (write-line (strcat "echo ========================================================") fBat)

    (write-line (strcat "\"" accoreExe "\" /i \"" dwg "\" /s \"" scrFile "\"") fBat)
    (setq i (1+ i))
  )

  (write-line "echo." fBat)
  (write-line "echo 批次出圖全數執行完畢！" fBat)
  (write-line "pause" fBat)
  (close fBat)

  ;; 6. 啟動 CMD
  (princ "\n即將透過內建引擎全自動批次出圖...")
  (vlax-invoke wsh 'Run (strcat "\"" batFile "\"") 1 :vlax-true)
  (vlax-release-object wsh)

  (princ "\n請查看彈出的命令提示字元視窗。")
  (princ)
)

(defun SplitString (str delim / pos lst)
  (while (setq pos (vl-string-search delim str))
    (setq lst (cons (substr str 1 pos) lst))
    (setq str (substr str (+ pos 2)))
  )
  (reverse (cons str lst))
)
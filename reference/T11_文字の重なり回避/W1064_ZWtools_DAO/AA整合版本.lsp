;;; =... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
;;;
;;;                   ZWCAD 多功能集成插件 (Integrated Plugins) - 修正版 v1.1
;;;
;;; =======================================================================================
;;;
;;; 版本: 1.3
;;; 修正日期: 2026-04-01
;;; 描述: 本文件整合了多个常用的AutoLISP插件，方便统一加载和管理。
;;;       作者：YS
;;;
;;; 包含以下命令:
;;;
;;;   - YSDL  : 提取选中文字到CSV文件，并改变文字颜色。
;;;   - HDDL  : 直接校核选中文字中的电缆编号和原理号，问题行标红并在行首标注。
;;;   - QSTXT : 快速从当前选择中仅选中所有文字对象。
;;;   - T     : 把字体刷为HZ样式，高度3，宽度0.7。
;;;   - H     : 先将选中文字统一为左中对正，再按指定间距从上到下排列。
;;;   - Y     : 将选中对象的颜色快速变为指定颜色（默认为黄色）。
;;;   - RR    : 将选中对象快速改为红色。
;;;   - WW    : 将选中对象快速改为白色。
;;;   - GG    : 将选中对象快速改为绿色。
;;;   - HH    : 将选中对象快速改为洋红色。
;;;   - HUI   : 将选中对象快速改为颜色 8。
;;;   - ZHONG : 将选中文字统一为中中对正，并以最上方文字为基准居中对齐。
;;;   - ZUO   : 将选中文字统一为左中对正，并以最上方文字为基准左对齐。
;;;   - HP    : 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。
;;;   - YOU   : 将选中文字统一为右中对正，并以最上方文字为基准右对齐。
;;;   - SHANG : 将选中文字统一为中上对正，并以最上方文字为基准上对齐。
;;;   - XIA   : 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。
;;;   - HE    : 将同一行的两个或以上文字合并。
;;;   - QR    : 快速修改文字高度。
;;;   - WI    : 修改选中文字的宽度比例。
;;;   - XB    : 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。
;;;   - YAN   : 延长竖直直线统一间距，支持分组和上下方向控制。
;;;   - SYAN  : 将选中直线向上延长 5 个单位。
;;;   - XYAN  : 将选中直线向下延长 5 个单位。
;;;   - SJ    : 在选中直线顶端生成上接短线。
;;;   - XJ    : 在选中直线底端生成下接短线。
;;;   - GTX   : 根据电缆文字前缀分类并输出汇总结果。
;;;   - GTY   : 汇总并按电缆编号排序整理电缆文字。
;;;   - BIAN  : 根据选中直线生成方向三角、至字样和电缆规格标注。
;;;   - LAN   : 竖直线/斜线/水平线联动复制+移动插件。
;;;   - XIN   : 统计选中直线矩形范围内的对象数量并标注结果。
;;;   - XY    : 先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。
;;;   - NU    : 材料表数字加数字，从选中文字中提取数字并执行加法运算。
;;;   - KAI   : 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。
;;;   - ZHENG : 将文字水平居中到直线中点，或将单个文字改为正中对正后水平放到矩形中心 X。
;;;   - GE    : 选中同一水平行的单行文字，按文字间隙绘制单行表格。
;;;   - UT    : 先将文字统一为左中对正，再按最上方一对的相对位置整理水平直线与文字。
;;;   - HAO   : 选中图框后批量填写页码和档案号。
;;;   - FIVE  : 将测得高度按比例缩放为 5。
;;;   - CE    : 测量点序列形成的多段线总长度。
;;;   - JZ    : 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。
;;;   - DX    : 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。
;;;   - DX1   : 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。
;;;   - DX2   : 按方格从左到右、从上到下导出文字，方格内按行排序并复制到剪贴板。
;;;   - ZZ    : 将选中文字居中到最近四条边界直线形成的矩形中心。
;;;   - MJ    : 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。
;;;   - JACC  : ZZ 的同功能入口。
;;;   - DB    : 删除每个选中文字末尾的 N 个字符。
;;;   - DF    : 删除每个选中文字开头的 N 个字符。
;;;   - DE    : 删除选中文字的最右侧括号及括号内容。
;;;   - DE2   : 用最右侧括号内容替换括号前连续数字。
;;;   - DL1   : 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。
;;;   - AB    : 在每个选中文字末尾增加输入的文字。
;;;   - AF    : 在每个选中文字开头增加输入的文字。
;;;   - QW    : 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。
;;;   - QW2   : 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。
;;;   - REP   : 将选中的柜名文字按内置映射表替换为标准柜名。
;;;   - QE    : 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。
;;;   - AW    : 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。
;;;   - ZDML  : 选择多个图框块，生成目录文字。
;;;   - ZDMLDEBUG : 选择一个图框块，打印所有增强属性。
;;;   - C1    : 复制文字并递增减号右侧编号，使用CAD原生捕捉连续放置。
;;;   - C2    : 复制文字并递减减号右侧编号，使用CAD原生捕捉连续放置。
;;;   - C3    : 复制文字并每次将减号右侧编号加 2，使用CAD原生捕捉连续放置。
;;;   - ZJ    : 为多条水平直线（多段线自动分解）左端补齐连接线，并在左侧生成包围矩形。
;;;   - YJ    : 为多条水平直线（多段线自动分解）右端补齐连接线，并在右侧生成包围矩形。
;;;   - XU    : 将所有选中且支持线型修改的对象改为 HIDDEN2。
;;;   - 0     : 将所选对象中的文字旋转角度统一改为 0 度。
;;;   - QZ    : 取消当前图纸中的全部分组，组内图元保持不变。
;;;   - XX    : 将选中文字内容替换为 7×2.5。
;;;   - DAO   : 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面）。
;;;   - QH    : 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。
;;;   - BK    : 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。
;;;   - ZTF   : 搜索系统字体并将选定字体写入指定文字样式。
;;; =======================================================================================

;;;----------------------------------------------------------------------------------------
;;;
;;;                              用户可自定义参数区域
;;;                 在这里修改变量值，可以方便地调整插件功能，无需改动核心代码
;;;
;;;----------------------------------------------------------------------------------------

;;; --- YSDL 命令相关参数 ---
(setq *YSDL_RowFuzz*      1.0)     ; (YSDL) 判断文字是否在同一行的Y坐标容差值
(setq *YSDL_CsvFileName*  "output.csv") ; (YSDL) 输出的CSV文件名
(setq *YSDL_TextColor*    2)       ; (YSDL) 提取后文字变为的颜色 (ACI颜色索引: 2=黄, 1=红, 3=绿, 4=青, 5=蓝, 6=品红, 7=白/黑, 8=浅灰, 9=浅灰)

;;; --- CONT 命令相关参数 ---
(setq *CONT_TextStyle*     "宋体")   ; (CONT) 目标文字样式名称
(setq *CONT_TextHeight*    4.0)     ; (CONT) 目标文字高度
(setq *CONT_TextWidthFactor* 0.8)   ; (CONT) 目标文字宽度因子 (仅对TEXT对象有效)
(setq *CONT_LineSpacing*   9.0)     ; (CONT) 文字垂直对齐的间距

;;; --- EXCEL 命令相关参数 ---
(setq *EXCEL_LayerName*  "表格")     ; (EXCEL) 创建的表格所在的图层名称
(setq *EXCEL_LayerColor* 3)        ; (EXCEL) 表格图层的颜色 (ACI颜色索引: 2=黄, 1=红, 3=绿, 4=青, 5=蓝, 6=品红, 7=白/黑, 8=浅灰, 9=浅灰)

;;; --- 快速改色命令相关参数 ---
(setq *Y_TextColor*      4)        ; (Y) 快速改色命令的目标颜色 (ACI颜色索引: 2=黄, 1=红, 3=绿, 4=青, 5=蓝, 6=品红, 7=白/黑, 8=浅灰, 9=浅灰)
(setq *RR_TextColor*     1)        ; (RR) 快速改色命令的目标颜色
(setq *WW_TextColor*     7)        ; (WW) 快速改色命令的目标颜色
(setq *GG_TextColor*     3)        ; (GG) 快速改色命令的目标颜色
(setq *HH_TextColor*     6)        ; (HH) 快速改色命令的目标颜色（洋红色）
(setq *HUI_TextColor*    8)        ; (HUI) 快速改色命令的目标颜色

;;; --- UT 参数 ---
(setq *UT_TiltAngle*    3.0)       ; (UT) 判断水平直线允许的最大倾斜角度（度），Y 偏差小于该角度视为水平线


;; 统一加载 Visual LISP COM 扩展，确保所有需要的功能都能正常运行
(vl-load-com)

;;;----------------------------------------------------------------------------------------
;;; ZTF - 文字样式字体搜索器
;;;----------------------------------------------------------------------------------------
(setq *ztf-style-name* nil)
(setq *ztf-font-records* nil)
(setq *ztf-filtered-fonts* nil)
(setq *ztf-selected-font* nil)
(setq *ztf-all-styles* nil)
(setq *ztf-filtered-styles* nil)
(setq *ztf-project-dir* "E:/366256/ZW-auto_lisp")

(defun ztf:sort-style-names (names / sorted name before tail)
  ;; 使用简单插入排序，避免 ZWCAD 的 vl-sort/acad_strlsort 兼容差异。
  (setq sorted nil)
  (foreach name names
    (if (= (type name) 'STR)
      (progn
        (setq before nil)
        (while (and sorted
                    (< (strcase (car sorted)) (strcase name)))
          (setq before (cons (car sorted) before)
                sorted (cdr sorted)))
        (setq sorted (append (reverse before) (cons name sorted))))))
  sorted)

(defun ztf:locate-dcl (/ p loadPath)
  (setq p (findfile "ZTF.dcl"))
  (if (not p)
    (progn
      (setq loadPath (if (and (boundp '*load-truename*)
                              (= (type *load-truename*) 'STR))
                       *load-truename*
                       nil))
      (if loadPath
        (setq p (strcat (vl-filename-directory loadPath) "\\ZTF.dcl")))))
  (if (and p (findfile p))
    (findfile p)
    (if (findfile (strcat *ztf-project-dir* "\\ZTF.dcl"))
      (findfile (strcat *ztf-project-dir* "\\ZTF.dcl"))
      nil)))

(defun ztf:style-names (/ item itemName out current)
  ;; 使用样式表原始顺序，不排序；遇到中望异常返回值时立即停止。
  (setq item (tblnext "STYLE" T))
  (while (and item (listp item))
    (setq itemName (cdr (assoc 2 item)))
    (if (= (type itemName) 'STR)
      (setq out (cons itemName out)))
    (setq item (tblnext "STYLE")))
  (setq current (getvar "TEXTSTYLE"))
  (if (and (= (type current) 'STR) (not (member current out)))
    (setq out (cons current out)))
  (ztf:sort-style-names (reverse out)))

(defun ztf:refresh-style-list (query / q style)
  (setq q (strcase (if (= (type query) 'STR) query "")))
  (setq *ztf-filtered-styles* nil)
  (start_list "style_list")
  (foreach style *ztf-all-styles*
    (if (or (= q "") (vl-string-search q (strcase style)))
      (progn
        (setq *ztf-filtered-styles*
              (append *ztf-filtered-styles* (list style)))
        (add_list style))))
  (end_list)
  (if *ztf-filtered-styles*
    (progn
      (if (member *ztf-style-name* *ztf-filtered-styles*)
        (set_tile "style_list"
                  (itoa (vl-position *ztf-style-name* *ztf-filtered-styles*)))
        (progn
          (setq *ztf-style-name* (car *ztf-filtered-styles*))
          (set_tile "style_list" "0")))
      (ztf:update-style-info *ztf-style-name*))
    (progn
      (setq *ztf-style-name* nil)
      (set_tile "style_info" "No matching text style"))))

(defun ztf:font-file-p (name / upper)
  (if (= (type name) 'STR)
    (progn
      (setq upper (strcase name))
      (or (wcmatch upper "*.TTF")
          (wcmatch upper "*.TTC")
          (wcmatch upper "*.OTF")
          (wcmatch upper "*.FON")
          (wcmatch upper "*.SHX")))
    nil))

(defun ztf:font-label (name / upper alias)
  (if (/= (type name) 'STR)
    (setq name "")
    nil)
  (setq upper (strcase name))
  (setq alias
    (cond
      ((wcmatch upper "SIMSUN*") "宋体")
      ((wcmatch upper "SIMHEI*") "黑体")
      ((wcmatch upper "SIMKAI*") "楷体")
      ((wcmatch upper "SIMFANG*") "仿宋")
      ((wcmatch upper "MSYH*") "微软雅黑")
      ((wcmatch upper "DENGXIAN*") "等线")
      ((wcmatch upper "MICROSOFTYAHEI*") "微软雅黑")
      ((wcmatch upper "NSIMSUN*") "新宋体")
      (T nil)))
  (if alias (strcat alias " | " name) name))

(defun ztf:add-font-file (file records / path)
  (if (and (= (type file) 'STR)
           (ztf:font-file-p file)
           (not (assoc file records))
           (setq path (findfile file)))
    (cons (cons file path) records)
    records))

(defun ztf:collect-font-records (/ windir dir files item path out)
  ;; 首版以 Windows Fonts 目录为主，同时补入当前图纸实际引用的字体文件。
  (setq windir (getenv "WINDIR"))
  (if (/= (type windir) 'STR) (setq windir "C:\\Windows"))
  (setq dir (strcat windir "\\Fonts"))
  (setq files (vl-catch-all-apply 'vl-directory-files (list dir nil 1)))
  (if (vl-catch-all-error-p files) (setq files nil))
  (if (/= (type files) 'LIST) (setq files nil))
  (foreach item files
    (if (ztf:font-file-p item)
      (setq out (cons (cons item (strcat dir "\\" item)) out))))
  ;; SHX 字体通常在 CAD 支持路径，不在 Windows Fonts 文件夹。
  (foreach item '("txt.shx" "simplex.shx" "romans.shx" "romand.shx"
                  "bigfont.shx" "gbcbig.shx")
    (setq out (ztf:add-font-file item out)))
  ;; 当前样式引用的 SHX 文件也加入列表。
  (setq item (getvar "TEXTSTYLE"))
  (if (= (type item) 'STR)
    (progn
      (setq path (vl-catch-all-apply 'tblsearch (list "STYLE" item)))
      (if (vl-catch-all-error-p path) (setq path nil))
      (if (and (listp path) (= (type (cdr (assoc 3 path))) 'STR))
        (setq out (ztf:add-font-file (cdr (assoc 3 path)) out)))))
  (reverse out))

(defun ztf:style-object (styleName / doc styles result)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq styles (vla-get-TextStyles doc))
  (setq result (vl-catch-all-apply 'vla-Item (list styles styleName)))
  (if (vl-catch-all-error-p result) nil result))

(defun ztf:style-font-file (styleName / styleObj result)
  (if (setq styleObj (ztf:style-object styleName))
    (progn
      (setq result (vl-catch-all-apply 'vla-get-FontFile (list styleObj)))
      (if (and (not (vl-catch-all-error-p result)) (= (type result) 'STR))
        result
        ""))
    ""))

(defun ztf:style-usage-count (styleName / ss)
  (if (setq ss (ssget "_X" (list '(0 . "TEXT,MTEXT") (cons 7 styleName))))
    (sslength ss)
    0))

(defun ztf:refresh-font-list (query / q rec label)
  (setq q (strcase (if query query "")))
  (setq *ztf-filtered-fonts* nil)
  (start_list "font_list")
  (foreach rec *ztf-font-records*
    (setq label (ztf:font-label (car rec)))
    (if (or (= q "") (vl-string-search q (strcase label)))
      (progn
        (setq *ztf-filtered-fonts* (append *ztf-filtered-fonts* (list rec)))
        (add_list label))))
  (end_list)
  (if *ztf-filtered-fonts*
    (progn
      (setq *ztf-selected-font* (car *ztf-filtered-fonts*))
      (set_tile "font_list" "0")
      (set_tile "font_path" (cdr *ztf-selected-font*)))
    (progn
      (setq *ztf-selected-font* nil)
      (set_tile "font_path" "没有匹配的字体文件"))))

(defun ztf:update-style-info (styleName / count)
  (setq *ztf-style-name* styleName)
  (setq count 0)
  (set_tile "style_info"
            (strcat "Style: " styleName "    Objects: " (itoa count))))

(defun ztf:apply-font (/ styleObj fontPath result doc)
  (if (and *ztf-style-name* *ztf-selected-font*)
    (progn
      (setq fontPath (cdr *ztf-selected-font*))
      (setq styleObj (ztf:style-object *ztf-style-name*))
      (if styleObj
        (progn
          (setq result
            (vl-catch-all-apply 'vla-put-FontFile
                                (list styleObj fontPath)))
          (if (vl-catch-all-error-p result)
            (alert (strcat "字体写入失败：\n" (vl-catch-all-error-message result)))
            (progn
              (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
              (vla-Regen doc 1)
              (alert (strcat "已将样式“" *ztf-style-name*
                             "”的字体改为：\n" (car *ztf-selected-font*))))))))
    (alert "请先选择文字样式和字体。")))

(defun ztf:run-dialog (/ dclPath dclId status styles styleIndex)
  (setq dclPath (ztf:locate-dcl))
  (if (not dclPath)
    (progn
      (alert "找不到 ZTF.dcl。请把项目目录加入 ZWCAD 的支持文件搜索路径。")
      nil)
    (progn
      (setq styles (ztf:style-names)
            *ztf-all-styles* styles)
      (if (not (member *ztf-style-name* styles))
        (setq *ztf-style-name* (getvar "TEXTSTYLE")))
      (setq dclId (load_dialog dclPath))
      (if (and (> dclId 0) (new_dialog "ztf_main" dclId))
        (progn
          (ztf:refresh-style-list "")
          (ztf:refresh-font-list "")
          (action_tile "style_search" "(ztf:refresh-style-list $value)")
          (action_tile "style_list"
            "(if (nth (atoi $value) *ztf-filtered-styles*) (ztf:update-style-info (nth (atoi $value) *ztf-filtered-styles*)))")
          (action_tile "font_search" "(ztf:refresh-font-list $value)")
          (action_tile "font_list"
            "(if (nth (atoi $value) *ztf-filtered-fonts*) (progn (setq *ztf-selected-font* (nth (atoi $value) *ztf-filtered-fonts*)) (set_tile \"font_path\" (cdr *ztf-selected-font*))) (set_tile \"font_path\" \"\"))")
          (action_tile "pick_style" "(done_dialog 2)")
          (action_tile "apply" "(ztf:apply-font)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq status (start_dialog)))
        (setq status 0))
      (if (> dclId 0) (unload_dialog dclId))
      status)))

(defun c:ZTF (/ ent ed status)
  (setq *ztf-style-name* (getvar "TEXTSTYLE"))
  (setq *ztf-font-records* (ztf:collect-font-records))
  (while (= (setq status (ztf:run-dialog)) 2)
    (if (setq ent (entsel "\n选择一段文字以读取其文字样式："))
      (progn
        (setq ed (entget (car ent)))
        (if (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
          (setq *ztf-style-name* (cdr (assoc 7 ed)))
          (princ "\n所选对象不是 TEXT 或 MTEXT。")))
      (princ "\n未选择文字。")))
  (princ)
)

(defun aa:set-entity-aci-color (ename color / ed)
  (if (setq ed (entget ename))
    (progn
      (setq ed
        (vl-remove-if
          '(lambda (item) (member (car item) '(420 430)))
          ed))
      (if (assoc 62 ed)
        (setq ed (subst (cons 62 color) (assoc 62 ed) ed))
        (setq ed (append ed (list (cons 62 color)))))
      (if (entmod ed) T nil))
    nil)
)

(defun aa:try-get-bbox (vla_obj / min_pt max_pt result)
  (setq result
         (vl-catch-all-apply
           'vla-getboundingbox
           (list vla_obj 'min_pt 'max_pt)))
  (if (not (vl-catch-all-error-p result))
    (list (vlax-safearray->list min_pt)
          (vlax-safearray->list max_pt))
  )
)

(defun aa:safe-get-bbox (doc ename / vla_obj bbox)
  (if (and ename
           (setq vla_obj (vlax-ename->vla-object ename)))
    (progn
      (setq bbox (aa:try-get-bbox vla_obj))
      (if (null bbox)
        (progn
          (vl-catch-all-apply 'vla-update (list vla_obj))
          (entupd ename)
          (setq bbox (aa:try-get-bbox vla_obj))
        )
      )
      (if (and (null bbox) doc)
        (progn
          (vl-catch-all-apply 'vla-regen (list doc 0))
          (setq bbox (aa:try-get-bbox vla_obj))
        )
      )
      bbox
    )
  )
)

(defun aa:bbox-center-x (bbox)
  (/ (+ (car (car bbox))
        (car (cadr bbox)))
     2.0)
)

(defun aa:bbox-left-x (bbox)
  (car (car bbox))
)

(defun aa:bbox-right-x (bbox)
  (car (cadr bbox))
)

(defun aa:bbox-top-y (bbox)
  (cadr (cadr bbox))
)

(defun aa:bbox-bottom-y (bbox)
  (cadr (car bbox))
)

(defun aa:safe-move-entity (ename move_vec / vla_obj result)
  (if (and ename
           move_vec
           (setq vla_obj (vlax-ename->vla-object ename)))
    (progn
      (setq result
             (vl-catch-all-apply
               'vla-move
               (list vla_obj
                     (vlax-3d-point '(0.0 0.0 0.0))
                     move_vec)))
      (if (not (vl-catch-all-error-p result))
        (progn
          (entupd ename)
          T
        )
        nil
      )
    )
  )
)

(defun aa:find-ref-by-left-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (< (aa:bbox-left-x bbox)
                 (aa:bbox-left-x ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:find-ref-by-top-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (> (aa:bbox-top-y bbox)
                 (aa:bbox-top-y ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:align-text-horizontal-by-bbox (doc ename base-x mode / bbox current-x delta-x)
  (if (setq bbox (aa:safe-get-bbox doc ename))
    (progn
      (setq current-x (cond
                        ((= mode 3) (aa:bbox-right-x bbox))
                        ((= mode 2) (aa:bbox-center-x bbox))
                        (T (aa:bbox-left-x bbox)))
            delta-x   (- base-x current-x))
      (if (equal delta-x 0.0 1e-8)
        T
        (aa:safe-move-entity ename (vlax-3d-point (list delta-x 0.0 0.0)))))
  )
)

(defun aa:align-text-vertical-by-bbox (doc ename base-y mode / bbox current-y delta-y)
  (if (setq bbox (aa:safe-get-bbox doc ename))
    (progn
      (setq current-y (if (= mode 1)
                        (aa:bbox-top-y bbox)
                        (aa:bbox-bottom-y bbox))
            delta-y   (- base-y current-y))
      (if (equal delta-y 0.0 1e-8)
        T
        (aa:safe-move-entity ename (vlax-3d-point (list 0.0 delta-y 0.0)))))
  )
)


;;; =======================================================================================
(defun aa:str-replace-all (old new str / start pos result old-len)
  (setq str     (if str str "")
        start   0
        result  ""
        old-len (strlen old))
  (if (= old-len 0)
    str
    (progn
      (while (setq pos (vl-string-search old str start))
        (setq result
               (strcat
                 result
                 (if (> pos start)
                   (substr str (1+ start) (- pos start))
                   "")
                 new)
              start (+ pos old-len))
      )
      (strcat result (substr str (1+ start)))
    )
  )
)

(defun aa:ysdl-get-raw-text (edata / etype raw pair)
  (setq etype (cdr (assoc 0 edata))
        raw   "")
  (cond
    ((= etype "MTEXT")
     (foreach pair edata
       (if (or (= (car pair) 3) (= (car pair) 1))
         (setq raw (strcat raw (cdr pair)))
       )
     )
    )
    (T
     (setq raw (cdr (assoc 1 edata)))
    )
  )
  (if raw raw "")
)

(defun aa:ysdl-strip-mtext-format (str / idx len out ch next semi stack)
  (setq str (if str str "")
        idx 1
        len (strlen str)
        out "")
  (while (<= idx len)
    (setq ch (substr str idx 1))
    (cond
      ((or (= ch "{") (= ch "}"))
       (setq idx (1+ idx)))
      ((/= ch "\\")
       (setq out (strcat out ch)
             idx (1+ idx)))
      ((= idx len)
       (setq idx (1+ idx)))
      (T
       (setq next (substr str (1+ idx) 1))
       (cond
         ((or (= next "\\") (= next "{") (= next "}"))
          (setq out (strcat out next)
                idx (+ idx 2)))
         ((or (= next "P") (= next "p") (= next "~"))
          (setq out (strcat out " ")
                idx (+ idx 2)))
         ((or (= next "L") (= next "l")
              (= next "O") (= next "o")
              (= next "K") (= next "k")
              (= next "X"))
          (setq idx (+ idx 2)))
         ((= next "S")
          (setq semi (vl-string-search ";" str (+ idx 1)))
          (if semi
            (progn
              (setq stack (substr str (+ idx 2) (- semi idx 1)))
              (setq stack (aa:str-replace-all "#" "/" stack))
              (setq stack (aa:str-replace-all "^" "/" stack))
              (setq out (strcat out stack)
                    idx (+ semi 2)))
            (setq idx (+ idx 2))
          )
         )
         ((or (= next "A") (= next "C") (= next "c")
              (= next "F") (= next "f")
              (= next "H") (= next "Q")
              (= next "T") (= next "W"))
          (setq semi (vl-string-search ";" str (+ idx 1)))
          (if semi
            (setq idx (+ semi 2))
            (setq idx (+ idx 2))
          )
         )
         (T
          (setq out (strcat out next)
                idx (+ idx 2)))
       )
      )
    )
  )
  out
)

(defun aa:ysdl-get-plain-text (edata / raw)
  (setq raw (aa:ysdl-get-raw-text edata))
  (if (= (cdr (assoc 0 edata)) "MTEXT")
    (setq raw (aa:ysdl-strip-mtext-format raw))
  )
  raw
)

(defun aa:ysdl-needs-text-formula (str / first)
  (and str
       (> (strlen str) 0)
       (setq first (substr str 1 1))
       (or (= first "=") (= first "+") (= first "-") (= first "@")))
)

(defun aa:ysdl-build-csv-field (cell / field)
  (setq field (if cell cell ""))
  (if (aa:ysdl-needs-text-formula field)
    (setq field (strcat (chr 9) field))
  )
  (setq field (aa:str-replace-all "\"" "\"\"" field))
  (strcat "\"" field "\"")
)

;;; 命令: YSDL
;;; 功能: 提取选中的文字，自动保存或追加到桌面指定名称的CSV文件中，然后改变文字颜色。
;;; =======================================================================================
(defun c:YSDL (/ *error* ss i ent edata text-data-list sorted-data
               csv-path f fuzz userprofile file-mode action-msg
               ename targetColor text-string ins-point all-rows current-row
               last-y item current-y line-str cell cell-safe)

  ;; 自定义错误处理函数
  (defun *error* (msg)
    (if (and f (= (type f) 'FILE))
      (close f)
    )
    (if (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*"))
      (princ (strcat "\n发生错误: " msg))
    )
    (princ)
  )

  ;; 从全局配置获取容差值
  (setq fuzz *YSDL_RowFuzz*) 

  ;; 1. 提示用户选择文字对象
  (princ "\n请选择要导出并改变颜色的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      ;; 2. 提取所选文字的内容和插入点坐标
      (setq text-data-list '()
            i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq edata (entget ent))
        (setq text-string (aa:ysdl-get-plain-text edata))
        (setq ins-point (cdr (assoc 10 edata)))
        (setq text-data-list (cons (list text-string ins-point) text-data-list))
        (setq i (1+ i))
      )

      ;; 3. 按坐标排序 (从上到下，从左到右)
      (setq sorted-data
             (vl-sort text-data-list
                      '(lambda (item1 item2)
                         (setq y1 (cadr (cadr item1)))
                         (setq y2 (cadr (cadr item2)))
                         (if (> y1 (+ y2 fuzz))
                           T
                           (if (< y1 (- y2 fuzz))
                             nil
                             (< (car (cadr item1)) (car (cadr item2)))
                           )
                         )
                       )
             )
      )

      ;; 4. 将排序后的数据按行分组
      (setq all-rows '())
      (if sorted-data
        (progn
          (setq current-row (list (car (car sorted-data))))
          (setq last-y (cadr (cadr (car sorted-data))))
          (foreach item (cdr sorted-data)
            (setq current-y (cadr (cadr item)))
            (if (<= (abs (- current-y last-y)) fuzz)
              (setq current-row (append current-row (list (car item))))
              (progn
                (setq all-rows (append all-rows (list current-row)))
                (setq current-row (list (car item)))
              )
            )
            (setq last-y current-y)
          )
          (setq all-rows (append all-rows (list current-row)))
        )
      )

      ;; 5. 自动定位桌面路径并写入或追加CSV文件
      (setq userprofile (getenv "USERPROFILE"))
      (if (and userprofile (/= userprofile ""))
        (progn
          (setq csv-path (strcat userprofile "\\Desktop\\" *YSDL_CsvFileName*))
          (if (findfile csv-path)
            (progn (setq file-mode "a") (setq action-msg "数据已成功追加到桌面文件:\n"))
            (progn (setq file-mode "w") (setq action-msg "已在桌面成功创建文件:\n"))
          )
          
          (setq f (open csv-path file-mode))
          (foreach row all-rows
            (setq line-str "")
            (foreach cell row
                (setq cell-safe (aa:ysdl-build-csv-field cell))
                (setq line-str (strcat line-str cell-safe ","))
            )
            (setq line-str (substr line-str 1 (1- (strlen line-str))))
            (write-line line-str f)
          )
          (close f)

          ;; 修改已导出文字的颜色
          (setq targetColor *YSDL_TextColor*)
          (setq i 0)
          (repeat (sslength ss)
            (setq ename (ssname ss i))
            (aa:set-entity-aci-color ename targetColor)
            (setq i (1+ i))
          )
          (redraw)

          (alert (strcat action-msg csv-path "\n\n并且所有选中的文字颜色已更改。"))
        )
        (alert "错误: 无法自动获取您的桌面路径!")
      )
    )
    (princ "\n未选择任何文字对象。")
  )
  (princ) 
)


;;; =======================================================================================
;;; 命令: CONT
;;; 功能: 批量修改文字的样式、字高、宽度，并从上到下等距左对齐排列。
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: EXCEL
;;; 功能: 根据用户输入的参数绘制一个表格。
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: LONG
;;; 功能: 计算所有选定多段线（Polyline 和 LWPolyline）的总长度。
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: QSTXT
;;; 功能: 快速选择。在已有的选择集中，仅保留文字类型的对象。
;;; =======================================================================================
(defun c:qstxt (/ ss i ent txt)
  (setq ss (ssget))
  (if ss
    (progn
      (setq txt (ssadd))
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (if (wcmatch (cdr (assoc 0 (entget ent))) "*TEXT")
          (ssadd ent txt)
        )
        (setq i (1+ i))
      )
      
      (if (> (sslength txt) 0)
        (progn
          (sssetfirst nil txt)
          (princ (strcat "\n已选择 " (itoa (sslength txt)) " 个文字对象"))
        )
        (princ "\n所选对象中没有找到文字对象")
      )
    )
    (princ "\n未选择任何对象")
  )
  (princ)
)



;;; =======================================================================================
;;; Command: TXT
;;; Purpose: Filter selected TEXT and MTEXT, explode MTEXT into TEXT, then set style,
;;;          height, and width factor while keeping other properties unchanged.
;;; =======================================================================================
(defun txt:set-dxf (code value data / item)
  (if (setq item (assoc code data))
    (subst (cons code value) item data)
    (append data (list (cons code value)))
  )
)

(defun txt:modify-text (ename / edata)
  (if (and ename (= "TEXT" (cdr (assoc 0 (setq edata (entget ename))))))
    (progn
      (setq edata (txt:set-dxf 7 "HZ" edata))
      (setq edata (txt:set-dxf 40 3.0 edata))
      (setq edata (txt:set-dxf 41 0.7 edata))
      (if (entmod edata) 1 0)
    )
    0
  )
)

(defun txt:modify-new-texts (before after / cur count)
  (setq count 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (if before (entnext before) (entnext)))
      (while cur
        (if (= "TEXT" (cdr (assoc 0 (entget cur))))
          (setq count (+ count (txt:modify-text cur)))
        )
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))
        )
      )
    )
  )
  count
)

(defun txt:process-selection (sel / *error* oldcmdecho total i ename etype mtss mtlist before after count)
  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho)
    )
    (if (and msg (/= msg "Function cancelled") (/= msg "quit / exit abort"))
      (princ (strcat "\n错误: " msg))
    )
    (princ)
  )

  (setq oldcmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setq total  (sslength sel)
        mtss   (ssadd)
        mtlist '()
        count  0
        i      0)

  ;; Modify TEXT immediately instead of building another large selection set.
  (while (< i total)
    (setq ename (ssname sel i)
          etype (cdr (assoc 0 (entget ename))))
    (cond
      ((= etype "TEXT")
       (setq count (+ count (txt:modify-text ename))))
      ((= etype "MTEXT")
       (ssadd ename mtss)
       (setq mtlist (cons ename mtlist)))
    )
    (setq i (1+ i))
  )

  ;; Explode all MTEXT objects in one native command invocation.
  (if (> (sslength mtss) 0)
    (progn
      (setq before (entlast))
      (command "_.explode" mtss "")

      ;; Retry only objects left behind by CAD versions that do not accept a
      ;; multi-object selection set from AutoLISP EXPLODE.
      (foreach ename mtlist
        (if (= "MTEXT" (cdr (assoc 0 (entget ename))))
          (command "_.explode" ename)
        )
      )

      ;; Process the new database range directly; do not copy it into a list
      ;; or reselect every result, both of which are costly in ZWCAD.
      (setq after (entlast)
            count (+ count (txt:modify-new-texts before after)))
    )
  )

  (redraw)
  (setvar "CMDECHO" oldcmdecho)
  (princ (strcat "\n已处理文字数量: " (itoa count)))
  count
)

(defun txt:run (/ sel)
  (if (null (tblsearch "STYLE" "HZ"))
    (princ "\n未找到文字样式 HZ。")
    (progn
      (setq sel (ssget '((0 . "TEXT,MTEXT"))))
      (if sel
        (txt:process-selection sel)
        (princ "\n未选择任何对象。")
      )
    )
  )
  (princ)
)

(defun c:T ()
  (txt:run)
)
;;; =======================================================================================
;;; 命令: H
;;; 功能: 先将选中文字统一为左中对正，再按用户输入的垂直间距从上到下排列。

;;; =======================================================================================
;;; 命令: KUANG
;;; 功能: 依次指定有效区域的左上角点，自动选中各图框有效范围内的对象。
;;; =======================================================================================
(vl-load-com)

(defun ys-pt (x y)
  (list x y 0.0)
)

(defun ys-make-eff-poly (p / x y p1 p2 p3 p4 p5 p6)
  (setq x (car p))
  (setq y (cadr p))

  (setq p1 (list x y 0.0))                 ; 起点：左上角
  (setq p2 (list (+ x 390.0) y 0.0))       ; 向右 390
  (setq p3 (list (+ x 390.0) (- y 237.0) 0.0)) ; 向下 237
  (setq p4 (list (+ x 210.0) (- y 237.0) 0.0)) ; 向左 180
  (setq p5 (list (+ x 210.0) (- y 287.0) 0.0)) ; 向下 50
  (setq p6 (list x (- y 287.0) 0.0))       ; 向左 210
  (list p1 p2 p3 p4 p5 p6)
)

(defun ys-ss->list (ss / i lst)
  (setq lst '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq lst (cons (ssname ss i) lst))
        (setq i (1+ i))
      )
    )
  )
  lst
)

;;; =======================================================================================
(defun c:H (/ a ss doc i ename vla_obj min_pt max_pt min_list max_list
              text_list sorted_text_list anchor_ent anchor_left anchor_top
              current_top current_left target_top delta_x delta_y move_vec count)
  (vl-load-com)
  (setq a (getdist "\n请输入上下间距 <5>: "))
  (if (not a)
    (setq a 5)
  )

  (princ "\n选择要对齐的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if (not ss)
    (progn (princ "\n未选择任何文字对象。") (exit))
  )

  (setq text_list '()
        i 0
        doc (vla-get-activedocument (vlax-get-acad-object)))
  (repeat (sslength ss)
    (setq ename   (ssname ss i)
          vla_obj (vlax-ename->vla-object ename))
    ;; 先统一为左中对正，再按统一的文字包围盒排列。
    (aa:normalize-text-horizontal-align doc ename 1)
    (vla-getboundingbox vla_obj 'min_pt 'max_pt)
    (setq min_list  (vlax-safearray->list min_pt)
          max_list  (vlax-safearray->list max_pt)
          text_list (cons (list (cadr max_list) (car min_list) ename) text_list)
          i         (1+ i))
  )

  (setq sorted_text_list
    (vl-sort
      text_list
      '(lambda (a b)
         (if (equal (car a) (car b) 1e-8)
           (< (cadr a) (cadr b))
           (> (car a) (car b))))))

  ;; Keep the top text completely unchanged. Its left edge is the anchor.
  (setq anchor_ent  (nth 2 (car sorted_text_list))
        anchor_top  (car (car sorted_text_list))
        anchor_left (cadr (car sorted_text_list))
        doc         (vla-get-activedocument (vlax-get-acad-object))
        count       0)

  (vla-startundomark doc)
  (foreach text_info sorted_text_list
    (setq ename (nth 2 text_info))
    (if (not (eq ename anchor_ent))
      (progn
        (setq vla_obj (vlax-ename->vla-object ename))
        (vla-getboundingbox vla_obj 'min_pt 'max_pt)
        (setq min_list   (vlax-safearray->list min_pt)
              max_list   (vlax-safearray->list max_pt)
              current_left (car min_list)
              current_top (cadr max_list)
              target_top (- anchor_top (* count a))
              delta_x    (- anchor_left current_left)
              delta_y    (- target_top current_top))
        (if (or (/= delta_x 0.0) (/= delta_y 0.0))
          (progn
            (setq move_vec (vlax-3d-point (list delta_x delta_y 0.0)))
            (vla-move vla_obj (vlax-3d-point '(0.0 0.0 0.0)) move_vec)
            (entupd ename)
          )
        )
      )
    )
    (setq count (1+ count))
  )
  (vla-endundomark doc)

  (princ (strcat "\n成功以最上方文字为基准排列并左对齐了 " (itoa (sslength ss)) " 个文字对象。"))
  (princ)
)


;;; =======================================================================================
;;; 命令: Y
;;; 功能: 快速将选中对象的颜色更改为预设颜色（默认为黄色）。
;;; =======================================================================================
(defun c:y (/ targetColor ss i ename)
  (setq targetColor *Y_TextColor*) ; 从配置区获取颜色
  (princ "\n选择要改变颜色的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ (strcat "\n所有选中的对象颜色已更改。"))
    )
    (princ "\n没有选中任何对象。")
  )
  (princ)
)

;;; =======================================================================================
;;; Command: RR
;;; Function: Set selected objects to red color.
;;; =======================================================================================
(defun c:RR (/ targetColor ss i ename)
  (setq targetColor *RR_TextColor*) ; 从配置区获取颜色
  (princ "\n选择要改为红色的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ "\n所有选中对象已改为红色。")
    )
    (princ "\n未选择任何对象。")
  )
  (princ)
)

;;; =======================================================================================
;;; Command: WW
;;; Function: Set selected objects to white color.
;;; =======================================================================================
(defun c:WW (/ targetColor ss i ename)
  (setq targetColor *WW_TextColor*) ; 从配置区获取颜色
  (princ "\n选择要改为白色的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ "\n所有选中对象已改为白色。")
    )
    (princ "\n未选择任何对象。")
  )
  (princ)
)
;;; =======================================================================================
;;; Command: XU
;;; Function: 将所有选中且支持线型修改的对象改为 HIDDEN2。
;;; =======================================================================================
(defun c:XU (/ *error* doc undo-open oldcmdecho ss i ename obj
              old-ltype result changed unchanged skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho (getvar "CMDECHO")
        changed 0
        unchanged 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[XU] 错误：" msg)))
    (princ))

  (setvar "CMDECHO" 0)
  ;; 图中没有 HIDDEN2 时，先从 CAD 默认线型库加载。
  (if (not (tblsearch "LTYPE" "HIDDEN2"))
    (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))

  (if (tblsearch "LTYPE" "HIDDEN2")
    (progn
      ;; 不设置任何对象类型过滤，处理时再判断是否支持线型属性。
      (setq ss (ssget "_I"))
      (if (null ss)
        (progn
          (princ "\n[XU] 请选择需要改为 HIDDEN2 线型的对象：")
          (setq ss (ssget))))

      (if ss
        (progn
          (vl-catch-all-apply 'vla-StartUndoMark (list doc))
          (setq undo-open T
                i 0)
          (repeat (sslength ss)
            (setq ename (ssname ss i)
                  obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
            (if (or (vl-catch-all-error-p obj)
                    (not (vlax-property-available-p obj 'Linetype T)))
              (setq skipped (1+ skipped))
              (progn
                (setq old-ltype
                      (vl-catch-all-apply 'vla-get-Linetype (list obj)))
                (if (and (not (vl-catch-all-error-p old-ltype))
                         (= (strcase old-ltype) "HIDDEN2"))
                  (setq unchanged (1+ unchanged))
                  (progn
                    (setq result
                          (vl-catch-all-apply
                            'vla-put-Linetype
                            (list obj "HIDDEN2")))
                    (if (vl-catch-all-error-p result)
                      (setq skipped (1+ skipped))
                      (setq changed (1+ changed)))))))
            (setq i (1+ i)))
          (redraw)
          (vl-catch-all-apply 'vla-EndUndoMark (list doc))
          (setq undo-open nil)
          (princ
            (strcat "\n[XU] 处理完成：已改为 HIDDEN2 " (itoa changed) " 个"
                    "，原本已是该线型 " (itoa unchanged) " 个"
                    "，无法修改 " (itoa skipped) " 个。")))
        (princ "\n[XU] 未选择任何对象。")))
    (princ "\n[XU] 无法加载 HIDDEN2 线型，命令已取消。"))

  (setvar "CMDECHO" oldcmdecho)
  (sssetfirst nil nil)
  (princ))

;;; =======================================================================================
;;; Command: GG
;;; Function: Set selected objects to green color.
;;; =======================================================================================
(defun c:GG (/ targetColor ss i ename)
  (setq targetColor *GG_TextColor*) ; 从配置区获取颜色
  (princ "\n选择要改为绿色的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ "\n所有选中对象已改为绿色。")
    )
    (princ "\n未选择任何对象。")
  )
  (princ)
)

;;; =======================================================================================
;;; 命令: HH
;;; 功能: 将选中的所有对象颜色改为洋红色（ACI 6）。
;;; =======================================================================================
(defun c:HH (/ targetColor ss i ename)
  (setq targetColor *HH_TextColor*) ; 从配置区获取颜色
  (princ "\n请选择要改为洋红色的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ "\n所有选中对象已改为洋红色。")
    )
    (princ "\n未选择任何对象。")
  )
  (princ)
)







;;; =======================================================================================
;;; 命令: HUI
;;; 功能: 将选中的所有对象颜色改为颜色 8。
;;; =======================================================================================
(defun c:HUI (/ targetColor ss i ename ed typ obj result exploded item child)
  (setq targetColor *HUI_TextColor*)
  (princ "\n选择要改为颜色 8 的对象: ")
  (setq ss (ssget))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq ed (entget ename)
              typ (cdr (assoc 0 ed)))
        (if (= typ "INSERT")
          (progn
            ;; 块参照先分解，再把分解出的每个对象改为目标颜色。
            (setq obj (vlax-ename->vla-object ename)
                  result (vl-catch-all-apply 'vla-Explode (list obj))
                  exploded nil)
            (if (not (vl-catch-all-error-p result))
              (progn
                (setq result (vl-catch-all-apply 'vlax-variant-value (list result)))
                (if (not (vl-catch-all-error-p result))
                  (progn
                    (setq result (vl-catch-all-apply 'vlax-safearray->list (list result)))
                    (if (not (vl-catch-all-error-p result))
                      (progn
                        (setq exploded T)
                        (foreach item result
                          (setq child (vl-catch-all-apply 'vlax-vla-object->ename (list item)))
                          (if (not (vl-catch-all-error-p child))
                            (aa:set-entity-aci-color child targetColor)))))))))
            ;; 分解失败时保留并尽量修改块参照自身颜色。
            (if (not exploded)
              (aa:set-entity-aci-color ename targetColor)))
          (aa:set-entity-aci-color ename targetColor))
        (setq i (1+ i))
      )
      (redraw)
      (princ "\n所有选中对象已改为颜色 8。")
    )
    (princ "\n没有选中任何对象。")
  )
  (princ)
)

(defun aa:get-dxf-point (ed code / v y z)
  (setq v (if (assoc code ed) (cdr (assoc code ed)) nil)
        y (if (assoc (+ code 10) ed) (cdr (assoc (+ code 10) ed)) 0.0)
        z (if (assoc (+ code 20) ed) (cdr (assoc (+ code 20) ed)) 0.0))
  (cond
    ((listp v)
     (list (float (car v))
           (float (cadr v))
           (float (if (caddr v) (caddr v) 0.0))))
    ((numberp v)
     (list (float v)
           (float y)
           (float z)))
  )
)

(defun aa:set-dxf-int (ed code value / row)
  (setq row (assoc code ed))
  (if row
    (subst (cons code value) row ed)
    (append ed (list (cons code value))))
)

(defun aa:set-dxf-point (ed code pt / row)
  (setq row (assoc code ed))
  (if row
    (subst (list code (car pt) (cadr pt) (caddr pt)) row ed)
    (append ed (list (list code (car pt) (cadr pt) (caddr pt)))))
)

(defun aa:text-anchor-point (ed / typ h v)
  (setq typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "TEXT")
     (setq h (if (assoc 72 ed) (cdr (assoc 72 ed)) 0)
           v (if (assoc 73 ed) (cdr (assoc 73 ed)) 0))
     (if (or (/= h 0) (/= v 0))
       (or (aa:get-dxf-point ed 11)
           (aa:get-dxf-point ed 10))
       (aa:get-dxf-point ed 10)))
    ((= typ "MTEXT")
     (aa:get-dxf-point ed 10))
  )
)

(defun aa:mtext-center-attachment (ap)
  (cond
    ((member ap '(1 2 3)) 2)
    ((member ap '(4 5 6)) 5)
    ((member ap '(7 8 9)) 8)
    (T 5))
)

(defun aa:center-text-by-anchor (ename base-x / ed typ pt v ap new-pt ok)
  (setq ed  (entget ename)
        typ (if ed (cdr (assoc 0 ed)) nil)
        pt  (aa:text-anchor-point ed))
  (if (and ed pt)
    (progn
      (setq new-pt (list base-x (cadr pt) (caddr pt)))
      (cond
        ((= typ "TEXT")
         (setq v  (if (assoc 73 ed) (cdr (assoc 73 ed)) 0)
               ed (aa:set-dxf-int ed 72 1)
               ed (aa:set-dxf-int ed 73 v)
               ed (aa:set-dxf-point ed 10 new-pt)
               ed (aa:set-dxf-point ed 11 new-pt)))
        ((= typ "MTEXT")
         (setq ap (if (assoc 71 ed) (cdr (assoc 71 ed)) 1)
               ed (aa:set-dxf-int ed 71 (aa:mtext-center-attachment ap))
               ed (aa:set-dxf-point ed 10 new-pt)))
      )
      (setq ok (entmod ed))
      (if ok
        (progn
          (entupd ename)
          T)
        nil))
    nil)
)

;;; 功能: 将选中文字统一为中中对正，并以最上方文字为基准居中对齐。
(defun c:ZHONG (/ *error* ss doc undo-open ref i ename bbox dx changed skipped base-x)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[ZHONG] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[ZHONG] 请选择要居中对齐的文字...")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (setq ref (aa:find-ref-by-top-bbox doc ss))
      (progn
        (setq base-x (aa:bbox-center-x (cadr ref)))
        (vla-startundomark doc)
        (setq undo-open T
              i         0)
        (repeat (sslength ss)
          (setq ename (ssname ss i))
          (if (aa:normalize-text-horizontal-align doc ename 2)
            (if (or (eq ename (car ref))
                    (aa:align-text-horizontal-by-bbox doc ename base-x 2))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq skipped (1+ skipped)))
          (setq i (1+ i))
        )
        (vla-endundomark doc)
        (setq undo-open nil)
        (princ
          (strcat
            "\n[ZHONG] 完成。基准 X: "
            (rtos base-x 2 4)
            "，已处理: "
            (itoa changed)
            "，跳过: "
            (itoa skipped)
            "."))
      )
      (princ "\n[ZHONG] 选择中没有有效的文字范围。")
    )
    (princ "\n[ZHONG] 未选择文字对象。")
  )
  (princ)
)

(defun aa:text-raw-v (ed)
  (if (assoc 73 ed) (cdr (assoc 73 ed)) 0)
)

(defun aa:text-normalized-h (ed / h)
  (setq h (if (assoc 72 ed) (cdr (assoc 72 ed)) 0))
  (cond
    ((= h 2) 2)
    ((member h '(1 4)) 1)
    (T 0))
)

(defun aa:mtext-h-tier (ap)
  (+ 1 (rem (max 0 (1- ap)) 3))
)

(defun aa:mtext-v-tier (ap)
  (+ 1 (fix (/ (max 0 (1- ap)) 3)))
)

(defun aa:mtext-attachment (h-tier v-tier)
  (+ h-tier (* (1- v-tier) 3))
)

(defun aa:set-text-horizontal-align (ename base-x mode / ed typ obj target result)
  (setq ed  (entget ename)
        typ (if ed (cdr (assoc 0 ed)) nil)
        obj (if ed (vlax-ename->vla-object ename) nil))
  (cond
    ((= typ "TEXT")
     (setq target (cond ((= mode 1) 9) ((= mode 3) 11) (T 10))
           result (vl-catch-all-apply 'vla-put-Alignment (list obj target))))
    ((= typ "MTEXT")
     (setq target (cond ((= mode 1) 4) ((= mode 3) 6) (T 5))
           result (vl-catch-all-apply 'vla-put-AttachmentPoint (list obj target))))
    (T
     (setq result nil))
  )
  (if (not (vl-catch-all-error-p result))
    (progn
      (vl-catch-all-apply 'vla-update (list obj))
      (entupd ename)
      T)
    nil)
)

(defun aa:set-text-vertical-align (ename base-y mode / ed typ obj target result)
  (setq ed  (entget ename)
        typ (if ed (cdr (assoc 0 ed)) nil)
        obj (if ed (vlax-ename->vla-object ename) nil))
  (cond
    ((= typ "TEXT")
     (setq target (if (= mode 1) 7 13)
           result (vl-catch-all-apply 'vla-put-Alignment (list obj target))))
    ((= typ "MTEXT")
     (setq target (if (= mode 1) 2 8)
           result (vl-catch-all-apply 'vla-put-AttachmentPoint (list obj target))))
    (T
     (setq result nil))
  )
  (if (not (vl-catch-all-error-p result))
    (progn
      (vl-catch-all-apply 'vla-update (list obj))
      (entupd ename)
      T)
    nil)
)

(defun aa:normalize-text-horizontal-align (doc ename mode / old-bbox new-bbox dx dy)
  (setq old-bbox (aa:safe-get-bbox doc ename))
  (if (aa:set-text-horizontal-align ename 0.0 mode)
    (if (and old-bbox (setq new-bbox (aa:safe-get-bbox doc ename)))
      (progn
        (setq dx (- (aa:bbox-left-x old-bbox) (aa:bbox-left-x new-bbox))
              dy (- (aa:bbox-bottom-y old-bbox) (aa:bbox-bottom-y new-bbox)))
        (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
          T
          (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))))
      T)
    nil)
)

(defun aa:normalize-text-vertical-align (doc ename mode / old-bbox new-bbox dx dy)
  (setq old-bbox (aa:safe-get-bbox doc ename))
  (if (aa:set-text-vertical-align ename 0.0 mode)
    (if (and old-bbox (setq new-bbox (aa:safe-get-bbox doc ename)))
      (progn
        (setq dx (- (aa:bbox-left-x old-bbox) (aa:bbox-left-x new-bbox))
              dy (- (aa:bbox-bottom-y old-bbox) (aa:bbox-bottom-y new-bbox)))
        (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
          T
          (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))))
      T)
    nil)
)

(defun aa:find-ref-by-top-anchor (ss / i ename ed pt ref-ename ref-pt)
  (setq i 0
        ref-ename nil
        ref-pt nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          ed    (entget ename)
          pt    (aa:text-anchor-point ed))
    (if pt
      (if (or (null ref-pt)
              (> (cadr pt) (cadr ref-pt)))
        (setq ref-ename ename
              ref-pt    pt))
    )
    (setq i (1+ i))
  )
  (if ref-pt
    (list ref-ename ref-pt))
)

(defun aa:find-ref-by-left-anchor (ss / i ename ed pt ref-ename ref-pt)
  (setq i 0
        ref-ename nil
        ref-pt nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          ed    (entget ename)
          pt    (aa:text-anchor-point ed))
    (if pt
      (if (or (null ref-pt)
              (< (car pt) (car ref-pt)))
        (setq ref-ename ename
              ref-pt    pt))
    )
    (setq i (1+ i))
  )
  (if ref-pt
    (list ref-ename ref-pt))
)

;;; 功能: 将选中文字统一为左中对正，并以最上方文字为基准左对齐。
(defun c:ZUO (/ *error* ss doc undo-open ref i ename base-x changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[ZUO] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[ZUO] 请选择要左对齐的文字...")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (setq ref (aa:find-ref-by-top-bbox doc ss))
      (progn
        (setq base-x (aa:bbox-left-x (cadr ref)))
        (vla-startundomark doc)
        (setq undo-open T
              i         0)
        (repeat (sslength ss)
          (setq ename (ssname ss i))
          (if (aa:normalize-text-horizontal-align doc ename 1)
            (if (or (eq ename (car ref))
                    (aa:align-text-horizontal-by-bbox doc ename base-x 1))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq skipped (1+ skipped)))
          (setq i (1+ i))
        )
        (vla-endundomark doc)
        (setq undo-open nil)
        (princ
          (strcat
            "\n[ZUO] 完成。基准 X: "
            (rtos base-x 2 4)
            "，已处理: "
            (itoa changed)
            "，跳过: "
            (itoa skipped)
            "."))
      )
      (princ "\n[ZUO] 选择中没有有效的文字范围。")
    )
    (princ "\n[ZUO] 未选择文字对象。")
  )
  (princ)
)

;;; =======================================================================================
;;; 命令: HP
;;; 功能: 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。
;;; =======================================================================================
(defun c:HP (/ *error* doc undo-open step ss i ename bbox items ref ref-bbox target-left base-top
             current-right item item-width dx dy changed skipped)
  (vl-load-com)
  (setq doc (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[HP] 错误: " msg)))
    (princ)
  )

  (setq step (getdist "\n请输入相邻文字首尾间距 <5>: "))
  (if (null step)
    (setq step 5.0))

  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[HP] 选择要左右排列的文字对象: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))))

  (if ss
    (progn
      (setq i 0
            items '()
            ref nil)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              bbox (aa:safe-get-bbox doc ename))
        (if bbox
          (progn
            (setq items (cons (list ename bbox) items))
            (if (or (null ref)
                    (< (aa:bbox-left-x bbox) (aa:bbox-left-x (cadr ref))))
              (setq ref (list ename bbox))))
          (setq skipped (1+ skipped)))
        (setq i (1+ i)))

      (if (> (length items) 0)
        (progn
          (setq items (vl-sort items
                        '(lambda (a b)
                           (< (aa:bbox-left-x (cadr a))
                              (aa:bbox-left-x (cadr b))))))
          (setq ref (car items)
                ref-bbox (cadr ref)
                base-top (aa:bbox-top-y ref-bbox)
                current-right (aa:bbox-right-x ref-bbox))

          (vla-startundomark doc)
          (setq undo-open T)

          (foreach item items
            (setq ename (car item)
                  bbox (cadr item))
            (if (eq ename (car ref))
              (setq changed (1+ changed))
              (progn
                (setq item-width (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox))
                      target-left (+ current-right step)
                      dx (- target-left (aa:bbox-left-x bbox))
                      dy (- base-top (aa:bbox-top-y bbox)))
                (if (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))
                  (setq changed (1+ changed))
                  (setq skipped (1+ skipped)))
                (setq current-right (+ target-left item-width)))))

          (vla-endundomark doc)
          (setq undo-open nil)
          (princ
            (strcat
              "\n[HP] 完成。间距: "
              (rtos step 2 4)
              "，已处理: "
              (itoa changed)
              "，跳过: "
              (itoa skipped)
              ".")))
        (princ "\n[HP] 选择中没有有效的文字范围。")))
    (princ "\n[HP] 未选择文字对象。"))
  (princ)
)

;;; 功能: 将选中文字统一为右中对正，并以最上方文字为基准右对齐。
(defun c:YOU (/ *error* ss doc undo-open ref i ename base-x changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[YOU] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[YOU] 请选择要右对齐的文字...")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (setq ref (aa:find-ref-by-top-bbox doc ss))
      (progn
        (setq base-x (aa:bbox-right-x (cadr ref)))
        (vla-startundomark doc)
        (setq undo-open T
              i         0)
        (repeat (sslength ss)
          (setq ename (ssname ss i))
          (if (aa:normalize-text-horizontal-align doc ename 3)
            (if (or (eq ename (car ref))
                    (aa:align-text-horizontal-by-bbox doc ename base-x 3))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq skipped (1+ skipped)))
          (setq i (1+ i))
        )
        (vla-endundomark doc)
        (setq undo-open nil)
        (princ
          (strcat
            "\n[YOU] 完成。基准 X: "
            (rtos base-x 2 4)
            "，已处理: "
            (itoa changed)
            "，跳过: "
            (itoa skipped)
            "."))
      )
      (princ "\n[YOU] 选择中没有有效的文字范围。")
    )
    (princ "\n[YOU] 未选择文字对象。")
  )
  (princ)
)

;;; 功能: 将选中文字统一为中上对正，并以最上方文字为基准上对齐。
(defun c:SHANG (/ *error* ss doc undo-open ref i ename base-y changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[SHANG] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[SHANG] 请选择要上对齐的文字...")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (setq ref (aa:find-ref-by-top-bbox doc ss))
      (progn
        (setq base-y (aa:bbox-top-y (cadr ref)))
        (vla-startundomark doc)
        (setq undo-open T
              i         0)
        (repeat (sslength ss)
          (setq ename (ssname ss i))
          (if (aa:normalize-text-vertical-align doc ename 1)
            (if (or (eq ename (car ref))
                    (aa:align-text-vertical-by-bbox doc ename base-y 1))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq skipped (1+ skipped)))
          (setq i (1+ i))
        )
        (vla-endundomark doc)
        (setq undo-open nil)
        (princ
          (strcat
            "\n[SHANG] 完成。基准 Y: "
            (rtos base-y 2 4)
            "，已处理: "
            (itoa changed)
            "，跳过: "
            (itoa skipped)
            "."))
      )
      (princ "\n[SHANG] 选择中没有有效的文字范围。")
    )
    (princ "\n[SHANG] 未选择文字对象。")
  )
  (princ)
)

;;; 功能: 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。
(defun c:XIA (/ *error* ss doc undo-open ref i ename base-y changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[XIA] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[XIA] 请选择要下对齐的文字...")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (setq ref (aa:find-ref-by-left-bbox doc ss))
      (progn
        (setq base-y (aa:bbox-bottom-y (cadr ref)))
        (vla-startundomark doc)
        (setq undo-open T
              i         0)
        (repeat (sslength ss)
          (setq ename (ssname ss i))
          (if (aa:normalize-text-vertical-align doc ename 3)
            (if (or (eq ename (car ref))
                    (aa:align-text-vertical-by-bbox doc ename base-y 3))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq skipped (1+ skipped)))
          (setq i (1+ i))
        )
        (vla-endundomark doc)
        (setq undo-open nil)
        (princ
          (strcat
            "\n[XIA] 完成。基准 Y: "
            (rtos base-y 2 4)
            "，已处理: "
            (itoa changed)
            "，跳过: "
            (itoa skipped)
            "."))
      )
      (princ "\n[XIA] 选择中没有有效的文字范围。")
    )
    (princ "\n[XIA] 未选择文字对象。")
  )
  (princ)
)

(defun c:HE (/ ss lst i ent ent-data pt txt ht sorted-lst master-ent master-data new-str
             vobj pt-min-var pt-max-var old-left-x new-left-x delta-x mv-from mv-to)
  (vl-load-com) ;; 加载 VL 扩展函数
  
  (princ "\n请选择需要合并的文字(按照从上到下，从左到右的逻辑合并):")
  
  ;; 1. 选择文字对象 (过滤 Text 和 MText)
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      (setq lst '())
      (setq i 0)
      
      ;; 2. 遍历选择集，提取实体名、坐标、高度和内容
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq ent-data (entget ent))
        (setq pt (cdr (assoc 10 ent-data))) ;; 插入点
        (setq txt (cdr (assoc 1 ent-data))) ;; 文字内容
        (setq ht (cdr (assoc 40 ent-data))) ;; 文字高度 (用于判断容差)
        
        ;; 将数据存入列表: (实体名 插入点 文字内容 文字高度)
        (setq lst (cons (list ent pt txt ht) lst))
        (setq i (1+ i))
      )
      
      ;; 3. 排序算法 (修正版：去除 let，使用标准 AutoLISP)
      (setq sorted-lst 
        (vl-sort lst 
          (function (lambda (e1 e2 / p1 p2 h y1 y2 x1 x2)
            ;; 提取变量
            (setq p1 (cadr e1))
            (setq p2 (cadr e2))
            (setq h (cadddr e1)) ;; 使用第一个对象的文字高度做参考
            (setq y1 (cadr p1))
            (setq y2 (cadr p2))
            (setq x1 (car p1))
            (setq x2 (car p2))
            
            ;; 判断逻辑
            (if (> (abs (- y1 y2)) (* h 0.5))
              (> y1 y2) ;; Y轴差值大：按Y从大到小(上到下)
              (< x1 x2) ;; Y轴差值小(同一行)：按X从小到大(左到右)
            )
          ))
        )
      )
      
      ;; 4. 合并文字
      (setq master-ent (car (car sorted-lst))) ;; 获取排序后的第一个实体作为主实体
      (setq new-str "")
      
      ;; 遍历排序后的列表，拼接字符串
      (foreach item sorted-lst
        (setq new-str (strcat new-str (caddr item)))
      )
      
      ;; 5. 更新主实体并删除其他实体
      ;; 5a. 记录修改前主实体的左边缘 X
      (setq vobj (vlax-ename->vla-object master-ent))
      (vla-getboundingbox vobj 'pt-min-var 'pt-max-var)
      (setq old-left-x (car (vlax-safearray->list pt-min-var)))
      
      ;; 5b. 写入合并后的新天文字串
      (setq master-data (entget master-ent))
      (setq master-data (subst (cons 1 new-str) (assoc 1 master-data) master-data))
      (entmod master-data)
      (entupd master-ent)
      
      ;; 5c. 取目前左边缘 X，按差值平移回原线
      ;;     这样无论主实体是何种对齐方式，最左边沿不移动
      (vla-getboundingbox vobj 'pt-min-var 'pt-max-var)
      (setq new-left-x (car (vlax-safearray->list pt-min-var)))
      (setq delta-x (- old-left-x new-left-x))
      (if (not (equal delta-x 0.0 1e-9))
        (progn
          (setq mv-from (list 0.0 0.0 0.0))
          (setq mv-to   (list delta-x 0.0 0.0))
          (vla-move vobj (vlax-3d-point mv-from) (vlax-3d-point mv-to))
        )
      )
      
      ;; 删除其余实体
      (foreach item (cdr sorted-lst)
        (entdel (car item))
      )
      
      (princ (strcat "\n成功合并 " (itoa (length sorted-lst)) " 个文字对象。结果: " new-str))
    )
    (princ "\n未选中任何文字对象。")
  )
  (princ)
)


;;; =======================================================================================
;;; 命令: QR
;;; 功能: 快速修改选中文字对象的高度。
;;; =======================================================================================
(defun c:QR (/ a ss i ent data)
  ;; 1. 提示用户输入高度值并存储在变量 a 中
  (setq a (getdist "\n请输入新的文字高度: "))

  ;; 2. 检查高度值是否有效
  (if (and a (> a 0))
    (progn
      ;; 3. 提示用户选择对象，并过滤出单行文字(TEXT)和多行文字(MTEXT)
      (princ "\n请选择需要修改高度的文字内容...")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))

      ;; 4. 检查是否选中了内容
      (if ss
        (progn
          (setq i 0)
          ;; 5. 遍历选择集
          (repeat (sslength ss)
            (setq ent (ssname ss i))
            (setq data (entget ent))
            
            ;; 6. 使用 subst 和 entmod 修改 DXF 组码 40 (高度)
            ;; assoc 40 获取当前高度，cons 40 a 构造新的高度项
            (setq data (subst (cons 40 a) (assoc 40 data) data))
            (entmod data)
            
            (setq i (1+ i))
          )
          (princ (strcat "\n操作成功！已将 " (itoa i) " 个文字的高度修改为: " (rtos a)))
        )
        (princ "\n未选中任何文字对象。")
      )
    )
    (princ "\n错误：请输入有效的高度数值。")
  )
  ;; 静默退出
  (princ)
)


;;; =======================================================================================
;;;                          --- WI 命令: 修改文字宽度比例 ---
;;; =======================================================================================
(defun c:wi (/ a ss i ename elist old_width)
  ;; 1. 提示用户输入文字宽度比例
  (setq a (getreal "\n请输入新的文字宽度比例 (例如 0.8 或 1.0): "))

  ;; 2. 检查输入是否有效
  (if (and a (> a 0))
    (progn
      ;; 3. 提示选择对象（过滤只选择 TEXT 和 MTEXT）
      (princ "\n请选择要修改的文字对象: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))

      (if ss
        (progn
          (setq i 0)
          ;; 4. 遍历选择集
          (repeat (sslength ss)
            (setq ename (ssname ss i))
            (setq elist (entget ename))
            
            ;; 对于普通文字 (TEXT)，41号组码是宽度比例
            ;; 对于多行文字 (MTEXT)，41号组码是参照矩形宽度
            ;; 这里统一处理 41 号组码
            (if (assoc 41 elist)
              (setq elist (subst (cons 41 a) (assoc 41 elist) elist))
              (setq elist (append elist (list (cons 41 a))))
            )
            
            ;; 更新实体数据
            (entmod elist)
            (setq i (1+ i))
          )
          (princ (strcat "\n成功修改了 " (itoa (sslength ss)) " 个文字的宽度比例。"))
        )
        (princ "\n未选中任何有效的文字对象。")
      )
    )
    (princ "\n无效的宽度数值，请输入大于0的数字。")
  )
  (princ)
)


;;; =======================================================================================
;;;                      --- XB 命令: 文字/尺寸标注整体缩小 10 倍 ---
;;; =======================================================================================
(defun c:XB (/ ss i ename elist typ old_height new_height obj old_scale result changed skipped)
  ;; 优先使用执行命令前已经预选的文字/尺寸标注；没有预选时再提示选择。
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT,DIMENSION"))))
  (if (null ss)
    (progn
      (princ "\n请选择要缩小的文字或尺寸标注: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT,DIMENSION"))))))

  (if ss
    (progn
      (setq i 0
            changed 0
            skipped 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              elist (entget ename)
              typ (cdr (assoc 0 elist)))
        (cond
          ((member typ '("TEXT" "MTEXT"))
           (setq old_height (cdr (assoc 40 elist)))
           (if (and old_height (> old_height 0.0))
             (progn
               (setq new_height (* old_height 0.1))
               (setq elist (subst (cons 40 new_height) (assoc 40 elist) elist))
               (if (entmod elist)
                 (setq changed (1+ changed))
                 (setq skipped (1+ skipped))))
             (setq skipped (1+ skipped))))
          ((= typ "DIMENSION")
           (setq obj (vlax-ename->vla-object ename)
                 result (vl-catch-all-apply 'vla-get-ScaleFactor (list obj)))
           (if (and (not (vl-catch-all-error-p result))
                    (> result 0.0))
             (progn
               (setq old_scale (* result 0.1))
               (setq result (vl-catch-all-apply 'vla-put-ScaleFactor
                                                (list obj old_scale)))
               (if (vl-catch-all-error-p result)
                 (setq skipped (1+ skipped))
                 (setq changed (1+ changed))))
             (setq skipped (1+ skipped)))))
        (setq i (1+ i)))
      (redraw)
      ;; 完成后清空选择集，不再保持刚修改对象的选中状态。
      (sssetfirst nil nil)
      (princ (strcat "\nXB 完成：已将 " (itoa changed) " 个对象缩小为原来的 1/10。"))
      (if (> skipped 0)
        (princ (strcat "跳过 " (itoa skipped) " 个无法处理的对象。"))))
    (princ "\n未选择任何文字或尺寸标注。"))
  (princ)
)


;;; =======================================================================================
;;;                      --- YAN 命令: 延长竖直直线统一间距 ---
;;; =======================================================================================
(defun c:YAN (/ *error* doc group_num extend_dir ss ent_list sorted_list i ent p10 p11 p10y p11y multiplier delta new_y new_pt obj)
  
  ;; --- 错误处理函数 ---
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\n错误: " msg))
    )
    (if (= (type doc) 'vla-object) (vla-EndUndoMark doc))
    (princ)
  )

  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  
  ;; --- 1. 获取用户输入选项 ---
  
  ;; 初始化选项：分组数量 (2 或 4)
  (initget 1 "2 4")
  (setq group_num (atoi (getkword "\n请输入分组数量 [2/4]: ")))
  
  ;; 初始化选项：延伸方向 (Up 或 Down)
  (initget 1 "Up Down")
  (setq extend_dir (getkword "\n请输入延伸方向 [向上(Up)/向下(Down)]: "))

  ;; --- 2. 选择对象 ---
  (princ "\n请选择竖直直线 (从左到右将自动排序): ")
  (setq ss (ssget '((0 . "LINE"))))
  
  (if ss
    (progn
      (vla-StartUndoMark doc)
      
      ;; --- 3. 将选择集转换为图元列表 ---
      (setq ent_list '())
      (setq i 0)
      (repeat (sslength ss)
        (setq ent_list (cons (ssname ss i) ent_list))
        (setq i (1+ i))
      )
      
      ;; --- 4. 从左到右排序 ---
      ;; 依据组码10 (起点) 的 X 坐标进行排序
      (setq sorted_list 
        (vl-sort ent_list 
          '(lambda (e1 e2)
             (< (car (cdr (assoc 10 (entget e1))))
                (car (cdr (assoc 10 (entget e2)))))
           )
        )
      )

      ;; --- 5. 循环处理每一条线 ---
      (setq i 0) ;; 重置计数器作为列表索引
      (foreach ent sorted_list
        (setq obj (entget ent))
        (setq p10 (cdr (assoc 10 obj))) ;; 起点坐标 (X Y Z)
        (setq p11 (cdr (assoc 11 obj))) ;; 终点坐标 (X Y Z)
        
        ;; 计算当前的倍数
        ;; 逻辑：索引除以组数取整，然后+1
        ;; 例如组数为2：0,1 -> 倍数1; 2,3 -> 倍数2
        (setq multiplier (1+ (fix (/ i group_num))))
        (setq delta (* multiplier 5))
        
        (setq p10y (cadr p10))
        (setq p11y (cadr p11))
        
        ;; 根据方向修改坐标
        (if (eq extend_dir "Down")
          ;; --- 向下延伸 ---
          ;; 逻辑：找到Y值较小的那个点，将其Y值减去delta
          (if (< p10y p11y)
            (progn
              ;; p10 是下端点
              (setq new_y (- p10y delta))
              (setq new_pt (list (car p10) new_y (caddr p10)))
              (setq obj (subst (cons 10 new_pt) (assoc 10 obj) obj))
            )
            (progn
              ;; p11 是下端点
              (setq new_y (- p11y delta))
              (setq new_pt (list (car p11) new_y (caddr p11)))
              (setq obj (subst (cons 11 new_pt) (assoc 11 obj) obj))
            )
          )
          ;; --- 向上延伸 ---
          ;; 逻辑：找到Y值较大的那个点，将其Y值加上delta
          (if (> p10y p11y)
            (progn
              ;; p10 是上端点
              (setq new_y (+ p10y delta))
              (setq new_pt (list (car p10) new_y (caddr p10)))
              (setq obj (subst (cons 10 new_pt) (assoc 10 obj) obj))
            )
            (progn
              ;; p11 是上端点
              (setq new_y (+ p11y delta))
              (setq new_pt (list (car p11) new_y (caddr p11)))
              (setq obj (subst (cons 11 new_pt) (assoc 11 obj) obj))
            )
          )
        )
        
        ;; 更新图元
        (entmod obj)
        
        ;; 增加索引
        (setq i (1+ i))
      )
      
      (vla-EndUndoMark doc)
      (princ (strcat "\n完成! 共处理了 " (itoa (length sorted_list)) " 条直线。"))
    )
    (princ "\n未选择任何对象。")
  )
  (princ)
)


;;; =======================================================================================
;;;                  --- SYAN & XYAN 命令: 直线定向延长工具 ---
;;; =======================================================================================

;;; --- 命令 1: 向上延长 (SYAN) ---
(defun c:SYAN (/ ss i ent p1 p2 high low ang new_high)
  (princ "\n请选择要向上延长的直线...")
  ;; 仅选择直线(LINE)
  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (entget (ssname ss i)))
        (setq p1 (cdr (assoc 10 ent))) ; 起点
        (setq p2 (cdr (assoc 11 ent))) ; 终点
        
        ;; 比较 Y 坐标，确定哪一个点在上方
        (if (> (cadr p1) (cadr p2))
          (setq high p1 low p2)
          (setq high p2 low p1)
        )
        
        ;; 计算从低点到高点的角度
        (setq ang (angle low high))
        ;; 在高点位置沿角度方向延长 5
        (setq new_high (polar high ang 5))
        
        ;; 更新实体数据
        (if (equal high p1)
          (setq ent (subst (cons 10 new_high) (assoc 10 ent) ent))
          (setq ent (subst (cons 11 new_high) (assoc 11 ent) ent))
        )
        
        (entmod ent) ; 修改实体
        (setq i (1+ i))
      )
      (princ (strcat "\n成功向上延长了 " (itoa i) " 条直线。"))
    )
    (princ "\n未选中任何直线。")
  )
  (princ)
)

;;; --- 命令 2: 向下延长 (XYAN) ---
(defun c:XYAN (/ ss i ent p1 p2 high low ang new_low)
  (princ "\n请选择要向下延长的直线...")
  ;; 仅选择直线(LINE)
  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (entget (ssname ss i)))
        (setq p1 (cdr (assoc 10 ent)))
        (setq p2 (cdr (assoc 11 ent)))
        
        ;; 比较 Y 坐标，确定哪一个点在下方
        (if (< (cadr p1) (cadr p2))
          (setq low p1 high p2)
          (setq low p2 high p1)
        )
        
        ;; 计算从高点到低点的角度
        (setq ang (angle high low))
        ;; 在低点位置沿角度方向延长 5
        (setq new_low (polar low ang 5))
        
        ;; 更新实体数据
        (if (equal low p1)
          (setq ent (subst (cons 10 new_low) (assoc 10 ent) ent))
          (setq ent (subst (cons 11 new_low) (assoc 11 ent) ent))
        )
        
        (entmod ent) ; 修改实体
        (setq i (1+ i))
      )
      (princ (strcat "\n成功向下延长了 " (itoa i) " 条直线。"))
    )
    (princ "\n未选中任何直线。")
  )
  (princ)
)


;;; =======================================================================================

;;; =======================================================================================
;;;              --- XSUO & SSUO 命令: 上下缩短直线 5 单位 ---
;;; =======================================================================================


;;; =======================================================================================
;;;                 --- SJ & XJ 命令: 电缆角标上下接短线 ---
;;; =======================================================================================

(defun c:SJ (/ ss i ent ed p1 p2 top sp ep)
  (princ "\n=== SJ 上接模式 ===")

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              p1  (cdr (assoc 10 ed))
              p2  (cdr (assoc 11 ed)))
        (setq top (if (> (cadr p1) (cadr p2)) p1 p2))
        (setq sp (list (+ (car top) 1.0) (cadr top) (caddr top))
              ep (list (car top) (- (cadr top) 1.0) (caddr top)))
        (entmake (list '(0 . "LINE")
                       (cons 62 7)
                       (cons 10 sp)
                       (cons 11 ep)))
        (setq i (1+ i))
      )
      (princ (strcat "\n已成功为 " (itoa (sslength ss)) " 条直线绘制【上接】短线！"))
    )
    (princ "\n未选中直线！请框选直线后再输入 SJ")
  )
  (princ)
)

(defun c:XJ (/ ss i ent ed p1 p2 bot sp ep)
  (princ "\n=== XJ 下接模式 ===")

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              p1  (cdr (assoc 10 ed))
              p2  (cdr (assoc 11 ed)))
        (setq bot (if (< (cadr p1) (cadr p2)) p1 p2))
        (setq sp (list (+ (car bot) 1.0) (cadr bot) (caddr bot))
              ep (list (car bot) (+ (cadr bot) 1.0) (caddr bot)))
        (entmake (list '(0 . "LINE")
                       (cons 62 7)
                       (cons 10 sp)
                       (cons 11 ep)))
        (setq i (1+ i))
      )
      (princ (strcat "\n已成功为 " (itoa (sslength ss)) " 条直线绘制【下接】短线！"))
    )
    (princ "\n未选中直线！请框选直线后再输入 XJ")
  )
  (princ)
)
;;; 函数: NU
;;; 功能: 材料表数字加数字 - 从选中的文字对象中提取数字，执行加法运算
;;; =======================================================================================



;;; =======================================================================================
;;;                             --- 文件加载完成提示 ---
;;; =======================================================================================

;;; =======================================================================================
;;; Added commands: SYI / XYI / ZYI / YYI / BIAN
;;; =======================================================================================

;; Move selected objects up by 5 units.

;; Move selected objects down by 5 units.

;; Move selected objects left by 5 units.

;; Move selected objects right by 5 units.

;; =============================================================================
;; 电缆文字分类与整理
;; GTX: 根据文字前缀分类输出
;; GTY: 汇总并按电缆编号排序整理
;; =============================================================================

(defun aa:gtx-find-last-char (char str / len pos)
  (setq len (strlen str)
        pos nil)
  (while (and (> len 0) (not pos))
    (if (= (substr str len 1) char)
      (setq pos len)
      (setq len (1- len))
    )
  )
  pos
)

(defun aa:gtx-parse-suffix (suffix / i char num-str alpha-str)
  (setq i 1
        num-str ""
        alpha-str "")
  (while (<= i (strlen suffix))
    (setq char (substr suffix i 1))
    (if (wcmatch char "#")
      (setq num-str (strcat num-str char))
      (setq alpha-str (strcat alpha-str char))
    )
    (setq i (1+ i))
  )
  (list (atoi num-str) alpha-str)
)

(defun aa:gtx-create-text-entity (pt content h sty)
  (entmake
    (list
      '(0 . "TEXT")
      (cons 10 pt)
      (cons 40 h)
      (cons 1 content)
      (cons 7 sty)
      '(41 . 0.7)
      '(62 . 7)))
)

(defun aa:gtx-first-text-from-ss (ss / i en)
  (setq i 0
        en nil)
  (while (and ss (< i (sslength ss)) (not en))
    (if (eq "TEXT" (cdr (assoc 0 (entget (ssname ss i)))))
      (setq en (ssname ss i))
    )
    (setq i (1+ i))
  )
  en
)

(defun aa:gtx-select-prefix-text (/ prefix-ss prefix-ent)
  (setq prefix-ent nil)
  (while (not prefix-ent)
    (sssetfirst nil nil)
    (prompt "\n[GTX] 请选择要加在每组前面的文字（支持框选）: ")
    (setq prefix-ss (ssget '((0 . "TEXT"))))
    (setq prefix-ent (aa:gtx-first-text-from-ss prefix-ss))
    (if (not prefix-ent)
      (prompt "\n[GTX] 未选中文字。请点选或框选一个文字，按 Esc 取消。")
    )
  )
  prefix-ent
)

(defun c:GTX (/ *error* ss i ent ent-data text-data text-string insertion-point
               lines current-item current-y found line categorized-groups
               left-text temp-text last-hyphen-pos category group-texts found-category
               pt start-x current-x col-width line-height text-height text-style
               category-group groups-in-category sorted-groups group text-item
               split-groups current-group last-item-x current-item-x
               prefix-text-ent prefix-text-str)

  (vl-load-com)
  (setq text-style (if (tblsearch "STYLE" "HZ")
                     "HZ"
                     (getvar "TEXTSTYLE")))

  (defun *error* (msg)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\n[GTX] 错误: " msg))
    )
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (not ss)
    (progn
      (prompt "\n[GTX] 请选择要分类的文字: ")
      (setq ss (ssget '((0 . "TEXT"))))
    )
  )

  (if ss
    (progn
      (setq prefix-text-ent (aa:gtx-select-prefix-text))
      (setq prefix-text-str (cdr (assoc 1 (entget prefix-text-ent))))

      (if prefix-text-str
        (progn
          (setq text-data '()
                i         0)
          (repeat (sslength ss)
            (setq ent             (ssname ss i)
                  ent-data        (entget ent)
                  text-string     (cdr (assoc 1 ent-data))
                  insertion-point (cdr (assoc 10 ent-data))
                  text-data       (cons (list text-string insertion-point) text-data)
                  i               (1+ i))
          )

          (setq lines '())
          (foreach current-item text-data
            (setq current-y (cadr (cadr current-item))
                  found     nil)
            (setq lines
              (mapcar
                '(lambda (line)
                   (if (and (not found)
                            (< (abs (- current-y (cadr (cadr (car line))))) 1.0))
                     (progn
                       (setq found T)
                       (cons current-item line))
                     line))
                lines))
            (if (not found)
              (setq lines (cons (list current-item) lines)))
          )

          (setq lines
            (mapcar
              '(lambda (line)
                 (vl-sort line '(lambda (a b) (< (car (cadr a)) (car (cadr b))))))
              lines))

          (setq split-groups '())
          (foreach line lines
            (if line
              (progn
                (setq current-group (list (car line))
                      last-item-x   (car (cadr (car line))))
                (foreach item (cdr line)
                  (setq current-item-x (car (cadr item)))
                  (if (> (- current-item-x last-item-x) 200.0)
                    (progn
                      (setq split-groups (cons current-group split-groups))
                      (setq current-group (list item)))
                    (setq current-group (append current-group (list item)))
                  )
                  (setq last-item-x current-item-x)
                )
                (setq split-groups (cons current-group split-groups))
              )
            )
          )
          (setq lines (reverse split-groups))

          (setq categorized-groups '())
          (foreach line lines
            (if (>= (length line) 1)
              (progn
                (setq left-text (caar line)
                      temp-text left-text)
                (if (wcmatch temp-text "并入*")
                  (setq temp-text (vl-string-subst "" "并入" temp-text))
                )
                (setq last-hyphen-pos (aa:gtx-find-last-char "-" temp-text))
                (if last-hyphen-pos
                  (setq category (substr temp-text 1 last-hyphen-pos))
                  (setq category temp-text)
                )
                (setq group-texts    (mapcar 'car line)
                      found-category (assoc category categorized-groups))
                (if found-category
                  (setq categorized-groups
                    (subst
                      (list category (cons group-texts (cadr found-category)))
                      found-category
                      categorized-groups))
                  (setq categorized-groups
                    (cons (list category (list group-texts)) categorized-groups))
                )
              )
            )
          )

          (setq pt (getpoint "\n[GTX] 请指定汇总结果的插入点: "))
          (if pt
            (progn
              (setq text-height 3.0
                    start-x     (car pt)
                    current-y   (cadr pt)
                    col-width   50.0
                    line-height (* 1.4 text-height))

              (setq categorized-groups
                (vl-sort categorized-groups '(lambda (a b) (< (car a) (car b)))))

              (foreach category-group categorized-groups
                (setq groups-in-category (cadr category-group))

                (setq sorted-groups
                  (vl-sort
                    groups-in-category
                    '(lambda (itemA itemB / keyA keyB posA posB suffixA suffixB parsedA parsedB numA alphaA numB alphaB)
                       (setq keyA (car itemA)
                             keyB (car itemB)
                             posA (aa:gtx-find-last-char "-" keyA)
                             posB (aa:gtx-find-last-char "-" keyB))
                       (if (and posA posB)
                         (progn
                           (setq suffixA (substr keyA (1+ posA))
                                 suffixB (substr keyB (1+ posB))
                                 parsedA (aa:gtx-parse-suffix suffixA)
                                 parsedB (aa:gtx-parse-suffix suffixB)
                                 numA    (car parsedA)
                                 alphaA  (cadr parsedA)
                                 numB    (car parsedB)
                                 alphaB  (cadr parsedB))
                           (if (= numA numB)
                             (< alphaA alphaB)
                             (< numA numB)))
                         (< keyA keyB))))
                )

                (foreach group sorted-groups
                  (setq current-x start-x)
                  (aa:gtx-create-text-entity (list current-x current-y 0.0) prefix-text-str text-height text-style)
                  (setq current-x (+ current-x col-width))
                  (foreach text-item group
                    (aa:gtx-create-text-entity (list current-x current-y 0.0) text-item text-height text-style)
                    (setq current-x (+ current-x col-width))
                  )
                  (setq current-y (- current-y line-height))
                )
                (setq current-y (- current-y (* 0.5 line-height)))
              )
              (princ "\n[GTX] 文字分类完成。")
            )
            (princ "\n[GTX] 已取消。")
          )
        )
        (princ "\n[GTX] 未选中有效的前缀文字。")
      )
    )
    (princ "\n[GTX] 未选择文字。")
  )
  (sssetfirst nil nil)
  (princ)
)

(defun aa:gty-pad-left (txt size / result)
  (setq result txt)
  (while (< (strlen result) size)
    (setq result (strcat "0" result))
  )
  result
)

(defun aa:gty-normalize-key (txt / src i char num-buf result)
  (setq src     (strcase (vl-string-trim " " (if txt txt "")))
        i       1
        num-buf ""
        result  "")
  (while (<= i (strlen src))
    (setq char (substr src i 1))
    (if (wcmatch char "#")
      (setq num-buf (strcat num-buf char))
      (progn
        (if (> (strlen num-buf) 0)
          (progn
            (setq result  (strcat result (aa:gty-pad-left num-buf 8))
                  num-buf ""))
        )
        (setq result (strcat result char))
      )
    )
    (setq i (1+ i))
  )
  (if (> (strlen num-buf) 0)
    (setq result (strcat result (aa:gty-pad-left num-buf 8)))
  )
  result
)

(defun aa:gty-get-item-ename (item) (nth 0 item))
(defun aa:gty-get-item-text  (item) (nth 1 item))
(defun aa:gty-get-item-pt    (item) (nth 2 item))
(defun aa:gty-get-item-x     (item) (car (aa:gty-get-item-pt item)))
(defun aa:gty-get-item-y     (item) (cadr (aa:gty-get-item-pt item)))
(defun aa:gty-get-item-z     (item / pt)
  (setq pt (aa:gty-get-item-pt item))
  (if (caddr pt) (caddr pt) 0.0)
)
(defun aa:gty-get-item-width (item) (nth 3 item))
(defun aa:gty-get-item-height (item) (nth 4 item))

(defun aa:gty-build-sort-key (row idx / raw lead rest i key)
  ;; 取每行最左文字内容
  (if (>= (length row) 4)
    (setq raw (aa:gty-get-item-text (nth 1 row)))
    (setq raw "")
  )
  (if (null raw) (setq raw ""))
  ;; 剥离开头连续数字(系统号,如 1/2),作为最低优先级,实现按后段序列交叉排列
  (setq lead "" i 1)
  (while (and (<= i (strlen raw)) (wcmatch (substr raw i 1) "#"))
    (setq lead (strcat lead (substr raw i 1))
          i    (1+ i)))
  (setq rest (substr raw i))
  ;; 主键=去掉开头数字后的部分(内部数字补零做自然排序);次键=开头数字;末键=原序保稳定
  (setq key (aa:gty-normalize-key rest))
  (strcat
    (if (> (strlen key) 0) "0|" "1|")
    key
    "|"
    (aa:gty-pad-left lead 8)
    "|"
    (aa:gty-pad-left (itoa idx) 6))
)

(defun aa:gty-get-text-width (edata / box p1 p2 h txt)
  (setq h   (cond ((cdr (assoc 40 edata))) (3.0))
        txt (cdr (assoc 1 edata))
        box (textbox edata))
  (if (and box (= (length box) 2))
    (progn
      (setq p1 (car box)
            p2 (cadr box))
      (max (- (car p2) (car p1)) h))
    (max (* (strlen txt) h 0.7) h))
)

(defun aa:gty-update-nth (idx val lst / n result)
  (setq n 0
        result '())
  (foreach itm lst
    (setq result (cons (if (= n idx) val itm) result)
          n      (1+ n))
  )
  (reverse result)
)

(defun aa:gty-move-entity (ename from-pt to-pt / obj)
  (setq obj (vlax-ename->vla-object ename))
  (vla-move obj (vlax-3d-point from-pt) (vlax-3d-point to-pt))
)

(defun c:GTY (/ *error* ss i ent ent-data text-string insertion-point text-height text-width
               text-data total-height avg-height row-tol split-gap col-gap line-height
               rows current-item current-y found split-rows current-row last-item-x current-item-x
               anchor-x anchor-y col-widths col-index row row-index sort-keys row-map token sorted-rows
               doc undo-started)

  (vl-load-com)
  (setq doc          (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-started nil)

  (defun *error* (msg)
    (if undo-started
      (vla-EndUndoMark doc)
    )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\n[GTY] 错误: " msg))
    )
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (not ss)
    (progn
      (prompt "\n[GTY] 请选择要整理的电缆文字: ")
      (setq ss (ssget '((0 . "TEXT"))))
    )
  )

  (if ss
    (progn
      (vla-StartUndoMark doc)
      (setq undo-started T
            text-data     '()
            total-height  0.0
            i             0)

      (repeat (sslength ss)
        (setq ent             (ssname ss i)
              ent-data        (entget ent)
              text-string     (cdr (assoc 1 ent-data))
              insertion-point (cdr (assoc 10 ent-data))
              text-height     (cond ((cdr (assoc 40 ent-data))) (3.0))
              text-width      (aa:gty-get-text-width ent-data)
              text-data       (cons (list ent text-string insertion-point text-width text-height) text-data)
              total-height    (+ total-height text-height)
              i               (1+ i))
      )
      (setq text-data (reverse text-data))

      (setq avg-height  (/ total-height (max 1 (length text-data)))
            row-tol     (max 1.0 (* avg-height 0.6))
            split-gap   200.0
            col-gap     (max 10.0 (* avg-height 2.0))
            line-height 5.0)  ;; 行间 Y 坐标差固定为 5

      (setq rows '())
      (foreach current-item text-data
        (setq current-y (aa:gty-get-item-y current-item)
              found     nil)
        (setq rows
          (mapcar
            '(lambda (line)
               (if (and (not found)
                        (<= (abs (- current-y (aa:gty-get-item-y (car line)))) row-tol))
                 (progn
                   (setq found T)
                   (cons current-item line))
                 line))
            rows))
        (if (not found)
          (setq rows (cons (list current-item) rows))
        )
      )

      (setq rows
        (mapcar
          '(lambda (line)
             (vl-sort line '(lambda (a b) (< (aa:gty-get-item-x a) (aa:gty-get-item-x b)))))
          rows))

      (setq split-rows '())
      (foreach row rows
        (if row
          (progn
            (setq current-row (list (car row))
                  last-item-x (aa:gty-get-item-x (car row)))
            (foreach current-item (cdr row)
              (setq current-item-x (aa:gty-get-item-x current-item))
              (if (> (- current-item-x last-item-x) split-gap)
                (progn
                  (setq split-rows (cons current-row split-rows))
                  (setq current-row (list current-item)))
                (setq current-row (append current-row (list current-item)))
              )
              (setq last-item-x current-item-x)
            )
            (setq split-rows (cons current-row split-rows))
          )
        )
      )
      (setq rows (reverse split-rows))

      (setq rows
        (vl-sort
          rows
          '(lambda (a b / ay by ax bx)
             (setq ay (aa:gty-get-item-y (car a))
                   by (aa:gty-get-item-y (car b))
                   ax (aa:gty-get-item-x (car a))
                   bx (aa:gty-get-item-x (car b)))
             (if (> (abs (- ay by)) row-tol)
               (> ay by)
               (< ax bx)))))

      (setq anchor-x (aa:gty-get-item-x (car text-data))
            anchor-y (aa:gty-get-item-y (car text-data)))
      (foreach current-item text-data
        (if (< (aa:gty-get-item-x current-item) anchor-x)
          (setq anchor-x (aa:gty-get-item-x current-item))
        )
        (if (> (aa:gty-get-item-y current-item) anchor-y)
          (setq anchor-y (aa:gty-get-item-y current-item))
        )
      )

      (setq col-widths '())
      (foreach row rows
        (setq col-index 0)
        (foreach current-item row
          (if (>= col-index (length col-widths))
            (setq col-widths
              (append col-widths (list (max (aa:gty-get-item-width current-item) col-gap))))
            (if (> (aa:gty-get-item-width current-item) (nth col-index col-widths))
              (setq col-widths
                (aa:gty-update-nth col-index (aa:gty-get-item-width current-item) col-widths))
            )
          )
          (setq col-index (1+ col-index))
        )
      )

      (setq sort-keys '()
            row-map   '()
            row-index 0)
      (foreach row rows
        (setq token     (aa:gty-build-sort-key row row-index)
              sort-keys (cons token sort-keys)
              row-map   (cons (cons token row) row-map)
              row-index (1+ row-index))
      )
      (setq sorted-rows
        (mapcar
          '(lambda (key) (cdr (assoc key row-map)))
          (acad_strlsort sort-keys)))

      (setq row-index 0)
      (foreach row sorted-rows
        (setq current-item-x anchor-x
              col-index      0)
        (foreach current-item row
          (aa:gty-move-entity
            (aa:gty-get-item-ename current-item)
            (aa:gty-get-item-pt current-item)
            (list current-item-x
                  (- anchor-y (* row-index line-height))
                  (aa:gty-get-item-z current-item)))
          (setq current-item-x (+ current-item-x (nth col-index col-widths) col-gap)
                col-index      (1+ col-index))
        )
        (setq row-index (1+ row-index))
      )

      (vla-EndUndoMark doc)
      (setq undo-started nil)
      (princ "\n[GTY] 电缆文字整理完成。")
    )
    (princ "\n[GTY] 未选择文字。")
  )
  (sssetfirst nil nil)
  (princ)
)

(defun bian-make-text (pt txt sty / data)
  (setq data
    (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      '(100 . "AcDbText")
      (cons 10 pt)
      (cons 40 3.0)
      (cons 1 txt)
      (cons 7 sty)
      '(72 . 0)
      (cons 11 pt)
      '(50 . 0.0)
      '(41 . 0.7)
      '(51 . 0.0)
      '(71 . 0)
      '(73 . 0)
    )
  )
  (entmake data)
)

(defun bian-right-point (p1 p2)
  (if (> (car p1) (car p2)) p1 p2)
)

(defun bian-draw-one (ed sty / p1 p2 rp oz alt half bp1 bp2)
  (setq p1   (cdr (assoc 10 ed))
        p2   (cdr (assoc 11 ed))
        rp   (bian-right-point p1 p2)
        oz   (list (- (car rp) 40.0) (cadr rp) 0.0)
        alt  (* 2.5 (sqrt 3.0))
        half 2.5
        bp1  (list (- (car oz) alt) (+ (cadr oz) half) 0.0)
        bp2  (list (- (car oz) alt) (- (cadr oz) half) 0.0))

  (entmake
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      '(100 . "AcDbPolyline")
      '(90 . 3)
      '(70 . 1)
      (cons 10 (list (car oz)  (cadr oz)))
      (cons 10 (list (car bp1) (cadr bp1)))
      (cons 10 (list (car bp2) (cadr bp2)))
    )
  )

  (bian-make-text (list (+ (car oz) 1.5)   (+ (cadr oz) 0.5) 0.0) "\\U+81F3"  sty)
  (bian-make-text (list (+ (car oz) 27.0)  (+ (cadr oz) 0.5) 0.0) "2\\U+00D74" sty)
  (bian-make-text (list (+ (car oz) -20.0) (+ (cadr oz) 0.5) 0.0) "UPS-12"    sty)
)

(defun c:BIAN (/ ss i ent ed sty cnt)
  (setq sty (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0
            cnt (sslength ss))
      (repeat cnt
        (setq ent (ssname ss i)
              ed  (entget ent))
        (bian-draw-one ed sty)
        (setq i (1+ i))
      )
      (if (tblsearch "STYLE" "HZ")
        (princ (strcat "\nBIAN 已完成，共处理 " (itoa cnt) " 条直线。"))
        (princ
          (strcat
            "\nBIAN 已完成，共处理 "
            (itoa cnt)
            " 条直线；未找到样式 HZ，改用当前样式 "
            sty
            "."
          )
        )
      )
    )
    (princ "\n请先选择直线，再运行 BIAN。")
  )
  (princ)
)
;;; =======================================================================================
;;; 命令: LAN
;;; 功能: 竖直线/斜线/水平线联动复制+移动插件。
;;;       选中 x 条竖直直线时，副本右移 5*x 单位；S = 向上 5，X = 向下 5
;;;       所有对象先原地复制，再对副本执行移动/变形，原始对象不动。
;;;       水平线：副本上/下移 5，左端缩短 5*x（右端不动）
;;; =======================================================================================

(defun lan-get-option (vert_count move_right / kw)
  (initget "Shang Xia")
  (setq kw
    (getkword
      (strcat "\n检测到 " (itoa vert_count)
              " 条竖直线，副本将右移 " (rtos move_right 2 0)
              " 单位。请选择方向 [向上(Shang)/向下(Xia)] <向上>: ")))

  (cond
    ((or (null kw) (equal kw "Shang")) "S")
    ((equal kw "Xia") "X")
  )
)

(defun c:LAN ( / ss total_count
               vert_lines  horiz_lines  diag_lines
               vert_count  horiz_count  diag_count
               opt  move_right  dy
               i  ent  copy_ent  entdata
               pt1 pt2 new_pt1 new_pt2 )

  ;; 1. 取得选择集
  (setq ss (ssget))
  (if (null ss)
    (progn (princ "\n未选中任何对象。") (exit))
  )

  (setq total_count (sslength ss)
        vert_lines  '()
        horiz_lines '()
        diag_lines  '())

  ;; 2. 分类：竖直线 / 水平线 / 斜线
  (setq i 0)
  (while (< i total_count)
    (setq ent     (ssname ss i)
          entdata (entget ent)
          pt1     (cdr (assoc 10 entdata))
          pt2     (cdr (assoc 11 entdata)))

    (if (and pt1 pt2)
      (cond
        ((< (abs (- (car pt1) (car pt2))) 0.001)
         (setq vert_lines (cons ent vert_lines)))
        ((< (abs (- (cadr pt1) (cadr pt2))) 0.001)
         (setq horiz_lines (cons ent horiz_lines)))
        (T
         (setq diag_lines (cons ent diag_lines)))
      )
    )
    (setq i (1+ i))
  )

  (setq vert_count  (length vert_lines)
        horiz_count (length horiz_lines)
        diag_count  (length diag_lines))

  ;; 3. 校验选择集
  (cond
    ((= vert_count 0)
     (princ "\n错误：未检测到竖直直线，请重新选择。")
     (exit))
    ((/= horiz_count 1)
     (princ (strcat "\n错误：需要恰好 1 条水平直线，当前检测到 "
                    (itoa horiz_count) " 条。"))
     (exit))
    ((/= diag_count vert_count)
     (princ (strcat "\n错误：斜线数量（" (itoa diag_count)
                    "）与竖直线数量（" (itoa vert_count)
                    "）不匹配。"))
     (exit))
  )

  ;; 4. 计算移动量
  (setq move_right (* 5 vert_count))

  ;; 5. 获取 S / X 选项
  (setq opt (lan-get-option vert_count move_right))
  (if (null opt)
    (progn (princ "\n已取消。") (exit)))

  (setq dy (if (equal opt "S") 5.0 -5.0))

  ;; 6. 处理竖直直线：复制 → 右移 move_right → 端点延长 5
  (foreach ent vert_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (setq new_pt1 (list (+ (car pt1) move_right) (cadr pt1) (caddr pt1))
          new_pt2 (list (+ (car pt2) move_right) (cadr pt2) (caddr pt2)))

    (if (> (cadr new_pt1) (cadr new_pt2))
      (if (> dy 0)
        (setq new_pt1 (list (car new_pt1) (+ (cadr new_pt1) 5.0) (caddr new_pt1)))
        (setq new_pt2 (list (car new_pt2) (- (cadr new_pt2) 5.0) (caddr new_pt2))))
      (if (> dy 0)
        (setq new_pt2 (list (car new_pt2) (+ (cadr new_pt2) 5.0) (caddr new_pt2)))
        (setq new_pt1 (list (car new_pt1) (- (cadr new_pt1) 5.0) (caddr new_pt1))))
    )

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 7. 处理斜线：复制 → 右移 move_right → 上/下移 5
  (foreach ent diag_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (setq new_pt1 (list (+ (car pt1) move_right) (+ (cadr pt1) dy) (caddr pt1))
          new_pt2 (list (+ (car pt2) move_right) (+ (cadr pt2) dy) (caddr pt2)))

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 8. 处理水平直线：复制 → 上/下移 5 → 左端缩短 move_right（右端不动）
  (foreach ent horiz_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (if (< (car pt1) (car pt2))
      (setq new_pt1 (list (+ (car pt1) move_right) (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (car pt2)                 (+ (cadr pt2) dy) (caddr pt2)))
      (setq new_pt1 (list (car pt1)                 (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (+ (car pt2) move_right)  (+ (cadr pt2) dy) (caddr pt2)))
    )

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 9. 完成提示
  (princ
    (strcat "\n完成！所有对象已原地复制。"
            "\n副本：竖直线 & 斜线右移 " (rtos move_right 2 0)
            " 单位 + " (if (> dy 0) "向上" "向下") " 5 单位；"
            "\n      水平线 " (if (> dy 0) "向上" "向下")
            " 5 单位 + 左端缩短 " (rtos move_right 2 0) " 单位（右端不动）。"))
  (princ)
)


;;; =======================================================================================
;;; 命令: XIN
;;; 功能: 统计每条选中直线矩形范围内的对象数量，并在直线右端标注统计值。
;;; =======================================================================================
(defun c:XIN ( / ss i ent entData pt1 pt2 leftX rightX topY bottomY
                countSS countNum insertPt textStr rightPt)
  (setq ss (ssget '((0 . "LINE"))))
  (if (null ss)
    (progn
      (alert "未选择任何直线！")
      (exit)
    )
  )

  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entData (entget ent))

    (setq pt1 (cdr (assoc 10 entData)))
    (setq pt2 (cdr (assoc 11 entData)))

    (if (< (car pt1) (car pt2))
      (progn
        (setq leftX (car pt1))
        (setq rightX (car pt2))
        (setq rightPt pt2)
      )
      (progn
        (setq leftX (car pt2))
        (setq rightX (car pt1))
        (setq rightPt pt1)
      )
    )

    (setq topY (+ (cadr pt1) 1.6))
    (setq bottomY (- (cadr pt1) 1.6))

    (setq countSS
           (ssget "W"
             (list leftX bottomY 0.0)
             (list rightX topY 0.0)
           )
    )

    (if countSS
      (progn
        (setq countNum (sslength countSS))
        (if (ssmemb ent countSS)
          (progn
            (ssdel ent countSS)
            (setq countNum (1- countNum))
          )
        )
      )
      (setq countNum 0)
    )

    (setq insertPt (list (+ (car rightPt) 2) (+ (cadr rightPt) 0.5) 0.0))
    (setq textStr (itoa countNum))

    (entmake
      (list
        (cons 0 "TEXT")
        (cons 10 insertPt)
        (cons 40 3.0)
        (cons 1 textStr)
        (cons 7 "Standard")
        (cons 50 0.0)
      )
    )

    (setq i (1+ i))
  )

  (princ (strcat "\n处理完成，共处理 " (itoa (sslength ss)) " 条直线。"))
  (princ)
)


;;; =======================================================================================
;;; 命令: XY
;;; 来源: 小命令\芯原XY.lsp
;;; 功能: 先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。
;;; =======================================================================================
(vl-load-com)

;; =========================
;; XY 参数区
;; =========================
(setq *xy-geom-tol*      1e-4)             ; 几何容差
(setq *xy-ang-tol*       (/ pi 180.0))     ; 角度容差：±1°
(setq *xy-ray-len*       20.0)             ; 竖直搜索区高度
(setq *xy-hit-half-width* 1.0)             ; 搜索矩形半宽
(setq *xy-out-offx*      10.0)             ; 输出起点相对水平线右端点偏移 X
(setq *xy-out-offy*      0.5)              ; 输出起点相对水平线右端点偏移 Y
(setq *xy-step-x*        30.0)             ; 新文字插入点固定间距
(setq *xy-warn-extend-len* 200.0)          ; 异常水平线右端点延长距离
(setq *xy-last-xin-counts* nil)            ; 最近一次XIN输出数字表
(setq *xy-last-vrec-map*   nil)            ; 最近一次每条水平线匹配到的竖线表
(setq *xy-last-vline-data* nil)            ; 最近一次 pre-fetched 竖直线数据 (en x y1 y2)
(setq *xy-vline-buckets* nil)              ; 竖线按 X 分桶索引 (bucket-id . vdata-list)
(setq *xy-vline-bucket-size* 100.0)        ; 竖线分桶宽度（图纸单位）

;; =========================
;; 通用函数
;; =========================
(defun xy:abs (x)
  (if (< x 0.0) (- x) x)
)

(defun xy:near (a b tol)
  (<= (xy:abs (- a b)) tol)
)

(defun xy:between (v a b tol)
  (and (>= v (- (min a b) tol))
       (<= v (+ (max a b) tol)))
)

(defun xy:ss->list (ss / i lst)
  (setq lst '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq lst (cons (ssname ss i) lst))
        (setq i (1+ i))
      )
    )
  )
  (reverse lst)
)

(defun xy:get-line-pts (en / ed p1 p2)
  (setq ed (entget en))
  (setq p1 (cdr (assoc 10 ed)))
  (setq p2 (cdr (assoc 11 ed)))
  (list p1 p2)
)

(defun xy:is-line-p (en)
  (= (cdr (assoc 0 (entget en))) "LINE")
)

(defun xy:is-horizontal-line-p (en tol / pts p1 p2)
  (if (not (xy:is-line-p en))
    nil
    (progn
      (setq pts (xy:get-line-pts en))
      (setq p1 (car pts))
      (setq p2 (cadr pts))
      (xy:near (cadr p1) (cadr p2) tol)
    )
  )
)

(defun xy:is-vertical-line-p (en tol / pts p1 p2)
  (if (not (xy:is-line-p en))
    nil
    (progn
      (setq pts (xy:get-line-pts en))
      (setq p1 (car pts))
      (setq p2 (cadr pts))
      (xy:near (car p1) (car p2) tol)
    )
  )
)

(defun xy:is-vertical-line-ed-p (ed tol / p1 p2)
  (and (= (cdr (assoc 0 ed)) "LINE")
       (setq p1 (cdr (assoc 10 ed)))
       (setq p2 (cdr (assoc 11 ed)))
       (xy:near (car p1) (car p2) tol))
)

(defun xy:right-endpoint (en / pts p1 p2)
  (setq pts (xy:get-line-pts en))
  (setq p1 (car pts))
  (setq p2 (cadr pts))
  (if (>= (car p1) (car p2)) p1 p2)
)

(defun xy:pt-offset-x (pt dx)
  (cons (+ (car pt) dx) (cdr pt))
)

(defun xy:remove-dxf-codes (ed codes)
  (vl-remove-if
    '(lambda (pair) (member (car pair) codes))
    ed)
)

(defun xy:mark-abnormal-hline (en / ed p1 p2 newPt)
  (setq ed (entget en))
  (setq p1 (cdr (assoc 10 ed)))
  (setq p2 (cdr (assoc 11 ed)))
  (if (and p1 p2)
    (progn
      (if (>= (car p1) (car p2))
        (progn
          (setq newPt (xy:pt-offset-x p1 *xy-warn-extend-len*))
          (setq ed (subst (cons 10 newPt) (assoc 10 ed) ed))
        )
        (progn
          (setq newPt (xy:pt-offset-x p2 *xy-warn-extend-len*))
          (setq ed (subst (cons 11 newPt) (assoc 11 ed) ed))
        )
      )
      (setq ed (xy:remove-dxf-codes ed '(62 420 430 440)))
      (entmod (append ed (list (cons 62 1))))
      (entupd en)
    )
  )
)

;; 从已取得的 entget 数据直接计算水平线信息，避免重复 entget
(defun xy:hline-info-ed (ed / p1 p2 x1 x2 y rightpt)
  (setq p1 (cdr (assoc 10 ed)))
  (setq p2 (cdr (assoc 11 ed)))
  (setq x1 (car p1))
  (setq x2 (car p2))
  (setq y  (cadr p1))
  (setq rightpt (if (>= x1 x2) p1 p2))
  (list (min x1 x2) (max x1 x2) y rightpt)
)

(defun xy:hline-info (en)
  (xy:hline-info-ed (entget en))
)

(defun xy:norm-angle (a)
  (while (< a 0.0)
    (setq a (+ a (* 2.0 pi)))
  )
  (while (>= a (* 2.0 pi))
    (setq a (- a (* 2.0 pi)))
  )
  a
)

(defun xy:is-vertical-text-90-p (ang tol / a)
  (setq a (xy:norm-angle ang))
  (<= (xy:abs (- a (/ pi 2.0))) tol)
)

(defun xy:dxf (code ed default / pair)
  (setq pair (assoc code ed))
  (if pair (cdr pair) default)
)

(defun xy:is-text-entity-p (en / typ)
  (setq typ (cdr (assoc 0 (entget en))))
  (or (= typ "TEXT") (= typ "MTEXT"))
)

(defun xy:get-text-rotation (ed)
  (xy:dxf 50 ed 0.0)
)

(defun xy:get-text-height (ed)
  (xy:dxf 40 ed 3.0)
)

(defun xy:get-text-style (ed)
  (xy:dxf 7 ed "Standard")
)

(defun xy:get-text-value (ed)
  (xy:dxf 1 ed "")
)

;; =========================
;; XIN 功能
;; =========================
(defun xy:filter-vertical-lines (lineList / out en ed p1 p2)
  (setq out '())
  (foreach en lineList
    (setq ed (entget en))
    (if (xy:is-vertical-line-ed-p ed *xy-geom-tol*)
      (progn
        (setq p1 (cdr (assoc 10 ed)))
        (setq p2 (cdr (assoc 11 ed)))
        (setq out (cons (list en (car p1) (cadr p1) (cadr p2)) out))
      )
    )
  )
  (reverse out)
)

;; 竖线数据按 X 坐标分桶：查询时只检查水平线 x 区间内的桶，避免全表扫描
(defun xy:build-vline-buckets (vlineDataList / out b vd)
  (setq out '())
  (foreach vd vlineDataList
    (setq b (fix (/ (cadr vd) *xy-vline-bucket-size*)))
    (setq out (cons (cons b (cons vd (cdr (assoc b out)))) out)))
  (setq *xy-vline-buckets* out)
  out
)

;; 用已取得的 entget 数据计算匹配竖线（避免重复 entget）；竖线按 X 分桶后只查区间内桶
(defun xy:get-vrecs-for-hline-ed (ed vlineDataList / handle pair hinfo xmin xmax vrecs b1 b2 bi vd vrec)
  (setq handle (cdr (assoc 5 ed)))
  (setq pair (assoc handle *xy-last-vrec-map*))
  (if pair
    (cdr pair)
    (progn
      (setq hinfo (xy:hline-info-ed ed))
      (setq xmin (car hinfo))
      (setq xmax (cadr hinfo))
      (setq vrecs '())
      (if *xy-vline-buckets*
        (progn
          (setq b1 (fix (/ (- xmin *xy-geom-tol*) *xy-vline-bucket-size*)))
          (setq b2 (fix (/ (+ xmax *xy-geom-tol*) *xy-vline-bucket-size*)))
          (setq bi b1)
          (while (<= bi b2)
            (setq pair (assoc bi *xy-vline-buckets*))
            (if pair
              (foreach vd (cdr pair)
                (setq vrec (xy:make-vrec-if-valid-fast vd hinfo *xy-geom-tol*))
                (if vrec
                  (setq vrecs (cons vrec vrecs))
                )
              )
            )
            (setq bi (1+ bi))
          )
        )
        (foreach vd vlineDataList
          (setq vrec (xy:make-vrec-if-valid-fast vd hinfo *xy-geom-tol*))
          (if vrec
            (setq vrecs (cons vrec vrecs))
          )
        )
      )
      (xy:dedup-vrecs vrecs *xy-geom-tol*)
    )
  )
)

(defun xy:get-vrecs-for-hline (hen vlineDataList)
  (xy:get-vrecs-for-hline-ed (entget hen) vlineDataList)
)

(defun xy:count-vlines-for-hline (hen lineList)
  (length (xy:get-vrecs-for-hline hen lineList))
)

(defun xy:run-xin (sel / selList lineSS vlineDataList ss i ent entData p1 p2 rightPt handle countMap vrecMap vrecs countNum insertPt textStr)
  (setq *xy-last-xin-counts* nil)
  (setq *xy-last-vrec-map* nil)
  (setq *xy-last-vline-data* nil)
  (setq selList  (xy:ss->list sel))
  (setq lineSS   (ssget "_X" '((0 . "LINE"))))
  (setq vlineDataList (xy:filter-vertical-lines (xy:ss->list lineSS)))
  (xy:build-vline-buckets vlineDataList)
  (setq *xy-last-vline-data* vlineDataList)
  (setq ss (ssadd))
  (foreach ent selList
    (setq entData (entget ent))
    (if (and (= (cdr (assoc 0 entData)) "LINE")
             (setq p1 (cdr (assoc 10 entData)))
             (setq p2 (cdr (assoc 11 entData)))
             (xy:near (cadr p1) (cadr p2) *xy-geom-tol*))
      (ssadd ent ss)
    )
  )
  (if (= (sslength ss) 0)
    (progn
      (princ "\n选集中没有可供XIN处理的水平直线。")
      nil
    )
    (progn
      (setq i 0)
      (setq countMap '())
      (setq vrecMap '())
      (while (< i (sslength ss))
        (setq ent     (ssname ss i))
        (setq entData (entget ent))
        (setq p1      (cdr (assoc 10 entData)))
        (setq p2      (cdr (assoc 11 entData)))
        (setq rightPt (if (>= (car p1) (car p2)) p1 p2))
        (setq vrecs (xy:get-vrecs-for-hline-ed entData vlineDataList))
        (setq countNum (length vrecs))

        (setq handle   (cdr (assoc 5 entData)))
        (setq countMap (cons (cons handle countNum) countMap))
        (setq vrecMap  (cons (cons handle vrecs) vrecMap))
        (setq insertPt (list (+ (car rightPt) 2) (+ (cadr rightPt) 0.5) 0.0))
        (setq textStr (itoa countNum))

        (entmake
          (list
            (cons 0 "TEXT")
            (cons 10 insertPt)
            (cons 40 3.0)
            (cons 1 textStr)
            (cons 7 "Standard")
            (cons 50 0.0)
          )
        )

        (setq i (1+ i))
      )

      (setq *xy-last-xin-counts* (reverse countMap))
      (setq *xy-last-vrec-map*   (reverse vrecMap))
      (princ (strcat "\nXIN处理完成，共处理 " (itoa (sslength ss)) " 条水平直线。"))
      T
    )
  )
);; =========================
;; YUAN 功能
;; =========================
(defun xy:make-vrec-if-valid (ven hinfo tol / pts p1 p2 x y1 y2 hy xmin xmax lo hi)
  (if (not (xy:is-vertical-line-p ven tol))
    nil
    (progn
      (setq pts  (xy:get-line-pts ven))
      (setq p1   (car pts))
      (setq p2   (cadr pts))
      (setq x    (car p1))
      (setq y1   (cadr p1))
      (setq y2   (cadr p2))
      (setq xmin (car hinfo))
      (setq xmax (cadr hinfo))
      (setq hy   (caddr hinfo))
      (setq lo   (if (< y1 y2) p1 p2))
      (setq hi   (if (> y1 y2) p1 p2))

      (if (not (xy:between x xmin xmax tol))
        nil
        (cond
          ((and (xy:near (cadr hi) hy tol)
                (< (cadr lo) (- hy tol)))
           (list x 'DOWN lo ven)
          )
          ((and (xy:near (cadr lo) hy tol)
                (> (cadr hi) (+ hy tol)))
           (list x 'UP hi ven)
          )
          (t nil)
        )
      )
    )
  )
)

;; Optimized: builds vrec from pre-fetched (en x y1 y2) vertical line data; zero entget calls
(defun xy:make-vrec-if-valid-fast (vdata hinfo tol / en x y1 y2 xmin xmax hy loY hiY)
  (setq en   (car vdata))
  (setq x    (cadr vdata))
  (setq y1   (caddr vdata))
  (setq y2   (cadddr vdata))
  (setq xmin (car hinfo))
  (setq xmax (cadr hinfo))
  (setq hy   (caddr hinfo))

  (if (not (xy:between x xmin xmax tol))
    nil
    (progn
      (setq loY (min y1 y2))
      (setq hiY (max y1 y2))
      (cond
        ((and (xy:near hiY hy tol)
              (< loY (- hy tol)))
         (list x 'DOWN (list x loY 0.0) en))
        ((and (xy:near loY hy tol)
              (> hiY (+ hy tol)))
         (list x 'UP   (list x hiY 0.0) en))
        (t nil)
      )
    )
  )
)

(defun xy:merge-vrec (a b / side pa pb)
  (setq side (cadr a))
  (setq pa   (caddr a))
  (setq pb   (caddr b))
  (cond
    ((eq side 'DOWN)
     (if (< (cadr pa) (cadr pb)) a b)
    )
    ((eq side 'UP)
     (if (> (cadr pa) (cadr pb)) a b)
    )
    (t a)
  )
)

(defun xy:dedup-vrecs (lst tol / sorted out rec top)
  (setq sorted
        (vl-sort lst
          '(lambda (a b) (< (car a) (car b)))
        )
  )
  (setq out '())
  (foreach rec sorted
    (if (null out)
      (setq out (list rec))
      (progn
        (setq top (car out))
        (if (and (xy:near (car rec) (car top) tol)
                 (eq (cadr rec) (cadr top)))
          (setq out (cons (xy:merge-vrec rec top) (cdr out)))
          (setq out (cons rec out))
        )
      )
    )
  )
  (reverse out)
)

(defun xy:sa->list (val)
  (vlax-safearray->list
    (if (= (type val) 'VARIANT)
      (vlax-variant-value val)
      val))
)

(defun xy:fallback-text-bbox (ed / ip h txt w)
  (setq ip  (xy:dxf 10 ed '(0.0 0.0 0.0)))
  (setq h   (xy:get-text-height ed))
  (setq txt (xy:get-text-value ed))
  (setq w   (max h (* (strlen txt) h 0.7)))
  (list (- (car ip) (/ h 2.0))
        (+ (car ip) (/ h 2.0))
        (- (cadr ip) (/ w 2.0))
        (+ (cadr ip) (/ w 2.0)))
)

(defun xy:get-text-bbox (en / ed obj minPt maxPt ret minLst maxLst)
  (setq ed (entget en))
  (if (xy:is-text-entity-p en)
    (progn
      (setq obj (vlax-ename->vla-object en))
      (setq ret (vl-catch-all-apply 'vla-getBoundingBox (list obj 'minPt 'maxPt)))
      (if (vl-catch-all-error-p ret)
        (xy:fallback-text-bbox ed)
        (progn
          (setq minLst (xy:sa->list minPt))
          (setq maxLst (xy:sa->list maxPt))
          (list (car minLst) (car maxLst) (cadr minLst) (cadr maxLst))
        )
      )
    )
    nil
  )
)

(defun xy:build-text-meta-list (textList / out en ed rot bbox)
  (setq out '())
  (foreach en textList
    (setq ed (entget en))
    (if (xy:is-text-entity-p en)
      (progn
        (setq rot (xy:get-text-rotation ed))
        (if (xy:is-vertical-text-90-p rot *xy-ang-tol*)
          (progn
            (setq bbox (xy:get-text-bbox en))
            (if bbox
              (setq out
                    (cons
                      (list en
                            (car bbox)
                            (cadr bbox)
                            (caddr bbox)
                            (cadddr bbox)
                            rot)
                      out))
            )
          )
        )
      )
    )
  )
  (vl-sort out '(lambda (a b) (< (cadr a) (cadr b))))
)

(defun xy:find-text-for-vrec (textMetaList vrec / side anchor ax ay rectXmin rectXmax rectYmin rectYmax best bestHit bestXDist item en xmin xmax ymin ymax hitY xCenter xDist)
  (setq side   (cadr vrec))
  (setq anchor (caddr vrec))
  (setq ax     (car anchor))
  (setq ay     (cadr anchor))

  (cond
    ((eq side 'DOWN)
     (setq rectXmin (- ax *xy-hit-half-width*))
     (setq rectXmax (+ ax *xy-hit-half-width*))
     (setq rectYmin (- ay *xy-ray-len*))
     (setq rectYmax ay)
     (setq best nil)
     (setq bestHit nil)
     (setq bestXDist nil)

     (foreach item textMetaList
       (setq en   (car item))
       (setq xmin (cadr item))
       (setq xmax (caddr item))
       (setq ymin (cadddr item))
       (setq ymax (nth 4 item))
       (if (and (<= xmin (+ rectXmax *xy-geom-tol*))
                (>= xmax (- rectXmin *xy-geom-tol*))
                (<= ymin (+ rectYmax *xy-geom-tol*))
                (>= ymax (- rectYmin *xy-geom-tol*)))
         (progn
           (setq hitY (min rectYmax ymax))
           (setq xCenter (/ (+ xmin xmax) 2.0))
           (setq xDist (xy:abs (- xCenter ax)))
           (if (or (null best)
                   (> hitY (+ bestHit *xy-geom-tol*))
                   (and (xy:near hitY bestHit *xy-geom-tol*)
                        (< xDist bestXDist)))
             (progn
               (setq best      en)
               (setq bestHit   hitY)
               (setq bestXDist xDist)
             )
           )
         )
       )
     )
     best
    )
    ((eq side 'UP)
     (setq rectXmin (- ax *xy-hit-half-width*))
     (setq rectXmax (+ ax *xy-hit-half-width*))
     (setq rectYmin ay)
     (setq rectYmax (+ ay *xy-ray-len*))
     (setq best nil)
     (setq bestHit nil)
     (setq bestXDist nil)

     (foreach item textMetaList
       (setq en   (car item))
       (setq xmin (cadr item))
       (setq xmax (caddr item))
       (setq ymin (cadddr item))
       (setq ymax (nth 4 item))
       (if (and (<= xmin (+ rectXmax *xy-geom-tol*))
                (>= xmax (- rectXmin *xy-geom-tol*))
                (<= ymin (+ rectYmax *xy-geom-tol*))
                (>= ymax (- rectYmin *xy-geom-tol*)))
         (progn
           (setq hitY (max rectYmin ymin))
           (setq xCenter (/ (+ xmin xmax) 2.0))
           (setq xDist (xy:abs (- xCenter ax)))
           (if (or (null best)
                   (< hitY (- bestHit *xy-geom-tol*))
                   (and (xy:near hitY bestHit *xy-geom-tol*)
                        (< xDist bestXDist)))
             (progn
               (setq best      en)
               (setq bestHit   hitY)
               (setq bestXDist xDist)
             )
           )
         )
       )
     )
     best
    )
    (t nil)
  )
)
(defun xy:copy-text-horizontal (srcEn insPt / ed data)
  (setq ed (entget srcEn))
  (setq data
    (list
      '(0 . "TEXT")
      (cons 8  (xy:dxf 8 ed "0"))
      (cons 10 insPt)
      (cons 40 (xy:get-text-height ed))
      (cons 1  (xy:get-text-value ed))
      (cons 7  (xy:get-text-style ed))
      (cons 50 0.0)
      (cons 72 0)
      (cons 73 0)
      (cons 210 (xy:dxf 210 ed '(0.0 0.0 1.0)))
    )
  )

  (if (assoc 41 ed)
    (setq data (append data (list (assoc 41 ed))))
  )
  (if (assoc 51 ed)
    (setq data (append data (list (assoc 51 ed))))
  )
  (if (assoc 39 ed)
    (setq data (append data (list (assoc 39 ed))))
  )
  (if (assoc 62 ed)
    (setq data (append data (list (assoc 62 ed))))
  )
  (if (assoc 420 ed)
    (setq data (append data (list (assoc 420 ed))))
  )

  (entmakex data)
)
(defun xy:process-one-hline (ed vlineDataList textMetaList / hinfo vrecs found txt rightPt startPt idx newCnt missCnt allVCnt tail cand scan rectXmin rectXmax)
  (setq hinfo (xy:hline-info-ed ed))
  (setq vrecs (xy:get-vrecs-for-hline-ed ed vlineDataList))
  (setq allVCnt (length vrecs))
  (setq found   '())
  (setq missCnt 0)

  ;; 滑动窗口：textMetaList 按 xmin 升序、vrecs 按 x 升序，双指针只检查窗口附近文字
  (setq tail textMetaList)
  (foreach vrec vrecs
    (setq rectXmin (- (car vrec) *xy-hit-half-width*))
    (setq rectXmax (+ (car vrec) *xy-hit-half-width*))
    (while (and tail (< (caddr (car tail)) (- rectXmin *xy-geom-tol*)))
      (setq tail (cdr tail)))
    (setq cand '())
    (setq scan tail)
    (while (and scan (<= (cadr (car scan)) (+ rectXmax *xy-geom-tol*)))
      (setq cand (cons (car scan) cand))
      (setq scan (cdr scan)))
    (setq txt (xy:find-text-for-vrec (reverse cand) vrec))
    (if txt
      (setq found (cons (list (car vrec) txt) found))
      (setq missCnt (1+ missCnt))
    )
  )

  (setq found
        (vl-sort found
          '(lambda (a b) (< (car a) (car b)))
        )
  )

  (setq rightPt (cadddr hinfo))
  (setq startPt
        (list (+ (car rightPt) *xy-out-offx*)
              (+ (cadr rightPt) *xy-out-offy*)
              (if (caddr rightPt) (caddr rightPt) 0.0))
  )

  (setq idx 0)
  (setq newCnt 0)

  (foreach item found
    (xy:copy-text-horizontal
      (cadr item)
      (list (+ (car startPt) (* idx *xy-step-x*))
            (cadr startPt)
            (caddr startPt))
    )
    (setq idx    (1+ idx))
    (setq newCnt (1+ newCnt))
  )

  (list newCnt missCnt allVCnt)
)

(defun xy:run-yuan (sel / selList lineSS textSS vlineDataList textList textMetaList hLines hitem en ed p1 p2 res totalH totalNew totalMiss totalV handle warnCnt hY warnYText)
  (if (null sel)
    (progn
      (princ "\n未选择对象，YUAN部分结束。")
      nil
    )
    (progn
      (if *xy-last-vline-data*
        (setq vlineDataList *xy-last-vline-data*)
        (progn
          (setq lineSS (ssget "_X" '((0 . "LINE"))))
          (setq vlineDataList (xy:filter-vertical-lines (xy:ss->list lineSS)))
          (xy:build-vline-buckets vlineDataList)
        )
      )
      (setq textSS   (ssget "_X" '((0 . "TEXT,MTEXT"))))
      (setq textList (xy:ss->list textSS))
      (setq textMetaList (xy:build-text-meta-list textList))
      (setq selList  (xy:ss->list sel))

      (setq hLines '())
      (foreach en selList
        (setq ed (entget en))
        (if (and (= (cdr (assoc 0 ed)) "LINE")
                 (setq p1 (cdr (assoc 10 ed)))
                 (setq p2 (cdr (assoc 11 ed)))
                 (xy:near (cadr p1) (cadr p2) *xy-geom-tol*))
          (setq hLines (cons (list en ed) hLines))
        )
      )
      (setq hLines (reverse hLines))

      (if (null hLines)
        (progn
          (princ "\n选集中没有可处理的水平 LINE，YUAN部分结束。")
          nil
        )
        (progn
          (setq totalH    0)
          (setq totalNew  0)
          (setq totalMiss 0)
          (setq totalV    0)
          (setq warnCnt   0)
          (setq warnYText "")

          (foreach hitem hLines
            (setq en (car hitem))
            (setq ed (cadr hitem))
            (setq res (xy:process-one-hline ed vlineDataList textMetaList))
            (setq totalH    (1+ totalH))
            (setq totalNew  (+ totalNew  (car res)))
            (setq totalMiss (+ totalMiss (cadr res)))
            (setq totalV    (+ totalV    (caddr res)))

            (setq handle  (cdr (assoc 5 ed)))
            (setq hY      (cadr (assoc 10 ed)))

            (princ
              (strcat
                "\n水平线 Handle="
                handle
                " | 竖线数="
                (itoa (caddr res))
                " | 成功="
                (itoa (car res))
                " | 未找到文字="
                (itoa (cadr res))
              )
            )

            (if (/= (car res) (caddr res))
              (progn
                (xy:mark-abnormal-hline en)
                (setq warnCnt (1+ warnCnt))
                (setq warnYText
                      (if (= warnYText "")
                        (rtos hY 2 4)
                        (strcat warnYText ", " (rtos hY 2 4))))
                (princ
                  (strcat
                    "\n警告: 水平线 Handle="
                    handle
                    "，Y="
                    (rtos hY 2 4)
                    " 找到文字="
                    (itoa (car res))
                    "，竖线数="
                    (itoa (caddr res))
                    "。异常请检查。"
                  )
                )
              )
            )
          )

          (princ
            (strcat
              "\n--- YUAN 执行完成 ---"
              "\n处理水平线数量: " (itoa totalH)
              "\n识别竖线总数: "   (itoa totalV)
              "\n新建文字总数: "   (itoa totalNew)
              "\n未找到文字总数: " (itoa totalMiss)
            )
          )
          (if (> warnCnt 0)
            (princ
              (strcat
                "\n注意: 发现 "
                (itoa warnCnt)
                " 条水平线的找到文字数与竖线数不一致，请检查对应水平线。"
                "\n异常水平线Y坐标汇总: "
                warnYText
              )
            )
          )
          T
        )
      )
    )
  )
)

;; =========================
;; 主命令：XY
;; =========================
(defun c:XY (/ sel)
  (princ "\n选择对象，XY会共用这一批对象执行XIN和YUAN: ")
  (setq sel (ssget))
  (if (null sel)
    (princ "\n未选择对象，XY命令结束。")
    (progn
      (princ "\n开始执行 XY：先运行 XIN，再运行 YUAN。")
      (xy:run-xin sel)
      (xy:run-yuan sel)
      (princ "\nXY 执行结束。")
    )
  )
  (princ)
)

(princ)
(princ) ; 干净地退出加载过程

(defun aa:digit-char-p (ch / code)
  (and ch
       (= (type ch) 'STR)
       (= (strlen ch) 1)
       (setq code (ascii ch))
       (<= 48 code 57))
)

(defun aa:nu-number-token-at (str start / len idx digit-found end)
  (setq len (strlen str)
        idx start
        digit-found nil
        end nil)
  (if (<= start len)
    (progn
      (if (member (substr str idx 1) '("+" "-"))
        (setq idx (1+ idx)))
      (while (and (<= idx len)
                  (aa:digit-char-p (substr str idx 1)))
        (setq digit-found T
              end idx
              idx (1+ idx)))
      (if (and (<= idx len)
               (= (substr str idx 1) ".")
               (< idx len)
               (aa:digit-char-p (substr str (1+ idx) 1)))
        (progn
          (setq idx (1+ idx))
          (while (and (<= idx len)
                      (aa:digit-char-p (substr str idx 1)))
            (setq digit-found T
                  end idx
                  idx (1+ idx)))))
      (if digit-found
        (list start
              end
              (substr str start (1+ (- end start)))))
    )
  )
)

(defun aa:nu-find-first-number (str / len idx token ch)
  (setq len (strlen str)
        idx 1
        token nil)
  (while (and (<= idx len) (null token))
    (setq ch (substr str idx 1))
    (if (or (aa:digit-char-p ch)
            (and (= ch ".")
                 (< idx len)
                 (aa:digit-char-p (substr str (1+ idx) 1)))
            (and (member ch '("+" "-"))
                 (< idx len)
                 (or (aa:digit-char-p (substr str (1+ idx) 1))
                     (and (< (1+ idx) len)
                          (= (substr str (1+ idx) 1) ".")
                          (aa:digit-char-p (substr str (+ idx 2) 1))))))
      (setq token (aa:nu-number-token-at str idx))
    )
    (if (null token)
      (setq idx (1+ idx))))
  token
)

(defun aa:nu-trim-number-string (str)
  (if (vl-string-search "." str)
    (progn
      (while (and (> (strlen str) 0)
                  (= (substr str (strlen str) 1) "0"))
        (setq str (substr str 1 (1- (strlen str)))))
      (if (and (> (strlen str) 0)
               (= (substr str (strlen str) 1) "."))
        (setq str (substr str 1 (1- (strlen str))))))
  )
  (if (or (= str "") (= str "-0") (= str "+0"))
    "0"
    str)
)

(defun aa:nu-string-all-digits-p (str / idx ok)
  (setq idx 1
        ok (> (strlen str) 0))
  (while (and ok (<= idx (strlen str)))
    (if (not (aa:digit-char-p (substr str idx 1)))
      (setq ok nil))
    (setq idx (1+ idx)))
  ok
)

(defun aa:nu-format-number (value old-token / raw body keep-plus pad-width abs-str)
  (setq raw (aa:nu-trim-number-string (rtos value 2 8))
        body old-token
        keep-plus nil
        pad-width 0)
  (if (> (strlen body) 0)
    (cond
      ((= (substr body 1 1) "+")
       (setq keep-plus T
             body (substr body 2)))
      ((= (substr body 1 1) "-")
       (setq body (substr body 2)))
    )
  )
  (if (and (= value (fix value))
           (> (strlen body) 1)
           (= (substr body 1 1) "0")
           (aa:nu-string-all-digits-p body))
    (progn
      (setq pad-width (strlen body)
            abs-str (itoa (abs (fix value))))
      (while (< (strlen abs-str) pad-width)
        (setq abs-str (strcat "0" abs-str)))
      (setq raw
             (strcat
               (cond
                 ((< value 0) "-")
                 ((and keep-plus (>= value 0)) "+")
                 (T ""))
               abs-str)))
    (if (and keep-plus
             (>= value 0)
             (/= raw ""))
      (setq raw (strcat "+" raw))))
  raw
)

(defun aa:nu-rewrite-text (str delta / token start end old-val new-str)
  (if (setq token (aa:nu-find-first-number str))
    (progn
      (setq start   (car token)
            end     (cadr token)
            old-val (distof (caddr token)))
      (if (numberp old-val)
        (progn
          (setq new-str (aa:nu-format-number (+ old-val delta) (caddr token)))
          (strcat
            (if (> start 1)
              (substr str 1 (1- start))
              "")
            new-str
            (if (< end (strlen str))
              (substr str (1+ end))
              "")))
      )
    )
  )
)

(defun c:NU (/ *error* doc undo-open ss a i en ed str new-str changed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[NU] 错误: " msg)))
    (princ)
  )

  (if (null (setq a (getreal "\n[NU] 请输入要相加的数值: ")))
    (princ "\n[NU] 未输入数值。")
    (progn
      (princ "\n[NU] 请选择 TEXT/MTEXT 文字: ")
      (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
        (progn
          (setq i 0
                changed 0)
          (vla-StartUndoMark doc)
          (setq undo-open T)
          (repeat (sslength ss)
            (setq en (ssname ss i)
                  ed (entget en)
                  str (cdr (assoc 1 ed))
                  new-str (if str (aa:nu-rewrite-text str a)))
            (if (and new-str (/= new-str str))
              (progn
                (setq ed (subst (cons 1 new-str) (assoc 1 ed) ed))
                (if (entmod ed)
                  (setq changed (1+ changed)))))
            (setq i (1+ i)))
          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (princ (strcat "\n[NU] 已更新 " (itoa changed) " 个文字对象。"))
        )
        (princ "\n[NU] 未选择文字对象。")
      )
    )
  )
  (princ)
)

;;; =======================================================================================
;;; 命令: KAI
;;; 功能: 将 TEXT/MTEXT 中由一个或多个空格分隔的内容劈开为多个独立文字；MTEXT 会先炸开为 TEXT 后处理。
;;; =======================================================================================
(defun aa:kai-remove-dxf (codes data / out item)
  (foreach item data
    (if (not (member (car item) codes))
      (setq out (cons item out))))
  (reverse out)
)

(defun aa:kai-space-p (ch)
  (= ch " ")
)

(defun aa:kai-split-spaces (str / len i ch in-word start parts)
  (setq len (strlen str)
        i 1
        in-word nil
        parts '())
  (while (<= i len)
    (setq ch (substr str i 1))
    (if (aa:kai-space-p ch)
      (if in-word
        (progn
          (setq parts (cons (list start (substr str start (- i start))) parts))
          (setq in-word nil)))
      (if (not in-word)
        (progn
          (setq start i)
          (setq in-word T))))
    (setq i (1+ i)))
  (if in-word
    (setq parts (cons (list start (substr str start (- i start))) parts)))
  (reverse parts)
)

(defun aa:kai-text-box (edata value / box)
  (textbox (subst (cons 1 value) (assoc 1 edata) edata))
)

(defun aa:kai-text-width (edata value / box p1 p2)
  (setq box (aa:kai-text-box edata value))
  (if box
    (progn
      (setq p1 (car box)
            p2 (cadr box))
      (- (car p2) (car p1)))
    0.0)
)

(defun aa:kai-prefix-width (edata prefix / marker with-marker marker-width total-width)
  (if (= prefix "")
    0.0
    (progn
      (setq marker "X"
            with-marker (strcat prefix marker)
            marker-width (aa:kai-text-width edata marker)
            total-width (aa:kai-text-width edata with-marker))
      (max 0.0 (- total-width marker-width))))
)

(defun aa:kai-real-text-width (doc edata value / newdata en bbox width)
  (if (= value "")
    0.0
    (progn
      (setq newdata (aa:kai-remove-dxf '(-1 5 102 330 360) edata))
      (setq newdata (aa:kai-replace-pair 1 value newdata))
      (setq en (entmakex newdata))
      (if en
        (progn
          (setq bbox (aa:safe-get-bbox doc en))
          (setq width (if bbox (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox)) nil))
          (entdel en)
          (if width width 0.0))
        0.0))
  )
)

(defun aa:kai-prefix-width-real (doc edata prefix / marker marker-width total-width)
  (if (= prefix "")
    0.0
    (progn
      (setq marker "X"
            marker-width (aa:kai-real-text-width doc edata marker)
            total-width (aa:kai-real-text-width doc edata (strcat prefix marker)))
      (max 0.0 (- total-width marker-width))))
)

(defun aa:kai-text-left (edata value / box)
  (setq box (aa:kai-text-box edata value))
  (if box
    (car (car box))
    0.0)
)

(defun aa:kai-dxf-int (code data default / pair)
  (if (setq pair (assoc code data))
    (cdr pair)
    default)
)

(defun aa:kai-aligned-text-p (edata)
  (or (/= (aa:kai-dxf-int 72 edata 0) 0)
      (/= (aa:kai-dxf-int 73 edata 0) 0))
)

(defun aa:kai-base-point (edata / p)
  (if (and (aa:kai-aligned-text-p edata)
           (setq p (cdr (assoc 11 edata))))
    p
    (cdr (assoc 10 edata)))
)

(defun aa:kai-set-position (edata pt)
  (if (aa:kai-aligned-text-p edata)
    (aa:kai-replace-pair 11 pt edata)
    (aa:kai-replace-pair 10 pt edata))
)

(defun aa:kai-offset-point (pt dist ang)
  (list (+ (car pt) (* dist (cos ang)))
        (+ (cadr pt) (* dist (sin ang)))
        (if (caddr pt) (caddr pt) 0.0))
)

(defun aa:kai-adjust-left-by-bbox (doc en target-left / bbox dx)
  (if (and doc en target-left (setq bbox (aa:safe-get-bbox doc en)))
    (progn
      (setq dx (- target-left (aa:bbox-left-x bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0)))))
    nil)
)

(defun aa:kai-replace-pair (code value data)
  (if (assoc code data)
    (subst (cons code value) (assoc code data) data)
    (append data (list (cons code value))))
)

(defun aa:kai-make-text (edata value pt / newdata)
  (setq newdata (aa:kai-remove-dxf '(-1 5 102 330 360) edata))
  (setq newdata (aa:kai-replace-pair 1 value newdata))
  (setq newdata (aa:kai-set-position newdata pt))
  (entmakex newdata)
)

(defun aa:kai-add-texts-after-explode (before after outss / cur ed typ added)
  (setq added 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (entnext before))
      (while cur
        (setq ed  (entget cur)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (if (= typ "TEXT")
          (progn
            (ssadd cur outss)
            (setq added (1+ added))))
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))))))
  added
)

(defun aa:kai-process-text (doc en / ed orig-ed str parts base ang first part prefix prefix-width offset pt made left0 orig-bbox orig-left target-left new-en)
  (setq ed (entget en)
        orig-ed ed
        str (cdr (assoc 1 ed))
        orig-bbox (aa:safe-get-bbox doc en)
        orig-left (if orig-bbox (aa:bbox-left-x orig-bbox) nil))
  (if (and str (wcmatch str "* *"))
    (progn
      (setq parts (aa:kai-split-spaces str))
      (if (> (length parts) 1)
        (progn
          (setq base (aa:kai-base-point ed)
                ang (cond ((cdr (assoc 50 ed))) (0.0))
                left0 (aa:kai-text-left ed str)
                first T
                made 0)
          (foreach part parts
            (setq prefix (if (> (car part) 1) (substr str 1 (1- (car part))) "")
                  prefix-width (aa:kai-prefix-width-real doc orig-ed prefix)
                  offset (- (+ left0 prefix-width)
                            (aa:kai-text-left orig-ed (cadr part)))
                  pt (aa:kai-offset-point base offset ang)
                  target-left (if orig-left (+ orig-left prefix-width) nil))
            (if first
              (progn
                (setq ed (subst (cons 1 (cadr part)) (assoc 1 ed) ed))
                (setq ed (aa:kai-set-position ed pt))
                (entmod ed)
                (entupd en)
                (aa:kai-adjust-left-by-bbox doc en target-left)
                (setq first nil
                      made (1+ made)))
              (progn
                (setq new-en (aa:kai-make-text orig-ed (cadr part) pt))
                (if new-en
                  (progn
                    (aa:kai-adjust-left-by-bbox doc new-en target-left)
                    (setq made (1+ made)))))))
          made)
        0))
    0)
)

(defun c:KAI (/ *error* doc undo-open oldcmdecho ss text-ss mtexts i en ed typ
                changed skipped made before after exploded)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        text-ss (ssadd)
        mtexts '())

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[KAI] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[KAI] 请选择要按空格拆分的 TEXT/MTEXT 文字: ")
      (setq ss (ssget "_:L" '((0 . "TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0
            changed 0
            skipped 0
            exploded 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              ed  (entget en)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (cond
          ((= typ "TEXT")
           (ssadd en text-ss))
          ((= typ "MTEXT")
           (setq mtexts (cons en mtexts))))
        (setq i (1+ i)))

      (if (and (= (sslength text-ss) 0) (null mtexts))
        (princ "\n[KAI] 未选择 TEXT/MTEXT 文字。")
        (progn
          (setq oldcmdecho (getvar "CMDECHO"))
          (setvar "CMDECHO" 0)
          (vla-StartUndoMark doc)
          (setq undo-open T)

          (foreach en (reverse mtexts)
            (setq before (entlast))
            (command "_.EXPLODE" en)
            (setq after (entlast)
                  made (aa:kai-add-texts-after-explode before after text-ss))
            (if (> made 0)
              (setq exploded (+ exploded made))
              (setq skipped (1+ skipped))))

          (setq i 0)
          (repeat (sslength text-ss)
            (setq made (aa:kai-process-text doc (ssname text-ss i)))
            (if (> made 0)
              (setq changed (+ changed made))
              (setq skipped (1+ skipped)))
            (setq i (1+ i)))

          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (setvar "CMDECHO" oldcmdecho)
          (setq oldcmdecho nil)
          (princ
            (strcat
              "\n[KAI] 已拆分文字: "
              (itoa changed)
              "，分解出的多行文字: "
              (itoa exploded)
              "，跳过对象: "
              (itoa skipped)
              ".")))))
    (princ "\n[KAI] 未选择 TEXT/MTEXT 文字。"))
  (princ)
)

;;; =======================================================================================
;;; Command: ZHENG
;;; Purpose: Center selected TEXT/MTEXT on the midpoint X of one horizontal LINE.
;;;          With one rectangle and one text, set middle-center justification first,
;;;          then align the text horizontally to the rectangle center, preserving Y.
;;; =======================================================================================
(defun aa:zheng-horizontal-line-p (en tol / ed p1 p2)
  (setq ed (entget en))
  (and (= (cdr (assoc 0 ed)) "LINE")
       (setq p1 (cdr (assoc 10 ed)))
       (setq p2 (cdr (assoc 11 ed)))
       (equal (cadr p1) (cadr p2) tol))
)

(defun aa:zheng-line-mid-x (en / ed p1 p2)
  (setq ed (entget en)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (/ (+ (car p1) (car p2)) 2.0)
)

(defun aa:zheng-add-texts-after-explode (before after outss / cur ed typ added)
  (setq added 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (entnext before))
      (while cur
        (setq ed  (entget cur)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (if (= typ "TEXT")
          (progn
            (ssadd cur outss)
            (setq added (1+ added))))
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))))))
  added
)

(defun aa:zheng-align-text-center-x (doc en base-x / bbox dx)
  (if (setq bbox (aa:safe-get-bbox doc en))
    (progn
      (setq dx (- base-x (aa:bbox-center-x bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0))))))
)

(defun aa:zheng-align-text-to-rect-center (doc en rect-bbox / text-bbox dx)
  (if (and rect-bbox
           (aa:normalize-text-horizontal-align doc en 2)
           (setq text-bbox (aa:safe-get-bbox doc en)))
    (progn
      (setq dx (- (aa:bbox-center-x rect-bbox)
                  (aa:bbox-center-x text-bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0)))))
    nil)
)

(defun c:ZHENG (/ *error* doc undo-open oldcmdecho ss i en ed typ line-ent rect-ent rect-count
                  rect-bbox text-ss mtexts text-count text-ent base-x before after made changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        line-ent nil
        rect-ent nil
        rect-count 0
        text-ss (ssadd)
        mtexts '()
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[ZHENG] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[ZHENG] 请选择水平直线和文字，或一个矩形和一个文字: ")
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              ed  (entget en)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (cond
          ((and (= typ "LINE")
                (null line-ent)
                (aa:zheng-horizontal-line-p en 1e-8))
           (setq line-ent en))
          ((member typ '("LWPOLYLINE" "POLYLINE"))
           (setq rect-count (1+ rect-count))
           (if (null rect-ent)
             (setq rect-ent en)))
          ((= typ "TEXT")
           (ssadd en text-ss))
          ((= typ "MTEXT")
           (setq mtexts (cons en mtexts))))
        (setq i (1+ i)))

      (setq text-count (+ (sslength text-ss) (length mtexts)))
      (cond
        ((> rect-count 1)
         (princ "\n[ZHENG] 矩形居中模式请只选择一个矩形。"))
        ((= rect-count 1)
         (cond
           ((/= text-count 1)
            (princ "\n[ZHENG] 矩形居中模式请只选择一个 TEXT/MTEXT 文字。"))
           ((null (setq rect-bbox (aa:safe-get-bbox doc rect-ent)))
            (princ "\n[ZHENG] 无法读取矩形范围。"))
           (T
            (setq text-ent (if (> (sslength text-ss) 0)
                             (ssname text-ss 0)
                             (car mtexts)))
            (vla-StartUndoMark doc)
            (setq undo-open T)
            (if (aa:zheng-align-text-to-rect-center doc text-ent rect-bbox)
              (setq changed 1)
              (setq skipped 1))
            (vla-EndUndoMark doc)
            (setq undo-open nil)
            (princ
              (strcat
                "\n[ZHENG] 完成。文字已改为正中对正并水平对齐到矩形中心，竖直位置保持不变，已处理: "
                (itoa changed)
                "，跳过: "
                (itoa skipped)
                ".")))))
        ((null line-ent)
         (princ "\n[ZHENG] 选择中没有水平直线。"))
        ((= text-count 0)
         (princ "\n[ZHENG] 选择中没有 TEXT/MTEXT 文字。"))
        (T
         (setq base-x (aa:zheng-line-mid-x line-ent)
               oldcmdecho (getvar "CMDECHO"))
         (setvar "CMDECHO" 0)
         (vla-StartUndoMark doc)
         (setq undo-open T)

         (foreach en (reverse mtexts)
           (setq before (entlast))
           (command "_.EXPLODE" en)
           (setq after (entlast)
                 made (aa:zheng-add-texts-after-explode before after text-ss))
           (if (= made 0)
             (setq skipped (1+ skipped))))

         (setq i 0)
         (repeat (sslength text-ss)
           (if (aa:zheng-align-text-center-x doc (ssname text-ss i) base-x)
             (setq changed (1+ changed))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))

         (vla-EndUndoMark doc)
         (setq undo-open nil)
         (setvar "CMDECHO" oldcmdecho)
         (setq oldcmdecho nil)
         (princ
           (strcat
             "\n[ZHENG] 完成。基准 X: "
             (rtos base-x 2 4)
             "，已对齐文字: "
             (itoa changed)
             "，跳过: "
             (itoa skipped)
             ".")))))
    (princ "\n[ZHENG] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

(princ)

;;; =======================================================================================
;;; BEGIN IMPORT: 自动页码HAO.lsp
;;; Source: 小命令\自动页码HAO.lsp
;;; Imported on: 2026-05-13 17:04:20
;;; =======================================================================================

;;; ============================================================
;;; 自动页码 HAO
;;; 功能：批量填写图框属性 —— 页码（自动排序）+ 项目编号
;;; 排序方式：按Y轴从上到下，Y相同时按X从左到右
;;; 使用方法：加载后执行命令 HAO
;;; ============================================================

(vl-load-com)

;; ── 工具函数 ──────────────────────────────────────────────────

;; 判断实体是否为带属性的块参照
(defun is-attblock (ent / ed)
  (setq ed (entget ent))
  (and (= (cdr (assoc 0 ed)) "INSERT")
       (= (cdr (assoc 66 ed)) 1))   ; 66=1 表示有属性
)

;; 获取块参照的所有属性对象列表 (VLA object)
(defun get-att-objects (blk-obj / atts att-list)
  (setq atts (vlax-invoke blk-obj 'GetAttributes))
  atts
)

;; 读取属性对象的标记名（大写）
(defun att-tag (att-obj)
  (strcase (vlax-get-property att-obj 'TagString))
)

;; 读取属性对象的当前值
(defun att-value (att-obj)
  (vlax-get-property att-obj 'TextString)
)

;; 写入属性值
(defun set-att-value (att-obj val)
  (vlax-put-property att-obj 'TextString val)
)

;; 获取块参照的插入点，返回普通 list (x y z)
;; InsertionPoint 返回的是 variant/safearray，必须用 vlax-safearray->list 转换
(defun blk-insertpt (blk-obj / raw)
  (setq raw (vlax-get-property blk-obj 'InsertionPoint))
  (vlax-safearray->list (vlax-variant-value raw))
)

;; ── 识别图框块 ────────────────────────────────────────────────

;; 判断一个块是否为图框：
;; 策略：检查属性标记中是否含有常见图框关键词
(defun is-frame-block (blk-obj / atts tags found)
  (setq atts (get-att-objects blk-obj)
        found nil)
  (foreach att atts
    (setq tag (att-tag att))
    (if (or (wcmatch tag "*页*")
            (wcmatch tag "*PAGE*")
            (wcmatch tag "*图号*")
            (wcmatch tag "*编号*")
            (wcmatch tag "*项目*")
            (wcmatch tag "*单位*")
            (wcmatch tag "*日期*")
            (wcmatch tag "*比例*")
            (wcmatch tag "*设计*")
            (wcmatch tag "*审核*"))
      (setq found T)
    )
  )
  found
)

;; 收集当前图纸中所有图框块
(defun collect-frame-blocks (/ ss i ent blk result)
  (setq result '())
  (setq ss (ssget "X" '((0 . "INSERT") (66 . 1))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              blk (vlax-ename->vla-object ent))
        (if (is-frame-block blk)
          (setq result (cons blk result))
        )
        (setq i (1+ i))
      )
    )
  )
  result
)

;; ── 排序 ──────────────────────────────────────────────────────

;; 按Y从大到小（上到下），Y相同时按X从小到大（左到右）
;; 容差：Y差值小于 tolerance 视为同行
(defun sort-frames-by-position (frame-list / tolerance)
  (setq tolerance 100.0)  ; 单位与图纸一致，可根据需要调整
  (vl-sort frame-list
    (function
      (lambda (a b / pa pb ya yb xa xb)
        (setq pa (blk-insertpt a)
              pb (blk-insertpt b)
              ya (cadr pa)
              yb (cadr pb)
              xa (car pa)
              xb (car pb))
        (if (< (abs (- ya yb)) tolerance)
          (< xa xb)          ; 同行：X小的在前
          (> ya yb)          ; 不同行：Y大的（靠上）在前
        )
      )
    )
  )
)

;; ── 属性标记匹配 ──────────────────────────────────────────────

;; 在属性列表中查找匹配关键词的属性对象
;; keywords: 标记关键词列表（大写），返回第一个匹配的 att-obj 或 nil
(defun find-att-by-keywords (atts keywords / result)
  (setq result nil)
  (foreach att atts
    (if (null result)
      (progn
        (setq tag (att-tag att))
        (foreach kw keywords
          (if (and (null result) (wcmatch tag kw))
            (setq result att)
          )
        )
      )
    )
  )
  result
)

;; ── 填写逻辑 ──────────────────────────────────────────────────

;; 页码属性的候选标记关键词（可扩展）
(defun page-keywords ()
  '("*页码*" "*页次*" "页" "*PAGE*")
)

;; 总页数属性的候选标记关键词
(defun total-page-keywords ()
  '("*总页*" "*共*页*" "*TOTAL*")
)

;; 档案号属性的候选标记关键词
(defun proj-num-keywords ()
  '("*档案号*" "*档案*" "*图号*")
)

;; 比例属性的候选标记关键词
(defun scale-keywords ()
  '("*比例*" "*图纸比例*")
)

;; 填写单个图框
(defun fill-one-frame (blk-obj page-num total-pages archive-num scale-value / atts pg-att tp-att ar-att sc-att)
  (setq atts (get-att-objects blk-obj))

  ;; 查找并填写页码
  (setq pg-att (find-att-by-keywords atts (page-keywords)))
  (if pg-att
    (set-att-value pg-att (itoa page-num))
    (princ (strcat "\n  [警告] 未找到页码属性，块名: "
                   (vlax-get-property blk-obj 'Name)))
  )

  ;; 查找并填写总页数
  (setq tp-att (find-att-by-keywords atts (total-page-keywords)))
  (if tp-att
    (set-att-value tp-att (itoa total-pages))
  )

  ;; 查找并填写档案号（前缀 + 两位页码，如 SHY2025504-901-EE-01）
  (if (and archive-num (> (strlen archive-num) 0))
    (progn
      (setq ar-att (find-att-by-keywords atts (proj-num-keywords)))
      (if ar-att
        (set-att-value ar-att
          (strcat archive-num
                  (if (< page-num 10) "0" "")  ; 不足两位补前导零
                  (itoa page-num)))
        (princ (strcat "\n  [警告] 未找到档案号属性，块名: "
                       (vlax-get-property blk-obj 'Name)))
      )
    )
  )

  ;; 查找并填写比例
  (if (and scale-value (> (strlen scale-value) 0))
    (progn
      (setq sc-att (find-att-by-keywords atts (scale-keywords)))
      (if sc-att
        (set-att-value sc-att scale-value)
        (princ (strcat "\n  [警告] 未找到比例属性，块名: "
                       (vlax-get-property blk-obj 'Name)))
      )
    )
  )

  ;; 刷新块显示
  (vlax-invoke blk-obj 'Update)
)

;; ── 诊断功能 ──────────────────────────────────────────────────

;; 打印某个块的所有属性标记，用于调试
(defun diagnose-frame (blk-obj / atts)
  (setq atts (get-att-objects blk-obj))
  (princ (strcat "\n块名: " (vlax-get-property blk-obj 'Name)))
  (foreach att atts
    (princ (strcat "\n  标记: [" (att-tag att) "]  当前值: [" (att-value att) "]"))
  )
)

;; ── 主命令：HAO ───────────────────────────────────────────────

;; 从选集中提取图框块 VLA 对象列表
(defun collect-frames-from-ss (ss / i ent blk result)
  (setq result '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              blk (vlax-ename->vla-object ent))
        (if (and (is-attblock ent) (is-frame-block blk))
          (setq result (cons blk result))
        )
        (setq i (1+ i))
      )
    )
  )
  result
)

(defun fillframes-run (/ ss frames sorted archive-num scale-value start-page total-pages i pg)

  (princ "\n=== HAO：批量填写图框属性 ===")

  ;; 1. 让用户框选要处理的图框
  (princ "\n请选择要填写的图框块（框选或点选，回车确认）：")
  (setq ss (ssget '((0 . "INSERT") (66 . 1))))

  (if (null ss)
    (progn
      (princ "\n[取消] 未选择任何对象。\n")
      (exit)
    )
  )

  ;; 2. 从选集中筛选出图框块
  (setq frames (collect-frames-from-ss ss))

  (if (null frames)
    (progn
      (princ "\n[错误] 选中的对象中未识别到图框块。")
      (princ "\n提示：请确认图框属性标记是否包含页码等关键词。\n")
      (exit)
    )
  )

  (princ (strcat "\n识别到 " (itoa (length frames)) " 个图框块"))

  ;; 3. 排序
  (setq sorted (sort-frames-by-position frames))
  (princ "，已按位置排序（从上到下，从左到右）。")

  ;; 4. 输入档案号
  (setq archive-num
    (getstring T "\n请输入档案号（直接回车跳过不填写）: "))

  ;; 5. 输入比例
  (setq scale-value
    (getstring T "\n请输入比例（直接回车跳过不填写）: "))

  ;; 6. 输入起始页码
  (setq start-page
    (getint "\n请输入起始页码（默认为1，直接回车使用默认值）: "))
  (if (null start-page) (setq start-page 1))

  ;; 7. 批量填写
  (setq i 0)
  (setq total-pages (length sorted))

  (princ "\n开始填写属性...")
  (foreach blk sorted
    (setq pg (+ start-page i))
    (princ (strcat "\n  第 " (itoa pg) " 页 → 块名: "
                   (vlax-get-property blk 'Name)
                   "  位置: ("
                   (rtos (car (blk-insertpt blk)) 2 0)
                   ", "
                   (rtos (cadr (blk-insertpt blk)) 2 0)
                   ")"))
    (fill-one-frame blk pg total-pages archive-num scale-value)
    (setq i (1+ i))
  )

  ;; 8. 刷新视图
  (command "_.REGEN")

  (princ (strcat "\n=== 完成！共填写 " (itoa total-pages) " 个图框 ===\n"))
)

(defun c:HAO ()
  (fillframes-run)
)




;;; =======================================================================================
;;;              --- FIVE 命令: 将测得高度按比例缩放为 5 ---
;;; =======================================================================================

(defun c:FIVE (/ *error* oldcmdecho p1 p2 a b ss base)
  (defun *error* (msg)
    (if oldcmdecho (setvar "CMDECHO" oldcmdecho))
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*")))
      (princ (strcat "\nFIVE 错误: " msg))
    )
    (princ)
  )

  (setq oldcmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (setq p1 (getpoint "\nFIVE - 请点取当前格子高度的第一个点: "))
  (if p1
    (progn
      (setq p2 (getpoint p1 "\n请点取当前格子高度的第二个点: "))
      (if p2
        (progn
          (setq a (distance p1 p2))
          (if (> a 1e-8)
            (progn
              (setq b (/ 5.0 a))
              (princ (strcat "\n当前高度 A = " (rtos a 2 4) "，缩放比例 B = " (rtos b 2 6)))
              (princ "\n请选择要缩放的对象，完成后按回车或空格确认: ")
              (setq ss (ssget))
              (if ss
                (progn
                  (setq base (getpoint "\n请点取缩放基点: "))
                  (if base
                    (progn
                      (command "_.SCALE" ss "" base b)
                      (princ "\nFIVE 完成：已按比例缩放，测得高度将变为 5。")
                    )
                    (princ "\n未点取基点，FIVE 已取消。")
                  )
                )
                (princ "\n未选择对象，FIVE 已取消。")
              )
            )
            (princ "\n两点距离过小，FIVE 已取消。")
          )
        )
        (princ "\n未点取第二个点，FIVE 已取消。")
      )
    )
    (princ "\n未点取第一个点，FIVE 已取消。")
  )

  (setvar "CMDECHO" oldcmdecho)
  (princ)
)

;;; END IMPORT: 自动页码HAO.lsp

;;; =======================================================================================
;;;              --- JZ 命令: 矩形水平中线对齐到两条直线中心线 ---
;;; =======================================================================================

(defun aa:jz-line-center-y (ename / ed p1 p2)
  (if (and ename
           (setq ed (entget ename))
           (= (cdr (assoc 0 ed)) "LINE"))
    (progn
      (setq p1 (cdr (assoc 10 ed))
            p2 (cdr (assoc 11 ed)))
      (/ (+ (cadr p1) (cadr p2)) 2.0)
    )
  )
)

(defun c:JZ (/ *error* doc undo-open obj-ss rect-ss text-ss i en typ rect-count text-count
             rect-en rect-bbox line-ss line-count line1 line2 y1 y2 target-y target-x
             moved failed bbox center-y delta-y center-x delta-x)
  (vl-load-com)
  (setq doc (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[JZ] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[JZ] 请选择一个矩形对象，可同时选择需要放到矩形正中间的文字，完成后按空格或回车确认: ")
  (setq obj-ss (ssget '((0 . "LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (cond
    ((null obj-ss)
     (princ "\n[JZ] 未选择矩形或文字，命令取消。"))
    (T
     (setq rect-ss (ssadd)
           text-ss (ssadd)
           i       0)
     (repeat (sslength obj-ss)
       (setq en  (ssname obj-ss i)
             typ (cdr (assoc 0 (entget en))))
       (cond
         ((or (= typ "LWPOLYLINE") (= typ "POLYLINE"))
          (ssadd en rect-ss))
         ((or (= typ "TEXT") (= typ "MTEXT"))
          (ssadd en text-ss))
       )
       (setq i (1+ i))
     )
     (setq rect-count (sslength rect-ss)
           text-count (sslength text-ss))
     (cond
       ((> rect-count 1)
        (princ "\n[JZ] 请只选择一个矩形对象。"))
       ((and (= rect-count 0) (= text-count 0))
        (princ "\n[JZ] 未选择可处理的矩形或文字，命令取消。"))
       (T
        (if (= rect-count 1)
          (setq rect-en   (ssname rect-ss 0)
                rect-bbox (aa:safe-get-bbox doc rect-en))
        )
        (if (and (= rect-count 1) (null rect-bbox))
          (princ "\n[JZ] 无法读取矩形范围，命令取消。")
          (progn
            (princ "\n[JZ] 请选择两条直线，完成后按空格或回车确认: ")
            (setq line-ss (ssget '((0 . "LINE"))))
            (cond
              ((null line-ss)
               (princ "\n[JZ] 未选择直线，命令取消。"))
              (T
               (setq line-count (sslength line-ss))
               (cond
                 ((= line-count 1)
                  (setq line1 (ssname line-ss 0)
                        y1 (aa:jz-line-center-y line1)
                        y2 y1))
                 ((>= line-count 2)
                  (setq line1 (ssname line-ss 0)
                        line2 (ssname line-ss 1)
                        y1 (aa:jz-line-center-y line1)
                        y2 (aa:jz-line-center-y line2)))
                 (T
                  (setq y1 nil
                        y2 nil))
               )
               (if (and y1 y2)
                 (progn
                   (setq target-y (/ (+ y1 y2) 2.0)
                         target-x (if rect-bbox (aa:bbox-center-x rect-bbox))
                         moved    0
                         failed   0)
                   (vla-startundomark doc)
                   (setq undo-open T)
                   (if (= rect-count 1)
                     (progn
                       (setq center-y (/ (+ (aa:bbox-top-y rect-bbox)
                                            (aa:bbox-bottom-y rect-bbox))
                                         2.0)
                             delta-y  (- target-y center-y))
                       (if (or (equal delta-y 0.0 1e-8)
                               (aa:safe-move-entity rect-en (vlax-3d-point (list 0.0 delta-y 0.0))))
                         (setq moved (1+ moved))
                         (setq failed (1+ failed))
                       )
                     )
                   )
                   (setq i 0)
                   (repeat text-count
                     (setq en   (ssname text-ss i)
                           bbox (aa:safe-get-bbox doc en))
                     (if bbox
                       (progn
                         (setq center-y (/ (+ (aa:bbox-top-y bbox)
                                              (aa:bbox-bottom-y bbox))
                                           2.0)
                               center-x (aa:bbox-center-x bbox)
                               delta-y  (- target-y center-y)
                               delta-x  (if target-x (- target-x center-x) 0.0))
                         (if (or (and (equal delta-x 0.0 1e-8)
                                      (equal delta-y 0.0 1e-8))
                                 (aa:safe-move-entity en (vlax-3d-point (list delta-x delta-y 0.0))))
                           (setq moved (1+ moved))
                           (setq failed (1+ failed))
                         )
                       )
                       (setq failed (1+ failed))
                     )
                     (setq i (1+ i))
                   )
                   (vla-endundomark doc)
                   (setq undo-open nil)
                   (princ
                     (strcat
                       "\n[JZ] 完成：已居中 "
                       (itoa moved)
                       " 个对象"
                       (if (> failed 0)
                         (strcat "，失败 " (itoa failed) " 个。")
                         "。")
                     )
                   )
                 )
                 (princ "\n[JZ] 无法读取直线中心位置，命令取消。")
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


;;; =======================================================================================
;;; DX 命令: 批量整理方格内的端子号、原理号和终点柜文字
;;; =======================================================================================

(defun dx:true-color-rgb (value / r g b)
  (setq r (fix (/ value 65536))
        g (fix (/ (- value (* r 65536)) 256))
        b (- value (* r 65536) (* g 256)))
  (list r g b)
)

(defun dx:effective-color (en / ed aci layer-ed tc)
  (setq ed  (entget en)
        tc  (cdr (assoc 420 ed))
        aci (cdr (assoc 62 ed)))
  (cond
    (tc (list 'RGB (dx:true-color-rgb tc)))
    ((and aci (/= aci 0) (/= aci 256)) (list 'ACI (abs aci)))
    (T
     (setq layer-ed (tblsearch "LAYER" (cdr (assoc 8 ed))))
     (cond
       ((cdr (assoc 420 layer-ed))
        (list 'RGB (dx:true-color-rgb (cdr (assoc 420 layer-ed)))))
       ((cdr (assoc 62 layer-ed))
        (list 'ACI (abs (cdr (assoc 62 layer-ed)))))
       (T (list 'ACI 7)))))
)

(defun dx:color-kind (en / color mode value)
  (setq color (dx:effective-color en)
        mode  (car color)
        value (cadr color))
  (cond
    ((and (= mode 'ACI) (= value 7)) 'WHITE)
    ((and (= mode 'ACI) (= value 4)) 'CYAN)
    ((and (= mode 'RGB)
          (>= (car value) 245)
          (>= (cadr value) 245)
          (>= (caddr value) 245))
     'WHITE)
    ((and (= mode 'RGB)
          (<= (car value) 20)
          (>= (cadr value) 235)
          (>= (caddr value) 235))
     'CYAN)
    (T nil))
)

(defun dx:text-string (en / ed typ obj value)
  (setq ed  (entget en)
        typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "TEXT") (cdr (assoc 1 ed)))
    ((= typ "MTEXT")
     (setq obj   (vlax-ename->vla-object en)
           value (vl-catch-all-apply 'vla-get-TextString (list obj)))
     (if (vl-catch-all-error-p value) "" value))
    (T ""))
)

(defun dx:has-hanzi-p (s / codes b found)
  ;; 兼容历史 GBK 数据字节和 LISPSYS Unicode 码点。
  (setq codes (vl-string->list (if s s ""))
        found nil)
  (while (and codes (not found))
    (setq b (car codes))
    (cond
      ((and (>= b 19968) (<= b 40959))
       (setq found T))
      ((and (>= b 176) (<= b 247) (cdr codes)
            (>= (cadr codes) 64) (<= (cadr codes) 254)
            (/= (cadr codes) 127))
       (setq found T
             codes (cdr codes))))
    (setq codes (cdr codes)))
  found
)

(defun dx:item-from-info (doc info / en bbox)
  (setq en   (car info)
        bbox (aa:safe-get-bbox doc en))
  (if bbox
    (list en
          (aa:bbox-center-x bbox)
          (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
          (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox))
          (- (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox))
          bbox))
)

(defun dx:insert-y-desc (item items)
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    (T (cons (car items) (dx:insert-y-desc item (cdr items)))))
)

(defun dx:sort-y-desc (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (dx:insert-y-desc item out)))
  out
)

(defun dx:max-item-value (items index / result item value)
  (setq result 0.0)
  (foreach item items
    (setq value (nth index item))
    (if (> value result) (setq result value)))
  result
)

(defun dx:move-item-center (item tx ty)
  (aa:zz-move-text (nth 0 item) (nth 1 item) (nth 2 item) tx ty)
)

(defun dx:apply-group (doc group / info item kind text terminals principles destinations ignored
                       rows terminal-w principle-w destination-w max-h hgap vgap total-h total-w
                       top-y left-x i y target-x moved failed destination)
  (setq terminals    nil
        principles   nil
        destinations nil
        ignored      0
        moved        0
        failed       0)
  (foreach info group
    (setq item (dx:item-from-info doc info)
          kind (dx:color-kind (car info))
          text (dx:text-string (car info)))
    (cond
      ((null item) (setq ignored (1+ ignored)))
      ((= kind 'WHITE) (setq terminals (cons item terminals)))
      ((= kind 'CYAN)
       (if (dx:has-hanzi-p text)
         (setq destinations (cons item destinations))
         (setq principles (cons item principles))))
      (T (setq ignored (1+ ignored)))))
  (setq terminals     (dx:sort-y-desc terminals)
        principles    (dx:sort-y-desc principles)
        destinations  (dx:sort-y-desc destinations)
        rows          (max (length terminals) (length principles) 1)
        terminal-w    (dx:max-item-value terminals 3)
        principle-w   (dx:max-item-value principles 3)
        destination-w (dx:max-item-value destinations 3)
        max-h         (max (dx:max-item-value terminals 4)
                           (dx:max-item-value principles 4)
                           (dx:max-item-value destinations 4)
                           1.0)
        hgap          (max 2.0 (* max-h 0.80))
        vgap          (max 1.0 (* max-h 0.55))
        total-h       (+ (* rows max-h) (* (1- rows) vgap))
        total-w       (+ terminal-w
                         (if (and (> terminal-w 0.0) (> principle-w 0.0)) hgap 0.0)
                         principle-w
                         (if destinations hgap 0.0)
                         destination-w)
        left-x        (- (/ (+ (nth 3 (car group)) (nth 4 (car group))) 2.0)
                         (/ total-w 2.0))
        top-y         (+ (/ (+ (nth 5 (car group)) (nth 6 (car group))) 2.0)
                         (/ total-h 2.0)
                         (- (/ max-h 2.0))))
  (setq i 0)
  (while (< i rows)
    (setq y (- top-y (* i (+ max-h vgap))))
    (if (< i (length terminals))
      (progn
        (setq item (nth i terminals))
        (if (dx:move-item-center item (+ left-x (/ (nth 3 item) 2.0)) y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))))
    (if (< i (length principles))
      (progn
        (setq item (nth i principles)
              target-x (+ left-x terminal-w
                          (if (> terminal-w 0.0) hgap 0.0)
                          (/ (nth 3 item) 2.0)))
        (if (dx:move-item-center item target-x y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))))
    (setq i (1+ i)))
  (if destinations
    (progn
      (setq y (- top-y (* (1- rows) (+ max-h vgap)))
            target-x (+ left-x terminal-w
                        (if (and (> terminal-w 0.0) (> principle-w 0.0)) hgap 0.0)
                        principle-w
                        hgap))
      (foreach destination destinations
        (if (dx:move-item-center destination (+ target-x (/ (nth 3 destination) 2.0)) y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))
        (setq target-x (+ target-x (nth 3 destination) hgap)))))
  (list moved failed ignored)
)

(defun c:DX (/ *error* doc undo-open ss text-ss i en info infos groups group result
              moved failed skipped tol rect-tol)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        moved     0
        failed    0
        skipped   0
        tol       1e-8
        rect-tol  0.1)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[DX] 错误: " msg)))
    (sssetfirst nil nil)
    (princ))

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\n[DX] 请框选需要整理的方格和文字: ")
      (setq ss (ssget))))

  (cond
    ((null ss) (princ "\n[DX] 未选择对象。"))
    (T
     (setq text-ss (aa:zz-filter-text-ss ss))
     (if (= (sslength text-ss) 0)
       (princ "\n[DX] 选择中没有 TEXT/MTEXT 文字。")
       (progn
         (setq i 0 infos nil)
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol))
           (if info
             (setq infos (cons info infos))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))
         (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
         (vla-StartUndoMark doc)
         (setq undo-open T)
         (foreach group groups
           (setq result  (dx:apply-group doc group)
                 moved   (+ moved (car result))
                 failed  (+ failed (cadr result))
                 skipped (+ skipped (caddr result))))
         (vla-EndUndoMark doc)
         (setq undo-open nil)
         (redraw)
         (princ
           (strcat "\n[DX] 完成：整理 "
                   (itoa (length groups))
                   " 个方格，处理 "
                   (itoa moved)
                   " 个文字"
                   (if (> skipped 0) (strcat "，跳过 " (itoa skipped) " 个") "")
                   (if (> failed 0) (strcat "，失败 " (itoa failed) " 个") "")
                   "。"))))))
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================
;;; =======================================================================================
;;; DX2 命令: 按方格和视觉位置导出文字到剪贴板
;;; =======================================================================================

(defun dx2:group-record (group index / info)
  (setq info (car group))
  (list group
        (/ (+ (nth 3 info) (nth 4 info)) 2.0)
        (/ (+ (nth 5 info) (nth 6 info)) 2.0)
        (nth 3 info)
        (nth 4 info)
        (nth 5 info)
        (nth 6 info)
        index)
)

(defun dx2:group-before-p (a b / ay by ax bx ah bh row-tol)
  (setq ay      (nth 2 a)
        by      (nth 2 b)
        ax      (nth 1 a)
        bx      (nth 1 b)
        ah      (- (nth 5 a) (nth 6 a))
        bh      (- (nth 5 b) (nth 6 b))
        row-tol (* 0.25 (min ah bh)))
  (if (<= (abs (- ay by)) row-tol)
    (if (equal ax bx 1e-8)
      (< (nth 7 a) (nth 7 b))
      (< ax bx))
    (> ay by))
)

(defun dx2:insert-group (item items)
  (cond
    ((null items) (list item))
    ((dx2:group-before-p item (car items)) (cons item items))
    (T (cons (car items) (dx2:insert-group item (cdr items)))))
)

(defun dx2:sort-groups (groups / out group index)
  (setq out nil
        index 0)
  (foreach group groups
    (setq out (dx2:insert-group (dx2:group-record group index) out)
          index (1+ index)))
  out
)

(defun dx2:text-record (doc info index / item text)
  (setq item (dx:item-from-info doc info)
        text (dx:text-string (car info)))
  (if (and item text (> (strlen text) 0))
    (list text
          (nth 1 item)
          (nth 2 item)
          (nth 3 item)
          (nth 4 item)
          index))
)

(defun dx2:insert-y-desc (item items)
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    ((and (equal (nth 2 item) (nth 2 (car items)) 1e-8)
          (< (nth 5 item) (nth 5 (car items))))
     (cons item items))
    (T (cons (car items) (dx2:insert-y-desc item (cdr items)))))
)

(defun dx2:sort-y-desc (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (dx2:insert-y-desc item out)))
  out
)

(defun dx2:insert-x-asc (item items)
  (cond
    ((null items) (list item))
    ((< (nth 1 item) (nth 1 (car items))) (cons item items))
    ((and (equal (nth 1 item) (nth 1 (car items)) 1e-8)
          (< (nth 5 item) (nth 5 (car items))))
     (cons item items))
    (T (cons (car items) (dx2:insert-x-asc item (cdr items)))))
)

(defun dx2:sort-x-asc (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (dx2:insert-x-asc item out)))
  out
)

(defun dx2:group-rows (items / rows row row-y row-h item tol)
  (setq items (dx2:sort-y-desc items)
        rows  nil
        row   nil
        row-y nil
        row-h 0.0)
  (foreach item items
    (setq tol (* 0.55 (max row-h (nth 4 item) 1e-8)))
    (if (and row (<= (abs (- (nth 2 item) row-y)) tol))
      (progn
        (setq row (cons item row))
        (if (> (nth 4 item) row-h) (setq row-h (nth 4 item))))
      (progn
        (if row (setq rows (cons (dx2:sort-x-asc row) rows)))
        (setq row   (list item)
              row-y (nth 2 item)
              row-h (nth 4 item)))))
  (if row (setq rows (cons (dx2:sort-x-asc row) rows)))
  (reverse rows)
)

(defun dx2:append-text (out text)
  (if (= out "") text (strcat out "、" text))
)

(defun dx2:export-group (doc group / items info item index rows row out)
  (setq items nil
        index 0
        out   "")
  (foreach info group
    (setq item (dx2:text-record doc info index))
    (if item (setq items (cons item items)))
    (setq index (1+ index)))
  (setq rows (dx2:group-rows items))
  (foreach row rows
    (foreach item row
      (setq out (dx2:append-text out (car item)))))
  out
)

(defun c:DX2 (/ doc ss text-ss i en info infos groups sorted-groups group-record
               group-text out skipped ok tol rect-tol)
  (vl-load-com)
  (setq doc      (vla-get-ActiveDocument (vlax-get-acad-object))
        skipped  0
        out      ""
        tol      1e-8
        rect-tol 0.1)

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\n[DX2] 请框选需要导出的方格和文字: ")
      (setq ss (ssget))))

  (cond
    ((null ss)
     (princ "\n[DX2] 未选择对象。"))
    (T
     (setq text-ss (aa:zz-filter-text-ss ss))
     (if (= (sslength text-ss) 0)
       (princ "\n[DX2] 选择中没有 TEXT/MTEXT 文字。")
       (progn
         (setq i 0 infos nil)
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol))
           (if info
             (setq infos (cons info infos))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))
         (setq groups        (aa:zz-group-by-rect (reverse infos) rect-tol)
               sorted-groups (dx2:sort-groups groups))
         (foreach group-record sorted-groups
           (setq group-text (dx2:export-group doc (car group-record)))
           (if (/= group-text "")
             (setq out (dx2:append-text out group-text))))
         (if (= out "")
           (princ "\n[DX2] 没有找到可导出的文字。")
           (progn
             (setq ok (zi:to-clip out))
             (princ
               (strcat "\n[DX2] 已按顺序导出 "
                       (itoa (length sorted-groups))
                       " 个方格、"
                       (itoa (- (sslength text-ss) skipped))
                       " 个文字"
                       (if ok "，并复制到剪贴板。" "，但复制到剪贴板失败。")
                       (if (> skipped 0)
                         (strcat " 跳过 " (itoa skipped) " 个无法识别方格的文字。")
                         "")))))))))
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================
;;; Command: ZZ / JACC
;;; Purpose: Center selected TEXT/MTEXT inside nearest surrounding horizontal/vertical LINEs.
;;; =======================================================================================
(defun aa:zz-near-line-tol (tol)
  (max 0.5 (* tol 10.0))
)

(defun aa:zz-between-p (v a b tol / lo hi)
  (setq lo (min a b)
        hi (max a b))
  (and (>= v (- lo tol))
       (<= v (+ hi tol)))
)

(defun aa:zz-filter-text-ss (ss / out i en typ)
  (setq out (ssadd)
        i   0)
  (if ss
    (repeat (sslength ss)
      (setq en  (ssname ss i)
            typ (cdr (assoc 0 (entget en))))
      (if (or (= typ "TEXT") (= typ "MTEXT"))
        (ssadd en out))
      (setq i (1+ i))))
  out
)

(defun aa:zz-add-seg (p1 p2 near / x y ymin ymax xmin xmax)
  (cond
    ((<= (abs (- (car p1) (car p2))) near)
     (setq x    (/ (+ (car p1) (car p2)) 2.0)
           ymin (min (cadr p1) (cadr p2))
           ymax (max (cadr p1) (cadr p2))
           vlist (cons (list x ymin ymax) vlist)))
    ((<= (abs (- (cadr p1) (cadr p2))) near)
     (setq y    (/ (+ (cadr p1) (cadr p2)) 2.0)
           xmin (min (car p1) (car p2))
           xmax (max (car p1) (car p2))
           hlist (cons (list y xmin xmax) hlist)))
  )
)

(defun aa:zz-collect-lwpoly-pts (ed / pts)
  (setq pts '())
  (foreach pair ed
    (if (= (car pair) 10)
      (setq pts (cons (cdr pair) pts))))
  (reverse pts)
)

(defun aa:zz-poly-closed-p (ed / f)
  (setq f (cdr (assoc 70 ed)))
  (if f (/= 0 (logand 1 f)) nil)
)

(defun aa:zz-build-line-cache (line-ss tol / i en ed typ p1 p2 near vlist hlist pts closed prev first en2 ed2)
  (setq i    0
        near (aa:zz-near-line-tol tol)
        vlist '()
        hlist '())
  (if line-ss
    (repeat (sslength line-ss)
      (setq en  (ssname line-ss i)
            ed  (entget en)
            typ (cdr (assoc 0 ed)))
      (cond
        ((= typ "LINE")
         (setq p1 (cdr (assoc 10 ed))
               p2 (cdr (assoc 11 ed)))
         (if (and p1 p2)
           (aa:zz-add-seg p1 p2 near)))
        ((= typ "LWPOLYLINE")
         (setq pts    (aa:zz-collect-lwpoly-pts ed)
               closed (aa:zz-poly-closed-p ed)
               prev   nil
               first  nil)
         (foreach p pts
           (if prev
             (aa:zz-add-seg prev p near)
             (setq first p))
           (setq prev p))
         (if (and closed first prev (not (equal first prev)))
           (aa:zz-add-seg prev first near)))
        ((= typ "POLYLINE")
         (setq pts '()
               en2 (entnext en))
         (while (and en2
                     (setq ed2 (entget en2))
                     (= (cdr (assoc 0 ed2)) "VERTEX"))
           (setq pts (cons (cdr (assoc 10 ed2)) pts)
                 en2 (entnext en2)))
         (setq pts    (reverse pts)
               closed (aa:zz-poly-closed-p ed)
               prev   nil
               first  nil)
         (foreach p pts
           (if prev
             (aa:zz-add-seg prev p near)
             (setq first p))
           (setq prev p))
         (if (and closed first prev (not (equal first prev)))
           (aa:zz-add-seg prev first near)))
      )
      (setq i (1+ i))))
  (list vlist hlist)
)

(defun aa:zz-find-bound-lines (line-cache cx cy tol / vlist hlist rec x y left-x right-x top-y bottom-y dl dr dt db dist)
  (setq vlist (car line-cache)
        hlist (cadr line-cache)
        left-x nil
        right-x nil
        top-y nil
        bottom-y nil
        dl nil
        dr nil
        dt nil
        db nil)
  (foreach rec vlist
    (if (aa:zz-between-p cy (cadr rec) (caddr rec) tol)
      (progn
        (setq x (car rec))
        (cond
          ((< x (- cx tol))
           (setq dist (- cx x))
           (if (or (null dl) (< dist dl))
             (setq dl dist
                   left-x x)))
          ((> x (+ cx tol))
           (setq dist (- x cx))
           (if (or (null dr) (< dist dr))
             (setq dr dist
                   right-x x)))))))
  (foreach rec hlist
    (if (aa:zz-between-p cx (cadr rec) (caddr rec) tol)
      (progn
        (setq y (car rec))
        (cond
          ((< y (- cy tol))
           (setq dist (- cy y))
           (if (or (null db) (< dist db))
             (setq db dist
                   bottom-y y)))
          ((> y (+ cy tol))
           (setq dist (- y cy))
           (if (or (null dt) (< dist dt))
             (setq dt dist
                   top-y y)))))))
  (if (and left-x right-x top-y bottom-y)
    (list left-x right-x top-y bottom-y))
)

(defun aa:zz-text-info (doc en tol / bbox cx cy line-ss line-cache bounds margin pt1 pt2 lx rx ty by max-dist left-dist right-dist top-dist bottom-dist)
  ;; Compute the rectangle (lx rx ty by) bounding a text via spatial query.
  ;; Returns (en cx cy lx rx ty by) or nil if no valid enclosing rectangle.
  (if (setq bbox (aa:safe-get-bbox doc en))
    (progn
      (setq cx       (aa:bbox-center-x bbox)
            cy       (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
            max-dist 300.0
            margin   max-dist
            pt1      (list (- cx margin) (- cy margin))
            pt2      (list (+ cx margin) (+ cy margin))
            line-ss  (ssget "_C" pt1 pt2
                       '((-4 . "<OR")
                         (0 . "LINE")
                         (0 . "LWPOLYLINE")
                         (0 . "POLYLINE")
                         (-4 . "OR>"))))
      (if line-ss
        (progn
          (setq line-cache (aa:zz-build-line-cache line-ss tol)
                bounds     (aa:zz-find-bound-lines line-cache cx cy tol))
          (if bounds
            (progn
              (setq lx          (car bounds)
                    rx          (cadr bounds)
                    ty          (caddr bounds)
                    by          (cadddr bounds)
                    left-dist   (abs (- cx lx))
                    right-dist  (abs (- rx cx))
                    top-dist    (abs (- ty cy))
                    bottom-dist (abs (- cy by)))
              (if (or (> left-dist max-dist)
                      (> right-dist max-dist)
                      (> top-dist max-dist)
                      (> bottom-dist max-dist))
                nil
                (list en cx cy lx rx ty by)))
            nil))
        nil))
    nil)
)

(defun aa:zz-move-text (en cx cy tx ty / dx dy)
  (setq dx (- tx cx)
        dy (- ty cy))
  (if (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6))
    T
    (aa:safe-move-entity en (vlax-3d-point (list dx dy 0.0))))
)

(defun aa:zz-rect-match-p (a b rect-tol)
  ;; Two text-info records share the same rectangle when all four edges match.
  (and (equal (nth 3 a) (nth 3 b) rect-tol)
       (equal (nth 4 a) (nth 4 b) rect-tol)
       (equal (nth 5 a) (nth 5 b) rect-tol)
       (equal (nth 6 a) (nth 6 b) rect-tol))
)

(defun aa:zz-group-by-rect (infos rect-tol / groups info placed new-groups g)
  ;; Bucket text-info records by shared rectangle. Returns list of groups,
  ;; each group is a list of text-info records.
  (setq groups '())
  (foreach info infos
    (setq placed     nil
          new-groups '())
    (foreach g groups
      (cond
        ((and (not placed) (aa:zz-rect-match-p info (car g) rect-tol))
         (setq new-groups (cons (cons info g) new-groups)
               placed     T))
        (T
         (setq new-groups (cons g new-groups)))))
    (if (not placed)
      (setq new-groups (cons (list info) new-groups)))
    (setq groups (reverse new-groups)))
  groups
)

(defun aa:zz-pick-upper (a b)
  ;; Return the text-info record with the larger original cy (placed on top).
  (if (>= (nth 2 a) (nth 2 b)) a b)
)

(defun aa:zz-insert-y-desc (item items)
  ;; Insert one text-info record, keeping the list sorted by cy descending.
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    (T (cons (car items) (aa:zz-insert-y-desc item (cdr items)))))
)

(defun aa:zz-sort-y-desc (items / out item)
  ;; Sort text-info records by original cy descending (top text first).
  (setq out nil)
  (foreach item items
    (setq out (aa:zz-insert-y-desc item out)))
  out
)

(defun aa:zz-apply-group (group / cnt info en cx cy lx rx ty by upper lower mid a b c tx tmp sorted n i y)
  ;; Move the texts in one group to their target positions and return the
  ;; number of texts that actually changed position (count for the [ZZ] report).
  (setq cnt (length group))
  (cond
    ((= cnt 1)
     (setq info (car group)
           en   (nth 0 info)
           cx   (nth 1 info)
           cy   (nth 2 info)
           lx   (nth 3 info)
           rx   (nth 4 info)
           ty   (nth 5 info)
           by   (nth 6 info))
     (if (aa:zz-move-text en cx cy (/ (+ lx rx) 2.0) (/ (+ ty by) 2.0))
       1 0))
    ((= cnt 2)
     ;; Split the rectangle into two halves; upper text -> center of upper
     ;; half, lower text -> center of lower half.
     (setq a     (car group)
           b     (cadr group)
           upper (aa:zz-pick-upper a b)
           lower (if (eq upper a) b a)
           lx    (nth 3 upper)
           rx    (nth 4 upper)
           ty    (nth 5 upper)
           by    (nth 6 upper)
           tx    (/ (+ lx rx) 2.0))
     (+
       (if (aa:zz-move-text (nth 0 upper) (nth 1 upper) (nth 2 upper)
                            tx (/ (+ (* 3.0 ty) by) 4.0)) 1 0)
       (if (aa:zz-move-text (nth 0 lower) (nth 1 lower) (nth 2 lower)
                            tx (/ (+ ty (* 3.0 by)) 4.0)) 1 0)))
    ((= cnt 3)
     ;; Split the rectangle into three equal vertical bands; sort by cy desc
     ;; and place each text at the center of its band.
     (setq a (nth 0 group)
           b (nth 1 group)
           c (nth 2 group))
     (cond
       ((and (>= (nth 2 a) (nth 2 b)) (>= (nth 2 a) (nth 2 c)))
        (setq upper a mid b lower c))
       ((and (>= (nth 2 b) (nth 2 a)) (>= (nth 2 b) (nth 2 c)))
        (setq upper b mid a lower c))
       (T
        (setq upper c mid a lower b)))
     (if (< (nth 2 mid) (nth 2 lower))
       (setq tmp mid mid lower lower tmp))
     (setq lx (nth 3 upper)
           rx (nth 4 upper)
           ty (nth 5 upper)
           by (nth 6 upper)
           tx (/ (+ lx rx) 2.0))
     (+
       (if (aa:zz-move-text (nth 0 upper) (nth 1 upper) (nth 2 upper)
                            tx (/ (+ (* 5.0 ty) by) 6.0)) 1 0)
       (if (aa:zz-move-text (nth 0 mid) (nth 1 mid) (nth 2 mid)
                            tx (/ (+ ty by) 2.0)) 1 0)
       (if (aa:zz-move-text (nth 0 lower) (nth 1 lower) (nth 2 lower)
                            tx (/ (+ ty (* 5.0 by)) 6.0)) 1 0)))
    (T
     ;; 4+ texts in one rectangle: split the rectangle vertically into N
     ;; equal bands and center each text in its own band (sorted top to
     ;; bottom by original cy), the same layout rule as the 2/3 cases.
     (setq sorted (aa:zz-sort-y-desc group)
           n      (length sorted)
           info   (car sorted)
           lx     (nth 3 info)
           rx     (nth 4 info)
           ty     (nth 5 info)
           by     (nth 6 info)
           tx     (/ (+ lx rx) 2.0)
           cnt    0
           i      0)
     (foreach info sorted
       (setq y (+ ty (* (1+ (* 2 i)) (- by ty) (/ 0.5 n))))
       (if (aa:zz-move-text (nth 0 info) (nth 1 info) (nth 2 info) tx y)
         (setq cnt (1+ cnt)))
       (setq i (1+ i)))
     cnt))
)

(defun aa:zz-run (/ *error* doc undo-open ss text-ss i en changed skipped tol rect-tol infos groups info)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0
        tol       1e-8
        rect-tol  0.1)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[ZZ] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\n[ZZ] 请选择对象，仅处理 TEXT/MTEXT 文字: ")
      (setq ss (ssget))))

  (if ss
    (progn
      (setq text-ss (aa:zz-filter-text-ss ss))
      (if (> (sslength text-ss) 0)
        (progn
          (sssetfirst nil text-ss)
          (vla-startundomark doc)
          (setq undo-open T
                i         0
                infos     '())
          (repeat (sslength text-ss)
            (setq en   (ssname text-ss i)
                  info (aa:zz-text-info doc en tol))
            (if info
              (setq infos (cons info infos))
              (setq skipped (1+ skipped)))
            (setq i (1+ i)))
          (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
          (foreach g groups
            (setq changed (+ changed (aa:zz-apply-group g))))
          (vla-endundomark doc)
          (setq undo-open nil)
          (princ
            (strcat
              "\n[ZZ] 完成。已居中: "
              (itoa changed)
              "，跳过: "
              (itoa skipped)
              ".")))
        (princ "\n[ZZ] 选择中没有 TEXT/MTEXT 文字。")))
    (princ "\n[ZZ] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

(defun c:ZZ ()
  (aa:zz-run)
)

(defun c:JACC ()
  (aa:zz-run)
)

;;; MJ: automatically fit a single-column table to its longest text.
(defun aa:mj-frame-bounds (doc ss / i en ed typ bbox low high)
  (setq i 0
        low nil
        high nil)
  (repeat (sslength ss)
    (setq en  (ssname ss i)
          ed  (entget en)
          typ (if ed (cdr (assoc 0 ed)) nil))
    (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
      (if (setq bbox (aa:safe-get-bbox doc en))
        (if low
          (setq low  (mapcar 'min low (car bbox))
                high (mapcar 'max high (cadr bbox)))
          (setq low  (car bbox)
                high (cadr bbox)))))
    (setq i (1+ i)))
  (if low (list low high))
)

(defun aa:mj-collect-text-data (doc ss / i en bbox width height cx cy max-width max-height items)
  (setq i 0
        max-width 0.0
        max-height 0.0
        items '())
  (repeat (sslength ss)
    (setq en   (ssname ss i)
          bbox (aa:safe-get-bbox doc en))
    (if bbox
      (progn
        (setq width  (- (car (cadr bbox)) (car (car bbox)))
              height (- (cadr (cadr bbox)) (cadr (car bbox)))
              cx (/ (+ (car (car bbox)) (car (cadr bbox))) 2.0)
              cy (/ (+ (cadr (car bbox)) (cadr (cadr bbox))) 2.0)
              max-width  (max max-width width)
              max-height (max max-height height)
              items (cons (list en cx cy) items))))
    (setq i (1+ i)))
  (if items (list max-width max-height (reverse items)))
)

(defun aa:mj-add-unique-y (y ys tol / found value)
  (setq found nil)
  (foreach value ys
    (if (equal y value tol) (setq found T)))
  (if found ys (cons y ys))
)

(defun aa:mj-horizontal-ys (doc line-ss / i en bbox width height y ys)
  (setq i 0
        ys '())
  (repeat (sslength line-ss)
    (setq en   (ssname line-ss i)
          bbox (aa:safe-get-bbox doc en))
    (if bbox
      (progn
        (setq width  (- (car (cadr bbox)) (car (car bbox)))
              height (- (cadr (cadr bbox)) (cadr (car bbox))))
        (if (and (> width 1e-8) (<= height 1e-6))
          (setq y (/ (+ (cadr (car bbox)) (cadr (cadr bbox))) 2.0)
                ys (aa:mj-add-unique-y y ys 1e-6)))))
    (setq i (1+ i)))
  ys
)

(defun aa:mj-row-center-y (cy ys / above below y)
  (setq above nil
        below nil)
  (foreach y ys
    (cond
      ((> y cy)
       (if (or (null above) (< y above)) (setq above y)))
      ((< y cy)
       (if (or (null below) (> y below)) (setq below y)))))
  (if (and above below)
    (/ (+ above below) 2.0)
    cy)
)
(defun aa:mj-scale-point-x (pt center-x factor)
  (cons (+ center-x (* (- (car pt) center-x) factor)) (cdr pt))
)

(defun aa:mj-scale-simple-entity-x (en center-x factor / ed typ codes new-ed)
  (setq ed  (entget en)
        typ (if ed (cdr (assoc 0 ed)) nil)
        codes (if (= typ "LINE") '(10 11) '(10)))
  (if ed
    (progn
      (setq new-ed
        (mapcar
          '(lambda (item)
             (if (and (member (car item) codes)
                      (listp (cdr item)))
               (cons (car item) (aa:mj-scale-point-x (cdr item) center-x factor))
               item))
          ed))
      (if (entmod new-ed) T nil))
    nil)
)

(defun aa:mj-scale-polyline-x (en center-x factor / vertex ed typ ok)
  (setq vertex (entnext en)
        ok T)
  (while vertex
    (setq ed  (entget vertex)
          typ (if ed (cdr (assoc 0 ed)) nil))
    (cond
      ((= typ "VERTEX")
       (if (not
             (entmod
               (subst
                 (cons 10 (aa:mj-scale-point-x (cdr (assoc 10 ed)) center-x factor))
                 (assoc 10 ed)
                 ed)))
         (setq ok nil)))
      ((= typ "SEQEND")
       (setq vertex nil)))
    (if vertex (setq vertex (entnext vertex))))
  ok
)

(defun aa:mj-scale-line-x (en center-x factor / typ)
  (setq typ (cdr (assoc 0 (entget en))))
  (cond
    ((member typ '("LINE" "LWPOLYLINE"))
     (aa:mj-scale-simple-entity-x en center-x factor))
    ((= typ "POLYLINE")
     (aa:mj-scale-polyline-x en center-x factor))
    (T nil))
)

(defun aa:mj-move-cached-texts (items center-x horizontal-ys / item target-y moved failed)
  (setq moved 0
        failed 0)
  (foreach item items
    (setq target-y (aa:mj-row-center-y (nth 2 item) horizontal-ys))
    (if (aa:zz-move-text (nth 0 item) (nth 1 item) (nth 2 item) center-x target-y)
      (setq moved (1+ moved))
      (setq failed (1+ failed))))
  (list moved failed)
)
(defun c:MJ (/ *error* doc undo-open ss line-ss text-ss i en typ
               bounds text-data horizontal-ys old-width target-width
               center-x factor scaled failed move-result)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        scaled    0
        failed    0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[MJ] 错误：" msg)))
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[MJ] 请框选整张表格的边线和文字：")
      (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))

  (if ss
    (progn
      (setq line-ss (ssadd)
            text-ss (ssadd)
            i 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              typ (cdr (assoc 0 (entget en))))
        (if (member typ '("TEXT" "MTEXT"))
          (ssadd en text-ss)
          (ssadd en line-ss))
        (setq i (1+ i)))

      (cond
        ((= (sslength line-ss) 0)
         (princ "\n[MJ] 选择中没有找到表格边线。"))
        ((= (sslength text-ss) 0)
         (princ "\n[MJ] 选择中没有找到 TEXT/MTEXT 文字。"))
        ((null (setq bounds (aa:mj-frame-bounds doc line-ss)))
         (princ "\n[MJ] 无法取得表格范围。"))
        ((null (setq text-data (aa:mj-collect-text-data doc text-ss)))
         (princ "\n[MJ] 无法取得文字尺寸。"))
        (T
         (setq old-width (- (car (cadr bounds)) (car (car bounds)))
               center-x (/ (+ (car (car bounds)) (car (cadr bounds))) 2.0)
               target-width (min old-width
                                 (+ (car text-data) (* 2.0 (cadr text-data))))
               horizontal-ys (aa:mj-horizontal-ys doc line-ss))
         (if (<= old-width 1e-8)
           (princ "\n[MJ] 表格宽度无效。")
           (progn
             (setq factor (/ target-width old-width))
             (vla-StartUndoMark doc)
             (setq undo-open T
                   i 0)

             (repeat (sslength line-ss)
               (setq en (ssname line-ss i))
               (if (aa:mj-scale-line-x en center-x factor)
                 (setq scaled (1+ scaled))
                 (setq failed (1+ failed)))
               (setq i (1+ i)))

             (setq move-result
                   (aa:mj-move-cached-texts
                     (caddr text-data) center-x horizontal-ys))
             (redraw)
             (vla-EndUndoMark doc)
             (setq undo-open nil)
             (princ
               (strcat
                 "\n[MJ] 完成：表格宽度由 " (rtos old-width 2 2)
                 " 调整为 " (rtos target-width 2 2)
                 "，居中文字 " (itoa (car move-result)) " 个。"
                 (if (> (+ failed (cadr move-result)) 0)
                   (strcat " 另有 "
                           (itoa (+ failed (cadr move-result)))
                           " 个对象修改失败。")
                   ""))))))))
    (princ "\n[MJ] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

;;;========================================================================================
;;; DF-DB-AF-AB  文字批量增删 (DB=删末尾 DF=删开头 AB=尾部加字 AF=头部加字)
;;;========================================================================================
;;; ============================================================
;;; DF-DB-AF-AB.lsp  文字批量增删
;;;   DB : 删除每个选中文字对象“末尾”的 N 个字符
;;;   DF : 删除每个选中文字对象“开头”的 N 个字符
;;;   AF : 在每个选中文字对象“开头”增加输入的文字
;;;   AB : 在每个选中文字对象“末尾”增加输入的文字
;;;   N 个字符：汉字/数字/字母/符号(如 ×)均按 1 个字符计
;;; ============================================================


;; 取实体的文字内容（TEXT/MTEXT 均用 DXF 1）
(defun db:get-str (en / e)
  (setq e (entget en))
  (cdr (assoc 1 e))
)

;; 写回文字内容
(defun db:set-str (en s / e)
  (setq e (entget en))
  (entmod (subst (cons 1 s) (assoc 1 e) e))
  (vl-catch-all-apply 'entupd (list en))
)

;; 选择文字对象，返回选择集（无则 nil）
(defun db:sel (/ ss)
  (princ "\n请选择文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss) (princ "\n未选择任何文字对象。"))
  ss
)

;; 删除：mode = "B" 删尾，"F" 删头
(defun db:del (mode / ss n i en s len ns cnt)
  (if (setq ss (db:sel))
    (progn
      (initget 7) ; 不允许空、0、负数
      (setq n (getint "\n请输入要删除的字符个数: "))
      (setq i 0 cnt 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        (setq s (db:get-str en))
        (if s
          (progn
            (setq len (strlen s))
            (if (>= n len)
              (setq ns "")                              ; 删空
              (if (= mode "B")
                (setq ns (substr s 1 (- len n)))        ; 删末尾 N
                (setq ns (substr s (1+ n)))             ; 删开头 N
              )
            )
            (db:set-str en ns)
            (setq cnt (1+ cnt))
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\n已处理 " (itoa cnt) " 个文字对象。"))
    )
  )
  (princ)
)

;; 增加：mode = "B" 加到末尾，"F" 加到开头
(defun db:add (mode / ss txt i en s ns cnt)
  (if (setq ss (db:sel))
    (progn
      (setq txt (getstring T "\n请输入要增加的文字: ")) ; T 允许含空格
      (if (= txt "")
        (princ "\n未输入文字，已取消。")
        (progn
          (setq i 0 cnt 0)
          (while (< i (sslength ss))
            (setq en (ssname ss i))
            (setq s (db:get-str en))
            (if s
              (progn
                (if (= mode "B")
                  (setq ns (strcat s txt))   ; 加到末尾
                  (setq ns (strcat txt s))   ; 加到开头
                )
                (db:set-str en ns)
                (setq cnt (1+ cnt))
              )
            )
            (setq i (1+ i))
          )
          (princ (strcat "\n已处理 " (itoa cnt) " 个文字对象。"))
        )
      )
    )
  )
  (princ)
)

;; DB 删除每个选中文字末尾的 N 个字符
(defun c:DB () (db:del "B"))
;; DF 删除每个选中文字开头的 N 个字符
(defun c:DF () (db:del "F"))
;; AB 在每个选中文字末尾增加输入的文字
(defun c:AB () (db:add "B"))
;; AF 在每个选中文字开头增加输入的文字
(defun c:AF () (db:add "F"))

(princ)


;; ============================================================
;; ZI  提取选中文字到剪贴板
;;   选中若干 TEXT/MTEXT 后执行 ZI，
;;   把所有文字内容按"从上到下、从左到右"排序，
;;   用顿号"、"连接后复制到 Windows 剪贴板。
;;   例: 公用测控柜、智能故障录波柜
;; ============================================================

;; 取实体插入点坐标 (优先 group 10)
(defun zi:pt (ed)
  (cdr (assoc 10 ed))
)

;; 把字符串写入剪贴板 (借助 htmlfile 的 ActiveX 剪贴板接口)
(defun zi:to-clip (str / html result)
  (setq result nil)
  (vl-catch-all-apply
    (function
      (lambda ()
        (setq html (vlax-create-object "htmlfile"))
        (vlax-invoke
          (vlax-get (vlax-get html 'ParentWindow) 'ClipboardData)
          'SetData "Text" str)
        (vlax-release-object html)
        (setq result t)
      )
    )
  )
  result
)

;; 读取 Windows 剪贴板中的文本
(defun qe:get-clip-text (/ html win clip result)
  (setq result
    (vl-catch-all-apply
      (function
        (lambda ()
          (setq html (vlax-create-object "htmlfile")
                win (vlax-get html 'ParentWindow)
                clip (vlax-get win 'ClipboardData))
          (vlax-invoke clip 'GetData "Text")
        )
      )
    )
  )
  (if clip (vl-catch-all-apply 'vlax-release-object (list clip)))
  (if win (vl-catch-all-apply 'vlax-release-object (list win)))
  (if html (vl-catch-all-apply 'vlax-release-object (list html)))
  (if (vl-catch-all-error-p result) nil result)
)

;; 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后面的部分（entmod 优化版：QE 命令）
(defun c:QE (/ *error* doc undo-open clip-text ss i ent ed old-text new-text pos changed failed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "
[QE] 执行失败：" msg)))
    (princ)
  )

  (setq clip-text (qe:get-clip-text))
  (cond
    ((not (= (type clip-text) 'STR))
     (princ "
[QE] 无法获取 Windows 剪贴板中的文字。"))
    ((= clip-text "")
     (princ "
[QE] 剪贴板中没有可用的文字，未修改任何对象"))
    ((not (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB,ATTDEF")))))
     (princ "
[QE] 未选中可替换文字的对象"))
    (t
     (vla-StartUndoMark doc)
     (setq undo-open t
           i -1
           changed 0
           failed 0)
     (repeat (sslength ss)
       (setq ent (ssname ss (setq i (1+ i)))
             ed (entget ent)
             old-text (cdr (assoc 1 ed)))
       (cond
         ((not old-text)
          (setq failed (1+ failed)))
         ((= old-text clip-text)
          (setq changed (1+ changed)))
         (t
          ;; 文字含“至”字时只替换“至”后面的文字，
          ;; 例如“至10kV 1(2)#站用变”+剪贴板“变压器超温报警”→“至变压器超温报警”
          (setq pos      (vl-string-search "至" old-text)
                new-text (if pos
                          (strcat (substr old-text 1 (1+ pos)) clip-text)
                          clip-text))
          (if (= old-text new-text)
            (setq changed (1+ changed))
            (progn
              (setq ed (subst (cons 1 new-text) (assoc 1 ed) ed))
              (if (entmod ed)
                (setq changed (1+ changed))
                (setq failed (1+ failed)))))))
     )
     (vla-EndUndoMark doc)
     (setq undo-open nil)
     (princ
       (strcat
         "
[QE] 已从剪贴板替换 "
         (itoa changed)
         " 个文字对象"
         (if (> failed 0)
           (strcat "，其中 " (itoa failed) " 个修改失败。")
           "。"))
     )
    )
  )
  (princ)
)

;; QW 内部: 把 (y x 文字 字高 序号) 列表按行分组，
;; 同一行用顿号连接，行与行之间也用顿号连接，返回 (连接结果 行数)
(defun qw:join (items / rows row row-y row-h tol res line)
  ;; 先整体按 y 从大到小(从上到下)排序，序号作为最后一级比较，
  ;; 保证比较严格，避免 vl-sort 把同坐标的元素当重复项丢掉
  (setq items
    (vl-sort items
      (function
        (lambda (a b)
          (if (equal (car a) (car b) 1e-9)
            (< (nth 4 a) (nth 4 b))
            (> (car a) (car b))
          )
        )
      )
    )
  )
  ;; 以字高的一半作容差分行: y 差在容差内视为同一行
  (setq rows nil row nil row-y nil row-h 0.0)
  (foreach it items
    (setq tol (* 0.5 (max row-h (cadddr it) 1e-8)))
    (if (and row (<= (abs (- (car it) row-y)) tol))
      (progn
        (setq row (cons it row))
        (if (> (cadddr it) row-h) (setq row-h (cadddr it)))
      )
      (progn
        (if row (setq rows (cons row rows)))
        (setq row    (list it)
              row-y  (car it)
              row-h  (cadddr it))
      )
    )
  )
  (if row (setq rows (cons row rows)))
  (setq rows (reverse rows))
  ;; 行内按 x 从小到大(从左到右)，行内行间全部用顿号连接
  (setq res "")
  (foreach r rows
    (setq r
      (vl-sort r
        (function
          (lambda (a b)
            (if (equal (cadr a) (cadr b) 1e-9)
              (< (nth 4 a) (nth 4 b))
              (< (cadr a) (cadr b))
            )
          )
        )
      )
    )
    (setq line "")
    (foreach it r
      (setq line
        (if (= line "")
          (caddr it)
          (strcat line "、" (caddr it))
        )
      )
    )
    (setq res (if (= res "") line (strcat res "、" line)))
  )
  (list res (length rows))
)

;;   例: ZD1、+KM1、ZD11、-KM1、直流馈线柜、1-2ID4、1(2)B-N4121
;; QW 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板
(defun c:QW ( / ss i idx ent ed txt hgt items pt out ok)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq txt (cdr (assoc 1 ed)))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          (setq out (qw:join items))
          (setq ok (zi:to-clip (car out)))
          (princ (strcat "
已提取 " (itoa (length items)) " 个文字，共 "
                         (itoa (cadr out)) " 行"
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "
选中的对象里没有可提取的文字。")
      )
    )
    (princ "
未选中文字。")
  )
  (princ)
)

;; QW2 提取选中文字及其坐标，每项一行 "x,y 文字"（坐标在前，保留 2 位小数），
;; 按从上到下、从左到右排序，复制到剪贴板
;; 按从上到下、从左到右排序
;; QW2 提取选中文字及坐标，每项一行 "x,y 文字"（坐标在前，保留 2 位小数），复制到剪贴板
(defun c:QW2 ( / ss i idx ent ed txt hgt pt items out ok)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq txt (cdr (assoc 1 ed)))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          ;; 排序: 按 y 从大到小(从上到下), 再按 x 从小到大(从左到右), 序号兜底保证严格比较
          (setq items
            (vl-sort items
              (function
                (lambda (a b)
                  (if (equal (car a) (car b) 1e-9)
                    (if (equal (cadr a) (cadr b) 1e-9)
                      (< (nth 4 a) (nth 4 b))
                      (< (cadr a) (cadr b))
                    )
                    (> (car a) (car b))
                  )
                )
              )
            )
          )
          ;; 每项一行 "x,y 文字"，行间用回车换行
          (setq out "")
          (foreach it items
            (setq out
              (strcat out
                      (rtos (cadr it) 2 2) "," (rtos (car it) 2 2) " " (caddr it)
                      "\r\n"))
          )
          ;; 去掉末尾换行，输出更干净
          (if (> (strlen out) 2)
            (setq out (substr out 1 (- (strlen out) 2))))
          (setq ok (zi:to-clip out))
          (princ (strcat "\n已提取 " (itoa (length items)) " 个文字及坐标"
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "\n选中的对象里没有可提取的文字。")
      )
    )
    (princ "\n未选中文字。")
  )
  (princ)
)

;; 白色及其他颜色与 QW2 相同，每项一行 "x,y 文字"；青色为 "x,y 文字 端子名"
;; DX1 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板
(defun c:DX1 ( / ss i idx ent ed txt hgt pt items out ok suffix cyan-n)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil cyan-n 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq txt (cdr (assoc 1 ed)))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (if (= (dx:color-kind ent) 'CYAN)
              (progn
                (setq suffix " 端子名")
                (setq cyan-n (1+ cyan-n))
              )
              (setq suffix "")
            )
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx suffix) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          ;; 排序: 按 y 从大到小(从上到下), 再按 x 从小到大(从左到右), 序号兜底保证严格比较
          (setq items
            (vl-sort items
              (function
                (lambda (a b)
                  (if (equal (car a) (car b) 1e-9)
                    (if (equal (cadr a) (cadr b) 1e-9)
                      (< (nth 4 a) (nth 4 b))
                      (< (cadr a) (cadr b))
                    )
                    (> (car a) (car b))
                  )
                )
              )
            )
          )
          ;; 每项一行 "x,y 文字"，青色追加 " 端子名"
          (setq out "")
          (foreach it items
            (setq out
              (strcat out
                      (rtos (cadr it) 2 2) "," (rtos (car it) 2 2) " " (caddr it) (nth 5 it)
                      "\r\n"))
          )
          ;; 去掉末尾换行，输出更干净
          (if (> (strlen out) 2)
            (setq out (substr out 1 (- (strlen out) 2))))
          (setq ok (zi:to-clip out))
          (princ (strcat "\n已提取 " (itoa (length items)) " 个文字及坐标"
                         (if (> cyan-n 0)
                           (strcat "，其中 " (itoa cyan-n) " 个青色文字已标注端子名")
                           "")
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "\n选中的对象里没有可提取的文字。")
      )
    )
    (princ "\n未选中文字。")
  )
  (princ)
)

(princ)


;; ============================================================
;; CE  测量点序列形成的多段线总长度
;; ============================================================

;;; CE - 测量点序列形成的多段线总长度
;;; 输入 CE 后依次点击若干点, 回车/空格结束, 输出总长度
;;; 点击过程中用带宽度的临时 LWPOLYLINE 实体做预览,
;;; 缩放/平移/REGEN 都不会被擦掉, 结束后自动删除预览, 仅输出长度

;; 用确认的点列重建预览多段线, 返回新实体名
(defun ce-redraw (pts w / lst)
  (setq lst
    (list '(0 . "LWPOLYLINE")
          '(100 . "AcDbEntity")
          '(100 . "AcDbPolyline")
          (cons 90 (length pts))
          '(70 . 0)
          (cons 43 w)   ;; 全局宽度
          '(62 . 1)))   ;; 颜色: 红
  (foreach p pts
    (setq lst (append lst (list (cons 10 (list (car p) (cadr p)))))))
  (entmake lst)
  (entlast)
)

;; CE 测量点序列形成的多段线总长度
(defun c:CE (/ pt pts total i p1 p2 tmp w)
  (setq pts '())
  (setq pt (getpoint "\n请点击第一个点 (回车/空格结束): "))
  (while pt
    (setq pts (cons pt pts))
    ;; 宽度取当前视图高度的比例, 任意图纸尺度下都明显
    (setq w (/ (getvar "VIEWSIZE") 50.0))
    (if tmp (entdel tmp))
    (if (>= (length pts) 2)
      (setq tmp (ce-redraw (reverse pts) w)))
    ;; (car pts) 为最近确认点, 作为当前段的橡皮筋基点
    (setq pt (getpoint (car pts) "\n请点击下一个点 (回车/空格结束): "))
  )
  (if tmp (entdel tmp)) ;; 删除预览, 只测量不留实体
  (setq pts (reverse pts))
  (if (< (length pts) 2)
    (princ "\n点数不足, 至少需要两个点。")
    (progn
      (setq total 0.0 i 0)
      (while (< (1+ i) (length pts))
        (setq p1 (nth i pts)
              p2 (nth (1+ i) pts)
              total (+ total (distance p1 p2))
              i (1+ i))
      )
      (princ (strcat "\n共点击 " (itoa (length pts)) " 个点, 多段线总长度 = " (rtos total 2 4)))
    )
  )
  (princ)
)
(princ)

;; ============================================================
;; AW  自动微移文字避让
;;   先选择很多文字，再输入 AW；如果选择集中夹杂其他对象，只处理 TEXT/MTEXT。
;;   程序按文字包围框检查附近对象，尽量向上、下、右、左小幅移动，
;;   目标是让文字包围框不再与线、文字或其他图元重叠。
;; ============================================================

(setq aw:gap-factor 0.03)     ; 避让余量，按文字高度折算
(setq aw:step-factor 0.15)    ; 每次尝试移动量，按文字高度折算
(setq aw:max-try 28)          ; 每个方向最多尝试次数

(defun aw:max2 (a b)
  (if (> a b) a b)
)

(defun aw:min2 (a b)
  (if (< a b) a b)
)

(defun aw:3d (p)
  (if (= (length p) 2)
    (list (car p) (cadr p) 0.0)
    p
  )
)

(defun aw:v+ (a b)
  (mapcar '+ (aw:3d a) (aw:3d b))
)

(defun aw:v* (v k)
  (mapcar '(lambda (x) (* x k)) (aw:3d v))
)

(defun aw:ucs-disp->wcs (v)
  (trans (aw:3d v) 1 0 T)
)

(defun aw:bbox (obj / mn mx r)
  (setq r (vl-catch-all-apply 'vla-getboundingbox (list obj 'mn 'mx)))
  (if (vl-catch-all-error-p r)
    nil
    (list (vlax-safearray->list mn) (vlax-safearray->list mx))
  )
)

(defun aw:bbox-move (bb v)
  (list (aw:v+ (car bb) v) (aw:v+ (cadr bb) v))
)

(defun aw:bbox-size (bb / mn mx)
  (setq mn (car bb) mx (cadr bb))
  (list (abs (- (car mx) (car mn)))
        (abs (- (cadr mx) (cadr mn)))
        (abs (- (caddr mx) (caddr mn))))
)

(defun aw:expand-bbox (bb gap / mn mx)
  (setq mn (car bb) mx (cadr bb))
  (list (list (- (car mn) gap) (- (cadr mn) gap) (- (caddr mn) gap))
        (list (+ (car mx) gap) (+ (cadr mx) gap) (+ (caddr mx) gap)))
)

(defun aw:bbox->ucs-window (bb / mn mx p1 p2 p3 p4 pts xs ys)
  (setq mn (car bb) mx (cadr bb))
  (setq p1 (trans (list (car mn) (cadr mn) 0.0) 0 1))
  (setq p2 (trans (list (car mx) (cadr mn) 0.0) 0 1))
  (setq p3 (trans (list (car mx) (cadr mx) 0.0) 0 1))
  (setq p4 (trans (list (car mn) (cadr mx) 0.0) 0 1))
  (setq pts (list p1 p2 p3 p4))
  (setq xs (mapcar 'car pts))
  (setq ys (mapcar 'cadr pts))
  (list (list (apply 'min xs) (apply 'min ys) 0.0)
        (list (apply 'max xs) (apply 'max ys) 0.0))
)

(defun aw:ss-has-other-p (ss self / i en found)
  (setq i 0 found nil)
  (while (and ss (< i (sslength ss)) (not found))
    (setq en (ssname ss i))
    (if (/= en self)
      (setq found T)
    )
    (setq i (1+ i))
  )
  found
)

(defun aw:blocked-p (self bb gap / win ss)
  (setq win (aw:bbox->ucs-window (aw:expand-bbox bb gap)))
  (setq ss (ssget "_C" (car win) (cadr win)))
  (aw:ss-has-other-p ss self)
)

(defun aw:try-offset (self basebb gap step / dirs n d v cand ok)
  (setq dirs
    (list
      (list 0.0 1.0 0.0)
      (list 0.0 -1.0 0.0)
      (list 1.0 0.0 0.0)
      (list -1.0 0.0 0.0)
    )
  )
  (setq n 1 ok nil)
  (while (and (<= n aw:max-try) (not ok))
    (foreach d dirs
      (if (not ok)
        (progn
          (setq v (aw:ucs-disp->wcs (aw:v* d (* step n))))
          (setq cand (aw:bbox-move basebb v))
          (if (not (aw:blocked-p self cand gap))
            (setq ok v)
          )
        )
      )
    )
    (setq n (1+ n))
  )
  ok
)

(defun aw:move-object (obj v / r)
  (setq r
    (vl-catch-all-apply
      'vla-move
      (list obj (vlax-3d-point '(0.0 0.0 0.0)) (vlax-3d-point v))
    )
  )
  (not (vl-catch-all-error-p r))
)

(defun aw:text-unit (en bb / ed h sz w)
  (setq ed (entget en))
  (setq h (cdr (assoc 40 ed)))
  (if (and h (> h 1.0e-8))
    h
    (progn
      (setq sz (aw:bbox-size bb))
      (setq w (car sz))
      (setq h (cadr sz))
      (cond
        ((and h (> h 1.0e-8)) h)
        ((and w (> w 1.0e-8)) w)
        (T 1.0)
      )
    )
  )
)

(defun aw:process-one (en / obj bb unit gap step v)
  (setq obj (vlax-ename->vla-object en))
  (setq bb (aw:bbox obj))
  (if bb
    (progn
      (setq unit (aw:text-unit en bb))
      (setq gap (aw:max2 (* unit aw:gap-factor) 1.0e-8))
      (setq step (aw:max2 (* unit aw:step-factor) 1.0e-8))
      (if (aw:blocked-p en bb gap)
        (progn
          (setq v (aw:try-offset en bb gap step))
          (if v
            (if (aw:move-object obj v) 1 -1)
            -1
          )
        )
        0
      )
    )
    -1
  )
)
(defun aw:get-selection (/ ss)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (not ss)
    (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  )
  ss
)

(defun c:AW (/ *error* doc ss i en r moved clean fail total)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (defun *error* (msg)
    (if doc
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
    )
    (sssetfirst nil nil)
    (if (and msg (/= msg "Function cancelled") (/= msg "quit / exit abort"))
      (princ (strcat "\nAW 出错：" msg))
    )
    (princ)
  )
  (setq ss (aw:get-selection))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq i 0 moved 0 clean 0 fail 0 total (sslength ss))
      (while (< i total)
        (setq en (ssname ss i))
        (setq r (aw:process-one en))
        (cond
          ((= r 1) (setq moved (1+ moved)))
          ((= r 0) (setq clean (1+ clean)))
          (T (setq fail (1+ fail)))
        )
        (setq i (1+ i))
      )
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
      (sssetfirst nil nil)
      (princ
        (strcat
          "\nAW 完成：共 " (itoa total)
          " 个文字，移动 " (itoa moved)
          " 个，原本无需移动 " (itoa clean)
          " 个，未找到合适位置 " (itoa fail) " 个。"
        )
      )
    )
    (princ "\nAW：未选中文字。")
  )
  (princ)
)

(princ)

;;; ---------------- 用户可修改参数 ----------------
(setq *TKTJ-COL-OFFSETS* '(5.0 12.0 62.0)) ; 序号列中心；图号/图名距左边线约 2
(setq *TKTJ-ROW-GAP* 9.0)                 ; 目录表每行高度
(setq *TKTJ-TEXT-HEIGHT* 4.0)
(setq *TKTJ-TEXT-STYLE* "宋体")
(setq *TKTJ-TEXT-FONTFILE* "simsun.ttc")
(setq *TKTJ-TEXT-WIDTH-FACTOR* 0.8)
(setq *TKTJ-OUTPUT-HEADER* nil)            ; 只输出正文，不生成“序号/图号/图名”表头
(setq *TKTJ-SORT-BY-POSITION* T)
(setq *TKTJ-ROW-SORT-TOL* 500.0)
(setq *TKTJ-SORT-BY-PAGE* nil)

;;; ---------------- 字段候选映射 ----------------
(setq *TKTJ-SHEETNO-TAGS*
       '("图号"))

(setq *TKTJ-SHEETNAME-TAGS*
       '("图名"))

(setq *TKTJ-PAGE-TAGS*
       '("页码" "页号" "PAGE" "SHEET"))

(setq *TKTJ-ARCHIVE-TAGS*
       '("图号" "档号" "文件号" "DWGNO" "DRAWINGNO"))

;;; ---------------- 基础工具函数 ----------------
(defun tktj:trim (s)
  (if s
    (vl-string-trim " \t\r\n" (vl-princ-to-string s))
    ""
  )
)

(defun tktj:norm-tag (s)
  ;; strcase 可处理英文大小写；中文会保持可匹配状态。
  (strcase (tktj:trim s))
)

(defun tktj:current-space (/ doc)
  ;; 在模型空间、布局图纸空间、布局视口内分别写入当前工作空间。
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (cond
    ((= 1 (getvar "TILEMODE")) (vla-get-ModelSpace doc))
    ((= 1 (getvar "CVPORT")) (vla-get-PaperSpace doc))
    (T (vla-get-ModelSpace doc))
  )
)

(defun tktj:ensure-text-style (/ doc styles style)
  ;; 优先使用“宋体”文字样式；不存在时创建，并尽量绑定宋体字体文件。
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq styles (vla-get-TextStyles doc))
  (setq style (vl-catch-all-apply 'vla-Item (list styles *TKTJ-TEXT-STYLE*)))
  (if (vl-catch-all-error-p style)
    (setq style (vl-catch-all-apply 'vla-Add (list styles *TKTJ-TEXT-STYLE*)))
  )
  (if (not (vl-catch-all-error-p style))
    (progn
      (vl-catch-all-apply 'vla-put-FontFile (list style *TKTJ-TEXT-FONTFILE*))
      (vl-catch-all-apply 'vla-put-Width (list style *TKTJ-TEXT-WIDTH-FACTOR*))
      *TKTJ-TEXT-STYLE*
    )
    (getvar "TEXTSTYLE")
  )
)

(defun tktj:safe-vla-object (ent / r)
  (setq r (vl-catch-all-apply 'vlax-ename->vla-object (list ent)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:safe-property (obj prop / r)
  (setq r (vl-catch-all-apply 'vlax-get-property (list obj prop)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:safe-getattributes (blk / r)
  (setq r (vl-catch-all-apply 'vlax-invoke (list blk 'GetAttributes)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:assoc-data (key data)
  (cdr (assoc key data))
)

(defun tktj:block-point (blockObj / p)
  (setq p (tktj:safe-property blockObj 'InsertionPoint))
  (if p
    (progn
      (setq p (vl-catch-all-apply 'vlax-safearray->list (list (vlax-variant-value p))))
      (if (vl-catch-all-error-p p)
        nil
        (list (car p) (cadr p) (if (caddr p) (caddr p) 0.0))
      )
    )
    nil
  )
)

(defun tktj:all-digits-p (s)
  (and (> (strlen s) 0)
       (not (wcmatch s "*[~0-9]*")))
)

(defun tktj:page-number (s / n)
  (setq s (tktj:trim s))
  (if (tktj:all-digits-p s)
    (progn
      (setq n (atoi s))
      n
    )
    2147483647
  )
)

;;; ---------------- 属性读取与字段提取 ----------------
(defun tktj:get-attributes (blockObj / atts att tag val result hasAtts)
  ;; 返回原始 TagString 关联表，例如 (("图名" . "xxx") ("页码" . "3"))。
  (setq result nil)
  (setq hasAtts (tktj:safe-property blockObj 'HasAttributes))
  (if (= :vlax-true hasAtts)
    (progn
      (setq atts (tktj:safe-getattributes blockObj))
      (foreach att atts
        (setq tag (tktj:safe-property att 'TagString))
        (setq val (tktj:safe-property att 'TextString))
        (setq tag (tktj:trim tag))
        (setq val (tktj:trim val))
        (if (> (strlen tag) 0)
          (setq result (append result (list (cons tag val))))
        )
      )
    )
  )
  result
)

(defun tktj:get-first-pair (attrs candidates skipTags / cand found pair tag val)
  ;; 按候选字段优先级返回 (原始Tag . 值)，可通过 skipTags 避免复用同一字段。
  (setq found nil)
  (foreach cand candidates
    (if (not found)
      (foreach pair attrs
        (if (not found)
          (progn
            (setq tag (car pair))
            (setq val (tktj:trim (cdr pair)))
            (if (and (> (strlen val) 0)
                     (= (tktj:norm-tag tag) (tktj:norm-tag cand))
                     (not (member (tktj:norm-tag tag) skipTags)))
              (setq found (cons tag val))
            )
          )
        )
      )
    )
  )
  found
)

(defun tktj:get-first-value (attrs candidates / pair)
  ;; 根据候选字段列表，从属性表中取第一个非空值。
  (setq pair (tktj:get-first-pair attrs candidates nil))
  (if pair (cdr pair) "")
)

(defun tktj:collect-one-block (blockObj / attrs namePair noPair page archive insPt)
  ;; 只有同一个块内同时找到“图号”和“图名”时，才返回一条目录数据。
  (setq attrs (tktj:get-attributes blockObj))
  (if attrs
    (progn
      (setq insPt (tktj:block-point blockObj))
      (setq namePair (tktj:get-first-pair attrs *TKTJ-SHEETNAME-TAGS* nil))
      (setq noPair (tktj:get-first-pair attrs *TKTJ-SHEETNO-TAGS* nil))
      (setq page (tktj:get-first-value attrs *TKTJ-PAGE-TAGS*))
      (setq archive (tktj:get-first-value attrs *TKTJ-ARCHIVE-TAGS*))
      (if (and noPair namePair insPt)
        (list
          (cons 'sheetNo (cdr noPair))
          (cons 'sheetName (cdr namePair))
          (cons 'page page)
          (cons 'archive archive)
          (cons 'x (car insPt))
          (cons 'y (cadr insPt))
        )
        nil
      )
    )
    nil
  )
)

;;; ---------------- 文字输出 ----------------
(defun tktj:add-text (pt txt alignMode / obj result)
  ;; 在当前空间插入带垂直居中的单行文字，图层/颜色默认 ByLayer。
  (setq obj
        (vla-AddText
          (tktj:current-space)
          (if txt (vl-princ-to-string txt) "")
          (vlax-3d-point pt)
          *TKTJ-TEXT-HEIGHT*
        )
  )
  (vla-put-Layer obj (getvar "CLAYER"))
  (vla-put-StyleName obj (tktj:ensure-text-style))
  (setq result (vl-catch-all-apply 'vla-put-Alignment (list obj alignMode)))
  (if (not (vl-catch-all-error-p result))
    (vl-catch-all-apply 'vla-put-TextAlignmentPoint
                        (list obj (vlax-3d-point pt))))
  (vl-catch-all-apply 'vla-put-ScaleFactor (list obj *TKTJ-TEXT-WIDTH-FACTOR*))
  obj
)

(defun tktj:nth-offset (n offsets / rest)
  (setq rest offsets)
  (while (and (> n 0) rest)
    (setq rest (cdr rest))
    (setq n (1- n))
  )
  (if rest (car rest) 0.0)
)

(defun tktj:draw-row (base rowIndex values / x y col pt alignMode)
  ;; base 是整个目录表左上角；文字锚点位于每行垂直中心线。
  (setq y (- (cadr base) (* (+ rowIndex 0.5) *TKTJ-ROW-GAP*)))
  (setq col 0)
  (foreach txt values
    (setq x (+ (car base) (tktj:nth-offset col *TKTJ-COL-OFFSETS*)))
    (setq pt (list x y (if (caddr base) (caddr base) 0.0)))
    ;; 序号列水平居中；图号、图名左对齐并统一垂直居中。
    (setq alignMode (if (= col 0) 10 9))
    (tktj:add-text pt txt alignMode)
    (setq col (1+ col))
  )
)

(defun tktj:take (dataList count / out rest n)
  (setq out nil rest dataList n 0)
  (while (and rest (< n count))
    (setq out (append out (list (car rest)))
          rest (cdr rest)
          n (1+ n)))
  out
)

(defun tktj:drop (dataList count / rest n)
  (setq rest dataList n 0)
  (while (and rest (< n count))
    (setq rest (cdr rest)
          n (1+ n)))
  rest
)

(defun tktj:draw-table (dataList basePt startIndex / rowIndex item values)
  ;; 根据数据列表、起点序号和基点生成一页三列目录文字。
  (setq rowIndex 0)
  (if *TKTJ-OUTPUT-HEADER*
    (progn
      (tktj:draw-row basePt rowIndex '("序号" "图号" "图名"))
      (setq rowIndex (1+ rowIndex))
    )
  )
  (foreach item dataList
    (setq values
           (list
             (itoa (+ 1 startIndex rowIndex))
             (tktj:assoc-data 'sheetNo item)
             (tktj:assoc-data 'sheetName item)
           )
    )
    (tktj:draw-row basePt rowIndex values)
    (setq rowIndex (1+ rowIndex))
  )
  dataList
)

;;; ---------------- 排序 ----------------
(defun tktj:sort-by-page (dataList)
  ;; 数字页码从小到大；非数字页码排到最后。
  (vl-sort
    dataList
    '(lambda (a b)
       (< (tktj:page-number (tktj:assoc-data 'page a))
          (tktj:page-number (tktj:assoc-data 'page b)))
     )
  )
)

(defun tktj:sort-by-position (dataList / sorted rows row rowY item y result)
  ;; 图面阅读顺序：先按上方优先分行，Y 相差容差内视为同一行；行内左侧优先。
  (setq sorted
        (vl-sort
          dataList
          '(lambda (a b / ay by)
             (setq ay (tktj:assoc-data 'y a))
             (setq by (tktj:assoc-data 'y b))
             (if (= ay by)
               (< (tktj:assoc-data 'x a)
                  (tktj:assoc-data 'x b))
               (> ay by)
             )
           )
        )
  )
  (foreach item sorted
    (setq y (tktj:assoc-data 'y item))
    (if (or (not rowY) (> (abs (- rowY y)) *TKTJ-ROW-SORT-TOL*))
      (progn
        (if row (setq rows (append rows (list row))))
        (setq row (list item))
        (setq rowY y)
      )
      (setq row (append row (list item)))
    )
  )
  (if row (setq rows (append rows (list row))))
  (foreach row rows
    (setq result
          (append
            result
            (vl-sort
              row
              '(lambda (a b)
                 (< (tktj:assoc-data 'x a)
                    (tktj:assoc-data 'x b))
               )
            )
          )
    )
  )
  result
)

;;; ---------------- 主命令 ----------------
(defun C:ZDML (/ ss i ent obj one data basePt skipped remaining pageData pageCap
                pageNo startIndex point written)
  (vl-load-com)
  (princ "\n请选择需要统计的图框块: ")
  (setq ss (ssget '((0 . "INSERT"))))
  (cond
    ((not ss)
     (princ "\n已取消。")
    )
    (T
     (setq i 0)
     (setq data nil)
     (setq skipped 0)
     (while (< i (sslength ss))
       (setq ent (ssname ss i))
       (setq obj (tktj:safe-vla-object ent))
       (setq one (if obj (tktj:collect-one-block obj) nil))
       (if one
         (setq data (append data (list one)))
         (setq skipped (1+ skipped))
       )
       (setq i (1+ i))
     )
     (if (not data)
       (princ "\n未选择有效图框块")
       (progn
         (cond
           (*TKTJ-SORT-BY-PAGE*
            (setq data (tktj:sort-by-page data))
           )
           (*TKTJ-SORT-BY-POSITION*
            (setq data (tktj:sort-by-position data))
           )
         )
         ;; 第一页最多 22 条，后续每页最多 26 条；每页分别点击目录表左上角。
         (setq remaining data
               pageNo 1
               startIndex 0
               written 0
               basePt (getpoint "\n指定第 1 页目录表左上角: "))
         (if basePt
           (progn
             (while remaining
               (setq pageCap (if (= pageNo 1) 22 26)
                     pageData (tktj:take remaining pageCap))
               (tktj:draw-table pageData basePt startIndex)
               (setq written (+ written (length pageData))
                     startIndex written
                     remaining (tktj:drop remaining pageCap))
               (if remaining
                 (progn
                   (setq pageNo (1+ pageNo)
                         point (getpoint
                           (strcat "\n指定第 " (itoa pageNo) " 页目录表左上角: ")))
                   (if point
                     (setq basePt point)
                     (setq remaining nil))))
             (if (= written (length data))
               (princ
                 (strcat
                   "\n已提取 " (itoa written)
                   " 个图框属性并生成 " (itoa pageNo) " 页目录。跳过 "
                   (itoa skipped) " 个无效或不兼容图框。"))
               (princ
                 (strcat "\n已生成前 " (itoa written)
                         " 个目录项，后续页面已取消。")))
           (princ "\n已取消。")
         )
       )
     )
    )
  )
  (princ)
)
)
)

;;; ---------------- 调试命令 ----------------
(defun C:ZDMLDEBUG (/ ent obj attrs pair)
  (vl-load-com)
  (setq ent (car (entsel "\n请选择一个图框块: ")))
  (cond
    ((not ent)
     (princ "\n已取消。")
    )
    ((/= "INSERT" (cdr (assoc 0 (entget ent))))
     (princ "\n选择对象不是块参照。")
    )
    (T
     (setq obj (vlax-ename->vla-object ent))
     (setq attrs (tktj:get-attributes obj))
     (if attrs
       (progn
         (princ "\n该块增强属性如下:")
         (foreach pair attrs
           (princ
             (strcat
               "\n属性标记: "
               (car pair)
               "  值: "
               (cdr pair)
             )
           )
         )
       )
       (princ "\n该块没有增强属性。")
     )
    )
  )
  (princ)
)

(princ)
;;;----------------------------------------------------------------------------------------
;;;
;;;                              C1 / C2 / C3 编号递增递减复制文字
;;;
;;;----------------------------------------------------------------------------------------

;;; 命令: C1 - 复制文字，优先把减号后的连续数字加 1
;;; 命令: C2 - 复制文字，优先把减号后的连续数字减 1
;;; 命令: C3 - 复制文字，优先把减号后的连续数字加 2
;;; 适用: 单行文字 TEXT、多行文字 MTEXT；不依赖项目主文件
;;; 说明: 使用CAD原生getpoint取点，优先保证对象捕捉、正交、极轴等交互体验。

(setq c1c2:*active-preview* nil)

(defun c1c2:is-digit (ch / n)
  (if (and ch (= (type ch) 'STR) (= (strlen ch) 1))
    (progn
      (setq n (ascii ch))
      (and (<= 48 n) (<= n 57))
    )
  )
)

(defun c1c2:first-number-span (s / i n start len first after last-hyphen)
  (setq i 1
        n (strlen s)
        first nil
        after nil
        last-hyphen nil)
  (while (<= i n)
    (if (= (substr s i 1) "-")
      (setq last-hyphen i)
    )
    (setq i (1+ i))
  )
  (setq i 1)
  (while (<= i n)
    (cond
      ((c1c2:is-digit (substr s i 1))
       (setq start i)
       (while (and (<= i n) (c1c2:is-digit (substr s i 1)))
         (setq i (1+ i))
       )
       (setq len (- i start))
       (if (null first)
         (setq first (list start len))
       )
       (if (and last-hyphen (> start last-hyphen) (null after))
         (setq after (list start len))
       )
      )
      (T
       (setq i (1+ i))
      )
    )
  )
  (if after after first)
)

(defun c1c2:repeat-char (ch n / out)
  (setq out "")
  (while (> n 0)
    (setq out (strcat out ch)
          n (1- n))
  )
  out
)

(defun c1c2:itoa-pad (num width / s)
  (setq s (itoa num))
  (if (and (>= num 0) (< (strlen s) width))
    (strcat (c1c2:repeat-char "0" (- width (strlen s))) s)
    s
  )
)

(defun c1c2:change-number (s delta / span start len old new pre post)
  (if (setq span (c1c2:first-number-span s))
    (progn
      (setq start (car span)
            len   (cadr span)
            old   (substr s start len)
            new   (c1c2:itoa-pad (+ (atoi old) delta) len)
            pre   (if (> start 1) (substr s 1 (1- start)) "")
            post  (if (<= (+ start len) (strlen s)) (substr s (+ start len)) ""))
      (strcat pre new post)
    )
  )
)

(defun c1c2:select-text (/ ss)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (and ss (> (sslength ss) 0))
    (ssname ss 0)
    (progn
      (princ "\n选择一个带数字的文字，回车确认: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
      (if (and ss (> (sslength ss) 0))
        (ssname ss 0)
      )
    )
  )
)

(defun c1c2:pt3 (pt)
  (cond
    ((null pt) nil)
    ((= (length pt) 2) (list (car pt) (cadr pt) 0.0))
    (T pt)
  )
)

(defun c1c2:wcs-point (pt)
  (vlax-3d-point (trans (c1c2:pt3 pt) 1 0))
)

(defun c1c2:move-object (obj from to)
  (if (and obj from to (not (equal from to 1e-8)))
    (vla-Move obj (c1c2:wcs-point from) (c1c2:wcs-point to))
  )
)

(defun c1c2:bit-set-p (mode bit)
  (= 1 (rem (fix (/ mode bit)) 2))
)

(defun c1c2:osnap-mode-string (/ mode pairs out)
  (setq mode (getvar "OSMODE")
        out "")
  (if (and mode (> mode 0) (not (c1c2:bit-set-p mode 16384)))
    (progn
      (setq pairs
        '(
          (1 . "END")
          (2 . "MID")
          (4 . "CEN")
          (8 . "NOD")
          (16 . "QUA")
          (32 . "INT")
          (64 . "INS")
          (128 . "PER")
          (256 . "TAN")
          (512 . "NEA")
          (2048 . "APP")
          (4096 . "EXT")
          (8192 . "PAR")
        )
      )
      (foreach p pairs
        (if (c1c2:bit-set-p mode (car p))
          (setq out
            (if (= out "")
              (cdr p)
              (strcat out "," (cdr p))
            )
          )
        )
      )
      (if (/= out "") out)
    )
  )
)

(defun c1c2:snap-point (pt / mode res)
  (setq pt (c1c2:pt3 pt)
        mode (c1c2:osnap-mode-string))
  (if mode
    (progn
      (setq res (vl-catch-all-apply 'osnap (list pt mode)))
      (if (and (not (vl-catch-all-error-p res)) res)
        res
        pt
      )
    )
    pt
  )
)

(defun c1c2:ortho-point (base pt / dx dy)
  (setq base (c1c2:pt3 base)
        pt   (c1c2:pt3 pt))
  (if (= 1 (getvar "ORTHOMODE"))
    (progn
      (setq dx (- (car pt) (car base))
            dy (- (cadr pt) (cadr base)))
      (if (>= (abs dx) (abs dy))
        (list (car pt) (cadr base) (caddr pt))
        (list (car base) (cadr pt) (caddr pt))
      )
    )
    pt
  )
)

(defun c1c2:target-point (base pt / snapped)
  (setq snapped (c1c2:snap-point pt))
  (if (equal snapped (c1c2:pt3 pt) 1e-8)
    (c1c2:ortho-point base snapped)
    snapped
  )
)

(defun c1c2:final-point (base pt)
  (c1c2:target-point base pt)
)

(defun c1c2:delete-preview ()
  (if c1c2:*active-preview*
    (progn
      (vl-catch-all-apply 'vla-Delete (list c1c2:*active-preview*))
      (setq c1c2:*active-preview* nil)
      (redraw)
    )
  )
)

(defun c1c2:make-preview (src txt base start / obj)
  (setq obj (vla-Copy src))
  (vla-put-TextString obj txt)
  (setq c1c2:*active-preview* obj)
  (if start
    (c1c2:move-object obj base start)
  )
  obj
)

(defun c1c2:place-one (src txt base start / obj pt)
  (setq base (c1c2:pt3 base))
  (if (setq pt (getpoint base "\n指定目标点 <回车结束>: "))
    (progn
      (setq pt (c1c2:pt3 pt)
            obj (vla-Copy src))
      (vla-put-TextString obj txt)
      (c1c2:move-object obj base pt)
      (list obj pt)
    )
  )
)

(defun c1c2:safe-end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc))
  )
)

(defun c1c2:run (delta / *error* doc en obj txt base started res start)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        started nil)
  (defun *error* (msg)
    (c1c2:delete-preview)
    (if started (c1c2:safe-end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\n错误: " msg))
    )
    (princ)
  )
  (setq en (c1c2:select-text))
  (cond
    ((null en)
     (princ "\n未选择文字。"))
    (T
     (setq obj (vlax-ename->vla-object en)
           txt (vla-get-TextString obj))
     (cond
       ((not (c1c2:first-number-span txt))
        (princ "\n选中文字中没有找到数字。"))
       ((not (setq base (getpoint "\n指定基点: ")))
        (princ "\n已取消。"))
       (T
        (vla-StartUndoMark doc)
        (setq started T
              txt (c1c2:change-number txt delta)
              start (c1c2:pt3 base))
        (while (setq res (c1c2:place-one obj txt base start))
          (setq start (cadr res)
                txt (c1c2:change-number txt delta))
        )
        (c1c2:safe-end-undo doc)
        (setq started nil)
       )
     )
    )
  )
  (princ)
)

(defun c:C1 ()
  (c1c2:run 1)
)

(defun c:C2 ()
  (c1c2:run -1)
)

(defun c:C3 ()
  (c1c2:run 2)
)

(princ)

;;;
;;; Source: 小命令\DE-DE2.lsp
;;;
(vl-load-com)

;; ============================================================
;; DE / DE2  括号处理（支持半角()、全角（）和批量选择）
;;   DE  : 删除括号及括号内容        "DS-10(11)" -> "DS-10"
;;   DE2 : 用括号内容替换括号前数字  "DS-10(11)" -> "DS-11"
;; ============================================================

;; 查找子串最后一次出现位置（0 基），无则 nil
(defun de:rfind (txt sub / pos last start)
  (setq last nil
        start 0)
  (while (setq pos (vl-string-search sub txt start))
    (setq last pos
          start (1+ pos))
  )
  last
)

;; 查找 limit 位置之前子串最后一次出现位置
(defun de:rfind-before (txt sub limit / pos last start)
  (setq last nil
        start 0)
  (while (and (setq pos (vl-string-search sub txt start))
              (< pos limit))
    (setq last pos
          start (1+ pos))
  )
  last
)

;; 去掉字符串末尾连续的半角数字，返回前缀部分
(defun de:rstrip-digits (s / n ch)
  (setq n (strlen s))
  (while (and (> n 0)
              (setq ch (substr s n 1))
              (>= (ascii ch) 48)
              (<= (ascii ch) 57))
    (setq n (1- n))
  )
  (substr s 1 n)
)

;; 返回最右侧完整括号对：（左位置 右位置 左括号 右括号）
(defun de:find-pair (txt / pa pb posR openCh closeCh posL)
  (setq pa (de:rfind txt ")")
        pb (de:rfind txt "）"))
  (cond
    ((and pa pb)
     (if (> pa pb)
       (setq posR pa openCh "(" closeCh ")")
       (setq posR pb openCh "（" closeCh "）")))
    (pa (setq posR pa openCh "(" closeCh ")"))
    (pb (setq posR pb openCh "（" closeCh "）"))
  )
  (if posR
    (setq posL (de:rfind-before txt openCh posR)))
  (if posL
    (list posL posR openCh closeCh)
    nil)
)

;; 处理单个字符串；无可处理括号时返回 nil
(defun de:strip (txt mode / pair posL posR openCh closeCh before inner after)
  (setq pair (de:find-pair txt))
  (if pair
    (progn
      (setq posL (nth 0 pair)
            posR (nth 1 pair)
            openCh (nth 2 pair)
            closeCh (nth 3 pair)
            before (substr txt 1 posL)
            inner (substr txt
                          (+ posL (strlen openCh) 1)
                          (- posR posL (strlen openCh)))
            after (substr txt (+ posR (strlen closeCh) 1)))
      (if (= mode 0)
        (strcat before after)
        (strcat (de:rstrip-digits before) inner after)))
    nil)
)

(defun de:get-text (ent / obj result)
  (setq obj (vlax-ename->vla-object ent)
        result (vl-catch-all-apply 'vla-get-TextString (list obj)))
  (if (vl-catch-all-error-p result)
    nil
    result)
)

(defun de:set-text (ent txt / obj result)
  (setq obj (vlax-ename->vla-object ent)
        result (vl-catch-all-apply 'vla-put-TextString (list obj txt)))
  (not (vl-catch-all-error-p result))
)

(defun de:end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
)

;; 批量处理单行文字、多行文字和属性文字
(defun de:run (mode / *error* doc undo-open ss i ent txt new changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)
  (defun *error* (msg)
    (if undo-open
      (de:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\n错误: " msg)))
    (princ)
  )
  (prompt "\n选择要处理的单行文字、多行文字或属性文字: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB"))))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T
            i 0
            changed 0
            skipped 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              txt (de:get-text ent)
              new (if txt (de:strip txt mode) nil))
        (cond
          ((or (null new) (= new txt)))
          ((de:set-text ent new)
           (setq changed (1+ changed)))
          (T
           (setq skipped (1+ skipped))))
        (setq i (1+ i))
      )
      (de:end-undo doc)
      (setq undo-open nil)
      (redraw)
      (princ (strcat "\n已处理 " (itoa changed) " 个文字"))
      (if (> skipped 0)
        (princ (strcat "，" (itoa skipped) " 个文字写入失败")))
    )
    (princ "\n未选中文字")
  )
  (princ)
)

(defun c:DE () (de:run 0))
(defun c:DE2 () (de:run 1))

(princ)

;;;
;;; Command: GE
;;; Purpose: Draw one table row around selected horizontal single-line TEXT objects.
;;;          Text is sorted left-to-right; dividers use the midpoint of each clear gap.
;;;
(vl-load-com)

(defun ge:end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
)

(defun ge:text-point-wcs (en ed / p)
  (setq p
    (if (or (/= 0 (if (assoc 72 ed) (cdr (assoc 72 ed)) 0))
            (/= 0 (if (assoc 73 ed) (cdr (assoc 73 ed)) 0)))
      (cdr (assoc 11 ed))
      (cdr (assoc 10 ed))))
  (if p (trans p en 0))
)

(defun ge:get-item (en / ed obj result minpt maxpt p rot)
  (setq ed  (entget en)
        rot (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0))
  (if (and (= "TEXT" (cdr (assoc 0 ed)))
           (equal (sin rot) 0.0 1e-6)
           (setq p (ge:text-point-wcs en ed)))
    (progn
      (setq obj    (vlax-ename->vla-object en)
            result (vl-catch-all-apply
                     'vla-GetBoundingBox
                     (list obj 'minpt 'maxpt)))
      (if (not (vl-catch-all-error-p result))
        (progn
          (setq minpt (vlax-safearray->list minpt)
                maxpt (vlax-safearray->list maxpt))
          (list
            (car minpt)
            (car maxpt)
            (cadr minpt)
            (cadr maxpt)
            (/ (+ (car minpt) (car maxpt)) 2.0)
            (cadr p)
            (max 1e-6 (- (cadr maxpt) (cadr minpt)))
            en)))))
)

(defun ge:insert-item (item items)
  (cond
    ((null items) (list item))
    ((< (nth 4 item) (nth 4 (car items))) (cons item items))
    (T (cons (car items) (ge:insert-item item (cdr items)))))
)

(defun ge:sort-items (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (ge:insert-item item out)))
  out
)

(defun ge:make-line (layer p1 p2 / en old)
  (setq en
    (entmakex
      (list
        '(0 . "LINE")
        (cons 8 layer)
        (cons 10 p1)
        (cons 11 p2))))
  (if en
    (setq created (cons en created))
    (progn
      (foreach old created
        (if (entget old) (entdel old)))
      (setq created nil)
      (error "GE 无法创建表格线。")))
  en
)

(defun c:GE (/ *error* doc undo-open ss i en item items bad maxh row-y row-tol
               prev rest cur overlap left right bottom top pad z layer created)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        created   nil)

  (defun *error* (msg)
    (if undo-open
      (ge:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\nGE 错误: " msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (or (null ss) (= 0 (sslength ss)))
    (progn
      (princ "\n[GE] 请选择同一水平行的单行文字: ")
      (setq ss (ssget "_:L" '((0 . "TEXT"))))))

  (cond
    ((or (null ss) (= 0 (sslength ss)))
     (princ "\n[GE] 未选择单行文字。"))
    (T
     (setq i 0 items nil bad 0 maxh 0.0)
     (repeat (sslength ss)
       (setq en   (ssname ss i)
             item (ge:get-item en))
       (if item
         (progn
           (setq items (cons item items))
           (if (> (nth 6 item) maxh)
             (setq maxh (nth 6 item))))
         (setq bad (1+ bad)))
       (setq i (1+ i)))

     (cond
       ((> bad 0)
        (princ "\n[GE] 选择中包含旋转或无法读取的单行文字，未绘制表格。"))
       ((null items)
        (princ "\n[GE] 没有找到可用的单行文字。"))
       (T
        (setq items   (ge:sort-items items)
              row-y   (nth 5 (car items))
              row-tol (max 1e-5 (* maxh 0.25))
              overlap nil
              prev    nil
              left    (nth 0 (car items))
              right   (nth 1 (car items))
              bottom  (nth 2 (car items))
              top     (nth 3 (car items)))

        (foreach cur items
          (if (> (abs (- (nth 5 cur) row-y)) row-tol)
            (setq bad (1+ bad)))
          (if (and prev (<= (nth 0 cur) (+ (nth 1 prev) 1e-6)))
            (setq overlap T))
          (setq right  (max right  (nth 1 cur))
                bottom (min bottom (nth 2 cur))
                top    (max top    (nth 3 cur))
                prev   cur))

        (cond
          ((> bad 0)
           (princ "\n[GE] 所选文字不在同一水平行，未绘制表格。"))
          (overlap
           (princ "\n[GE] 相邻文字的外包框横向重叠，无法安全绘制分隔线。"))
          (T
           (setq pad    (* maxh 0.5)
                 left   (- left pad)
                 right  (+ right pad)
                 bottom (- bottom pad)
                 top    (+ top pad)
                 z      (caddr (trans (cdr (assoc 10 (entget (nth 7 (car items)))))
                                      (nth 7 (car items)) 0))
                 layer  (getvar "CLAYER"))
           (vl-catch-all-apply 'vla-StartUndoMark (list doc))
           (setq undo-open T)

           (ge:make-line layer (list left bottom z) (list right bottom z))
           (ge:make-line layer (list right bottom z) (list right top z))
           (ge:make-line layer (list right top z) (list left top z))
           (ge:make-line layer (list left top z) (list left bottom z))

           (setq prev (car items)
                 rest (cdr items))
           (while rest
             (setq cur (car rest)
                   i   (/ (+ (nth 1 prev) (nth 0 cur)) 2.0))
             (ge:make-line layer (list i bottom z) (list i top z))
             (setq prev cur
                   rest (cdr rest)))

           (ge:end-undo doc)
           (setq undo-open nil)
           (redraw)
           (princ
             (strcat "\n[GE] 已生成表格，单元格数: "
                     (itoa (length items))
                     "。"))))))))
  (princ)
)

(princ)

;;; =======================================================================================
;;; BEGIN IMPORT: UT.lsp
;;; =======================================================================================
(defun ut:abs (x)
  (if (< x 0.0) (- x) x)
)

(defun ut:horizontal-line-p (ename / ed p1 p2 dx dy ang)
  (setq ed (entget ename)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (if (and p1 p2)
    (progn
      (setq dx (ut:abs (- (car p1) (car p2)))
            dy (ut:abs (- (cadr p1) (cadr p2)))
            ang (* *UT_TiltAngle* (/ pi 180.0)))
      ;; 倾斜角不超过 *UT_TiltAngle* 度即视为水平直线
      (and (> dx 1e-12)
           (<= dy (* dx (/ (sin ang) (cos ang))))))
    nil)
)

(defun ut:line-y (ename / ed p1 p2)
  (setq ed (entget ename)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (/ (+ (cadr p1) (cadr p2)) 2.0)
)

(defun ut:get-bbox (ename / obj minp maxp result)
  (setq obj (vlax-ename->vla-object ename))
  (setq result
    (vl-catch-all-apply 'vla-getboundingbox (list obj 'minp 'maxp)))
  (if (vl-catch-all-error-p result)
    nil
    (list (vlax-safearray->list minp)
          (vlax-safearray->list maxp)))
)

(defun ut:bbox-left (bbox)
  (car (car bbox))
)

(defun ut:bbox-bottom (bbox)
  (cadr (car bbox))
)

(defun ut:insert-desc (item items / y out done)
  (setq y (cadr item)
        out nil
        done nil)
  (while items
    (if (and (not done) (> y (cadr (car items))))
      (progn
        (setq out (cons item out))
        (setq done T)))
    (setq out (cons (car items) out)
          items (cdr items)))
  (if (not done)
    (setq out (cons item out)))
  (reverse out)
)

(defun ut:sort-desc (items / out)
  (setq out nil)
  (while items
    (setq out (ut:insert-desc (car items) out)
          items (cdr items)))
  out
)

(defun ut:move (ename dx dy / obj result)
  (if (and ename (or (not (equal dx 0.0 1e-10))
                     (not (equal dy 0.0 1e-10))))
    (progn
      (setq obj (vlax-ename->vla-object ename)
            result
              (vl-catch-all-apply
                'vla-move
                (list obj
                      (vlax-3d-point '(0.0 0.0 0.0))
                      (vlax-3d-point (list dx dy 0.0)))))
      (not (vl-catch-all-error-p result)))
    T)
)

(defun c:UT (/ *error* doc undo-open oldcmdecho ss i en ed typ
              lines texts line-items text-items line-count text-count
              pair-count base-line base-text base-bbox base-left base-gap
              line-item text-item line-y text-bbox target-left target-bottom
              dx dy changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        lines nil
        texts nil
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[UT] 错误：" msg)))
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[UT] 请选择水平直线和其上方的文字：")
      (setq ss (ssget "_:L" '((0 . "LINE,TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              typ (cdr (assoc 0 ed)))
        (cond
          ((and (= typ "LINE") (ut:horizontal-line-p en))
           (setq lines (cons en lines)))
          ((and (or (= typ "TEXT") (= typ "MTEXT"))
                (ut:get-bbox en))
           (setq texts (cons en texts)))
        )
        (setq i (1+ i)))

      (setq line-items nil)
      (foreach en lines
        (setq line-items (cons (list en (ut:line-y en)) line-items)))
      (setq line-items (ut:sort-desc line-items))

      (setq text-items nil)
      (foreach en texts
        ;; 先统一文字为左中对正，再读取包围盒进行配对。
        (aa:normalize-text-horizontal-align doc en 1)
        (setq text-bbox (ut:get-bbox en))
        (if text-bbox
          (setq text-items
                (cons (list en (ut:bbox-bottom text-bbox) text-bbox)
                      text-items))))
      (setq text-items (ut:sort-desc text-items))

      (setq line-count (length line-items)
            text-count (length text-items)
            pair-count (min line-count text-count))
      (cond
        ((= line-count 0)
         (princ "\n[UT] 未找到水平直线。"))
        ((= text-count 0)
         (princ "\n[UT] 未找到有效的 TEXT/MTEXT 文字。"))
        (T
         (setq base-line (car line-items)
               base-text (car text-items)
               base-bbox (caddr base-text)
               base-left (ut:bbox-left base-bbox)
               base-gap (- (cadr base-text) (cadr base-line))
               oldcmdecho (getvar "CMDECHO"))
         (setvar "CMDECHO" 0)
         (vl-catch-all-apply 'vla-StartUndoMark (list doc))
         (setq undo-open T)
         (repeat pair-count
           (setq line-item (car line-items)
                 text-item (car text-items)
                 line-y (cadr line-item)
                 text-bbox (caddr text-item)
                 target-left base-left
                 target-bottom (+ line-y base-gap)
                 dx (- target-left (ut:bbox-left text-bbox))
                 dy (- target-bottom (ut:bbox-bottom text-bbox)))
           (if (ut:move (car text-item) dx dy)
             (if (or (not (equal dx 0.0 1e-10))
                     (not (equal dy 0.0 1e-10)))
               (setq changed (1+ changed)))
             (setq skipped (1+ skipped)))
           (setq line-items (cdr line-items)
                 text-items (cdr text-items)))
         (redraw)
         (vl-catch-all-apply 'vla-EndUndoMark (list doc))
         (setq undo-open nil)
         (setvar "CMDECHO" oldcmdecho)
         (setq oldcmdecho nil)
         (princ
           (strcat
             "\n[UT] 整理完成：处理 " (itoa pair-count) " 对，移动 "
             (itoa changed) " 个文字。"
             (if (/= line-count text-count)
               (strcat " 选中的直线(" (itoa line-count) ")与文字("
                       (itoa text-count) ")数量不一致，按较少数量配对。")
               ""))))))
    (princ "\n[UT] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)



(princ)

;;; 0.lsp
;;; 命令 0：将所选对象中的文字旋转角度统一改为 0 度。

(vl-load-com)

(defun c:0 (/ ss index entity data entity-type changed failed)
  (setq changed 0
        failed  0)
  (prompt "\n请选择要处理的对象：")
  (if (setq ss (ssget))
    (progn
      (setq index 0)
      (repeat (sslength ss)
        (setq entity      (ssname ss index)
              data        (entget entity)
              entity-type (cdr (assoc 0 data)))
        (if (member entity-type '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
          (if
            (entmod
              (if (assoc 50 data)
                (subst (cons 50 0.0) (assoc 50 data) data)
                (append data (list (cons 50 0.0)))))
            (setq changed (1+ changed))
            (setq failed (1+ failed))))
        (setq index (1+ index)))
      (redraw)
      (prompt
        (strcat
          "\n已将 "
          (itoa changed)
          " 个文字对象的旋转角度改为 0 度。"))
      (if (> failed 0)
        (prompt
          (strcat
            " 另有 "
            (itoa failed)
            " 个文字对象修改失败。"))))
    (prompt "\n未选择对象。"))
  (princ))

(princ)



;;; QZ.lsp
;;; 检测当前图纸中的所有组，并立即取消全部分组；组内图元保持不变。

(vl-load-com)

(defun c:QZ (/ *error* doc groups group-list group-object total success failed undo-open result)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        groups (vla-get-Groups doc)
        undo-open nil)

  (defun *error* (message)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and message
             (/= message "Function cancelled")
             (/= message "quit / exit abort"))
      (princ (strcat "\n[QZ] 执行失败：" message)))
    (princ))

  ;; 先保存组对象，避免删除时改变正在遍历的集合。
  (vlax-for group-object groups
    (setq group-list (cons group-object group-list)))
  (setq total (length group-list))

  (if (= total 0)
    (princ "\n[QZ] 当前图纸中没有检测到任何组。")
    (progn
      (vla-StartUndoMark doc)
      (setq undo-open T
            success 0
            failed 0)
      (foreach group-object group-list
        (setq result
          (vl-catch-all-apply 'vla-Delete (list group-object)))
        (if (vl-catch-all-error-p result)
          (setq failed (1+ failed))
          (setq success (1+ success))))
      (vla-EndUndoMark doc)
      (setq undo-open nil)
      (vla-Regen doc 1)
      (princ
        (strcat
          "\n[QZ] 检测到 " (itoa total) " 个组，成功取消 "
          (itoa success) " 个组"
          (if (> failed 0)
            (strcat "，失败 " (itoa failed) " 个。")
            "。")))
      (princ "\n组内图元未被删除，可使用 Ctrl+Z 撤销。")))
  (princ))

(princ)

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: DL1.lsp
;;; =======================================================================================
;; ============================================================
;; DL1  创建电缆柜、电缆路径、电缆竖井相关 1F / 2F 图层
;; 依赖：仅使用 CAD 内置 AutoLISP 函数，无外部依赖。
;; ============================================================

(defun dl1:make-layer (name /)
  (if (not (tblsearch "LAYER" name))
    (entmake
      (list
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 name)
        '(70 . 0)
        '(62 . 7)
        '(6 . "Continuous")
      )
    )
  )
)

(defun c:DL1 (/ layers)
  (setq layers
    '(
      "CABLE_CABINET_1F"
      "CABLE_CABINET_2F"
      "CABLE_ROUTE_1F"
      "CABLE_ROUTE_2F"
      "CABLE_SHAFT_1F"
      "CABLE_SHAFT_2F"
    )
  )
  (foreach lay layers
    (dl1:make-layer lay)
  )
  (princ "\nDL1：已检查并创建 6 个电缆相关图层。")
  (princ)
)

(princ "\nDL1 命令已加载，输入 DL1 创建电缆相关图层。")
(princ)
;;; END INTEGRATED SOURCE: DL1.lsp

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: REP.lsp
;;; =======================================================================================
;;; REP.lsp  柜名标准化替换命令
;;; 命令 REP：选择若干单行/多行文字，将其内容（柜名）替换为标准柜名。
;;; 映射表已内置于本文件（原始数据来自文字替换.xlsx：A列=原柜名，B列=标准柜名）
;;; 匹配规则：去除文字首尾空格后，与原柜名整体精确匹配，命中则整体替换为标准柜名。

(defun rep-trim (s)
  (if (null s) (setq s ""))
  (while (and (> (strlen s) 0)
              (member (substr s 1 1) (list " " "\t")))
    (setq s (substr s 2)))
  (while (and (> (strlen s) 0)
              (member (substr s (strlen s) 1) (list " " "\t")))
    (setq s (substr s 1 (1- (strlen s)))))
  s)

(defun c:REP ( / ss i en obj str key pair cnt miss table)
  (vl-load-com)
  (setq table
    (list
      (cons "#2直流馈线柜" "直流馈线柜2")
      (cons "1#直流馈线柜" "直流馈线柜1")
      (cons "#1直流馈线柜" "直流馈线柜1")
      (cons "#2配网综合故障管控PT柜" "10kV#2配网综合故障管控PT柜")
      (cons "#1配网综合故障管控PT柜" "10kV#1配网综合故障管控PT柜")
      (cons "#1主变10kV侧开关柜" "10kV#1主变进线柜")
      (cons "#2主变10kV侧开关柜" "10kV#2主变进线柜")
      (cons "#2配网综合故障管控接地柜" "10kV#2配网综合故障管控接地柜")
      (cons "#1配网综合故障管控接地柜" "10kV#1配网综合故障管控接地柜")
      (cons "#1主变测控柜" "主变测控柜1")
      (cons "#2主变测控柜" "主变测控柜2")
      (cons "#1主变保护柜" "主变保护柜1")
      (cons "#2主变保护柜" "主变保护柜2")
      (cons "#1SVG控制柜" "10kV#1SVG控制柜")
      (cons "#2SVG控制柜" "10kV#2SVG控制柜")
      (cons "10kV#1电容出线柜" "10kV#1电容器出线柜")
      (cons "10kV#2电容出线柜" "10kV#2电容器出线柜")
      (cons "#1电容器" "10kV#1电容器")
      (cons "#2电容器" "10kV#2电容器")
      (cons "调度数据专网柜1" "调度数据网柜1")
      (cons "调度数据专网柜2" "调度数据网柜2")
      (cons "10kV 分段柜" "10kV分段柜")
      (cons "110kV 母线智能汇控柜" "110kV母线智能汇控柜")
      (cons "1#主变保护柜" "主变保护柜1")
      (cons "2#主变保护柜" "主变保护柜2")
      (cons "2#直流馈线柜" "直流馈线柜2")
      (cons "逆功率保护及电能质量在线监测柜" "逆功率保护及电能质量监测柜")
      (cons "逆功率保护及电能质量检测柜" "逆功率保护及电能质量监测柜")
      (cons "时钟同步柜" "时间同步柜")
      (cons "GIS#1主变间隔汇控柜" "#1主变110kV智能控制柜")
      (cons "GIS#2主变间隔汇控柜" "#2主变110kV智能控制柜")
      (cons "GIS线路间隔汇控柜" "110kV线路智能汇控柜")
      (cons "10kV#1电容器开关柜" "10kV#1电容器出线柜")
      (cons "10kV#2电容器开关柜" "10kV#2电容器出线柜")
      (cons "GISPT间隔汇控柜" "110kV母线智能汇控柜")
      (cons "10kV分段隔离柜" "10kV隔离柜")
      (cons "10kV1#SVG开关柜" "10kV#1SVG出线柜")
      (cons "10kV2#SVG开关柜" "10kV#2SVG出线柜")
      (cons "#1主变中性点成套装置" "#1主变中性点隔离开关机构")
      (cons "#2主变中性点成套装置" "#2主变中性点隔离开关机构")
      (cons "#1主变有载开关" "#1主变有载调压端子箱")
      (cons "#2主变有载开关" "#2主变有载调压端子箱")
      (cons "#1主变风冷控制柜1" "#1主变风冷控制柜")
      (cons "#1主变风冷控制柜2" "#1主变风冷控制柜")
      (cons "#2主变风冷控制柜1" "#2主变风冷控制柜")
      (cons "#2主变风冷控制柜2" "#2主变风冷控制柜")
      (cons "#1主变油色谱在线监测主机" "#1主变油色谱就地柜")
      (cons "#2主变油色谱在线监测主机" "#2主变油色谱就地柜")
      (cons "在线监测后台主机" "在线监测后台柜")
      (cons "主变油色谱在线监测后台主机柜" "在线监测后台柜")
      (cons "110kV进线间隔GIS汇控柜" "110kV线路智能汇控柜")
      (cons "110kVPT间隔GIS汇控柜" "110kV母线智能汇控柜")
      (cons "#1电容器组" "10kV#1电容器")
      (cons "#2电容器组" "10kV#2电容器")
      (cons "10kV#1电容器组" "10kV#1电容器")
      (cons "10kV#2电容器组" "10kV#2电容器")
      (cons "10kV#1电容器端子箱" "10kV#1电容器")
      (cons "10kV#2电容器端子箱" "10kV#2电容器")
      (cons "#1-1储能并网柜" "10kV#1-1储能出线柜")
      (cons "#1-2储能并网柜" "10kV#1-2储能出线柜")
      (cons "#1-3储能并网柜" "10kV#1-3储能出线柜")
      (cons "#1-4储能并网柜" "10kV#1-4储能出线柜")
      (cons "#2-1储能并网柜" "10kV#2-1储能出线柜")
      (cons "2-2#储能并网柜" "10kV#2-2储能出线柜")
      (cons "#2-3储能并网柜" "10kV#2-3储能出线柜")
      (cons "#2-4储能并网柜" "10kV#2-4储能出线柜")
    )
  )
  (princ "\n请选择要替换的文字（单行文字/多行文字）：")
  (setq ss (ssget (list (cons 0 "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq cnt 0 miss 0 i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        (setq obj (vlax-ename->vla-object en))
        (setq str (vlax-get obj (quote TextString)))
        (setq key (rep-trim str))
        (setq pair (assoc key table))
        (if pair
          (progn
            (vlax-put obj (quote TextString) (cdr pair))
            (setq cnt (1+ cnt)))
          (setq miss (1+ miss)))
        (setq i (1+ i)))
      (princ (strcat "\n替换完成：成功 " (itoa cnt) " 个，未匹配 " (itoa miss) " 个。")))
    (princ "\n未选择任何文字。"))
  (princ)
)
(princ "\nREP 柜名标准化替换命令已加载，输入 REP 运行。")
(princ)
;;; END INTEGRATED SOURCE: REP.lsp

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: ZJ.lsp
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; 将选择集中的 LWPOLYLINE/POLYLINE 分解为 LINE，返回全部 LINE 实体列表
(defun aa:explode-collect-lines (ss / oldcmd plines all-lines i en ed typ
                                 pl-ss before cur)
  (setq plines nil
        all-lines nil
        i 0)
  (repeat (sslength ss)
    (setq en (ssname ss i)
          ed (entget en)
          typ (cdr (assoc 0 ed)))
    (cond
      ((= typ "LINE")
       (setq all-lines (cons en all-lines)))
      ((member typ '("LWPOLYLINE" "POLYLINE"))
       (setq plines (cons en plines))))
    (setq i (1+ i)))
  (if plines
    (progn
      (setq oldcmd (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (setq pl-ss (ssadd))
      (foreach en plines
        (ssadd en pl-ss))
      (setq before (entlast))
      (command "_.explode" pl-ss "")
      ;; 个别 CAD 版本不接受选择集参数时，逐个兜底分解
      (foreach en plines
        (if (entget en)
          (command "_.explode" en)))
      ;; 收集分解产生的新 LINE
      (setq cur (if before (entnext before) (entnext)))
      (while cur
        (if (= "LINE" (cdr (assoc 0 (entget cur))))
          (setq all-lines (cons cur all-lines)))
        (setq cur (entnext cur)))
      (setvar "CMDECHO" oldcmd)))
  all-lines)


;;; ZJ：为多条水平直线左端补齐连接线，并在左侧生成矩形（选中多段线时自动分解为直线）。
(defun c:ZJ (/ *error* doc undo-open oldcmd oldct ss all-lines i en ed p1 p2 left
              left-points min-left-x min-y max-y base-z valid
              joint-x left-x height center-y bottom top rect1 rect2
              created failed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmd nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[ZJ] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if (null ss)
    (progn
      (princ "\n[ZJ] 请选择水平直线或多段线（多段线将自动分解）：")
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))

  (if ss
    (progn
      ;; 多段线先分解为直线；分解与后续生成放在同一个撤销标记内
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T)
      (setq all-lines (aa:explode-collect-lines ss))
      (if (>= (length all-lines) 2)
        (progn
          (setq i 0
                left-points nil
                min-left-x nil
                min-y nil
                max-y nil
                base-z nil
                valid T)
          (foreach en all-lines
            (setq ed (entget en)
                  p1 (cdr (assoc 10 ed))
                  p2 (cdr (assoc 11 ed)))
            (if (and p1 p2
                     (equal (cadr p1) (cadr p2) 1e-8)
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-8))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-8))
              (progn
                (setq left (if (<= (car p1) (car p2)) p1 p2))
                (if (null base-z)
                  (setq base-z (if (caddr left) (caddr left) 0.0)))
                (setq left-points (cons left left-points)
                      min-left-x (if min-left-x (min min-left-x (car left)) (car left))
                      min-y (if min-y (min min-y (cadr left)) (cadr left))
                      max-y (if max-y (max max-y (cadr left)) (cadr left))))
              (setq valid nil)))

          (if valid
            (progn
              (setq joint-x (- min-left-x 10.0)
                    left-x (- joint-x 12.0)
                    height (max 20.0 (+ (- max-y min-y) 4.0))
                    center-y (/ (+ min-y max-y) 2.0)
                    bottom (- center-y (/ height 2.0))
                    top (+ center-y (/ height 2.0))
                    rect1 (list left-x bottom base-z)
                    rect2 (list joint-x top base-z)
                    oldcmd (getvar "CMDECHO")
                    created 0
                    failed 0)
              (setvar "CMDECHO" 0)
              (if (not (tblsearch "LTYPE" "HIDDEN2"))
                (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))
              (setq oldct (getvar "CELTYPE"))
              (setvar "CELTYPE" "HIDDEN2")

              (foreach left left-points
                (if (entmakex
                      (list '(0 . "LINE")
                            (cons 8 (getvar "CLAYER"))
                            (cons 10 left)
                            (cons 11 (list joint-x (cadr left) base-z))))
                  (setq created (1+ created))
                  (setq failed (1+ failed))))

              (command "_.RECTANG" "_non" rect1 "_non" rect2)
              (redraw)
              (setvar "CELTYPE" oldct)
              (setvar "CMDECHO" oldcmd)
              (setq oldcmd nil)
              (princ
                (strcat "\n[ZJ] 已为 " (itoa created) " 条水平直线生成左侧连接线和矩形，矩形宽 12、高 "
                        (rtos height 2 2) "。"
                        (if (> failed 0)
                          (strcat " 有 " (itoa failed) " 条连接线生成失败。")
                          ""))))
            (princ "\n[ZJ] 所选直线必须全部水平且位于同一标高。")))
        (princ "\n[ZJ] 分解后至少需要两条水平直线。"))
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
      (setq undo-open nil))
    (princ "\n[ZJ] 必须选择直线或多段线。"))
  (sssetfirst nil nil)
  (princ)
)


(princ)
;;; END INTEGRATED SOURCE: ZJ.lsp

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: YJ.lsp
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; YJ：为多条水平直线右端补齐连接线，并在右侧生成矩形（选中多段线时自动分解为直线）。

(defun c:YJ (/ *error* doc undo-open oldcmd oldct ss all-lines i en ed p1 p2 right
              right-points max-right-x min-y max-y base-z valid
              joint-x right-x height center-y bottom top rect1 rect2
              created failed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmd nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[YJ] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if (null ss)
    (progn
      (princ "\n[YJ] 请选择水平直线或多段线（多段线将自动分解）：")
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))

  (if ss
    (progn
      ;; 多段线先分解为直线；分解与后续生成放在同一个撤销标记内
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T)
      (setq all-lines (aa:explode-collect-lines ss))
      (if (>= (length all-lines) 2)
        (progn
          (setq i 0
                right-points nil
                max-right-x nil
                min-y nil
                max-y nil
                base-z nil
                valid T)
          (foreach en all-lines
            (setq ed (entget en)
                  p1 (cdr (assoc 10 ed))
                  p2 (cdr (assoc 11 ed)))
            (if (and p1 p2
                     (equal (cadr p1) (cadr p2) 1e-8)
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-8))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-8))
              (progn
                (setq right (if (>= (car p1) (car p2)) p1 p2))
                (if (null base-z)
                  (setq base-z (if (caddr right) (caddr right) 0.0)))
                (setq right-points (cons right right-points)
                      max-right-x (if max-right-x (max max-right-x (car right)) (car right))
                      min-y (if min-y (min min-y (cadr right)) (cadr right))
                      max-y (if max-y (max max-y (cadr right)) (cadr right))))
              (setq valid nil)))

          (if valid
            (progn
              (setq joint-x (+ max-right-x 10.0)
                    right-x (+ joint-x 12.0)
                    height (max 20.0 (+ (- max-y min-y) 4.0))
                    center-y (/ (+ min-y max-y) 2.0)
                    bottom (- center-y (/ height 2.0))
                    top (+ center-y (/ height 2.0))
                    rect1 (list joint-x bottom base-z)
                    rect2 (list right-x top base-z)
                    oldcmd (getvar "CMDECHO")
                    created 0
                    failed 0)
              (setvar "CMDECHO" 0)
              (if (not (tblsearch "LTYPE" "HIDDEN2"))
                (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))
              (setq oldct (getvar "CELTYPE"))
              (setvar "CELTYPE" "HIDDEN2")

              (foreach right right-points
                (if (entmakex
                      (list '(0 . "LINE")
                            (cons 8 (getvar "CLAYER"))
                            (cons 10 right)
                            (cons 11 (list joint-x (cadr right) base-z))))
                  (setq created (1+ created))
                  (setq failed (1+ failed))))

              (command "_.RECTANG" "_non" rect1 "_non" rect2)
              (redraw)
              (setvar "CELTYPE" oldct)
              (setvar "CMDECHO" oldcmd)
              (setq oldcmd nil)
              (princ
                (strcat "\n[YJ] 已为 " (itoa created) " 条水平直线生成右侧连接线和矩形，矩形宽 12、高 "
                        (rtos height 2 2) "。"
                        (if (> failed 0)
                          (strcat " 有 " (itoa failed) " 条连接线生成失败。")
                          ""))))
            (princ "\n[YJ] 所选直线必须全部水平且位于同一标高。")))
        (princ "\n[YJ] 分解后至少需要两条水平直线。"))
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
      (setq undo-open nil))
    (princ "\n[YJ] 必须选择直线或多段线。"))
  (sssetfirst nil nil)
  (princ)
)


(princ)
;;; END INTEGRATED SOURCE: YJ.lsp

;;; =======================================================================================
;;; BEGIN XX: 将选中文字替换为固定内容 7×2.5
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; XX：将选中文字内容替换为 "7×2.5"（预选优先，未预选则点选）。

(defun c:XX (/ ss en obj cnt i)
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n请点选要替换为 7×2.5 的文字：")
      (setq en (entsel))
      (if en
        (setq ss (ssadd (car en))))))
  (if ss
    (progn
      (setq cnt 0 i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i)
              obj (vlax-ename->vla-object en))
        (if (member (strcase (vla-get-ObjectName obj))
                    '("ACDBTEXT" "ACDBMTEXT"))
          (progn
            (vlax-put obj (quote TextString) "7×2.5")
            (setq cnt (1+ cnt))))
        (setq i (1+ i)))
      (redraw)
      (princ (strcat "\n[XX] 已把 " (itoa cnt) " 个文字替换为 7×2.5。")))
    (princ "\n[XX] 未选择文字。"))
  (sssetfirst nil nil)
  (princ)
)
;;; =======================================================================================
;;; 命令: DAO
;;; 功能: 将选中的从上到下排列的文字顺序颠倒：最下面的文字放到最上面，
;;;       从下往上倒数第二个变成从上往下第二个，其余依此类推。
;;; =======================================================================================

;;; 判断 item 是否应排在 other 之前（Y 大在前；同一行 X 小在前）
(defun dao:upper-p (item other / y1 y2)
  (setq y1 (cadr (cadr item))
        y2 (cadr (cadr other)))
  (if (equal y1 y2 1e-6)
    (< (car (cadr item)) (car (cadr other)))
    (> y1 y2)
  )
)

;;; 把 item 插入已排序列表（保持 Y 降序、同行 X 升序）
(defun dao:insert-sorted (item sorted / result done)
  (setq result '()
        done   nil)
  (while (and sorted (not done))
    (if (dao:upper-p item (car sorted))
      (setq done T)
      (progn
        (setq result (append result (list (car sorted))))
        (setq sorted (cdr sorted))
      )
    )
  )
  (append result (list item) sorted)
)

;;; 平移文字：entmod 修改组码 10（TEXT 若有 11 对齐点则同步平移）
(defun dao:move-text (ename dx dy / ed p10 p11 ok)
  (setq ed (entget ename))
  (if (and ed (setq p10 (cdr (assoc 10 ed))))
    (progn
      (setq ed
        (subst
          (cons 10
                (list (+ (car p10) dx)
                      (+ (cadr p10) dy)
                      (if (caddr p10) (caddr p10) 0.0)))
          (assoc 10 ed)
          ed))
      (if (assoc 11 ed)
        (progn
          (setq p11 (cdr (assoc 11 ed)))
          (setq ed
            (subst
              (cons 11
                    (list (+ (car p11) dx)
                          (+ (cadr p11) dy)
                          (if (caddr p11) (caddr p11) 0.0)))
              (assoc 11 ed)
              ed))))
      (setq ok (entmod ed))
      (if ok
        (progn
          (entupd ename)
          T)
        nil))
    nil)
)

(defun c:DAO (/ *error* doc undo-open ss i ename ed typ p10 lst sorted n
               cur target dx dy moved skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        moved     0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\n[DAO] 错误: " msg))
    )
    (princ)
  )

  (princ "\n[DAO] 请选择要颠倒排列的文字 (TEXT/MTEXT): ")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      ;; 1. 收集每个文字及其插入点（组码 10）
      (setq lst '()
            i   0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              ed    (entget ename)
              typ   (cdr (assoc 0 ed))
              p10   (cdr (assoc 10 ed)))
        (if (and p10 (or (= typ "TEXT") (= typ "MTEXT")))
          (setq lst (cons (list ename p10) lst))
          (setq skipped (1+ skipped))
        )
        (setq i (1+ i))
      )

      ;; 2. 插入排序：从上到下（Y 大在前，同一行 X 小在前）
      (setq sorted '())
      (foreach item lst
        (setq sorted (dao:insert-sorted item sorted))
      )
      (setq n (length sorted))

      (if (< n 2)
        (princ "\n[DAO] 有效文字不足 2 个，无需颠倒。")
        (progn
          (vla-startundomark doc)
          (setq undo-open T
                i         0)
          ;; 3. 第 i 个（从上到下）文字移到第 n-1-i 个文字的位置，实现上下颠倒
          (foreach item sorted
            (setq ename  (car item)
                  cur    (cadr item)
                  target (cadr (nth (- n 1 i) sorted))
                  dx     (- (car target) (car cur))
                  dy     (- (cadr target) (cadr cur)))
            (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
              (setq moved (1+ moved))
              (if (dao:move-text ename dx dy)
                (setq moved (1+ moved))
                (setq skipped (1+ skipped))
              )
            )
            (setq i (1+ i))
          )
          (vla-endundomark doc)
          (setq undo-open nil)
          (princ
            (strcat
              "\n[DAO] 完成：共颠倒 " (itoa n) " 个文字，已处理 " (itoa moved)
              " 个，跳过 " (itoa skipped) " 个。"))
        )
      )
    )
    (princ "\n[DAO] 未选择任何文字对象。")
  )
  (princ)
)
(princ "\n[DAO] 文字上下颠倒命令已加载，选中文字后输入 DAO 运行。")
;;; =======================================================================================
;;; 命令: QH
;;; 功能: 只选中已选文字所在行的所有文字（参考文字跨多行时逐行选择）；仅当前屏幕内、参考文字范围左右各 1000 绘图单位内寻找。
;;; =======================================================================================
(defun c:QH (/ *error* ss i ename ed ins x y h
             xmin xmax n ref-list sorted-ref rows
             last last-avg last-maxh item row
             row-centers rt left right bottom top found
             j e2 ed2 p2 x2 y2
             vctr vsize ssize aspect vw vh cx cy2
             scr-xmin scr-xmax scr-ymin scr-ymax)
  (vl-load-com)

  (defun *error* (msg)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[QH] 错误: " msg))
    )
    (princ)
  )

  ;; 1. 取已选中的文字作为参考（无预选时手动选择）
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[QH] 请选择参考文字（可先选中文字再运行命令）: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )
  (if (null ss)
    (progn
      (princ "\n[QH] 未选择任何文字，命令已取消。")
      (exit)
    )
  )

  ;; 2. 收集参考文字信息 (x y h) 并统计整体 X 范围
  (setq i 0 xmin nil xmax nil n 0 ref-list '())
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          ed    (entget ename)
          ins   (cdr (assoc 10 ed)))
    (if ins
      (progn
        (setq x (car ins)
              y (cadr ins)
              h (if (assoc 40 ed) (cdr (assoc 40 ed)) 0.0))
        (if (null xmin) (setq xmin x xmax x))
        (setq xmin (min xmin x)
              xmax (max xmax x)
              n     (1+ n)
              ref-list (cons (list x y h) ref-list))
      )
    )
    (setq i (1+ i))
  )
  (if (= n 0)
    (progn
      (princ "\n[QH] 无法读取参考文字的位置信息，命令已取消。")
      (exit)
    )
  )

  ;; 3. 参考文字按 Y 排序后聚类成行（行间容差取组内最大字高的 0.7 倍）
  (setq sorted-ref (vl-sort ref-list
                     '(lambda (a b) (< (cadr a) (cadr b))))
        rows '())
  (foreach item sorted-ref
    (setq y (cadr item)
          h (caddr item))
    (if (null rows)
      (setq rows (list (list y y h)))
      (progn
        (setq last     (car rows)
              last-avg (/ (+ (car last) (cadr last)) 2.0)
              last-maxh (caddr last))
        (if (<= (abs (- y last-avg)) (* last-maxh 0.7))
          (setq rows (cons (list (min (car last) y)
                                 (max (cadr last) y)
                                 (max (caddr last) h))
                           (cdr rows)))
          (setq rows (cons (list y y h) rows))
        )
      )
    )
  )
  ;; 每行生成 (行中心Y 行容差)，容差至少半个字高
  (setq row-centers '())
  (foreach row rows
    (setq row-centers
           (cons (list (/ (+ (car row) (cadr row)) 2.0)
                       (max (+ (/ (- (cadr row) (car row)) 2.0)
                                (* (caddr row) 0.5))
                            (* (caddr row) 0.5)))
                 row-centers))
  )

  ;; 4. 当前屏幕可视范围（模型空间当前视口）
  (setq vctr  (getvar "VIEWCTR")
        vsize (getvar "VIEWSIZE")
        ssize (getvar "SCREENSIZE")
        aspect (if (and (> (car ssize) 0) (> (cadr ssize) 0))
                 (/ (float (car ssize)) (cadr ssize))
                 1.0)
        vw    (* vsize aspect)
        vh    vsize
        cx    (car vctr)
        cy2   (cadr vctr)
        scr-xmin (- cx (/ vw 2.0))
        scr-xmax (+ cx (/ vw 2.0))
        scr-ymin (- cy2 (/ vh 2.0))
        scr-ymax (+ cy2 (/ vh 2.0)))

  ;; 5. 全库文字：只保留 屏幕内 + 参考文字所在行 + 左右各 1000 内
  (setq left  (max scr-xmin (- xmin 1000.0))
        right (min scr-xmax (+ xmax 1000.0))
        bottom scr-ymin
        top    scr-ymax
        found (ssadd))
  (setq ss (ssget "X" '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq j 0)
      (repeat (sslength ss)
        (setq e2  (ssname ss j)
              ed2 (entget e2)
              p2  (cdr (assoc 10 ed2)))
        (if p2
          (progn
            (setq x2 (car p2)
                  y2 (cadr p2))
            (if (and (<= left x2) (<= x2 right)
                     (<= bottom y2) (<= y2 top)
                     (vl-some
                       '(lambda (rt)
                          (<= (abs (- y2 (car rt))) (cadr rt)))
                       row-centers))
              (ssadd e2 found)
            )
          )
        )
        (setq j (1+ j))
      )
    )
  )

  ;; 6. 高亮选中结果
  (if (> (sslength found) 0)
    (progn
      (sssetfirst nil found)
      (princ (strcat "\n[QH] 已选中 " (itoa (sslength found))
                     " 个文字（参考文字所在行 · 当前屏幕内 · 左右各 1000 内）。")))
    (princ "\n[QH] 未找到同行文字。")
  )
  (princ)
)
(princ "\n[QH] 行内文字批量选择命令已加载，先选中文字再输入 QH 运行。")
(princ "\n[XX] 文字替换命令已加载，选中文字后输入 XX 运行。")
(princ)
;;; =======================================================================================
;;; 命令: BK
;;; 功能: 选中文字后，只保留最后一对括号（半角/全角均可）内的内容。
;;;       例: "至10kV 1#分段开关柜(10kV 1#分段隔离柜)" -> "至10kV 1#分段隔离柜"
;;;           "1-24S-901(2-11S-901)" -> "2-11S-901"
;;;           "至2#主变保护柜(故障录波柜)" -> "至故障录波柜"
;;; =======================================================================================
(defun bk:extract-inner (txt / pair posL posR openCh before inner)
  (setq pair (de:find-pair txt))
  (if pair
    (progn
      (setq posL   (nth 0 pair)
            posR   (nth 1 pair)
            openCh (nth 2 pair)
            before (substr txt 1 (1- posL))
            inner  (substr txt
                           (+ posL (strlen openCh) 1)
                           (- posR posL (strlen openCh))))
      (if (> (strlen inner) 0)
        (if (vl-string-search "至" before)
          (strcat "至" inner)
          inner)
        nil))
    nil)
)

(defun c:BK (/ *error* doc undo-open ss i ent txt new changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)
  (defun *error* (msg)
    (if undo-open
      (de:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\n错误: " msg)))
    (princ)
  )
  (prompt "\n选择要提取括号内内容的文字 (TEXT/MTEXT/ATTRIB): ")
  (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB"))))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T
            i 0
            changed 0
            skipped 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              txt (de:get-text ent)
              new (if txt (bk:extract-inner txt) nil))
        (cond
          ((or (null new) (= new txt)))
          ((de:set-text ent new)
           (setq changed (1+ changed)))
          (T
           (setq skipped (1+ skipped))))
        (setq i (1+ i))
      )
      (de:end-undo doc)
      (setq undo-open nil)
      (redraw)
      (princ (strcat "\n[BK] 已处理 " (itoa changed) " 个文字"))
      (if (> skipped 0)
        (princ (strcat "，" (itoa skipped) " 个文字写入失败")))
    )
    (princ "\n[BK] 未选中文字")
  )
  (princ)
)

(princ "\nAA整合版本已加载。")
(princ)

;;; HDDL 内置校核命令
;;; HDDL - 直接校核选中文字中的电缆编号（内置于 AA整合版本.lsp）
;;; 不依赖外部文件或其他 CAD 平台专有函数。

(defun hddl:ensure-layer (/)
  (if (not (tblsearch "LAYER" "HDDL_MARK"))
    (entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord")
               (100 . "AcDbLayerTableRecord") (2 . "HDDL_MARK")
               (70 . 0) (62 . 1))))
  "HDDL_MARK")

(defun hddl:clear-markers (/ ss i)
  (if (setq ss (ssget "_X" '((0 . "TEXT") (8 . "HDDL_MARK"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (entdel (ssname ss i))
        (setq i (1+ i))))))

(defun hddl:text (ed)
  (cond ((= (cdr (assoc 0 ed)) "TEXT") (cdr (assoc 1 ed)))
        ((= (cdr (assoc 0 ed)) "MTEXT")
         (vl-string-subst "" "\\P" (cdr (assoc 1 ed))))
        (T "")))

(defun hddl:color (e c / d)
  (if (setq d (entget e))
    (progn
      (setq d (vl-remove-if '(lambda (x) (member (car x) '(420 430))) d))
      (if (assoc 62 d) (setq d (subst (cons 62 c) (assoc 62 d) d))
        (setq d (append d (list (cons 62 c)))))
      (entmod d))))

(defun hddl:coord (rec axis / p)
  (setq p (if (and rec (= (type rec) 'LIST)) (caddr rec) nil))
  (if (and p (= (type p) 'LIST) (numberp (car p)) (numberp (cadr p)))
    (if (= axis 0) (car p) (cadr p))
    0.0))

(defun hddl:point (p)
  (if (and p (= (type p) 'LIST) (numberp (car p)) (numberp (cadr p)))
    (list (car p) (cadr p) (if (numberp (caddr p)) (caddr p) 0.0))
    '(0.0 0.0 0.0)))

(defun hddl:skip (xs n / i)
  (setq i 0)
  (while (and xs (< i n) (= (type xs) 'LIST))
    (setq xs (cdr xs) i (1+ i)))
  (if (= (type xs) 'LIST) xs nil))

(defun hddl:item (xs n / i)
  (setq i 0)
  (while (and xs (< i n) (= (type xs) 'LIST))
    (setq xs (cdr xs) i (1+ i)))
  (if (and xs (= (type xs) 'LIST) (= i n)) (car xs) nil))

(defun hddl:row-sort (a b / ya yb xa xb)
  (setq ya (hddl:coord a 1) yb (hddl:coord b 1)
        xa (hddl:coord a 0) xb (hddl:coord b 0))
  (if (> ya (+ yb 1.0)) T
    (if (< ya (- yb 1.0)) nil (< xa xb))))

(defun hddl:insert-sorted (rec sorted / head)
  (if (null sorted)
    (list rec)
    (if (hddl:row-sort rec (car sorted))
      (cons rec sorted)
      (cons (car sorted) (hddl:insert-sorted rec (cdr sorted))))))

(defun hddl:sort (items / result rec)
  (setq result nil)
  (foreach rec items (setq result (hddl:insert-sorted rec result)))
  result)

(defun hddl:add-row (rec rows / y out hit row)
  (setq y (hddl:coord rec 1) out '() hit nil)
  (foreach row rows
    (if (and (not hit) (<= (abs (- y (hddl:coord (car row) 1))) 1.0))
      (progn (setq out (append out (list (append row (list rec)))) hit T))
      (setq out (append out (list row)))))
  (if hit out (append out (list (list rec)))))

(defun hddl:sort-rows (rows / out row)
  (setq out '())
  (foreach row rows (setq out (append out (list (hddl:sort row)))))
  out)

(defun hddl:make-marker (rec txt / ed pt h style rot layer dist p)
  (setq ed (entget (car rec))
        pt (caddr rec)
        h (cdr (assoc 40 ed))
        style (if (assoc 7 ed) (cdr (assoc 7 ed)) (getvar "TEXTSTYLE"))
        rot (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0)
        layer "HDDL_MARK")
  (if (or (null h) (<= h 0.0)) (setq h (getvar "TEXTSIZE")))
  (if (or (null h) (<= h 0.0)) (setq h 2.5))
  (setq dist (* h (+ 2.0 (strlen txt)))
        p (list (- (car pt) (* dist (cos rot)))
                (- (cadr pt) (* dist (sin rot)))
                (if (caddr pt) (caddr pt) 0.0)))
  (entmakex (list '(0 . "TEXT") (cons 8 layer) (cons 10 p) (cons 40 h)
                  (cons 1 txt) (cons 7 style) (cons 50 rot) '(62 . 1))))

(defun hddl:tail-duplicate-p (row / rest seen v hit one)
  ;; YSDL 导出行的第 5 列起是芯线/原理号区域；同一行重复值通常表示原理号填错。
  (setq rest (hddl:skip row 4) seen '() hit nil)
  (while (and rest (not hit))
    (setq one (car rest)
          v (if (and (= (type one) 'LIST) (cdr one))
              (vl-string-trim " \t" (cadr one)) ""))
    (if (and (/= v "") (member (strcase v) seen)) (setq hit T))
    (if (/= v "") (setq seen (cons (strcase v) seen)))
    (setq rest (cdr rest)))
  hit)

(defun hddl:cell (row n)
  (if (setq row (hddl:item row n))
    (if (and (= (type row) 'LIST) (cdr row))
      (vl-string-trim " \t" (cadr row)) "")
    ""))

(defun hddl:tail-count (row / rest n v one)
  (setq rest (hddl:skip row 4) n 0)
  (foreach rec rest
    (setq one rec
          v (if (and (= (type one) 'LIST) (cdr one))
              (vl-string-trim " \t" (cadr one)) ""))
    (if (/= v "") (setq n (1+ n))))
  n)

(defun hddl:cabinet (s /)
  ;; “至”表示到达方向，不属于柜名；比较镜像端点时统一去掉前缀。
  (setq s (vl-string-trim " \t" (if s s "")))
  (while (and (> (strlen s) 0) (= (substr s 1 1) "至"))
    (setq s (vl-string-trim " \t" (substr s 2))))
  s)

(defun hddl:mirror-p (a b)
  (and (= (strcase (hddl:cabinet (hddl:cell a 0)))
          (strcase (hddl:cabinet (hddl:cell b 2))))
       (= (strcase (hddl:cabinet (hddl:cell a 2)))
          (strcase (hddl:cabinet (hddl:cell b 0))))))

(defun c:HDDL (/ ss i e d items sorted rows cur lasty rec row id groups grp
                 issue bad marker made mirror-ok olderr stage)
  (setq olderr *error*)
  (defun *error* (msg)
    (if (and msg (/= (strcase msg) "FUNCTION CANCELLED"))
      (princ (strcat "\n[HDDL] 校核失败（阶段：" stage "）：" msg)))
    (setq *error* olderr)
    (princ))
  (princ "\n请选择要校核的 YSDL 文字: ")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      (setq stage "清理旧标记")
      (hddl:ensure-layer)
      (hddl:clear-markers)
      (setq stage "读取文字")
      (setq items '() i 0)
      (repeat (sslength ss)
        (setq e (ssname ss i) d (entget e))
        (setq items (cons (list e (hddl:text d) (hddl:point (cdr (assoc 10 d)))) items))
        (setq i (1+ i)))
      ;; 逐条按 Y 坐标归行，再只对每一行的小列表按 X 排序，避免大列表递归。
      (setq stage "按坐标分行" rows '())
      (foreach rec items (setq rows (hddl:add-row rec rows)))
      (setq rows (hddl:sort-rows rows))
      ;; 第二列是 YSDL 的电缆编号列；先按编号收集整行，随后排除合法镜像行。
      (setq stage "按电缆编号分组")
      (setq groups '())
      (foreach row rows
        (setq id (hddl:cell row 1))
        (if (/= id "")
          (if (assoc (strcase id) groups)
            (setq groups
              (subst (cons (strcase id) (append (cdr (assoc (strcase id) groups)) (list row)))
                     (assoc (strcase id) groups) groups))
            (setq groups (cons (cons (strcase id) (list row)) groups)))))
      (setq stage "检查编号和原理号" bad 0 made 0)
      (foreach row rows
        (setq id (hddl:cell row 1) issue nil)
        (if (/= id "")
          (progn
            (setq grp (cdr (assoc (strcase id) groups))
                  mirror-ok (and (= (length grp) 2)
                                 (hddl:mirror-p (car grp) (cadr grp))))
            (cond
              ((hddl:tail-duplicate-p row) (setq issue "[原理号重复]"))
              ((and mirror-ok (/= (hddl:tail-count (car grp))
                                  (hddl:tail-count (cadr grp))))
               (setq issue "[原理号不一致]"))
              ((not mirror-ok) (setq issue "[编号重复]")))))
        (if issue
          (progn
            (setq bad (1+ bad))
            (foreach rec row (hddl:color (car rec) 1))
            (setq marker (hddl:make-marker (car row) issue))
            (if marker (setq made (1+ made))))))
      (setq stage "绘制问题标记")
      (redraw)
      (alert (strcat "HDDL 校核完成\n\n问题行: " (itoa bad)
                     "\n已生成红色标记: " (itoa made)
                     "\n\n规则：合法的起终点互换镜像行不标红；同向重复、镜像原理号数量不一致或行内原理号重复会标红。")))
      (princ "\n未选择文字。"))
  (setq *error* olderr)
  (princ))

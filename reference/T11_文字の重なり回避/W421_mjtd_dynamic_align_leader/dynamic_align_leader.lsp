(defun c:aa()(C:dynamic-align-LEADER))
(defun c:aa1()(setq *textpoint-ctrl T) (C:dynamic-align-LEADER));文字在引线上面
(defun c:aa2()(setq *textpoint-ctrl nil) (C:dynamic-align-LEADER))
;;组操作
(defun C:AASZ()
        (if *textpoint-ctrl
                (progn
                        (setq *textpoint-ctrl nil)
                        (princ "\n文字在引线后面<<<<<<<<<<<<<<<<<<<<<<<<<")
                )
                (progn
                        (setq *textpoint-ctrl T)
                        (princ "\n文字在引线上面>>>>>>>>>>>>>>>>>>>>>>>>>")
                )
        )
        (princ)
)
(defun C:dynamic-align-LEADER(/ ss code ent gr loop name pt ang0 dist0 ss-enlst ss-leader ss-text DDian elist-res text-info pt_temp pt1 Text_alignment_pt xyp-DXF xyp-Etype leader-last-pt pdyxfx)
        (defun ss-enlst        (ss / enlst)
                (cond
                        ((= (type ss) 'PICKSET)
                                (vl-remove-if-not '(lambda (x) (= (type x) 'ENAME)) (mapcar 'cadr (ssnamex SS)))
                        )
                        ((= (type ss) 'LIST)
                                (setq enlst (ssadd))
                                (last (mapcar '(lambda (x) (ssadd x enlst)) ss))
                        )
                )
        )
        ;检查文字的对齐点是第一对齐点10,还是第二对齐点11
        (defun Text_alignment_pt(ename)
                (if
                        (or (equal (xyp-DXF '(72 73) ename) '((72 0)(73 0)))
                                (equal (xyp-DXF 0 ename) "MTEXT")
                        )
                        (assoc 10 (entget ename))
                        (assoc 11 (entget ename))
                )
        )
        ;; xyp-DXF 实体dxf数据 (xyp-DXF code ename)
        (defun xyp-DXF (code ename / ent lst a)
                (if (= (type code) 'LIST)
                        (progn
                                (setq ent   (entget ename)
                                        lst  '()
                                )
                                (foreach a code
                                        (setq lst (cons (list a (cdr (assoc a ent))) lst))
                                )
                                (reverse lst)
                        )
                        (if (= code -3)
                                (cdr (assoc code (entget ename '("*"))))
                                (cdr (assoc code (entget ename)))
                        )
                )
        )
        ;; xyp-Etype 检查实体类型 (xyp-Etype ename etype)
        (defun xyp-Etype (ename etype)
                (wcmatch (xyp-dxf 0 ename) (strcase etype))
        )
        (defun mydxf (ent n);;;查询DXF内容
                (if (= (type ent) 'ename)
                        (setq ent (entget ent))
                )
                (cdr (assoc n ent))
        )
        (defun pdyxfx (ent / jds bili jd jd0x jd0y jd1x jd1y jd2x jd2y yxfx);;;判断引线方向
                (setq jds (mydxf ent 76))
                (setq bili (vla-get-ScaleFactor (vlax-ename->vla-object ent)))
                (setq jd (vla-get-Coordinates (vlax-ename->vla-object ent)))
                (setq jd (vlax-safearray->list (vlax-variant-value jd)))
                (setq
                        ;jd0x (nth (- (* jds 3) 9) jd);;取倒数第三个点的x坐标
                        ;jd0y (nth (- (* jds 3) 8) jd);;取倒数第三个点的y坐标
                        jd1x (nth (- (* jds 3) 6) jd);;取倒数第二个点的x坐标
                        jd1y (nth (- (* jds 3) 5) jd);;取倒数第二个点的y坐标
                        jd2x (nth (- (* jds 3) 3) jd);;取倒数第一个点的x坐标
                        jd2y (nth (- (* jds 3) 2) jd);;取倒数第一个点的y坐标
                )
                (if (> (abs (- jd1x jd2x)) (abs (- jd1y jd2y)));true为横向
                        (if (> jd1x jd2x)
                                (setq yxfx "HR")
                                (setq yxfx "HL")
                        )
                        (if (> jd1y jd2y)
                                (setq yxfx "VU")
                                (setq yxfx "VD")
                        )
                )
                yxfx
        )
        ;;;获取引线最后一个顶点
        (defun leader-last-pt (ent / jds jd jd1x jd1y jd2x jd2y)
                (setq jds (xyp-DXF 76 ent))
                (setq jd (vla-get-Coordinates (vlax-ename->vla-object ent)))
                (setq jd (vlax-safearray->list (vlax-variant-value jd)))
                (setq jd1x (nth (- (* jds 3) 6) jd);;取倒数第二个点的x坐标
                        jd1y (nth (- (* jds 3) 5) jd);;取倒数第二个点的y坐标
                        jd2x (nth (- (* jds 3) 3) jd);;取倒数第一个点的x坐标
                        jd2y (nth (- (* jds 3) 2) jd);;取倒数第一个点的y坐标
                )
                (list jd2x jd2y);引线的倒数第1个点
        )
        (if *textpoint-ctrl
                (princ "\n文字在引线上面>>>>>>>>>>>>>>>>>>>>>>>>>执行C:AASZ切换")
                (princ "\n文字在引线后面<<<<<<<<<<<<<<<<<<<<<<<<<执行C:AASZ切换")
        )
        (prompt "\n请选择引线和文字:")
  (if (setq ss (ssget '((0 . "LEADER,*TEXT"))))
                (progn
                        (command "_undo" "_be")
      (setq loop t)
                        (setq ss (ss-enlst ss))
                        (if        (and
                                                (setq ss-leader (vl-remove-if-not        '(lambda (x) (xyp-Etype x "LEADER"))        ss));筛选引线
                                                (setq ss-text (vl-remove-if-not        '(lambda (x) (xyp-Etype x "*TEXT")) ss));筛选文字
                                        )
                                (progn
                                        (setq pt0 (leader-last-pt(car ss-leader)));;获取参照点
                                        (setq text-info(mapcar '(lambda (x / pt-tt)
                                                                                                                                                (progn
                                                                                                                                                        (setq pt-tt (Text_alignment_pt x))
                                                                                                                                                        (cons x (list(list (distance pt0 (cdr pt-tt)) (angle pt0 (cdr pt-tt)))))
                                                                                                                                                )
                                                                                                                                        )
                                                                                                         ss-text
                                                                                                 );;((文字图元名 (文字对齐点 角度 距离))(文字图元名 (文字对齐点 角度 距离)))
                                        );;建立文本相对位置关系表
                                )
                        )
                        (princ "\n指定点:")
                        (princ "\n指定点[开/关捕捉(F3)]:")
                        (while loop
                                (if (null ss-leader) (exit))
        (setq gr (grread t 15 0) code (car gr) pt (cadr gr))
        (cond
          ((= code 3)(redraw) (setq loop nil))  ; 鼠标左键
          ((= code 5)                  ; 鼠标移动
                                                (redraw)
                                                (if (>(getvar"OSMODE")16384)
                                                        (princ)
                                                        (setq pt (osnappt name pt))
                                                )
                                                (setq pt(trans pt 1 0))
                                                (if ss-leader;;移动引线
                                                        (foreach name ss-leader
                                                                (setq ent (entget name))
                                                                (setq DDian (vl-remove-if-not
                                                                                                                        '(lambda (x) (member (car x) '(10)))
                                                                                                                        ent
                                                                                                                )
                                                                );;获取引线的顶点表((10 x y z)(10 x y z)...)
                                                                (setq DDian (reverse(cdr(reverse DDian))));;剔除引线最后一个顶点
                                                                ;(setq DDian (vl-remove (last DDian) DDian));;剔除引线最后一个顶点
                                                                (setq elist-res (vl-remove-if
                                                                                                                                        '(lambda (x) (member (car x) '(10)))
                                                                                                                                        ent
                                                                                                                                )
                                                                )
                                                                (setq pt1(leader-last-pt name))
                                                                (setq pt_temp (subst  (nth 0 pt) (nth 0 pt1) pt1));更新X坐标
                                                                (setq ent (append elist-res DDian (list(cons 10 pt_temp))));重新组合
                                                                (entmod ent)
                                                        )
                                                )
                                                (if (and ss-leader ss-text);;移动文字
                                                        (foreach name ss-text
                                                                (setq ent (entget name))
                                                                (setq pt0 (leader-last-pt(car ss-leader)));;获取参照点
                                                                (setq dist0 (car(cadr(assoc name text-info))))
                                                                (setq ang0 (cadr(cadr(assoc name text-info))))
                                                                (setq pt_align_new(polar pt0 ang0 dist0))
                                                                (setq pt_align_code(car(Text_alignment_pt name)))
                                                                (entmod (setq ent (subst(cons pt_align_code pt_align_new)(assoc pt_align_code ent)ent)))
                                                        )
                                                )
                                        )
                                        ((member code '(2 6))                  ; 键盘输入
                                                (if(>(getvar"OSMODE")16384)(setvar"OSMODE"(-(getvar"OSMODE")16384))(setvar"OSMODE"(+(getvar"OSMODE")16384))))
                                        ;((= code 2)                  ; 键盘输入
                                        ;        (princ "\n键盘输入=")(princ pt))
                                        ((member code '(11 25))      ; 鼠标右击
                                                (redraw)  (setq loop nil)
                                        )
                                )
                        )
                        ;Worlducs        指示 UCS 是否与 WCS 相同。0. UCS 与 WCS 不同 1. UCS 与 WCS 相同
                        (if (and ss-text (=(getvar "Worlducs")1))
                                (progn
                                        (setq yxfx (pdyxfx(car ss-leader)))
                                        (cond
                                                ((and(= yxfx "HL")*textpoint-ctrl)(setq amode "R"));尾端
                                                ((and(= yxfx "HR")*textpoint-ctrl)(setq amode "L"));尾端
                                                ((and(= yxfx "HL")(NULL *textpoint-ctrl))(setq amode "L"))
                                                ((and(= yxfx "HR")(NULL *textpoint-ctrl))(setq amode "R"))
                                        )
                                        (process-align-text (ss-enlst ss-text) (leader-last-pt(car ss-leader)))
                                )
                                (princ "\当前绘图坐标系，非WCS坐标系，不支持文字对齐，因为容易出错！！！")
                        );;添加额外的操作
                        (command "_undo" "_E")
                )
        )
        (princ)
)
(defun process-align-text (selobjs         apnt /                apnt        apnt_x
                                                                                                                apnt_y          count            objname   vlaxobj        MinPoint
                                                                                                                MaxPoint  minext   maxext   ext_l        ext_r
                                                                                                                ext_m          tpnt temp
                                                                                                        )
        (if (null amode)
    (setq amode "L")
  )
  (initget "L R")
  (if(setq        temp (getkword
                                                                         (strcat
                                                                                 "\n选择对齐方式[左对齐(L)/右对齐(R)]<("amode")>:"
                                                                         )
                                                                 )
                 )
                (setq amode temp)
        )
        (cond 
                ((= amode "L")                        
                        (command "justifytext" selobjs "" amode)                        
                )
                ((= amode "R")                        
                        (command "justifytext" selobjs "" amode)                        
                )
        )
        (initget 1)
        (setq apnt(trans apnt 1 0))
  (setq        apnt_x (car apnt)
                apnt_y (cadr apnt)
  )
  (vl-load-com)
  (setq count 0)
  (repeat (sslength selobjs)
    (setq objname (ssname selobjs count))
    (setq vlaxobj (vlax-ename->vla-object objname))
    (setq MinPoint (vlax-make-variant))
    (setq MaxPoint (vlax-make-variant))
    (vla-GetBoundingBox vlaxobj 'MinPoint 'MaxPoint)
    (setq minext (vlax-safearray->list MinPoint))
    (setq maxext (vlax-safearray->list MaxPoint))
                (setq minext(trans minext 1 0));;;
                (setq maxext(trans maxext 1 0));;;
    (setq ext_l (car minext))
    (setq ext_r (car maxext))
    (setq ext_m (+ (/ (abs (- ext_l ext_r)) 2) ext_l))
    (cond
      ((= amode "L")
                                (setq tpnt (list ext_l apnt_y))
      )
      ((= amode "M")
                                (setq tpnt (list ext_m apnt_y))
      )
      ((= amode "R")
                                (setq tpnt (list ext_r apnt_y))
      )
    )
    (if        tpnt
                        (progn
                                (command "_move" objname "" "_none" (trans tpnt 1 0) "_none" (trans apnt 1 0))
                                (if amode        (command "justifytext" objname "" (strcat (if *textpoint-ctrl "" "M")  amode)))
                        )
    )
    (setq count (1+ count))
  )
)
;;; grread捕捉子函数
;;; name为移动的图元名，pt为光标点
;;; 返回值：如果有捕捉点则返回捕捉点，无则返回光标点
(defun osnappt (name pt / color d h k lst nearpt nearpt2 osmo pt1 pt2 pt3 pt4 pt5 ptx pty x)
  (if name (entdel name))
  (redraw)
  (if (< (getvar "osmode") 16384);;打开捕捉
    (progn
      (setq color (vla-get-autosnapmarkercolor (vla-get-drafting (vla-get-preferences (vlax-get-acad-object))))
                                h (/ (getvar "viewsize") (cadr (getvar "screensize"))) d (getvar "pickbox")
                                lst (list (* d h) (* (- d 0.5) h) (* (+ d 0.5) h)) k (* 1.5 d h))
      (if (setq nearpt (osnap pt "_END,_CEN,_NOD,_QUA,_INS,_TAN,_EXT"))(setq osmo 1))
      (if (and(setq nearpt2 (osnap pt "_NEA"))(not (equal nearpt nearpt2 k)))
        (setq osmo 2 nearpt nearpt2))
      (if (and(setq nearpt2 (osnap pt "_MID"))(equal nearpt nearpt2 k))
        (setq osmo 3 nearpt nearpt2))
      (if (and(setq nearpt2 (osnap pt "_INT"))(equal nearpt nearpt2 k))
        (setq osmo 4 nearpt nearpt2))))
  (if name(entdel name))
  (if nearpt
    (progn
      (setq ptx (car nearpt)pty (cadr nearpt))
      (foreach x lst
        (setq pt1 (list (- ptx x) (- pty x)) pt2 (list (+ ptx x) (- pty x))
                                        pt3 (list (+ ptx x) (+ pty x)) pt4 (list (- ptx x) (+ pty x))
                                        pt5 (list ptx (+ pty x)))
        (cond
          ((= osmo 1)(grvecs (list color pt1 pt2 pt2 pt3 pt3 pt4 pt4 pt1)))
          ((= osmo 2)(grvecs (list color pt1 pt2 pt2 pt4 pt3 pt4 pt3 pt1)))
          ((= osmo 3) (grvecs (list color pt1 pt2 pt2 pt5 pt5 pt1)))
          ((= osmo 4) (grvecs (list color pt1 pt3 color pt2 pt4)))))
      (setq pt nearpt)))
  pt
)
(princ "\n动态对齐文字引线命令 C:AA----默认：上面")
(princ "\n动态对齐文字引线命令 C:AA1---文字在引线上面")
(princ "\n动态对齐文字引线命令 C:AA2---文字在引线后面")
(princ "\n动态对齐文字引线命令 C:AASZ--切换AA对应的模式")
(princ)

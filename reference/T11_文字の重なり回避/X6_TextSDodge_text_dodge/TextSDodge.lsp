;;;-----------------------------------------------------------------------------
;|文本避让程序，功能：实现单行文本与其它对象重叠或交叉时，按设置移动到空白位置。
如果按设置要求，无法实现移动到空白位置，则按要求改变文本颜色或把文本转移到指定图层。

本程序的设计采用类似C++ Builder的对象程序设计方式：
1.所有程序内容均封闭在主函数TextSDodge中，主要的变量为主函数里的局域变量，但同时也是子函数间的公共变量。
2.主函数仅为控制界面、实现与界面的连接的部分，通过其它功能均作为子函数实现。所有子函数内容均写在主函数内容之前。
3.主变量值变化控制方式：各主要变量的初始化与界面各组件的初始化通过初始化函数实现，
  集中设置dcl界面组件的OnClick事件函数，一部分变量值通过关闭界面时检测，另一部分变量值的变化均在OnClick函数里实现。
4.各变量、子函数的命名采用C++的命名法则：
  变量命名：变量类型+变量作用，
  子函数：一般子函数,直接采用功能命名，界面子函数，组合名+OnClick 或 按功能

程序阅读建议:使用可进行语法着色、代码折叠及检测函数名列表的代码编辑器,如Ultra Editor,EditMinus之类，
             如果gVim或Emacs用得很好的，Gvim、Emacs也是不错的选择
|;
(defun c:TextSDodge
                    (/                                ssSelectedTexts ;文本选择集
                     intSelectedTextsNumber ;选择集包括文本个数
                     intDodgeLosedTextNumber ;避让失败的文本个数
                     intDodgeSucceedTextNumber ;避让成功的文本个数
                     intNotNeedToDodgeTextNumber ;不需要避让的文本个数
                     lispFormatedSelectedTexts ;格式化后的文本列表,格式:( (对象名 基点 倾斜角度(角度制) 字高 ...))
                     strTextDodgeOrder ;处理顺序
                     listAllowedTextDodgeOrder ;允许的处理顺序列表
                     listDodgeTargetFilter ;避让对象类型
                     floatDodgeMinDist ;避让间距
                     strDodgeType ;避让方式值: "坐标轴方向" / "文本方向"
                     strDodgeRouteFirst ;第一避让路径
                     strDodgeRouteSecond ;第二避让路径
                     floatDodgeLimitDistFirst ;第一避让路径最大移动距离
                     floatDodgeLimitDistSecond ;第二避让路径最大移动距离
                     boolChangeToColor ;避让失败时，是否改变文本颜色
                     intTargetColorName ;避让失败后，文本的颜色名
                     boolChangeToLayer ;避让失败时，是否改变文本所在图层
                     strTargetLayerName ;避让失败后，文本的图层名
                     listMoveAlongTextDirectionDodgeRoute ;记录沿文本自身方向避让时，允许的避让方式的表
                     listMoveAlongCoordinateAxisDirectionDodgeRoute ;记录沿坐标轴向避让时，允许的避让方式的表
                     listFirstMoveDirection ;第一避让方式列表，与允许的避让方式列表相同
                     listSecondMoveDirection ;第二避让方式列表,第二避让方式受第一方式限制，才设此变量
                     listColorNames ;进行文本避让失败处理时，文本允许选择的颜色列表
                     listExistedtLayerNames ;所有图层名称列表
                     intDialogCloseType ;对话框的关闭类型，与done_dialog返回值相等
                     dcl_id ;窗口id
                     ;;以上所有变量均为程序的全局控制变量
                    )
;;;-----------------------------------------------------------------------------
;;;根据相应列表值，重新设置对话框中listbox/popuplist显示值
;;;调用形式 ( 显示的内容列表 对话框中listbox/popuplist组件的名称 )
  (defun ListToPoPupList (listName strDCLPoPupListName)
    (start_list strDCLPoPupListName 3 0)
    (mapcar 'add_list listName)
    (end_list)
  )
;;;-----------------------------------------------------------------------------
;;;搜索已有图层并加入到DCL中相应的List
  (defun GetExistedLayerNames (/ LayerName LayerDXF)
    (setq LayerDXF (tblnext "LAYER" T)
          listExistedtLayerNames
           nil
    )
    (while LayerDXF
      (setq LayerName (cdr (assoc 2 LayerDXF)))
      ;;往表中加入已有图层名列表
      (if (/= LayerName "")
        (setq listExistedtLayerNames
               (append listExistedtLayerNames
                       (list LayerName)
               )
        )
      )
      (setq LayerDXF (tblnext "LAYER"))
    )

    (ListToPoPupList
      listExistedtLayerNames
      "plExistedlLayerNames"
    )

    (setq LayerName (nth 0 listExistedtLayerNames))
  )
;;;-----------------------------------------------------------------------------
;;;创建程序界面时，对大部分主要控制变量及界面进行初始化
  (defun FormMainOnCreat ()
    (setq strTextDodgeOrder                              "按选择顺序"
          listAllowedTextDodgeOrder                      '("按选择顺序" "从左到右" "从右到左" "从上到下" "从下到上")
          listDodgeTargetFilter                          nil
          floatDodgeMinDist                              0
          strDodgeType                                   "坐标轴方向"
          strDodgeRouteFirst                             "X轴正方向"
          strDodgeRouteSecond                            "Y轴正方向"
          floatDodgeLimitDistFirst                       0
          floatDodgeLimitDistSecond                      0
          boolChangeToColor                              "否"
          intTargetColorName                             1
          boolChangeToLayer                              "否"
          strTargetLayerName                             "0"
          listMoveAlongTextDirectionDodgeRoute           '("倾斜方向左" "倾斜方向右" "法线方向上" "法线方向下")
          listMoveAlongCoordinateAxisDirectionDodgeRoute '("X轴正方向" "X轴负方向" "Y轴正方向" "Y轴负方向")
          listColorNames                                 '("红色" "黄色" "绿色" "浅蓝色" "蓝色" "紫色" "白色")
          intDialogCloseType                             0
    )

    (set_tile "edSelectedTextNumber"
              (rtos intSelectedTextsNumber 2 0)
    )     ;在对话框中显示选择的文本个数

    (ListToPoPupList listAllowedTextDodgeOrder
                     "plTextDodgeOrder"
    )     ;设置允许的文本处理顺序列表

    (rbMoveAlongCoordinateAxisDirectionOnClick)
          ;默认按"坐标轴方向"移动文本

    (ListToPoPupList listColorNames "plColorNames")
          ;默认按"坐标轴方向"移动文本
    (setq intTargetColorName 1) ;默认避让失败的文本改变颜色为颜色列表的第一种颜色
    (tgBoolChangeToColorOnClick "0") ;默认避让失败时文本不改变颜色

    (GetExistedLayerNames) ;查询所有图层名并反映到界面中相关的组件值
    (setq strTargetLayerName (car listExistedtLayerNames))
          ;默认避让失败的文本改变所在图层名为图层列表的第一个图层名
    (tgBoolChangeToLayerOnClick "0") ;默认避让失败时文本不改变所在图层
  )
;;;-----------------------------------------------------------------------------
;;;根据设置进行文本避让处理
  (defun DoTextSDodge (/                        strTextToBeDealedEntityName ;当前处理的文本
                       listTextDXF ;文本的DXF编码
                       strTextToBeDealedEntityName ;当前处理的文本的实体名
                       lispTextInsertionPoint ;文本插入基点
                       floatTextRotationAngle ;文本旋转角度
                       listTextBoxPoints ;文本外框点表
                       tmpList                  tmpPointX                tmpPointY                tmpAngleInPi
                       lispLayerFilter ;临时记录过滤图层名组码
                      )
    (FormatSelectedTextsList)
    (setq lispLayerFilter (listGetLayerNamesFilter))
    (if lispLayerFilter
      (setq listDodgeTargetFilter
             (append listDodgeTargetFilter
                     lispLayerFilter
             )
      )
    )

    (setvar "osmode" 0)
    (vl-cmdf "ucs" "w")

    (setq i 0
          intDodgeLosedTextNumber 0
          intDodgeSucceedTextNumber 0
          intNotNeedToDodgeTextNumber 0
    )
    (repeat intSelectedTextsNumber
      (setq tmpList (nth i lispFormatedSelectedTexts))
      (setq strTextToBeDealedEntityName (car tmpList) ;当前处理的文本的实体名
            lispTextInsertionPoint (nth 1 tmpList) ;文本插入基点
            floatTextRotationAngle (nth 2 tmpList) ;文本旋转角度
      )

      (if (and (/= strDodgeType "坐标轴方向")
               (/= floatTextRotationAngle 0)
          )
        (progn
          (setq tmpPointX (polar lispTextInsertionPoint floatTextRotationAngle 10))
          (setq tmpPointY (polar lispTextInsertionPoint
                                 (+ (/ PI 2) floatTextRotationAngle)
                                 10
                          )
          )

          (vl-cmdf "ucs" "n" "3" lispTextInsertionPoint tmpPointX tmpPointY)
        ) ;旋转坐标轴
      )
      (setq listTextBoxPoints (GetTextBoxPointList strTextToBeDealedEntityName
                                                   floatDodgeMinDist
                                                   floatTextRotationAngle
                              )
      )
      ;;计算文本外框点表

      (if (and (/= (strSingleTextDodge
                     strTextToBeDealedEntityName     listTextBoxPoints               listDodgeTargetFilter
                     strDodgeRouteFirst              floatDodgeLimitDistFirst        floatTextRotationAngle
                    )
                   "避让成功"
               )
               (/= (strSingleTextDodge
                     strTextToBeDealedEntityName      listTextBoxPoints                listDodgeTargetFilter
                     strDodgeRouteSecond              floatDodgeLimitDistSecond        floatTextRotationAngle
                    )
                   "避让成功"
               )
          )
        (progn ;避让失败时
          (setq listTextDXF (entget strTextToBeDealedEntityName))
          (if (= boolChangeToColor "是") ;设置了改变文本颜色时
            (vla-put-color
              (vlax-ename->vla-object strTextToBeDealedEntityName)
              intTargetColorName
            )
          )
          (if (= boolChangeToLayer "是") ;设置了改变文本图层时
            (progn
              (entmod (subst (cons 8 strTargetLayerName)
                             (assoc 8 listTextDXF)
                             listTextDXF
                      )
              )
              (entupd strTextToBeDealedEntityName)
            )
          )
          (setq intDodgeLosedTextNumber (1+ intDodgeLosedTextNumber))
        )
      )

      (if (and (/= strDodgeType "坐标轴方向")
               (/= floatTextRotationAngle 0)
          )
        (vl-cmdf "ucs" "w") ;还原坐标轴
      )

      (setq i (1+ i))
    )

    (setvar "osmode" 431)

    (PrintTextDodgeResult) ;输出处理结果
  )
;;;-----------------------------------------------------------------------------
;;;输出文本避让处理结果信息
  (defun PrintTextDodgeResult (/
                               strResultInformation ;处理结果提示文本
                               strHasOtherTextDodegResultType
                               ;;记录是否存在与当前类型不同的，避让结果文本，用于程序末尾处理输出信息：值"Yes"/ "No"
                              )
    (setq intDodgeSucceedTextNumber (- intSelectedTextsNumber
                                       intDodgeLosedTextNumber
                                       intNotNeedToDodgeTextNumber
                                    )
    )
    (setq strResultInformation           (strcat "共选择"
                                                 (rtos intSelectedTextsNumber 2 0)
                                                 "个文本,其中:"
                                         )
          strHasOtherTextDodegResultType "No"
    )

    (if (/= intDodgeSucceedTextNumber 0)
      (progn
        (setq strResultInformation
               (strcat
                 strResultInformation
                 (rtos intDodgeSucceedTextNumber 2 0)
                 "个文本成功处理"
               )
        )
        (setq strHasOtherTextDodegResultType "Yes")
      )
    )

    (if (/= intDodgeLosedTextNumber 0)
      (progn
        (if (= strHasOtherTextDodegResultType "Yes")
          (setq strResultInformation (strcat strResultInformation ","))
        )
        (setq strResultInformation
               (strcat strResultInformation
                       (rtos intDodgeLosedTextNumber 2 0)
                       "文本处理处理失败"
               )
        )
        (setq strHasOtherTextDodegResultType "Yes")
      )
    )

    (if (/= intNotNeedToDodgeTextNumber 0)
      (progn
        (if (= strHasOtherTextDodegResultType "Yes")
          (setq strResultInformation (strcat strResultInformation ","))
        )
        (setq strResultInformation
               (strcat
                 strResultInformation
                 (rtos intNotNeedToDodgeTextNumber 2 0)
                 "个文本不需要处理"
               )
        )
      )
    )

    (princ strResultInformation)
  )
;;;-----------------------------------------------------------------------------
;;;主功能函数：根据输入，对单文本沿指定方向作避让处理
;;;调用形式(strSingleTextDodge     需处理的文本对象名  所求外框坐标表 过滤条件 避让方式 避让总距离限制)
;;;返回值字符串：成功时，返回“避让成功” ;失败时，返回字符串“避让失败”
  (defun strSingleTextDodge
                            (strTextToBeDealedEntityName                           listTextBoxPoints          listFilter
                             strDodgeRoute              floatDodgeLimitDist        floatTextRotationAngle     /
                             ssInPointListBox
                             ;;选择集，在文本外框内的所有对象
                             floatDodgeStepDist ;文本移动的步长
                             floatDodgeStepAddDist ;文本移动步长在交点所确定步长的基础上的增加值
                             floatTotalMovedDist ;当前已经移动的总距离
                             floatNextLocationTotalMovedDist ;下一文本位置相对原始位置的总距离
                             listInterPoints ;文本外框与框内所有符合要求的对象的交点表
                             listSortedptlistTextBox ;排序后的文本外框点坐标表
                             strDodgeResult ;避让处理的结果
                             strMovedAngle ;文本移动的相对角度，角度制，值：“<0”或“<90”
                             strMovedDistAndAngle ;文本移动的距离及角度
                             floatTextWidth ;文本宽度
                             floatTextHeight ;文本高度
                             floatMinDodgeStepDist ;最小移动步长,用于防止计算交点坐标有问题时，
                             ;;出现移动步长过小或文本反复在同一位置附近上下、左右移动
                             tmpfloat
                            )

    (if (/= strDodgeRoute "不再处理")
      (progn
        (setq strDodgeResult "避让成功"
              floatTotalMovedDist 0
              floatNextLocationTotalMovedDist 0
        )

        (setq floatTextWidth  (abs (- (car (nth 0 listTextBoxPoints))
                                      (car (nth 2 listTextBoxPoints))
                                   )
                              )
              floatTextHeight (abs (- (cadr (nth 0 listTextBoxPoints))
                                      (cadr (nth 2 listTextBoxPoints))
                                   )
                              )
        )
        (setq floatDodgeStepAddDist (* 0.1 floatTextHeight))
          ;移动步长单步增加值设置为0.1倍字高

        ;;以下通过移动文本，逐步判断在指定条件下是否存在足够的空白位置放下指定文本
        ;;如果存在，最终把文本移到移动距离最小的位置

        (cond ;对文本外框坐标表按避让方式的反方向进行排序,以便后续计算单次移动距离时，只需要用坐标表的第一个点坐标即可
          ((or (= strDodgeRoute "倾斜方向左")
               (= strDodgeRoute "X轴负方向")
           )
           (setq listSortedptlistTextBox
                  (vl-sort
                    listTextBoxPoints
                    (function (lambda (e1 e2)
                                (>= (car e1) (car e2))
                              )
                    )
                  )
           ) ;对文本外框点表按X坐标从大到小进行排序
           (setq strMovedAngle "<0")

           (setq floatMinDodgeStepDist (* 0.2 floatTextWidth))
          )

          ((or (= strDodgeRoute "倾斜方向右")
               (= strDodgeRoute "X轴正方向")
           )
           (setq listSortedptlistTextBox
                  (vl-sort
                    listTextBoxPoints
                    (function (lambda (e1 e2)
                                (<= (car e1) (car e2))
                              )
                    )
                  )
           ) ;对文本外框点表按X坐标从小到大进行排序
           (setq strMovedAngle "<0")

           (setq floatMinDodgeStepDist (* 0.2 floatTextWidth))
          )

          ((or (= strDodgeRoute "法线方向下")
               (= strDodgeRoute "Y轴负方向")
           )
           (setq listSortedptlistTextBox
                  (vl-sort
                    listTextBoxPoints
                    (function
                      (lambda (e1 e2)
                        (>= (cadr e1) (cadr e2))
                      )
                    )
                  )
           ) ;对文本外框点表按Y坐标从大到小进行排序
           (setq strMovedAngle "<90")
           (setq floatMinDodgeStepDist (* 0.2 floatTextHeight))
          )

          (T ;(or (= strDodgeRoute "法线方向上") (= strDodgeRoute "Y轴正方向") )
           (setq listSortedptlistTextBox
                  (vl-sort
                    listTextBoxPoints
                    (function
                      (lambda (e1 e2)
                        (<= (cadr e1) (cadr e2))
                      )
                    )
                  )
           ) ;对文本外框点表按Y坐标从小到大进行排序
           (setq strMovedAngle         "<90"
                 floatMinDodgeStepDist (* 0.2 floatTextHeight)
           )
          )
        )

        (setq ssInPointListBox
               (ssget "_CP" listTextBoxPoints listFilter)
        ) ;获取与文本外框相交及在文本框内的所有对象

        (if (and (> (sslength ssInPointListBox) 0)
                 (ssmemb strTextToBeDealedEntityName ssInPointListBox)
            )
          (ssdel strTextToBeDealedEntityName ssInPointListBox)
        ) ;去掉需要处理的文本本身

        (if (> (sslength ssInPointListBox) 0)
          (progn
            (while (and (> (sslength ssInPointListBox) 0)
                        (= strDodgeResult "避让成功")
                   )
              (setq listInterPoints
                     (GetInterPointsList
                       (vlax-ename->vla-object strTextToBeDealedEntityName)
                       ssInPointListBox
                       floatTextRotationAngle
                     )
              )
              ;;取得文本外框与框内符合条件的对象的所有交点表,表形式

              (cond
                ;;先对交点坐标表按避让方式方向进行排序,以便后续计算单次移动距离时，只需要用坐标表的第一个点坐标即可
                ;;本结构作用是：判断是否在指定限制距离内成功避让，可以时，计算移动距离；否则把避让结果strDodgeResult设置为“避让失败”
                ((or (= strDodgeRoute "倾斜方向左")
                     (= strDodgeRoute "X轴负方向")
                 )
                 (if (> (length listInterPoints) 1)
          ;交点多于1个时，对交点表进行排序
                   (setq listInterPoints
                          (vl-sort
                            listInterPoints
                            (function (lambda (e1 e2)
                                        (<= (car e1) (car e2))
                                      )
                            )
                          )
                   ) ;对交点表按X坐标从小到大进行排序
                 )
                 (if listInterPoints ;存在交点时按交点坐标计算步长，否则,说明存在完全被文本覆盖的对象，此时按文本全长计算
                   (progn
                     (setq tmpfloat (- (car (car listInterPoints))
                                       (car (car listSortedptlistTextBox))
                                       floatDodgeStepAddDist
                                       floatTextWidth
                                    )
                     )
                     ;;把交点最小的X坐标与文本外框最大的X坐标的差值，并加上单步长增加距离，作为下次移动是步长之和

                     (if (> tmpfloat
                            (- floatNextLocationTotalMovedDist
                               floatMinDodgeStepDist
                            )
                         )
                       (setq floatNextLocationTotalMovedDist (- floatNextLocationTotalMovedDist floatMinDodgeStepDist))
                       (setq floatNextLocationTotalMovedDist tmpfloat)
                     ) ;限制最小移动步长，使程序不容易出问题
                   )

                   (setq floatNextLocationTotalMovedDist (- floatTotalMovedDist floatTextWidth))
                 )
                )

                ((or (= strDodgeRoute "倾斜方向右")
                     (= strDodgeRoute "X轴正方向")
                 )
                 (if (> (length listInterPoints) 1)
          ;交点多于1个时，对交点表进行排序
                   (setq listInterPoints
                          (vl-sort
                            listInterPoints
                            (function (lambda (e1 e2)
                                        (>= (car e1) (car e2))
                                      )
                            )
                          )
                   ) ;对交点表按X坐标从大于小进行排序

                 )
                 (if listInterPoints ;存在交点时按交点坐标计算步长，否则,说明存在完全被文本覆盖的对象，此时按文本全长计算
                   (progn
                     (setq tmpfloat
                            (+ (- (car (car listInterPoints))
                                  (car (car listSortedptlistTextBox))
                               )
                               floatDodgeStepAddDist
                            )
                     )
                     ;;把交点最大的X坐标与文本外框最小的X坐标的差值，并加上单步长增加距离，作为下次移动是步长之和

                     (if (< tmpfloat
                            (+ floatNextLocationTotalMovedDist
                               floatMinDodgeStepDist
                            )
                         )
                       (setq floatNextLocationTotalMovedDist (+ floatNextLocationTotalMovedDist floatMinDodgeStepDist))

                       (setq floatNextLocationTotalMovedDist tmpfloat)
                     ) ;限制最小移动步长，使程序不容易出问题
                   )

                   (setq floatNextLocationTotalMovedDist (+ floatTotalMovedDist floatTextWidth))
                 )
                )
                ((or (= strDodgeRoute "法线方向下")
                     (= strDodgeRoute "Y轴负方向")
                 )
                 (if (> (length listInterPoints) 1)
          ;交点多于1个时，对交点表进行排序
                   (setq listInterPoints
                          (vl-sort
                            listInterPoints
                            (function
                              (lambda (e1 e2)
                                (<= (cadr e1) (cadr e2))
                              )
                            )
                          )
                   ) ;对交点表按Y坐标从小到大进行排序
                 )
                 (if listInterPoints ;存在交点时按交点坐标计算步长，否则,说明存在完全被文本覆盖的对象，此时按文本全高计算
                   (progn
                     (setq tmpfloat
                            (- (cadr (car listInterPoints))
                               (cadr (car listSortedptlistTextBox))
                               floatDodgeStepAddDist
                               floatTextHeight
                            )

                     )
                     ;;把交点最小的Y坐标与文本外框最大的Y坐标的差值，并加上单步长增加距离，作为下次移动是步长之和

                     (if (> tmpfloat
                            (- floatNextLocationTotalMovedDist
                               floatMinDodgeStepDist
                            )
                         )
                       (setq floatNextLocationTotalMovedDist (- floatNextLocationTotalMovedDist floatMinDodgeStepDist))

                       (setq floatNextLocationTotalMovedDist tmpfloat)
                     ) ;限制最小移动步长，使程序不容易出问题
                   )

                   (setq floatNextLocationTotalMovedDist (- floatTotalMovedDist floatTextHeight))
                 )
                )
                (T ;(or (= strDodgeRoute "法线方向上" ) (= strDodgeRoute "Y轴正方向" ))
                 (if (> (length listInterPoints) 1)
          ;交点多于1个时，对交点表进行排序
                   (setq listInterPoints
                          (vl-sort
                            listInterPoints
                            (function
                              (lambda (e1 e2)
                                (>= (cadr e1) (cadr e2))
                              )
                            )
                          )
                   ) ;对交点表按Y坐标从大于小进行排序
                 )
                 (if listInterPoints ;存在交点时按交点坐标计算步长，否则,说明存在完全被文本覆盖的对象，此时按文本全高计算
                   (progn
                     (setq tmpfloat
                            (+
                              (- (cadr (car listInterPoints))
                                 (cadr (car listSortedptlistTextBox))
                              )
                              floatDodgeStepAddDist
                            )

                     )
                     ;;把交点最小的Y坐标与文本外框最大的Y坐标的差值，并加上单步长增加距离，作为下次移动是步长之和

                     (if (< tmpfloat
                            (+ floatNextLocationTotalMovedDist
                               floatMinDodgeStepDist
                            )
                         )
                       (setq floatNextLocationTotalMovedDist (+ floatNextLocationTotalMovedDist floatMinDodgeStepDist))
                       (setq floatNextLocationTotalMovedDist tmpfloat)
                     ) ;限制最小移动步长，使程序不容易出问题
                   )

                   (setq floatNextLocationTotalMovedDist (+ floatTotalMovedDist floatTextHeight))
                 )
                )
              )

              (if (or (<= floatDodgeLimitDist 0)
                      (<= (abs floatNextLocationTotalMovedDist)
                          floatDodgeLimitDist
                      )
                  )
                ;;移动限制不存在或总移动距离在限制范围内时，移动文本到新位置
                (progn
                  (setq floatDodgeStepDist (- floatNextLocationTotalMovedDist floatTotalMovedDist))
                  ;;计算本次移动步长
                  (setq strMovedDistAndAngle (strcat "@" (rtos floatDodgeStepDist 2 3) strMovedAngle))
                  (command "move"
                           strTextToBeDealedEntityName
                           ""
                           (list 0 0)
                           strMovedDistAndAngle
                  )

                  (setq listTextBoxPoints
                         (GetTextBoxPointList
                           strTextToBeDealedEntityName
                           floatDodgeMinDist
                           floatTextRotationAngle
                         )
                  )

                  (setq floatTotalMovedDist
                         floatNextLocationTotalMovedDist
                  )
                  ;;计算总移动距离

                  (setq ssInPointListBox
                         (ssget "_CP"
                                listTextBoxPoints
                                listFilter
                         )
                  )
                  ;;获取与文本外框相交及在文本框内的所有对象

                  (if (and (> (sslength ssInPointListBox) 0)
                           (ssmemb strTextToBeDealedEntityName
                                   ssInPointListBox
                           )
                      )
                    (ssdel strTextToBeDealedEntityName ssInPointListBox)
                  ) ;去掉需要处理的文本本身
                )

                (setq strDodgeResult "避让失败")
              )
            )

            (if (= strDodgeResult "避让失败")
          ;在指定条件下可以成功避让时，移动文本
              (progn
                (setq strMovedDistAndAngle (strcat "@"
                                                   (rtos (- 0 floatTotalMovedDist) 2 3)
                                                   strMovedAngle
                                           )
                )
                (command "move"
                         strTextToBeDealedEntityName
                         ""
                         (list 0 0)
                         strMovedDistAndAngle
                )
              )
            )
          )

          (setq intNotNeedToDodgeTextNumber
                 (1+ intNotNeedToDodgeTextNumber)
          )
          ;;文本外框不含任何对象且不与任何对象相交时，不需要处理的文本个数+1
        )

      )
      (setq strDodgeResult "避让失败")
    )
    strDodgeResult
  )
;;;-----------------------------------------------------------------------------
;;;计算一个对象和选择集的交点表,成功时返回点表，不成功时返回nil
;;;调用形式：( GetInterPointsList 文本vla对象 选择集 floatTextRotationAngle )
  (defun GetInterPointsList (strTextVlaObject         ssInPointListBox         floatTextRotationAngle   /
                             OriginalPointsList       listResultInterPoints    k
                             intSelectSetNumber       strBoolInterPointsListGeted    strGetInterPointsTest
                             lst_new                  strTextVlaObject
                            )
    (setq intSelectSetNumber (sslength ssInPointListBox)
          OriginalPointsList nil
          listResultInterPoints nil
          k 0
          strBoolInterPointsListGeted "否"
    )

    (while (and (< k intSelectSetNumber)
                (/= strBoolInterPointsListGeted "是")
           )
      (setq strssVlaObject
             (vlax-ename->vla-object
               (ssname ssInPointListBox k)
             )
      )

      (setq strGetInterPointsTest
             (vl-catch-all-apply
               '(lambda (x y)
                  (vla-IntersectWith x y acExtendnone)
                )
               (list strTextVlaObject strssVlaObject)
             )
      )

      (if (vl-catch-all-error-p strGetInterPointsTest)
        (setq strBoolInterPointsListGeted "是"
              strGetInterPointsTest nil
        )

        (if (> (vlax-safearray-get-u-bound
                 (vlax-variant-value strGetInterPointsTest)
                 1
               )
               1
            )
          ;;判断有无交点
          (setq strGetInterPointsTest
                 (vlax-safearray->list
                   (vlax-variant-value
                     strGetInterPointsTest
                   )
                 )
          )

          (setq strBoolInterPointsListGeted "是"
                strGetInterPointsTest nil
          )
        )
      )

      (if strGetInterPointsTest
        (setq OriginalPointsList (append OriginalPointsList strGetInterPointsTest))

        (setq OriginalPointsList nil
              strBoolInterPointsListGeted "是"
        )
      )

      (setq k (1+ k))
    )

    (setq k 0
          listResultInterPoints
           nil
    )
    (while (< k (length OriginalPointsList))
      (setq listResultInterPoints
             (cons
               (list (nth k OriginalPointsList)
                     (nth (+ k 1) OriginalPointsList)
                     (nth (+ k 2) OriginalPointsList)
               )
               listResultInterPoints
             )
      )
      (setq k (+ k 3))
    )     ;取得文本外框与框内符合条件的对象的所有交点表，点表形式

    (if (and (/= strDodgeType "坐标轴方向")
             (/= floatTextRotationAngle 0)
        )
        ;|只有(and (/= strDodgeType "坐标轴方向") (/= floatTextRotationAngle 0))时，
      文字避让处理是按文本局部坐标系来计算的，此时需要转换坐标系；
      其它情况下，均是采用世界坐标系来计算的,此处不需要要求考虑坐标转换问题，因vla-intersectwith返回的就是世界坐标
  |;
      (progn

        ;;转换坐标系
        (setq LST_NEW listResultInterPoints)
        (setq listResultInterPoints nil)

        (foreach PT LST_NEW
          (setq listResultInterPoints
                 (cons (trans PT 0 1)
                       listResultInterPoints
                 )
          )
        )
      )
    )

    listResultInterPoints
  )
;;;-----------------------------------------------------------------------------
;;;修改自zml的函数
;;;功能：获取TEXT对象包围框扩大指定距离后的外框的四角点
;;;调用形式(GetTextBoxPointList     文本对象名  所求外框与原始文本框的距离 文本倾斜角度)
  (defun GetTextBoxPointList
                             (strTextEntityName floatDistOffSet   floatTextRotationAngle              /                 listTextDXF
                              lispTextInsertionPoint              ptlistTextBox     PTA               PTB               PTC
                              PTD               LST_NEW           PT_ANG            PT_DIST
                             )
    ;;插入点、角度
    (setq listTextDXF (entget strTextEntityName))
    (setq lispTextInsertionPoint (cdr (assoc 10 listTextDXF)))

    ;;计算局部坐标系中，偏移后的外框角点
    (setq ptlistTextBox (textbox listTextDXF))
    (setq PTA (list (- (car (car ptlistTextBox)) floatDistOffSet)
                    (- (cadr (car ptlistTextBox)) floatDistOffSet)
                    0
              )
          PTB (list (+ (car (cadr ptlistTextBox)) floatDistOffSet)
                    (+ (cadr (cadr ptlistTextBox)) floatDistOffSet)
                    0
              )
    )
    (setq PTC (list (car PTA) (cadr PTB) 0)
          PTD (list (car PTB) (cadr PTA) 0)
    )
    (setq ptlistTextBox (list PTA PTC PTB PTD))
          ;生成按文本插入点原点，倾斜角度方向为X轴方向的文本四角坐标表

    (if (or (= strDodgeType "坐标轴方向")
            (= floatTextRotationAngle 0)
        )
        ;|只有(and (/= strDodgeType "坐标轴方向") (/= floatTextRotationAngle 0))时，
      文字避让处理是按当前坐标系来计算的，此时不需要转换坐标系,但坐标需要考虑当前插入位置的坐标；
      其它情况下，均是采用世界坐标系来计算的,此处按要求考虑坐标转换问题
  |;
      (progn ;求世界坐标
        (setq LST_NEW nil)
        ;;旋转坐标系
        (foreach PT ptlistTextBox
          (setq PT_DIST (distance '(0 0 0) PT)
                PT_ANG  (angle '(0 0 0) PT)
                PT      (polar '(0 0 0)
                               (+ PT_ANG floatTextRotationAngle)
                               PT_DIST
                        )
                LST_NEW (cons PT LST_NEW)
          )
        )
        ;;平移坐标系
        (setq ptlistTextBox nil)
        (foreach PT LST_NEW
          (setq PT            (mapcar '+ lispTextInsertionPoint PT)
                ptlistTextBox (cons PT ptlistTextBox)
          )
        )
      )

      (progn

        ;;平移坐标系
        (setq LST_NEW ptlistTextBox)
        (setq ptlistTextBox nil
              lispTextInsertionPoint
               (trans lispTextInsertionPoint 0 1)
        )

        (foreach PT LST_NEW
          (setq ptlistTextBox
                 (cons (mapcar '+ lispTextInsertionPoint PT)
                       ptlistTextBox
                 )
          )
        )

      )
    )

    ;;返回
    ptlistTextBox
  )
;;;-----------------------------------------------------------------------------
;;;求出用于作为ssget过滤锁定图层参数的过滤表
;;;调用形式 (listGetLayerNamesFilter )
  (defun listGetLayerNamesFilter (/                     listFilter            strUnLockedLayerNames listUnLockedLayerNames
                                  listExistedLayerNames intLock               LayerName             LayerDXF
                                 )
    (setq LayerDXF (tblnext "LAYER" T)
          listFilter nil
          listUnLockedLayerNames nil
          strUnLockedLayerNames ""
          listExistedLayerNames nil
    )
    (while LayerDXF ;生成未锁定图层表
      (setq LayerName (cdr (assoc 2 LayerDXF)))
      ;;往表中加入已有图层名列表
      (if (/= LayerName "")
        (progn
          (setq listExistedLayerNames
                 (append listExistedLayerNames
                         (list LayerName)
                 )
          )

          (if (and (/= (cdr (assoc 70 LayerDXF)) 4)
                   (/= (cdr (assoc 70 LayerDXF)) 5)
              )
            (setq listUnLockedLayerNames
                   (append listUnLockedLayerNames
                           (list LayerName)
                   )
            )
          )

        )
      )
      (setq LayerDXF (tblnext "LAYER"))
    )


    (if (= (length listExistedLayerNames)
           (length listUnLockedLayerNames)
        )
      (setq listFilter nil) ;所有图层均未锁定时，不设置图层过滤

      (progn
        (setq listFilter nil)
        (mapcar '(lambda (LayerNameI)
                   (if (= strUnLockedLayerNames "")
                     (setq strUnLockedLayerNames LayerNameI)
                     ;;处理第一个图层名时

                     (strcat strUnLockedLayerNames "," LayerNameI)
                     ;;处理第二个及之后图层名时
                   )
                 )
                listUnLockedLayerNames
        )

        (setq listFilter (list (cons 2 listUnLockedLayerNames)))
      )
      ;;含有锁定图层时，把未锁定的图层名作为选择集的过滤条件，并生成相关表

    )
    ;;生成过滤表

    listFilter
  )
;;;-----------------------------------------------------------------------------
;;;对所选择文本进行格式化，并按设置的顺序进行排序
;;;生成文本列表,格式: ( (对象名 插入基点 倾斜角度(角度制)  )...)
;;;不考虑返回值
  (defun FormatSelectedTextsList (/ listTextDXF ;文本的DXF编码
                                  strTextEntityName ;文本对象名
                                  lispTextInsertionPoint ;文本插入基点
                                  floatTextRotationAngle ;文本旋转角度
                                  i)
    (setq i 0
          lispFormatedSelectedTexts
           nil
    )
    (repeat intSelectedTextsNumber ;生成文本列表,格式: ( (对象名 插入基点 倾斜角度(角度制) 字高 ...))
      (setq strTextEntityName (ssname ssSelectedTexts i))
          ; strTextEntityName，取得第i个对象名
      (setq listTextDXF (entget strTextEntityName))
      (setq lispTextInsertionPoint (cdr (assoc 10 listTextDXF)))
      (setq floatTextRotationAngle (cdr (assoc 50 listTextDXF)))

      (setq lispFormatedSelectedTexts
             (append
               lispFormatedSelectedTexts
               (list (list strTextEntityName
                           lispTextInsertionPoint
                           floatTextRotationAngle
                     )
               )
             )
      )

      (setq i (1+ i))
    )

    (cond ;对格式化文本列表进行排序
      ((= strTextDodgeOrder "按选择顺序")
       nil
      )

      ((= strTextDodgeOrder "从左到右")
       (setq lispFormatedSelectedTexts
              (vl-sort
                lispFormatedSelectedTexts
                (function (lambda (e1 e2)
                            (<= (car (cadr e1))
                                (car (cadr e2))
                            )
                          )
                )
              )
       )  ;对格式化文本列表按X坐标从小到大进行排序
      )

      ((= strTextDodgeOrder "从右到左")
       (setq listSortedptlistTextBox
              (vl-sort listTextBoxPoints
                       (function (lambda (e1 e2)
                                   (>= (car (cadr e1))
                                       (car (cadr e2))
                                   )
                                 )
                       )
              )
       )  ;对格式化文本列表按Y坐标从大到小进行排序
      )

      ((= strTextDodgeOrder "从上到下")
       (setq listSortedptlistTextBox
              (vl-sort
                listTextBoxPoints
                (function (lambda (e1 e2)
                            (>= (cadr (cadr e1))
                                (cadr (cadr e2))
                            )
                          )
                )
              )
       )  ;对格式化文本列表按Y坐标从大到小进行排序
      )

      (T  ;(= strTextDodgeOrder "从下到上")
       (setq listSortedptlistTextBox
              (vl-sort
                listTextBoxPoints
                (function (lambda (e1 e2)
                            (<= (cadr (cadr e1))
                                (cadr (cadr e2))
                            )
                          )
                )
              )
       )  ;对格式化文本列表按Y坐标从小到大进行排序
      )
    )

  )
;;;-----------------------------------------------------------------------------
;;;获取对话话上用户的输入
  (defun GetDCLTiles (/ tmpFloat tmpstr)

    (setq tmpstr "")

    (if (= (get_tile "tgDodgeTexts") "1") ;获取是否避让文本
      (setq tmpstr "*Text")
    )


    (if (= (get_tile "tgDodgeLines") "1")
          ;获取是否避让直线、多义线、样条曲线
      (progn
        (if (/= tmpstr "")
          (setq tmpstr (strcat tmpstr ","))
        )

        (setq tmpstr (strcat tmpstr "*LINE"))
      )
    )


    (if (= (get_tile "tgDodgeCirles") "1") ;获取是否避让圆 、圆、椭圆
      (progn
        (if (/= tmpstr "")
          (setq tmpstr (strcat tmpstr ","))
        )

        (setq tmpstr (strcat tmpstr "ARC,CIRCLE,ELLIPSE"))
      )
    )

    (setq listDodgeTargetFilter (list (cons 0 tmpstr)))
          ;生成避让对象格式表

    (setq tmpFloat (atof (get_tile "edMinDist")))
    (if (and tmpFloat (> tmpFloat 0))
      (setq floatDodgeMinDist tmpFloat)
      (setq floatDodgeMinDist 0)
    )
    ;;获取用户输入的控制最小避让间距值

    (setq tmpFloat (atof (get_tile "edFirstDistLimit")))
    (if (and tmpFloat (> tmpFloat 0))
      (setq floatDodgeLimitDistFirst tmpFloat)
      (setq floatDodgeLimitDistFirst 0)
    )
    ;;获取用户输入的第一避让路径最大移动距离

    (setq tmpFloat (atof (get_tile "edSecondDistLimit")))
    (if (and tmpFloat (> tmpFloat 0))
      (setq floatDodgeLimitDistSecond tmpFloat)
      (setq floatDodgeLimitDistSecond 0)
    )
    ;;获取用户输入的第二避让路径最大移动距离
  )
;;;-----------------------------------------------------------------------------
;;;点选文本处理顺序列表时
  (defun plTextDodgeOrderOnClick (strKeyValue)
    (setq strTextDodgeOrder
           (nth (atoi strKeyValue)
                listAllowedTextDodgeOrder
           )
    )
  )
;;;-----------------------------------------------------------------------------
;;;点选图层名列表时
  (defun LayersExistedOnClick (strKeyValue)
    (setq strTargetLayerName
           (nth (atoi strKeyValue) ExistedLayersNameList)
    )
  )
;;;-----------------------------------------------------------------------------
;;;点选按"坐标轴方向"移动文本后
  (defun rbMoveAlongCoordinateAxisDirectionOnClick ()
    (setq strDodgeType "坐标轴方向")
    (rbMoveAlongTextDirectionSet)
  )
;;;-----------------------------------------------------------------------------
;;;点选按"文本方向"移动文本后
  (defun rbMoveAlongTextDirectionOnClick ()
    (setq strDodgeType "文本方向")
    (rbMoveAlongTextDirectionSet)
  )
;;;-----------------------------------------------------------------------------
;;;点选按"文本方向"及"坐标轴方向"移动文本后设置界面中的相关选项
  (defun rbMoveAlongTextDirectionSet ()
    (if (= strDodgeType "文本方向")
      (setq listFirstMoveDirection listMoveAlongTextDirectionDodgeRoute)
      (setq listFirstMoveDirection
             listMoveAlongCoordinateAxisDirectionDodgeRoute
      )
    )

    (ListToPoPupList
      listFirstMoveDirection
      "plFirstMoveDirection"
    )

    (plFirstMoveDirectionOnClick "0")
    (set_tile "plFirstMoveDirection" "0")
  )
;;;-----------------------------------------------------------------------------
;;;点选第一避让方式列表时
  (defun plFirstMoveDirectionOnClick (strValue)
    (setq strDodgeRouteFirst
           (nth (atoi strValue) listFirstMoveDirection)
    )     ;设置第一避让方式

    (setq listSecondMoveDirection (list "不再处理"))
    (mapcar '(lambda (strI)
               (if (/= strI strDodgeRouteFirst)
                 (setq listSecondMoveDirection
                        (append listSecondMoveDirection
                                (list strI)
                        )
                 )
               )
             )
            listFirstMoveDirection
    )
    ;;设置第二避让方式列表

    (ListToPoPupList
      listSecondMoveDirection
      "plSecondMoveDirection"
    )
    (setq strDodgeRouteSecond (nth 0 listSecondMoveDirection))
          ;设置第二避让方式
    (set_tile "plSecondMoveDirection" "0")
  )
;;;-----------------------------------------------------------------------------
;;;点选第二避让方式列表时
  (defun plSecondMoveDirectionOnClick (strValue)
    (setq strDodgeRouteSecond
           (nth (atoi strValue) listSecondMoveDirection)
    )
  )
;;;-----------------------------------------------------------------------------
;;;点选避让失败时是否改变文本颜色选项时
  (defun tgBoolChangeToColorOnClick (strValue)

    (if (= strValue "1")
      (progn
        (setq boolChangeToColor "是")
        (mode_tile "plColorNames" 0)
        (mode_tile "001" 0)
        (mode_tile "002" 0)
        (mode_tile "003" 0)
        (mode_tile "004" 0)
        (mode_tile "005" 0)
        (mode_tile "006" 0)
        (mode_tile "007" 0)
        (mode_tile "008" 0)
        (mode_tile "009" 0)
      )

      (progn
        (setq boolChangeToColor "否")
        (mode_tile "plColorNames" 1)
        (mode_tile "001" 1)
        (mode_tile "002" 1)
        (mode_tile "003" 1)
        (mode_tile "004" 1)
        (mode_tile "005" 1)
        (mode_tile "006" 1)
        (mode_tile "007" 1)
        (mode_tile "008" 1)
        (mode_tile "009" 1)
      )
    )
  )
;;;-----------------------------------------------------------------------------
;;;点选颜色名列表时
  (defun plColorNamesOnClick (strValue)
    (setq intTargetColorName (+ 1 (atoi strValue)))
  )
;;;-----------------------------------------------------------------------------
;;;点选颜色面板时
  (defun ColorPaletteOnClick (intKeyValue)
    (set_tile "plColorNames" (itoa (- intKeyValue 1)))
    (setq intTargetColorName intKeyValue)
  )
;;;-----------------------------------------------------------------------------
;;;点选避让失败时是否改变文本图层选项时
  (defun tgBoolChangeToLayerOnClick (strValue)
    (if (= strValue "1")
      (progn
        (setq boolChangeToLayer "是")
        (mode_tile "plExistedlLayerNames" 0)
      )

      (progn
        (setq boolChangeToLayer "否")
        (mode_tile "plExistedlLayerNames" 1)
      )
    )
  )
;;;-----------------------------------------------------------------------------
;;;点选图层列表时
  (defun plExistedlLayerNamesOnClick (strValue)
    (setq strTargetLayerName
           (nth (atoi strValue) listExistedtLayerNames)
    )
  )
;;;-----------------------------------------------------------------------------
;;;定义出错处理
  (defun *error* (msg)
    (setvar "osmode" 431)
    (vl-cmdf "ucs" "w") ;还原坐标系
    (princ "文字避让程序出错退出或被用户中断运行!")
    (princ)
  )
;;;-----------------------------------------------------------------------------
;;;主函数内容，设置、调用DCL
  (princ "\n选择需要处理的单行文本:")
  (setq ssSelectedTexts (ssget '((0 . "text")))) ; 创建选择集 ob

  (if ssSelectedTexts ;选择有文本时才启动程序界面
    (progn
      (setq intSelectedTextsNumber (sslength ssSelectedTexts))
      (if (setq dcl_id (load_dialog "TextSDodge.dcl"  ))
        (if (new_dialog "TextSDodge" dcl_id)
          (progn
            ;;  (action_tile "btSelectText" "(done_dialog 2)")
            (action_tile
              "rbMoveAlongCoordinateAxisDirection"
              "(rbMoveAlongCoordinateAxisDirectionOnClick)"
            )
            (action_tile
              "rbMoveAlongTextDirection"
              "(rbMoveAlongTextDirectionOnClick)"
            )
            (action_tile
              "plFirstMoveDirection"
              "(plFirstMoveDirectionOnClick $value)"
            )
            (action_tile
              "plSecondMoveDirection"
              "(plSecondMoveDirectionOnClick $value)"
            )
            (action_tile
              "tgBoolChangeToColor"
              "(tgBoolChangeToColorOnClick $value)"
            )

            (action_tile "plColorNames" "(plColorNamesOnClick $value)")

            (action_tile "001" "(ColorPaletteOnClick 1)")
            (action_tile "002" "(ColorPaletteOnClick 2)")

            (action_tile "003" "(ColorPaletteOnClick 3)")
            (action_tile "004" "(ColorPaletteOnClick 4)")

            (action_tile "005" "(ColorPaletteOnClick 5)")
            (action_tile "006" "(ColorPaletteOnClick 6)")
            (action_tile "007" "(ColorPaletteOnClick 7)")
            (action_tile
              "tgBoolChangeToLayer"
              "(tgBoolChangeToLayerOnClick $value)"
            )

            (action_tile
              "plExistedlLayerNames"
              "(plExistedlLayerNamesOnClick $value)"
            )
            (action_tile "accept" "(GetDCLTiles) (done_dialog 1) ")

            (FormMainOnCreat)

            (setq intDialogCloseType (start_dialog))
            (unload_dialog dcl_id)

            (if (= intDialogCloseType 1)
              (DoTextSDodge)
            )
          )

          (princ "无法创建对话框!")
        )
      )
    )

    (princ "未指定需要处理的文本!")
  )
  (princ)
)
;;;-----------------------------------------------------------------------------
(defun c:td ()
  (c:TextSDodge)
  (princ)
)
(princ "文本避让工具,启动命令\"td\"\n")

;;;-----------------------------------------------------------------------------

TextSDodge:dialog {
    label = "重叠文字避让" ;
    spacer;
    :row {
        children_fixed_width = true ;
        label = "需处理的单行文本" ;
        :column {
            children_fixed_width = true ;
            :row {
                children_fixed_width = true ;
                :edit_box {
                    allow_accept = true ;
                    edit_width = 8 ;
                    fixed_width = true ;
                    key = "edSelectedTextNumber" ;
                    label = "已选择文本个数:" ;
                    value = "0" ;
                }
                spacer;
                :popup_list {
                    fixed_width = true ;
                    key = "plTextDodgeOrder" ;
                    label = "处理顺序" ;
                    list = "" ;
                    value = "0" ;
                    width = 26 ;
               }
           //     :button {
           //         key = "btSelectText" ;
           //         label = "选择文本" ;
            //    }
            }
            spacer;
        }
        spacer;
    }
    spacer;
    :column {
        children_fixed_width = true ;
        label = "避让条件设置" ;
        :row {
            children_fixed_width = true ;
            spacer;
            :column {
                children_fixed_width = true ;
                spacer;
                :row {
                    children_fixed_width = true ;
                    label = "避让对象" ;
                    :column {
                        children_fixed_width = true ;
                        :row {
                            children_fixed_width = true ;
                            :toggle {
                                key = "tgDodgeTexts" ;
                                label = "单行文本" ;
                                value = "1" ;
                            }
                            :toggle {
                                key = "tgDodgeLines" ;
                                label = "直线、多段线、样条曲线" ;
                                value = "0" ;
                            }
                            :toggle {
                                key = "tgDodgeCirles" ;
                                label = "圆弧、圆、椭圆" ;
                                value = "0" ;
                            }
                        }
                        spacer;
                    }
                }
                spacer;
                :row {
                    children_fixed_width = true ;
                    :edit_box {
                        allow_accept = true ;
                        edit_width = 8 ;
                        fixed_width = true ;
                        key = "edMinDist" ;
                        label = "文本与其它对象的最小间距:" ;
                        value = "0" ;
                    }
                    spacer;
                }
                spacer;
            }
        }
        spacer;
    }
    spacer;
    :column {
        children_fixed_width = true ;
        label = "避让方式设置" ;
        :row {
            children_fixed_width = true ;
            :column {
                children_fixed_width = true ;
                :row {
                    children_fixed_width = true ;
                    :radio_column {
                        children_fixed_width = true ;
                        spacer;
                        :radio_button {
                            label = "坐标轴方向" ;
                            key = "rbMoveAlongCoordinateAxisDirection" ;
                            value = "1" ;
                        }
                        spacer;
                        :radio_button {
                            label = "文本方向" ;
                            key = "rbMoveAlongTextDirection" ;
                        }
                        spacer;
                    }
                    :column {
                        children_fixed_width = true ;
                        :column {
                            children_fixed_width = true ;
                            label = "移动方向及移动距离限制" ;
                            :row {
                                children_fixed_width = true ;
                                spacer;
                                :popup_list {
                                    fixed_width = true ;
                                    key = "plFirstMoveDirection" ;
                                    label = "第一方向" ;
                                    list = "" ;
                                    value = "0" ;
                                    width = 26 ;
                                }
                                spacer;
                                :edit_box {
                                    allow_accept = true ;
                                    edit_width = 8 ;
                                    fixed_width = true ;
                                    key = "edFirstDistLimit" ;
                                    label = "最大移动距离:" ;
                                    value = "0" ;
                                }
                                spacer;
                            }
                            spacer;
                            :row {
                                children_fixed_width = true ;
                                spacer;
                                :popup_list {
                                    fixed_width = true ;
                                    key = "plSecondMoveDirection" ;
                                    label = "第二方向" ;
                                    list = "" ;
                                    value = "2" ;
                                    width = 26 ;
                                }
                                spacer;
                                :edit_box {
                                    allow_accept = true ;
                                    edit_width = 8 ;
                                    fixed_width = true ;
                                    key = "edSecondDistLimit" ;
                                    label = "最大移动距离:" ;
                                    value = "0" ;
                                }
                                spacer;
                            }
                            spacer;
                        }
                    }
                    spacer;
                }
            }
        }
        :text {
            label = "注：" ;
        }
        :text {
            label = "    1.最大移动距离，0及负数表示不限制。" ;
        }
        :text {
            label = "    2.当文本从第一方向移动失败时，才会向第二方向移动。" ;
        }
        spacer;
    }
    spacer;
    :column {
        children_fixed_width = true ;
        label = "文本避让失败时" ;
        spacer;
        :row {
            children_fixed_width = true ;
            spacer;
            :toggle {
                key = "tgBoolChangeToColor" ;
                label = "颜色改变为：" ;
                value = "0" ;
            }
            :popup_list {
                fixed_width = true ;
                key = "plColorNames" ;
                list = "" ;
                value = "0" ;
                width = 12 ;
            }
            color_palette_1_7;
        }
        spacer;
        :row {
            children_fixed_width = true ;
            spacer;
            :toggle {
                key = "tgBoolChangeToLayer" ;
                label = "转移到图层：" ;
                value = "0" ;
            }
            :popup_list {
                fixed_width = true ;
                key = "plExistedlLayerNames" ;
                list = "0" ;
                value = "0" ;
                width = 30 ;
            }
        }
        spacer;
    }
    spacer;
    :text {
        label = "版权所有：  梁伯全" ;
    }
    :text {
        label = "联系方式：  QQ:32774362   Email:guangdonglbq@qq.com" ;
    }
    :text {
        label = "2008年6月25日  于  广东中山" ;
    }
    ok_cancel;
}

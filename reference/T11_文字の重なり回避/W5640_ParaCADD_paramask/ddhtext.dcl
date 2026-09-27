dcl_settings : default_dcl_settings { audit_level = 3; }

hdtext_spacer : spacer {
    alignment = centered;
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_ebox : edit_box {
    alignment = centered;
    vertical_margin   = tiny;
    horizontal_margin = tiny;
//    height	      = 1;
}
hdtext_toggle : toggle {
    alignment = centered;
    horizontal_margin = tiny;
    vertical_margin   = tiny;
    height	      = 1;
}

hdtext_row : row {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_boxed_row : boxed_row {
    alignment = centered;
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_boxed_radrow : boxed_radio_row {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_col : column {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_boxed_col : boxed_column {
    horizontal_margin = tiny;
//    vertical_margin   = tiny;
}

hdtext_radcol : radio_column {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_radrow : radio_row {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_boxed_radcol : boxed_radio_column {
    horizontal_margin = tiny;
    vertical_margin   = tiny;
}

hdtext_radbutn : radio_button {
    alignment = centered;
    horizontal_margin = tiny;
    vertical_margin   = tiny;
//    height	      = 1;
}

hdtext_text: text {
    vertical_margin   = tiny;
    height	      = 1.15;
}
ddhtext : dialog {
      label = "ParaMASK - Mask Text, Dimensions";
//      : row {
          : column {
          : row {
            : hdtext_boxed_radcol {
              label	= "Location";
              key	= "space_opt";
                : hdtext_radbutn {
                  mnemonic	= "P";
                  label		= "Paper space";
                  key		= "paper_space";
                  value		= "1";
                }
                : hdtext_radbutn {
                  mnemonic	= "M";
                  label		= "Model space";
                  key		= "model_space";
                  value		= "0";
                }
            }
            : hdtext_boxed_radcol {
              label	= "Selection";
              key	= "select_opt";
                : hdtext_radbutn {
                  mnemonic	= "A";
                  label		= "All";
                  key		= "select_all";
                  value		= "1";
                }
                : hdtext_radbutn {
                  mnemonic	= "S";
                  label		= "Select";
                  key		= "select_some";
                  value		= "0";
                }
            }
            }
              : hdtext_boxed_row {
                label	= "Margin";
            : hdtext_toggle {
              mnemonic	= "C";
              label	= "Custom";
              value	= "0";
              key	= "custom_margin";
            }
            : column {
                : hdtext_ebox {
                  mnemonic	= "W";
                  key		= "margin_width";
                  label		= "Width =";
                  edit_width	= 6;
                }
                : hdtext_spacer {
                }
                }
              : hdtext_text {
                label	= "x text height";
                key	= "x_text";
              }
              }
          }
            : hdtext_boxed_row {
              label	= "Apply to:";
//              key	= "apply_opt";
                : hdtext_toggle {
                  mnemonic	= "T";
                  label		= "Text";
                  key		= "apply_text";
                  value		= "1";
                }
                : hdtext_toggle {
                  mnemonic	= "x";
                  label		= "Mtext";
                  key		= "apply_mtext";
                  value		= "1";
                }
                : hdtext_toggle {
                  mnemonic	= "D";
                  label		= "Dimensions";
                  key		= "apply_dims";
                  value		= "1";
                }
            }
            : hdtext_boxed_radrow {
              label	= "Existing Mask Objects";
              key	= "existhd_opt";
                : hdtext_radbutn {
                  mnemonic	= "E";
                  label		= "Erase";
                  key		= "existhd_erase";
                  value		= "0";
                }
                : hdtext_radbutn {
                  mnemonic	= "K";
                  label		= "Keep";
                  value		= "0";
                  key		= "existhd_keep";
                }
            }
//              : boxed_row {
//                 label	= "Coordinates";
//                : spacer {
//                }
//              : hdtext_ebox {
//                key		= "X_coord";
//                label		= " X=";
//                edit_width	= 8;
//                value		= "1.25";
//              }
//                : spacer {
//                }
//              : hdtext_ebox {
//                key		= "Y_coord";
//                label		= " Y=";
//                edit_width	= 8;
//                value		= "0.5";
//              }
//                : spacer {
//                }
//              : hdtext_ebox {
//                key		= "Z_coord";
//                label		= " Z=";
//                edit_width	= 8;
//                value		= "0.0";
//              }
//              }
//            : hdtext_row {
//            : boxed_column {
//                  label	= "X Limits";
//            : hdtext_row {
//              : hdtext_ebox {
//                key		= "x_dist";
//                label		= "Offset X";
//                edit_width	= 6;
//                width		= 14;
//                fixed_width	= true;
//              }
//              : hdtext_text {
//                label	= "from";
//              }
//            }
//            : hdtext_row {
//              : hdtext_radrow {
//                value	= "off_x_left";
//                key	= "x_off";
//                : hdtext_radbutn {
//                  label	= "left";
//                  key	= "off_x_left";
//                  value	= "1";
//                }
//                : hdtext_radbutn {
//                  label	= "right";
//                  key	= "off_x_right";
//                  value	= "0";
//                }
//              }
//              : hdtext_text {
//                label	= "X limits";
//              }
//              }
//              }
//              : boxed_column {
//                  label	= "Y Limits";
//              : hdtext_row {
//              : hdtext_ebox {
//                key		= "y_dist";
//                label		= "Offset Y";
//                edit_width	= 6;
//                width		= 14;
//                fixed_width	= true;
//              }
//              : hdtext_text {
//                label	= "from";
//              }
//              }
//              : hdtext_row {
//              : hdtext_radrow {
//                value	= "off_y_bottom";
//                key	= "y_off";
//                : hdtext_radbutn {
//                  label	= "top";
//                  key	= "off_y_top";
//                  value	= "0";
//                }
//                 : hdtext_radbutn {
//                  label	= "bottom";
//                  key	= "off_y_bottom";
//                  value	= "1";
//                }
//              }
//              : hdtext_text {
//                label	= "Y limits";
//              }
//              }
//              }
//            }
//          }
//        }
      ok_cancel_help;
      errtile;
}

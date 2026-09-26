//     EXCHPROP.DCL        Version 1.0
//
//     Copyright (C) 1991, 1992, 1993, 1994 by Autodesk, Inc.
//
//     Permission to use, copy, modify, and distribute this software
//     for any purpose and without fee is hereby granted, provided
//     that the above copyright notice appears in all copies and
//     that both that copyright notice and the limited warranty and
//     restricted rights notice below appear in all supporting
//     documentation.
//
//     AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.
//     AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
//     MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC.
//     DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
//     UNINTERRUPTED OR ERROR FREE.
//
//     Use, duplication, or disclosure by the U.S. Government is subject to
//     restrictions set forth in FAR 52.227-19 (Commercial Computer
//     Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
//     (Rights in Technical Data and Computer Software), as applicable.
//
//.
//
//    Dialogue for the EXCHPROP command, for use with EXCHPROP.LSP
//


//dcl_settings : default_dcl_settings { audit_level = 3; }


textbox : edit_box {
    vertical_margin = tiny;
    horizontal_margin = tiny;
}

ch_prop : dialog {
    label = "Change Properties";
        : column {
            fixed_width = true;
            : row {
                : button {
                    label = "Color...   ";
                    mnemonic = "C";
                    key = "b_color";
                    width = 15;
                    fixed_width = true;
                }
                : image_button {
                    key = "show_image";
                    height = 1;
                    width = 4;
                }
                : text {
                    key = "t_color";
                    width = 20;
                }
            }
            : row {
                : button {
                    label = "Layer...   ";
                    mnemonic = "L";
                    key = "b_name";
                    width = 15;
                    fixed_width = true;
                }
                : spacer { width = 4; }
                : text {
                    key = "t_layer";
                    width = 20;
                }
            }
            : row {
                : button {
                    label = "Linetype...";
                    mnemonic = "i";
                    key = "b_line";
                    fixed_width = true;
                    width = 15;
                }
                : spacer { width = 4; }
                : text {
                    key = "t_ltype";
                    width = 20;
                }
            } //row
        } //column
    : column {
     spacer;
     : row {
        alignment = centered; 
        fixed_width = true;
        width = 40;
        : text_part {
            label = "Linetype Scale:";
            key = "txt_ltscale";
            mnemonic = "S";
            fixed_width = true;
            width = 20;
        } 
        : edit_box {
            label = "";
            key = "eb_ltscale";
            mnemonic = "S";
            edit_width = 20;
            fixed_width = true;
            width = 20;
        }
     }
     : row {
        alignment = centered; 
        fixed_width = true;
        width = 40;
        : text_part {
            label = "Thickness:";
            key = "txt_thick";
            mnemonic = "T";
            fixed_width = true;
            width = 20;
        } 
        : edit_box {
            label = "";
            key = "eb_thickness";
            mnemonic = "T";
            edit_width = 20;
            fixed_width = true;
            width = 20;
        }
     }    //row
 // support for polyline and text properties
     spacer;
         : boxed_column {
            label = " Polyline ";
            : row {
               alignment = centered; 
               fixed_width = true;
               width = 40;
               : text_part {
                   label = " Width:";
                   key = "txt_width";
                   mnemonic = "W";
                   fixed_width = true;
                   width = 20;
               } 
               : edit_box {
                   label = "";
                   key = "poly_wid";
                   mnemonic = "W";
                   edit_width = 20;
                   width = 20;
                   fixed_width = true;
               }
            } //row
            : row {
               alignment = centered; 
               fixed_width = true;
               width = 40;
               : text_part {
                   label = " Elevation:";
                   key = "txt_elevation";
                   mnemonic = "E";
                   fixed_width = true;
                   width = 20;
               } 
               : edit_box {
                   label = "";
                   key = "poly_elev";
                   mnemonic = "E";
                   edit_width = 20;
                   width = 20;
                   fixed_width = true;
               }
            } //row
         }
         : boxed_column {
             label = " Text/Mtext/Attdef ";
            : row {
               alignment = centered; 
               fixed_width = true;
               width = 40;
               : text_part {
                   label = " Height:";
                   key = "txt_height";
                   mnemonic = "g";
                   fixed_width = true;
                   width = 20;
               } 
               : edit_box {
                   label = "";
                   mnemonic = "g";
                   key = "text_hgt";
                   edit_width = 20;
                   width = 20;
                   fixed_width = true;
               }
            } //row
            : row {
               alignment = centered; 
               fixed_width = true;
               width = 42;
               : text_part {
                   label = " Style:";
                   key = "txt_style";
                   mnemonic = "y";
                   fixed_width = true;
                   width = 20;
               } 
               : popup_list {
                   label = "";
                   mnemonic = "y";
                   key = "text_style";
                   width = 22;
                   fixed_width = true;
               }
            } //row
         }
 // end support for polyline and text properties
    } //end column
//    spacer;
//    spacer;
//    spacer;
//    ok_cancel_help_errtile;
//   spacer;
//    : column {
//       alignment = centered; 
//       fixed_width = true;
//       width = 42;
     : text_part {
        key = "error";
     }
     ok_cancel_help;
//    }
}

setcolor : dialog {
    label = "Select Color";
    image_block;
    : list_box {
        key = "list_col";
        allow_accept = true;
    }
    : textbox {
        key = "edit_col";
        allow_accept = false;
        label = "Color Code:";
        edit_width = 13;
     }
     ok_cancel_err;
}

setltype : dialog {
    label = "Select Linetype";
    image_block;
    : list_box {
        key = "list_lt";
        allow_accept = true;
    }
    : edit_box {
        key = "edit_lt";
        allow_accept = false;
        label = "Linetype:";
        mnemonic = "L";
    edit_limit = 217;
    }
    ok_cancel;
    errtile;
}

setlayer : dialog {
    subassembly = 0;
    label = "Select Layer";
    initial_focus = "listbox";
    : concatenation {
        children_fixed_width = true;
        key = "clayer";
        : text_part {
            label = "Current Layer: ";
        }
        : text_part {
            key = "cur_layer";
            width = 35;
        }
    }
    : row {
        fixed_width = true;
        key = "titles";
        children_fixed_width = true;
        : text {
            label = "Layer Name";
            width = 34;
        }
        : text {
            label = "State";
            width = 9;
        }
        : text {
            label = "Color";
            width = 8;
        }
        : text {
            label = "Linetype";
        }
    }
    : list_box {
        width = 67;
        tabs = "32 35 37 39 41 44 53";
        height = 12;
        key = "list_lay";
        allow_accept = true;
    }
    : row {
        key = "controls";
        : column {
            key = "lname";
            fixed_width = true;
            : edit_box {
                label = "Set Layer Name:";
                mnemonic = "S";
                key = "edit_lay";
                edit_width = 32;
                edit_limit = 217;
                allow_accept = true;
            }
        }
    }
    ok_cancel_err;
}



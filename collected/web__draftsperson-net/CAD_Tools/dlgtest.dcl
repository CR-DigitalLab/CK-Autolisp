// Next available MSG number is    24 
// MODULE_ID DLGTEST_DCL_
/* Next available MSG number is  24 */

//----------------------------------------------------------------------------
//
//   DLGTEST.DCL   Version 1.0
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
//----------------------------------------------------------------------------
//
//  Dlgtest.dcl - For use with dlgtest.c and dlgtest.lsp
//   (Test Programs for User Programmable Dialog Boxes)
//
//----------------------------------------------------------------------------

//dcl_settings : default_dcl_settings { audit_level = 3; }

// Display and set some of the dimensioning variables
dimensions : dialog {
    aspect_ratio = 0;
    label = "AutoCAD Dimension Controls";
    : cluster {
        : cluster {
            layout = vertical;
            : cluster {
                layout = vertical;
                : toggle {
                    label = "Suppress Extension line 1";
                    key = "dimse1";
                }
                : toggle {
                    label = "Suppress Extension line 2";
                    key = "dimse2";
                }
                : toggle {
                    label = "Text Inside Horizontal";
                    key = "dimtih";
                }
                : toggle {
                    label = "Text Outside Horizontal";
                    key = "dimtoh";
                }
                : toggle {
                    label = "Text Above Dimension Line";
                    key = "dimtad";
                }
                : toggle {
                    label = "Append tolerance";
                    key = "dimtol";
                }
                : toggle {
                    label = "Generate limits";
                    key = "dimlim";
                }
                : toggle {
                    label = "Alternate units";
                    key = "dimalt";
                }
                : toggle {
                    label = "Associative dimensioning";
                    key = "dimaso";
                }
                : toggle {
                    label = "Show new dimension";
                    key = "dimsho";
                }
            }
        }
        : cluster {
            layout = vertical;
            : cluster {
                layout = vertical;
                : edit_box {
                    label = "Arrow size";
                    key = "dimasz";
                }
                : edit_box {
                    label = "Tick size";
                    key = "dimtsz";
                }
                : edit_box {
                    label = "Text size";
                    key = "dimtxt";
                }
                : edit_box {
                    label = "Center mark size";
                    key = "dimcen";
                }
                : edit_box {
                    label = "Extension line offset";
                    key = "dimexo";
                }
                : edit_box {
                    label = "Extension line extension";
                    key = "dimexe";
                }
                : edit_box {
                    label = "Dimension line extension";
                    key = "dimdle";
                }
            }
        }
    }
    ok_cancel;
    errtile;
}





// TestLisp DCL (Dialog Control Language)
// Test Proteus/LISP

setcolor : dialog {
    aspect_ratio = 0;
    label = "Select Color";
    : cluster {
        layout = vertical;
        image_block;
        : list_box {
            key = "list_col";
            allow_accept = true;
        }
        : edit_box {
            key = "edit_col";
            allow_accept = true;
            label = "Color code";
            edit_width = 10;
            fixed_width = true;
        }
    }
    ok_cancel_help;
    errtile;
}


chgtext : dialog {
    aspect_ratio = 0;
    label = "Change Text";
    initial_focus = "old_str";
    : edit_box {
        key = "old_str";
        label = "Old String:";
        edit_width = 30;
        fixed_width = true;
        width = 45;
    }
    : edit_box {
        key = "new_str";
        allow_accept = true;
        label = "New String:";
        edit_width = 30;
        fixed_width = true;
        width = 45;
    }
    ok_cancel;
    errtile;
}

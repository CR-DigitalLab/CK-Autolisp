//     LMAN.DCL
//     Copyright (C) 1997 by Autodesk, Inc.
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
//----------------------------------------------------------------------------


lman : dialog {
    label = "Layer Manager: Save and Restore Layer Settings";
    : row {
      : list_box {
          label = "Saved Layer states:";
          mnemonic = "L";
          width = 42;
          tabs = "34";
          key = "list_states";
          tab_truncate = true;
      }
      : column {
          spacer_1;
          : button {
              label = "Save...";
              mnemonic = "S";
              //fixed_width=true;
              //width=18;
              key = "saveas";
          }
          : button {
              label = "Edit...";
              mnemonic = "E";
              //fixed_width=true;
              //width=18;
              key = "edit";
          }
          spacer_1;
          : button {
              label = "Delete";
              mnemonic = "D";
              //fixed_width=true;
              //width=18;
              key = "delete";
          }
          spacer_1;
          : button {
              label = "Import...";
              mnemonic = "I";
              //fixed_width=true;
              //width=18;
              key = "import";
          }
          : button {
              label = "eXport...";
              mnemonic = "X";
              //fixed_width=true;
              //width=18;
              key = "export";
          }
     }
    } 
    : text_part
    { label = "          ";
      key   = "msg"; 
    }
    : row {
      spacer_1;
      : button {
         label = "Restore";
         width=14;
         fixed_width=true;
         mnemonic = "R";
         key = "restore";
      }
      //spacer_1;
      : button {
         label = "Close";
         fixed_width=true;
         width=14;
         mnemonic = "C";
         key = "close";
         is_cancel =true;
      }
      spacer_1;  
    }
}

new_lman : dialog {
    label = "Layer state name";
    : text_part {
        key = "new_msg";
        value = "";
        width = 32;     
    } 
    : edit_box {
        //label = "New name:";
        key = "new_name";
        value = "";
        width = 32;     
    } 
    : row {
      spacer_1;
      : button {
         label = "OK";
         width=10;
         fixed_width=true;
         mnemonic = "A";
         is_default=true;
         key = "accept";
      }
      spacer_1;
      : button {
         label = "Cancel";
         fixed_width=true;
         width=10;
         mnemonic = "C";
         key = "cancel";
         is_cancel =true;
      }
      spacer_1;  
    }
}

warning : dialog {
    label = "* Warning! *";
    spacer_1;
    //alignment = centered;
    : column {
     : text_part {
         key = "warn_msg";
         value = "";
         width = 42;     
     } 
     : text_part {
         key = "warn_msg2";
         value = "";
         width = 42;     
     } 
    }
    spacer_1;
    : row {
      spacer_1;
      : button {
         label = "Yes";
         width=10;
         fixed_width=true;
         mnemonic = "Y";
         key = "accept";
      }
      spacer_1;
      : button {
         label = "No";
         fixed_width=true;
         width=10;
         mnemonic = "N";
         key = "cancel";
         is_cancel =true;
      }
      spacer_1;  
    }
}

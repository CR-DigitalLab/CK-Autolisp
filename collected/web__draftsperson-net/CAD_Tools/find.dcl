//     FIND.DCL
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
//      Credits: Greg Robinson
//               Bill Kramer Q.C.

find : dialog {
   label = "Find and Replace";
   : column {
      : edit_box {
         label = "Find:";
         key = "find";
         mnemonic = "F";
         edit_width = 30;
      }  
      : edit_box {
         label = "Replace With:";
         key = "replace";
         mnemonic = "R";
         edit_width = 30;
      }  
   }   
   spacer_1 ;
   : row {
      : toggle {
         label = "Case Sensitive";
         key = "case";
         mnemonic = "C";
         alignment = left;
      }   
      : toggle {
         label = "Global Change";
         key = "global";
         mnemonic = "G";
         alignment = right;
      }   
   }   
   spacer_1 ;
   : column {
      ok_cancel;
      errtile;
   }   
}
find2 : dialog {
   label = "Find and Replace";
   : row {
      : button {
         label = "Replace";
         fixed_width = true;
         alignment = centered;
         key = "accept";
         mnemonic = "R";
      }  
      : spacer { width = 2; }
      : button {
         label = " Auto  ";
         fixed_width = true;
         alignment = centered;
         key = "auto";
         mnemonic = "A";
      }  
      : spacer { width = 2; }
      : button {
         label = " Skip  ";
         fixed_width = true;
         alignment = centered;
         key = "skip";
         mnemonic = "S";
      }  
      : spacer { width = 2; }
      cancel_button;
   }   
   errtile;
}

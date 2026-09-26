//     xlist.dcl
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
xlistblock : dialog {
label = "Xref/Block Nested Object List";
: row {	
	spacer; spacer;
	: column {
		: text {
		label = "Object:";
		//width = 12;
		//fixed_width = true; 
		}  
		: text {
		label = "Block Name:";
		}
		: text {
		label = "Layer:";
		}
		: text  {
		label = "Color:";
		}
		: text {
		label = "Linetype:";
		}
	}	
	: column {
		: text { 
		key = "sObjectType"; 
		//width = 35; 
		//fixed_width = true;
		}
		: text { 
		key = "sBlockname"; 
		}
		: text { 
		key = "sLayer"; 
		width = 31; 
		}
		: text { 
		key = "sColor";  
		}
		: text { 
		key = "sLineType"; 
		}
	}
}
ok_only;
}



xlisttext : dialog {
label = "Xref/Block Nested Object List";
: row {	
	spacer; spacer;
	: column {
		: text {
		label = "Object:";
		//width = 12;
		//fixed_width = true; 
		}  
		: text {
		label = "Style Name:";
		}
		: text {
		label = "Layer:";
		}
		: text  {
		label = "Color:";
		}
		: text {
		label = "Linetype:";
		}
	}	
	: column {
		: text { 
		key = "sObjectType"; 
		//width = 35; 
		//fixed_width = true;
		}
		: text { 
		key = "sStyleName"; 
		}
		: text { 
		key = "sLayer"; 
		width = 31; 
		}
		: text { 
		key = "sColor";  
		}
		: text { 
		key = "sLineType"; 
		}
	}
}
ok_only;
}



xlist : dialog {
label = "Xref/Block Nested Object List";
: row {	
	spacer; spacer;
	: column {
		: text {
		label = "Object:";
		//width = 12;
		//fixed_width = true; 
		}  
		: text {
		label = "Layer:";
		}
		: text  {
		label = "Color:";
		}
		: text {
		label = "Linetype:";
		}
	}	
	: column {
		: text { 
		key = "sObjectType"; 
		//width = 35; 
		//fixed_width = true;
		}
		: text { 
		key = "sLayer"; 
		width = 31; 
		}
		: text { 
		key = "sColor";  
		}
		: text { 
		key = "sLineType"; 
		}
	}
}
ok_only;
}

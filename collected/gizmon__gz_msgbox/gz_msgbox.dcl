dcl_settings : default_dcl_settings { audit_level = 3; }
//////////////////////////////////////////////////////////////////////
// メッセージボックス表示 LISP関数用ダイアログ
// using : gz_msgbox.lsp
//////////////////////////////////////////////////////////////////////
lspOkCancel : dialog {
  key = "main";
  initial_focus = "cancel";
  : column {
	: text {
	  key = "message1";
	  width = 20;
	}
	: text {
	  key = "message2";
	  width = 20;
	}
	: text {
	  key = "message3";
	  width = 20;
	}
  }
  : spacer { width = 1; }
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	  is_default = true;
	}
    : spacer { width = 1; }
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
}

//////////////////////////////////////////////////////////////////////
lspYesNo : dialog {
  key = "main";
  initial_focus = "no";
  : column {
	: text {
	  key = "message1";
	  width = 50;
	}
 	: text {
	  key = "message2";
	  width = 50;
	}
	: text {
	  key = "message3";
	  width = 50;
	}
  }
  : row {
	: spacer { width = 1; }
	: button {
	  key = "yes";
	  label = "はい (Y)";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "Y";
	  is_default = true;
	}
	: button {
	  key = "no";
	  label = "いいえ (N)";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "N";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
}

//////////////////////////////////////////////////////////////////////
lspOkOnly : dialog {
	key = "main";
  : column {
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
  }
  : row {
	: spacer { 
	  width = 1; 
	}
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	  is_default = true;
	  alignment = centered;
	}
	: spacer { 
	  width = 1;
	}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspYesNoCancel : dialog {
  key = "main";
  initial_focus = "cancel";

  : column {
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
  }
  : row {
	: spacer { width = 1; }
	: button {
	  key = "yes";
	  label = "はい (Y)";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "Y";
	  is_default = true;
	}
	: button {
	  key = "no";
	  label = "いいえ (N)";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "N";
  	}
	: button {
	  key = "cancel";
	  label = "キャンセル (C)";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;
	}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspRetryCancel : dialog {
  key = "main";
  initial_focus = "retry";

  : column {
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
	}
  : row {
	: spacer { width = 1; }
	: button {
	  label = "再試行 (R)";
	  key = "retry";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "R";
	  is_default = true;
	}
	: button {
	  label = "キャンセル (C)";
	  key = "Cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspGetPass : dialog {
  key = "main";
  initial_focus = "password";
  : column {
	: spacer { width = 1; }
	: text {
	  key = "message1";
	  width = 20;
	       }
	: text {
	  key = "message2";
	  width = 20;
	       }
	: text {
	  key = "message3";
	  width = 20;
	       }
    : spacer { width = 1; }
	}
  : edit_box { 
    label = "パスワード:"; 
    edit_width = 24; 
    key = "password"; 
    password_char = "*"; 
    is_default = true;
	allow_accept = true;
	} 
  : spacer { width = 1; }
	
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	}
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspInputBox : dialog {
  key = "main";
  initial_focus = "textbox";
  : row {
	: column {
		 width = 47;
		: spacer { width = 1; }
		: text {
		key = "message1";
		width = 20;
		       }
		: text {
		key = "message2";
		width = 20;
		       }
		: text {
		key = "message3";
		width = 20;
		       }
		: text {
		key = "message4";
		width = 20;
		       }
		: spacer { width = 1; }
	}
	: column {
		: button {
		  key = "accept";
		  label = "OK";
		  width = 3;
		  mnemonic = "O";
		  is_default = true;
		}
		: button {
		  label = "キャンセル (C)";
		  key = "cancel";
		  width = 3;
		  mnemonic = "C";
		  is_cancel = true;
		}
		: spacer { width = 1; }
	}
  }
  : edit_box { 
	edit_width = 60; 
	label = " ";
	key = "textbox";
	allow_accept = true;
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspInputBox2 : dialog {
  key = "main";
  initial_focus = "textbox";
  : row {
	: column {
		 width = 47;
		: spacer { width = 1; }
		: text {
		key = "message1";
		width = 20;
		       }
		: text {
		key = "message2";
		width = 20;
		       }
		: text {
		key = "message3";
		width = 20;
		       }
		: text {
		key = "message4";
		width = 20;
		       }
		: spacer { width = 1; }
	}
  }
  : edit_box { 
	edit_width = 60; 
	label = " ";
	key = "textbox";
	allow_accept = true;
  }
  : row {
	: button {
		  key = "accept";
		  label = "OK";
		  width = 3;
		  mnemonic = "O";
		  is_default = true;
	}
	: button {
		  label = "キャンセル (C)";
		  key = "cancel";
		  width = 3;
		  mnemonic = "C";
		  is_cancel = true;
	}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 66;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspInputBox3 : dialog {
  key = "main";
  initial_focus = "textbox";
  : row {
	  : column {
		 width = 47;
		: spacer { width = 1; }
		: text {
			key = "message1";
			width = 20;
		}
		: text {
			key = "message2";
			width = 20;
		}
		: text {
			key = "message3";
			width = 20;
		}
		: text {
			key = "message4";
			width = 20;
		}
		: spacer { width = 1; }
		: toggle {
			key = "chk1";
			label = "カウントアップで連続指示する";
	    }
		: spacer { width = 1; }
	  }
	}
	: spacer { width = 1; }
  : edit_box { 
		edit_width = 60; 
		label = " ";
		key = "textbox";
		allow_accept = true;
  }
  : row {
	: button {
		  key = "accept";
		  label = "OK";
		  width = 3;
		  mnemonic = "O";
		  is_default = true;
	}
	: button {
		  label = "キャンセル (C)";
		  key = "cancel";
		  width = 3;
		  mnemonic = "C";
		  is_cancel = true;
	}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 66;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspCombobox : dialog {
  key = "main";
  initial_focus = "poplist";
  : column {
	: spacer { width = 1; }
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
    : spacer { width = 1; }
    : popup_list{
       key = "poplist";
       label = "項目";
       edit_width = 48;
    }
    : spacer { width = 1; }
  }
  : spacer { width = 1; }
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	}
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspListbox : dialog {
  key = "main";
  initial_focus = "listbox";
  : column {
	: spacer { width = 1; }
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
    : spacer { width = 1; }
    : list_box{
       key = "listbox";
       label = "項目";
       edit_width = 48;
       allow_accept = false;
    }
    : spacer { width = 1; }
  }
  : spacer { width = 1; }
	
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	}
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspListboxMulti : dialog {
  key = "main";
  initial_focus = "listbox";
  : column {
	: spacer { width = 1; }
	: text {
	key = "message1";
	  width = 20;
	       }
	: text {
	key = "message2";
	  width = 20;
	       }
	: text {
	key = "message3";
	  width = 20;
	       }
    : spacer { width = 1; }
    : list_box{
       key = "listbox";
       label = "項目";
       edit_width = 80;
       allow_accept = false;
       multiple_select = true;
    }
    : spacer { width = 1; }
  }
  : spacer { width = 1; }
	
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	}
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
// 上部メッセージ無しタイプ
lspListboxMulti0 : dialog {
  key = "main";
  initial_focus = "listbox";
  : column {
    width = 75;

    : list_box{
       key = "listbox";
       edit_width = 80;
       allow_accept = true;
       multiple_select = true;
    }
    : spacer { width = 1; }
  }
  : spacer { width = 1; }
	
  : row {
	: spacer { width = 1; }
	: button {
	  key = "accept";
	  label = "OK";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "O";
	}
	: button {
	  label = "キャンセル (C)";
	  key = "cancel";
	  width = 12;
	  fixed_width = true;
	  mnemonic = "C";
	  is_cancel = true;
	}
	: spacer { width = 1;}
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 60;
    }
  }
  // ij2020 bug avoidance
}

//////////////////////////////////////////////////////////////////////
lspEd : dialog {
  label = "文字の編集";
  initial_focus = "contents";
  : edit_box {
    label = "内容:";
    key = "contents";
    edit_width = 40;
    edit_limit = 256;
    allow_accept = true;
  }
  spacer;
  : column {
    : row {
      fixed_width = true;
      alignment = centered;
      ok_button;
      : spacer { width = 2; }
      cancel_button;
      : spacer { width = 2; }
    }
  }
  // ij2020 bug avoidance
  : column { 
    : text { 
     key = "bug_avoidance";
     width = 50;
    }
  }
  // ij2020 bug avoidance
}
//////////////////////////////////////////////////////////////////////

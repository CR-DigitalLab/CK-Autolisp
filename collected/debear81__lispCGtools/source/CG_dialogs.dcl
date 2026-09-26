//---------------------------------------------------------------------------------------------------------
// DCL for use with CG3D.lsp`
// Dialog Box for User Input Values
//: text { label = "Dwg. Units"; }
//-------------------------------------------------------------------------------------------------------
CG3d_MatDlg : dialog {
	label = "Enter Material Densities";
	: text { label = "Enter material densities for each layer (material), according to the active drawing units."; width = 75; }
	: text { label = "Typical US Customary densities:"; width = 75; }
	: text { label = "Steel: 490 lbs/cu.ft. = 490/1728 lbs/cu.in. ~ 0.283565 lbs/cu.in."; width = 75; }
	: text { label = "Conc: 150 lbs/cu.ft. = 150/1728 lbs/cu.in. ~ 0.086806 lbs/cu.in."; width = 75; }
	: text { label = "Alum: 170 lbs/cu.ft. = 170/1728 lbs/cu.in. ~ 0.098380 lbs/cu.in."; width = 75; }
	: text { label = "Wood: 45 lbs/cu.ft. = 45/1728 lbs/cu.in. ~ 0.026042 lbs/cu.in."; width = 75; }	
	: text { label = " "; width = 75; }
	: text { label = "Input the numerical values only. No units."; width = 50; }
	: row { : text { key = "label1"; label = "Material Layer 1:"; width = 25; }
			: edit_box { key = "mat1"; width = 25; }
			}
	: row { : text { key = "label2"; label = "Material Layer 2:"; width = 25; }
			: edit_box { key = "mat2"; width = 25; }
			}
	: row { : text { key = "label3"; label = "Material Layer 3:"; width = 25; }
			: edit_box { key = "mat3"; width = 25; }
			}
	: row { : text { key = "label4"; label = "Material Layer 4:"; width = 25; }
			: edit_box { key = "mat4"; width = 25; }
			}
	: row { : text { key = "label5"; label = "Material Layer 5:"; width = 25; }
			: edit_box { key = "mat5"; width = 25; }
			}
	: row { : text { key = "label6"; label = "Material Layer 6:"; width = 25; }
			: edit_box { key = "mat6"; width = 25; }
			}
	: row { : text { label = " "; width = 75; }
			}
	: row { : text { key = "Sphere1"; label = "Layer Name for Sphere:"; width = 25; }
			: edit_box { key = "SphLay"; width = 25; value = "CGsphere"; }
			}
	: row { : text { key = "Sphere2"; label = "Sphere Diam. (dwg units):"; width = 25; }
			: edit_box { key = "SphDiam"; width = 25; value = "4"; }
			}
	: row { : button { label = "OK"; is_default = true; key = "accept"; }
			: button { label = "Cancel"; is_cancel = true; key = "cancel"; }
			}
}

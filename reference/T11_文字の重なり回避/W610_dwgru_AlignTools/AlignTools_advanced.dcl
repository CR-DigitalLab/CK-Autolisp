// AlignTools.dcl - Диалоговое окно выравнивания и распределения
align_tools : dialog {

    label = "Выравнивание и распределение объектов";
    : row {
		: column {label = "Выровнять";
			
			: boxed_row {
				label = "по горизонтали";
				: button {
					key = "al";
					label = "<<"; // Левый край
				}
				: button {
					key = "acx";
					label = ">|<"; // По центру
				}
				: button {
					key = "ar";
					label = ">>"; // Правый край
				}
			}

			: boxed_row {
				label = "по вертикали";
				: button {
					key = "at";
					label = "^^ "; // Верхний край
				}
				: button {
					key = "acy";
					label = "---"; // По центру
				}
				: button {
					key = "ab";
					label = "__"; // Нижний край
				}
			}
		}

		: column {label = "Распределить";
			
			: boxed_row {
				label = "по горизонтали";
				: button {
					key = "rlx";
					label = "< .. <"; // Левый край
				}
				: button {
					key = "rcx";
					label = "| .. |"; // По центру
				}
				: button {
					key = "rrx";
					label = "> .. >"; // Правый край
				}
				
				: button {
					key = "rzx";
					label = "< zz >"; // по зазорам
				}

			}

			: boxed_row {
				label = "по вертикали";
				: button {
					key = "rty";
					label = "^ .. ^"; // Верхний край
				}
				: button {
					key = "rcy";
					label = "- .. -"; // По центру
				}
				: button {
					key = "rby";
					label = "_ .. _"; // Нижний край
				}
				: button {
					key = "rzy";
					label = "^ zz _"; // по зазорам
				}
			}
		}
		
        
		: column {label = "Распределить с указанным расстоянием";
			
			: boxed_row {
				label = "по горизонтали";
				: button {
					key = "rlxd";
					label = "< xx <"; // Левый край
				}
				: button {
					key = "rcxd";
					label = "| xx |"; // По центру
				}
				: button {
					key = "rrxd";
					label = "> xx >"; // Правый край
				}
				
				: button {
					key = "rzxd";
					label = "< xx >"; // по зазорам
				}

			}

			: boxed_row {
				label = "по вертикали";
				: button {
					key = "rtyd";
					label = "^ xx ^"; // Верхний край
				}
				: button {
					key = "rcyd";
					label = "- xx -"; // По центру
				}
				: button {
					key = "rbyd";
					label = "_ xx _"; // Нижний край
				}
				: button {
					key = "rzyd";
					label = "^ xx _"; // по зазорам
					//width = 5;
					//fixed_width = true;
				}
			}
		}
       
        
        
    }
  
    spacer;
    ok_cancel;
}
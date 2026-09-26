# AutoLispCogo
LISP based coordinate geometry functions for AutoCAD

# cogo.lsp
Record coordinate geometry points from AcadCAD into a text based cogo file.
Allows user to select points (c:p), adds a description and places a point 
number on the draiwing.  User can also select and set elevation (c:pe) and
print a table of cogo coordinates (c:cogotable)

# bluefix.lsp
Changes color of entities in selection set to a new color value
based on the original color value (ie. translation table). Does not change 'bylayer' color value.

;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;       Developed by Rustin Gesner, Joseph Smith, and Patrick Haessly       
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
;;;* GROUP.LSP defines a function for creating and accessing groups of
;;;* entities in much the same way as blocks, but the entities may
;;;* be edited individually as well as together. This is accomplished by
;;;* attaching invisible extended data to each entity in the group. Groups
;;;* may contain any AutoCAD entities, including blocks, polylines and
;;;* attdefs. Multiple groups can be created, and individual entities
;;;* may be members of more than one group. When an entity is copied, the
;;;* group name is copied along with it, creating a new entity belonging
;;;* to the original group (or groups). Use this function to maintain
;;;* complex selection sets for editing or in parametric programs
;;;* to work with groups of entities yet be able to change any one.
;;;* The command may be invoked transparently:
;;;*   Command: ERASE
;;;*   Select objects: 'GROUP

(load "UENTSL")                                         ;Loads subroutine

(if (not (and dxf uentsl))                              ;Test subroutines   
  (prompt "\nRequires DXF and UENTSL functions. Load aborted. ")            
  (progn                                                ;else load OK

;;C:GROUP is the "front-end" function which presents the user options,
;;and calls the appropriate subroutine to build, select, query or list
;;grouped entities. The function requires some of the standard IL LISP
;;library functions.

(defun c:group ( / opt ss selectflag)

  ;; Put the whole program in a while loop; the user may wish to perform
  ;; several grouping operations.
  (while
    (setq
      opt (ukword                                  ;Get the option from user
            0                                      ;Bit, allows null to exit
            "Create Select Remove Query ?"         ;Keywords
            "Group (Create/Select/Remove/Query/?)" ;The prompt
            nil                                    ;The default, nil to exit
          );ukword
    );setq

    ;; Now test the user's keyword and act accordingly
    (cond

      ;; This option permits the user to create groups.
      ;; Any set of entities may be selected and turned into a group.
      ;; Groups may intersect other groups. In fact there are no limitations
      ;; on how the user may combine entities in the groups.
      ((= opt "Create")
        (group_create)
      );create opt

      ;; User wants to make a selection set of objects defined in the group
      ((= opt "Select")
        (setq
          ss (group_select)
          selectflag T
        )
      );select opt

      ;; The user wishes to remove some entities from a group
      ((= opt "Remove")
        (group_remove)
      );remove opt

      ;; The user wants to know which groups are attached to an entity
      ((= opt "Query")
        (group_query)
      ); query opt

      ;; The user wants a listing of the defined group names in the drawing
      ((= opt "?")
        (group_list)
      ); ? opt

    );cond
  );while

  ;; Decide what to return if the user did a select option
  (if selectflag
    (progn
      ;; The CMDACTIVE system variable tells if a command is active.
      ;; If one is active, this function may have been called
      ;; transparently with 'GROUP and can return the selection
      ;; set directly to AutoCAD without needing to place the
      ;; entities in a Previous selection set. It is assumed
      ;; the user has invoked the program during a "Select objects:"
      ;; type of prompt for an AutoCAD editing command.
      (if (/= 0 (getvar "cmdactive"))
        ss                             ;Let the SS return out
        (progn
          (if ss
            (command "_.select" ss "") ;Force into the previous set
          )
          (princ)                      ;End cleanly for this option
        );progn
      );if
    );progn
    (princ)                            ;End cleanly for this option
  );if
);defun


;;; Create a group
(defun group_create ( / regname en ed ss count smax xd)
  ;; Ask for name, upper case it.
  (setq
    #grpname (ustr 1 "Group name " #grpname nil)
    #grpname (strcase #grpname)
    regname (strcat "IL_GRP" #grpname)
  );setq

  ;; Allow selection of any entities that are not already in the group. 
  ;; Use the NOT operator to exclude these names. No need to retag the members.
  ;; Also, it saves having to trap for duplicate group data. 
  (if (setq ss (ssget (list '(-4 . "<NOT")
                              (list -3 (list regname))
                            '(-4 . "NOT>")
                      );list
               );ssget
      );setq
    (progn
      ;; Register the application name
      (regapp regname)
      (setq
        smax (sslength ss)                ;Set up counters to go
        count 0                           ;Process the selection set
        ;; Make a piece of extended data so each selected
        ;; entity keeps the xdata application id with it
        xd (list (cons 1000 "."))         ;Make xdata-type list
        xd (cons regname xd)              ;Add app name
        xd (list -3 xd)                   ;Add app -3 sentinal
      );setq
      (while (< count smax)           ;Loop through the selection set
        (setq
          en (ssname ss count)        ;Get entity name
          ed (entget en)              ;Need only edata, not xdata
          ed (append ed (list xd))    ;Add xdata list to edata list
          count (1+ count)            ;Increment the counter
        );setq
        (entmod ed)                   ;Update the entity w/ xdata added;
                                      ;existing xdata for all other appids
                                      ;is preserved
      );while
    );progn
  );if
);defun


;;; Makes a selection set from a group name
(defun group_select ( / regname ss)
  ;; Ask user which group name; upper case it for comparisons
  (setq
    #grpname (ustr 1 "Group name " #grpname nil)
    #grpname (strcase #grpname)
    regname (strcat "IL_GRP" #grpname)
  )

  ;; Search the database for the group and return the set if found;
  ;; else inform the user with prompt, which returns nil.
  (if (setq ss (ssget "X" (list (list -3 (list regname)))))
    (progn
      (prompt " ")                      ;Print a space
      (princ (sslength ss))             ;Print the number found
      (prompt " found.")                ;Finish the info
      ss                                ;Return the selection set
    );progn
    (prompt "\nThere are no entities for that group.")
  );if
);defun



;;; The user wants to know which groups are defined for 
;;; a particular entity.
(defun group_query ( / es en ed appdata name grplist)
  (setq es (uentsl 1 "" "" nil))        ;Get an entity, default the prompt
  (if (and es (listp es))               ;If an entity was selected
    (progn
      (setq
        en (car es)                     ;Get entity name from pickset
        ed (entget en '("IL_GRP*"))     ;Look for all IL_GRP app
      );setq
      (if (dxf -3 ed)                       ;If it has extended group data
        (progn
          (foreach appdata (dxf -3 ed)      ;Look at each app name
            (setq
              name (substr (car appdata) 7) ;Take the name, starting at
                                            ;7th char; IL_GRP is first 6
              grplist (append grplist (list name))
            )
          );foreach
          (group_display grplist)           ;Display the group list
        );progn
        (prompt "\nEntity does not belong to a group.")  ;Else prompt
      );if
    );progn
  );if
);defun



;;; Search the AutoCAD APPID reference table to get the names of all 
;;; registered applications. If the app name starts with IL_GRP it is one
;;; of ours - put it on the list to display. It is possible, but not too 
;;; probable for an app name to be on the APPID table but not reference any 
;;; entities. This is ok, since the select option traps for empty selection 
;;; sets. Unreferenced APPIDs are automatically purged when the drawing 
;;; is reloaded.
(defun group_list ( / flag td grplist)
  (setq flag T)
  (while (setq td (tblnext "APPID" flag))
    (setq
      flag nil
    )
    (if (wcmatch (dxf 2 td) "IL_GRP*")
      (setq
        grplist (append grplist (list (substr (dxf 2 td) 7)))
      )
    )
  )

  ;; Display the group list
  (group_display grplist)
);defun


;;; Remove a group name from a selection of entities
(defun group_remove ( / regname en ed ss count smax xd name grplist appdata)
  ;; Ask user which group name, upper case it for comparisons later.
  (setq
    #grpname (ustr 1 "Group name " #grpname nil)
    #grpname (strcase #grpname)
    regname (strcat "IL_GRP" #grpname)
  )

  ;; Let the user decide which entities to remove from the group.
  (if (setq ss (ssget (list (list -3 (list regname)))))
    (progn
      (setq
        smax (sslength ss)                  ;Set up counters
        count 0
      )

      ;; Scan each entity and test to see if it matchs the
      ;; group name. If it does, remove the group name from
      ;; the entity's extended data list.
      (while (< count smax)
        (setq
          en (ssname ss count)              ;Get entity name
          ed (entget en (list regname))     ;Look for any IL_GRP* app
          grplist nil
        )

        ;; Build a list of all the group names for the current entity.
        (foreach appdata (dxf -3 ed)        ;Look at each app name
          (setq
            name (car appdata)              ;Get the app name
          )
          (if (wcmatch name regname)        ;Remove it from the list
            (setq
              grplist (append grplist (list (list name))) ;As list of lists
            )
          );if
        );foreach

        (if grplist                         ;If there were matches 
          (progn
            (setq
              xd (append '(-3) grplist)         ;Make an empty -3 list
              ed (subst xd (assoc -3 ed) ed)    ;Sub in the new xdata
              count (1+ count)                  ;Increment the counter
            );setq
            (entmod ed)                         ;Update the entity
          );progn
        );if
      );while
    );progn
  );if
);defun

;;; Subroutine to display a list of group names to the text screen.
(defun group_display (grplist / grp)
  ;; Test to see if any group names have been found and if so, print them out.
  (if grplist
    (progn
      (textpage)                                 ;Clear text screen
      (prompt "\nCreated Groups For Entity:\n")  ;Print header
      (foreach grp grplist                       ;Print out each one
        (prompt (strcat "\t" grp "\n"))          ;of the group names
      )
    );progn
    (prompt "\nNo groups are defined.")          ;No valid names found
  );if
);defun

(princ)
;;;*
));test subroutines                                                  

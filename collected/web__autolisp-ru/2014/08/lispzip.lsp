;;;   ZipUtils.lsp
;;;   Copyright ©2009 by K.E. Blackie
;;;
;;;   http://www.resourcecad.com
;;;   kblackie@resourcecad.com
;;;
;;;   AutoCAD 2000+  VisualLISP
;;;
;;;   Permission to use, copy, modify, and distribute this software
;;;   for any purpose and without fee is hereby granted, provided
;;;   that the above copyright notice appears in all copies and that
;;;   both that copyright notice and this permission notice appear in
;;;   all supporting documentation.
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;;;   WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;;;   PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;
;;;
;;;
;;;
;;;
;;;----------------------------------------------------------------------------
;;;   DESCRIPTION
;;;----------------------------------------------------------------------------
;;;
;;;   This program uses VisualLISP and scripting objects to create, zip and
;;;   unzip files directly within AutoCAD. Error hecking is limited and it is
;;;   presumed the user will ensure the proper parameters are passed to each
;;;   function to obtain the desired results.
;;;
;;;----------------------------------------------------------------------------
;;;   USAGE
;;;----------------------------------------------------------------------------
;;;
;;;   (MakeZip "source filename with path" "destination file.zip* with path") *must not exist
;;;   (MakeEmptyZip "destination file.zip* with path") *must not exist
;;;   (Add2Zip "source filename with path" "destination file.zip* with path") *must exist
;;;   (AddFolder2Zip "source path" "destination file.zip* with path") *must not exist
;;;   (ExtractFilesFromZip "source file.zip with path" "source file in file.zip" "destination path")
;;;   (ExtractAllFilesFromZip "source file.zip with path" "destination path")
;;;   (GetAllFilesInZip "source file.zip with path") returns a list of all files in the zip file
;;;
;;;----------------------------------------------------------------------------


(defun makezip (srcfile destfile)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  ;; (MakeZip "source filename with path" "destination file.zip* with path") *must not exist
  (makeemptyzip destfile)
  (add2zip srcfile destfile)
  ) ;_ end of defun

(defun makeemptyzip (destfile / fso fo)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  ;; (MakeEmptyZip "destination file.zip* with path") *must not exist
  (setq fso (vlax-create-object "Scripting.FileSystemObject"))
  (setq fo (vlax-invoke fso 'opentextfile destfile '2 'true))
  (vlax-invoke fo 'write (strcat (chr 80) (chr 75) (chr 5) (chr 6)))
  (repeat 18 (vlax-invoke fo 'write (chr 256)))
  (vlax-invoke fo 'close)
  (vlax-release-object fo)
  (vlax-release-object fso)
  ) ;_ end of defun

(defun add2zip (srcfile destfile / app folder)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  (setq app (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke app 'namespace destfile))
  (vlax-invoke folder 'copyhere srcfile)
  (vlax-release-object folder)
  (vlax-release-object app)
  ) ;_ end of defun

(defun addfolder2zip (srcfolder destfile)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  (makeemptyzip destfile)
  (setq app (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke app 'namespace srcfolder))
  (setq destzip (vlax-invoke app 'namespace destfile))
  (setq files (vlax-invoke folder 'items))
  (setq count (vlax-get-property files 'count))
  (setq ndx 0)
  (repeat count
    (setq file (vlax-invoke files 'item ndx))
    (vlax-invoke destzip 'copyhere file)
    (setq ndx (1+ ndx))
    ) ;_ end of repeat
  ) ;_ end of defun

(defun extractfilefromzip (zipfile srcname strdest / folder fso)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  (if (member srcname (getallfilesinzip zipfile))
    (progn
      (setq fso (vlax-create-object "Shell.Application"))
      (setq folder (vlax-invoke fso 'namespace strdest))
      (vlax-invoke folder 'copyhere (strcat zipfile "\\" srcname))
      (vlax-release-object folder)
      (vlax-release-object fso)
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(defun extractallfilesfromzip (zipfile strdest / folder fso)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  (setq filelist (getallfilesinzip zipfile))
  (setq fso (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke fso 'namespace strdest))
  (setq ndx 0)
  (repeat (length filelist)
    (vlax-invoke folder 'copyhere (strcat zipfile "\\" (nth ndx filelist)))
    (setq ndx (1+ ndx))
    ) ;_ end of repeat
  (vlax-release-object folder)
  (vlax-release-object fso)
  ) ;_ end of defun

(defun getallfilesinzip (zipfile / count file filelist files folder fso ndx path)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  ;; (GetAllFilesInZip "source file.zip with path") returns a list of all files in the zip file
  (setq path (car (fnsplitl zipfile)))
  (setq fso (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke fso 'namespace zipfile))
  (setq files (vlax-invoke folder 'items))
  (setq count (vlax-get-property files 'count))
  (setq ndx 0)
  (repeat count
    (setq file (vlax-invoke files 'item ndx))
    (setq filelist (append filelist (list (vlax-get-property file 'name))))
    (setq ndx (1+ ndx))
    ) ;_ end of repeat
  filelist
  ) ;_ end of defun


(defun c:clevis(/ oldosnap p1 p2 p3 p4)
    ; clevis program to draw pole with clevis attachment at each end.
    ; options are side view or top view.
    
    (setq p1 (getpoint "\nStarting point for clevis rod:"))
    (setq o1 (getstring "\nPlace by Top or <Side>:"))
    (setq p2 (getpoint "\nEnding point:" p1))
    (setq o2 (getstring "\nPlace by Top or <Side>:"))
    
    (setq oldosnap (getvar "osmode"))
    (setvar "osmode" 0)
    
    (if (= (strcase o1) "T") 
        (command "-insert" "clevis-top" p1 1 1 (/ (* (angle p1 p2) 180.0) pi))
        (command "-insert" "clevis-side" p1 1 1 (/ (* (angle p1 p2) 180.0) pi))
        )
    (if (= (strcase o2) "T")         
        (command "-insert" "clevis-top" p2 1 1 (/ (* (angle p2 p1) 180.0) pi))
        (command "-insert" "clevis-side" p2 1 1 (/ (* (angle p2 p1) 180.0) pi))
        )
    
    ;calc points 12" from p1 and p2, for shaft start and end locations.
    (setq p3 (polar p1 (angle p1 p2) 12.0))
    (setq p4 (polar p2 (angle p2 p1) 12.0))
    
    ;pline for the 2" shaft, will be turned into wipeout
    (command "pline" (polar p3 (- (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p4 (- (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p4 (+ (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p3 (+ (angle p3 p4) (/ pi 2.0)) 1.0) "c")

    ;turn the pline you just drew into a wipeout
    (command "wipeout" "p" "l" "y")

    ;draw pline again incase the wipeout frames are turned off.
    (command "pline" (polar p3 (- (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p4 (- (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p4 (+ (angle p3 p4) (/ pi 2.0)) 1.0)
        (polar p3 (+ (angle p3 p4) (/ pi 2.0)) 1.0) "c")
        
    (setvar "osmode" oldosnap)
(princ)
)
; ===================================================================
; Lock object. Used for the security icon in the AP list
; $20.b - sec value
; ===================================================================
Obj_Lock:
    moveq   #0,d0
    move.b  1(a0),d0
    move.w  Obj_Lock__Routines(pc,d0.w),d0
    jmp     Obj_Lock__Routines(pc,d0.w)
; -------------------------------------------------------------------
Obj_Lock__Routines:
    dc.w    Obj_Lock__rSetup-Obj_Lock__Routines
    dc.w    Obj_Lock__rDisplay-Obj_Lock__Routines
; -------------------------------------------------------------------
Obj_Lock__rSetup:
    addq.b  #2,1(a0)                    ; next routine
    move.w  #vWSS_LocksOff/32,2(a0)     ; set art pointer
    move.l  #Map_Lock,4(a0)             ; set mappings
    move.b  #1,$10(a0)                  ; set "opened" frame

    tst.b   $20(a0)             ; test sec value
    beq.s   Obj_Lock__rDisplay  ; if sec is OPEN, branch to display
    move.b  #0,$10(a0)          ; else set "closed" frame

Obj_Lock__rDisplay:
    jmp     DisplaySprite 
; ===================================================================
Art_Lock:   incbin  "artunc/locks.bin"
Art_Lock__End:
Map_Lock:   include "_maps/Lock.asm"
Map_Lock__End:
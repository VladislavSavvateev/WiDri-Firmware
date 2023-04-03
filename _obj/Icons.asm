; ===================================================================
; Icons object
; ===================================================================
Obj_Icons:
    moveq   #0,d0
    move.b  1(a0),d0
    move.w  Obj_Icons__Routines(pc,d0.w),d0
    jsr     Obj_Icons__Routines(pc,d0.w)
    jmp     DisplaySprite
; -------------------------------------------------------------------
Obj_Icons__Routines:
    dc.w    Obj_Icons__rSetup-Obj_Icons__Routines
    dc.w    Obj_Icons__rLoop-Obj_Icons__Routines
; -------------------------------------------------------------------
Obj_Icons__rSetup:
    addq.b  #2,1(a0)
    move.l  #Map_Icons,4(a0)

Obj_Icons__rLoop:
    rts

; ===================================================================
; Icons GFX
; ===================================================================
Art_Icons:  incbin  "artunc/icons.bin"
Art_Icons__End:
Map_Icons:  include "_maps/Icon.asm"
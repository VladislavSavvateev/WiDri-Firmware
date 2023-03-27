; ===================================================================
; Keyboard layout object
; ===================================================================
Obj_Keyboard:
    moveq   #0,d0
    move.b  1(a0),d0
    move.w  Obj_Keyboard__Routines(pc,d0.w),d0
    jmp     Obj_Keyboard__Routines(pc,d0.w)
; ===================================================================
Obj_Keyboard__Routines:
    dc.w    Obj_Keyboard__rSetup-Obj_Keyboard__Routines
    dc.w    Obj_Keyboard__rLoop-Obj_Keyboard__Routines
; ===================================================================
Obj_Keyboard__rSetup:
    addq.b  #2,1(a0)                    ; next routine
    move.w  #0,2(a0)                    ; font at $0000
    move.l  #Map_KeyboardLayout,4(a0)   ; mappings
    move.w  #$80+144,8(a0)              ; X-pos
    move.w  #$80+148,$C(a0)             ; Y-pox
    move.b  #0,$10(a0)                  ; first layout

Obj_Keyboard__rLoop:
    jmp     DisplaySprite
; ===================================================================
Map_KeyboardLayout:
    include "_maps/Keyboard.asm"
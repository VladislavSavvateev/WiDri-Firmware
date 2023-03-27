; ===================================================================
; Keyboard Hover Object
; $20.b - X-pos (based on keys)
; $21.b - Y-pos (based on keys)
; ===================================================================
Obj_KbdHover:
    moveq   #0,d0
    move.b  1(a0),d0
    move.w  Obj_KbdHover__Routines(pc,d0.w),d0
    jsr     Obj_KbdHover__Routines(pc,d0.w)
    jmp     DisplaySprite
; ===================================================================
Obj_KbdHover__Routines:
    dc.w    Obj_KbdHover__rSetup-Obj_KbdHover__Routines
    dc.w    Obj_KbdHover__rRecalcPos-Obj_KbdHover__Routines
    dc.w    Obj_KbdHover__rControl-Obj_KbdHover__Routines
; ===================================================================
Obj_KbdHover__rSetup:
    addq.b  #4,1(a0)
    move.w  #(vWPI_KbdHovOff/32),2(a0)
    move.l  #Map_KbdHover,4(a0)

Obj_KbdHover__rRecalcPos:
    moveq   #0,d0
    move.b  $20(a0),d0
    lsl.l   #2,d0
    add.l   #Obj_KbdHover__Rows,d0
    move.l  d0,a1
    move.l  (a1),a1

    move.w  (a1)+,d0        ; skip key count (it should be pre-validated!)

    moveq   #0,d0
    move.b  $21(a0),d0
    lsl.l   #2,d0
    add.l   d0,a1

    move.w  (a1)+,8(a0)         ; X-pos
    move.w  (a1)+,$C(a0)        ; Y-pos
    move.b  (a1)+,d0            ; skip value
    move.b  (a1)+,$10(a0)       ; frame

Obj_KbdHover__rControl:
    rts
; ===================================================================
; Keys position
; ===================================================================
Obj_KbdHover__Rows:
    dc.l    Obj_KbdHover__R1
    dc.l    Obj_KbdHover__R2
    dc.l    Obj_KbdHover__R3
    dc.l    Obj_KbdHover__R4
    dc.l    Obj_KbdHover__R5
; -------------------------------------------------------------------
Obj_KbdHover__R1:
Obj_KbdHover__R2:
Obj_KbdHover__R3:
Obj_KbdHover__R4:
Obj_KbdHover__R5:
    dc.w    1   ; keys count

    dc.w    $80+40, $80+128     ; key pos
    dc.b    'A'                 ; key val
    dc.b    0                   ; frame
    dc.w    0                   ; flags (reserved)

; ===================================================================
; GFX
; ===================================================================
Art_KbdHover:   incbin  "artunc/kbd_hover.bin"
Art_KbdHover__End:
Map_KbdHover:   include "_maps/KbdHover.asm"
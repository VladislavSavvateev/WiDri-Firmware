; ===================================================================
; Keyboard Hover Object
; $20.b - X-pos (based on keys)
; $21.b - Y-pos (based on keys)
; $22.l - keyboard object
; $26.l - callback for values
;   #$18 - cancel
; $2A.w - SHIFT SYM art pos
; $2C.w - keyboard art pos
; ===================================================================
iShift          equ 0
iSym            equ 1
iEnter          equ 2
iDontApplyShift equ 3

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

    move.b  #3,d0
    jsr     FindObject
    move.l  a1,$22(a0)
; -------------------------------------------------------------------
Obj_KbdHover__rRecalcPos:
    jsr     Obj_KbdHover__JumpToKey

    move.w  (a1)+,8(a0)         ; X-pos
    move.w  (a1)+,$C(a0)        ; Y-pos
    move.b  (a1)+,d0            ; skip value
    move.b  (a1)+,$10(a0)       ; frame
; -------------------------------------------------------------------
Obj_KbdHover__rControl:
    btst    #iA,Joypad+Press
    beq.w   @cancel

    move.b  #$A0,d0
    jsr     PlaySound

    jsr     Obj_KbdHover__JumpToKey
    move.b  4(a1),d0    ; value
    move.b  6(a1),d1    ; get flags
    move.b  7(a1),d2    ; SYM value
    move.l  $22(a0),a1

    btst    #iShift,d1
    beq.s   @symCheck

    cmp.b   #1,$10(a1)
    bne.s   @changeToShift
    jmp     @changeToNormal

@changeToShift
    move.b  #1,$10(a1)
    jsr     Obj_KbdHover__ShowShiftActivated
    jsr     Obj_KbdHover__ShowSymDeactivated
    jmp     @right


@symCheck
    btst    #iSym,d1
    beq.s   @symbolCallback

    cmp.b   #2,$10(a1)
    beq.s   @changeToNormal
    move.b  #2,$10(a1)
    jsr     Obj_KbdHover__ShowSymActivated
    jsr     Obj_KbdHover__ShowShiftDeactivated
    jmp     @right

@changeToNormal
    move.b  #0,$10(a1)
    jsr     Obj_KbdHover__ShowSymDeactivated
    jsr     Obj_KbdHover__ShowShiftDeactivated
    jmp     @right
; -------------------------------------------------------------------
@symbolCallback
    cmp.b   #2,$10(a1)      ; is SYM layout is shown?
    bne.s   @checkShift
    move.b  d2,d0
    jmp     @callback

@checkShift
    cmp.b   #1,$10(a1)      ; is SHIFT layout is shown?
    bne.s   @callback
    btst    #iDontApplyShift,d1
    bne.s   @callback
    sub.b   #$20,d0

@callback
    move.l  $26(a0),a1
    jsr     (a1)            ; call callback
; -------------------------------------------------------------------
@cancel:
    btst    #iB,Joypad+Press
    beq.s   @right
    move.b  #$18,d0
    move.l  $26(a0),a1
    jsr     (a1)            ; call callback
; -------------------------------------------------------------------
@right
    btst    #iRight,Joypad+Press
    beq.s   @left
    addq.b  #1,$20(a0)
    jmp     @checkIfXInLimit
    
@left
    btst    #iLeft,Joypad+Press
    beq.s   @down
    tst.b   $20(a0)
    beq.s   @rts
    subq.b  #1,$20(a0)
    jmp     @changesWasMade

@down
    btst    #iDown,Joypad+Press
    beq.s   @up
    cmp.b   #4,$21(a0)
    beq.s   @rts
    addq.b  #1,$21(a0)
    jmp     @checkIfXInLimit

@up
    btst    #iUp,Joypad+Press
    beq.s   @rts
    tst.b   $21(a0)
    beq.s   @rts
    subq.b  #1,$21(a0)
    jmp     @changesWasMade

@checkIfXInLimit
    moveq   #0,d0
    move.b  $21(a0),d0
    lsl.l   #2,d0
    add.l   #Obj_KbdHover__Rows,d0
    move.l  d0,a1
    move.l  (a1),a1

    move.w  (a1)+,d0
    subq.b  #1,d0
    move.b  $20(a0),d1
    cmp.b   d0,d1
    ble.s   @changesWasMade
    move.b  d0,$20(a0)

@changesWasMade
    subq.b  #2,1(a0)
@rts
    rts
; -------------------------------------------------------------------
Obj_KbdHover__JumpToKey:
    moveq   #0,d0
    move.b  $21(a0),d0
    lsl.l   #2,d0
    add.l   #Obj_KbdHover__Rows,d0
    move.l  d0,a1
    move.l  (a1),a1

    move.w  (a1)+,d0        ; skip key count (it should be pre-validated!)

    moveq   #0,d0
    move.b  $20(a0),d0
    lsl.l   #3,d0
    add.l   d0,a1
    rts
; -------------------------------------------------------------------
Obj_KbdHover__ShowShiftActivated:  
    drawMapInObj    Map_Shift, Map_Shift_End, 512, $C000, 5, 22, 40, $2A(a0)
    rts
Obj_KbdHover__ShowSymActivated:  
    drawMapInObj    Map_Sym, Map_Sym_End, 512, $C000, 5, 24, 40, $2A(a0)
    rts

Obj_KbdHover__ShowShiftDeactivated:  
    drawMapInObj    Map_ShiftDeactivated, Map_ShiftDeactivated_End, 512, $C000, 5, 22, 40, $2C(a0)
    rts
Obj_KbdHover__ShowSymDeactivated:  
    drawMapInObj    Map_SymDeactivated, Map_SymDeactivated_End, 512, $C000, 5, 24, 40, $2C(a0)
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

; flags:
; %abcdefgh
;   a -
;   b - 
;   c -
;   d -
;   e -
;   f - do not apply SHIFT addition
;   g - works as a SYM key
;   h - works as a SHIFT key

Obj_KbdHover__R1:
    dc.w    10      ; keys count

    dc.w    $80+40+24*0, $80+128    ; key pos
    dc.b    '1'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '1'                     ; SYM value

    dc.w    $80+40+24*1, $80+128    ; key pos
    dc.b    '2'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '2'                     ; SYM value

    dc.w    $80+40+24*2, $80+128    ; key pos
    dc.b    '3'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '3'                     ; SYM value

    dc.w    $80+40+24*3, $80+128    ; key pos
    dc.b    '4'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '4'                     ; SYM value

    dc.w    $80+40+24*4, $80+128    ; key pos
    dc.b    '5'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '5'                     ; SYM value

    dc.w    $80+40+24*5, $80+128    ; key pos
    dc.b    '6'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '6'                     ; SYM value

    dc.w    $80+40+24*6, $80+128    ; key pos
    dc.b    '7'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '7'                     ; SYM value

    dc.w    $80+40+24*7, $80+128    ; key pos
    dc.b    '8'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '8'                     ; SYM value

    dc.w    $80+40+24*8, $80+128    ; key pos
    dc.b    '9'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '9'                     ; SYM value

    dc.w    $80+40+24*9, $80+128    ; key pos
    dc.b    '0'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '0'                     ; SYM value

Obj_KbdHover__R2:
    dc.w    10      ; keys count

    dc.w    $80+40+24*0, $80+128+16 ; key pos
    dc.b    'q'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '@'                     ; SYM value

    dc.w    $80+40+24*1, $80+128+16 ; key pos
    dc.b    'w'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '#'                     ; SYM value

    dc.w    $80+40+24*2, $80+128+16 ; key pos
    dc.b    'e'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '$'                     ; SYM value

    dc.w    $80+40+24*3, $80+128+16 ; key pos
    dc.b    'r'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '_'                     ; SYM value

    dc.w    $80+40+24*4, $80+128+16 ; key pos
    dc.b    't'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '&'                     ; SYM value

    dc.w    $80+40+24*5, $80+128+16 ; key pos
    dc.b    'y'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '-'                     ; SYM value

    dc.w    $80+40+24*6, $80+128+16 ; key pos
    dc.b    'u'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '+'                     ; SYM value

    dc.w    $80+40+24*7, $80+128+16 ; key pos
    dc.b    'i'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '('                     ; SYM value

    dc.w    $80+40+24*8, $80+128+16 ; key pos
    dc.b    'o'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    ')'                     ; SYM value

    dc.w    $80+40+24*9, $80+128+16 ; key pos
    dc.b    'p'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '/'                     ; SYM value

Obj_KbdHover__R3:
    dc.w    9   ; keys count

    dc.w    $80+48+24*0, $80+128+32 ; key pos
    dc.b    'a'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '*'                     ; SYM value

    dc.w    $80+48+24*1, $80+128+32 ; key pos
    dc.b    's'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    $22                     ; SYM value

    dc.w    $80+48+24*2, $80+128+32 ; key pos
    dc.b    'd'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    $27                     ; SYM value

    dc.w    $80+48+24*3, $80+128+32 ; key pos
    dc.b    'f'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    ':'                     ; SYM value

    dc.w    $80+48+24*4, $80+128+32 ; key pos
    dc.b    'g'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    ';'                     ; SYM value

    dc.w    $80+48+24*5, $80+128+32 ; key pos
    dc.b    'h'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '!'                     ; SYM value

    dc.w    $80+48+24*6, $80+128+32 ; key pos
    dc.b    'j'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '?'                     ; SYM value

    dc.w    $80+48+24*7, $80+128+32 ; key pos
    dc.b    'k'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '%'                     ; SYM value

    dc.w    $80+48+24*8, $80+128+32 ; key pos
    dc.b    'l'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '='                     ; SYM value

Obj_KbdHover__R4:
    dc.w    9   ; keys count

    dc.w    $80+40, $80+128+48      ; key pos
    dc.b    ' '                     ; key val
    dc.b    2                       ; frame
    dc.b    1<<iShift               ; flags (reserved)
    dc.b    0                       ; flags (reserved)

    dc.w    $80+80+24*0, $80+128+48 ; key pos
    dc.b    'z'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '<'                     ; SYM value

    dc.w    $80+80+24*1, $80+128+48 ; key pos
    dc.b    'x'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '>'                     ; SYM value

    dc.w    $80+80+24*2, $80+128+48 ; key pos
    dc.b    'c'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '{'                     ; SYM value

    dc.w    $80+80+24*3, $80+128+48 ; key pos
    dc.b    'v'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '|'                     ; SYM value

    dc.w    $80+80+24*4, $80+128+48 ; key pos
    dc.b    'b'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '}'                     ; SYM value

    dc.w    $80+80+24*5, $80+128+48 ; key pos
    dc.b    'n'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '~'                     ; SYM value

    dc.w    $80+80+24*6, $80+128+48 ; key pos
    dc.b    'm'                     ; key val
    dc.b    0                       ; frame
    dc.b    0                       ; flags (reserved)
    dc.b    '^'                     ; SYM value

    dc.w    $80+80+24*7, $80+128+48 ; key pos
    dc.b    8                       ; key val
    dc.b    1                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    8                       ; SYM value

Obj_KbdHover__R5:
    dc.w    5   ; keys count

    dc.w    $80+40, $80+128+64      ; key pos
    dc.b    ' '                     ; key val
    dc.b    2                       ; frame
    dc.b    1<<iSym                 ; flags (reserved)
    dc.b    0                       ; flags (reserved)

    dc.w    $80+80+24*0, $80+128+64 ; key pos
    dc.b    ','                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    ','                     ; SYM value

    dc.w    $80+80+24*1, $80+128+64 ; key pos
    dc.b    ' '                     ; key val
    dc.b    3                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    ' '                     ; SYM value

    dc.w    $80+48+24*7, $80+128+64 ; key pos
    dc.b    '.'                     ; key val
    dc.b    0                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    '.'                     ; SYM value

    dc.w    $80+48+24*8, $80+128+64 ; key pos
    dc.b    $A                      ; key val
    dc.b    2                       ; frame
    dc.b    1<<iDontApplyShift      ; flags (reserved)
    dc.b    $A                      ; SYM value

; ===================================================================
; GFX
; ===================================================================
Art_KbdHover:   incbin  "artunc/kbd_hover.bin"
Art_KbdHover__End:
Map_KbdHover:   include "_maps/KbdHover.asm"
; =========================================================
; WiDri Logo Eye
; $20.w - timer
; $22.b - only animation
; $23.b - palette counter
; $24.b - end
; =========================================================
LogoEye:
    moveq   #0,d0
    move.b  1(a0),d0
    move.w  LogoEye_Routines(pc,d0.w),d0
    jmp     LogoEye_Routines(pc,d0.w)
; ---------------------------------------------------------
LogoEye_Routines:
    dc.w    LogoEye_Main-LogoEye_Routines

    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_OpenEye-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_CloseEye-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_WhinkLeft-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_CloseEye-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_WhinkRight-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_CloseEye-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_OpenEyeWoBrow-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_PlayFadeSound-LogoEye_Routines

    dc.w    LogoEye_PalFade-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_CheckPalCycle-LogoEye_Routines
    dc.w    LogoEye_Wait-LogoEye_Routines
    dc.w    LogoEye_SetFlag-LogoEye_Routines
    
    dc.w    LogoEye_Loop-LogoEye_Routines
; ---------------------------------------------------------
LogoEye_Main:
    move.b  #1,$24(a0)
    rts

    ; skip this bullshit

    addq.b  #2,1(a0)
    move.w  #95+(1<<13),2(a0)
    move.l  #LogoEye_Map,4(a0)
    move.b  #0,$10(a0)
    move.w  #60,$20(a0)
LogoEye_Loop:
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_OpenEye:
    addq.b  #2,1(a0)
    move.b  #1,$10(a0)
    move.w  #60,$20(a0)
    tst.b   $22(a0)
    bne.s   @cont
    move.b  #$A9,d0
    jsr     PlaySound
@cont
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_OpenEyeWoBrow:
    addq.b  #2,1(a0)
    move.b  #4,$10(a0)
    move.w  #60,$20(a0)
    tst.b   $22(a0)
    beq.s   @cont
    add.b  #$E,1(a0)

@cont
    move.b  #7,$23(a0)
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_PlayFadeSound:
    addq.b  #2,1(a0)
    move.b  #$CA,d0
    jsr     PlaySound
    rts
; ---------------------------------------------------------
LogoEye_CloseEye:
    addq.b  #2,1(a0)
    move.b  #0,$10(a0)
    move.w  #5,$20(a0)
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_WhinkLeft:
    addq.b  #2,1(a0)
    move.b  #2,$10(a0)
    move.w  #30,$20(a0)
    tst.b   $22(a0)
    bne.s   @cont
    move.b  #$A9,d0
    jsr     PlaySound
@cont
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_WhinkRight:
    addq.b  #2,1(a0)
    move.b  #3,$10(a0)
    move.w  #30,$20(a0)
    tst.b   $22(a0)
    bne.s   @cont
    move.b  #$A9,d0
    jsr     PlaySound
@cont
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_Wait:
    sub.w   #1,$20(a0)
    bne.s   @rts
    addq.b  #2,1(a0)
@rts
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_PalFade:
    addq.b  #2,1(a0)

    lea     $FFFFFB00,a1
    lea     $FFFFFB20,a2
    moveq   #15,d2
    moveq   #0,d0
    moveq   #0,d1

@next
    ; blue
    move.b  (a1),d0
    move.b  (a2),d1
    cmp.w   d0,d1       ; CHECK
    ble.s   @g
    add.b   #2,(a1)

    ; green
@g  move.b  1(a1),d0
    move.b  1(a2),d1
    and.b   #$E0,d0
    and.b   #$E0,d1
    cmp.w   d0,d1       ; CHECK
    ble.s   @r
    add.b   #$20,1(a1)

    ; red
@r  move.b  1(a1),d0
    move.b  1(a2),d1
    and.b   #$E,d0
    and.b   #$E,d1
    cmp.w   d0,d1       ; CHECK
    ble.s   @end
    add.b   #$2,1(a1)

@end
    lea     2(a1),a1
    lea     2(a2),a2

    dbf     d2,@next
    move.w  #3,$20(a0)
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_CheckPalCycle:
    addq.b  #2,1(a0)
    sub.b   #1,$23(a0)
    beq.s   @flag
    subq.b  #6,1(a0)
    jmp     @disp
@flag   
    move.w  #120,$20(a0)
@disp
    jmp     DisplaySprite
; ---------------------------------------------------------
LogoEye_SetFlag:
    addq.b  #2,1(a0)
    move.b  #1,$24(a0)
    jmp     DisplaySprite
; ---------------------------------------------------------
; Mappings
; ---------------------------------------------------------
LogoEye_Art:
    incbin  "artunc/eye.bin"
LogoEye_Map:
    include "_maps/Eye.asm"
LogoEye_Pal:
    incbin  "palette/logo.bin"

LogoEye_End:
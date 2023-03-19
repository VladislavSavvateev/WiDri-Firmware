; =========================================================
; Logo Screen
; =========================================================
vLogoScreen_Action          equ $FFFF6000   ; b
vLogoScreen_SsidLength      equ $FFFF6002   ; b
vLogoScreen_Timer           equ $FFFF6003   ; b

LogoScreen:   
    lea		$C00004,a6	; load VDP
	move.w	#$8004,(a6)	; Reg#00: H-Int disabled, line counter disabled
	move.w	#$8174,(a6)	; Reg#01: DISPLAY on, V-Int enabled, DMA on, 224
	move.w	#$8230,(a6)	; Reg#02: Plan A is $C000
	move.w	#$8407,(a6)	; Reg#04: Plan B is $E000
	move.w	#$8700,(a6)	; Reg#07: backColor is 0, 0
	move.w	#$8B03,(a6)	; Reg#11: Scrolling: V(F), H(EL)
	move.w	#$9001,(a6)	; Reg#16: 512x256

	jsr		ClearObjects

    ; load main palette
    lea     Pal_Main,a0
    moveq  #0,d0
    move.w  #(Pal_Main_End-Pal_Main)/2-1,d0
    lea		$FFFFFB80,a1
@mainPalLoop
	move.w	(a0)+,(a1)+
	dbf		d0,@mainPalLoop

    ; load font GFX
	lea		Font_Art,a0
	moveq	#0,d0
	move.w	#(Font_Art_End-Font_Art)/4-1,d0
	vram	$0000
@fntArtLoop
	move.l	(a0)+,$C00000
	dbf		d0,@fntArtLoop

    ; load BG GFX
    lea     Art_BG,a0
    moveq   #0,d0
    move.w  #(Art_BG_End-Art_BG)/4-1,d0
    vram    Font_Art_End-Font_Art
@bgArtLoop
    move.l  (a0)+,$C00000
    dbf     d0,@bgArtLoop
    

    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, (Font_Art_End-Font_Art)/32

    ; reset vars
    move.b  #0,vLogoScreen_Action
    move.b  #2,vLogoScreen_Timer

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     LogoScreen_Loop

	jmp		@loop
; =========================================================
; Main Loop
; =========================================================
LogoScreen_Loop:
    moveq   #0,d0
    move.b  vLogoScreen_Action,d0
    move.w  LogoScreen_LoopActions(pc,d0.w),d0
    jmp     LogoScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
LogoScreen_LoopActions:
    dc.w    LogoScreen_Wait-LogoScreen_LoopActions
    dc.w    LogoScreen_PalFadeIn-LogoScreen_LoopActions

    dc.w    LogoScreen_CheckForArduino-LogoScreen_LoopActions
    dc.w    LogoScreen_CheckForSSID_1-LogoScreen_LoopActions
    dc.w    LogoScreen_CheckForSSID_2-LogoScreen_LoopActions
    dc.w    LogoScreen_GetSSID-LogoScreen_LoopActions

    dc.w    LogoScreen_GotSSID-LogoScreen_LoopActions
    dc.w    LogoScreen_NoSSID-LogoScreen_LoopActions

    dc.w    LogoScreen_LoopEnd-LogoScreen_LoopActions
; ---------------------------------------------------------
LogoScreen_Wait:
    subq.b  #1,vLogoScreen_Timer
    bne.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts
    
LogoScreen_PalFadeIn:
    addq.b  #2,vLogoScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vLogoScreen_Action   ; if not, move to the wait action
    move.b  #2,vLogoScreen_Timer    ; and set the timer
@rts
    rts

LogoScreen_CheckForArduino:
    move.w  $B00004,d0
    move.w  $B00004,d0
    cmp.w   #1337,d0
    bne.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts

LogoScreen_CheckForSSID_1:
    addq.b  #2,vLogoScreen_Action
    move.b  #1,$B00000
    rts

LogoScreen_CheckForSSID_2:
    move.w  $B00002,d0
    beq.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts

LogoScreen_GetSSID:
    addq.b  #2,vLogoScreen_Action
    move.b  $B00000,d0
    move.b  d0,vLogoScreen_SsidLength
    bne.s   @cont
    addq.b  #2,vLogoScreen_Action
    rts

@cont
    subq.b  #1,d0
    lea     vLogoScreen_SsidLength+1,a0
@loop
    move.b  $B00000,(a0)+
    dbf     d0,@loop
    rts

LogoScreen_GotSSID:
    vram    $C000
    moveq   #0,d0
    move.b  vLogoScreen_SsidLength,d0
    lea     vLogoScreen_SsidLength+1,a0
@loop
    moveq   #0,d1
    move.b  (a0)+,d1
    sub.b   #' ',d1
    move.w  d1,$C00000
    dbf     d0,@loop   

    addq.b  #2,vLogoScreen_Action

LogoScreen_LoopEnd:
LogoScreen_NoSSID:
    rts

; =========================================================
; Font
; =========================================================
Logo_Art:
    incbin  "artunc/logo.bin"
Logo_Map:
    incbin  "mapunc/logo.bin"
Logo_Pal:
    incbin  "palette/logo.bin"

LogoScreen_End:
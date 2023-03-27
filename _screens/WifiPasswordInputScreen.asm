; =========================================================
; WiFi AP Password input Screen
; =========================================================
vWifiPasswordInputScreen_Action equ $FFFF6000   ; b
vWifiPasswordInputScreen_Timer  equ $FFFF6001   ; b

vWPI_FontOff    equ $0000
vWPI_BgOff      equ vWSS_FontOff+(Font_Art_End-Font_Art)
vWPI_KbOff      equ vWPI_BgOff+(Art_BG_End-Art_BG)

WifiPasswordInputScreen:   
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
    loadPal Pal_Main, Pal_Main_End, $FFFFFB80

    ; load font GFX
    loadArt Font_Art, Font_Art_End, vWSS_FontOff

    ; load BG GFX
    loadArt Art_BG, Art_BG_End, vWSS_BgOff
    
    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vWSS_BgOff/32

    ; load keyboard GFX
    loadArt Art_Keyboard, Art_Keyboard_End, vWPI_KbOff

    ; load keyboard mappings
    drawMap Map_Keyboard, Map_Keyboard_End, 512, $C000, 0, 14, 320, vWPI_KbOff/32

    jsr     FindFreeObject
    move.b  #3,(a0)

    move.b  #0,vWifiPasswordInputScreen_Action    ; and set the timer
    move.b  #2,vWifiPasswordInputScreen_Timer    ; and set the timer

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     WifiPasswordInputScreen_Loop

	jmp		@loop
; =========================================================
; Main Loop
; =========================================================
WifiPasswordInputScreen_Loop:
    moveq   #0,d0
    move.b  vWifiPasswordInputScreen_Action,d0
    move.w  WifiPasswordInputScreen_LoopActions(pc,d0.w),d0
    jmp     WifiPasswordInputScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
WifiPasswordInputScreen_LoopActions:
    dc.w    WifiPasswordInputScreen_Wait-WifiPasswordInputScreen_LoopActions
    dc.w    WifiPasswordInputScreen_PalFadeIn-WifiPasswordInputScreen_LoopActions

    dc.w    WifiPasswordInputScreen_LoopEnd-WifiPasswordInputScreen_LoopActions
; ---------------------------------------------------------
WifiPasswordInputScreen_Wait:
    subq.b  #1,vWifiPasswordInputScreen_Timer
    bne.s   @rts
    addq.b  #2,vWifiPasswordInputScreen_Action
@rts
    rts
    
WifiPasswordInputScreen_PalFadeIn:
    addq.b  #2,vWifiPasswordInputScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vWifiPasswordInputScreen_Action   ; if not, move to the wait action
    move.b  #2,vWifiPasswordInputScreen_Timer    ; and set the timer
@rts
    rts

WifiPasswordInputScreen_LoopEnd:
    rts

WifiPasswordInputScreen_End:
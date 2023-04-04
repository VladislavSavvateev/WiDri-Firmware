; =========================================================
; WiFi AP Password input Screen
; =========================================================
vWifiPasswordInputScreen_Action         equ $FFFF6000   ; b
vWifiPasswordInputScreen_Timer          equ $FFFF6001   ; b
vWifiPasswordInputScreen_PasswordBuffer equ $FFFF6002   ; 64 bytes
vWifiPasswordInputScreen_PasswordPos    equ $FFFF6042   ; b
vWifiPasswordInputScreen_ExitFromScreen equ $FFFF6043   ; b

vWifiPasswordInputScreen_SelectedSSID   equ $FFFF7000   ; idk, zero-based

vWPI_FontOff        equ $0000
vWPI_BgOff          equ vWSS_FontOff+(Font_Art_End-Font_Art)
vWPI_KbOff          equ vWPI_BgOff+(Art_BG_End-Art_BG)
vWPI_KbdHovOff      equ vWPI_KbOff+(Art_Keyboard_End-Art_Keyboard)
vWPI_ShiftSymOff    equ vWPI_KbdHovOff+(Art_KbdHover__End-Art_KbdHover)
vWPI_InputFieldOff  equ vWPI_ShiftSymOff+(Art_ShiftSym_End-Art_ShiftSym)
vWPI_IconsOff       equ vWPI_InputFieldOff+(Art_InputField_End-Art_InputField)

WifiPasswordInputScreen:   
    jsr     Pal_FadeFrom

    clearRect   512, $C000, 0, 0, 320, 224, 0

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

    ; load keyboard hover GFX
    loadArt Art_KbdHover, Art_KbdHover__End, vWPI_KbdHovOff

    ; load SHIFT SYM GFX
    loadArt Art_ShiftSym, Art_ShiftSym_End, vWPI_ShiftSymOff

    ; load input field GFX
    loadArt Art_InputField, Art_InputField_End, vWPI_InputFieldOff

    ; load input field map
    drawMap Map_InputField, Map_InputField_End, 512, $E000, 48/8, 64/8, 224, vWPI_InputFieldOff/32

    ; load icons GFX
    loadArt Art_Icons, Art_Icons__End, vWPI_IconsOff

    jsr     FindFreeObject
    move.b  #3,(a0)

    jsr     FindFreeObject
    move.b  #4,(a0)
    move.b  #0,$20(a0)
    move.b  #0,$21(a0)
    move.l  #WifiPasswordInputScreen_KeyboardCallback,$26(a0)
    move.w  #vWPI_ShiftSymOff/32,$2A(a0)
    move.w  #vWPI_KbOff/32,$2C(a0)

    jsr     FindFreeObject
    move.b  #5,(a0)
    move.w  #vWPI_IconsOff/32,2(a0)
    move.w  #$80+56,8(a0)
    move.w  #$80+24,$C(a0)
    move.b  #0,$10(a0)

    PosToVRAM   $C000, 96/8, 40/8, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    lea     vWifiPasswordInputScreen_SelectedSSID,a6
    jsr     DrawText

    PosToVRAM   $C000, 96/8, 24/8, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    lea     Str_EnterPassword_Title,a6
    jsr     DrawText

    move.b  #0,vWifiPasswordInputScreen_Action  ; set current action
    move.b  #2,vWifiPasswordInputScreen_Timer   ; set timer for pal fade
    move.b  #0,vWifiPasswordInputScreen_ExitFromScreen
    
    moveq   #64/4-1,d0
    lea     vWifiPasswordInputScreen_PasswordBuffer,a0
@clearBuf
    move.l  #0,(a0)+
    dbf     d0,@clearBuf

    move.b  #0,vWifiPasswordInputScreen_PasswordPos

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     WifiPasswordInputScreen_Loop

    tst.b   vWifiPasswordInputScreen_ExitFromScreen
    beq.s   @loop
    rts
; ---------------------------------------------------------
WifiPasswordInputScreen_KeyboardCallback:
    moveq   #0,d1
    move.b  vWifiPasswordInputScreen_PasswordPos,d1
    move.l  #vWifiPasswordInputScreen_PasswordBuffer,a1
    add.l   d1,a1

    cmp.b   #$20,d0
    bge.s   @normalSymbol

    cmp.b   #8,d0           ; backspace?
    bne.s   @enter
    tst.b   d1
    beq.w   @rts
    move.b  #0,-1(a1)
    subq.b  #1,vWifiPasswordInputScreen_PasswordPos

    jmp     @redraw

@enter
    cmp.b   #$A,d0          ; enter?
    bne.s   @cancel

    lea     vWifiPasswordInputScreen_PasswordBuffer,a1
    lea     vConnectToWiFiScreen_Password,a2

@passLoop
        move.b  (a1)+,(a2)+
        bne.s   @passLoop

    move.b  #1,vWifiPasswordInputScreen_ExitFromScreen
    move.b  #4,$FFFFF600

    jmp     @rts

@normalSymbol
    cmp.b   #64,d1
    beq.s   @rts
    move.b  d0,(a1)
    addq.b  #1,vWifiPasswordInputScreen_PasswordPos

@redraw
    clearRect   512, $C000, 56, 72, 208, 8, 0
    PosToVRAM   $C000, 56/8, 72/8, 512, d7
    move.w  #0,d3
    move.l  #vWifiPasswordInputScreen_PasswordBuffer,a6
    jmp     DrawText

@cancel
    cmp.b   #$18,d0
    bne.s   @rts

    move.b  #1,vWifiPasswordInputScreen_ExitFromScreen
    move.b  #1,$FFFFF600

@rts
    rts

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
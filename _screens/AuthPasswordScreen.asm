; =========================================================
; WiFi AP Password input Screen
; =========================================================
vAuthPasswordScreen_Action         equ $FFFF6000   ; b
vAuthPasswordScreen_Timer          equ $FFFF6001   ; b
vAuthPasswordScreen_PasswordBuffer equ $FFFF6002   ; 64 bytes
vAuthPasswordScreen_PasswordPos    equ $FFFF6042   ; b
vAuthPasswordScreen_ExitFromScreen equ $FFFF6043   ; b

vAP_FontOff        equ $0000
vAP_BgOff          equ vAP_FontOff+(Font_Art_End-Font_Art)
vAP_KbOff          equ vAP_BgOff+(Art_BG_End-Art_BG)
vAP_KbdHovOff      equ vAP_KbOff+(Art_Keyboard_End-Art_Keyboard)
vAP_ShiftSymOff    equ vAP_KbdHovOff+(Art_KbdHover__End-Art_KbdHover)
vAP_InputFieldOff  equ vAP_ShiftSymOff+(Art_ShiftSym_End-Art_ShiftSym)
vAP_IconsOff       equ vAP_InputFieldOff+(Art_InputField_End-Art_InputField)

AuthPasswordScreen:   
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
    loadArt Art_Keyboard, Art_Keyboard_End, vAP_KbOff

    ; load keyboard mappings
    drawMap Map_Keyboard, Map_Keyboard_End, 512, $C000, 0, 14, 320, vAP_KbOff/32

    ; load keyboard hover GFX
    loadArt Art_KbdHover, Art_KbdHover__End, vAP_KbdHovOff

    ; load SHIFT SYM GFX
    loadArt Art_ShiftSym, Art_ShiftSym_End, vAP_ShiftSymOff

    ; load input field GFX
    loadArt Art_InputField, Art_InputField_End, vAP_InputFieldOff

    ; load input field map
    drawMap Map_InputField, Map_InputField_End, 512, $E000, 48/8, 64/8, 224, vAP_InputFieldOff/32

    ; load icons GFX
    loadArt Art_Icons, Art_Icons__End, vAP_IconsOff

    jsr     FindFreeObject
    move.b  #3,(a0)

    jsr     FindFreeObject
    move.b  #4,(a0)
    move.b  #0,$20(a0)
    move.b  #0,$21(a0)
    move.l  #AuthPasswordScreen_KeyboardCallback,$26(a0)
    move.w  #vAP_ShiftSymOff/32,$2A(a0)
    move.w  #vAP_KbOff/32,$2C(a0)

    jsr     FindFreeObject
    move.b  #5,(a0)
    move.w  #vAP_IconsOff/32,2(a0)
    move.w  #$80+56,8(a0)
    move.w  #$80+24,$C(a0)
    move.b  #1,$10(a0)

    PosToVRAM   $C000, 96/8, 32/8, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    lea     Str_AuthPassword_Title,a6
    jsr     DrawText

    move.b  #0,vAuthPasswordScreen_Action  ; set current action
    move.b  #2,vAuthPasswordScreen_Timer   ; set timer for pal fade
    move.b  #0,vAuthPasswordScreen_ExitFromScreen
    
    moveq   #64/4-1,d0
    lea     vAuthPasswordScreen_PasswordBuffer,a0
@clearBuf
    move.l  #0,(a0)+
    dbf     d0,@clearBuf

    move.b  #0,vAuthPasswordScreen_PasswordPos

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     AuthPasswordScreen_Loop

    tst.b   vAuthPasswordScreen_ExitFromScreen
    beq.s   @loop
    rts
; ---------------------------------------------------------
AuthPasswordScreen_KeyboardCallback:
    moveq   #0,d1
    move.b  vAuthPasswordScreen_PasswordPos,d1
    move.l  #vAuthPasswordScreen_PasswordBuffer,a1
    add.l   d1,a1

    cmp.b   #$20,d0
    bge.s   @normalSymbol

    cmp.b   #8,d0           ; backspace?
    bne.s   @enter
    tst.b   d1
    beq.w   @rts
    move.b  #0,-1(a1)
    subq.b  #1,vAuthPasswordScreen_PasswordPos

    jmp     @redraw

@enter
    cmp.b   #$A,d0          ; enter?
    bne.s   @rts

    lea     vAuthPasswordScreen_PasswordBuffer,a1
    lea     vAuthenticationScreen_Password,a2

@passLoop
        move.b  (a1)+,(a2)+
        bne.s   @passLoop

    move.b  #1,vAuthPasswordScreen_ExitFromScreen
    move.b  #7,$FFFFF600

    jmp     @rts

@normalSymbol
    cmp.b   #64,d1
    beq.s   @rts
    move.b  d0,(a1)
    addq.b  #1,vAuthPasswordScreen_PasswordPos

@redraw
    clearRect   512, $C000, 56, 72, 208, 8, 0
    PosToVRAM   $C000, 56/8, 72/8, 512, d7
    move.w  #0,d3
    move.l  #vAuthPasswordScreen_PasswordBuffer,a6
    jmp     DrawText
@rts
    rts

; =========================================================
; Main Loop
; =========================================================
AuthPasswordScreen_Loop:
    moveq   #0,d0
    move.b  vAuthPasswordScreen_Action,d0
    move.w  AuthPasswordScreen_LoopActions(pc,d0.w),d0
    jmp     AuthPasswordScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
AuthPasswordScreen_LoopActions:
    dc.w    AuthPasswordScreen_Wait-AuthPasswordScreen_LoopActions
    dc.w    AuthPasswordScreen_PalFadeIn-AuthPasswordScreen_LoopActions

    dc.w    AuthPasswordScreen_LoopEnd-AuthPasswordScreen_LoopActions
; ---------------------------------------------------------
AuthPasswordScreen_Wait:
    subq.b  #1,vAuthPasswordScreen_Timer
    bne.s   @rts
    addq.b  #2,vAuthPasswordScreen_Action
@rts
    rts
    
AuthPasswordScreen_PalFadeIn:
    addq.b  #2,vAuthPasswordScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vAuthPasswordScreen_Action   ; if not, move to the wait action
    move.b  #2,vAuthPasswordScreen_Timer    ; and set the timer
@rts
    rts

AuthPasswordScreen_LoopEnd:
    rts

AuthPasswordScreen_End:
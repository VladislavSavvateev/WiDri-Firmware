; =========================================================
; Connect to WiFi Screen
; =========================================================
vAuthenticationScreen_Action             equ $FFFF6000   ; b
vAuthenticationScreen_Timer              equ $FFFF6001   ; b
vAuthenticationScreen_ExitFromScreen     equ $FFFF6002   ; b

vAuthenticationScreen_Login     equ $FFFF7000   ; idk, zero-based
vAuthenticationScreen_Password  equ $FFFF7040   ; idk, zero-based

vA_FontOff     equ $0000
vA_BgOff       equ vA_FontOff+(Font_Art_End-Font_Art)

AuthenticationScreen:    
    jsr     Pal_FadeFrom

    jsr     ClearPlaneA

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
    loadArt Font_Art, Font_Art_End, vA_FontOff

    ; load BG GFX
    loadArt Art_BG, Art_BG_End, vA_BgOff
    
    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vA_BgOff/32

    ; reset vars
    move.b  #2,vAuthenticationScreen_Action
    move.b  #2,vAuthenticationScreen_Timer
    move.b  #0,vAuthenticationScreen_ExitFromScreen

    PosToVRAM   $C000, 12, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_AuthProcess,a6
    jsr     DrawText

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     AuthenticationScreen_Loop

    tst.b   vAuthenticationScreen_ExitFromScreen
    beq.s   @loop
    rts
; =========================================================
; Main Loop
; =========================================================
AuthenticationScreen_Loop:
    moveq   #0,d0
    move.b  vAuthenticationScreen_Action,d0
    move.w  AuthenticationScreen_LoopActions(pc,d0.w),d0
    jmp     AuthenticationScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
AuthenticationScreen_LoopActions:
    dc.w    AuthenticationScreen_LoopEnd-AuthenticationScreen_LoopActions

    dc.w    AuthenticationScreen_Wait-AuthenticationScreen_LoopActions
    dc.w    AuthenticationScreen_PalFadeIn-AuthenticationScreen_LoopActions

    dc.w    AuthenticationScreen_AuthLogin-AuthenticationScreen_LoopActions
    dc.w    AuthenticationScreen_CheckBuf-AuthenticationScreen_LoopActions
    dc.w    AuthenticationScreen_AuthLogin__CheckVal-AuthenticationScreen_LoopActions

    dc.w    AuthenticationScreen_LoopEnd-AuthenticationScreen_LoopActions
; ---------------------------------------------------------
AuthenticationScreen_Wait:
    subq.b  #1,vAuthenticationScreen_Timer
    bne.s   @rts
    addq.b  #2,vAuthenticationScreen_Action
@rts
    rts
; ---------------------------------------------------------------------------
AuthenticationScreen_PalFadeIn:
    addq.b  #2,vAuthenticationScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vAuthenticationScreen_Action   ; if not, move to the wait action
    move.b  #2,vAuthenticationScreen_Timer    ; and set the timer
@rts
    rts
; ---------------------------------------------------------------------------
AuthenticationScreen_AuthLogin:
    addq.b  #2,vAuthenticationScreen_Action
    lea     vAuthenticationScreen_Login,a1
    lea     vAuthenticationScreen_Password,a2
    jmp     Auth_Login
; ---------------------------------------------------------------------------
AuthenticationScreen_CheckBuf:
    jsr     Arduino_GetBufferLength
    tst.w   d0
    beq.s   @rts
    addq.b  #2,vAuthenticationScreen_Action
@rts
    rts
; ---------------------------------------------------------------------------
AuthenticationScreen_AuthLogin__CheckVal:
    jsr     AuthenticationScreen_ClearStatus
    move.b  #0,vAuthenticationScreen_Action

    jsr     Auth_Login_r
    tst.b   d0
    beq.s   @error

    PosToVRAM   $C000, 8, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_AuthProcess_OK,a6
    jmp     DrawText

@error
    PosToVRAM   $C000, 14, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_AuthProcess_Fail,a6
    jmp     DrawText
; ---------------------------------------------------------------------------
AuthenticationScreen_LoopEnd:
    rts
; ---------------------------------------------------------------------------
AuthenticationScreen_ClearStatus:
    clearRect   512, $C000, 0, 224/2, 320, 8, 0
    rts

AuthenticationScreen_End:
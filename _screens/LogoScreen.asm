; =========================================================
; Logo Screen
; =========================================================
vLogoScreen_Action              equ $FFFF6000   ; b
vLogoScreen_Timer               equ $FFFF6001   ; b
vLogoScreen_ArduinoCheckCount   equ $FFFF6002   ; w
vLogoScreen_ExitFromScreen      equ $FFFF6003   ; b

vLogoScreen_SSIDBuf equ $FFFF6010   ; idk, zero-based

vL_FontOff        equ $0000
vL_BgOff          equ vL_FontOff+(Font_Art_End-Font_Art)

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
    loadPal Pal_Main, Pal_Main_End, $FFFFFB80

    ; load font GFX
    loadArt Font_Art, Font_Art_End, vL_FontOff

    ; load BG GFX
    loadArt Art_BG, Art_BG_End, vL_BgOff

    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vL_BgOff/32

    PosToVRAM   $C000, 0, 0, 512, d7
    moveq   #0,d3
    lea     Str_Debug_CheckingForArduino,a6
    jsr     DrawText

    ; reset vars
    move.b  #2,vLogoScreen_Action
    move.b  #2,vLogoScreen_Timer
    move.w  #180,vLogoScreen_ArduinoCheckCount
    move.b  #0,vLogoScreen_ExitFromScreen

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     LogoScreen_Loop

    tst.b   vLogoScreen_ExitFromScreen
    beq.s   @loop

    rts
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
    dc.w    LogoScreen_LoopEnd-LogoScreen_LoopActions                           ; 00

    dc.w    LogoScreen_Wait-LogoScreen_LoopActions                              ; 02
    dc.w    LogoScreen_PalFadeIn-LogoScreen_LoopActions                         ; 04

    dc.w    LogoScreen_CheckForArduino-LogoScreen_LoopActions                   ; 06

    dc.w    LogoScreen_SendWiFiHasApCreds-LogoScreen_LoopActions                ; 08
    dc.w    LogoScreen_BufCheck-LogoScreen_LoopActions                          ; 0A
    dc.w    LogoScreen_SendWiFiHasApCreds__CheckVal-LogoScreen_LoopActions      ; 0C

    dc.w    LogoScreen_SendWiFiGetSSID-LogoScreen_LoopActions                   ; 0E
    dc.w    LogoScreen_BufCheck-LogoScreen_LoopActions                          ; 10
    dc.w    LogoScreen_SendWiFiGetSSID__DisplaySSID-LogoScreen_LoopActions      ; 12

    dc.w    LogoScreen_WiFiConnect-LogoScreen_LoopActions                       ; 14
    dc.w    LogoScreen_WiFiGetConStatus-LogoScreen_LoopActions                  ; 16
    dc.w    LogoScreen_BufCheck-LogoScreen_LoopActions                          ; 18
    dc.w    LogoScreen_WiFiGetConStatus__CheckVal-LogoScreen_LoopActions        ; 1A

    dc.w    LogoScreen_AuthIsLoggedIn-LogoScreen_LoopActions                    ; 1C
    dc.w    LogoScreen_BufCheck-LogoScreen_LoopActions                          ; 1E
    dc.w    LogoScreen_AuthIsLoggedIn__CheckVal-LogoScreen_LoopActions          ; 20

    dc.w    LogoScreen_UserGetMe-LogoScreen_LoopActions                         ; 22
    dc.w    LogoScreen_BufCheck-LogoScreen_LoopActions                          ; 24
    dc.w    LogoScreen_UserGetMe__CheckVal-LogoScreen_LoopActions               ; 26

    dc.w    LogoScreen_LoopEnd-LogoScreen_LoopActions  
; ---------------------------------------------------------
LogoScreen_Wait:
    subq.b  #1,vLogoScreen_Timer
    bne.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts
; ---------------------------------------------------------
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
; ---------------------------------------------------------
LogoScreen_CheckForArduino:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 1, 1, 512, d7
    moveq   #0,d3
    lea     Str_Common_OK,a6

    jsr     Arduino_CheckForMagicWord
    tst.b   d0
    bne.s   @ok

    subq.b  #1,vLogoScreen_ArduinoCheckCount
    bne.s   @fail

    move.b  #0,vLogoScreen_Action
    lea     Str_Common_Fail,a6
@ok
    jmp     DrawText

@fail
    subq.b  #2,vLogoScreen_Action

@rts
    rts
; ---------------------------------------------------------
LogoScreen_SendWiFiHasApCreds:
    PosToVRAM   $C000, 0, 2, 512, d7
    moveq   #0,d3
    lea     Str_Debug_CheckingForAPSettings,a6
    jsr     DrawText

    jsr     WiFi_HasApCreds
    addq.b  #2,vWifiSelectScreen_Action
    rts

LogoScreen_SendWiFiHasApCreds__CheckVal:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 1, 3, 512, d7
    moveq   #0,d3
    lea     Str_Common_Yes,a6

    jsr     WiFi_HasApCreds_r
    tst.b   d0
    bne.s   @rts

    addq.b  #6,vLogoScreen_Action
    lea     Str_Common_No,a6

    move.b  #1,$FFFFF600
    move.b  #1,vLogoScreen_ExitFromScreen
@rts
    jmp     DrawText
; ---------------------------------------------------------
LogoScreen_SendWiFiGetSSID:
    PosToVRAM   $C000, 0, 4, 512, d7
    moveq   #0,d3
    lea     Str_Debug_GettingSSID,a6
    jsr     DrawText

    move.b  #1,$B00000
    addq.b  #2,vLogoScreen_Action
    rts

LogoScreen_SendWiFiGetSSID__DisplaySSID:
    addq.b  #2,vLogoScreen_Action

    lea     vLogoScreen_SSIDBuf,a1
    jsr     WiFi_GetSSID_r

    PosToVRAM   $C000, 1, 5, 512, d7
    moveq   #0,d3
    lea     vLogoScreen_SSIDBuf,a6
    jmp     DrawText
; ---------------------------------------------------------
LogoScreen_WiFiConnect:
    PosToVRAM   $C000, 0, 6, 512, d7
    moveq   #0,d3
    lea     Str_Debug_ConnectingToWiFi,a6
    jsr     DrawText

    jsr     WiFi_Connect
    addq.b  #2,vLogoScreen_Action
    rts

LogoScreen_WiFiGetConStatus:
    jsr     WiFi_GetConStatus
    addq.b  #2,vLogoScreen_Action
    rts

LogoScreen_WiFiGetConStatus__CheckVal:
    jsr     WiFi_GetConStatus_r
    beq.s   @ok

    cmp.b   #3,d0
    beq.s   @ok

    cmp.b   #6,d0
    beq.s   @disconnected

    move.b  #0,vLogoScreen_Action
    PosToVRAM   $C000, 1, 7, 512, d7
    moveq   #0,d3
    lea     Str_Common_Fail,a6
    jmp     DrawText

    rts

@disconnected
    subq.b  #4,vLogoScreen_Action
    rts

@ok
    addq.b  #2,vLogoScreen_Action
    PosToVRAM   $C000, 1, 7, 512, d7
    moveq   #0,d3
    lea     Str_Common_OK,a6
    jmp     DrawText
; ---------------------------------------------------------
LogoScreen_AuthIsLoggedIn:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 0, 8, 512, d7
    moveq   #0,d3
    lea     Str_Debug_CheckAuth,a6
    jsr     DrawText

    jmp     Auth_IsLoggedIn

LogoScreen_AuthIsLoggedIn__CheckVal:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 1, 9, 512, d7
    moveq   #0,d3
    lea     Str_Common_Yes,a6

    jsr     Auth_IsLoggedIn_r
    tst.b   d0
    bne.s   @ok

    move.b  #0,vLogoScreen_Action
    lea     Str_Common_No,a6
    move.b  #5,$FFFFF600
    move.b  #1,vLogoScreen_ExitFromScreen

@ok 
    jmp     DrawText
; ---------------------------------------------------------
LogoScreen_UserGetMe:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 0, 10, 512, d7
    moveq   #0,d3
    lea     Str_Debug_GetLogin,a6
    jsr     DrawText

    jmp     User_GetMe

LogoScreen_UserGetMe__CheckVal:
    addq.b  #2,vLogoScreen_Action

    lea     vLogoScreen_SSIDBuf,a1
    jsr     User_GetMe_r

    PosToVRAM   $C000, 1, 11, 512, d7
    moveq   #0,d3
    lea     vLogoScreen_SSIDBuf,a6
    jmp     DrawText
; ---------------------------------------------------------
LogoScreen_BufCheck:
    jsr     Arduino_GetBufferLength
    tst.w   d0
    beq.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts
; ---------------------------------------------------------
LogoScreen_LoopEnd:
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
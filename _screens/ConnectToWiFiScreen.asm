; =========================================================
; Connect to WiFi Screen
; =========================================================
vConnectToWiFiScreen_Action             equ $FFFF6000   ; b
vConnectToWiFiScreen_Timer              equ $FFFF6001   ; b
vConnectToWiFiScreen_ExitFromScreen     equ $FFFF6002   ; b

vConnectToWiFiScreen_SelectedSSID       equ $FFFF7000   ; idk, zero-based
vConnectToWiFiScreen_Password           equ $FFFF7040   ; idk, zero-based

vCW_FontOff     equ $0000
vCW_BgOff       equ vCW_FontOff+(Font_Art_End-Font_Art)

ConnectToWiFiScreen:    
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
    loadArt Font_Art, Font_Art_End, vCW_FontOff

    ; load BG GFX
    loadArt Art_BG, Art_BG_End, vCW_BgOff
    
    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vCW_BgOff/32

    ; reset vars
    move.b  #2,vConnectToWiFiScreen_Action
    move.b  #2,vConnectToWiFiScreen_Timer
    move.b  #0,vConnectToWiFiScreen_ExitFromScreen

    PosToVRAM   $C000, 8, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_Saving,a6
    jsr     DrawText

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     ConnectToWiFiScreen_Loop

    tst.b   vConnectToWiFiScreen_ExitFromScreen
    beq.s   @loop
    rts
; =========================================================
; Main Loop
; =========================================================
ConnectToWiFiScreen_Loop:
    moveq   #0,d0
    move.b  vConnectToWiFiScreen_Action,d0
    move.w  ConnectToWiFiScreen_LoopActions(pc,d0.w),d0
    jmp     ConnectToWiFiScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
ConnectToWiFiScreen_LoopActions:
    dc.w    ConnectToWiFiScreen_LoopEnd-ConnectToWiFiScreen_LoopActions

    dc.w    ConnectToWiFiScreen_Wait-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_PalFadeIn-ConnectToWiFiScreen_LoopActions

    dc.w    ConnectToWiFiScreen_WiFiSetAP-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_BufCheck-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_WiFiSetAP__ValCheck-ConnectToWiFiScreen_LoopActions

    dc.w    ConnectToWiFiScreen_WiFiConnect-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_BufCheck-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_WiFiConnect__ValCheck-ConnectToWiFiScreen_LoopActions

    dc.w    ConnectToWiFiScreen_WiFiGetConStatus-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_BufCheck-ConnectToWiFiScreen_LoopActions
    dc.w    ConnectToWiFiScreen_WiFiGetConStatus__ValCheck-ConnectToWiFiScreen_LoopActions

    dc.w    ConnectToWiFiScreen_LoopEnd-ConnectToWiFiScreen_LoopActions
; ---------------------------------------------------------
ConnectToWiFiScreen_Wait:
    subq.b  #1,vConnectToWiFiScreen_Timer
    bne.s   @rts
    addq.b  #2,vConnectToWiFiScreen_Action
@rts
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_PalFadeIn:
    addq.b  #2,vConnectToWiFiScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vConnectToWiFiScreen_Action   ; if not, move to the wait action
    move.b  #2,vConnectToWiFiScreen_Timer    ; and set the timer
@rts
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiSetAP:
    addq.b  #2,vConnectToWiFiScreen_Action

    move.b  #2,$B00000

    lea     vConnectToWiFiScreen_SelectedSSID,a0
    moveq   #0,d0
@calcSSIDlen
        move.b  (a0)+,d1
        beq.s   @calcSSIDdone
        addq.b  #1,d0
        bra.s   @calcSSIDlen

@calcSSIDdone
    move.b  d0,$B00000
    lea     vConnectToWiFiScreen_SelectedSSID,a0

@sendSSID
        move.b  (a0)+,d0
        beq.s   @sendSSID_end
        move.b  d0,$B00000
        bra.s   @sendSSID

@sendSSID_end
    lea     vConnectToWiFiScreen_Password,a0
    moveq   #0,d0
@calcPassLen
        move.b  (a0)+,d1
        beq.s   @calcPassDone
        addq.b  #1,d0
        bra.s   @calcPassLen

@calcPassDone
    move.b  d0,$B00000
    lea     vConnectToWiFiScreen_Password,a0

@sendPass
        move.b  (a0)+,d0
        beq.s   @sendPass_end
        move.b  d0,$B00000
        bra.s   @sendPass

@sendPass_end
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_BufCheck:
    move.w  $B00002,d0
    beq.s   @rts
    addq.b  #2,vConnectToWiFiScreen_Action
@rts
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiSetAP__ValCheck:
    move.b  $B00000,d0
    bne.s   @good

    move.b  #0,vConnectToWiFiScreen_Action
    jsr     ConnectToWiFiScreen_ClearStatus
    PosToVRAM   $C000, 14, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_SaveFailed,a6
    jmp     DrawText

@good
    addq.b  #2,vLogoScreen_Action
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiConnect:
    jsr     ConnectToWiFiScreen_ClearStatus
    PosToVRAM   $C000, 9, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_Connecting,a6
    jsr     DrawText

    addq.b  #2,vConnectToWiFiScreen_Action
    move.b  #3,$B00000
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiConnect__ValCheck:
    move.b  $B00000,d0
    beq.s   @good
    cmp.b   #6,d0
    beq.s   @good

    move.b  #0,vConnectToWiFiScreen_Action
    jsr     ConnectToWiFiScreen_ClearStatus
    PosToVRAM   $C000, 11, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_ConnectionFailed,a6
    jmp     DrawText

@good:
    addq.b  #2,vConnectToWiFiScreen_Action
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiGetConStatus:
    addq.b  #2,vConnectToWiFiScreen_Action
    move.b  #5,$B00000
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_WiFiGetConStatus__ValCheck:
    move.b  $B00000,d0
    beq.s   @good
    cmp.b   #6,d0
    beq.s   @disconnected

    cmp.b   #3,d0
    beq.s   @good

    move.b  #0,vConnectToWiFiScreen_Action
    jsr     ConnectToWiFiScreen_ClearStatus
    PosToVRAM   $C000, 11, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_ConnectionFailed,a6
    jmp     DrawText

@good
    move.b  #0,vConnectToWiFiScreen_Action
    jsr     ConnectToWiFiScreen_ClearStatus
    PosToVRAM   $C000, 9, 224/16, 512, d7
    moveq   #0,d3
    lea     Str_ConnectToWiFi_Connected,a6
    jmp     DrawText

@disconnected
    subq.b  #4,vConnectToWiFiScreen_Action
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_LoopEnd:
    rts
; ---------------------------------------------------------------------------
ConnectToWiFiScreen_ClearStatus:
    clearRect   512, $C000, 0, 224/2, 320, 8, 0
    rts

ConnectToWiFiScreen_End:
; =========================================================
; WiFi AP Select Screen
; =========================================================
vWifiSelectScreen_Action            equ $FFFF6000   ; b
vWifiSelectScreen_Timer             equ $FFFF6001   ; b
vWifiSelectScreen_ListOffset        equ $FFFF6002   ; b
vWifiSelectScreen_ListPos           equ $FFFF6003   ; b
vWifiSelectScreen_FoundWifiAPs      equ $FFFF6010   ; unknown size

vWSS_FontOff    equ $0000
vWSS_BgOff      equ vWSS_FontOff+(Font_Art_End-Font_Art)
vWSS_ListOff    equ vWSS_BgOff+(Art_BG_End-Art_BG)
vWSS_LocksOff   equ vWSS_ListOff+(Art_List_End-Art_List)

WifiSelectScreen:   
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

    ; load list GFX
    loadArt Art_List, Art_List_End, vWSS_ListOff

    ; load list mappings
    drawMap Map_List, Map_List_End, 512, $E000, 48/8, 56/8, 224, vWSS_ListOff/32

    ; load locks GFX
    loadArt Art_Lock, Art_Lock__End, vWSS_LocksOff

    lea     Str_SearchingForNetworks,a6
    PosToVRAM $C000, 56/8, 112/8, 512, d7
    jsr     DrawText

    ; reset vars
    move.b  #0,vWifiSelectScreen_Action
    move.b  #2,vWifiSelectScreen_Timer

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     WifiSelectScreen_Loop

	jmp		@loop
; =========================================================
; Main Loop
; =========================================================
WifiSelectScreen_Loop:
    moveq   #0,d0
    move.b  vWifiSelectScreen_Action,d0
    move.w  WifiSelectScreen_LoopActions(pc,d0.w),d0
    jmp     WifiSelectScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
WifiSelectScreen_LoopActions:
    dc.w    WifiSelectScreen_Wait-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_PalFadeIn-WifiSelectScreen_LoopActions

    dc.w    WifiSelectScreen_CheckForArduino-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_SendSearchReq-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_CheckForSearchEnd_1-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_CheckForSearchEnd_2-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_CheckForSearchEnd_3-WifiSelectScreen_LoopActions

    dc.w    WifiSelectScreen_GettingListOfAPs_1-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_GettingListOfAPs_2-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_GettingListOfAPs_3-WifiSelectScreen_LoopActions

    dc.w    WifiSelectScreen_ClearList-WifiSelectScreen_LoopActions
    dc.w    WifiSelectScreen_DrawList-WifiSelectScreen_LoopActions

    dc.w    WifiSelectScreen_LoopEnd-WifiSelectScreen_LoopActions
; ---------------------------------------------------------
WifiSelectScreen_Wait:
    subq.b  #1,vWifiSelectScreen_Timer
    bne.s   @rts
    addq.b  #2,vWifiSelectScreen_Action
@rts
    rts
    
WifiSelectScreen_PalFadeIn:
    addq.b  #2,vWifiSelectScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vWifiSelectScreen_Action   ; if not, move to the wait action
    move.b  #2,vWifiSelectScreen_Timer    ; and set the timer
@rts
    rts

WifiSelectScreen_CheckForArduino:
    move.w  $B00004,d0
    move.w  $B00004,d0
    cmp.w   #1337,d0
    bne.s   @rts
    addq.b  #2,vWifiSelectScreen_Action
@rts
    rts

WifiSelectScreen_SendSearchReq:             ; sending wifi.search
    move.b  #7,$B00000
    addq.b  #2,vWifiSelectScreen_Action
    rts

WifiSelectScreen_CheckForSearchEnd_1:       ; sending wifi.found_ap_count
    addq.b  #2,vWifiSelectScreen_Action
    move.b  #9,$B00000
    rts

WifiSelectScreen_CheckForSearchEnd_2:       ; checking for anything in the buffer
    move.w  $B00002,d0
    beq.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts

WifiSelectScreen_CheckForSearchEnd_3:       ; checking for the SCAN_COMPLETE
    move.b  $B00000,d0
    bmi.s   @notComplete            ; -1 and -2 are not success statuses

    addq.b  #6,vLogoScreen_Action

@notComplete
    subq.b  #4,vLogoScreen_Action
    rts

; ---------------------------------------------------------------------------

WifiSelectScreen_GettingListOfAPs_1:       ; sending wifi.get_scan_results
    move.b  #8,$B00000
    addq.b  #2,vLogoScreen_Action
    rts

WifiSelectScreen_GettingListOfAPs_2:
    move.w  $B00002,d0
    beq.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts

WifiSelectScreen_GettingListOfAPs_3:
    addq.b  #2,vLogoScreen_Action

    moveq   #0,d0

    lea     vWifiSelectScreen_FoundWifiAPs,a0
    move.b  $B00000,d0  ; get APs count
    move.b  d0,(a0)+
    subq.b  #1,d0

@apLoop
        moveq   #0,d1
        move.b  $B00000,d1  ; get SSID length
        subq.b  #1,d1

@ssidLoop
            move.b  $B00000,(a0)+   ; SSID char by char
            dbf     d1,@ssidLoop
        
        move.b  #0,(a0)+        ; string stop byte

        move.b  $B00000,(a0)+   ; sec byte
        dbf     d0,@apLoop
    
    rts

; ---------------------------------------------------------------------------

WifiSelectScreen_ClearList:
    addq.b  #2,vWifiSelectScreen_Action
    clearRect 512, $C000, 48, 56, 224, 120, 0
    rts

WifiSelectScreen_DrawList:
    addq.b  #2,vWifiSelectScreen_Action

    lea     vWifiSelectScreen_FoundWifiAPs,a6   ; loading found APs
    moveq   #0,d1
    move.b  (a6)+,d1        ; APs count
    
    cmp.b   #5,d1       ; check if networks more than 5
    ble.s   @okCount    ; if not, branch
    move.b  #5,d1       ; else limit loop counter to 5

@okCount
    subq.b  #1,d1                           ; decrement loop counter for dbf
    move.w  #128+58,d2                      ; lock sprite y pos
    PosToVRAM $C000, 80/8, 64/8, 512, d4    ; SSID VRAM pos 
@apLoop
        move.w  d4,d7       ; move VRAM pos to d7
        jsr     DrawText    ; draw SSID

        jsr     FindFreeObject  ; find free obj slot
        move.b  #2,(a0)         ; set "Lock" obj
        move.b  (a6)+,$20(a0)   ; set sec byte
        move.w  #128+60,$8(a0)  ; set x pos
        move.w  d2,$C(a0)       ; move y pos

        add.w   #512/4*3,d4 ; next line for SSID
        add.w   #24,d2      ; next y pos for lock obj

    dbf     d1,@apLoop

    rts

; ---------------------------------------------------------------------------


WifiSelectScreen_LoopEnd:
    rts

WifiSelectScreen_End:
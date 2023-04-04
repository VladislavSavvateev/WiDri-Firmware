; =========================================================
; Clear EEPROM Screen
; =========================================================
vClearEEPROMScreen_Action         equ $FFFF6000   ; b

vCEEMPROM_FontOff   equ $0000
vCEEMPROM_BgOff     equ vCEEMPROM_FontOff+(Font_Art_End-Font_Art)

ClearEEPROMScreen:   
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
    loadPal Pal_Main, Pal_Main_End, $FFFFFB00
    ; load main palette
    loadPal Pal_MainR, Pal_MainR_End, $FFFFFB20

    ; load font GFX
    loadArt Font_Art, Font_Art_End, vWSS_FontOff

    ; load bg GFX
    loadArt Art_BG, Art_BG_End, vCEEMPROM_BgOff
    
    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vWSS_BgOff/32+(1<<13)

    PosToVRAM   $C000, 13, 2, 512, d7
    move.w  #512,d5
    move.w  #1<<13,d3
    move.l  #Str_Danger,a6
    jsr     DrawText

    PosToVRAM   $C000, 0, 5, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_1,a6
    jsr     DrawText


    PosToVRAM   $C000, 3, 10, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_2,a6
    jsr     DrawText

    PosToVRAM   $C000, 4, 18, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_Combo,a6
    jsr     DrawText

    PosToVRAM   $C000, 6, 23, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_Reset,a6
    jsr     DrawText

    move.b  #0,vClearEEPROMScreen_Action  ; set current action

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     ClearEEPROMScreen_Loop

	jmp		@loop
; =========================================================
; Main Loop
; =========================================================
ClearEEPROMScreen_Loop:
    moveq   #0,d0
    move.b  vClearEEPROMScreen_Action,d0
    move.w  ClearEEPROMScreen_LoopActions(pc,d0.w),d0
    jmp     ClearEEPROMScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
ClearEEPROMScreen_LoopActions:
    dc.w    ClearEEPROMScreen_CheckForCombo-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_DrawText-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_CheckForArduino-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_SendClearReq-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_WaitForAnswer-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_DrawResetText-ClearEEPROMScreen_LoopActions
    dc.w    ClearEEPROMScreen_LoopEnd-ClearEEPROMScreen_LoopActions
; ---------------------------------------------------------
ClearEEPROMScreen_CheckForCombo:
    move.b  Joypad+Held,d0
    andi.b  #Right+A+B+C+Start,d0
    cmp.b   #Right+A+B+C+Start,d0
    bne.s   @rts
    addq.b  #2,vClearEEPROMScreen_Action

@rts
    rts
; ---------------------------------------------------------
ClearEEPROMScreen_DrawText:
    addq.b  #2,vClearEEPROMScreen_Action

    clearRect   512, $C000, 0, 0, 320, 224, 0

    PosToVRAM   $C000, 9, 14, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_Clearing,a6
    jmp     DrawText
; ---------------------------------------------------------
ClearEEPROMScreen_CheckForArduino:
    move.w  $B00004,d0
    move.w  $B00004,d0
    cmp.w   #1337,d0
    bne.s   @rts
    addq.b  #2,vClearEEPROMScreen_Action
@rts
    rts
; ---------------------------------------------------------
ClearEEPROMScreen_SendClearReq:
    move.b  #$40,$B00000
    addq.b  #2,vClearEEPROMScreen_Action
    rts
; ---------------------------------------------------------
ClearEEPROMScreen_WaitForAnswer:
    move.w  $B00002,d0
    beq.s   @rts
    addq.b  #2,vLogoScreen_Action
@rts
    rts
; ---------------------------------------------------------
ClearEEPROMScreen_DrawResetText:
    addq.b  #2,vLogoScreen_Action

    PosToVRAM   $C000, 4, 14, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    move.l  #Str_FactoryReset_Cleared,a6
    jmp     DrawText
; ---------------------------------------------------------
ClearEEPROMScreen_LoopEnd:
    rts

ClearEEPROMScreen_End:
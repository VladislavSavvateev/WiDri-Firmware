; =========================================================
; Explorer Screen
; =========================================================
vExplorerScreen_Action              equ $FFFF6000   ; b
vExplorerScreen_Timer               equ $FFFF6001   ; b
vExplorerScreen_ExitFromScreen      equ $FFFF6002   ; b
vExplorerScreen_CurrentEntryId_1    equ $FFFF6004   ; l
vExplorerScreen_CurrentEntryId_2    equ $FFFF6008   ; l
vExplorerScreen_EntryCount          equ $FFFF600C   ; w
vExplorerScreen_Offset              equ $FFFF600E   ; w
vExplorerScreen_Position            equ $FFFF6010   ; w
vExplorerScreen_MaxPosition         equ $FFFF6012   ; w
vExplorerScreen_Temp                equ $FFFF6014   ; w
vExplorerScreen_Entries             equ $FFFF7000   ; idk

vES_FontOff         equ $0000
vES_BgOff           equ vES_FontOff+(Font_Art_End-Font_Art)
vES_ExplorerListOff equ vES_BgOff+(Art_BG_End-Art_BG)
vES_IconsOff        equ vES_ExplorerListOff+(Art_ExplorerList__End-Art_ExplorerList)

ExplorerScreen:    
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

    lea     $FFFFFB20,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade

    ; load font GFX
    loadArt Font_Art, Font_Art_End, vES_FontOff

    ; load BG GFX
    loadArt Art_BG, Art_BG_End, vES_BgOff
    
    ; load BG mappings
    drawMap Map_BG, Map_BG_End, 512, $E000, 0, 0, 320, vES_BgOff/32

    ; load explorer list GFX
    loadArt Art_ExplorerList, Art_ExplorerList__End, vES_ExplorerListOff

    ; 24 24
    drawMap Map_ExplorerList, Map_ExplorerList__End, 512, $E000, 24/8, 24/8, 272, vES_ExplorerListOff/32

    ; load icons GFX
    loadArt Art_Icons, Art_Icons__End, vES_IconsOff

    ; reset vars
    move.b  #0,vExplorerScreen_Action
    move.b  #2,vExplorerScreen_Timer
    move.b  #0,vExplorerScreen_ExitFromScreen
    move.l  #0,vExplorerScreen_CurrentEntryId_1
    move.l  #0,vExplorerScreen_CurrentEntryId_2
    move.w  #0,vExplorerScreen_Offset

@loop
	move.b	#2,($FFFFF62A).w
	jsr		DelayProgram

	jsr		ClearSprites
	jsr		ObjectRun
    jsr     ExplorerScreen_Loop

    tst.b   vExplorerScreen_ExitFromScreen
    beq.s   @loop
    rts
; =========================================================
; Main Loop
; =========================================================
ExplorerScreen_Loop:
    moveq   #0,d0
    move.b  vExplorerScreen_Action,d0
    move.w  ExplorerScreen_LoopActions(pc,d0.w),d0
    jmp     ExplorerScreen_LoopActions(pc,d0.w)
; ---------------------------------------------------------
ExplorerScreen_LoopActions:
    dc.w    ExplorerScreen_Wait-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_PalFadeIn-ExplorerScreen_LoopActions

    dc.w    ExplorerScreen_GetListing-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_CheckForBuf-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_GetListing__Read-ExplorerScreen_LoopActions

    dc.w    ExplorerScreen_DrawPath-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_CountEntries-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_RenderEntries-ExplorerScreen_LoopActions
    dc.w    ExplorerScreen_Control-ExplorerScreen_LoopActions

    dc.w    ExplorerScreen_LoopEnd-ExplorerScreen_LoopActions
; ---------------------------------------------------------
ExplorerScreen_Wait:
    subq.b  #1,vExplorerScreen_Timer
    bne.s   @rts
    addq.b  #2,vExplorerScreen_Action
@rts
    rts
; ---------------------------------------------------------------------------
ExplorerScreen_PalFadeIn:
    addq.b  #2,vExplorerScreen_Action   ; pre-move to the next action

    lea     $FFFFFB00,a1
    lea     $FFFFFB80,a2
    moveq   #16,d2
    jsr     Pal_FadeInStep  ; making one step fade
    tst.b   d3              ; changes was made?
    beq.s   @rts            ; if yes, branch

    subq.b  #4,vExplorerScreen_Action   ; if not, move to the wait action
    move.b  #2,vExplorerScreen_Timer    ; and set the timer
@rts
    rts
; ---------------------------------------------------------------------------
ExplorerScreen_GetListing:
    addq.b  #2,vExplorerScreen_Action   ; pre-move to the next action

    PosToVRAM   $C000, 120/8, 8/8, 512, d7
    move.w  #512,d5
    move.w  #0,d3
    lea     Str_Explorer_Loading,a6
    jsr     DrawText

    move.w  #0,vExplorerScreen_Offset
    move.l  vExplorerScreen_CurrentEntryId_1,d1
    move.l  vExplorerScreen_CurrentEntryId_2,d2
    jmp     File_GetListing

ExplorerScreen_CheckForBuf:
    jsr     Arduino_GetBufferLength
    tst.w   d0
    beq.s   @rts
    addq.b  #2,vExplorerScreen_Action
@rts
    rts

ExplorerScreen_GetListing__Read:
    addq.b  #2,vExplorerScreen_Action
    lea     vExplorerScreen_Entries,a1
    jmp     File_GetListing_r
; ---------------------------------------------------------------------------
ExplorerScreen_DrawPath:
    addq.b  #2,vExplorerScreen_Action

    clearRect   512, $C000, 32, 8, 256, 32, 0

    ; 32 32
    PosToVRAM   $C000, 32/8, 32/8, 512, d7
    move.w  #0,d3
    lea     vExplorerScreen_Entries,a6
    jmp     DrawText
; ---------------------------------------------------------------------------
ExplorerScreen_CountEntries:
    addq.b  #2,vExplorerScreen_Action
    lea     vExplorerScreen_Entries,a6

    ; skip path
@skipPath
        move.b  (a6)+,d1
        bne.s   @skipPath

    moveq   #0,d1
    move.b  (a6)+,d1
    lsl.w   #8,d1
    move.b  (a6)+,d1

    move.w  d1,vExplorerScreen_EntryCount
    cmp.w   #6,d1
    bgt.s   @moreThanSix
    subq.w  #1,d1
    move.w  d1,vExplorerScreen_MaxPosition
    move.w  d1,vExplorerScreen_Position
    rts
    
@moreThanSix
    move.w  #5,vExplorerScreen_MaxPosition
    move.w  #5,vExplorerScreen_Position
    rts
; ---------------------------------------------------------------------------
ExplorerScreen_RenderEntries:
    addq.b  #2,vExplorerScreen_Action

    jsr     ClearObjects
    clearRect   512, $C000, 48, 56, 272, 128, 0

    lea     vExplorerScreen_Entries,a6

    ; skip path
@skipPath
        move.b  (a6)+,d1
        bne.s   @skipPath

    moveq   #0,d1
    move.b  (a6)+,d1
    lsl.w   #8,d1
    move.b  (a6)+,d1

    subq.w  #1,d1

    sub.w   vExplorerScreen_Offset,d1

    cmp.w   #5,d1
    ble.s   @countIsOk
    move.w  #5,d1

@countIsOk
    moveq   #0,d0
    move.w  vExplorerScreen_Offset,d0
    beq.s   @drawEntities
    subq.w  #1,d0
@skip
        lea     9(a6),a6
@skipName
            tst.b   (a6)+
            bne.s   @skipName
        dbf     d0,@skip

@drawEntities
    ; start at 48 56
    ; skip 3 rows
    PosToVRAM   $C000, 48/8, 56/8, 512, d4
    move.w  #128+56,d2  ; start icon y pos
@entryLoop
        lea     8(a6),a6    ; skip ID

        jsr     FindFreeObject
        move.b  #5,(a0)
        move.w  #vES_IconsOff/32,2(a0)
        move.b  #3,$10(a0)
        tst.b   (a6)+    ; check type
        beq.s   @isFile
        subq.b  #1,$10(a0)
@isFile move.w  #128+32,$8(a0)
        move.w  d2,$C(a0)

        move.w  #0,d3
        move.w  d1,vExplorerScreen_Temp
        cmp.w   vExplorerScreen_Position,d1
        beq.s   @useFirstPal
        move.w  #(1<<13),d3
@useFirstPal
        move.w  d4,d7
        jsr     DrawText

        add.w   #512/4*3,d4 ; next row
        add.w   #24,d2
        move.w  vExplorerScreen_Temp,d1
        dbf     d1,@entryLoop
    rts
; ---------------------------------------------------------------------------
ExplorerScreen_Control:
    btst    #iDown,Joypad+Press
    beq.s   @up

    ; check pos
    tst.w   vExplorerScreen_Position
    beq.s   @shiftOffsetDown
    subq.w  #1,vExplorerScreen_Position
    jmp     @redraw

    ; check offset
@shiftOffsetDown
    cmp.w   #6,vExplorerScreen_EntryCount
    ble.s   @rts

    moveq   #0,d0
    moveq   #0,d1
    move.w  vExplorerScreen_EntryCount,d0
    subq.w  #6,d0
    move.w  vExplorerScreen_Offset,d1
    cmp.w   d0,d1
    beq.s   @rts
    addq.w  #1,vExplorerScreen_Offset
    jmp     @redraw

@up btst    #iUp,Joypad+Press
    beq.s   @a

    move.w  vExplorerScreen_Position,d0
    cmp.w   vExplorerScreen_MaxPosition,d0
    beq.s   @shiftOffsetUp
    addq.w  #1,vExplorerScreen_Position
    jmp     @redraw
    
@shiftOffsetUp
    tst.w   vExplorerScreen_Offset
    beq.s   @rts
    subq.w  #1,vExplorerScreen_Offset

@redraw
    subq.b  #2,vExplorerScreen_Action
@rts
    rts

@a
    btst    #iA,Joypad+Press
    beq.s   @rts

ExplorerScreen_ClickHandler:
    lea     vExplorerScreen_Entries,a6

    ; skip path
@skipPath
        tst.b  (a6)+
        bne.s   @skipPath

    moveq   #0,d1
    move.b  (a6)+,d1
    lsl.w   #8,d1
    move.b  (a6)+,d1
    subq.w  #1,d1

    cmp.w   #5,d1
    ble.s   @countIsOk
    move.w  #5,d1

@countIsOk
    moveq   #0,d0
    move.w  vExplorerScreen_Offset,d0
    beq.s   @iterEntries
    subq.w  #1,d0
@skip
        lea     9(a6),a6
@skipName
            tst.b   (a6)+
            bne.s   @skipName
        dbf     d0,@skip

@iterEntries
        cmp.w   vExplorerScreen_Position,d1
        beq.s   @found
        lea     9(a6),a6
@skipEntryName
            tst.b   (a6)+
            bne.s   @skipEntryName
        dbf     d1,@iterEntries

@found
        moveq   #0,d2
        moveq   #0,d3

        ; read first half of ID
        move.b  (a6)+,d2
        lsl.l   #8,d2
        move.b  (a6)+,d2
        lsl.l   #8,d2
        move.b  (a6)+,d2
        lsl.l   #8,d2
        move.b  (a6)+,d2

        ; read second half of ID
        move.b  (a6)+,d3
        lsl.l   #8,d3
        move.b  (a6)+,d3
        lsl.l   #8,d3
        move.b  (a6)+,d3
        lsl.l   #8,d3
        move.b  (a6)+,d3

        tst.b   (a6)+   ; skip type
        beq.s   @foundFile

        move.l  d2,vExplorerScreen_CurrentEntryId_1
        move.l  d3,vExplorerScreen_CurrentEntryId_2
        move.w  #4,vExplorerScreen_Action
        rts ; found dir

@foundFile
        rts


; ---------------------------------------------------------------------------
ExplorerScreen_LoopEnd:
    rts

ExplorerScreen_End:
; ===========================================================================
; GFX
; ===========================================================================
Art_ExplorerList:
    incbin  "artunc/explorer-list.bin"
Art_ExplorerList__End:
Map_ExplorerList:
    incbin  "mapunc/explorer-list.bin"
Map_ExplorerList__End:
; =========================================================
; Logo Screen
; $FF6000.b - current action
; =========================================================
vLogoScreen_Action   equ $FFFF6000

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

	lea		Font_Art,a0
	moveq	#0,d0
	move.w	#(Font_Art_End-Font_Art)/4-1,d0
	vram	$0000
@fntArtLoop
	move.l	(a0)+,$C00000
	dbf		d0,@fntArtLoop

    lea     Logo_Art,a0
    moveq   #0,d0
    move.w  #(Logo_Map-Logo_Art)/4-1,d0
    vram    $0BE0
@logoArtLoop
    move.l  (a0)+,$C00000
    dbf     d0,@logoArtLoop

    lea     Logo_Map,a0
    moveq   #0,d0
    move.w  #(Logo_Map-Logo_Art)/2-1,d0
    vram    $E000
    moveq   #40,d2
@logoMapLoop
    move.w  (a0)+,d1
    add.w   #95,d1
    move.w  d1,$C00000

    sub.b   #1,d2
    bne.s   @lml_dbf
    moveq   #23,d2
@empty_tiles
    move.w  #0,$C00000
    dbf     d2,@empty_tiles
    moveq   #40,d2

@lml_dbf
    dbf     d0,@logoMapLoop

	lea		Logo_Pal,a0
	moveq	#0,d0
	move.w	#(LogoScreen_End-Logo_Pal)/2-1,d0
	lea		$FFFFFB20,a1
@logoPalLoop
	move.w	(a0)+,(a1)+
	dbf		d0,@logoPalLoop

	; first eye
	jsr 	FindFreeObject
	move.b	#1,(a0)
    move.w  #136+$80,8(a0)
    move.w  #88+$80,$C(a0)

	; second eye
    jsr 	FindFreeObject
	move.b	#1,(a0)
    move.w  #240+$80,8(a0)
    move.w  #88+$80,$C(a0)
    move.b  #1,$22(a0)

    ; reset vars
    move.b  #0,vLogoScreen_Action

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
    dc.w    LogoScreen_WaitForAnimEnd-LogoScreen_LoopActions
; ---------------------------------------------------------
LogoScreen_WaitForAnimEnd:
    rts

; =========================================================
; Font
; =========================================================
Font_Art:
		incbin "artunc/font.bin"
Font_Art_End:

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

; =============================================================
; Joypad button indexes & values
; For theld and tpress macros
; -------------------------------------------------------------

; $FFFFF602	= SonicControl|Held
; $FFFFF603	= SonicControl|Press
; $FFFFF604	= Joypad|Held
; $FFFFF605	= Joypad|Press  


_normal = $0000
_moving	= $0200
_linear = $0400

SonicControl	equ	$FFFFF602
Joypad		equ	$FFFFF604

Held		equ	0
Press		equ	1

iStart		equ 	7
iA		equ 	6
iC		equ 	5
iB		equ 	4
iRight		equ 	3
iLeft		equ 	2
iDown		equ 	1
iUp		equ 	0

Start		equ 	1<<7
A		equ 	1<<6
C		equ 	1<<5
B		equ 	1<<4
Right		equ 	1<<3
Left		equ 	1<<2
Down		equ 	1<<1
Up		equ 	1

; =============================================================
; Macro to check button presses
; Arguments:	1 - buttons to check
;		2 - bitfield to check
; -------------------------------------------------------------
tpress	macro
	move.b	(\2+1),d0
	andi.b	#\1,d0
	endm

; =============================================================
; Macro to check if buttons are held
; Arguments:	1 - buttons to check
;		2 - bitfield to check
; -------------------------------------------------------------
theld	macro
	move.b	\2,d0
	andi.b	#\1,d0
	endm

; =============================================================
; Macro to align data
; Arguments:	1 - align value
; -------------------------------------------------------------
align	macro
	cnop 0,\1
	endm

; =============================================================
; Macro to set VRAM write access
; Arguments:	1 - raw VRAM offset
;		2 - register to write access bitfield in (Optional)
; -------------------------------------------------------------
vram	macro
	if (narg=1)
		move.l	#($40000000+((\1&$3FFF)<<16)+((\1&$C000)>>14)),($C00004).l
	else
		move.l	#($40000000+((\1&$3FFF)<<16)+((\1&$C000)>>14)),\2
	endc
	endm

; =============================================================
; Macro to raise an error in vectors
; Arguments:	1 - error number
;		2 - branch location
;		3 - if exists, adds 2 to stack pointer
; -------------------------------------------------------------
raise	macro
		move.w	#\1,(-$7FC0).w
		jmp	ErrorScreen+$38(pc)
	endm
	


; =============================================================
stopZ80		macro
 		move.w	#$100,($A11100).l
		nop
		nop
		nop

@wait\@:	btst	#0,($A11100).l
		bne.s	@wait\@
		endm

; =============================================================

startZ80	macro
		move.w	#0,($A11100).l	; start	the Z80
		endm

; =============================================================

waitYM		macro
@wait\@:	move.b	($A04000).l,d2
		btst	#7,d2
		bne.s	@wait\@
		endm
; =============================================================
; Macro to easy play DAC samples
; Arguments:	1 - track number (must be in hex!!) e.g. F; F=$8F
; -------------------------------------------------------------
PlayDAC		macro
		move.w	#$FFFFFF80,d0
		add.w	#$\1,d0
		jsr		PlaySample
		endm
; =============================================================
; Macro to easy play music and sounds
; Arguments:	1 - music or sound number
; -------------------------------------------------------------
PlaySoMu	macro
		move.b	#$\1,d0
		jsr		PlaySound
		endm
; =============================================================
; Macro to simple fade out music
; Arguments:	not used
; -------------------------------------------------------------
FadeOut		macro
		move.b	#$E0,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple stop music
; Arguments:	not used
; -------------------------------------------------------------
StopMusic	macro
		move.b	#$E4,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple speed up music
; Arguments:	not used
; -------------------------------------------------------------
SpeedUp		macro
		move.b	#$E2,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to simple back music to normal speed
; Arguments:	not used
; -------------------------------------------------------------
BackToNormalSpeed	macro
		move.b	#$E3,d0
		jsr		PlaySound_Special
		endm
; =============================================================
; Macro to set object VRAM settings
; Arguments:	1 - VRAM pointer
;				2 - pallet row
;				3 - reverse
; -------------------------------------------------------------
SetVRAM	macro
		move.w	(((\2+\3)*$1000)+\1),$4(a0)
		endm
; =============================================================
; Macro to load art
; Arguments:	artoff - art offset (Nemesis)
;				vram_art - where store art in VRAM
;				paloff - pallet offset
;				palshft - pallet RAM shift
;				palclr - how many colors transfer
;				mapoff - map offset (Enigma)
;				enidec_param - parameter of EniDec
;				vram_map - where store map in VRAM
;				cols - cols
;				rows - rows
; -------------------------------------------------------------
LoadArt	macro artoff, vram_art, paloff, palshft, palclr, mapoff, enidec_param, vram_map, cols, rows
		vram	\vram_art
        lea		\artoff,a0
        jsr		NemDec
		
		lea		\paloff,a1
		lea		$FFFFFB00+\palshft,a2
		moveq	#\palclr-1,d0
@loop\@:
		move.w	(a1)+,(a2)+
		dbf		d0,@loop\@
		
        lea    	($FF0000).l,a1
        lea    	\mapoff,a0
        move.w	#\enidec_param,d0
        jsr		EniDec

		lea		($FF0000).l,a1
        vram	\vram_map,d0
        moveq   #\cols,d1
        moveq   #\rows,d2
        jsr		ShowVDPGraphics
		endm

; ---------------------------------------------------------------------
; Macro to draw raw mapping to the VRAM
; Input:
;	map_off 	- start of mapping
; 	map_end		- end of mapping
;	cur_width	- current width of the VDP plane
; 	base 		- base address in VRAM
;	x 			- x pos of tile
;	y 			- y pos of tile to draw
;	width 		- width of the plane
; 	flags 		- addition to the tile word (such as start tile, palette row, flips and priority)
; ---------------------------------------------------------------------
drawMap	macro map_off, map_end, cur_width, base, x, y, width, flags
	lea     \map_off,a0
    moveq   #0,d0
    move.w  #(\map_end-\map_off)/2-1,d0
    moveq   #\width/8,d2
	move.w	#(\base+\y*(\cur_width/4)+\x*2),d7
	jsr		Req_W_VRAM
@\map_off\__MapLoop
		move.w  (a0)+,d1
		add.w   #\flags,d1
		move.w  d1,$C00000

		sub.b   #1,d2
		bne.s   @\map_off\__lml_dbf

@\map_off\__empty_tiles
		add.w	#(\cur_width/4),d7
		jsr		Req_W_VRAM

    	moveq   #\width/8,d2

@\map_off\__lml_dbf
    dbf     d0,@\map_off\__MapLoop
	endm

; ---------------------------------------------------------------------
; Macro to draw raw mapping to the VRAM
; Input:
;	map_off 	- start of mapping
; 	map_end		- end of mapping
;	cur_width	- current width of the VDP plane
; 	base 		- base address in VRAM
;	x 			- x pos of tile
;	y 			- y pos of tile to draw
;	width 		- width of the plane
; 	flags 		- addition to the tile word (such as start tile, palette row, flips and priority)
; ---------------------------------------------------------------------
drawMapInObj	macro map_off, map_end, cur_width, base, x, y, width, flags
	lea     \map_off,a1
    moveq   #0,d0
    move.w  #(\map_end-\map_off)/2-1,d0
    moveq   #\width/8,d2
	move.w	#(\base+\y*(\cur_width/4)+\x*2),d7
	jsr		Req_W_VRAM
@\map_off\__MapLoop
		move.w  (a1)+,d1
		add.w   \flags,d1
		move.w  d1,$C00000

		sub.b   #1,d2
		bne.s   @\map_off\__lml_dbf

@\map_off\__empty_tiles
		add.w	#(\cur_width/4),d7
		jsr		Req_W_VRAM

    	moveq   #\width/8,d2

@\map_off\__lml_dbf
    dbf     d0,@\map_off\__MapLoop
	endm

; ---------------------------------------------------------------------
; Macro to move pal from one addr to another
; Inputs:
;	pal_off - start of pal
; 	pal_end - end of pal
;	to		- dest addr
; ---------------------------------------------------------------------
loadPal	macro pal_off, pal_end, to
	lea     \pal_off,a0
    moveq  #0,d0
    move.w  #(\pal_end-\pal_off)/2-1,d0
    lea		\to,a1

@\pal_off\__loop
		move.w	(a0)+,(a1)+
	dbf		d0,@\pal_off\__loop

	endm

; ---------------------------------------------------------------------
; Macro to load raw tiles to the VRAM
; Inputs:
;	art_off 	- start of art
; 	art_end 	- end of art
;	vram_addr	- VRAM addr
; ---------------------------------------------------------------------
loadArt	macro art_off, art_end, vram_addr
	lea		\art_off,a0
	moveq	#0,d0
	move.w	#(\art_end-\art_off)/4-1,d0
	vram	\vram_addr
@\art_off\__loop
	move.l	(a0)+,$C00000
	dbf		d0,@\art_off\__loop
	endm


string macro name
Str_\name\:
	if (narg=2)
		dc.b	\2, 0
	endc

	if (narg=3)
		dc.b	\2, \3, 0
	endc

	if (narg=4)
		dc.b	\2, \3, \4, 0
	endc

	if (narg=5)
		dc.b	\2, \3, \4, \5, 0
	endc

	if (narg=6)
		dc.b	\2, \3, \4, \5, \6, 0
	endc
Str_\name\_End:
Str_\name\_Length	equ	Str_\name\_End-Str_\name\
	endm

_n	equ	$0A

PosToVRAM macro base, x, y, cur_width, reg
	move.w	#\base+\y*(\cur_width/4)+\x*2,\reg
	endm

; ---------------------------------------------------------------------
; Macro to clear rect on plane
; Input:
;	cur_width	- current width of the VDP plane
; 	base 		- base address in VRAM
;	x 			- x pos of tile
;	y 			- y pos of tile to draw
;	width 		- width of the rect
;	height		- height of the rect 
;	clearWith	- clear value
; ---------------------------------------------------------------------
clearRect	macro cur_width, base, x, y, width, height, clearWith
    moveq   #0,d0
    move.w  #\height/8-1,d0
    moveq   #\width/8,d2
	PosToVRAM	\base, \x/8, \y/8, \cur_width, d7
	jsr		Req_W_VRAM
@clearRect__MapLoop
		move.w  #\clearWith,$C00000

		sub.b   #1,d2
		bne.s   @clearRect__MapLoop

		add.w	#(\cur_width/4),d7
		jsr		Req_W_VRAM

    	moveq   #\width/8,d2

@clearRect__lml_dbf
    dbf     d0,@clearRect__MapLoop
	endm
Sound_99_Header:
	smpsHeaderVoice     Sound_99_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM3, Sound_99_FM3,	$07, $04

; FM3 Data
Sound_99_FM3:
	smpsFMvoice        $00
	dc.b	G2, $A, B2, $A
	smpsStop

Sound_99_Voices:
;	Voice $00
	dc.b	$03
	dc.b	$10, $70, $00, $3F, 	$1F, $1F, $1F, $1F, 	$17, $1F, $00, $15
	dc.b	$00, $00, $00, $00, 	$FF, $0F, $0F, $FF, 	$03, $1B, $2C, $80

; Standard Octave Pitch Equates
smpsPitch10lo		EQU	$88
smpsPitch09lo		EQU	$94
smpsPitch08lo		EQU	$A0
smpsPitch07lo		EQU	$AC
smpsPitch06lo		EQU	$B8
smpsPitch05lo		EQU	$C4
smpsPitch04lo		EQU	$D0
smpsPitch03lo		EQU	$DC
smpsPitch02lo		EQU	$E8
smpsPitch01lo		EQU	$F4
smpsPitch00		EQU	$00
smpsPitch01hi		EQU	$0C
smpsPitch02hi		EQU	$18
smpsPitch03hi		EQU	$24
smpsPitch04hi		EQU	$30
smpsPitch05hi		EQU	$3C
smpsPitch06hi		EQU	$48
smpsPitch07hi		EQU	$54
smpsPitch08hi		EQU	$60
smpsPitch09hi		EQU	$6C
smpsPitch10hi		EQU	$78

; Note Equates
noff			EQU	$80
C1			EQU	$81
C_1			EQU	$82
D1			EQU	$83
D_1			EQU	$84
E1			EQU	$85
F1			EQU	$86
F_1			EQU	$87
G1			EQU	$88
G_1			EQU	$89
A1			EQU	$8A
A_1			EQU	$8B
B1			EQU	$8C
C2			EQU	$8D
C_2			EQU	$8E
D2			EQU	$8F
D_2			EQU	$90
E2			EQU	$91
F2			EQU	$92
F_2			EQU	$93
G2			EQU	$94
G_2			EQU	$95
A2			EQU	$96
A_2			EQU	$97
B2			EQU	$98
C3			EQU	$99
C_3			EQU	$9A
D3			EQU	$9B
D_3			EQU	$9C
E3			EQU	$9D
F3			EQU	$9E
F_3			EQU	$9F
G3			EQU	$A0
G_3			EQU	$A1
A3			EQU	$A2
A_3			EQU	$A3
B3			EQU	$A4
C4			EQU	$A5
C_4			EQU	$A6
D4			EQU	$A7
D_4			EQU	$A8
E4			EQU	$A9
F4			EQU	$AA
F_4			EQU	$AB
G4			EQU	$AC
G_4			EQU	$AD
A4			EQU	$AE
A_4			EQU	$AF
B4			EQU	$B0
C5			EQU	$B1
C_5			EQU	$B2
D5			EQU	$B3
D_5			EQU	$B4
E5			EQU	$B5
F5			EQU	$B6
F_5			EQU	$B7
G5			EQU	$B8
G_5			EQU	$B9
A5			EQU	$BA
A_5			EQU	$BB
B5			EQU	$BC
C6			EQU	$BD
C_6			EQU	$BE
D6			EQU	$BF
D_6			EQU	$C0
E6			EQU	$C1
F6			EQU	$C2
F_6			EQU	$C3
G6			EQU	$C4
G_6			EQU	$C5
A6			EQU	$C6
A_6			EQU	$C7
B6			EQU	$C8
C7			EQU	$C9
C_7			EQU	$CA
D7			EQU	$CB
D_7			EQU	$CC
E7			EQU	$CD
F7			EQU	$CE
F_7			EQU	$CF
G7			EQU	$D0
G_7			EQU	$D1
A7			EQU	$D2
A_7			EQU	$D3
B7			EQU	$D4
C8			EQU	$D5
C_8			EQU	$D6
D8			EQU	$D7
D_8			EQU	$D8
E8			EQU	$D9
F8			EQU	$DA
F_8			EQU	$DB
G8			EQU	$DC
G_8			EQU	$DD
A8			EQU	$DE
B8			EQU	$DF

; DAC Equates
NONE				EQU	$80
DKick				EQU $81
DSnare				EQU $82
DTimpani			EQU $83
;Blank				EQU $84
DSlap				EQU $85
DKick_n_Snare		EQU $86
DHi_Timpani			EQU $87
DMid_Timpani		EQU $88
DMid_Low_Timpani	EQU $89
DLow_Timpani		EQU $8A
DOp_Hi_Conga		EQU $8B
DLow_Conga			EQU $8C
DLow_Bongo			EQU $8D
DScratch_Push		EQU $8E
DCrash_Kick			EQU $8F
DHard_Kick			EQU $90
DHard_Snare			EQU $91
DScratch_Pull		EQU $92
DCrash				EQU	$9B

; Header macros for SFX (not for music)
; Header - Set up Tempo
smpsHeaderTempoSFX macro div
	dc.b	div
	endm

; Header - Set up Channel Usage
smpsHeaderChanSFX macro chan
	dc.b	chan
	endm

; Header - Set up FM Channel
smpsHeaderSFXChannel macro chanid,loc,pitch,vol
	dc.b	$80,chanid
	dc.w	loc-songStart
	dc.b	pitch
	dc.b	vol
	endm

; Channel IDs for SFX
cPSG1				EQU $80
cPSG2				EQU $A0
cPSG3				EQU $C0
cNoise				EQU $E0	; Not for use in S3/S&K/S3D
cFM3				EQU $02
cFM4				EQU $04
cFM5				EQU $05

; Header Macros
; Header - Set up Voice Location
smpsHeaderVoice macro loc
songStart set *
	dc.w	loc-songStart
	endm
; Header - Set up Channel Usage	
smpsHeaderChan macro fm,psg
	dc.b	fm,psg
	endm
; Header - Set up Tempo
smpsHeaderTempo macro div,mod
	dc.b	div,mod
	endm
; Header - Set up DAC Channel
smpsHeaderDAC macro loc
	dc.w	loc-songStart
	dc.w	$00
	endm
; Header - Set up FM Channel	
smpsHeaderFM macro loc,pitch,vol
	dc.w	loc-songStart
	dc.b	pitch,vol
	endm
; Header - Set up PSG Channel
smpsHeaderPSG macro loc,pitch,vol,voice
	dc.w	loc-songStart
	dc.b	pitch,vol
	dc.w	voice
	endm

; Co-ord Flag Macros and Equates
; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
panNone set $00
panRight set $40
panLeft set $80
panCentre set $C0
panCenter set $C0 ; silly Americans :U
	dc.b $E0,direction+amsfms
	endm
	
; E1xx - Alter note values by xx
smpsAlterNote macro val
	dc.b	$E1,val
	endm
	
; E2xx - Unknown
smpsE2 macro val
	dc.b	$E2,val
	endm

; E3 - Return (generally used after F8)
smpsReturn macro val
	dc.b	$E3
	endm
	
; E4 - Fade in previous song (ie. 1-Up)
smpsFade macro val
	dc.b	$E4
	endm

; E5xx - Set channel tempo divider to xx
smpsChanTempoDiv macro val
	dc.b	$E5,val
	endm
	
; E6xx - Alter Volume by xx
smpsAlterVol macro val
	dc.b	$E6,val
	endm
	
; E7 - Prevent attack of next note
smpsNoAttack	EQU $E7

; E8xx - Set note fill to xx
smpsNoteFill macro val
	dc.b	$E8,val
	endm
	
; E9xx - Add xx to channel pitch
smpsAlterPitch macro val
	dc.b	$E9,val
	endm
	
; EAxx - Set music tempo modifier to xx
smpsSetTempoMod macro val
	dc.b	$EA,val
	endm
	
; EBxx - Set music tempo divider to xx
smpsSetTempoDiv macro val
	dc.b	$EB,val
	endm
	
; ECxx - Set Volume to xx
smpsSetVol macro val
	dc.b	$EC,val
	endm
nB3					EQU	$B0
nG3					EQU	$AC
	
; ED - Unknown
smpsED		EQU $ED
	
; EE - Unknown (Something to do with voice selection)
smpsEE 		EQU $EE
	
; EFxx - Set Voice of FM channel to xx
smpsFMvoice macro voice
	dc.b	$EF,voice
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro wait,speed,change,step
	dc.b	$F0,wait,speed,change,step
	endm
	
; F1 - Turn on Modulation
smpsModOn macro
        dc.b    $F1
        endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm
	
; F3xx - PSG waveform to xx
smpsPSGform macro form
	dc.b	$F3,form
	endm
	
; F4 - Turn off Modulation
smpsModOff macro
        dc.b    $F4
        endm
; F5xx - PSG voice to xx
smpsPSGvoice macro voice
	dc.b	$F5,voice
	endm

; F6xxxx - Jump to xxxx
smpsJump macro loc
	dc.b	$F6
	dc.w	loc-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro index,loops,loc
	dc.b	$F7
	dc.b	index,loops
	dc.w	loc-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro loc
	dc.b	$F8
	dc.w	loc-*-1
	endm
	
; F9 - Unknown
smpsF9		EQU $F9

; Voices - Feedback
smpsVcFeedback macro val
vcFeedback set val
	endm

; Voices - Algorithm
smpsVcAlgorithm macro val
vcAlgorithm set val
	endm

; Voices - Detune
smpsVcDetune macro op1,op2,op3,op4
vcDT1 set op1
vcDT2 set op2
vcDT3 set op3
vcDT4 set op4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro op1,op2,op3,op4
vcCF1 set op1
vcCF2 set op2
vcCF3 set op3
vcCF4 set op4
	endm

; Voices - Rate Scale
smpsVcRateScale macro op1,op2,op3,op4
vcRS1 set op1
vcRS2 set op2
vcRS3 set op3
vcRS4 set op4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro op1,op2,op3,op4
vcAR1 set op1
vcAR2 set op2
vcAR3 set op3
vcAR4 set op4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro op1,op2,op3,op4
vcAM1 set op1
vcAM2 set op2
vcAM3 set op3
vcAM4 set op4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro op1,op2,op3,op4
vcD1R1 set op1
vcD1R2 set op2
vcD1R3 set op3
vcD1R4 set op4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro op1,op2,op3,op4
vcD2R1 set op1
vcD2R2 set op2
vcD2R3 set op3
vcD2R4 set op4
	endm

; Voices - Decay Level	
smpsVcDecayLevel macro op1,op2,op3,op4
vcDL1 set op1
vcDL2 set op2
vcDL3 set op3
vcDL4 set op4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro op1,op2,op3,op4
vcRR1 set op1
vcRR2 set op2
vcRR3 set op3
vcRR4 set op4
	endm

; Voices - Total Level
smpsVcTotalLevel macro op1,op2,op3,op4
vcTL1 set op1
vcTL2 set op2
vcTL3 set op3
vcTL4 set op4
	dc.b	(vcFeedback<<3)+vcAlgorithm
	dc.b	(vcDT4<<4)+vcCF4,(vcDT3<<4)+vcCF3,(vcDT2<<4)+vcCF2,(vcDT1<<4)+vcCF1
	dc.b	(vcRS4<<6)+vcAR4,(vcRS3<<6)+vcAR3,(vcRS2<<6)+vcAR2,(vcRS1<<6)+vcAR1
	dc.b	(vcAM4<<5)+vcD1R4,(vcAM3<<5)+vcD1R3,(vcAM2<<5)+vcD1R2,(vcAM1<<5)+vcD1R1
	dc.b	vcD2R4,vcD2R3,vcD2R2,vcD2R1
	dc.b	(vcDL4<<4)+vcRR4,(vcDL3<<4)+vcRR3,(vcDL2<<4)+vcRR2,(vcDL1<<4)+vcRR1
	dc.b	vcTL4,vcTL3,vcTL2,vcTL1	
	endm

; Header - Set up a secondary PWM Channel
smpsHeaderPWM macro loc
	dc.w	loc-songStart
	endm
	
; Header - Set up first PWM Channel
smpsHeaderPWM1 macro loc,num
	dc.w	loc-songStart
	dc.b	num,0
	endm
	

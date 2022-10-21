; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_8cD4q:	
		dc.w SME_8cD4q_A-SME_8cD4q, SME_8cD4q_15-SME_8cD4q	
		dc.w SME_8cD4q_2A-SME_8cD4q, SME_8cD4q_3F-SME_8cD4q	
		dc.w SME_8cD4q_54-SME_8cD4q	
SME_8cD4q_A:	dc.b 2	
		dc.b 3, 4, 0, $64, $F6	
		dc.b 3, 4, 8, $64, 6	
SME_8cD4q_15:	dc.b 4	
		dc.b $F2, 4, 0, $64, $F5	
		dc.b $F2, 4, 8, $64, 5	
		dc.b 0, 4, 0, 8, 0	
		dc.b 8, 4, 0, $17, 0	
SME_8cD4q_2A:	dc.b 4	
		dc.b $EE, 5, 0, $66, $F5	
		dc.b $EB, 5, $18, $66, 5	
		dc.b 0, 4, 0, 8, $F8	
		dc.b 8, 4, 0, $17, $F8	
SME_8cD4q_3F:	dc.b 4	
		dc.b 0, 4, 0, 8, 8	
		dc.b 8, 4, 0, $17, 8	
		dc.b $EE, 5, 8, $66, 5	
		dc.b $EB, 5, $10, $66, $F5	
SME_8cD4q_54:	dc.b 2	
		dc.b 0, 4, 0, 8, 0	
		dc.b 8, 4, 0, $17, 0	
		even
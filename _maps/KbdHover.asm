; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_eMy8r:	
		dc.w SME_eMy8r_8-SME_eMy8r, SME_eMy8r_13-SME_eMy8r	
		dc.w SME_eMy8r_1E-SME_eMy8r, SME_eMy8r_2E-SME_eMy8r	
SME_eMy8r_8:	dc.b 2	
		dc.b 0, 5, 0, 0, 0	
		dc.b 0, 1, 8, 0, $10	
SME_eMy8r_13:	dc.b 2	
		dc.b 0, 5, 0, 0, 0	
		dc.b 0, 5, 8, 0, $10	
SME_eMy8r_1E:	dc.b 3	
		dc.b 0, 5, 0, 0, 0	
		dc.b 0, 1, 0, 2, $10	
		dc.b 0, 5, 8, 0, $18	
SME_eMy8r_2E:	dc.b 5	
		dc.b 0, 5, 0, 0, 0	
		dc.b 0, 5, 8, 0, $60	
		dc.b 0, $D, 0, 2, $10	
		dc.b 0, $D, 0, 2, $30	
		dc.b 0, 5, 0, 2, $50	
		even
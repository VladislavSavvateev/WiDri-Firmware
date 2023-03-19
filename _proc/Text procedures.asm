; =====================================================================
; Draws the text over on plane.
; Inputs:
; d7 - VRAM addr
; a6 - string location
; =====================================================================
DrawText:
    jsr     Req_W_VRAM

@loop
    moveq   #0,d0
    move.b  (a6)+,d0
    beq.s   @rts
    sub.b  #' ',d0
    move.w  d0,$C00000
    bsr     @loop

@rts
    rts
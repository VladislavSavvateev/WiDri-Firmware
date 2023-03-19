; =====================================================================
; Draws the text over on plane.
; Inputs:
; d7.w - VRAM addr
; d5.w - current width of plane
; a6.l - string location
; =====================================================================
DrawText:
    lsr.w   #2,d5

    jsr     Req_W_VRAM

@loop
    moveq   #0,d0

    move.b  (a6)+,d0
    beq.s   @rts

    cmp.b   #' ',d0
    bge.s   @nonControl

    ; check for \n
    cmp.b   #_n,d0
    bne.s   @nonN
    add.w   d5,d7
    jsr     Req_W_VRAM

@nonN
    bra     @loop

@nonControl
    sub.b  #' ',d0
    move.w  d0,$C00000
    bsr     @loop

@rts
    rts
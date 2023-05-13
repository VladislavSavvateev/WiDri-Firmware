WIFI__HAS_AP_CREDS      equ 0
WIFI__GET_SSID          equ 1
WIFI__SET_AP            equ 2
WIFI__CONNECT           equ 3
WIFI__DISCONNECT        equ 4
WIFI__GET_CON_STATUS    equ 5
WIFI__IP                equ 6
WIFI__SEARCH            equ 7
WIFI__GET_SCAN_RESULTS  equ 8
WIFI__FOUND_AP_COUNT    equ 9

USER__GET_ME    equ $10

AUTH__LOGIN         equ $20
AUTH__LOGOUT        equ $21
AUTH__IS_LOGGED_IN  equ $22

FILE__GET_LISTING   equ $30
FILE__DOWNLOAD      equ $31

; ===================================================================
; Checks for magic word in Arduino at the start
; output:
;   d0.b - non-zero, if OK
; =================================================================== 
Arduino_CheckForMagicWord:
    move.w  $B00004,d0
    move.w  $B00004,d0
    cmp.w   #1337,d0
    beq.s   @ok
    sf      d0
    rts

@ok st      d0
    rts

; ===================================================================
; Returns buffer length
; output:
;   d0.w - buffer length
; ===================================================================
Arduino_GetBufferLength:
    moveq   #0,d0
    move.w  $B00002,d0
    rts

; ===================================================================
; Flushes buffer of the Arduino
; ===================================================================
Arduino_FlushBuffer:
    jsr     Arduino_GetBufferLength
    tst.w   d0
    beq.s   @rts

    subq.b  #1,d0
@loop
        move.b  $B00000,d1
    dbf d0,@loop

@rts
    rts

; ===================================================================
; Sends wifi.has_ap_creds
; ===================================================================
WiFi_HasApCreds:
    move.b  #WIFI__HAS_AP_CREDS,$B00000
    rts

; ===================================================================
; Reads non-zero answer from any request
; output:
;   d0.b - 1 byte answer
; ===================================================================
WiFi_HasApCreds_r:
WiFi_SetAP_r:
WiFi_Connect_r:
WiFi_GetConStatus_r:
WiFi_Search_r:
Auth_IsLoggedIn_r:
Auth_Login_r:
    moveq   #0,d0
    move.b  $B00000,d0
    rts

; ===================================================================
; Sends wifi.get_ssid
; ===================================================================
WiFi_GetSSID:
    move.b  #WIFI__GET_SSID,$B00000
    rts

; ===================================================================
; Reads answer from wifi.get_ssid
; input:
;   a1 - buffer
; ===================================================================
WiFi_GetSSID_r:
    moveq   #0,d0
    move.b  $B00000,d0
    sub.b   #1,d0
@loop
        move.b  $B00000,(a1)+
    dbf d0,@loop
    move.b  #0,(a1)+
    rts

; ===================================================================
; Sends auth.login
; input:
;   a1 - SSID buf (null-terminated)
;   a2 - password buf (null-terminated)
; ===================================================================
WiFi_SetAP:
    move.b  #2,$B00000

    move.l  a1,a3
    moveq   #0,d0
@calcSSIDlen
        move.b  (a3)+,d1
        beq.s   @calcSSIDdone
        addq.b  #1,d0
        bra.s   @calcSSIDlen

@calcSSIDdone
    move.b  d0,$B00000

@sendSSID
        move.b  (a1)+,d0
        beq.s   @sendSSID_end
        move.b  d0,$B00000
        bra.s   @sendSSID

@sendSSID_end
    move.l  a2,a3
    moveq   #0,d0
@calcPassLen
        move.b  (a3)+,d1
        beq.s   @calcPassDone
        addq.b  #1,d0
        bra.s   @calcPassLen

@calcPassDone
    move.b  d0,$B00000

@sendPass
        move.b  (a2)+,d0
        beq.s   @sendPass_end
        move.b  d0,$B00000
        bra.s   @sendPass

@sendPass_end
    rts

; ===================================================================
; Sends wifi.connect
; ===================================================================
WiFi_Connect:
    move.b  #WIFI__CONNECT,$B00000
    rts

WiFi_Disconnect:
    rts

; ===================================================================
; Sends wifi.get_con_status
; ===================================================================
WiFi_GetConStatus:
    move.b  #WIFI__GET_CON_STATUS,$B00000
    rts

; ===================================================================
; Sends wifi.search
; ===================================================================
WiFi_Search:
    move.b  #WIFI__SEARCH, $B00000
    rts

; ===================================================================
; Sends wifi.get_scan_results
; ===================================================================
WiFi_GetScanResuls:
    move.b  #WIFI__GET_SCAN_RESULTS,$B00000
    rts

; ===================================================================
; Reads answer from wifi.get_scan_results
; input:
;   a1 - buffer
; ===================================================================
WiFi_GetScanResults_r:
    moveq   #0,d0
    move.b  $B00000,d0  ; get APs count
    beq.s   @rts
    move.b  d0,(a1)+
    subq.b  #1,d0

@apLoop
        moveq   #0,d1
        move.b  $B00000,d1  ; get SSID length
        subq.b  #1,d1

@ssidLoop
            move.b  $B00000,(a1)+   ; SSID char by char
            dbf     d1,@ssidLoop
        
        move.b  #0,(a1)+        ; string stop byte

        move.b  $B00000,(a1)+   ; sec byte
        dbf     d0,@apLoop
    
@rts
    rts

; ===================================================================
; Sends wifi.found_ap_count
; ===================================================================
WiFi_FoundApCount:
    move.b  #WIFI__FOUND_AP_COUNT,$B00000
    rts

; ===================================================================

; ===================================================================
; Sends user.get_me
; ===================================================================
User_GetMe:
    move.b  #USER__GET_ME,$B00000
    rts

; ===================================================================
; Reads answer from user.get_me
; input:
;   a1 - buffer
; ===================================================================
User_GetMe_r:
    moveq   #0,d0
    move.b  $B00000,d0
    sub.b   #1,d0
@loop
        move.b  $B00000,(a1)+
    dbf d0,@loop
    move.b  #0,(a1)+
    rts

; ===================================================================

; ===================================================================
; Sends auth.login
; input:
;   a1 - login buf (null-terminated)
;   a2 - password buf (null-terminated)
; ===================================================================
Auth_Login:
    move.b  #AUTH__LOGIN,$B00000

    move.l  a1,a3
    moveq   #0,d0
@calcLoginLen
        move.b  (a3)+,d1
        beq.s   @calcLoginLenDone
        addq.b  #1,d0
        bra.s   @calcLoginLen

@calcLoginLenDone
    move.b  d0,$B00000

@sendLogin
        move.b  (a1)+,d0
        beq.s   @sendLoginEnd
        move.b  d0,$B00000
        bra.s   @sendLogin

@sendLoginEnd
    move.l  a2,a3
    moveq   #0,d0
@calcPassLen
        move.b  (a3)+,d1
        beq.s   @calcPassDone
        addq.b  #1,d0
        bra.s   @calcPassLen

@calcPassDone
    move.b  d0,$B00000

@sendPass
        move.b  (a2)+,d0
        beq.s   @sendPass_end
        move.b  d0,$B00000
        bra.s   @sendPass

@sendPass_end
    rts

Auth_Logout:
    rts

; ===================================================================
; Sends auth.is_logged_in
; ===================================================================
Auth_IsLoggedIn:
    move.b  #AUTH__IS_LOGGED_IN,$B00000
    rts

; ===================================================================
; Sends file.get_listing
; input:
;   d1 - first half of ID   ($0000****)
;   d2 - second half of ID  ($****0000)
; ===================================================================
File_GetListing:
    move.b  #FILE__GET_LISTING,$B00000
    
    ; sends first half of ID
    move.l  d1,$B00000
    move.l  d2,$B00000

    rts

; ===================================================================
; Reads answer from file.get_listing
; input:
;   a1 - buffer
; ===================================================================
File_GetListing_r:
    moveq   #0,d1
    move.w  $B00000,d1
    subq.w  #1,d1

@readPath
        move.b  $B00000,(a1)+
    dbf     d1,@readPath
    move.b  #0,(a1)+

    moveq   #0,d1
    move.b  $B00000,d1
    lsl.w   #8,d1
    move.b  $B00000,d1
    move.w  d1,(a1)+
    beq.s   @rts

    subq.w  #1,d1
@entries
        ; read entry ID
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+
        move.b  $B00000,(a1)+

        ; read type
        move.b  $B00000,(a1)+

        moveq   #0,d2
        move.w  $B00000,d2
        subq.w  #1,d2
        
@entryName 
            move.b  $B00000,(a1)+
        dbf     d2,@entryName
        move.b  #0,(a1)+
    dbf     d1,@entries

@rts
    rts
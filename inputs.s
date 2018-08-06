; Patches to read CPS2-style inputs for CPS1 and to handle dip switches

SF2_BTN_UP      = $0008
SF2_BTN_DOWN    = $0004
SF2_BTN_LEFT    = $0002
SF2_BTN_RIGHT   = $0001
SF2_BTN_1       = $0010
SF2_BTN_2       = $0020
SF2_BTN_3       = $0040
SF2_BTN_4       = $0100
SF2_BTN_5       = $0200
SF2_BTN_6       = $0400

;Input read locations:
; Player:
; 403C6		800000.b
; 1D2BC		800001.b
; 1D2C8		800000.b
; B8050		800001.b
; B805C		800000.b
; Sys/DIP:
; 1D2A4		800018.b
; 1D3D4		80001A.b
; 1D3E0		80001C.b
; 1D3EC		80001E.b

; Patch DIP switches
	ORG	$01D3D4
	move.b	(DSWA_LOC).l, $86(a5)
	move.b	(DSWB_LOC).l, $87(a5)
	move.b	(DSWC_LOC).l, $88(a5)
	bra.s	$01D3F8

; Patch extra set of player reads (related to turbo?)
	ORG	$0B8044
	jsr	input_read_players
	bra.b	$0B8084

; mystery player input read from leftover debug stuff
	ORG	$0403C6
;	move.b	(CPS2_IN0 + 1).l, d0

; -----------------------------------------------------------------------------

	ORG LAST_ORG

; Called from replacement vblank routine.
input_read_all:
	jsr	input_read_system
	jsr	input_read_players
	jsr	input_read_kicks
	rts

;sys_input_translator:
input_read_system:
	; Read service mode switch
	move.w	(CPS2_IN2).l, d0
	not.w	d0
	andi.w	#$0002, d0
	lsl.w	#5, d0

	; Read service coin
	move.w	(CPS2_IN2).l, d1
	not.w	d1
	andi.w	#$0004, d1
	or.b	d1, d0

	; Read coins and transpose into two LSB
	move.w	(CPS2_IN2).l, d1
	not.w	d1
	andi.w	#$3000, d1
	lsr.w	#8, d1
	lsr.w	#4, d1
	or.b	d1, d0

	; Read start buttons and transpose
	move.w	(CPS2_IN2).l, d1
	not.w	d1
	andi.w	#$0300, d1
	lsr.w	#4, d1
	or.b	d1, d0
	move.b	d0, $72(a5)
	clr.w	d1
	rts

input_read_players:
	; Update previous-frame history
	move.w	$7A(a5), $7C(a5)
	move.w	$7E(a5), $80(a5)
	; Player two
	move.b	(CPS2_IN0 + 1).l, d0
	not.b	d0
	move.b	d0, $7B(a5)
	; Same for player one
	move.b	(CPS2_IN0).l, d0
	not.b	d0
	move.b	d0, $7F(a5)
	rts

; a5 = RAM base
; Mangles d0, d1
input_read_kicks:
	; Read kick buttons and transform
	move.w	(CPS2_IN1).l, d0
	not.w	d0
	move.w	d0, d1
	andi.b	#$07, d0
	move.b	d0, $7A(a5) ; Player 1 kick buttons

	move.w	d1, d0
	; P2B4-P2B5 are sensible
	andi.w	#$30, d0
	lsr.b	#4, d0
	; P2B6 is way over in another spot
	move.w	(CPS2_IN2).l, d1
	not.w	d1
	andi.w	#$4000, d1
	lsr.w	#8, d1
	lsr.w	#4, d1
	or.w	d1, d0
	move.b	d0, $7E(a5)
	move.b	d0, d1
	rts

LAST_ORG	:=	*

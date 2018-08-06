; STREET FIGHTER II' TURBO: HYPER FIGHTING on CPS2 hardware
; Michael Moffitt 2018
;
; This top level file should be assembled in the same directory as the SF2HF(j)
; rom files with the 68k program condensed to a flat binary.
; It will emit binaries suitable for the darksoft multi.
;
; New RAM locations:
; $FFFF00 - Used for swapping CPS2 sprite banks
; $FFFF02 - Set during vblank; set to 0 and block on going nonzero to wait
; $FFFF04 - DSWA
; $FFFF06 - DSWB
; $FFFF08 - DSWC
;
; Known bugs:
; * barrel punching stage has the top barrel invisible when the scroll is low
; * sprites stay on screen during some transitions when it should be black
; * high score entry and original test menu key repeat is unchained
; * ! after winning the game, it locks up on the win screen??

	CPU 68000
	PADDING OFF
	ORG		$000000
	BINCLUDE	"prg.orig"
FREE = $165800
	ORG FREE
LAST_ORG	:=	*

	INCLUDE		"cps.s"
	INCLUDE		"qsound.s"
	INCLUDE		"inputs.s"
	INCLUDE		"sprites.s"
	INCLUDE		"layer_lut.s"
	INCLUDE		"dipconfig.s"
	INCLUDE		"eeprom.s"
	INCLUDE		"fixes.s"

TEST_PRINT = $0B94EC

INIT_PALETTE_ROUTINE = $0B95B4

; ============================================================================
;                                Init patches
; ============================================================================
; Before jumping to "STREET FIGHTER II '" build screen do the qsound init
	ORG	$0B9288

; Replacement for the first part of the reset vector that commits registers
init_routine_hijack:
	ORG	$0B91E8
	nop	; Dummy out write to the CPS1 coin control register
	nop	;
	lea	.post, a4
	jmp	INIT_PALETTE_ROUTINE
.post:

	lea	$0B9258, a4 ; resume with remainder of normal init
	jmp	cps_init_reg_setup

; Hook in our own replacement to the start of vblank for inputs and sprites
vgl_replacement_hook:
	ORG	$1D1E0
	jmp	vbl_replacement

; Hook to init qsound after testing work RAM
init_screen_extras_hook:
	ORG	$0B9498
	jmp	init_extras


; Hook the end of vblank to allow for turbo adjustment
vbl_end_turbo_hook:
	ORG	$01D55E
	jmp	vbl_end_turbo

; -----------------------------------------------------------------------------

	ORG	LAST_ORG

; Hook in some extra functionality to the early pre-boot tests
init_extras:
	lea	$0B964A, a2
	lea	.post_print, a5
	jmp	TEST_PRINT

.post_print:
	; Clear sprite ram
	lea	.post_sprite_ram_clear, a4
	jmp	sprite_ram_clear

.post_sprite_ram_clear:
	; Do the init for qsound
	lea	.post_qsound_init, a4
	jmp	qsound_init


.post_qsound_init:
	; Overwrite sanity area to eliminate possible false positives
	move.w	#5555, (DIP_SANITY).l

	; Show RAM OK
	lea	qsound_init_text, a2
	lea	$0B94A4, a5
	jmp	TEST_PRINT


; Replace the start of vblank with a few extra things
vbl_replacement:
;	tst.w	($FFFF00).l ; Unused scratch memory we will oscillate

; An unknown oscillation that HSF does. Not sure we need it.
;	beq	.no_qsound_unk
;	move.b	#$FF, ($619FFD).l
;	bra.b	.post_qsound_unk
;.no_qsound_unk:
;	move.b	#$00, ($619FFD).l
;
;.post_qsound_unk:

; Just a replication of what the original does
	move.b	#1, $33B(a5)
	movem.l	d0-a6, -(sp)
	move.w	$26(a5), $33C(a5)

	jsr	register_commit

	move.l	$72(a5), d0
	lsr.l	#8, d0
	move.l	d0, $72(a5)

	; Mark vblank as ended
	move.w	#$FFFF, (DIP_VBL_CHECK).l

	jsr	input_read_all

	jmp	$01D2F0 ; jump to post-input-reading

vbl_end_turbo:
	jsr	dipconfig_sanity_check

	move.w	DIP_TURBO_DELAY, d0
.turbo_waitloop:
	dbf	d0, .turbo_waitloop
	movem.l	(sp)+, d0-a6
	rte

LAST_ORG	:=	*

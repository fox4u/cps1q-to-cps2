
; DIP settings
;
; SWA
; ===
; 000- ----	1coin/1cred
; 001- ----	1coin/6cred
; 010- ----	1coin/3cred
; 011- ----	3coin/1cred
; 100- ----	1coin/2cred
; 101- ----	2coin/1cred
; 110- ----	1coin/4cred
; 111- ----	4coin/1cred
; ---0 00--	1coin/1cred
; ---0 01--	1coin/6cred
; ---0 10--	1coin/3cred
; ---0 11--	3coin/1cred
; ---1 00--	1coin/2cred
; ---1 01--	2coin/1cred
; ---1 10--	1coin/4cred
; ---1 11--	4coin/1cred
; ---- --c-	continue at half price
; ---- ---x	Unused
;
; SWB
; ===
; ddd- ----	Difficulty (reversed binary count from 0 - 7)
; ---p ----	2P game, 2cred; winner continues. Else, 1cred 2p game, no cont.
; ---- xxxx	Unused
;
; SWC
; ===
; xx-- ----	Unused
; --f- ----	Free play
; ---F ----	Freeze
; ---- r---	Reverse screen
; ---- -s--	Demo sound
; ---- --c-	Continue allowed
; ---- ---t	Test mode
;
; Condensed Options:
; Free play
; Coin 1 cost
; Coin 2 cost
; Demo Sound
; Allow continue
; Flip screen

;
;  ============================================
;  =         Soft-DIP configuration           =
;  ============================================
;
;  1  Free Play ............................ ON
;
;  2  Difficulty ............................ 1
;
;  3  Demo Sound .......................... OFF
;
;  4  Continue ............................. ON
;
;  5  Save
; -----------------------------------------------------------------------------

TURBO_DELAY_MAX = $1800

TURBO_DEFAULT = $0900

TURBO_STEP = $0300

SWC_CONTINUE_MASK = $40
SWC_SOUND_MASK = $20
SWC_FREEPLAY_MASK = $04

; TODO: Use an assembler variable to assign new ram locations dynamically
DIP_VBL_CHECK = $FFFF02
DIP_MEM_BASE = $FFFF04
DSWA_LOC = DIP_MEM_BASE + 0
DSWB_LOC = DIP_MEM_BASE + 2
DSWC_LOC = DIP_MEM_BASE + 4
DIP_SANITY = DIP_MEM_BASE + 6
DIP_TURBO_DELAY = DIP_MEM_BASE + 8

DIP_STORE_SIZE = 10
DIP_EEP_DEST = $00

DIP_CURRENT_SEL = DIP_MEM_BASE + 10
DIP_DIFF_STR = DIP_MEM_BASE + 12

DIP_MENU_SIZE = 7


; Hook to enter DIP menu when service button is pressed
dipconfig_menu_entry_hook:
	ORG	$0A7970
	jmp	dipconfig_menu_entry

; -----------------------------------------------------------------------------
	ORG	LAST_ORG

dipconfig_eeprom_read:
; Read D5 bytes from D4, to target at A0
	lea	(DIP_MEM_BASE).l, a0
	moveq	#DIP_STORE_SIZE, d5
	moveq	#DIP_EEP_DEST, d4
	jsr	eep_read

; Sanity check for turbo setting, in case it gets something invalid and
; locks everything up
	cmpi.w	#TURBO_DELAY_MAX+1, (DIP_TURBO_DELAY).l
	bge	.turbo_invalid
	rts

.turbo_invalid:
	move.w	#TURBO_DEFAULT, (DIP_TURBO_DELAY).l

	rts

dipconfig_eeprom_write:
	lea	(DIP_MEM_BASE).l, a0
	moveq	#DIP_STORE_SIZE, d5
	moveq	#DIP_EEP_DEST, d4
	jsr	eep_write
	rts

dipconfig_set_defaults:
	move.b	#$00, (DSWA_LOC).l
	move.b	#%11010000, (DSWB_LOC).l ; Difficulty normal; 2 credits for vs
	move.b	#%00100110, (DSWC_LOC).l ; Demo sound on, free play, continue on
	move.w	#TURBO_DEFAULT, (DIP_TURBO_DELAY).l
	move.w	#$BEEF, (DIP_SANITY).l
	rts

dipconfig_sanity_check:
	cmpi.w	#$BEEF, (DIP_SANITY).l
	beq.s	.sane_ok

	; If sanity failed, re-read the EPROM and check once more
	jsr	dipconfig_eeprom_read

	cmpi.w	#$BEEF, (DIP_SANITY).l
	beq.s	.sane_ok
	jmp	dipconfig_set_defaults

.sane_ok:
	rts

; Wraps the printing function from the init in a routine.
; a2: mapping
print_wrapper:
	movem.l	d0-d7/a0-a6, -(sp)
	lea	.retspot, a5
	jmp	TEST_PRINT
.retspot:
	movem.l	(sp)+, d0-d7/a0-a6
	rts

; Layout information for DIP screen
a_softdip_title:
	dc.b	$04
	dc.b	$08
	dc.b	1
	dc.b	"Street Fighter 2 Turbo DIP Configuration",0

a_softdip_opt1:
	dc.b	$08
	dc.b	$0C
	dc.b	0
	dc.b	"1  Free Play ...............",0

a_softdip_opt2:
	dc.b	$08
	dc.b	$0E
	dc.b	0
	dc.b	"2  Difficulty ............",0

a_softdip_opt3:
	dc.b	$08
	dc.b	$10
	dc.b	0
	dc.b	"3  Demo Sound ..............",0

a_softdip_opt4:
	dc.b	$08
	dc.b	$12
	dc.b	0
	dc.b	"4  Continue ................",0

a_softdip_opt5:
	dc.b	$08
	dc.b	$14
	dc.b	0
	dc.b	"5  Turbo ...................",0

a_softdip_opt6:
	dc.b	$08
	dc.b	$16
	dc.b	0
	dc.b	"6  Reset to defaults",0

a_softdip_opt7:
	dc.b	$08
	dc.b	$18
	dc.b	0
	dc.b	"7  Exit ",0

dipscreen_mapping_list:
	dc.l	a_softdip_title
	dc.l	a_softdip_opt1
	dc.l	a_softdip_opt2
	dc.l	a_softdip_opt3
	dc.l	a_softdip_opt4
	dc.l	a_softdip_opt5
	dc.l	a_softdip_opt6
	dc.l	a_softdip_opt7
	dc.l	0

dipscreen_text_palette:
	dc.w	$F4A5, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w	$F406, $F0F9, $F0E9, $F1D8, $F2C7, $F3B6, $F3A5, $0000

dipscreen_text_palette_sel:
	dc.w	$FF00, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w	$F811, $FFC0, $FFA0, $FF80, $FF60, $FF40, $FF20, $0000

a_on:
	dc.b	". ON",0
a_off:
	dc.b	" OFF",0
a_turbo_backing:
	dc.b	"         ",0
a_star:
	dc.b	"*", 0
a_sel:
	dc.b	">",0
a_blank:
	dc.b	" ",0

a_version:
	dc.b	"180219-RC1                   2018 MIKEJMOFFITT",0

	ALIGN	2

; a4 = palette selection
; d0 = index
dipconfig_load_palette:
	lea	($900400).l, a0
	lsl.w	#5, d0
	add.w	d0, a0
	move.w	#$000, d0
.palette_write_top:
	move.w	(a4)+, d1
	move.w	d1, (a0)+
	addi.w	#$1, d0
	cmpi.w	#$10, d0
	bne	.palette_write_top

	rts

; Entry point for DIP config screen
dipconfig_top:
	; Clear sprites
	lea	SF_SPR_TABLE2, a0
	jsr	$050752
	lea	($900400).l, a0
	lea	dipscreen_text_palette_sel, a4
	move.w	#$0, d0
	jsr	dipconfig_load_palette
	lea	dipscreen_text_palette, a4
	move.w	#$1, d0
	jsr	dipconfig_load_palette

	jsr	dipconfig_clear_screen
	jsr	dipconfig_draw_layout
	jsr	dipconfig_eeprom_read
	clr.w	(DIP_CURRENT_SEL).l
	clr.w	(DIP_DIFF_STR).l

.main_loop:
	jsr	dipconfig_handle_inputs ; returns BEEF in d0 if exit
	cmpi.w	#$BEEF, d0
	bne	.no_exit
	bra	.exit_dipscreen
.no_exit:
	jsr	dipconfig_draw_choices
	jsr	dipconfig_highlight_selection

	; Zero out the sprite list and update it
	lea	SF_SPR_TABLE2+8, a0
	jsr	$050752
	lea	.post_reg_setup, a4
	jmp	cps_init_reg_setup
.post_reg_setup:
	jsr	dipconfig_wait_vbl
	bra	.main_loop

.exit_dipscreen:

	jsr	dipconfig_eeprom_write

	rts

dipconfig_clear_screen:
	; TODO: This base address like other initial CPS configs should be an
	; enum so it may be configured elsewhere
	lea	$90C000, a1
	move.w	#$800, d0
	move.l	#$20002000, d1
.clrtop:
	move.l	d1, (a1)+
	dbf.w	d0, .clrtop
	rts

; Read inputs, change things based on them
dipconfig_handle_inputs:
	; Read P1 inputs, or with P2 inputs
	move.w	($FF807A).l, d0
	or.w	($FF807E).l, d0

	; Do the same with previous-frame inputs
	move.w	($FF807C).l, d1
	or.w	($FF8080).l, d1

	; Move selection up and down
	move.b	d0, d2
	andi.b	#SF2_BTN_DOWN, d2
	beq	.post_down
	move.b	d1, d2
	andi.b	#SF2_BTN_DOWN, d2
	bne	.post_down

	; Increment menu choice, wrap around bottom
	move.w	(DIP_CURRENT_SEL).l, d2
	addi.w	#$1, d2
	cmpi.w	#DIP_MENU_SIZE, d2
	bne.b	.no_down_wrap
	clr.w	(DIP_CURRENT_SEL).l
	bra.b	.post_down

.no_down_wrap:
	move.w	d2, (DIP_CURRENT_SEL).l

.post_down:
	move.b	d0, d2
	andi.b	#SF2_BTN_UP, d2
	beq	.post_up
	move.b	d1, d2
	andi.b	#SF2_BTN_UP, d2
	bne	.post_up

	move.w	(DIP_CURRENT_SEL).l, d2
	bne	.no_up_wrap
	move.w	#(DIP_MENU_SIZE-1), (DIP_CURRENT_SEL).l
	bra	.post_up

.no_up_wrap:
	subi.w	#1, d2
	move.w	d2, (DIP_CURRENT_SEL).l	

.post_up:

	; Select an item for change
	move.w	d0, d2
	andi.w	#(SF2_BTN_RIGHT | SF2_BTN_LEFT | $0990), d2
	beq	.post_select
	move.w	d1, d2
	andi.w	#(SF2_BTN_RIGHT | SF2_BTN_LEFT | $0990), d2
	bne	.post_select

	; Button pressed - do something
	jsr	dip_handle_button_press

.post_select:
	rts


dip_handle_button_press:
	move.w	d0, d2
	move.w	(DIP_CURRENT_SEL).l, d0
	
	cmpi.w	#$0, d0
	bne	.post_0
	eori.b	#SWC_FREEPLAY_MASK, (DSWC_LOC).l
	
	rts

.post_0:
	cmpi.w	#$1, d0
	bne	.post_1
	jsr	dip_difficulty_modify

	rts

.post_1:
	cmpi.w	#$2, d0
	bne	.post_2
	eori.b	#SWC_SOUND_MASK, (DSWC_LOC).l

	rts

.post_2:
	cmpi.w	#$3, d0
	bne	.post_3
	eori.b	#SWC_CONTINUE_MASK, (DSWC_LOC).l

	rts

.post_3:
	cmpi.w	#$4, d0
	bne	.post_4

	; Was left pressed?
	andi.w	#(SF2_BTN_LEFT), d2
	bne	.turbo_left_pressed

	; Increment turbo amount
	cmpi.w	#TURBO_STEP, (DIP_TURBO_DELAY).l
	bge.s	.turbo_sub
	; Underflow
	move.w	#TURBO_DELAY_MAX, (DIP_TURBO_DELAY).l
	rts
.turbo_sub:
	subi.w	#TURBO_STEP, (DIP_TURBO_DELAY).l
	rts

.turbo_left_pressed:
	cmpi.w	#TURBO_DELAY_MAX, (DIP_TURBO_DELAY).l
	blt.s	.turbo_add
	; Overflow
	move.w	#0, (DIP_TURBO_DELAY).l
	rts
.turbo_add:
	addi.w	#TURBO_STEP, (DIP_TURBO_DELAY).l
	rts

.post_4:
	cmpi.w	#$5, d0
	bne	.post_5
	; Reset to default
	jsr	dipconfig_set_defaults
	rts

.post_5:
	cmpi.w	#$6, d0
	bne	.post_6
	move.w	#$BEEF, d0
	rts

.post_6:
	rts
; SWA
; ===
; 000- ----	1coin/1cred
; 001- ----	1coin/6cred
; 010- ----	1coin/3cred
; 011- ----	3coin/1cred
; 100- ----	1coin/2cred
; 101- ----	2coin/1cred
; 110- ----	1coin/4cred
; 111- ----	4coin/1cred
; ---0 00--	1coin/1cred
; ---0 01--	1coin/6cred
; ---0 10--	1coin/3cred
; ---0 11--	3coin/1cred
; ---1 00--	1coin/2cred
; ---1 01--	2coin/1cred
; ---1 10--	1coin/4cred
; ---1 11--	4coin/1cred
; ---- --c-	continue at half price
; ---- ---x	Unused
;
; SWB
; ===
; ddd- ----	Difficulty (reversed binary count from 0 - 7)
; ---p ----	2P game, 2cred; winner continues. Else, 1cred 2p game, no cont.
; ---- xxxx	Unused
;
; SWC
; ===
; xx-- ----	Unused
; --f- ----	Free play
; ---F ----	Freeze
; ---- r---	Reverse screen
; ---- -s--	Demo sound
; ---- --c-	Continue allowed
; ---- ---t	Test mode
; Draw the values of different options

; D0 = palette choice
; D1 = line selection
dipconfig_line_set_pal:
	lea	$90C002, a1
	addi.w	#$2, d1
	lsl.w	#2, d1
	add.w	d1, a1
	andi.w	#$000F, d0
	move.w	#192, d7
.write_top:
	move.w	d0, (a1)
	addi.w	#$80, a1
	dbf	d7, .write_top
	rts

; Print a word on the screen
; D0 = X
; D1 = Y
; D2 = value
dipconfig_xyprint_hex:
	lea	$90C000, a1
	addi.w	#$2, d1
	lsl.w	#2, d1
	add.w	d1, a1
	lsl.w	#7, d0
	add.w	d0, a1

	move.w	#3, d7

.write:
	move.b	#$40, (a1)+
	move.w	d2, d4
	lsl.w	#4, d2
	andi.w	#$F000, d4
	lsr.w	#8, d4
	lsr.w	#4, d4
	andi.w	#$FFF0, d2
	or	d4, d2
	move.b	d2, d3

	andi.w	#$F, d3
	move.b	d3, (a1)+
	move.w	#$0000, (a1)+
	addi.w	#($80 - $4), a1
	dbf	d7, .write

	rts

; A0 = thing to print
; D0 = X
; D1 = Y
dipconfig_xyprint:
	lea	$90C000, a1
	addi.w	#$2, d1 ; Offset for scroll
	lsl.w	#2, d1
	add.w	d1, a1
	lsl.w	#7, d0
	add.w	d0, a1
.copytop:
	move.b	#$40, (a1)+
	move.b	(a0)+, (a1)+
	move.w	#$0000, (a1)+
	addi.w	#($80 - $4), a1
	cmpi.b	#$00, (a0)
	bne	.copytop
	rts

dipconfig_draw_choices:
; Free play
	lea	a_off, a0
	move.b	DSWC_LOC, d0
	andi.b	#SWC_FREEPLAY_MASK, d0
	beq.b	.freeplay_draw
	lea	a_on, a0
.freeplay_draw
	move.w	#32, d0
	move.w	#10, d1
	jsr	dipconfig_xyprint

; Special case for difficulty
	move.b	DSWB_LOC, d0
	move.b	d0, d1
	andi.w	#$80, d1
	lsr.b	#7, d1
	move.b	d1, d2
	move.b	d0, d1
	andi.w	#$40, d1
	lsr.b	#5, d1
	or.b	d1, d2
	move.b	d0, d1
	andi.w	#$20, d1
	lsr.b	#3, d1
	or.b	d1, d2
	; D2 contains difficulty as regular integer
	addi.w	#$31, d2 ; Add 1 and bring it up to the 0 char
	lea	DIP_DIFF_STR, a0
	move.w	#$0000, (DIP_DIFF_STR).l
	move.b	d2, (DIP_DIFF_STR).l
	move.w	#35, d0
	move.w	#12, d1
	jsr	dipconfig_xyprint

; Demo sound
	lea	a_off, a0
	move.b	DSWC_LOC, d0
	andi.b	#SWC_SOUND_MASK, d0
	beq.b	.demosound_draw
	lea	a_on, a0
.demosound_draw
	move.w	#32, d0
	move.w	#14, d1
	jsr	dipconfig_xyprint

; Continue
	lea	a_off, a0
	move.b	DSWC_LOC, d0
	andi.b	#SWC_CONTINUE_MASK, d0
	beq.b	.continue_draw
	lea	a_on, a0
.continue_draw
	move.w	#32, d0
	move.w	#16, d1
	jsr	dipconfig_xyprint

; Turbo number
	jsr	dipconfig_turbo_draw

	rts

dipconfig_turbo_draw:
	; Draw backing behind turbo indicator
	lea	a_turbo_backing, a0
	move.w	#27, d0
	move.w	#18, d1
	jsr	dipconfig_xyprint
	

	; Initial print X and Y
	move.w	#TURBO_DELAY_MAX, d2
	sub.w	DIP_TURBO_DELAY, d2
	move.w	#28, d3
.draw_top:
	cmpi.w	#TURBO_STEP, d2
	bge.s	.not_finished
	rts
.not_finished:
	lea	a_star, a0
	move.w	d3, d0
	move.w	#18, d1
	jsr	dipconfig_xyprint
	addi.w	#1, d3
	subi.w	#TURBO_STEP, d2
	bra.s	.draw_top
	rts

; Draw the main layout
dipconfig_draw_layout:

	; Show version string
	move.w	#1, d0
	move.w	#26, d1
	lea	a_version, a0
	jsr	dipconfig_xyprint

	; Max number of mapping entries
	move.w	#DIP_MENU_SIZE, d0

.drawtop:
	move.w	d0, d1
	lsl.w	#2, d1
	lea	dipscreen_mapping_list, a2
	cmpi.l	#$00000000, a2
	bne	.next_mapping
	rts
.next_mapping:
	move.l	(a2, d1), a2
	jsr	print_wrapper
	dbf	d0, .drawtop

	rts

dipconfig_highlight_selection:
;	move.b	#$00, d0
;	move.w	#2, d1

	move.w	#DIP_MENU_SIZE, d7

.mark_top:
	; Set position to left of menu choices
	move.w	#6, d0 ; X = 6
	move.w	d7, d1
	lsl.w	#1, d1
	addi.w	#10, d1 ; Y = (choice * 2) + 10

	cmp.w	(DIP_CURRENT_SEL).l, d7
	bne	.draw_blank

	; Draw a >
	lea	a_sel, a0
	jsr	dipconfig_xyprint
	dbf	d7, .mark_top
	rts

.draw_blank:
	
	; Draw a space for this selection
	lea	a_blank, a0
	jsr	dipconfig_xyprint
	dbf	d7, .mark_top

	rts
	

	; Mark the line
;	jsr	dipconfig_line_set_pal

	rts

dipconfig_wait_vbl:
	move.w	#$0, (DIP_VBL_CHECK).l ; Clear the vblank flag
.wait_vbl:
	tst.w	(DIP_VBL_CHECK).l
	beq.b	.wait_vbl
	rts

; Increment the odd difficulty settin
dip_difficulty_modify:
	move.w	d2, d7
	move.b	(DSWB_LOC).l, d0
	move.b	d0, d1
	move.b	d0, d2
	andi.b	#$80, 0
	andi.b	#$40, d1
	andi.b	#$20, d2
	lsr.b	#2, d0
	lsl.b	#2, d2

	or.b	d2, d1
	or.b	d1, d0

	lsr.b	#5, d0

	andi.b	#(SF2_BTN_LEFT), d7
	beq	.no_sub
	tst.b	d0
	bne	.do_sub
	move.b	#7, d0
	bra.s	.post_change
.do_sub:
	subi.w	#1, d0
	bra.s	.post_change
.no_sub:
	; Do the actual addition
	addi.b	#1, d0
	cmpi.b	#$8, d0
	bne	.post_change
	clr.b	d0

.post_change:

	lsl.b	#5, d0

	move.b	d0, d1
	move.b	d0, d2
	andi.b	#$80, d0
	andi.b	#$40, d1
	andi.b	#$20, d2
	lsr.b	#2, d0
	lsl.b	#2, d2

	or.b	d2, d1
	or.b	d1, d0

	move.b	d0, (DSWB_LOC).l
	rts

	

; Soft-dip configuration screen

dipconfig_menu_entry:
	movem.l	d0-d7/a0-a6, -(sp)
	jsr	dipconfig_top
	movem.l	(sp)+, d0-d7/a0-a6
	jsr	$0A7928
	move.w	#$0, d0
	jmp	$0A7976

LAST_ORG	:=	*

; Sprites and CPS register poking

; SF2 HF puts its sprite tables here.
SF_SPR_TABLE1 = $910000 ; Sprites get put here
SF_SPR_TABLE2 = $918000 ; Sprites _would_ get put here, but that's been snipped

SPR_TERM_POS = $FFFF10

; Cut short memtests that hit CPS2 registers
	ORG $0B9486
	adda.l	#$FF00, a1
	ORG $0B953e
	move.w	#$1F00, d4

; Patch the ISP to not clobber CPS2 obj registers
sprite_fix_isp:
	ORG	$000000
	dc.l	$FFFFEA
	ORG	$040378
	move.l	($000000).w, sp

; TODO: Slated for removal. Not needed with bank detection code
; Disable use of second CPS1 sprite bank (stay in 910000)
; This makes it seem as though the bank at 918000 is selected for display,
; so the game will always write to the first bank.
;cps1_sprite_force_bank:
;	ORG $50740
;	ori.b	#$80, $27(a5)
;	rts

; Use bit 15 of the layer control register cache to indicate that we are on
; the title screen
title_prio_indicator_hack:
	ORG	$09A8EE
	move.w	#$89CE, $4E(a5)
	ORG	$0816F8
	move.w	#$89CE, $4E(a5)

; Hook the function that terminates the sprite list to initiate the sprite
; table copy.
; a0 already contains the end terminator position.
sprite_list_update_hook:
	ORG	$050752

;	move.l	a0, (SPR_TERM_POS).l ; Store terminator position
;	move.l	#$BEEFAD00, 0(a0) ; Throw false terminator for debug marking
;	move.l	#$D00CACA5, 4(a0)

	jmp sprtable_copy_lean

; The high score table does not terminate the sprite list so we must help it
; out by hooking it after the sprite table is updated.
; a0 contains the next sprite slot which we terminate.
hiscore_sprite_update_hook:
	ORG	$0032EA
	jmp	hiscore_sprite_update

; The round ending screen also needs a sprite update, but we do not want to
; modify the original sprite table this time.
round_end_sprite_update_hook:
	ORG	$0034EA
	jmp	round_end_sprite_update

; Replace a function which clears all sprites so it triggers the sprite copy
clear_sprites_hook:
	ORG	$0039F6
	jmp	sprites_clear

; Hack to get the new challenger text to appear
newchallenger_hook:
	ORG	$0033B2
	jmp	newchallenger_setup

	ORG	$0033DA
	jmp	newchallenger_hack

; -----------------------------------------------------------------------------

	ORG	LAST_ORG

newchallenger_setup:
	lea	(SPR_TERM_POS).l, a0
	movea.l	(a0), a0
	jmp	$0033BA

newchallenger_hack:
	ori.l	#%1000 0000 0000 0000 0000 0000 0000 0000, d2
	move.l	d2, (a0)
	move.w	d0, 4(a0)
	move.w	d1, 6(a0)
	move.l	#$00FF00FF, 8(a0)
	move.l	#$00FF00FF, 12(a0)
	suba.l	#$8000, a0
	move.l	d2, (a0)+
	move.w	d0, (a0)+
	move.w	d1, (a0)+
	move.l	#$00FF00FF, (a0)
	move.l	#$00FF00FF, 4(a0)
	adda.l	#$8000, a0
	move.l	a0, (SPR_TERM_POS).l
	jmp	$0033F8

round_end_sprite_update:
	moveq	#0, d0
	move.b	$13(a6), d0

	movem.l	d0-d7/a0-a6, -(sp)
	jsr sprtable_copy_lean
	movem.l	(sp)+, d0-d7/a0-a6

	jmp	$0034F0

hiscore_sprite_update:
	beq.w	.do_exit
	cmpi.b	#$2F, d0
	jmp	$0032F2

.do_exit:
	movem.l	d0-d7/a0-a6, -(sp)
	addi.w	#$200, a0
	jsr	$050752
	movem.l	(sp)+, d0-d7/a0-a6
	jmp	$00314C

sprites_clear:
	moveq	#0, d0
	move.w	d0, $2B4(a5)
	move.w	d0, $2B6(a5)
	lea	(SF_SPR_TABLE1).l, a0
	jsr	$003A62
	lea	(SF_SPR_TABLE2).l, a0
	jsr	$003A62
	bra	sprtable_copy_lean
	rts

sprite_manual_update_hook:
	addi.w	#$08, a0	; Offset to make room for the terminator
	move.l	#$BEEFAD00, 0(a0) ; Throw fals terminator for debug marking
	move.l	#$D00CACA5, 4(a0)
	jsr	sprtable_copy_lean
	jmp	$0B9896

; Clear sprites as part of init. Jumps back to (a4)
sprite_ram_clear:
	lea	(CPS2_OBJRAM1).l, a0
	lea	(CPS2_OBJRAM2).l, a1
	moveq	#$0, d1
	move.w	#$FF, d4
.clr_top:
	move.l	d1, (a1)+
	move.l	d1, (a1)+
	move.l	d1, (a1)+
	move.l	d1, (a1)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	dbf	d4, .clr_top
	jmp (a4)
	


; CPS custom and CPS2 sprite custom initialization routine
cps_init_reg_setup:
	move.w	#$0F00,	CPS2_EEPWRITE
	move.w	#$7080, (CPS2_SPR_BASE + 0).l ; Set object base?
	move.w	#$0, ($8040A0).l
	move.w	#$9180, (CPS_A_OBJ_BASE).l
	move.w	#$FFC0, (CPS_A_SCROLL1_X).l
	move.w	#$0000, (CPS_A_SCROLL1_Y).l
	move.w	#$807d, (CPS2_SPR_BASE + 2).l ; Unknown, is 808e when flipped
	move.w	#$40, (CPS2_SPR_BASE + 8).l ; Set X offset
	move.w	#$10, (CPS2_SPR_BASE + 10).l ; Set X offset
	move.w	#$90C0, (CPS_A_SCROLL1_BASE).l
	move.w	#$9040, (CPS_A_SCROLL2_BASE).l
	move.w	#$9080, (CPS_A_SCROLL3_BASE).l
	move.w	#$9200, (CPS_A_ROWSCROLL_BASE).l
	move.w	#$0000, ($80414e).l ; unknown thing in CPS-A range
	move.w	#$0106, ($804150).l
	move.w	#$0106, ($804152).l

	move.w	#$0F08, CPS2_EEPWRITE
	move.w	#$12C2, (CPS_B_LAYER_CTRL).l
	move.w	#$4570, (CPS2_OBJ_PRIO).l
	move.w	#$1101, (CPS2_OBJ_UNK2).l
	move.w	#$003F, (CPS_A_VIDEO_CTRL).l
	move.w	#$003F, (CPS_B_PALETTE_CTRL).l
	move.w	#$9000, (CPS_A_PALETTE_BASE).l

	jmp	(a4)

; Hooked from the spritelist_term function.
; a0 = location of final terminating sprite
sprtable_copy_lean:

	; Mask with $1FFF to find sprite_count * 8
	move.l	a0, d7
	andi.w	#$1FFF, d7
	lsr.w	#3, d7 ; Divide by 8
	; D7 now contains # sprites to count back from
	movea.l	a0, a1 ; Set up source

; D7 = number of sprites to copy
; Source pointer has now been walked to the end of the sprite table.
; Subtract 8 from a1 to remove the terminator.
; D7 tells us how many sprites to draw.
	lea	(CPS2_OBJRAM2).l, a0 ; Target

;	subi.w	#$0008, a1
.copytop:
	move.l	-(a1), d0
	move.l	-(a1), d1
	;Set priority to 2
	ori.l	#%1000 0000 0000 0000 0000 0000 0000 0000, d1
	move.l	d1, (a0)+
	move.l	d0, (a0)+
	dbf	d7, .copytop

.list_term:
	move.l	#$0000FF00, d0
	move.l	d0, -(a0)
	move.l	d0, -(a0)
	move.l	a0, (SPR_TERM_POS).l ; Store terminator position

.swap_buffers:
	; Swap sprite banks
	move.w	($FFFF00).l, d0 ; Unused scratch memory we will oscillate
	andi.w	#$0001, d0
	eor.w	#$0001, d0
	move.w	d0, ($FFFF00).l
	move.w	d0, (CPS2_OBJBANK).l
	rts

; Called during vblank to commit changes to CPS custom registers
register_commit:
	jsr	cps_a_updates
	jsr	cps_b_updates
	jsr	cps2_spr_updates
	rts

; Normal stuff, replicating what was originally there
; This has been re-ordered for sanity. On the CPS2 hardware doing things in
; this order causes no problems. I do not know what the reason was behind the
; esoteric order done in the CPS2 original.
cps_a_updates:
	move.w	$26(a5), (CPS_A_OBJ_BASE).l
	move.w	$28(a5), (CPS_A_SCROLL1_BASE).l
	move.w	$2A(a5), (CPS_A_SCROLL2_BASE).l
	move.w	$2C(a5), (CPS_A_SCROLL3_BASE).l
	move.w	$2E(a5), (CPS_A_ROWSCROLL_BASE).l
	move.w	$5C(a5), (CPS_A_SCROLL1_X).l
	move.w	$5E(a5), (CPS_A_SCROLL1_Y).l
	move.w	$60(a5), (CPS_A_SCROLL2_X).l
	move.w	$62(a5), (CPS_A_SCROLL2_Y).l
	move.w	$64(a5), (CPS_A_SCROLL3_X).l
	move.w	$66(a5), (CPS_A_SCROLL3_Y).l
	move.w	$70(a5), (CPS_A_ROWSCROLL_START).l
	
	; Generate layer enables for CPS_A_VIDEO_CTRL
	move.b	$2CE(a5), d0
	move.b	$2DB(a5), d1
	eor	d1, d0
	move.b	d0, $89(a5)
	lsl.w	#8, d0
	or.w	$48(a5), d0
	move.w	d0, (CPS_A_VIDEO_CTRL).l
	rts

; Nothing out of the ordinary; CPS_B_PRIO writes are likely not necessary.
cps_b_updates:
	move.w	$4E(a5), (CPS_B_LAYER_CTRL).l
	move.w	$50(a5), (CPS_B_PRIO0).l
	move.w	$52(a5), (CPS_B_PRIO1).l
	move.w	$54(a5), (CPS_B_PRIO2).l
	move.w	$56(a5), (CPS_B_PRIO3).l
	rts

cps2_spr_updates:
	move.w	#$807d, (CPS2_OBJ_UNK1).l ; Unknown, is 808e when flipped
	move.w	#$40, (CPS2_OBJ_XOFF).l ; Set X offset
	move.w	#$10, (CPS2_OBJ_YOFF).l ; Set Y offset
	move.w	#$1101, (CPS2_OBJ_UNK2).l ; Set unk2
; Priority hack for just the title screen
	cmpi.w	#$89CE, $4E(a5)
	beq.b	.title
	
	jsr	cps2_layer_ctrl_adjust_proper
	rts
.title:
	move.w	#$0404, (CPS2_OBJ_PRIO).l
	rts

cps2_layer_ctrl_adjust_proper:
	move.w	$4E(a5), d0
	move.l	a0, d1
	lsr.w	#5, d0
	and.w	#$01FE, d0
	movea.l	#cps2_layer_lut, a0
	move.w	(a0, d0.w), d0
	move.w	d0, (CPS2_OBJ_PRIO).l
	move.l	d1, a0
	rts

LAST_ORG	:=	*


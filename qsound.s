
; ============================================================================
;                                 QSound patches
; ============================================================================

	INCLUDE		"sndid.s"

Q_SMEM = $618000
QSOUND_STEREO_EN = Q_SMEM + $001ffd
QSOUND_CTRL = Q_SMEM + $00001F
Q_BUFFER_BASE = -$758A	; Base address for Qsound cmd buffer
Q_R_SLOT = -$758C; 
Q_W_SLOT = -$758E ; Writeback from the Z80 saying

; Replace the writes to the Z80 latch with a call to the qsound function
sound_play_hook:
	ORG	$01D498
	jmp	play_sound_hook

play_sound_hook:
	ORG	$01D488

	cmpi.b	#$FF, (QSOUND_CTRL).l
	bne.b	$01D4AA	; If z80 isn't ready, don't do this now

	jsr	play_sound

	bra.b	$01D4AA

; -----------------------------------------------------------------------------

	ORG LAST_ORG

qsound_init_text:
	dc.b	$11
	dc.b	$12
	dc.b	0
	dc.b	"QSOUND RAM OK ",0

play_sound:
	jsr	qsound_id_transform
	cmpi.w	#$0000, d1
	beq.b	.abort
	cmpi.w	#$00F0, d1
	beq.b	.do_stop
	jsr	qsound_simple_play
	rts
.do_stop:
	jsr	qsound_simple_stop
.abort:
	rts

; Translate between HF sound codes and matched codes from QSound driver
qsound_id_transform:
	lea	($19e, a5), a4	; Get sound queue base in A4
	move.w	($24, a5), d0	; slot of next sound to play
	move.w	(a4, d0.w), d1	; get original sound ID
	addq.w	#$2, d0		; Increment slot
	andi.w	#$7E, d0	; wrap slot at $7E
	move.w	d0, $24(a5)	; store slot position

	cmpi.w	#$0000, d1
	beq.b	.abort
	cmpi.w	#$00FF, d1
	beq.b	.abort

	cmpi.w	#$00F0, d1
	beq.b	.do_stop
	cmpi.w	#$00F7, d1
	beq.b	.do_stop

	; Codes above $8F are rejected
	cmpi.w	#$008F, d1
	ble.b	.no_wrap
	move.w	#$0000, d1
	rts
.no_wrap:
	
	andi.w	#$00FF, d1
	lsl.w	#1, d1

	clr.w	d0
	lea	sound_id_lookup_hsf2, a4
	move.w	$0(a4, d1.w), d0
	move.w	d0, d1

.abort:
	rts

.do_stop:
	move.w	#$00F0, d1
	rts

; Qsound initialization; returns to a4
qsound_init:
	; Fiddle with the Z80
	move.w	#$0F08, $804040.l
	; Clear QSound memory
	bra.s	.skip_clear
	lea	(Q_SMEM).l, a0
	move.b	#$FE, d0
	move.l	#$FFFFFFFF, d1
.clrtop:
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	move.l	d1, (a0)+
	dbf	d0, .clrtop

.skip_clear:
	; Tell QSound CPU we are ready
	move.b	#$88, (Q_SMEM + $1FFB).l
	move.b	#$00, (Q_SMEM + $1FFD).l
	move.b	#$FF, (Q_SMEM + $1FFF).l

	jmp	(a4)
	move.w	#$00FF, d1
	moveq	#0, d2
	move.w	d2, d3
	jsr	qsound_simple_stop
	move.b	#$FF, d0
	move.b	#$00, (Q_SMEM + $07).l
	move.b	#$00, (Q_SMEM + $09).l
	move.b	#$FF, (Q_SMEM + $01).l
	move.b	#$0B, (Q_SMEM + $03).l
	move.b	#$00, (Q_SMEM + $0D).l
	move.b	#$00, (Q_SMEM + $0F).l
	move.b	#$00, (Q_SMEM + $11).l
	move.b	#$00, (Q_SMEM + $13).l
	move.b	#$00, (Q_SMEM + $15).l
	move.b	#$0, (QSOUND_CTRL).l
	
	jmp	(a4)

qsound_simple_stop:
	move.b	#$FF, d0
	move.b	#$00, (Q_SMEM + $07).l
	move.b	#$00, (Q_SMEM + $09).l
	move.b	#$FF, (Q_SMEM + $01).l
	move.b	#$00, (Q_SMEM + $03).l
	move.b	#$00, (Q_SMEM + $0D).l
	move.b	#$00, (Q_SMEM + $0F).l
	move.b	#$00, (Q_SMEM + $11).l
	move.b	#$00, (Q_SMEM + $13).l
	move.b	#$00, (Q_SMEM + $15).l
	move.b	#$0, (QSOUND_CTRL).l
	rts

; Play the track in D1 without any queue
qsound_simple_play:
	; TODO: Load d0 with whether or not we want stereo or whatever
;	cmpi.b	#$0, d0
;	beq.b	.want_mono
	bra.b	.want_mono

	move.b	#$FF, (QSOUND_STEREO_EN).l

.want_mono:
	move.b	#$00, (QSOUND_STEREO_EN).l

	; If QSound driver is not ready, abort
	cmpi.b	#$FF, (QSOUND_CTRL).l
	bne.b	.finish

	move.b	#$00, (Q_SMEM + $07).l
	move.b	#$00, (Q_SMEM + $09).l
	move.b	d1, (Q_SMEM + $03).l
	lsr.w	#8, d1
	move.b	d1, (Q_SMEM + $01).l
	move.b	#$00, (Q_SMEM + $0D).l

	move.b	#$00, (Q_SMEM + $13).l
	move.b	#$00, (Q_SMEM + $15).l
	move.b	#0, (QSOUND_CTRL).l ; Send command req

.finish:
	rts

LAST_ORG	:=	*

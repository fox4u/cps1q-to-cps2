; Bunch of EEPROM stuff hastily yanked from trap15's shit

; EEPROM stuff
CPS2_EEP_DO_BIT         = 0
CPS2_EEP_DI_BIT         = 4
CPS2_EEP_CLK_BIT        = 5
CPS2_EEP_CS_BIT         = 6

CPS2_EEP_DO_MASK        = (1 << CPS2_EEP_DO_BIT)
CPS2_EEP_DI_MASK        = (1 << CPS2_EEP_DI_BIT)
CPS2_EEP_CLK_MASK       = (1 << CPS2_EEP_CLK_BIT)
CPS2_EEP_CS_MASK        = (1 << CPS2_EEP_CS_BIT)

CPS2_EEP_WORD_BITS      = 16
CPS2_EEP_ADDR_BITS      = 6
CPS2_EEP_OPCODE         = CPS2_EEP_ADDR_BITS
CPS2_EEP_START_BIT      = (CPS2_EEP_OPCODE + 2)
CPS2_EEP_CMD_LEN        = (CPS2_EEP_START_BIT + 1)
CPS2_EEP_OPCODE2        = (CPS2_EEP_OPCODE - 2)
CPS2_EEP_WORDS          = (1 << CPS2_EEP_ADDR_BITS)
CPS2_EEP_WORDS_MASK     = (CPS2_EEP_WORDS - 1)
CPS2_EEP_BYTES          = (CPS2_EEP_WORDS << 1)

CPS2_EEP_CMD_MISC       = 0
CPS2_EEP_CMD_WRITE      = 1
CPS2_EEP_CMD_READ       = 2
CPS2_EEP_CMD_ERASE      = 3

CPS2_EEP_CMD            FUNCTION	opcode, addr, (1 << CPS2_EEP_START_BIT) | (opcode << CPS2_EEP_OPCODE) | addr

CPS2_EEP_CMD_EWEN       = CPS2_EEP_CMD(CPS2_EEP_CMD_MISC, $3 << CPS2_EEP_OPCODE2)
CPS2_EEP_CMD_ERAL       = CPS2_EEP_CMD(CPS2_EEP_CMD_MISC, $2 << CPS2_EEP_OPCODE2)
CPS2_EEP_CMD_WRAL       = CPS2_EEP_CMD(CPS2_EEP_CMD_MISC, $1 << CPS2_EEP_OPCODE2)
CPS2_EEP_CMD_EWDS       = CPS2_EEP_CMD(CPS2_EEP_CMD_MISC, $0 << CPS2_EEP_OPCODE2)

CPS2_EEP_WRITE	MACRO
	move.b	d2, (CPS2_EEPWRITE).l
	ENDM

CPS2_EEP_READ	MACRO reg
	move.b	(CPS2_IN2 + 1).l, reg
	ENDM

CPS2_EEP_CS_ON	MACRO
	ori.b	#CPS2_EEP_CS_MASK, d2
	CPS2_EEP_WRITE
	ENDM

CPS2_EEP_CS_OFF	MACRO
	andi.b	#~CPS2_EEP_CS_MASK, d2
	CPS2_EEP_WRITE
	ENDM

CPS2_EEP_READ_CORE	MACRO	tgtreg, tmpreg1, tmpreg2
	; Read the word
	move.w	#CPS2_EEP_WORD_BITS - 1, tmpreg2
	moveq	#0, tgtreg
.inner_loop:
	add.w	tgtreg, tgtreg
	jsr	eep_clk
	CPS2_EEP_READ tmpreg1
	andi.w	#CPS2_EEP_DO_MASK, tmpreg1
	beq	.data_zero
	or.w	#1, tgtreg
.data_zero:
	dbf	tmpreg2, .inner_loop

	jsr	eep_clk
	CPS2_EEP_CS_OFF
	jsr	eep_clk

	ENDM


; ----------------------------------------------------------------------------
	ORG LAST_ORG

; Read D5 bytes from D4, to target at A0
eep_read:
	moveq	#0, d2
	ori.w	#CPS2_EEP_CMD(CPS2_EEP_CMD_READ, 0), d4

	lsr.w	#1, d5
.outer_loop:
	bsr	eep_cmd

	CPS2_EEP_READ_CORE	d0, d1, d3

	move.w	d0, (a0)+
	addq.w	#1, d4
	dbf	d5, .outer_loop
	rts

; Write D5 bytes from A0, to D4
eep_write:
	move	#0, d2
	move.w	d4, d7
	move.w	#CPS2_EEP_CMD_EWEN, d4
	bsr	eep_cmd

	CPS2_EEP_CS_OFF

	lsr.w	#1, d5
	move.w	d7, d4
.outer_loop:
	andi.w	#CPS2_EEP_WORDS - 1, d4
	ori.w	#CPS2_EEP_CMD(CPS2_EEP_CMD_ERASE, 0), d4
	bsr	eep_cmd
	bsr	eep_clk
	CPS2_EEP_CS_OFF
	bsr	eep_clk
	bsr	eep_wait_for_ack
	bne	.eeprom_failed

	andi.w	#CPS2_EEP_WORDS - 1, d4
	ori.w	#CPS2_EEP_CMD(CPS2_EEP_CMD_WRITE, 0), d4
	bsr	eep_cmd

	; write one word
	move.w	#CPS2_EEP_WORD_BITS - 1, d3
	move.w	(a0)+, d0

.inner_loop:
	andi.w	#~CPS2_EEP_DI_MASK, d2
	add.w	d0, d0
	bcc	.no_di
	ori.w	#CPS2_EEP_DI_MASK, d2
.no_di:
	CPS2_EEP_WRITE
	bsr	eep_clk
	dbf	d3, .inner_loop

	CPS2_EEP_CS_OFF
	bsr	eep_clk
	bsr	eep_clk

	bsr	eep_wait_for_ack
	bne	.eeprom_failed

	andi.b	#~CPS2_EEP_CLK_MASK, d2
	CPS2_EEP_WRITE

	addq.w	#1, d4
	dbf	d5, .outer_loop

	moveq	#0, d0
	rts

.eeprom_failed:
	moveq	#1, d0

eep_wait_for_ack:
	CPS2_EEP_CS_ON
	move.l	#$2FFFF, d1
.loop:
	subq.l	#1, d1
	beq	.timeout

	bsr	eep_clk
	CPS2_EEP_READ d0
	btst	#CPS2_EEP_DO_BIT, d0
	beq	.loop
	CPS2_EEP_CS_OFF
	bsr	eep_clk
	moveq	#0, d0
	rts

.timeout:
	moveq	#1, d0
	rts

eep_cmd:
	CPS2_EEP_CS_ON
	move.w	#CPS2_EEP_CMD_LEN, d3
	move.w	d4, d1
	lsl.w	#15 - CPS2_EEP_CMD_LEN, d1
.loop:
	andi.w	#~CPS2_EEP_DI_MASK, d2
	add.w	d1, d1
	bcc	.data_zero
	ori.b	#CPS2_EEP_DI_MASK, d2
.data_zero:
	CPS2_EEP_WRITE
	bsr	eep_clk
	dbf	d3, .loop
	rts

eep_clk:
	ori.b	#CPS2_EEP_CLK_MASK, d2
	CPS2_EEP_WRITE
	andi.b	#~CPS2_EEP_CLK_MASK, d2
	CPS2_EEP_WRITE
	rts


LAST_ORG	:=	*

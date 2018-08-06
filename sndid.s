
	ORG	LAST_ORG

_sndid_na = $00
_snd_unk = $00

; sound ID mapping
;	SF2HF	SSF2X
;	01	02	; Ryu
;	02	03	; Honda
;	03	05	; Blanka
;	04	01	; Ken
;	05	07	; Guile
;	06	04	; Chun Li
;	07	06	; Zangief
;	08	08	; Dhalsim
;	09	09	; Boxer
;	0A	0A	; Claw
;	0B	0B	; Sagat
;	0C	0C	; Dictator
;	0D	3B	; Challenge
;	0E	34	; Character Select
;	0F	35	; Match beginning
;	10	36	; Match over
;	11	37	; Continue?
;	12	3A	; High score table 2?
;	13	39	; Game Over
;	14	3A	; High score table
;	15	38	; Challenger
;	16	D3	; Street Fighter 2 theme
;	17	xx	; Nothing
;	18	23	; end
;	19	24	; end
;	1A	27	; end
;	1B	29	; end
;	1C	22	; end
;	1D	25	; end
;	1E	28	; end
;	1F	2A	; end


;	20	40	; coin
;	21	42	; change select
;	22	43	; confirm select
;	23	44	; bee-boop
;	24	45	; score ticking sound
;	25	46	; light
;	26	47	; medium
;	27	48	; heavy
;	28	49	; smack
;	29	4A	; smack
;	2A	4B	; smack
;	2B	4C
;	2C	4D
;	2D	4E
;	2E	50
;	2F	51
;	30	xx	; Nothing
;	31	52	; shattering
;	32	53	; box break
;	33	54	; break 2

;	34	21	; wedding
;	35	??	; some ending
;	36	??	; unknown punch
;	37	??	; unknown scratchy punch
;	38	55	; blanka electricity
;	39	5F	; elephant
;	3A	xx	; nothing
;	3B	5A	; knockin some shit around
;	3C	5B	; fire 
;	3D	5E	; plane
;	3E	5D	; claw
;	3F	xx	; nothing
;	40	??	; ooh!
;	41	xx	; nothing
;	42	??	; "HAH" (souds like "fuh....ck");
;	43	64	; Ryu "uuuwaaah"
;	44	xx
;	45	70	; chun uwaaah
;	46	??	; eh!
;	47	63	; huwah!
;	48	68	; chun yah
;	49	xx
;	4A	95	; gief laugh
;	4B	xx
;	4C	6E	; chun laugh
;	4D	8D	; yodel
;	4E	xx
;	4F	6F	; chun yatta
;	50	??	; crowd loop 1
;	51	??	; crowd cheer loop 1
;	52	AE	; "YOU"
;	53	AF	; "WIN"
;	54	B0	; "LOSE"
;	55	B1	; "PERFECT"
;	56	AC	; "FIGHT"
;	57	B2	; "JAPAAAN"
;	58	B5	; "BRAZIL"
;	59	B3	; "USA"
;	5A	B4	; "CHINA"
;	5B	B7	; "USSR"
;	5C	B6	; "INDIA"
;	5D	B8	; "SPAIN"
;	5E	B9	; "THAILAND"
;	5F	AB	; "ROUND"
;	60	??	; 1
;	61	??	; 2
;	62	??	; 3
;	63	??	; 4
;	64	??	; 5
;	65	??	; 6
;	66	??	; 7
;	67	??	; 8
;	68	??	; 9
;	69	BE	; "FINAL"
;	6A	60	; "SHORYUKEN"
;	6B	62	; "TATSUMAKI SENNPUKYAKU"
;	6C	78	; "DOSU KOI"
;	6D	7B	; Blanka yell
;	6E	7E	; "FIRE"
;	6F	7F	; "FLAME"
;	70	71	; "SONIC BOOM"
;	71	??	; abrupt hit
;	72	58	; block
;	73	?6A	; spinning bird kick
;	74	61	; "hadouken"
;	75	8F	; claw yell (or 8B)
;	76	90	; tiger
;	77	91	; uppercut
;	78	xx
;	79	12	; ryu fast
;	7A	13	; honda fast
;	7B	15	; blanka fast
;	7C	17	; guile fast
;	7D	11	; ken fast
;	7E	14	; chun fast
;	7F	16	; gief fast
;	80	18	; sim fast
;	81	19	; boxer fast
;	82	1A	; claw fast
;	83	1B	; sagat fast
;	84	1C	; dictator fast
;	85	80	; "YOGA"
;	86	??	; electric / slashing sound
;	87	55	; blanka electricity
;	88	??	; unk
;	89	??	; looping unk
;	8A	55	; electricity sustained
;	8C	??	; unknown music
;	8D	??	; unknown ending music (ken remix)
;	8F	02	; wrap back to 1
;	

;	F0	xx	; stop
;	F7	xx	; stop
;	??	11	



; Mappings to the HSF2 sound driver
sound_id_lookup_hsf2:
	dc.w	$00
	dc.w	$02	; Ryu
	dc.w	$03	; Honda
	dc.w	$05	; Blanka
	dc.w	$01	; Ken
	dc.w	$07	; Guile
	dc.w	$04	; Chun Li
	dc.w	$06	; Zangief
	dc.w	$08	; Dhalsim
	dc.w	$09	; Boxer
	dc.w	$0A	; Claw
	dc.w	$0B	; Sagat
	dc.w	$0C	; Dictator
	dc.w	$3B	; Challenge
	dc.w	$34	; Character Select
	dc.w	$35	; Match beginning
	dc.w	$36	; Match over
	dc.w	$37	; Continue?
	dc.w	$3A	; High score table 2?
	dc.w	$39	; Game Over
	dc.w	$3A	; High score table
	dc.w	$38	; Challenger
	dc.w	$D3	; Street Fighter 2 theme
	dc.w	_sndid_na	; Nothing
	dc.w	$23	; end
	dc.w	$24	; end
	dc.w	$27	; end
	dc.w	$29	; end
	dc.w	$22	; end
	dc.w	$25	; end
	dc.w	$28	; end
	dc.w	$2A	; end
	dc.w	$40	; coin
	dc.w	$42	; change select
	dc.w	$200	; confirm select
	dc.w	$44	; bee-boop
	dc.w	$45	; score ticking sound
	dc.w	$201	; light
	dc.w	$202	; medium
	dc.w	$203	; heavy
	dc.w	$204	; smack
	dc.w	$205	; smack
	dc.w	$206	; smack
	dc.w	$207
	dc.w	$208
	dc.w	$209
	dc.w	$50
	dc.w	$51
	dc.w	_sndid_na	; Nothing
	dc.w	$52	; shattering
	dc.w	$53	; box break
	dc.w	$54	; break 2
	dc.w	$21	; wedding
	dc.w	_snd_unk	; some ending
	dc.w	$20A	; unknown punch
	dc.w	_snd_unk	; unknown scratchy punch
	dc.w	$55	; blanka electricity
	dc.w	$5F	; elephant
	dc.w	_sndid_na	; nothing
	dc.w	$5A	; knockin some shit around
	dc.w	$5B	; fire 
	dc.w	$5C	; dictator moves
	dc.w	$5D	; dhalsim fire hit sound
	dc.w	_sndid_na	; nothing
	dc.w	_snd_unk	; ooh!
	dc.w	_sndid_na	; nothing
	dc.w	_snd_unk	; "HAH" (souds like "fuh....ck");
	dc.w	$20B	; Ryu "uuuwaaah"
	dc.w	_sndid_na
	dc.w	$20C	; chun uwaaah
	dc.w	$20D	; eh!
	dc.w	$20E	; huwah!
	dc.w	$20F	; chun yah
	dc.w	_sndid_na
	dc.w	$210	; gief laugh
	dc.w	_sndid_na
	dc.w	$211	; chun laugh
	dc.w	$212	; claw yodel
	dc.w	_sndid_na
	dc.w	$6F	; chun yatta
	dc.w	_snd_unk	; crowd loop 1
	dc.w	_snd_unk	; crowd cheer loop 1
	dc.w	$AE	; "YOU"
	dc.w	$AF	; "WIN"
	dc.w	$B0	; "LOSE"
	dc.w	$B1	; "PERFECT"
	dc.w	$AC	; "FIGHT"
	dc.w	$B2	; "JAPAAAN"
	dc.w	$B5	; "BRAZIL"
	dc.w	$B3	; "USA"
	dc.w	$B4	; "CHINA"
	dc.w	$B7	; "USSR"
	dc.w	$B6	; "INDIA"
	dc.w	$B8	; "SPAIN"
	dc.w	$B9	; "THAILAND"
	dc.w	$AB	; "ROUND"
	dc.w	$214	; 1
	dc.w	$215	; 2
	dc.w	$216	; 3
	dc.w	$217	; 4
	dc.w	$218	; 5
	dc.w	$219	; 6
	dc.w	$21A	; 7
	dc.w	$01FA	; 8
	dc.w	$01FB	; 9
	dc.w	$21B	; "FINAL"
	dc.w	$21C	; "SHORYUKEN"
	dc.w	$21D	; "TATSUMAKI SENNPUKYAKU"
	dc.w	$21E	; "DOSU KOI"
	dc.w	$21F	; Blanka yell
	dc.w	$220	; "FIRE"
	dc.w	$221	; "FLAME"
	dc.w	$222	; "SONIC BOOM"
	dc.w	$207	; abrupt hit
	dc.w	$58	; block
	dc.w	$223	; spinning bird kick
	dc.w	$224	; "hadouken"
	dc.w	$225	; claw yell (or 8B)
	dc.w	$226	; tiger
	dc.w	$227	; uppercut
	dc.w	_sndid_na
	dc.w	$12	; ryu fast
	dc.w	$13	; honda fast
	dc.w	$15	; blanka fast
	dc.w	$17	; guile fast
	dc.w	$11	; ken fast
	dc.w	$14	; chun fast
	dc.w	$16	; gief fast
	dc.w	$18	; sim fast
	dc.w	$19	; boxer fast
	dc.w	$1A	; claw fast
	dc.w	$1B	; sagat fast
	dc.w	$1C	; dictator fast
	dc.w	$228	; "YOGA"
	dc.w	_snd_unk	; electric / slashing sound
	dc.w	$55	; blanka electricity
	dc.w	$56	; unk
	dc.w	_snd_unk	; looping unk
	dc.w	$55	; electricity sustained
	dc.w	_snd_unk	; unknown music
	dc.w	_snd_unk	; unknown ending music (ken remix)
	dc.w	$	02	; wrap back to 1

; Mappings to the SSF2X sound driver
sound_id_lookup_ssf2x:
	dc.w	$00
	dc.w	$02	; Ryu
	dc.w	$03	; Honda
	dc.w	$05	; Blanka
	dc.w	$01	; Ken
	dc.w	$07	; Guile
	dc.w	$04	; Chun Li
	dc.w	$06	; Zangief
	dc.w	$08	; Dhalsim
	dc.w	$09	; Boxer
	dc.w	$0A	; Claw
	dc.w	$0B	; Sagat
	dc.w	$0C	; Dictator
	dc.w	$3B	; Challenge
	dc.w	$34	; Character Select
	dc.w	$35	; Match beginning
	dc.w	$36	; Match over
	dc.w	$37	; Continue?
	dc.w	$3A	; High score table 2?
	dc.w	$39	; Game Over
	dc.w	$3A	; High score table
	dc.w	$38	; Challenger
	dc.w	$D3	; Street Fighter 2 theme
	dc.w	_sndid_na	; Nothing
	dc.w	$23	; end
	dc.w	$24	; end
	dc.w	$27	; end
	dc.w	$29	; end
	dc.w	$22	; end
	dc.w	$25	; end
	dc.w	$28	; end
	dc.w	$2A	; end
	dc.w	$40	; coin
	dc.w	$42	; change select
	dc.w	$43	; confirm select
	dc.w	$44	; bee-boop
	dc.w	$45	; score ticking sound
	dc.w	$46	; light
	dc.w	$47	; medium
	dc.w	$48	; heavy
	dc.w	$49	; smack
	dc.w	$4A	; smack
	dc.w	$4B	; smack
	dc.w	$4C
	dc.w	$4D
	dc.w	$4E
	dc.w	$50
	dc.w	$51
	dc.w	_sndid_na	; Nothing
	dc.w	$52	; shattering
	dc.w	$53	; box break
	dc.w	$54	; break 2
	dc.w	$21	; wedding
	dc.w	_snd_unk	; some ending
	dc.w	_snd_unk	; unknown punch
	dc.w	_snd_unk	; unknown scratchy punch
	dc.w	$55	; blanka electricity
	dc.w	$5F	; elephant
	dc.w	_sndid_na	; nothing
	dc.w	$5A	; knockin some shit around
	dc.w	$5B	; fire 
	dc.w	$5E	; plane
	dc.w	$5D	; claw
	dc.w	_sndid_na	; nothing
	dc.w	_snd_unk	; ooh!
	dc.w	_sndid_na	; nothing
	dc.w	_snd_unk	; "HAH" (souds like "fuh....ck");
	dc.w	$64	; Ryu "uuuwaaah"
	dc.w	_sndid_na
	dc.w	$70	; chun uwaaah
	dc.w	_snd_unk	; eh!
	dc.w	$63	; huwah!
	dc.w	$68	; chun yah
	dc.w	_sndid_na
	dc.w	$95	; gief laugh
	dc.w	_sndid_na
	dc.w	$6E	; chun laugh
	dc.w	$8D	; yodel
	dc.w	_sndid_na
	dc.w	$6F	; chun yatta
	dc.w	_snd_unk	; crowd loop 1
	dc.w	_snd_unk	; crowd cheer loop 1
	dc.w	$AE	; "YOU"
	dc.w	$AF	; "WIN"
	dc.w	$B0	; "LOSE"
	dc.w	$B1	; "PERFECT"
	dc.w	$AC	; "FIGHT"
	dc.w	$B2	; "JAPAAAN"
	dc.w	$B5	; "BRAZIL"
	dc.w	$B3	; "USA"
	dc.w	$B4	; "CHINA"
	dc.w	$B7	; "USSR"
	dc.w	$B6	; "INDIA"
	dc.w	$B8	; "SPAIN"
	dc.w	$B9	; "THAILAND"
	dc.w	$AB	; "ROUND"
	dc.w	_snd_unk	; 1
	dc.w	_snd_unk	; 2
	dc.w	_snd_unk	; 3
	dc.w	_snd_unk	; 4
	dc.w	_snd_unk	; 5
	dc.w	_snd_unk	; 6
	dc.w	_snd_unk	; 7
	dc.w	_snd_unk	; 8
	dc.w	_snd_unk	; 9
	dc.w	$BE	; "FINAL"
	dc.w	$60	; "SHORYUKEN"
	dc.w	$62	; "TATSUMAKI SENNPUKYAKU"
	dc.w	$78	; "DOSU KOI"
	dc.w	$7B	; Blanka yell
	dc.w	$7E	; "FIRE"
	dc.w	$7F	; "FLAME"
	dc.w	$71	; "SONIC BOOM"
	dc.w	_snd_unk	; abrupt hit
	dc.w	$58	; block
	dc.w	$6A	; spinning bird kick
	dc.w	$61	; "hadouken"
	dc.w	$8F	; claw yell (or 8B)
	dc.w	$90	; tiger
	dc.w	$91	; uppercut
	dc.w	_sndid_na
	dc.w	$12	; ryu fast
	dc.w	$13	; honda fast
	dc.w	$15	; blanka fast
	dc.w	$17	; guile fast
	dc.w	$11	; ken fast
	dc.w	$14	; chun fast
	dc.w	$16	; gief fast
	dc.w	$18	; sim fast
	dc.w	$19	; boxer fast
	dc.w	$1A	; claw fast
	dc.w	$1B	; sagat fast
	dc.w	$1C	; dictator fast
	dc.w	$80	; "YOGA"
	dc.w	_snd_unk	; electric / slashing sound
	dc.w	$55	; blanka electricity
	dc.w	_snd_unk	; unk
	dc.w	_snd_unk	; looping unk
	dc.w	$55	; electricity sustained
	dc.w	_snd_unk	; unknown music
	dc.w	_snd_unk	; unknown ending music (ken remix)
	dc.w	$	02	; wrap back to 1
LAST_ORG	:=	*

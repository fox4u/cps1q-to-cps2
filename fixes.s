; Fixes to SF2' that are stylistic decisions

; Fix misplaced black dot in in-game text
	ORG	$0ADC20
	dc.w	$0B00
	ORG	$0ADC40
	dc.w	$004B

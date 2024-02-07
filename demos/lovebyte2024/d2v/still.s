
; still...

still:
	jsr	HOME
	bit	SET_TEXT

;	HLINE   = $F819                 ; HLINE Y,$2C at A
;	VLINE   = $F828                 ; VLINE A,$2D at Y

	lda	#'*'|$80
	sta	COLOR

	lda	#39
	sta	H2
	lda	#0
	tay
	jsr	HLINE

	; x=0, Y=39 after?
	sty	H2
	ldy	#0
	lda	#46
	jsr	HLINE
	; x=0, y=39 after

	lda	#46
	sta	V2
	lda	#0
	tay
	jsr	VLINE
	; x=0,y=0
	lda	#46
	sta	V2
	lda	#1
	ldy	#18
	jsr	VLINE
	lda	#46
	sta	V2
	lda	#1
	ldy	#39
	jsr	VLINE

	;==============
	; set screen for wrap

	lda	#20
	sta	$20		; left edge
	sta	$21		; right edge
	lda	#2
	sta	$22		; top edge

	;==================
	; draw opening

	lda	#<opening
	sta	INL
	lda	#>opening
	sta	INH

	ldy	#0
opening_loop:
	lda	(INL),Y
	beq	done_still
	ora	#$80
	jsr	COUT1
	iny
	bne	opening_loop	; bra

	;===========================
	; play music and draw loop

	lda	#<music_data
	sta	INL
	lda	#>music_data
	sta	INH


	ldy	#0
music_loop:
	lda	(INL),Y
	beq	done_music
	sta	$300		; F
	iny
	lda	(INL),Y
	sta	$301		; D
	iny

	sty	SAVEY

play_tone:
	lda	$C030		; click speaker
duration_loop:
	dey			; where is y set?
	bne	ahead
	dec	$0301		; $301=D
	beq	done_tone
ahead:
	dex
	bne	duration_loop
	ldx	$0300		; $300=F
	jmp	play_tone
done_tone:

	ldy	SAVEY
	jmp	music_loop

done_music:
	jmp	done_music

;	.byte 173,48,192,136,208,5,206,1,3,240,9
;	.byte 202,208,245,174,0,3,76,2,3,96


done_still:
	jmp	done_still

opening:
.byte	13
.byte "       ,:/;=",13
.byte "   ,X M@@M  HM@/",13
.byte "  @@M MX. XXXH@@#/",13
.byte " @@@X.       .    ;",13
.byte "@  M/          +M@M",13
.byte "@@M .          H @@",13
.byte "/MMMH.         MM =",13
.byte " .    .     -H @@M ",13
.byte "  =MMM@MH +M@+ MX",13
.byte "    ,++ .MMMM= ",0


	; F,D
music_data:
	.byte 85,54
	.byte 91,54
	.byte 102,54
	.byte 102,54
	.byte 91,54
	.byte 0
;80 T$="This ":D=54:F=85:GOSUB 8
;82 T$="was ":F=91:GOSUB 8
;84 T$="a ":F=102:GOSUB 8
;86 T$="tri":GOSUB 8
;89 T$="umph."+C$:F=91:GOSUB 8
;90 FOR I=1 TO 800:NEXT



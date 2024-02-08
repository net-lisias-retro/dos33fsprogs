
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
	sta	$21		; width
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
	beq	play_music
	ora	#$80
	jsr	COUT1
	iny
	bne	opening_loop	; bra

	;===========================
	; play music and draw loop

play_music:


	;==========================
	; set screen for wrap again

	lda	#1
	sta	$20		; left edge
	lda	#15		; width
	sta	$21
	lda	#2
	sta	$22		; top edge
	lda	#18
	sta	$23

	lda	#2
	sta	CH
	jsr	TABV


	;==================
        ; load song
        ;==================
	lda     #<music_data
	sta     MADDRL
	lda	#>music_data
	sta     MADDRH

	jsr	play_ed

done_music:
	jmp	done_music


display_lyrics_ed:
	lda	#'@'|$80
	jsr	COUT1
	lda	#'@'|$80
	jsr	COUT1
	lda	#'@'|$80
	jsr	COUT1
	lda	#' '|$80
	jsr	COUT1
	rts


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


.include "duet.s"

music_data:
.incbin "SA.ED"


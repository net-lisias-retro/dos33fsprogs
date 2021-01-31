; fake sierpinski

; x=0..39
;  T =0 	XX_T = 0 .. 0
;  T =1		XX_T = 0 .. 39 ($0027)
;  T =2		XX_T = 0 .. 78 ($004E)
;  T =3		XX_T = 0 .. 117 ($0075)
;  T = 128	XX_T = 0 .. 4992 ($1380)
;  T = 255	XX_T = 0 .. 9945 ($26D9)


; just plot X AND Y

;.include "zp.inc"
.include "hardware.inc"

GBASH	=	$27
MASK	=	$2E
COLOR	=	$30
XX	=	$F5
XX_TH	=	$F6
XX_TL	=	$F7
YY	=	$F8
YY_TH	=	$F9
YY_TL	=	$FA
T_L	=	$FB
T_H	=	$FC
FACTOR1	=	$FD
FACTOR2	=	$FE
SAVED	=	$FF


	;================================
	; Clear screen and setup graphics
	;================================
sier:

	jsr	SETGR		; set lo-res 40x40 mode
	bit	FULLGR		; make it 40x48

	lda	#0		; start with multiplier 0
	sta	T_L
	sta	T_H

sier_outer:

	lda	#0
	sta	YY
	sta	YY_TL
	sta	YY_TH

sier_yloop:

	; reset XX to 0

	lda	#0
	sta	XX
	sta	XX_TL
	sta	XX_TH


	; calc YY_T
	clc
	lda	YY_TL
	adc	T_L
	sta	YY_TL
	lda	YY_TH
	adc	T_H
	sta	YY_TH

	lda	YY

	lsr
	bcc	even_mask
	ldx	#$f0
	bne	set_mask
even_mask:
	ldx	#$0f
set_mask:
	stx	MASK

	jsr	GBASCALC	; take Y-coord/2 in A, put address in GBASL/H ( a trashed, C clear)

	lda	GBASH
draw_page_smc:
	adc	#0
	sta	GBASH


sier_xloop:

	; want (YY-(XX*T)) & (XX+(YY*T)


	; SAVED = XX+(Y*T)
	clc
	lda	XX	; XX
	adc	YY_TH
	sta	SAVED


	; calc XX*T
	clc
	lda	XX_TL
	adc	T_L
	sta	XX_TL
	lda	XX_TH
	adc	T_H
	sta	XX_TH


	; calc (YY-X_T)
	lda	YY
	sec
	sbc	XX_TH

	; want (YY-(XX*T)) & (XX+(YY*T)

	and	SAVED

;	and	#$ff
	beq	red

black:
	lda	#00	; black
	.byte	$2C	; bit trick
red:
	lda	#$11	; red

	sta	COLOR

	ldy	XX

	jsr	PLOT1		; PLOT AT (GBASL),Y

	inc	XX
	lda	XX
	cmp	#40
	bne	sier_xloop

	inc	YY
	lda	YY
	cmp	#48
	bne	sier_yloop

	; inc T
	clc
	lda	T_L
	adc	#1
	sta	T_L
	lda	T_H
	adc	#0
	sta	T_H

flip_pages:
	; X already 0

	lda	draw_page_smc+1 ; DRAW_PAGE
	beq	done_page
	inx
done_page:
	ldy	PAGE0,X         ; set display page to PAGE1 or PAGE2

	eor	#$4             ; flip draw page between $400/$800
	sta	draw_page_smc+1 ; DRAW_PAGE

	jmp	sier_outer


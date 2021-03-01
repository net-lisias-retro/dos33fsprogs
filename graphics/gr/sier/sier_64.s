; fake sierpinski

; scrolling and colors

; by Vince `deater` Weaver, dSr, Lovebyte 2021

; just plot XX AND YY

; zero page
COLOR	=	$30
XX	=	$66
YY	=	$67
FRAME	=	$68
;X2	=	$69

; soft-switches
FULLGR	=	$C052

; rom routines
PLOT	=	$F800	;; PLOT AT Y,A
PLOT1	=	$F80E	;; PLOT at (GBASL),Y (need MASK to be $0f or $f0)
SETCOL	=	$F864	;; COLOR=A
SETGR	=	$FB40

	;================================
	; Clear screen and setup graphics
	;================================
sier:

	jsr	SETGR		; set lo-res 40x40 mode
	bit	FULLGR		; make it 40x48

	lda	#0
	sta	FRAME

sier_loop:

	inc	FRAME

	ldx	#47		; YY

sier_yloop:

	lda	#39
	sta	XX

	tay
	txa
	jsr	PLOT		; PLOT AT Y,A
				; sets GBASL/GBASH and MASK

sier_xloop:

	txa
	clc
	adc	FRAME

;	sta	X2
;	lda	XX
;	adc	FRAME
;	and	X2

	and	XX

	bne	black
;	lda	#$11	; red
	lda	FRAME
	lsr
	lsr
	lsr
	lsr
	bne	not_zero
	lda	#3

not_zero:

	.byte	$2C	; bit trick
black:
	lda	#$00
;	sta	COLOR
	jsr	SETCOL

	ldy	XX
	txa
	jsr	PLOT1		; PLOT AT (GBASL),Y

	dec	XX
	bpl	sier_xloop

	dex
	bpl	sier_yloop

done:
	bmi	sier_loop

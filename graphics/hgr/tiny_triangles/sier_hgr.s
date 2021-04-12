; sierpinski-like demo
; based on the code from Hellmood's Memories demo

; by Vince `deater` Weaver <vince@deater.net>

; the simple sierpinski you more or less just plot
;		X AND Y

; Hellmood's you plot something more or less like
; 	COLOR = ( (Y-(X*T)) & (X+(Y*T) ) & 0xf0
; where T is an incrementing frame value

; to get speed on 6502/Apple II we change the multiplies to
; a series of 16-bit 8.8 fixed point adds

; TODO:
;	HPLOT timing
;	MOVERIGHT timing
;	MOVERIGHT MOVEDOWN timing
;	LOOKUP TABLE timing


; zero page

HGR_BITS	= $1C
GBASL		= $26
GBASH		= $27
MASK		= $2E
COLOR		= $30
HGR_HMASK	= $30
HGR_X		= $E0
HGR_Y		= $E2
HGR_COLOR	= $E4


SAVEX	=	$F7
XX_TH	=	$F8
XX_TL	=	$F9
YY	=	$FA
YY_TH	=	$FB
YY_TL	=	$FC
T_L	=	$FD
T_H	=	$FE
SAVED	=	$FF

; Soft switches
FULLGR	= $C052
PAGE1	= $C054
PAGE2	= $C055
LORES	= $C056		; Enable LORES graphics

; ROM routines
HGR	= $F3E2
HGR2	= $F3D8
HPOSN		= $F411
HPLOT0		= $F457
HPLOT1		= $F45A		; skip the HPOSN call
COLOR_SHIFT	= $F47E		; shift color for odd/even Y (0..7 or 7..13)
MOVE_RIGHT	= $F48A		; move next plot location one to the right
MOVE_DOWN	= $F504		; clc at f504, needed?
				; f505 is applesoft entry point but assumes c?
				; move next plot location one to the right

				; note moveright/movedown respect HGR_PAGE

COLORTBL	= $F6F6


;.zeropage
;.globalzp T_L,T_H

	;================================
	; Clear screen and setup graphics
	;================================
sier:
	jsr	HGR2		; set FULLGR, sets A=0


	lda	#0		; start with multiplier 0
	sta	T_L
	sta	T_H

sier_outer:
	ldy	#$40
	sty	GBASH


	ldy	#0		; YY starts at 0
	sty	YY
	sty	GBASL

	sty	YY_TL
	sty	YY_TH

sier_yloop:

	ldy	#0		; y is x/7

	lda	#$FF
	sta	HGR_HMASK

	; calc YY_T (8.8 fixed point add)
	; save space by skipping clc as it's only a slight variation w/o
;	clc
	lda	YY_TL
	adc	T_L
	sta	YY_TL
	lda	YY_TH
	adc	T_H
	sta	YY_TH

	; reset XX to 0

	ldx	#0		; XX
	stx	XX_TL
	stx	XX_TH

sier_xloop:

	; want (YY-(XX*T)) & (XX+(YY*T)


	; SAVED = XX+(Y*T)
;	clc
	txa		; XX					; 2
	adc	YY_TH						; 3
	sta	SAVED						; 3

	; calc XX*T
;	clc
	lda	XX_TL						; 3
	adc	T_L						; 3
	sta	XX_TL						; 3
	lda	XX_TH						; 3
	adc	T_H						; 3
	sta	XX_TH						; 3

	; calc (YY-X_T)
	lda 	YY						; 3
	sec							; 2
	sbc	XX_TH						; 3

	; want (YY-(XX*T)) & (XX+(YY*T)

	and	SAVED						; 3
							;============
							;	37


	and	#$f0						; 2

	beq	white
black:
	lda	#0	; black
	.byte	$2C	; bit trick
white:
	lda	#$ff	; white

color_ready:
	sta	HGR_BITS

no_shift:

	jsr	HPLOT1		; plot at current position

	jsr	MOVE_RIGHT	; move current position right (trashes A)

	;==================================
	inx
	bne	sier_xloop

	;==================================

	jsr	MOVE_DOWN	; X/Y left alone

	inc	YY		; repeat until Y=192
	ldy	YY
	cpy	#192
	bne	sier_yloop


	; inc T
;	clc
	lda	T_L
blah_smc:
	adc	#1
	sta	T_L
	bcc	no_carry
	inc	T_H
no_carry:

	; speed up the zoom as it goes
	inc	blah_smc+1

;flip_pages:
;	TODO if frame rate ever gets fast enough

	jmp	sier_outer	; what can we branch on?




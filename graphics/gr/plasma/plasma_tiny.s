; do a (hopefully fast) plasma

; 151 -- original
; 137 -- optimize generation
; 136 -- align lookup table so we can index it easier
; 130 -- optimize indexing of lookup
; 126 -- run loops backaward
; 124 -- notice X already 0 before plot
; 131 -- use GBASCALC.  much faster, but 7 bytes larger
; 129 -- run loop backwards
; 128 -- set color ourselves
; 127 -- overlap color lookup with sine table
; 119 -- forgot to comment out unused
; 121 -- make full screen

.include "zp.inc"
.include "hardware.inc"

CTEMP	= $FC
SAVEOFF = $FD
SAVEX = $FE
SAVEY = $FF

	;================================
	; Clear screen and setup graphics
	;================================

	jsr	SETGR
	bit	FULLGR		; full screen

;	lda	#0
;	sta	DISP_PAGE
;	lda	#4
;	sta	DRAW_PAGE

;col = ( 8.0 + (sintable[xx&0xf])
;           + 8.0 + (sintable[yy&0xf])
;            ) / 2;

create_lookup:

	ldy	#15
create_yloop:
	ldx	#15
create_xloop:
	clc
	lda	#15
	adc	sinetable,X
	adc	sinetable,Y
	lsr
lookup_smc:
	sta	lookup		; always starts at $d00

	inc	lookup_smc+1

	dex
	bpl	create_xloop

	dey
	bpl	create_yloop


create_lookup_done:

forever_loop:

cycle_colors:
	; cycle colors

	; X is $FF when arrive here
	inx

;	ldx	#0
cycle_loop:
	inc	lookup,X
	inx
	bne	cycle_loop


plot_frame:

	; plot frame

	ldx	#47		; YY=0

plot_yloop:

	txa			; get (y&0xf)<<4
	asl
	asl
	asl
	asl
	sta	CTEMP

	txa
	lsr

	php
	jsr	GBASCALC	; point GBASL/H to address in A
				; after, A trashed, C is clear
	plp

	lda	#$0f		; setup mask
	bcc	plot_mask
	adc	#$e0

plot_mask:
	sta	MASK

	;==========

	ldy	#39		; XX = 39 (countdown)

plot_xloop:

	stx	SAVEX		; SAVE YY

	tya			; get x&0xf
	and	#$f
	ora 	CTEMP 		; get ((y&0xf)*16)+x

	tax

plot_lookup:

;	sta	plot_lookup_smc+1

plot_lookup_smc:
	lda	lookup,X	; load lookup, (y*16)+x
;	lda	lookup	; load lookup, (y*16)+x

	and	#$f
	lsr
	tax
	lda	colorlookup,X
	sta	COLOR

	jsr	PLOT1	; plot at GBASL,Y (x co-ord in Y)

	ldx	SAVEX		; restore YY

	dey
	bpl	plot_xloop

	dex
	bpl	plot_yloop
	bmi	forever_loop

;	iny
;	cpy	#40
;	bne	plot_xloop

;	inx
;	cpx	#40
;	bne	plot_yloop
;	beq	forever_loop


colorlookup:
bw_color_lookup:
.byte $55,$22,$66,$77,$ff,$77,$55	; ,$00 shared w sin table

sinetable:
.byte $00,$03,$05,$07,$08,$07,$05,$03
.byte $00,$FD,$FB,$F9,$F8,$F9,$FB,$FD

;colorlookup:
;.byte $00,$00,$05,$05,$07,$07,$0f,$0f
;.byte $07,$07,$06,$06,$02,$02,$05,$05
;.byte $00,$55,$77,$ff,$77,$66,$22,$55



.org	$d00
;.align	$100
lookup:

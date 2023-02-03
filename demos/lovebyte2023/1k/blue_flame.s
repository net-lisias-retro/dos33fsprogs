; Apple II graphics/music in 1k

; by deater (Vince Weaver) <vince@deater.net>

; Lovebyte 2023

;  920 bytes -- (compressed) have letters/flame/music more or less going
;  914 bytes -- fallthrough into the flames code
;  887 bytes -- BF using compact zx02 code, inlined
; 1007 bytes -- merge in sier_parallax
; 1006 bytes -- mildly optimzie hgr table gen
; 1046 bytes (+26) -- add static_column

; TODO:
;	MIRROR (140)
;	THICK_LINES (88)
;	RAINBOW SQUARES (106)
;	THICK (113) ***
;	WIRES (91)
;	STAGGERED (60)
;	STATIC_COLUMN (44) ***

.include "zp.inc"
.include "hardware.inc"


hgr_lookup_h    =       $1000
hgr_lookup_l    =       $1100
div4_lookup	=	$90


blue_flame:

	; clear both pages of graphics
	jsr	HGR
	jsr	HGR2

	; A and Y are 0 now?

	sty	FRAME			; init frame.  Maybe only H important?
	sty	FRAMEH

	;===================
        ; int tables

	; Y must be 0? actually might not matter

	;====================================
	; Make HGR row address lookup table

	ldx	#191
hgr_table_loop:
	txa
	jsr	HPOSN			; X= (y,x) Y=(a), saves incoming values

	ldx	HGR_X			; restore X

	lda	GBASL
	sta	hgr_lookup_l,X
	lda	GBASH
	and	#$1F				; 20 30    001X 40 50  010X
	sta	hgr_lookup_h,X


	dex
	cpx	#$ff			; can't bpl/bmi as start > 128
	bne	hgr_table_loop		; though if never use address 0 can we?

	; lookup table of 0..40 but divided by 4
	; in $90 to $C0 or so

	ldx	#39
div4_loop:
	txa
	asl
	asl
	sta	div4_lookup,X
	dex
	bpl	div4_loop


	;===================
	; music Player Setup

	; assume mockingboard in slot#4

	; inline mockingboard_init

	; Y must be 0

	ldy	#0

.include "mockingboard_init.s"

.include "tracker_init.s"

	cli				; enable music

	.include "sier.s"

	.include "static_column.s"

	jsr	do_letters

	; fallthrough into flames

;	jsr	flames
;
;end:
;	jmp	end


.include "flame.s"

.include "letters.s"


.include "interrupt_handler.s"
.include "mockingboard_constants.s"

; music
.include	"SmallLove2.s"


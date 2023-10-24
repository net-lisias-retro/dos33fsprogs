; Credits

; o/~ It's the credits, yeah, that's the best part
;     When the movie ends and the reading starts o/~

;
; by deater (Vince Weaver) <vince@deater.net>

.include "../zp.inc"
.include "../hardware.inc"
.include "../qload.inc"

mod7_table	= $1c00
div7_table	= $1d00
hposn_low	= $1e00
hposn_high	= $1f00

intro_start:
	;=====================
	; initializations
	;=====================

	;===================
	; Load graphics
	;===================
load_loop:

	bit	SET_GR
	bit	HIRES
	bit	FULLGR
	bit	PAGE1

	lda	#0
	jsr	hgr_page1_clearscreen

	jsr	hgr_make_tables


	; fc logo

	lda	#<fc_grey_data
	sta	zx_src_l+1
	lda	#>fc_grey_data
	sta	zx_src_h+1
	lda	#$20
	jsr	zx02_full_decomp
	jsr	wait_until_keypress

	; fc logo

	lda	#<fc_iipix_data
	sta	zx_src_l+1
	lda	#>fc_iipix_data
	sta	zx_src_h+1
	lda	#$20
	jsr	zx02_full_decomp
	jsr	wait_until_keypress


	; nuts4 logo

	lda	#<nuts4_data
	sta	zx_src_l+1
	lda	#>nuts4_data
	sta	zx_src_h+1
	lda	#$20
	jsr	zx02_full_decomp
	jsr	wait_until_keypress

	; nuts4 logo

	lda	#<nuts_pg_data
	sta	zx_src_l+1
	lda	#>nuts_pg_data
	sta	zx_src_h+1
	lda	#$20
	jsr	zx02_full_decomp
	jsr	wait_until_keypress

	; nuts4 logo

	lda	#<nuts_blue_data
	sta	zx_src_l+1
	lda	#>nuts_blue_data
	sta	zx_src_h+1
	lda	#$20
	jsr	zx02_full_decomp
	jsr	wait_until_keypress


	; sample logo

	lda	#<sample_data
	sta	zx_src_l+1

	lda	#>sample_data
	sta	zx_src_h+1

	lda	#$20

	jsr	zx02_full_decomp

	jsr	wait_until_keypress




	jsr	wait_until_keypress

	ldx	#0
	stx	FRAME

do_scroll:

	lda	FRAME
	and	#$7
	bne	no_update_message

	; clear lines
	ldx	#200
cl_outer_loop:
	lda	hposn_low,X
	sta	OUTL
	lda	hposn_high,X
	sta	OUTH
	ldy	#39
	lda	#0
cl_inner_loop:
	sta	(OUTL),Y
	dey
	bpl	cl_inner_loop
	dex
	cpx	#191
	bne	cl_outer_loop


	; print message

        lda     #12
        sta     CH
        lda     #192
        sta     CV

        lda     #<apple_message
        ldy     #>apple_message

	jsr	DrawCondensedString

no_update_message:

	inc	FRAME

	jsr	hgr_vertical_scroll





	jmp	do_scroll

.align $100
	.include	"../wait_keypress.s"
	.include	"../zx02_optim.s"
	.include	"../hgr_table.s"
	.include	"../hgr_clear_screen.s"
	.include	"vertical_scroll.s"
	.include	"font_console_1x8.s"

	.include	"../part00_boot/fonts/a2_cga_thin.inc"

fc_grey_data:
	.incbin "graphics/fc_grey.hgr.zx02"
fc_iipix_data:
	.incbin "graphics/fc_iipix.hgr.zx02"

nuts4_data:
	.incbin "graphics/nuts4.hgr.zx02"
nuts_pg_data:
	.incbin "graphics/nuts_pg.hgr.zx02"
nuts_blue_data:
	.incbin "graphics/nuts_blue.hgr.zx02"

sample_data:
	.incbin "graphics/credits_2.hgr.zx02"

apple_message:
	.byte "Apple ][ Forever"

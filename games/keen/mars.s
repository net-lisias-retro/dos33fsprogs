; Keen MARS main map
;
; by deater (Vince Weaver) <vince@deater.net>

; Zero Page
	.include "zp.inc"
	.include "hardware.inc"
	.include "common_defines.inc"


; or are there?
NUM_ENEMIES = 0
TILE_COLS = 20		; define this elsewhere?

mars_start:
	;===================
	; init screen
;	jsr	TEXT
;	jsr	HOME
	bit	KEYRESET

	bit	SET_GR
	bit	PAGE1
	bit	LORES
	bit	FULLGR

	lda	#0
	sta	clear_all_color+1
	jsr	clear_all	; avoid grey stripes at load

	lda	KEENS
	bpl	plenty_of_keens

	jmp	return_to_title

plenty_of_keens:

	;=====================
	; init vars
	;=====================

	lda	#0
	sta	ANIMATE_FRAME
	sta	FRAMEL
	sta	FRAMEH

	lda	#4
	sta	DRAW_PAGE

	; see if returning and if game over

	lda	LEVEL_OVER
	cmp	#GAME_OVER

	bne	not_game_over
	jmp	return_to_title

not_game_over:

	; TODO: set this in title, don't over-write

	lda	#1
	sta	MARS_TILEX
	lda	#6
	sta	MARS_TILEY

	lda	#0
	sta	MARS_X
	sta	MARS_Y

	;====================================
	; load mars tilemap
	;====================================

	lda	#<mars_data_zx02
	sta	ZX0_src
	lda	#>mars_data_zx02
	sta	ZX0_src+1
	lda	#$90			; load to page $9000
	jsr	full_decomp


	;====================================
	; copy in tilemap subset
	;====================================
	; FIXME: start values
	;	center around MARS_TILEX, MARS_TILEY

	lda	MARS_TILEX
	sta	TILEMAP_X
	lda	MARS_TILEY
	sta	TILEMAP_Y

	jsr	copy_tilemap_subset

	; make a copy in $c00 for fade-in purposes

	lda	DRAW_PAGE	; necssary
	pha

	lda	#8
	sta	DRAW_PAGE

	jsr	draw_tilemap

	pla
	sta	DRAW_PAGE

	lda	#1
	sta	INITIAL_SOUND

	jsr	fade_in

	lda	#0
	sta	LEVEL_OVER

	;====================================
	;====================================
	; Main loop
	;====================================
	;====================================

mars_loop:
	; draw tilemap

	jsr	draw_tilemap

	; draw keen

	jsr	draw_keen

	jsr	page_flip

	jsr	handle_keypress

;	jsr	move_keen

	;========================
	; increment frame count
	;========================

	inc	FRAMEL
	bne	no_frame_oflo
	inc	FRAMEH
no_frame_oflo:


	; rotate star colors

;	lda	FRAMEL
;	lsr
;	lsr
;	lsr
;	and	#$7
;	tay
;	lda	star_colors,Y
;	sta	$F28			; 0,28

	;===========================
	; check end of level
	;===========================

	lda	LEVEL_OVER
	bne	done_with_keen


do_mars_loop:

	;=====================
	; sound effect
	;=====================

	lda	INITIAL_SOUND
	beq	skip_initial_sound

	ldy	#SFX_KEENSLEFT
	jsr	play_sfx
	dec	INITIAL_SOUND

skip_initial_sound:

	; delay
;	lda	#200
;	jsr	WAIT

	jmp	mars_loop


done_with_keen:
	cmp	#GAME_OVER
	beq	return_to_title

	; else, start level

	bit	KEYRESET	; clear keypress

	; sound effect

	ldy	#SFX_WLDENTRSND
	jsr	play_sfx

	jsr	fade_out

        lda     #LOAD_KEEN1
        sta     WHICH_LOAD

	rts			; exit back


return_to_title:

	jsr	game_over

;	ldy	#SFX_GAMEOVERSND
;	jsr	play_sfx



	lda	#LOAD_TITLE
	sta	WHICH_LOAD

	rts





	;=========================
	; draw keen
	;=========================

draw_keen:

	sec
	lda	MARS_TILEX
	sbc	TILEMAP_X
	asl
	clc
	adc	MARS_X
	sta	XPOS

	sec
	lda	MARS_TILEY
	sbc	TILEMAP_Y
	asl
	asl
	clc
	adc	MARS_Y
	sta	YPOS

	ldx	#<keen_sprite_tiny
	lda	#>keen_sprite_tiny
	stx	INL
	sta	INH
	jsr	put_sprite_crop

	rts				; tail call



draw_keen_even:

	lda	MARS_Y
;	and	#$FE		; no need to mask, know bottom bit is 0
	tay
	lda	gr_offsets,Y
	sta	OUTL
	lda	gr_offsets+1,Y
	clc
	adc	DRAW_PAGE
	sta	OUTH
	ldy	MARS_X		; adjust with Xpos

	lda	#$3D
	sta	(OUTL),Y

	lda	MARS_Y
	clc
	adc	#2
;	and	#$FE		; no need to mask
	tay
	lda	gr_offsets,Y
	sta	OUTL
	lda	gr_offsets+1,Y
	clc
	adc	DRAW_PAGE
	sta	OUTH
	ldy	MARS_X		; adjust with Xpos

	lda	(OUTL),Y
	and	#$F0
	ora	#$02
	sta	(OUTL),Y

	rts


	;=================================
	;=================================
	; check valid feet
	;=================================
	;=================================
	; essentially if SCRN(Y,X+2)=9
check_valid_feet:
	txa
	ror
	bcc	feet_mask_odd
feet_mask_even:
	lda	#$F0
	bne	feet_mask_done		; bra
feet_mask_odd:
	lda	#$0F
feet_mask_done:
	sta	feet_mask_smc+1

	txa
	clc
	adc	#2
	and	#$FE
	tax
	lda	gr_offsets,X
	sta	OUTL
	lda	gr_offsets+1,X
	clc
	adc	#$8		; into $C00 page (bg lives here)
	sta	OUTH

	lda	(OUTL),Y
	eor	#$99
feet_mask_smc:
	and	#$F0
	beq	feet_valid
	bne	feet_invalid

feet_valid:
	sec
	rts
feet_invalid:
;	clc
	sec
	rts





	;====================================
	;====================================
	; show parts screen
	;====================================
	;====================================
	; TODO: color in if found
do_parts:
	lda	#<parts_zx02
	sta	ZX0_src
	lda	#>parts_zx02
	sta	ZX0_src+1

	lda	#$c    ; load to page $c00

	jsr	full_decomp

	jsr	gr_copy_to_current

	jsr	page_flip

	bit	TEXTGR

	bit	KEYRESET
parts_loop:
	lda	KEYPRESS
	bpl	parts_loop

done_parts:
	bit	KEYRESET

	bit	FULLGR

;	lda	#<mars_zx02
;	sta	ZX0_src
;	lda	#>mars_zx02
;	sta	ZX0_src+1

;	lda	#$c    ; load to page $c00

;	jsr	full_decomp	; tail call

	rts

	;====================================
	;====================================
	; Mars action (enter pressed on map)
	;====================================
	;====================================
	; if enter pressed on map

	; off by one so the levels can fit in a two byte bitmap
	;
	; 	location		tilex,tiley	size
	; 0	level1 (Border Town)		19,37	2
	; 1	level2 (First Shrine)		22,28	1
	; 2	level3 (Treasury)		 9,21	2
	; 3	level4 (Capital City)		22,23	2
	; 4	level5 (Pogo Shrine)		13,16	1
	; 5 	level6 (Second Shrine)		16,11	1
	; 6	level7 (Emerald City)		25,8	2
	; 7	level8 (Ice City)		38,3	2
	; 8	level9 (Third Shrine)		36,13	1
	; 9	level10 (Ice Shrine 1)		43,5	1
	; 10	level11 (Fourth Shrine)		52,16	1
	; 11	level12 (Fifth Shrine)		36,21	1
	; 12	level13 (Red Maze City)		44,24	2
	; 13	level14 (Secret City)		60,28	2
	; 14	level15 (Ice Shrine 2)		38,60	1
	; 15	level16 (Vorticon Castle)	29,59	2
	; 16	spaceship			10,37	1
	; 17	left transporter		26,4	1
	; 18	right transporter		34,3	1
	; 19	secret transporter		60,35	1

NUM_LOCATIONS = 20

do_action:

	ldx	#NUM_LOCATIONS

do_action_loop:

	;  mtx-ltx
	;   -1   0    1    2
	;  1234 1234 1234 1234
	;  XYY   XY   YX   YYX
	;   YY   YY   YY   YY

check_location_x:
	sec
	lda	MARS_TILEX
	sbc	location_x,X
	bmi	check_location_nomatch

	cmp	location_size,X
	bcs	check_location_nomatch

check_location_y:

	;  mty-lty
	;      -2  -1    0    1    2

	; 0    X
	; 1    X    X
	; 2   YY   YX   YX   YY   YY
	; 3   YY   YY   YX   YX   YY
	; 4                   X    X
	; 5                        X

	clc
	lda	MARS_TILEY
	adc	#1
	sec
	sbc	location_y,X
	bmi	check_location_nomatch

	cmp	location_size,X

	bcc	check_location_match

;	bcs	check_location_nomatch



check_location_nomatch:
	dex
	bpl	do_action_loop

	rts

check_location_match:

	; jump table

	lda	location_actions_high,X
	pha
	lda	location_actions_low,X
	pha

	rts	; jump


;	lda	MARS_X
;	cmp	#15
;	bcc	do_nothing	; blt
;	cmp	#20
;	bcc	maybe_ship
;	cmp	#35
;	bcs	maybe_exit
;do_nothing:
;	; TODO: make sound?
;	rts
;maybe_ship:
;	lda	MARS_Y
;	cmp	#16
;	bcc	do_nothing
;	cmp	#24
;	bcs	do_nothing
;	jmp	do_parts	; tail call
;maybe_exit:
;	inc	LEVEL_OVER
;	rts






dummy_action:
	rts


location_x:
	.byte 19,22, 9,22,13,16,25,38
	.byte 36,43,52,36,44,60,38,29
	.byte 10,26,34,60

location_y:
	.byte 37,28,21,23,16,11, 8, 3
	.byte 13, 5,16,21,24,28,60,59
	.byte 37, 4, 3,35

location_size:
	.byte 2,1,2,2,1,1,2,2
	.byte 1,1,1,1,2,2,1,2
	.byte 1,1,1,1

location_actions_low:
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(dummy_action-1),<(dummy_action-1)
	.byte <(do_parts-1),<(dummy_action-1)		; ship, l transport
	.byte <(dummy_action-1),<(dummy_action-1)	; r trans, secret

location_actions_high:
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(dummy_action-1),>(dummy_action-1)
	.byte >(do_parts-1),>(dummy_action-1)		; ship, l transport
	.byte >(dummy_action-1),>(dummy_action-1)	; r trans, secret



;star_colors:
;	.byte $05,$07,$07,$0f
;	.byte $0f,$07,$05,$0a




	;==========================
	; includes
	;==========================

	; level graphics

mars_zx02:
	.incbin	"maps/mars_map.gr.zx02"
parts_zx02:
	.incbin	"graphics/parts.gr.zx02"

	.include	"text_print.s"
	.include	"gr_offsets.s"
	.include	"gr_fast_clear.s"
	.include	"gr_copy.s"
	.include	"gr_pageflip.s"
;	.include	"gr_putsprite_crop.s"
	.include	"zx02_optim.s"
	.include	"gr_fade.s"

	.include	"joystick.s"

	.include	"text_drawbox.s"
	.include	"text_help.s"
	.include	"text_quit_yn.s"
	.include	"game_over.s"
	.include	"mars_keyboard.s"
	.include	"draw_tilemap.s"

	.include	"mars_sfx.s"
	.include	"longer_sound.s"
	.include	"gr_putsprite_crop.s"

mars_data_zx02:
	.incbin	"maps/mars_new.zx02"

	; dummy
enemy_data_out:
enemy_data_tilex:


keen_sprite_tiny:
	.byte	1,2
	.byte	$DA
	.byte	$23

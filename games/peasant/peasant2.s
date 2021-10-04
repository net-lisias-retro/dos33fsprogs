; Peasant's Quest

; Peasantry Part 2 (second line of map)

;	haystack, puddle, archery, river, knight (pass)


WHICH_PEASANTRY=1

; by Vince `deater` Weaver	vince@deater.net

; with apologies to everyone

.include "hardware.inc"
.include "zp.inc"

.include "qload.inc"


peasant_quest:
	lda	#0
	sta	GAME_OVER
	sta	FRAME

	jsr	hgr_make_tables		; necessary?
	jsr	hgr2			; necessary?

	; update map location

	jsr	update_map_location

	; update score

	jsr	update_score

	;=============================
	;=============================
	; new screen location
	;=============================
	;=============================

new_location:
	lda	#0
	sta	GAME_OVER

	;=====================
	; load bg

	; we are PEASANT2 so locations 5...9 map to 0...4

	lda	MAP_LOCATION
	sec
	sbc	#5
	tax

	lda	map_backgrounds_low,X
	sta	getsrc_smc+1
	lda	map_backgrounds_hi,X
	sta	getsrc_smc+2

	lda	#$40

	jsr	decompress_lzsa2_fast


	; we are PEASANT2 so locations 5...9 map to 0...4

	lda	MAP_LOCATION
	sec
	sbc	#5
	tax

	lda	map_priority_low,X
	sta	getsrc_smc+1
	lda	map_priority_hi,X
	sta	getsrc_smc+2

	lda	#$20

	jsr	decompress_lzsa2_fast

	jsr	gr_copy_to_page1

	; put peasant text

	lda	#<peasant_text
	sta	OUTL
	lda	#>peasant_text
	sta	OUTH

	jsr	hgr_put_string

	; put score

	jsr	print_score

	;====================
	; save background

	lda	PEASANT_X
	sta	CURSOR_X
	lda	PEASANT_Y
	sta	CURSOR_Y

	;=======================
	; draw initial peasant

	jsr	save_bg_7x28

	jsr	draw_peasant

game_loop:

	jsr	move_peasant

	inc	FRAME

	jsr	check_keyboard

	lda	GAME_OVER
	bmi	oops_new_location
	bne	game_over


	; delay

	lda	#200
	jsr	wait


	jmp	game_loop

oops_new_location:
	jmp	new_location


	;************************
	; exit level
	;************************
game_over:

	rts



.include "wait_keypress.s"

.include "draw_peasant.s"

.include "gr_copy.s"

.include "new_map_location.s"
.include "peasant_move.s"

.include "score.s"

.include "parse_input.s"

.include "keyboard.s"

.include "wait.s"
.include "wait_a_bit.s"

.include "graphics/graphics_peasant2.inc"
.include "graphics/priority_peasant2.inc"

.include "version.inc"

.include "inventory.s"

.include "loadsave_menu.s"


; moved to QLOAD

;.include "decompress_fast_v2.s"
;.include "hgr_font.s"
;.include "draw_box.s"
;.include "hgr_rectangle.s"
;.include "hgr_7x28_sprite_mask.s"
;.include "hgr_1x5_sprite.s"
;.include "hgr_partial_save.s"
;.include "hgr_input.s"
;.include "hgr_tables.s"
;.include "hgr_text_box.s"
;.include "clear_bottom.s"
;.include "hgr_hgr2.s"

;.include "text/common.inc"





;help_message:
;.byte   0,43,24, 0,253,82
;.byte   8,41,"I don't understand. Type",13
;.byte	     "HELP for assistances.",0

;fake_error1:
;.byte   0,43,24, 0,253,82
;.byte   8,41,"?SYNTAX ERROR IN 1020",13
;.byte	     "]",127,0

;fake_error2:
;.byte   0,43,24, 0,253,82
;.byte   8,41,"?UNDEF'D STATEMENT ERROR",13
;.byte	     "]",127,0



map_backgrounds_low:
	.byte	<haystack_lzsa		; 5	-- haystack
	.byte	<puddle_lzsa		; 6	-- puddle
	.byte	<archery_lzsa		; 7	-- archery
	.byte	<river_lzsa		; 8	-- river
	.byte	<knight_lzsa		; 9	-- knight

map_backgrounds_hi:
	.byte	>haystack_lzsa		; 5	-- haystack
	.byte	>puddle_lzsa		; 6	-- puddle
	.byte	>archery_lzsa		; 7	-- archery
	.byte	>river_lzsa		; 8	-- river
	.byte	>knight_lzsa		; 9	-- knight

map_priority_low:
	.byte	<haystack_priority_lzsa		; 5	-- haystack
	.byte	<puddle_priority_lzsa		; 6	-- puddle
	.byte	<archery_priority_lzsa		; 7	-- archery
	.byte	<river_priority_lzsa		; 8	-- river
	.byte	<knight_priority_lzsa		; 9	-- knight

map_priority_hi:
	.byte	>haystack_priority_lzsa		; 5	-- haystack
	.byte	>puddle_priority_lzsa		; 6	-- puddle
	.byte	>archery_priority_lzsa		; 7	-- archery
	.byte	>river_priority_lzsa		; 8	-- river
	.byte	>knight_priority_lzsa		; 9	-- knight
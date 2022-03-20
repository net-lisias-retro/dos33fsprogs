.include "zp.inc"
.include "hardware.inc"
.include "qload.inc"
.include "lemm.inc"
.include "lemming_status.inc"

.byte 3		; level 3

do_level3:

	;======================
	; set up initial stuff
	;======================

	lda	#15
	sta	DOOR_X
	lda	#0
	sta	DOOR_Y

	lda	#18
	sta	INIT_X
	lda	#11
	sta	INIT_Y

	; flame location

	lda	#15			;
	sta	l_flame_x_smc+1
	lda	#122
	sta	l_flame_y_smc+1
        sta	r_flame_y_smc+1

	lda	#19			;
	sta	r_flame_x_smc+1

	; door exit location

	lda	#15			;
	sta	exit_x1_smc+1
	lda	#19
	sta	exit_x2_smc+1

	lda	#122
	sta	exit_y1_smc+1
	lda	#144
	sta	exit_y2_smc+1


	;==============
	; set up intro
	;==============

	lda	#<level3_preview_lzsa
	sta	level_preview_l_smc+1
	lda	#>level3_preview_lzsa
	sta	level_preview_h_smc+1

	;==============
	; set up music
	;==============

	lda	#0
	sta	CURRENT_CHUNK
	sta	DONE_PLAYING
	sta	BASE_FRAME_L
	sta	BUTTON_LOCATION

	; set up first song

	lda	#<music11_parts_l
	sta	chunk_l_smc+1
	lda	#>music11_parts_l
	sta	chunk_l_smc+2

	lda	#<music11_parts_h
	sta	chunk_h_smc+1
	lda	#>music11_parts_h
	sta	chunk_h_smc+2


	lda	#$D0
	sta	CHUNK_NEXT_LOAD		; Load at $D0
	jsr	load_song_chunk

	lda	#$D0			; music starts at $d000
	sta	CHUNK_NEXT_PLAY
	sta	BASE_FRAME_H

	lda	#1
	sta	LOOP
	sta	CURRENT_CHUNK



        ;=======================
        ; show title screen
        ;=======================

	jsr	intro_level

        ;=======================
        ; Load Graphics
        ;=======================

	lda	#$20
	sta	HGR_PAGE
	jsr	hgr_make_tables

	bit	SET_GR
	bit	PAGE0
	bit	HIRES
	bit	FULLGR

	lda     #<level3_lzsa
	sta     getsrc_smc+1	; LZSA_SRC_LO
	lda     #>level3_lzsa
	sta     getsrc_smc+2	; LZSA_SRC_HI

	lda	#$20

	jsr	decompress_lzsa2_fast

	lda     #<level3_lzsa
	sta     getsrc_smc+1	; LZSA_SRC_LO
	lda     #>level3_lzsa
	sta     getsrc_smc+2	; LZSA_SRC_HI

	lda	#$40

	jsr	decompress_lzsa2_fast


        ;=======================
        ; Setup cursor
        ;=======================

	lda	#0
	sta	OVER_LEMMING
	lda	#10
	sta	CURSOR_X
	lda	#100
	sta	CURSOR_Y

	;=======================
	; init vars
	;=======================

	lda	#0
	sta	LEVEL_OVER
	sta	DOOR_OPEN
	sta	FRAMEL
	sta	LOAD_NEXT_CHUNK
	sta	LEMMINGS_OUT

	jsr	update_lemmings_out	; update display

	lda	#1
	sta	LEMMINGS_TO_RELEASE
	jsr	clear_lemmings_out

	; set up time

	lda	#$5
	sta	TIME_MINUTES
	lda	#$00
	sta	TIME_SECONDS

	sta	TIMER_COUNT

	;=======================
	; Play "Let's Go"
	;=======================

	jsr	play_letsgo


	;===================
	;===================
	; Main Loop
	;===================
	;===================
l4_main_loop:

	;=========================
	; load next chunk of music
	; if necessary
	;=========================

	jsr	load_music


	;=========================
	; open door
	;=========================

	lda	DOOR_OPEN
	bne	l4_door_is_open

	jsr	draw_door

l4_door_is_open:

	;======================
	; release lemmings
	;======================

	lda	LEMMINGS_TO_RELEASE
	beq	l4_done_release_lemmings

	lda	DOOR_OPEN
	beq	l4_done_release_lemmings

	lda	FRAMEL
	and	#$f
	bne	l4_done_release_lemmings

	jsr	release_lemming

l4_done_release_lemmings:

	;======================
	; animate flames
	;======================

	jsr	draw_flames

	lda	TIMER_COUNT
	cmp	#$50
	bcc	l4_timer_not_yet

	jsr	update_time

	lda	#$0
	sta	TIMER_COUNT
l4_timer_not_yet:


	; main drawing loop

	jsr	erase_lemming

	jsr	erase_pointer

	jsr	move_lemmings

	jsr	draw_lemming

	jsr	handle_keypress

	jsr	draw_pointer

	lda	#$ff
	jsr	wait

	inc	FRAMEL

	lda	LEVEL_OVER
	bne	l4_level_over

	jmp	l4_main_loop


l4_level_over:

	jsr	disable_music

	jsr	outro_level1

	rts


	.include	"release_lemming.s"


.include "graphics/graphics_level3.inc"


music11_parts_h:
	.byte >lemm11_part1_lzsa,>lemm11_part2_lzsa,>lemm11_part3_lzsa
	.byte >lemm11_part4_lzsa,>lemm11_part5_lzsa,>lemm11_part6_lzsa
	.byte >lemm11_part7_lzsa
	.byte $00

music11_parts_l:
	.byte <lemm11_part1_lzsa,<lemm11_part2_lzsa,<lemm11_part3_lzsa
	.byte <lemm11_part4_lzsa,<lemm11_part5_lzsa,<lemm11_part6_lzsa
	.byte <lemm11_part7_lzsa



lemm11_part1_lzsa:
.incbin "music/lemm11.part1.lzsa"
lemm11_part2_lzsa:
.incbin "music/lemm11.part2.lzsa"
lemm11_part3_lzsa:
.incbin "music/lemm11.part3.lzsa"
lemm11_part4_lzsa:
.incbin "music/lemm11.part4.lzsa"
lemm11_part5_lzsa:
.incbin "music/lemm11.part5.lzsa"
lemm11_part6_lzsa:
.incbin "music/lemm11.part6.lzsa"
lemm11_part7_lzsa:
.incbin "music/lemm11.part7.lzsa"



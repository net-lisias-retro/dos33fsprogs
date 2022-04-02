
	;==============================
	; Handle Keypress
	;==============================
handle_keypress:

	; first handle joystick
	lda	JOYSTICK_ENABLED
	beq	actually_handle_keypress

	; only check joystick every-other frame
	lda	FRAMEL
	and	#$1
	beq	actually_handle_keypress

check_button:
        lda     PADDLE_BUTTON0
        bpl     button_clear

        lda     JS_BUTTON_STATE
        bne     js_check

        lda     #1
        sta     JS_BUTTON_STATE
        lda     #' '
        jmp     handle_input

button_clear:
        lda     #0
        sta     JS_BUTTON_STATE

js_check:
        jsr     handle_joystick

js_check_left:
        lda     value0
        cmp     #$20
        bcs     js_check_right  ; if less than 32, left
        lda     #'A'
        bne     handle_input

js_check_right:
        cmp     #$40
        bcc     js_check_up
        lda     #'D'
        bne     handle_input

js_check_up:
        lda     value1
        cmp     #$20
        bcs     js_check_down
        lda     #'W'

        bne     handle_input

js_check_down:
        cmp     #$40
        bcc     done_joystick
        lda     #'S'
        bne     handle_input


done_joystick:



actually_handle_keypress:
	lda	KEYPRESS
	bmi	keypress

	jmp	no_keypress

keypress:
	and	#$7f			; clear high bit
	cmp	#$40
	bcc	handle_input		; make sure not to lose space
					; and numbers

	and	#$df			; convert uppercase to lower case


handle_input:


	; first check if 1...8 pressed
	cmp	#'1'
	bcc	check_sound
	cmp	#'9'
	bcs	check_sound

	sec				; map 1->3, 2->4, 4->5, etc
	sbc	#'1'
	clc
	adc	#3
	jsr	handle_menu_which_in_a
	jmp	done_keypress

check_sound:
	cmp	#$14			; control-T
	bne	check_joystick

	lda	SOUND_STATUS
	eor	#SOUND_DISABLED
	sta	SOUND_STATUS
	jmp	done_keypress

	; can't be ^J as that's the same as down
check_joystick:
	cmp	#'J'
	bne	check_left

	lda	JOYSTICK_ENABLED
	eor	#1
	sta	JOYSTICK_ENABLED
	jmp	done_keypress

check_left:
	cmp	#'A'
	beq	left_pressed
	cmp	#8			; left key
	bne	check_right
left_pressed:
	lda	CURSOR_X		; if 41<x<$FE don't decrement
	cmp	#41
	bcc	do_dec_cursor_x
	cmp	#$FE
	bcc	done_left_pressed
do_dec_cursor_x:
	dec	CURSOR_X
done_left_pressed:
	jmp	done_keypress

check_right:
	cmp	#'D'
	beq	right_pressed
	cmp	#$15			; right key
	bne	check_up
right_pressed:
	lda	CURSOR_X		; if 40<x<$FE don't increment
	cmp	#40
	bcc	do_inc_cursor_x
	cmp	#$FE
	bcc	done_right_pressed
do_inc_cursor_x:
	inc	CURSOR_X
done_right_pressed:
	jmp	done_keypress

check_up:
	cmp	#'W'
	beq	up_pressed
	cmp	#$0B			; up key
	bne	check_down
up_pressed:
	lda	CURSOR_Y		; if 191<y<$F0 don't decrement
	cmp	#191
	bcc	do_dec_cursor_y
	cmp	#$F0
	bcc	done_up_pressed
do_dec_cursor_y:
	dec	CURSOR_Y
	dec	CURSOR_Y
	dec	CURSOR_Y
	dec	CURSOR_Y

done_up_pressed:
	jmp	done_keypress

check_down:
	cmp	#'S'
	beq	down_pressed
	cmp	#$0A
	bne	check_escape
down_pressed:
	lda	CURSOR_Y		; if 191<y<$EE don't decrement
	cmp	#191
	bcc	do_inc_cursor_y
	cmp	#$EE
	bcc	done_down_pressed
do_inc_cursor_y:
	inc	CURSOR_Y
	inc	CURSOR_Y
	inc	CURSOR_Y
	inc	CURSOR_Y
done_down_pressed:
	jmp	done_keypress

check_escape:
	cmp	#27
	bne	check_return
escape_pressed:
	lda	#LEVEL_FAIL
	sta	LEVEL_OVER

	jmp	done_keypress

check_return:
	cmp	#' '
	beq	return_pressed
	cmp	#13
	bne	done_keypress

return_pressed:

	; first check if off bottom of screen

	lda	CURSOR_Y
	cmp	#168-8			; center of cursor
	bcc	return_check_lemming

	jsr	handle_menu

	jmp	done_keypress

	; next check if over lemming
return_check_lemming:
	lda	OVER_LEMMING
	bmi	not_over_lemming

	tay

	; check if digging selected

	jsr	click_speaker

	lda	BUTTON_LOCATION
	tax

	lda	button_jump_h,X
	pha
	lda	button_jump_l,X
	pha
	rts					; jump to it


not_over_lemming:


done_keypress:


no_keypress:
	bit	KEYRESET
	rts



button_jump_l:
	.byte	<(make_nop-1)
	.byte	<(make_climber-1)
	.byte	<(make_floater-1)
	.byte	<(make_exploding-1)
	.byte	<(make_stopper-1)
	.byte	<(make_builder-1)
	.byte	<(make_basher-1)
	.byte	<(make_miner-1)
	.byte	<(make_digger-1)

button_jump_h:
	.byte	>(make_nop-1)
	.byte	>(make_climber-1)
	.byte	>(make_floater-1)
	.byte	>(make_exploding-1)
	.byte	>(make_stopper-1)
	.byte	>(make_builder-1)
	.byte	>(make_basher-1)
	.byte	>(make_miner-1)
	.byte	>(make_digger-1)


make_nop:
	jmp	done_keypress


	;========================
	; make climber
	;========================
make_climber:
	lda	#LEMMING_CLIMBER
	ora	lemming_attribute,Y
	sta	lemming_attribute,Y
	jmp	done_keypress

	;========================
	; make floater
	;========================
make_floater:
	lda	#LEMMING_FLOATER
	ora	lemming_attribute,Y
	sta	lemming_attribute,Y
	jmp	done_keypress


	;========================
	; make exploding
	;========================
make_exploding:
	jsr	explode_lemming
	jmp	done_keypress


	;========================
	; make stopper
	;========================
make_stopper:
	lda	lemming_status,Y
	cmp	#LEMMING_FLOATER		; can't stop if floating
	beq	cant_stop
	cmp	#LEMMING_FALLING		; can't stop if falling
	beq	cant_stop
	cmp	#LEMMING_STOPPING		; an unmoving object can't be
	beq	cant_stop			; stopped!

	lda	#LEMMING_STOPPING
	sta	lemming_status,Y

	; put line on page2 to make lemmings reverse

	; make it a specific pattern so climbers won't climb over

	lda	lemming_x,Y
	sta	dbl_smc2+1

	lda	lemming_y,Y
	tax
	inx
	clc
	adc	#8
	sta	dbl_smc+1

draw_blocker_loop:

	lda	hposn_high,X
	clc
	adc	#$20
	sta	GBASH
	lda	hposn_low,X
	sta	GBASL

dbl_smc2:
	ldy	#30

	lda	#$10
	sta	(GBASL),Y

	inx
dbl_smc:
	cpx	#8
	bne	draw_blocker_loop


.if 0
	; line from (x,a) to (x,a+y)
	lda	#$7
	sta	HGR_COLOR

	jsr	hgr_vlin_page_toggle

	clc
	lda	lemming_x,Y		; multiply x by 7
	asl
	adc	lemming_x,Y
	asl
	adc	lemming_x,Y
	adc	#2			; center a bit

	tax
	lda	lemming_y,Y
	clc
	adc	#1

	ldy	#8

	jsr	hgr_vlin

	jsr	hgr_vlin_page_toggle
.endif

cant_stop:
	jmp	done_keypress


	;========================
	; make builder
	;========================
make_builder:

	; if walking, shrugging, bashing

	lda	lemming_status,Y
	cmp	#LEMMING_WALKING
	beq	really_make_builder
	cmp	#LEMMING_SHRUGGING
	beq	really_make_builder
	cmp	#LEMMING_BASHING
	beq	really_make_builder


	jmp	done_make_builder

really_make_builder:
	lda	#LEMMING_BUILDING
	sta	lemming_status,Y

	; build count=0
	lda	lemming_attribute,Y
	and	#$f0
	sta	lemming_attribute,Y


	; FIXME: decrement count
done_make_builder:
	jmp	done_keypress


	;========================
	; make basher
	;========================
make_basher:
	; only do it if walking
	lda	lemming_status,Y
	cmp	#LEMMING_WALKING
	bne	done_make_basher

	lda	#LEMMING_BASHING
	sta	lemming_status,Y

	; FIXME: decrement count
done_make_basher:
	jmp	done_keypress


	;========================
	; make miner
	;========================
make_miner:
	; only do it if walking
	lda	lemming_status,Y
	cmp	#LEMMING_WALKING
	bne	done_make_miner

	lda	#LEMMING_MINING
	sta	lemming_status,Y

	; FIXME: decrement count
done_make_miner:
	jmp	done_keypress


	;========================
	; make digger
	;========================
make_digger:
	; only do it if walking
	lda	lemming_status,Y
	cmp	#LEMMING_WALKING
	bne	done_make_digger

	lda	#LEMMING_DIGGING
	sta	lemming_status,Y

	; FIXME: decrement digger_count
done_make_digger:
	jmp	done_keypress












	;=============================
	;=============================
	; handle menu
	;=============================
	;=============================

handle_menu:
	; see where we clicked
	lda	CURSOR_X
	; urgh need to multiply by 7
	clc
	asl
	adc	CURSOR_X
	asl
	adc	CURSOR_X
	clc
	adc	#24			; adjust to center

	lsr				; /16 for on-screen co-ords
	lsr
	lsr
	lsr				; each box is 16 wide

handle_menu_which_in_a:

	cmp	#3
	bcc	plus_minus_buttons
	cmp	#11
	beq	pause_button
	cmp	#12
	beq	nuke_button
	bcs	map_grid_button

	;==========================
	; otherwise was job button
job_button:

	pha

	jsr	click_speaker

	pla
	pha

	; erase old

	jsr	erase_menu

	; update value
	pla
	sec
	sbc	#2
	sta	BUTTON_LOCATION

	; draw new

	jsr	update_menu
	jmp	done_menu


	;============================
	;============================
	; plus/minus button
	;============================
	;============================
plus_minus_buttons:

	lda	release_lemming_speed+1
	cmp	#1
	beq	done_plus_adjust

	lsr	release_lemming_speed+1	; make release faster

done_plus_adjust:
	jmp	done_menu

	;============================
	;============================
	; nuke
	;============================
	;============================
	; TODO: offset them a bit so it's not simultaneous

nuke_button:
	; stop lemmings from exiting
	lda	#0
	sta	LEMMINGS_TO_RELEASE

	ldy	#0
nuke_loop:
	jsr	explode_lemming
	iny
	cpy	#MAX_LEMMINGS
	bne	nuke_loop

	jmp	done_menu

	;============================
	;============================
	; map grid
	;============================
	;============================

map_grid_button:
	; TODO
	jmp	done_menu

	;============================
	;============================
	; pause
	;============================
	;============================
	; FIXME: should stop clock too
pause_button:

	bit	KEYRESET
	jsr	wait_until_keypress

done_menu:

	rts


	;=====================
	;=====================
	; explode lemming
	;=====================
	;=====================
	; which is in  Y
explode_lemming:
	; only explode if not already exploding

	lda	lemming_exploding,Y
	bne	skip_explode

	lda	#1
	sta	lemming_exploding,Y

skip_explode:
	rts

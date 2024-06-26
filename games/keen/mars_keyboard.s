MARS_MAX_TILE_Y = 57		; 69-12

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
        jmp     check_sound

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
        bne     check_sound

js_check_right:
        cmp     #$40
        bcc     js_check_up
        lda     #'D'
        bne     check_sound

js_check_up:
        lda     value1
        cmp     #$20
        bcs     js_check_down
        lda     #'W'

        bne     check_sound

js_check_down:
        cmp     #$40
        bcc     done_joystick
        lda     #'S'
        bne     check_sound


done_joystick:



actually_handle_keypress:
	lda	KEYPRESS
	bmi	keypress

	jmp	no_keypress

keypress:
	and	#$7f			; clear high bit
	cmp	#' '
	beq	check_sound		; make sure not to lose space
	and	#$df			; convert uppercase to lower case

check_sound:
	cmp	#$14			; control-T
	bne	check_help

	lda	SOUND_STATUS
	eor	#SOUND_DISABLED
	sta	SOUND_STATUS
	jmp	done_keypress

check_help:
	cmp	#'H'			; H (^H is same as left)
	bne	check_joystick

	jsr	print_help
	jmp	done_keypress

	; can't be ^J as that's the same as down
check_joystick:
	cmp	#'J'			; J
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

	; check if allowed to move left

	ldx	MARS_TILEY
	;dex				; look one up

	lda	tilemap_lookup_high,X
	sta	INH
	lda	tilemap_lookup_low,X
	sta	INL

	ldy	MARS_TILEX
	dey

	lda	(INL),Y

	cmp	#32
	bcs	done_left_pressed



	lda	TILEMAP_X
	beq	keen_walk_left

	sec
	lda	MARS_TILEX
	sbc	TILEMAP_X
	cmp	#7
	bcs	keen_walk_left

keen_scroll_left:
	dec	TILEMAP_X
	dec	MARS_TILEX

	jsr	copy_tilemap_subset
	jmp	done_move_keen

keen_walk_left:
	dec	MARS_X
	bpl	dwl_noflo
	lda	#1
	sta	MARS_X
	dec	MARS_TILEX
dwl_noflo:

;	ldy	MARS_X
;	dey
;	ldx	MARS_Y
;	jsr	check_valid_feet
;	bcc	done_left_pressed
;	dec	MARS_X
done_left_pressed:
	jmp	done_keypress

check_right:
	cmp	#'D'
	beq	right_pressed
	cmp	#$15			; right key
	bne	check_up

right_pressed:

	; check if allowed to move right

	ldx	MARS_TILEY
;	dex				; look one up

	lda	tilemap_lookup_high,X
	sta	INH
	lda	tilemap_lookup_low,X
	sta	INL

	ldy	MARS_TILEX
	iny

	lda	(INL),Y

	cmp	#32
	bcs	done_right_pressed


	lda	MARS_TILEY
	sta	INH
	lda	#$0
	lsr	INH
	ror
	sta	INL

	lda	INH
	clc
	adc	#>big_tilemap
	sta	INH
	ldy	MARS_TILEX
	iny

	lda	(INL),Y

	cmp	#32
	bcs	done_right_pressed



move_right:
	lda	TILEMAP_X
	cmp	#50			; 70-20
	bcs	keen_walk_right

	sec
	lda	MARS_TILEX
	sbc	TILEMAP_X
	cmp	#11
	bcc	keen_walk_right

keen_scroll_right:

	inc	TILEMAP_X
	inc	MARS_TILEX

	jsr	copy_tilemap_subset

	jmp	done_move_keen

keen_walk_right:
	inc	MARS_X
	lda	MARS_X
	cmp	#2
	bne	dwr_noflo

	lda	#0
	sta	MARS_X

	inc	MARS_TILEX

dwr_noflo:

;	ldy	MARS_X
;	iny
;	ldx	MARS_Y
;	jsr	check_valid_feet
;	bcc	done_right_pressed
;	inc	MARS_X
done_right_pressed:
	jmp	done_keypress

check_up:
	cmp	#'W'
	beq	up_pressed
	cmp	#$0B			; up key
	bne	check_down

up_pressed:

	; check if allowed to move up

	ldx	MARS_TILEY
;	dex				; look one up

	lda	tilemap_lookup_high,X
	sta	INH
	lda	tilemap_lookup_low,X
	sta	INL

	ldy	MARS_TILEX

	lda	(INL),Y

	cmp	#32
	bcs	done_up_pressed



	lda	MARS_TILEY
	cmp	#0		; not needed
	beq	move_keen_up

	sec
	lda	MARS_TILEY
	sbc	TILEMAP_Y
	cmp	#4
	bcc	scroll_keen_up

move_keen_up:

	lda	MARS_Y
	beq	keen_up_not2
move_keen_up2:
	lda	#0
	sta	MARS_Y
	jmp	done_check_up

keen_up_not2:
	dec	MARS_TILEY
	lda	#2
	sta	MARS_Y
	jmp	done_check_up

scroll_keen_up:
	dec	TILEMAP_Y
	dec	MARS_TILEY
	jsr	copy_tilemap_subset


;	ldy	MARS_X
;	ldx	MARS_Y
;	dex
;	jsr	check_valid_feet
;	bcc	done_up_pressed
;	dec	MARS_Y
done_check_up:
done_up_pressed:
	jmp	done_keypress

check_down:
	cmp	#'S'
	beq	down_pressed
	cmp	#$0A
	bne	check_space
down_pressed:

	; check if allowed to move down

	ldx	MARS_TILEY
	inx				; look one down

	lda	tilemap_lookup_high,X
	sta	INH
	lda	tilemap_lookup_low,X
	sta	INL

	ldy	MARS_TILEX

	lda	(INL),Y

	cmp	#32
	bcs	done_down_pressed


	sec
	lda	MARS_TILEY
	sbc	TILEMAP_Y
	cmp	#8
	bcc	move_keen_down

	lda	TILEMAP_Y
	cmp	#MARS_MAX_TILE_Y
	bcs	move_keen_down

	jmp	scroll_keen_down

move_keen_down:

	lda	#0
	sta	MARS_Y
	inc	MARS_TILEY
	jmp	done_check_down

scroll_keen_down:
	lda	#0
	sta	MARS_Y
	inc	TILEMAP_Y
	inc	MARS_TILEY
	jsr	copy_tilemap_subset

;	ldy	MARS_X
;	ldx	MARS_Y
;	inx
;	jsr	check_valid_feet
;	bcc	done_up_pressed
;	inc	MARS_Y
done_check_down:

done_down_pressed:
	jmp	done_keypress

check_space:
	cmp	#' '
	bne	check_return
space_pressed:

	jsr	do_action

	jmp	done_keypress

check_return:
	cmp	#13
	bne	check_escape

return_pressed:
	;inc	LEVEL_OVER

	jsr	do_action

done_return:
	jmp	no_keypress

check_escape:
	cmp	#27
	bne	done_keypress

	jsr	print_quit

	jmp	done_keypress


done_move_keen:
done_keypress:
no_keypress:
	bit	KEYRESET
	rts


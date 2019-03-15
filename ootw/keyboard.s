;======================================
; handle keypress
;======================================

handle_keypress:

	lda	KEYPRESS						; 4
	bmi	keypress						; 3

	rts	; nothing pressed, return

keypress:
									; -1

	and	#$7f		; clear high bit

check_quit:
;	cmp	#'Q'
;	beq	quit
	cmp	#27
	bne	check_left
quit:
	lda	#$ff		; could just dec
	sta	GAME_OVER
	rts

check_left:
	cmp	#'A'
	beq	left
	cmp	#$8		; left arrow
	bne	check_right
left:

	; walk left

	lda	#P_WALKING
	sta	PHYSICIST_STATE		; stand from crouching

	lda	DIRECTION		; if facing right, turn to face left
	bne	face_left

	inc	GAIT			; cycle through animation

	lda	GAIT
	and	#$7
	cmp	#$4
	bne	no_move_left

	dec	PHYSICIST_X		; walk left

no_move_left:
	lda	PHYSICIST_X
	cmp	LEFT_LIMIT
	bpl	just_fine_left
too_far_left:
	inc	PHYSICIST_X
	lda	#1
	sta	GAME_OVER

just_fine_left:



	jmp	done_keypress		; done

face_left:
	lda	#0
	sta	DIRECTION
	sta	GAIT
	jmp	done_keypress

check_right:
	cmp	#'D'
	beq	right
	cmp	#$15
	bne	check_down
right:
	lda	#P_WALKING
	sta	PHYSICIST_STATE

	lda	DIRECTION
	beq	face_right

	inc	GAIT

	lda	GAIT
	and	#$7
	cmp	#$4
	bne	no_move_right

	inc	PHYSICIST_X
no_move_right:

	lda	PHYSICIST_X
	cmp	RIGHT_LIMIT
	bne	just_fine_right
too_far_right:

	dec	PHYSICIST_X

	lda	#2
	sta	GAME_OVER


just_fine_right:

	jmp	done_keypress

face_right:
	lda	#0
	sta	GAIT
	lda	#1
	sta	DIRECTION
	jmp	done_keypress

check_down:
	cmp	#'S'
	beq	down
	cmp	#$0A
	bne	check_space
down:
	lda	#P_CROUCHING
	sta	PHYSICIST_STATE
	lda	#0
	sta	GAIT

	jmp	done_keypress

check_space:
	cmp	#' '
	beq	space
	cmp	#$15
	bne	unknown
space:
	lda	#P_KICKING
	sta	PHYSICIST_STATE
	lda	#15
	sta	GAIT
unknown:
done_keypress:
	bit	KEYRESET	; clear the keyboard strobe		; 4

	rts								; 6



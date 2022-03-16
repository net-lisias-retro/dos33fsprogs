
	; updates the time left
update_time:

	; update explosion timer
	; not ideal (first second might be short)
	lda	lemming_exploding
	beq	not_done_exploding

	inc	lemming_exploding
	lda	lemming_exploding
	cmp	#6
	bne	not_done_exploding

	lda	#LEMMING_EXPLODING
	sta	lemming_status
	lda	#0
	sta	lemming_frame
	sta	lemming_exploding


not_done_exploding:


	sed

	sec
	lda	TIME_SECONDS
	sbc	#1
	cmp	#$99
	bne	no_time_uflo
	lda	#$59
	dec	TIME_MINUTES

no_time_uflo:
	sta	TIME_SECONDS

	cld

	lda	TIME_MINUTES
	bne	not_over
	lda	TIME_SECONDS
	bne	not_over

	; out of time


	lda	#LEVEL_FAIL
	sta	LEVEL_OVER


not_over:


draw_time:

	; draw minute
	ldy	TIME_MINUTES

	lda	bignums_l,Y
	sta	INL
	lda	bignums_h,Y
	sta	INH

	; 246, 152

	ldx	#35		; 245
        stx     XPOS
	lda	#152
	sta	YPOS

	jsr	hgr_draw_sprite_autoshift

	; draw seconds
	lda	TIME_SECONDS
	lsr
	lsr
	lsr
	lsr
	tay

	lda	bignums_l,Y
	sta	INL
	lda	bignums_h,Y
	sta	INH

	ldx	#37
        stx     XPOS
	lda	#152
	sta	YPOS

	jsr	hgr_draw_sprite_autoshift


	; draw seconds
	lda	TIME_SECONDS
	and	#$f
	tay

	lda	bignums_l,Y
	sta	INL
	lda	bignums_h,Y
	sta	INH

	ldx	#38
        stx     XPOS
	lda	#152
	sta	YPOS

	jsr	hgr_draw_sprite_autoshift

	rts


	; update lemmings out number
update_lemmings_out:

	; draw minute
	ldy	LEMMINGS_OUT

	lda	bignums_l,Y
	sta	INL
	lda	bignums_h,Y
	sta	INH

	; 246, 152

	ldx	#15		; 105
        stx     XPOS
	lda	#152
	sta	YPOS

	jsr	hgr_draw_sprite_autoshift

	rts



bignums_l:
.byte	<big0_sprite,<big1_sprite,<big2_sprite,<big3_sprite,<big4_sprite
.byte	<big5_sprite,<big6_sprite,<big7_sprite,<big8_sprite,<big9_sprite

bignums_h:
.byte	>big0_sprite,>big1_sprite,>big2_sprite,>big3_sprite,>big4_sprite
.byte	>big5_sprite,>big6_sprite,>big7_sprite,>big8_sprite,>big9_sprite

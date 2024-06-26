
	;=======================
	; move enemies
	;=======================

move_enemies:

	ldx	#0

move_enemies_loop:
	cpx	NUM_ENEMIES
	bne	keep_on_moving

	jmp	done_move_enemies_loop
keep_on_moving:

	; only move if out

	; only move every 4th frame to slow things down

	lda	FRAMEL
	and	#$3
	bne	move_enemy_frame_skip

	lda	enemy_data_out,X
	bne	enemy_is_out
move_enemy_frame_skip:
	jmp	done_move_enemy
enemy_is_out:


	;=======================================
	; check if falling
	;	i.e., if something under feet
	;=======================================

	clc
	lda	enemy_data_tiley,X
	adc	#2				; point below feet

	tay
	lda	tilemap_lookup_high,Y
;	adc	#>big_tilemap
	sta	load_foot1_smc+2

	lda	tilemap_lookup_low,Y
	sta	load_foot1_smc+1

	ldy	enemy_data_tilex,X
load_foot1_smc:

	lda	small_tilemap,Y
	cmp	HARDTOP_TILES
	bcs	no_enemy_fall			; if hardtop tile, don't fall

	inc	enemy_data_tiley,X		; fall one tiles worth



no_enemy_fall:
	;============================
	; not falling, so do actions
	;============================
	; if walking, walk
	;	if searching, search


	dec	enemy_data_count,X
	bne	enemy_action

enemy_new_state:
	jsr	random16
	lda	SEEDL
	and	#$3
	sta	enemy_data_state,X

	jsr	random16
	lda	SEEDL
	and	#$f
	clc
	adc	#4
	sta	enemy_data_count,X


enemy_action:
	lda	enemy_data_state,X
	cmp	#YORP_STUNNED
	beq	goto_done_move_enemy
	cmp	#YORP_SEARCH
	beq	enemy_search
	cmp	#YORP_JUMP
	beq	enemy_jump
	bne	enemy_walk

goto_done_move_enemy:
	jmp	done_move_enemy

enemy_search:
	lda	enemy_data_direction,X
	eor	#$FF
	clc
	adc	#1
	sta	enemy_data_direction,X

	; TODO: face keen when done

	jmp	done_move_enemy


enemy_jump:
	; make sure we don't jump for too long
	; hack
	lda	enemy_data_count,X
	and	#$3
	sta	enemy_data_count,X

	; jump a bit
	dec	enemy_data_tiley,X

	; fallthrough

	;=======================================
	; move sideways
	;	until you hit something
	;=======================================
enemy_walk:
	; check if moving right/left

	lda	enemy_data_direction,X
	bmi	enemy_facing_left
enemy_facing_right:

	;==============================
	; check if barrier to the right

	clc
	lda	enemy_data_tiley,X
	adc	#1				; point to feet
	tay

;	adc	#>big_tilemap
	lda	tilemap_lookup_high,Y
	sta	load_right_foot_smc+2
	lda	tilemap_lookup_low,Y
	sta	load_right_foot_smc+1


	ldy	enemy_data_tilex,X
	iny	; to the right
load_right_foot_smc:
	lda	small_tilemap,Y
	cmp	ALLHARD_TILES
	bcc	no_right_barrier		; skip if no right barrier

	; hit right barrier

	lda	enemy_data_direction,X
	eor	#$ff				; ff->00, 01->fe
	clc
	adc	#1
	sta	enemy_data_direction,X

	jmp	done_move_enemy


no_right_barrier:

	; move to the right

	lda	enemy_data_x,X
	clc
	adc	#1
	sta	enemy_data_x,X
	cmp	#2
	bne	move_right_noflo

	; moved to next tile
	lda	#0
	sta	enemy_data_x,X

	lda	enemy_data_tilex,X
	clc
	adc	#1
	sta	enemy_data_tilex,X

move_right_noflo:
	jmp	done_move_enemy

enemy_facing_left:

	;==============================
	; check if barrier to the left

	clc
	lda	enemy_data_tiley,X
	adc	#1				; point to feet

	tay

;	adc	#>big_tilemap
	lda	tilemap_lookup_high,Y
	sta	load_left_foot_smc+2
	lda	tilemap_lookup_low,Y
	sta	load_left_foot_smc+1

	ldy	enemy_data_tilex,X
	dey					; look to the left
load_left_foot_smc:
	lda	small_tilemap,Y
	cmp	ALLHARD_TILES
	bcc	no_left_barrier			; skip if no right barrier

	; hit left barrier

	lda	enemy_data_direction,X
	eor	#$ff				; ff->00, 01->fe
	clc
	adc	#1
	sta	enemy_data_direction,X

	jmp	done_move_enemy


no_left_barrier:

	; move to the left

	sec
	lda	enemy_data_x,X
	sbc	#1
	sta	enemy_data_x,X
	bpl	move_left_noflo

	; adjust tile

	lda	#1
	sta	enemy_data_x,X

	lda	enemy_data_tilex,X
	sec
	sbc	#1
	sta	enemy_data_tilex,X

move_left_noflo:


done_move_enemy:

	inx
;	cpx	NUM_ENEMIES
;	beq	totally_done_move_enemies

	jmp	move_enemies_loop

done_move_enemies_loop:
totally_done_move_enemies:
	rts



	;=================
	; draw enemies
	;=================
draw_enemies:

	ldy	#0
draw_enemies_loop:
	cpy	NUM_ENEMIES
	beq	done_draw_enemies

	; see if out

	lda	enemy_data_out,Y
	beq	done_draw_enemy

	; see if exploding
	lda	enemy_data_exploding,Y
	beq	draw_proper_enemy
;draw_exploding_enemy:
;	asl
;	tax
;	lda	enemy_explosion_sprites,X
;	sta	INL
;	lda	enemy_explosion_sprites+1,X
;	sta	INH

;	lda	FRAMEL
;	and	#$3
;	bne	done_exploding

	; move to next frame
;	lda	enemy_data+ENEMY_DATA_EXPLODING,Y
;	clc
;	adc	#1
;	sta	enemy_data+ENEMY_DATA_EXPLODING,Y

;	cmp	#4
;	bne	done_exploding
;	lda	#0
;	sta	enemy_data+ENEMY_DATA_OUT,Y

;done_exploding:
;	jmp	draw_enemy

	; otherwise draw proper sprite
draw_proper_enemy:
;	lda	enemy_data+ENEMY_DATA_TYPE,Y
;	tax
;	lda	enemy_sprites,X
;	sta	INL
;	lda	enemy_sprites+1,X
;	sta	INH

	lda	enemy_data_state,Y
	cmp	#YORP_STUNNED
	bne	draw_enemy_walk

	lda	#<yorp_sprite_stunned
	sta	INL

	lda	#>yorp_sprite_stunned
	jmp	draw_enemy_common


draw_enemy_walk:
	lda	enemy_data_direction,Y
	bmi	draw_enemy_left

draw_enemy_right:
	lda	#<yorp_sprite_walking_right
	sta	INL

	lda	#>yorp_sprite_walking_right
	jmp	draw_enemy_common

draw_enemy_left:
	lda	#<yorp_sprite_walking_left
	sta	INL

	lda	#>yorp_sprite_walking_left

draw_enemy_common:
	sta	INH

	;======================
	; calculate X and Y
	;	tiles are 2x4 in size

	sec
	lda	enemy_data_tilex,Y
	sbc	TILEMAP_X
	asl
	clc
	adc	enemy_data_x,Y		; Add in X offset
	sta	XPOS

	sec
	lda	enemy_data_tiley,Y
	sbc	TILEMAP_Y
	asl
	asl
	clc
	adc	enemy_data_y,Y		; Add in Y offset
	sta	YPOS

draw_enemy:
	tya
	pha

	jsr	put_sprite_crop

	pla
	tay

done_draw_enemy:
	iny
;	cpy	NUM_ENEMIES
;	beq	exit_draw_enemy
	jmp	draw_enemies_loop

done_draw_enemies:
exit_draw_enemy:
	rts

enemy_explosion_sprites:
	.word	enemy_explosion_sprite1
	.word	enemy_explosion_sprite1
	.word	enemy_explosion_sprite2
	.word	enemy_explosion_sprite3

enemy_explosion_sprite1:
	.byte	2,2
	.byte	$d9,$d9
	.byte	$9d,$9d

enemy_explosion_sprite2:
	.byte	2,2
	.byte	$9A,$9A
	.byte	$A9,$A9

enemy_explosion_sprite3:
	.byte	2,2
	.byte	$7A,$5A
	.byte	$A5,$A7

;YORP	= 0

;YORP_WALK   = 0
;YORP_JUMP   = 1
;YORP_SEARCH = 2
;YORP_WALK2  = 3
;YORP_STUNNED= 4

;LEFT	= $FF
;RIGHT	= $1

;enemy_data_out:		.byte 1,     0,	  0,    0,    0,    0,   0,    0
;enemy_data_exploding:	.byte 0,     0,	  0,    0,    0,    0,   0,    0
;enemy_data_type:	.byte YORP,  YORP, YORP, YORP, YORP, YORP,YORP,YORP
;enemy_data_direction:	.byte RIGHT, LEFT, LEFT, LEFT, LEFT, RIGHT,RIGHT,LEFT
;enemy_data_tilex:	.byte 19,    38,   45,   69,   81,   89,  92,  100
;enemy_data_tiley:	.byte 13,    4,    4,    13,   4,    4,   13,  10
;enemy_data_x:		.byte 0,     0,    0,    0,    0,    0,   0,   0
;enemy_data_y:		.byte 0,     0,    0,    0,    0,    0,   0,   0
;enemy_data_state:	.byte 0,     0,    0,    0,    0,    0,   0,   0
;enemy_data_count:	.byte 8,     8,    8,    8,    8,    8,   8,   8

; question: when do they activate?  When do they move when offscreen?

; enemy behavior
;	Yorp:
;		two behaviors, walking with random jump
;			walking, reverses direction if hits barrier
;		stopping, looking left/right few times then walking at Keen



	;======================
	; check touching things
	;======================
	; do head, than foot
	; FIXME: should we check both head/feet?
check_items:
	jsr	check_door

	ldx	KEEN_HEAD_POINTER
	jsr	check_item

	ldx	KEEN_FOOT_POINTER
	; fallthrough

	;==================
	; check for items
	;==================

check_item:
	lda	tilemap,X

do_check_enemy:
	

do_check_item:
	cmp	#27
	bcc	done_check_item		; not an item
	cmp	#32
	bcs	done_check_item		; not an item

	sec
	sbc	#27			; subtract off to get index

	; 0 = laser gun
	; 1 = lollipop			100 pts
	; 2 = book			1000 pts
	; 3 = pizza			500 pts
	; 4 = carbonated beverage	200 pts
	; ? = bear			5000 pts

	beq	get_laser_gun

	; otherwise look up points and add it

	tay
	lda	score_lookup,Y
	jsr	inc_score
	jmp	done_item_pickup

get_laser_gun:
	lda	RAYGUNS
	clc
	sed
	adc	#$05
	sta	RAYGUNS
	cld

	jmp	done_item_pickup

	; keycards go here too...
get_keycard:

done_item_pickup:

	; erase small tilemap

	lda	#1			; plain tile
	sta	tilemap,X

	; big tilemap:
	;	to find... urgh
	;	X is currently (KEEN_Y/4)*20)+(KEEN_X/2)

	lda	KEEN_Y			; divide by 4 as tile 4 blocks tall
	lsr
	lsr

	clc
	adc	TILEMAP_Y		; add in tilemap Y (each row 256 bytes)
	adc	#>big_tilemap		; add in offset of start
	sta	btc_smc+2

	lda	TILEMAP_X		; add in X offset of tilemap
	sta	btc_smc+1

	lda	KEEN_X
	lsr
	tay
;	iny				; why add 1????

	lda	#0			; background tile
btc_smc:
	sta	$b000,Y

	; play sound
	jsr	pickup_noise


done_check_item:
	rts

	;==========================
	; check if feet at door
	;==========================
check_door:
	lda	KEEN_FOOT_TILE1
	cmp	#11			; door tile
	beq	at_door
	lda	KEEN_FOOT_TILE2
	cmp	#11
	bne	done_check_door

at_door:
	inc	LEVEL_OVER
	; TODO: mark level complete somehow
	jsr	exit_music
done_check_door:
	rts

score_lookup:
	.byte $00,$01,$10,$05,$02,$50		; BCD
	; 0 = laser gun
	; 1 = lollipop			100 pts
	; 2 = book			1000 pts
	; 3 = pizza			500 pts
	; 4 = carbonated beverage	200 pts
	; ? = bear			5000 pts

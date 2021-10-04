
	;=====================
	; new map location
	;=====================

new_map_location:
	lda	#NEW_LOCATION
	sta	GAME_OVER

	; fall through

	;==================
	; update map
	;	on main map, it's (MAP_Y*5)+MAP_X
update_map_location:
	; put in map

map_wrap_x:
	; wrap X (0..4)
	lda	MAP_X
	bmi	map_x_went_negative
	cmp	#5
	bcc	map_wrap_y		; blt

	lda	#0
	beq	update_map_x		; bra

map_x_went_negative:
	lda	#4

update_map_x:
	sta	MAP_X

map_wrap_y:

	; wrap Y (0..3)
	lda	MAP_Y
	and	#$3
	sta	MAP_Y

	clc
	lda	MAP_Y
	asl
	asl
	adc	MAP_Y
	adc	MAP_X

	sta	MAP_LOCATION

	; see if we need to change disk

	lda	MAP_Y
	cmp	#WHICH_PEASANTRY

	beq	were_good

must_load_from_disk:
	lda	#NEW_FROM_DISK
	sta	GAME_OVER

	lda	MAP_Y
	clc
	adc	#LOAD_PEASANT1
	sta	WHICH_LOAD

were_good:
	rts



do_plasma:
	; init

BP3:

; ============================================================================
; Precalculate some values (inlined)
; ROUTINES PRE CALCUL
; ============================================================================
;
; cycles = 30 + (40*53) -1 + 25 = 2174 cycles

precalc:
; 0
	lda	PARAM1		; self modify various parts		; 3
	sta	pc_off1+1						; 4
	lda	PARAM2							; 3
	sta	pc_off2+1						; 4
	lda	PARAM3							; 3
	sta	pc_off3+1						; 4
	lda	PARAM4							; 3
	sta	pc_off4+1						; 4

; 28

	; Table1(X) = sin1(PARAM1+X)+sin2(PARAM1+X)
	; Table2(X) = sin3(PARAM3+X)+sin1(PARAM4+X)

	ldx	#$28		; 40					; 2
; 30

precalc_loop:

pc_off1:
	lda	sin1							; 4
pc_off2:
	adc	sin2							; 4
	sta	Table1,X						; 4
; 12

pc_off3:
	lda	sin3							; 4
pc_off4:
	adc	sin1							; 4
	sta	Table2,X						; 4
; 24

	inc	pc_off1+1						; 6
	inc	pc_off2+1						; 6
	inc	pc_off3+1						; 6
	inc	pc_off4+1						; 6
; 48
 	dex								; 2
	bpl	precalc_loop						; 2/3
; 53

 	inc	PARAM1							; 5
 	inc	PARAM1							; 5
	dec	PARAM2							; 5
 	inc	PARAM3							; 5
	dec	PARAM4							; 5
; 25

; ============================================================================
; Display Routines
; ROUTINES AFFICHAGES
; ============================================================================
; 26+( 24*(11+(40*(39+(38*2))) = 110,690
; 26+( 24*(11+(40*(39+(38*4))) = 183,650
; 26+( 24*(11+(40*(39+(38*8))) = 329,570

; Display "Normal"
; AFFICHAGE "NORMAL"

display_normal:

	ldx	#23			; lines 0-23	lignes 0-23	; 2

display_line_loop:
; 0
	lda	hposn_low_div8,X	; setup line pointer		; 4
	sta	GBASL							; 3
; 7
	ldy	#39			; col 0-39			; 2

	lda	Table2,X		; setup base sine value for row	; 4
	sta	display_row_sin_smc+1					; 4
; 17

display_col_loop:

	lda	Table1,Y		; load in column sine value	; 4
display_row_sin_smc:
	adc	#00			; add in row value		; 2
	sta	display_lookup_smc+1	; patch in low byte of lookup	; 4
; 8
	; pick 0/1 for odd even
	lda	display_lookup_smc+2					; 4
	eor	#$01							; 2
	sta	display_lookup_smc+2					; 4

; 18

;	lda	hires_colors_even_l0	; attention: must be aligned
;	sta	color_smc+1

	lda	hposn_high_div8,X					; 4
	clc								; 2
	adc	PAGE							; 3
	sta	GBASH							; 3
; 30
	lda	#1							; 2
	sta	COUNT							; 3
; 35
store_loop:
color_smc:

	lda	display_lookup_smc+2					; 4
	eor	#$02							; 2
	sta	display_lookup_smc+2					; 4
; 10

display_lookup_smc:
	lda	hires_colors_even_l0	; attention: must be aligned	; 4
;	lda	#$fe
	sta	(GBASL),Y						; 6
	clc								; 2
	lda	#$10							; 2
	adc	GBASH							; 3
	sta	GBASH							; 3
	dec	COUNT							; 5
	bpl	store_loop						; 2/3
; 38

	dey								; 2
	bpl	display_col_loop					; 2/3

	dex								; 2
	bpl	display_line_loop					; 2/3

; ============================================================================

	lda	PAGE							; 3
	beq	was_page1						; 2/3
was_page2:
	bit	PAGE2							; 4
	lda	#0							; 2
	beq	done_pageflip						; 2/3
was_page1:
	bit	PAGE1							; 4
	lda	#$20							; 2
done_pageflip:
	sta	PAGE							; 3

	lda	#52
	jsr	wait_for_pattern

	bcc	wasnt_keypress

	jmp	done_plasma

wasnt_keypress:


; 15?
	inc	COMPT1							; 6
	beq	display_done2						; 2/3

;	bne	BP3
	jmp	BP3							; 3

display_done2:

	dec	COMPT2							; 6
	beq	display_done						; 2/3
;	bne	BP3
	jmp	BP3							; 3
display_done:

	jmp	do_plasma
;	beq	do_plasma	; bra


done_plasma:
	bit	KEYRESET
	rts


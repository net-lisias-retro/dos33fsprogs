; PLASMAGORIA

; original code by French Touch

; this is just part3 and size optimized
; just the graphics, no music


; Note: look into modifying color lookup table
;	there's a wide setting that gives a slightly different effect

.include "hardware.inc"

; Page Zero
OUT1			= $20 ; +$21
OUT2			= $22 ; +$23

; counter if not MOCKING
COMPT1			= $30
COMPT2			= $31

;
PARAM1			= $60
PARAM2			= $61
PARAM3			= $62
PARAM4			= $63
count			= $64
count2			= $65
;

GRLINE			= $F0	; +$F1
IndexMask		= $F2
Mask			= $F3

Beat			= $FA
Mark			= $FB

; =============================================================================
; ROUTINE MAIN
; =============================================================================
PLASMA_DEBUT:
	bit	PAGE2		; set page 2
	bit	SET_TEXT	; set text
	bit	LORES		; set lo-res


;	jsr	setup_dump

; ============================================================================

; -------------------------------------
STEP3:
	; init

;	lda	#00
;	sta	Beat

	lda	#02
	sta	COMPT2
	sta	PARAM1
	sta	PARAM2
	sta	PARAM3
	sta	PARAM4

BP3:
	jsr	precalc		; pre-calc
	jsr	display_normal	; display normal
	jsr	VBLANK
;	jsr	DUMP

	inc	COMPT1
	bne	BP3
	dec	COMPT2
	bne	BP3

	jmp	STEP3


; ============================================================================
; Precalculate some values
; ROUTINES PRE CALCUL
; ============================================================================
precalc:
	lda	PARAM1		; self modify various parts
	sta	pc_off1+1
	lda	PARAM2
	sta	pc_off2+1
	lda	PARAM3
	sta	pc_off3+1
	lda	PARAM4
	sta	pc_off4+1

	; Table1(X) = sin1(PARAM1+X)+sin2(PARAM1+X)
	; Table2(X) = sin3(PARAM3+X)+sin1(PARAM4+X)

	ldx	#$28		; 40
pc_b1:
pc_off1:
	lda	sin1
pc_off2:
	adc	sin2
	sta	Table1,X
pc_off3:
	lda	sin3
pc_off4:
	adc	sin1
	sta	Table2,X

	inc	pc_off1+1
	inc	pc_off2+1
	inc	pc_off3+1
	inc	pc_off4+1

 	dex
	bpl	pc_b1

 	inc	PARAM1
 	inc	PARAM1
	dec	PARAM2
 	inc	PARAM3
	dec	PARAM4

 	rts

; ============================================================================
; Display Routines
; ROUTINES AFFICHAGES
; ============================================================================

; Display "Normal"
; AFFICHAGE "NORMAL"

display_normal:
	bit	SET_GR			; gfx (lores)	why needed?

	ldx	#23			; lines 0-23	lignes 0-23

display_line_loop:
	lda	gr_lookup_low,X		; setup pointers for line
	sta	GRLINE
	lda	gr_lookup_high,X
	sta	GRLINE+1

	ldy	#39			; col 0-39

	lda	Table2,X		; setup base sine value for row
	sta	display_row_sin_smc+1
display_col_loop:
	lda	Table1,Y		; load in column sine value
display_row_sin_smc:
	adc	#00			; add in row value
	sta	display_lookup_smc+1	; patch in low byte of lookup
display_lookup_smc:
	lda	lores_colors_fine	; attention: must be aligned
	sta	(GRLINE),Y
	dey
	bpl	display_col_loop
	dex
	bpl	display_line_loop

	rts

VBLANK:
	inc	Mark
	rts


;.align 256

gr_lookup_low:
	.byte $00,$80,$00,$80,$00,$80,$00,$80
	.byte $28,$A8,$28,$A8,$28,$A8,$28,$A8
	.byte $50,$D0,$50,$D0,$50,$D0,$50,$D0

gr_lookup_high:
	.byte $08,$08,$09,$09,$0A,$0A,$0B,$0B
	.byte $08,$08,$09,$09,$0A,$0A,$0B,$0B
	.byte $08,$08,$09,$09,$0A,$0A,$0B,$0B



.align 256


; This appears to be roughly 47+32*sin(x)+16*sin(2x)
sin1: ; 256
.byte $2E,$30,$32,$34,$35,$36,$38,$3A,$3C,$3C,$3E,$40,$41,$42,$44,$45,$47,$47,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$53,$54,$54
.byte $55,$55,$56,$57,$57,$58,$58,$57,$58,$58,$58,$58,$58,$58,$58,$58,$58,$57,$57,$57,$56,$56,$55,$54,$55,$54,$53,$52,$52,$51,$50,$4F
.byte $4E,$4E,$4D,$4C,$4B,$4B,$4A,$49,$48,$47,$46,$45,$45,$44,$42,$42,$41,$41,$3F,$3F,$3D,$3D,$3C,$3B,$3B,$39,$39,$39,$38,$38,$37,$36
.byte $36,$35,$35,$34,$34,$33,$32,$32,$32,$31,$31,$31,$30,$31,$30,$30,$30,$30,$2F,$2F,$30,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$2E,$2F,$2F,$2F
.byte $2E,$2F,$2F,$2F,$2F,$2E,$2F,$2F,$2F,$2E,$2F,$2F,$2E,$2E,$2F,$2E,$2E,$2D,$2E,$2D,$2D,$2D,$2C,$2C,$2C,$2B,$2B,$2B,$2A,$2A,$29,$28
.byte $28,$27,$27,$26,$26,$25,$25,$23,$23,$22,$21,$21,$20,$1F,$1F,$1D,$1D,$1C,$1B,$1A,$19,$19,$17,$16,$16,$15,$14,$13,$13,$12,$11,$10
.byte $0F,$0F,$0E,$0D,$0C,$0C,$0B,$0A,$09,$09,$08,$08,$08,$07,$06,$07,$06,$06,$06,$06,$05,$06,$05,$05,$06,$05,$06,$06,$07,$07,$08,$08
.byte $09,$09,$0A,$0B,$0B,$0C,$0C,$0D,$0F,$0F,$10,$12,$12,$14,$15,$16,$17,$19,$1A,$1B,$1D,$1E,$20,$21,$22,$24,$26,$27,$28,$2A,$2C,$2E

; This appears to be roughly 47+32*sin(4x)+16*sin(3x)
sin2: ; 256
.byte $2E,$33,$38,$3C,$40,$43,$47,$4B,$4E,$51,$54,$56,$59,$5A,$5C,$5D,$5D,$5E,$5E,$5D,$5C,$5A,$59,$57,$55,$53,$4F,$4C,$49,$46,$42,$3E
.byte $3A,$36,$32,$2E,$2A,$26,$23,$1F,$1C,$18,$15,$12,$10,$0E,$0C,$0A,$09,$08,$07,$07,$07,$07,$09,$0A,$0B,$0D,$0F,$11,$13,$16,$19,$1C
.byte $1F,$22,$26,$29,$2C,$2F,$32,$36,$38,$3B,$3E,$3F,$42,$44,$46,$47,$48,$49,$4B,$4B,$4B,$4A,$4A,$49,$49,$48,$46,$44,$43,$41,$3F,$3C
.byte $3A,$38,$35,$33,$30,$2E,$2C,$2A,$28,$26,$24,$22,$21,$20,$1F,$1F,$1E,$1E,$1D,$1D,$1E,$1E,$1F,$20,$21,$22,$24,$25,$27,$29,$2B,$2D
.byte $2E,$30,$33,$35,$37,$38,$3A,$3C,$3D,$3E,$3F,$3F,$40,$40,$41,$40,$40,$3F,$3F,$3E,$3D,$3B,$3A,$38,$36,$34,$31,$2F,$2D,$2B,$29,$25
.byte $23,$21,$1F,$1D,$1B,$19,$18,$16,$15,$14,$14,$13,$13,$13,$13,$14,$16,$17,$18,$1A,$1C,$1D,$20,$23,$26,$28,$2C,$2E,$32,$35,$38,$3B
.byte $3E,$41,$45,$48,$4B,$4C,$4F,$51,$53,$54,$55,$55,$57,$57,$57,$56,$55,$53,$52,$50,$4E,$4B,$49,$45,$42,$3F,$3B,$37,$34,$30,$2C,$27
.byte $23,$1F,$1C,$18,$14,$11,$0E,$0B,$09,$07,$05,$03,$02,$01,$00,$00,$01,$01,$02,$03,$05,$07,$0A,$0D,$10,$13,$17,$1A,$1E,$22,$26,$2A

; This appears to be roughly 38+24*sin(3x)+16*sin(8x)
sin3: ; 256
.byte $26,$2C,$31,$35,$39,$3D,$40,$42,$44,$45,$45,$46,$45,$43,$42,$40,$3C,$3A,$38,$36,$33,$31,$30,$2F,$2F,$2E,$2F,$2F,$30,$33,$33,$36
.byte $37,$3A,$3C,$3C,$3E,$3E,$3D,$3D,$3B,$39,$36,$34,$30,$2B,$28,$23,$1D,$19,$14,$11,$0C,$09,$07,$04,$03,$03,$03,$03,$04,$07,$09,$0C
.byte $0F,$13,$16,$18,$1B,$1E,$20,$22,$22,$23,$24,$24,$23,$22,$21,$20,$1D,$1C,$1B,$1A,$19,$19,$19,$1A,$1C,$1E,$20,$23,$27,$2B,$2F,$33
.byte $37,$3D,$40,$44,$47,$4A,$4C,$4D,$4E,$4E,$4D,$4C,$4A,$47,$45,$41,$3C,$39,$35,$32,$2E,$2B,$28,$26,$25,$23,$23,$22,$22,$24,$24,$25
.byte $26,$29,$2A,$2A,$2B,$2C,$2B,$2B,$29,$28,$25,$23,$20,$1C,$19,$15,$10,$0D,$09,$07,$04,$02,$01,$00,$00,$00,$02,$03,$06,$0A,$0D,$11
.byte $15,$1B,$1F,$23,$27,$2B,$2D,$30,$32,$33,$34,$35,$35,$33,$33,$32,$30,$2E,$2D,$2C,$2B,$2A,$2A,$2A,$2B,$2C,$2E,$30,$32,$36,$38,$3B
.byte $3E,$42,$45,$47,$49,$4B,$4B,$4B,$4A,$49,$47,$45,$42,$3D,$3A,$35,$30,$2B,$26,$22,$1E,$1A,$17,$14,$13,$11,$10,$10,$10,$12,$12,$14
.byte $15,$18,$1A,$1B,$1D,$1E,$1F,$1F,$1F,$1F,$1E,$1D,$1B,$18,$16,$14,$10,$0E,$0C,$0B,$09,$08,$08,$09,$0A,$0C,$0E,$11,$14,$19,$1D,$22

.if 0
; This appears to be roughly 64+64*sin(x)
sin4: ; 256
.byte $40,$41,$43,$44,$46,$47,$49,$4A,$4C,$4D,$4F,$50,$52,$53,$55,$56,$58,$59,$5B,$5C,$5D,$5F,$60,$61,$63,$64,$65,$67,$68,$69,$6A,$6B
.byte $6C,$6D,$6F,$70,$71,$72,$73,$73,$74,$75,$76,$77,$78,$78,$79,$7A,$7A,$7B,$7B,$7C,$7C,$7D,$7D,$7D,$7E,$7E,$7E,$7F,$7F,$7F,$7F,$7F
.byte $7F,$7F,$7F,$7F,$7F,$7F,$7E,$7E,$7E,$7D,$7D,$7D,$7C,$7C,$7B,$7B,$7A,$7A,$79,$78,$78,$77,$76,$75,$74,$73,$73,$72,$71,$70,$6F,$6D
.byte $6C,$6B,$6A,$69,$68,$67,$65,$64,$63,$61,$60,$5F,$5D,$5C,$5B,$59,$58,$56,$55,$53,$52,$50,$4F,$4D,$4C,$4A,$49,$47,$46,$44,$43,$41
.byte $3F,$3E,$3C,$3B,$39,$38,$36,$35,$33,$32,$30,$2F,$2D,$2C,$2A,$29,$27,$26,$24,$23,$22,$20,$1F,$1E,$1C,$1B,$1A,$18,$17,$16,$15,$14
.byte $13,$12,$10,$0F,$0E,$0D,$0C,$0C,$0B,$0A,$09,$08,$07,$07,$06,$05,$05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04,$05,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0C,$0D,$0E,$0F,$10,$12
.byte $13,$14,$15,$16,$17,$18,$1A,$1B,$1C,$1E,$1F,$20,$22,$23,$24,$26,$27,$29,$2A,$2C,$2D,$2F,$30,$32,$33,$35,$36,$38,$39,$3B,$3C,$3E
.endif


; Lookup table for colors
; Note the sine tables point roughly to the middle and go to the edges


; This table has relatively fine color bands
lores_colors_fine: ; 256
.if 1
.byte $00,$00,$00,$00,$88,$88,$88,$88
.byte $55,$55,$55,$55,$99,$99,$99,$99
.byte $ff,$ff,$ff,$ff,$bb,$bb,$bb,$bb
.byte $33,$33,$33,$33,$22,$22,$22,$22
.byte $66,$66,$66,$66,$77,$77,$77,$77
.byte $44,$44,$44,$44,$cc,$cc,$cc,$cc
.byte $ee,$ee,$ee,$ee,$dd,$dd,$dd,$dd
.byte $99,$99,$99,$99,$11,$11,$11,$11

.byte $00,$00,$00,$00,$88,$88,$88,$88
.byte $55,$55,$55,$55,$99,$99,$99,$99
.byte $ff,$ff,$ff,$ff,$bb,$bb,$bb,$bb
.byte $33,$33,$33,$33,$22,$22,$22,$22
.byte $66,$66,$66,$66,$77,$77,$77,$77
.byte $44,$44,$44,$44,$cc,$cc,$cc,$cc
.byte $ee,$ee,$ee,$ee,$dd,$dd,$dd,$dd
.byte $99,$99,$99,$99,$11,$11,$11,$11

.byte $00,$00,$00,$00,$88,$88,$88,$88
.byte $55,$55,$55,$55,$99,$99,$99,$99
.byte $ff,$ff,$ff,$ff,$bb,$bb,$bb,$bb
.byte $33,$33,$33,$33,$22,$22,$22,$22
.byte $66,$66,$66,$66,$77,$77,$77,$77
.byte $44,$44,$44,$44,$cc,$cc,$cc,$cc
.byte $ee,$ee,$ee,$ee,$dd,$dd,$dd,$dd
.byte $99,$99,$99,$99,$11,$11,$11,$11

.byte $00,$00,$00,$00,$88,$88,$88,$88
.byte $55,$55,$55,$55,$99,$99,$99,$99
.byte $ff,$ff,$ff,$ff,$bb,$bb,$bb,$bb
.byte $33,$33,$33,$33,$22,$22,$22,$22
.byte $66,$66,$66,$66,$77,$77,$77,$77
.byte $44,$44,$44,$44,$cc,$cc,$cc,$cc
.byte $ee,$ee,$ee,$ee,$dd,$dd,$dd,$dd
.byte $99,$99,$99,$99,$11,$11,$11,$11
.else
; This table has relatively wide color bands
lores_colors_wide: ; 256
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $88,$88,$88,$88,$88,$88,$88,$88
.byte $88,$88,$88,$88,$88,$88,$88,$88
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $22,$22,$22,$22,$22,$22,$22,$22
.byte $22,$22,$22,$22,$22,$22,$22,$22
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $bb,$bb,$bb,$bb,$bb,$bb,$bb,$bb
.byte $bb,$bb,$bb,$bb,$bb,$bb,$bb,$bb
.byte $33,$33,$33,$33,$33,$33,$33,$33
.byte $33,$33,$33,$33,$33,$33,$33,$33
.byte $22,$22,$22,$22,$22,$22,$22,$22
.byte $22,$22,$22,$22,$22,$22,$22,$22
.byte $66,$66,$66,$66,$66,$66,$66,$66
.byte $66,$66,$66,$66,$66,$66,$66,$66
.byte $77,$77,$77,$77,$77,$77,$77,$77
.byte $77,$77,$77,$77,$77,$77,$77,$77
.byte $44,$44,$44,$44,$44,$44,$44,$44
.byte $44,$44,$44,$44,$44,$44,$44,$44
.byte $cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
.byte $cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
.byte $ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee
.byte $ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee
.byte $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd
.byte $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd
.byte $99,$99,$99,$99,$99,$99,$99,$99
.byte $99,$99,$99,$99,$99,$99,$99,$99
.byte $11,$11,$11,$11,$11,$11,$11,$11
.byte $11,$11,$11,$11,$11,$11,$11,$11
.endif







Table1	=	$8000
Table2	=	$8000+64

.if 0
Table1:	; !fill 64,0
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
Table2: ; !fill 64,0
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
.endif
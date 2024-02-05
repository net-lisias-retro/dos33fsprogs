; PLASMAGORIA, hi-res version

; original code by French Touch


.include "hardware.inc"

hposn_high=$6000
hposn_low =$6100

;Table1	=	$8000
;Table2	=	$8000+64

HGR     =       $F3E2

; Page Zero

GBASL	= $26
GBASH	= $27

COMPT1	= $30
COMPT2	= $31

PARAM1	= $60
PARAM2	= $61
PARAM3	= $62
PARAM4	= $63

Table1	= $A0	; 40 bytes
Table2	= $D0	; 40 bytes


; =============================================================================
; ROUTINE MAIN
; =============================================================================

plasma_debut:
	jsr	HGR		; have table gen appear on hgr page1
	bit	FULLGR

	jsr	build_tables

lores_colors_fine=$8100

; ============================================================================
; init lores colors (inline)
; ============================================================================

init_lores_colors:
	ldx	#0
	ldy	#0
; 347

init_lores_colors_loop:
	lda	lores_colors_lookup,X
	sta	lores_colors_fine,Y
	iny
	sta	lores_colors_fine,Y
	iny
	sta	lores_colors_fine,Y
	iny
	sta	lores_colors_fine,Y
	iny
	beq	done_init_lores_colors

	inx
	txa
	and	#$f
	tax
	jmp	init_lores_colors_loop

done_init_lores_colors:

; ============================================================================

do_plasma:
	; init

;	lda	#02
;	ldx	#5
;init_loop:
;	sta	COMPT1,X
;	dex
;	bne	init_loop

BP3:

; ============================================================================
; Precalculate some values (inlined)
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

; ============================================================================
; Display Routines
; ROUTINES AFFICHAGES
; ============================================================================

; Display "Normal"
; AFFICHAGE "NORMAL"

display_normal:

	ldx	#23			; lines 0-23	lignes 0-23

display_line_loop:

	txa
	pha
	asl
	asl
	asl
	tax
	lda	hposn_high,X
	sta	output_smc+2
	lda	hposn_low,X
	sta	output_smc+1
	pla
	tax

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

output_smc:
	sta	$2000,Y

	dey
	bpl	display_col_loop
	dex
	bpl	display_line_loop

; ============================================================================

	inc	COMPT1
	bne	BP3

	dec	COMPT2
	bne	BP3

	beq	do_plasma	; bra





lores_colors_lookup:
.byte $00,$88,$55,$99,$ff,$bb,$33,$22,$66,$77,$44,$cc,$ee,$dd,$99,$11

.include "hgr_table.s"

.align 256
sin1:
.incbin "tables"
sin2=sin1+256
sin3=sin2+256

; Double Hi-res / Double lo-res mode switch fun

; by Vince `deater` Weaver

.include "zp.inc"
.include "hardware.inc"


double:

	;================================
	; detect model
	;================================

	jsr	detect_appleii_model


	;======================
	; machine workarounds
	;======================
	; mostly IIgs
	;===================
	; thanks to 4am who provided this code from Total Replay

	lda	ROM_MACHINEID
	cmp	#$06
	bne	not_a_iigs
	sec
	jsr	$FE1F			; check for IIgs
	bcs	not_a_iigs

	; gr/text page2 handling broken on early IIgs models
	; this enables the workaround

	jsr	ROM_TEXT2COPY		; set alternate display mode on IIgs
	cli				; enable VBL interrupts


	; also set background color to black instead of blue
	lda     NEWVIDEO
	and     #%00011111	; bit 7 = 0 -> IIgs Apple II-compat video modes
				; bit 6 = 0 -> IIgs 128K memory map same as IIe
				; bit 5 = 0 -> IIgs DHGR is color, not mono
				; bits 0-4 unchanged
	sta	NEWVIDEO
	lda	#$F0
	sta	TBCOLOR			; white text on black background
	lda	#$00
	sta	CLOCKCTL		; black border
	sta	CLOCKCTL		; set twice for VidHD

not_a_iigs:

	;================================
	; setup vblank routine
	;================================

	lda	APPLEII_MODEL
	cmp	#'G'
	beq	setup_vblank_iigs
	cmp	#'C'
	beq	setup_vblank_iic
setup_vblank_iie:
	lda	#<wait_vblank_iie
	sta	vblank_smc+1
	lda	#>wait_vblank_iie
	sta	vblank_smc+2
	jmp	done_setup_vblank

setup_vblank_iigs:
	lda	#<wait_vblank_iigs
	sta	vblank_smc+1
	lda	#>wait_vblank_iigs
	sta	vblank_smc+2
	jmp	done_setup_vblank

setup_vblank_iic:
	lda	#<wait_vblank_iic
	sta	vblank_smc+1
	lda	#>wait_vblank_iic
	sta	vblank_smc+2
	jmp	done_setup_vblank
done_setup_vblank:


	;====================
	; show title message
	;====================

	lda	#0
	sta	DRAW_PAGE

	jsr	show_title

	;===================
	; print config
	;===================

	lda	#<config_string
	sta	OUTL
	lda	#>config_string
	sta	OUTH

	jsr	move_and_print

	; print detected model

	lda	APPLEII_MODEL
	ora	#$80
	sta	$7d0+8			; 23,8

	; if GS print the extra S
	cmp	#'G'|$80
	bne	not_gs
	lda	#'S'|$80
	sta	$7d0+9

not_gs:

	;=========================================
	; detect if we have a language card (64k)
	; and load sound into it if possible
	;=========================================

	lda	#0
	sta	SOUND_STATUS	; clear out, sound enabled

	;===========================================
	; skip checks if open-apple being held down

	lda	$C061
	and	#$80			; only bit 7 is affected
	bne	skip_all_checks		; rest is floating bus


	jsr	detect_language_card
	bcs	no_language_card

yes_language_card:
	; update status
	lda	#'6'|$80
	sta	$7d0+11		; 23,11
	lda	#'4'|$80
	sta	$7d0+12		; 23,12

	; update sound status
	lda	SOUND_STATUS
	ora	#SOUND_IN_LC
	sta	SOUND_STATUS

	jmp	done_language_card

no_language_card:

done_language_card:

	;===================================
        ; Detect Mockingboard
        ;===================================

PT3_ENABLE_APPLE_IIC = 1

	; detect mockingboard
	jsr	mockingboard_detect

	bcc	mockingboard_notfound
mockingboard_found:
        ; print detected location

        lda     #'S'+$80                ; change NO to slot
        sta     $7d0+30

        lda     MB_ADDR_H               ; $C4 = 4, want $B4 1100 -> 1011
        and     #$87
        ora     #$30

        sta     $7d0+31                 ; 23,31

        ; NOTE: in this game we need both language card && mockingboard
        ;       to enable mockingboard music

        lda     SOUND_STATUS
        and     #SOUND_IN_LC
        beq     dont_enable_mc

        lda     SOUND_STATUS
        ora     #SOUND_MOCKINGBOARD
        sta     SOUND_STATUS

dont_enable_mc:
mockingboard_notfound:

skip_all_checks:

	;==================================
        ; load music into the language card
        ;       into $D000 set 2
        ;==================================

        ; switch in language card
        ; read/write RAM, $d000 bank 2

;	lda	$C08b
;	lda	$C08b


	jsr	mockingboard_patch      ; patch to work in slots other than 4?

	;=======================
	; Set up 50Hz interrupt
	;========================

	jsr	mockingboard_init
	jsr	mockingboard_setup_interrupt


zurg:

	;============================
	; Init the Mockingboard
	;============================

	jsr	reset_ay_both
	jsr	clear_ay_both

        ;=======================
        ; wait for keypress
        ;=======================

;       jsr     wait_until_keypress

        lda     #25
        jsr     wait_a_bit


;	jsr	wait_until_keypress

	;================================
	; Clear screen and setup graphics
	;================================

	jsr	SETGR		; set lo-res 40x40 mode
	bit	LORES


	;====================================================
	; setup text page2 screen of "Apple II Forever" text
	;====================================================
	; there are much better ways to accomplish this

	sta	SETMOUSETEXT

	ldy	#0
	ldx	#0
	sty	XX
a24e_newy:
	lda	gr_offsets_l,Y
	sta	stringing_smc+1
	lda	gr_offsets_h,Y
	clc
	adc	#4
	sta	stringing_smc+2

a24e_loop:

	lda	a2_string,X
	bne	keep_stringing

	ldx	#0
	lda	a2_string,X

keep_stringing:

	inx

	eor	#$80

stringing_smc:
	sta	$d000

	inc	stringing_smc+1

	inc	XX
	lda	XX
	cmp	#40
	bne	a24e_loop

	lda	#0
	sta	XX
	iny
	cpy	#24
	bne	a24e_newy

stringing_done:



	; set 80-store mode

	sta	EIGHTYSTOREON	; PAGE2 selects AUX memory

	;=========================================================
	; load double lo-res image to $C00 and copy to MAIN:PAGE1
	;=========================================================

	bit	PAGE1

	lda	#<image_dgr_main
	sta	ZX0_src
	lda	#>image_dgr_main
	sta	ZX0_src+1

	lda	#$0c

	jsr	full_decomp

	jsr	copy_to_400

	;=========================================================
	; load double lo-res image to $C00 and copy to AUX:PAGE1
	;=========================================================

	bit	PAGE2			; map in AUX (80store)

	lda	#<image_dgr_aux
	sta	ZX0_src
	lda	#>image_dgr_aux
	sta	ZX0_src+1

	lda	#$0c

	jsr	full_decomp

	jsr	copy_to_400

	;=======================================
	; load double hi-res image to MAIN:PAGE1
	;=======================================
	bit	HIRES			; need to do this for 80store to work
	bit	PAGE1

	lda	#<image_dhgr_bin
	sta	ZX0_src
	lda	#>image_dhgr_bin
	sta	ZX0_src+1

	lda	#$20

	jsr	full_decomp

	;=======================================
	; load double hi-res image to AUX:PAGE1
	;=======================================

	bit	PAGE2			; map in AUX (80store)

	lda	#<image_dhgr_aux
	sta	ZX0_src
	lda	#>image_dhgr_aux
	sta	ZX0_src+1

        lda	#$20

	jsr	full_decomp


	;=================================
	; load hi-res image to MAIN:PAGE2
	;=================================

	; turn off eightystore

	sta	EIGHTYSTOREOFF

	lda	#<image_hgr
	sta	ZX0_src
	lda	#>image_hgr
	sta	ZX0_src+1

        lda	#$40

	jsr	full_decomp



	sta	FULLGR


	;==============
        ; set up music
        ;==============

        lda     #0
        sta     CURRENT_CHUNK
        sta     DONE_PLAYING
        sta     BASE_FRAME_L

        ; set up first song

        lda     #<music_parts_l
        sta     chunk_l_smc+1
        lda     #>music_parts_l
        sta     chunk_l_smc+2

        lda     #<music_parts_h
        sta     chunk_h_smc+1
        lda     #>music_parts_h
        sta     chunk_h_smc+2

	lda     #$D0
        sta     CHUNK_NEXT_LOAD         ; Load at $D0
        jsr     load_song_chunk

        lda     #$D0                    ; music starts at $d000
        sta     CHUNK_NEXT_PLAY
        sta     BASE_FRAME_H

        lda     #1
        sta     LOOP
;        sta     CURRENT_CHUNK
	sta	LOAD_NEXT_CHUNK

        ; switch in language card
        ; read/write RAM, $d000 bank 2

	lda	$C08b
	lda	$C08b

	;=================================
	; main static loop
	;=================================
	;	each line 65 cycles (25 hblank+40 bytes)

double_loop:


	jsr	load_music
	jsr	play_music


	; note, coming out of vblank routines might be
	; 	8-12 cycles in already

vblank_smc:
	jsr	$ffff


; 3 LINES 80-COL TEXT AN3=0 PAGE=2

	bit	PAGE2

;	nop
;	nop
;	sta	SET80COL	; 4
	bit	SET_TEXT	; 4

	; wait 6*4=24 lines
	; (24*65)-8 = 1560-8 = 1552

	jsr	delay_1552

; 3 LINES 40-COL TEXT AN3=0 PAGE=2

	nop
	nop

	nop
	nop
	sta	CLR80COL	; 4
	bit	SET_TEXT	; 4

	jsr	delay_1552

; 3 LINES 40-col LORES AN3=0 PAGE=1

	nop
	nop

	nop
	nop
	bit	PAGE1		; 4
	bit	SET_GR		; 4

	jsr	delay_1552

; 3 LINES 80-col DLORES AN3=0 PAGE=1

	nop
	nop

	sta	LORES
	sta	SET80COL	; 4
	sta	CLRAN3		; 4

	jsr	delay_1552


; 3 LINES 80-col DLORES AN3=0 PAGE=1

	nop
	nop

	nop
	nop

	nop
	nop

	nop
	nop

	jsr	delay_1552

; 3 lines HIRES 40-COL AN3=1 PAGE=2

	sta	CLR80COL
	sta	HIRES		; 4
	sta	PAGE2		; 4
	sta	SETAN3

	jsr	delay_1552

; 3 lines Double-hires AN3=0 PAGE=1
	sta	PAGE1
	bit	HIRES
	sta	SET80COL	; 4	; set 80 column mode
	sta	CLRAN3		; 4	; doublehireson

	jsr	delay_1552

; 3 line Double-HIRES

	nop
	nop

	nop
	nop

	nop
	nop

	nop
	nop

	jsr	delay_1552




	jmp	double_loop	; 3

;=======================================================
; need to align because if we straddle a page boundary
;	the time counts end up off

.align $100

.include "vblank.s"

	; actually want 1552-12 (6 each for jsr/rts)
	; 1540
	; Try X=15 Y=19 cycles=1540
	; 1532
	; Try X=1 Y=139 cycles=1530

delay_1552:

	nop



        ldy     #139							; 2
loop5:  ldx     #1							; 2
loop6:  dex								; 2
        bne     loop6							; 2nt/3
        dey								; 2
        bne     loop5							; 2nt/3

	rts


wait_until_keypress:
	lda	KEYBOARD
	bpl	wait_until_keypress
	bit	KEYRESET
	rts


	.include "pt3_lib_detect_model.s"
	.include "pt3_lib_mockingboard_detect.s"
	.include "pt3_lib_mockingboard_setup.s"
	.include "interrupt_handler.s"
	.include "pt3_lib_mockingboard_patch.s"

	.include "zx02_optim.s"

	.include "copy_400.s"

image_hgr:
	.incbin "graphics/sworg_hgr.hgr.zx02"
image_dhgr_aux:
	.incbin "graphics/sworg_dhgr.aux.zx02"
image_dhgr_bin:
	.incbin "graphics/sworg_dhgr.bin.zx02"
image_dgr_aux:
	.incbin "graphics/sworg_dgr.aux.zx02"
image_dgr_main:
	.incbin "graphics/sworg_dgr.main.zx02"

a2_string:
	;      012345678901234567   8       9
	.byte "Apple II Forever!! ",'@'+$80," "
	.byte "Apple II Forever! ",'@'+$80," ",0

top_string:
	.byte "DOUBLE DOUBLE by DEATER / DsR ",0
	.byte "       Graphics based on art by @YYYYYYYYY  Music: N. OOOOOOO",0


config_string:
;             0123456789012345678901234567890123456789
.byte   0,23,"APPLE II?, 48K, MOCKINGBOARD: NO, SSI: N",0


.include "gr_offsets.s"
.include "lc_detect.s"
.include "text_print.s"
.include "title.s"
.include "gr_fast_clear.s"
.include "wait_a_bit.s"
.include "wait.s"
.include "load_music.s"

music_parts_h:
        .byte >fighting_part1_zx02,>fighting_part2_zx02,>fighting_part3_zx02
        .byte >fighting_part4_zx02,>fighting_part5_zx02,>fighting_part6_zx02
        .byte >fighting_part7_zx02,>fighting_part8_zx02,>fighting_part9_zx02
	.byte >fighting_part10_zx02
	.byte $00

music_parts_l:
        .byte <fighting_part1_zx02,<fighting_part2_zx02,<fighting_part3_zx02
        .byte <fighting_part4_zx02,<fighting_part5_zx02,<fighting_part6_zx02
        .byte <fighting_part7_zx02,<fighting_part8_zx02,<fighting_part9_zx02
        .byte <fighting_part10_zx02

fighting_part1_zx02:
.incbin "music/fighting.part1.zx02"
fighting_part2_zx02:
.incbin "music/fighting.part2.zx02"
fighting_part3_zx02:
.incbin "music/fighting.part3.zx02"
fighting_part4_zx02:
.incbin "music/fighting.part4.zx02"
fighting_part5_zx02:
.incbin "music/fighting.part5.zx02"
fighting_part6_zx02:
.incbin "music/fighting.part6.zx02"
fighting_part7_zx02:
.incbin "music/fighting.part7.zx02"
fighting_part8_zx02:
.incbin "music/fighting.part8.zx02"
fighting_part9_zx02:
.incbin "music/fighting.part9.zx02"
fighting_part10_zx02:
.incbin "music/fighting.part10.zx02"





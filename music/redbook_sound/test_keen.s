
SOUND_OFFSET	= $F0
WHICH_SOUND	= $F1
INL		= $FE
INH		= $FF

KEYPRESS        = $C000
KEYRESET        = $C010

test_keen:
	lda	#0
	sta	WHICH_SOUND

next_sound:
	ldy	WHICH_SOUND
	lda	sounds_low,Y
	sta	INL
	lda	sounds_high,Y
	cmp	#$FF
	beq	test_keen		; reset

	sta	INH

	ldy	#0
	sty	SOUND_OFFSET
play_loop:
	ldy	SOUND_OFFSET
	lda	(INL),Y
	sta	speaker_frequency

	iny
	lda	(INL),Y
	cmp	#$FF
	beq	play_done

	asl
;	clc
;	adc	(INL),Y

	sta	speaker_duration
	iny
	bne	no_wrap
	inc	INH
no_wrap:

	sty	SOUND_OFFSET

	jsr	speaker_tone

	jmp	play_loop


play_done:
	lda	KEYPRESS
	bpl	play_done

	bit	KEYRESET

	inc	WHICH_SOUND

	jmp	next_sound



.include "longer_sound.s"
.include "ck1_sounds.inc"


sounds_low:
	.byte <WLDWALKSND, <WLDBLOCKSND,<WLDENTERSND,<KEENWALKSND
	.byte <KEENBLOKSND,<KEENJUMPSND,<KEENLANDSND,<KEENDIESND
	.byte <GOTBONUSSND,<GOTITEMSND, <GOTPARTSND, <KEENFIRESND
	.byte <KEENPOGOSND,<POGOJUMPSND,<LVLDONESND, <GAMEOVERSND
	.byte <HISCORESND, <TELEPORTSND,<CHUNKSMASH, <GOINDOORSND
	.byte <BUMPHEADSND,<USEKEYSND,  <CANNONFIRE, <SLAMSND
	.byte <CLICKSND,   <CRYSTALSND, <PLUMMETSND, <EXTRAMANSND
	.byte <YORPBUMPSND,<KEENWLK2SND,<YORPBOPSND, <GETCARDSND
	.byte <DOOROPENSND,<YORPSCREAM, <GARGSCREAM, <GUNCLICK
	.byte <SHOTHIT,    <TANKFIRE,   <vortscream, <keencicle
	.byte <keensleft,  <EARTHPOW,   $FF

sounds_high:
	.byte >WLDWALKSND, >WLDBLOCKSND,>WLDENTERSND,>KEENWALKSND
	.byte >KEENBLOKSND,>KEENJUMPSND,>KEENLANDSND,>KEENDIESND
	.byte >GOTBONUSSND,>GOTITEMSND, >GOTPARTSND, >KEENFIRESND
	.byte >KEENPOGOSND,>POGOJUMPSND,>LVLDONESND, >GAMEOVERSND
	.byte >HISCORESND, >TELEPORTSND,>CHUNKSMASH, >GOINDOORSND
	.byte >BUMPHEADSND,>USEKEYSND,  >CANNONFIRE, >SLAMSND
	.byte >CLICKSND,   >CRYSTALSND, >PLUMMETSND, >EXTRAMANSND
	.byte >YORPBUMPSND,>KEENWLK2SND,>YORPBOPSND, >GETCARDSND
	.byte >DOOROPENSND,>YORPSCREAM, >GARGSCREAM, >GUNCLICK
	.byte >SHOTHIT,    >TANKFIRE,   >vortscream, >keencicle
	.byte >keensleft,  >EARTHPOW,   $FF

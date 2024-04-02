; this code was widely shared for playing tones on Apple II
;	by POKEing the machine language and CALLing from BASIC

; it's originally by Paul Lutus, from the Apple II Red Book p45


; it's hard to find good info on this, but loading from $C030
;	"toggles" the speaker.  So toggling twice is esentially a square wave?

; using regular load/store/bit of $C030 is safe.  Some of the more
;	advanced addressing modes can double-toggle due to how some 6502
;	implementations run the address bus

; these seem to have been calculated assuming a 1MHz clock
;	but the Apple II actually runs at roughly 1.023MHz

; or a frequency of 1/(speaker_freq*20.46e-6)

; to go other way, speaker_freq=1/(freq*20.46e-6)

;NOTE_C3      = 376	; 129.7 (130.8)
;NOTE_CSHARP3 = 355	; 137.4 (138.6)
;NOTE_D3      = 335	; 145.6 (146.8)
;NOTE_DSHARP3 = 316	; 154.3 (155.6)
;NOTE_E3      = 298	; 163.5 (164.8)
;NOTE_F3      = 281	; 173.2 (174.6)
;NOTE_FSHARP3 = 265	; 183.6 (185.0)
NOTE_G3      = 250	; 194.5 (196.0)
NOTE_GSHARP3 = 236	; 206.1 (207.7)
NOTE_A3      = 223	; 218.3 (220.0)
NOTE_ASHARP3 = 210	; 231.3 (233.1)
NOTE_B3      = 199	; 245.0 (246.9)
NOTE_C4      = 187	; 259.6 (261.6)
NOTE_CSHARP4 = 177	; 275.0 (277.2)
NOTE_D4      = 167	; 291.4 (293.7)
NOTE_DSHARP4 = 158	; 308.6 (311.1)
NOTE_E4      = 149	; 326.9 (329.6)
NOTE_F4      = 140	; 346.3 (349.2)
NOTE_FSHARP4 = 132	; 366.8 (370.0)
NOTE_G4      = 125	; 388.5 (392.0)
NOTE_GSHARP4 = 118	; 411.5 (415.3)
NOTE_A4      = 111	; 435.8 (440.0)
NOTE_ASHARP4 = 105	; 461.6 (466.2)
NOTE_B4      = 99	; 488.9 (493.9)
NOTE_C5      = 94	; 517.7 (523.3)
NOTE_CSHARP5 = 88	; 548.3 (554.4)
NOTE_D5      = 83	; 580.5 (587.3)
NOTE_DSHARP5 = 79	; 614.8 (622.3)
NOTE_E5      = 74	; 651.0 (659.3)
NOTE_F5      = 70	; 689.3 (698.5)
NOTE_FSHARP5 = 66	; 729.8 (740.0)
NOTE_G5      = 62	; 772.6 (784.0)
NOTE_GSHARP5 = 59	; 817.9 (830.6)
NOTE_A5      = 56	; 865.9 (880.0)
NOTE_ASHARP5 = 52	; 916.6 (932.3)
NOTE_B5      = 50	; 970.3 (987.8)
NOTE_C6      = 47	; 1027.5 (1047.0)
NOTE_CSHARP6 = 44	; 1087.2 (1109.0)
NOTE_D6      = 42	; 1150.7 (1175.0)
NOTE_DSHARP6 = 39	; 1217.8 (1245.0)
NOTE_E6      = 37	; 1288.6 (1319.0)
NOTE_F6      = 35	; 1363.1 (1397.0)
NOTE_FSHARP6 = 33	; 1442.1 (1480.0)
NOTE_G6      = 31	; 1525.6 (1568.0)
NOTE_GSHARP6 = 29	; 1613.6 (1661.0)
NOTE_A6      = 28	; 1706.9 (1760.0)
NOTE_ASHARP6 = 26	; 1805.6 (1865.0)
NOTE_B6      = 25	; 1909.6 (1976.0)


;=====================================================
; speaker tone
;=====================================================
; A,X,Y trashed
; duration also trashed

; this was designed by basic to be poked into 770 ($302)
;	on an Applesoft CALL, X=$9d, Y=$02  (A,Y = Address to call)

; it was originally designed for Integer BASIC where Y=0 on call
;	and it was poked to $00 (zero page)

	; the inner freq loop is roughly FREQ*10cycles
	; so the square wave generated has a period of
	;	freq*20*1.023us
	; or a frequency of 1/(freq*20.46e-6)

	; more exactly, it is (4+10F)+(13+10F) = 20F+17

speaker_tone:
	ldy	#0							; 3
speaker_tone_loop:
	lda	$C030		; click speaker				; 4
speaker_loop:
	dey			;					; 2
	bne	freq_loop	;					; 2/3
	dec	speaker_duration	; (Duration)			; 6
	beq	done_tone						; 2/3
freq_loop:
	dex								; 2
	bne	speaker_loop						; 2/3
	ldx	speaker_frequency	; (Frequency)			; 4
	jmp	speaker_tone_loop					; 3
done_tone:
	rts

speaker_duration:
	.byte	$00
speaker_frequency:
	.byte	$00


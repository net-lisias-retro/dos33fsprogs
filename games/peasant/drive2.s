; roughly based on anti-m/anti-m.a

; Notes from qkumba/4am

; Drive with no disk and no motor, will return same value in range $00..$7f
; Drive with no disk but motor running will return random $00..$FF
; Some cards will return random even with no drive connected
; so the best way to detect if disk is there is to try seeking/reading
;	and seeing if you get valid data

.if 0
switch_drive1:
	lda	curtrk_smc+1
	sta	DRIVE2_TRACK	;	save track location
slotpatch10:
	lda	$C0d1		; 	drive 1 select
	lda	#1
	sta	CURRENT_DRIVE
	lda	DRIVE1_TRACK	;	restore saved track location
	sta	curtrk_smc+1
	rts

switch_drive2:
	lda	curtrk_smc+1
	sta	DRIVE1_TRACK	;	save track location
slotpatch11:
	lda	$C0d1		;	drive 2 select
	lda	#2
	sta	CURRENT_DRIVE
	lda	DRIVE2_TRACK	;	restore saved track location
	sta	curtrk_smc+1
	rts
.endif

	;=================================
	; check floppy in drive2
	;=================================
	; switches to drive2
	; turns drive on
	; seeks to track0
	; attempts to read a sector
	; if fails, returns C=0
	; if succeeds, returns C=1
	; turns drive off
	; switches back to drive1

check_floppy_in_drive2:

	jsr	switch_drive2

	jsr	driveon		; turn drive on

	; seek to track 0

	lda	#(35*2)		; worst case scenario(?)
	sta	curtrk_smc+1
	lda	#0		; seek to track0
	sta	phase_smc+1

	jsr	seek


	;=====================================
	; try 768 times to find valid sector

	; does this by looking for $D5 $AA $96 sector address header

	ldx	#2
	ldy	#0

check_drive2_loop:
	iny
	bne	keep_trying

	;========================
	; didn't find it in time

	clc				; clear Carry for failure
	dex
	bmi	done_check		; actually done after 3*256

keep_trying:

get_valid_byte:
;	lda	$C0EC			; read byte
	jsr	readnib
	bpl	get_valid_byte		; keep trying if high bit not set

check_if_d5:
	cmp	#$D5			; see if D5 (start of ... )
	bne	check_drive2_loop	; if not, try again

check_if_aa:
;	lda	$C0EC			; read byte
	jsr	readnib
	bpl	check_if_aa		; keep trying until valid
	cmp	#$AA			; see if aa
	bne 	get_valid_byte		; if not try again

check_if_96:
;	lda	$C0EC			; read byte
	jsr	readnib
	bpl	check_if_96		; keep trying until valid
	cmp	#$96			; see if 96
	bne	check_if_d5		; if not try again

	; if we make it here, carry is set
	; because result was greater or equal to #$96

done_check:
	jsr	driveoff

	jmp	switch_drive1		; tail call

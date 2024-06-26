; Spiraling Shape

; o/~ Down, Down, Down You Go o/~

; by Vince `deater` Weaver / DsR

; Lovebyte 2024

; Spiral plus some bass notes in 31 bytes on Apple II

; You can enter it directly onto your Apple II with the following:
; CALL -151
; E9: 20 D8 F3 2C 30 C0 A8 A2  8C A9 60 20 11 F4 A2 DF
; F9: A0 E2 E6 FE A9 01 29 7F  85 E7 20 5D F6 F0 E4
; E9G


; zero page locations
HGR_SCALE	=	$E7
HGR_COLLISION	=	$EA		; overlaps our code, but it's OK
					; as it's modified after the HGR2
					; runs

HGR_ROTATION	=	$FE		; IMPORTANT! set this right!
					; we get this for free by loading
					; our code into $E9 in zero page
; ROM locations
HGR2		=	$F3D8
HPOSN		=	$F411
XDRAW0		=	$F65D

spiraling_shape:
	jsr	HGR2		; Set Hi-resolution  (280x192) mode
				; and clear screen to black0
				;   (purple/green fringes)
				; HGR2 means use PAGE2 ($4000)
				; and no text at bottom

				; Y=0, A=0 after this call

	; A and Y are always 0 here.
	; we can't rely on X (left behind by the boot process?)

tiny_loop:
	bit	$C030		; click the speaker for some sound

	tay			; set Y to 0 (A always 0 here)

	ldx	#140		; center spiral on the screen
				; this is expensive
	lda	#96		; but otherwise doesn't look right

	jsr	HPOSN		; set screen position to xpos= (Y,X) ypos=(A)
				; so xpos = (Y*256)+X, ypos = (A)

				; as side effect saves X,Y,A to zero page
				; after returning Y = orig X/7
				; A and X are ??

	ldx	#<our_shape	; load pointer to $E2DF
	ldy	#>our_shape	;

	inc	HGR_ROTATION	; rotate the line, also make it larger

	lda	#1		; HGR_ROTATION is HERE (zero page $FE)
				; we also use it for scale

	and	#$7f		; cut off before it gets too awful (big)
	sta	HGR_SCALE	; and save as SCALE size

	jsr	XDRAW0		; similar to BASIC's XDRAW 1 AT X,Y

				; XDRAW does an exclusive-or shape table
				; draw (essentially in-ROM scaled vector
				; drawing)
				; XOR so it draws the spiral first, then
				; undraws it on the second pass

				; XDRAW0 entry point expects
				;	shape pointer in X/Y
				;	and rotation in A

				; Both A and X are 0 at exit
				; Z flag set on exit
				; Y varies

	beq	tiny_loop	; bra (branch always)
				; 1 byte shorter than a JMP

	; o/~ No way to stop o/~



our_shape = $E2DF		; location in the Applesoft ROM
				; that holds $11,$F0,$03,$20,$00
				; which makes two offset lines,
				; one up, one down, when
				; interpreted as a shape table
				; (it points into the code for the FRE()
				;  BASIC routine but that's not important)

; For the curious, the patterns was found experimentally
;	(looking for short ROM patterns with a convenient terminating 0)

; NRT = no-draw, move right
; DN  = draw, move down
; etc.
; NOP = do nothing (special case as top 2 bits not enough to hold
;		a full complement of movements)

; $11, $F0, $03, $20, $00 corresponds to

; 0001 0001	=  00 010 001		NRT NDN NOP
; 1111 0000	=  11 110 000		NUP DN  NLT
; 0000 0011	=  00 000 011		NLT NUP NOP
; 0010 0000     =  00 100 000		NUP UP  NOP
; 0000 0000	= end of shape

; x is the starting point, * are the two line segments drawn

;                      ^
;                      *
;                      . x *
;                      . . V

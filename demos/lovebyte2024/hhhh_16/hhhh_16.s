; 16B interesting XDRAW pattern

; it starts out sorta looking like hhhh?  Or is it just me?

; by Vince `deater` Weaver / dSr

; for Lovebyte 2024

; zero page locations
GBASL		=	$26
GBASH		=	$27
HGR_SCALE	=	$E7
HGR_COLLISIONS	=	$EA

; ROM locations
HGR2		=	$F3D8
HPOSN		=	$F411
XDRAW0		=	$F65D
XDRAW1		=	$F661
HPLOT0          =       $F457

field15:

	; we load at zero page $E7 which is HGR_SCALE
	; this means the scale is $20 (JSR)

	; $20 $D8 $F3

	jsr	HGR2		; Hi-res, full screen		; 3
				; Y=0, A=0 after this call

	; A and Y are 0 here.
	; X is left behind by the boot process?

	; set GBASL/GBASH
	; we really have to call this, otherwise it won't run
	; on some real hardware depending on setup of zero page at boot

	jsr	HPLOT0		; set screen position to X= (y,x) Y=(a)
				; saves X,Y,A to zero page
				; after Y= orig X/7
				; A and X are ??
tiny_loop:

	lda	#$E3		; ROT=$E3
	tay			;
	dey			; Y=$E2
	tax			; X=$E3

	jsr	XDRAW0		; XDRAW, A =ROTATE, X/Y = point to shape
				; Both A and X are 0 at exit
				; Z flag set on exit
				; Y varies

	beq	tiny_loop	; bra


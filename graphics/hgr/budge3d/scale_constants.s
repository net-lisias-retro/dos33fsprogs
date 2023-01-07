;
; Math constants for scaling.
;
; Each table has 16 sets of 16 entries, with one set for each of the 16 possible
; scale values.  The values within a set determine how one 4-bit nibble of the
; coordinate is scaled.
;
; Suppose you want to scale the value 100 ($64) by scale factor 8 (a bit over
; half size).  We begin by using self-modifying code to select the table
; subsets.  This is done in a clever way to avoid shifting.  The instructions
; that load from ScaleTabLo are modified to reference $1800, $1810, $1820, and
; so on.  The instructions that load from ScaleTabHi reference $1900, $1901,
; $1902, etc.  The offset comes from the two 16-byte ScaleIndex tables.  For a
; scale factor of 8, we'll be using $1880 and $1908 as the base addresses.
;
; To do the actual scaling, we mask to get the low part of the value ($04) and
; index into ScaleTabLo, at address $1884.  We mask the high part of the value
; ($60) and index into ScaleTabHi, at $1968.  We add the values there ($02, $36)
; to get $38 = 56, which is just over half size as expected.
;
; This is an approximation, but so is any integer division, and it's done in
; 512+32=544 bytes instead of the 16*256=4096 bytes that you'd need for a fully-
; formed scale.  For hi-res graphics it's certainly good enough.
;
;   32 = $20 = ($1880)+($1928) = 0+18 = 18 (.563)
;   40 = $28 = ($1888)+($1928) = 22 (.55)
;   47 = $2F = ($188F)+($1928) = 26 (.553)
;   48 = $30 = ($1880)+($1938) = 27 (.563)
;  100 = $64 = ($1884)+($1968) = 56 (.56)
;

ScaleTabLo:
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
.byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
.byte $00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03
.byte $00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04
.byte $00,$00,$00,$01,$01,$01,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
.byte $00,$00,$00,$01,$01,$02,$02,$03,$03,$03,$04,$04,$05,$05,$06,$06
.byte $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
.byte $00,$00,$01,$01,$02,$02,$03,$03,$04,$05,$05,$06,$06,$07,$07,$08
.byte $00,$00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$06,$07,$08,$08,$09
.byte $00,$00,$01,$02,$02,$03,$04,$04,$05,$06,$06,$07,$08,$08,$09,$0a
.byte $00,$00,$01,$02,$03,$03,$04,$05,$06,$06,$07,$08,$09,$09,$0a,$0b
.byte $00,$00,$01,$02,$03,$04,$04,$05,$06,$07,$08,$08,$09,$0a,$0b,$0c
.byte $00,$00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0a,$0b,$0c,$0d
.byte $00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e
.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f

ScaleTabHi:
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10
.byte $02,$04,$06,$08,$0a,$0c,$0e,$10,$12,$14,$16,$18,$1a,$1c,$1e,$20
.byte $03,$06,$09,$0c,$0f,$12,$15,$18,$1b,$1e,$21,$24,$27,$2a,$2d,$30
.byte $04,$08,$0c,$10,$14,$18,$1c,$20,$24,$28,$2c,$30,$34,$38,$3c,$40
.byte $05,$0a,$0f,$14,$19,$1e,$23,$28,$2d,$32,$37,$3c,$41,$46,$4b,$50
.byte $06,$0c,$12,$18,$1e,$24,$2a,$30,$36,$3c,$42,$48,$4e,$54,$5a,$60
.byte $07,$0e,$15,$1c,$23,$2a,$31,$38,$3f,$46,$4d,$54,$5b,$62,$69,$70
.byte $f8,$f0,$e8,$e0,$d8,$d0,$c8,$c0,$b8,$b0,$a8,$a0,$98,$90,$88,$80
.byte $f9,$f2,$eb,$e4,$dd,$d6,$cf,$c8,$c1,$ba,$b3,$ac,$a5,$9e,$97,$90
.byte $fa,$f4,$ee,$e8,$e2,$dc,$d6,$d0,$ca,$c4,$be,$b8,$b2,$ac,$a6,$a0
.byte $fb,$f6,$f1,$ec,$e7,$e2,$dd,$d8,$d3,$ce,$c9,$c4,$bf,$ba,$b5,$b0
.byte $fc,$f8,$f4,$f0,$ec,$e8,$e4,$e0,$dc,$d8,$d4,$d0,$cc,$c8,$c4,$c0
.byte $fd,$fa,$f7,$f4,$f1,$ee,$eb,$e8,$e5,$e2,$df,$dc,$d9,$d6,$d3,$d0
.byte $fe,$fc,$fa,$f8,$f6,$f4,$f2,$f0,$ee,$ec,$ea,$e8,$e6,$e4,$e2,$e0
.byte $ff,$fe,$fd,$fc,$fb,$fa,$f9,$f8,$f7,$f6,$f5,$f4,$f3,$f2,$f1,$f0

;
; Indexes into the rotation tables.  One entry for each rotation value (0-27). 
; The "low" and "high" tables have the same value at each position, just shifted
; over 4 bits.
;
; Mathematically, cosine has the same shape as sine, but is shifted by PI/2 (one
; quarter period) ahead of it.  That's why there are two sets of tables, one of
; which is shifted by 7 bytes.
;
; See the comments above RotTabLo for more details.
;

RotIndexLo_sin:
	.byte $70,$60,$50,$40,$30,$20,$10,$00
	.byte $10,$20,$30,$40,$50,$60,$70,$80
	.byte $90,$a0,$b0,$c0,$d0,$e0,$d0,$c0
	.byte $b0,$a0,$90,$80

RotIndexHi_sin:
	.byte $07,$06,$05,$04,$03,$02,$01,$00
	.byte $01,$02,$03,$04,$05,$06,$07,$08
	.byte $09,$0a,$0b,$0c,$0d,$0e,$0d,$0c
	.byte $0b,$0a,$09,$08

RotIndexLo_cos:
	.byte $00,$10,$20,$30,$40,$50,$60,$70
	.byte $80,$90,$a0,$b0,$c0,$d0,$e0,$d0
	.byte $c0,$b0,$a0,$90,$80,$70,$60,$50
	.byte $40,$30,$20,$10

RotIndexHi_cos:
	.byte $00,$01,$02,$03,$04,$05,$06,$07
	.byte $08,$09,$0a,$0b,$0c,$0d,$0e,$0d
	.byte $0c,$0b,$0a,$09,$08,$07,$06,$05
	.byte $04,$03,$02,$01

;
; Indexes into the scale tables.  One entry for each scale value (0-15).  See
; the comments above ScaleTabLo for more details.
;
ScaleIndexLo:
	.byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0

ScaleIndexHi:
	.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f

;
; Junk, pads to end of 256-byte page.
.align  $0100


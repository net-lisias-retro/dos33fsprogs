	.byte SET_COLOR | LIGHT_BLUE
	.byte BOX,4,6,30,30
	.byte BOX_ADD_LSAME,19,41 ; 4, 31
	.byte SET_COLOR | BROWN
	.byte BOX,19,8,35,27
	.byte HLIN,19,26,6
	.byte 31,32,6
	.byte HLIN_ADD,19,25	; 7
	.byte HLIN,28,32,7
	.byte 19,34,28
	.byte HLIN_ADD_LSAME,33 ; 19, 33, 29
	.byte 31
	.byte 29
	.byte 27
	.byte 26
	.byte 24
	.byte 22
	.byte HLIN,20,21,36
	.byte SET_COLOR | WHITE
	.byte BOX,4,6,22,11
	.byte 4,13,21,14
	.byte 4,16,19,26
	.byte HLIN,4,20,12
	.byte 4,20,15
	.byte 4,15,27
	.byte HLIN_ADD_LSAME,13 ; 4, 13, 28
	.byte 10
	.byte 8
	.byte 5
	.byte PLOT,28,7
	.byte SET_COLOR | GREEN
	.byte BOX,23,17,29,19
	.byte 20,38,35,41
	.byte 25,14,28,15
	.byte HLIN,26,27,13
	.byte 24,28,16
	.byte 32,35,31
	.byte HLIN_ADD_RSAME,30	; 30 35 32
	.byte 28	; 28 35 33
	.byte 27	; 27 35 34
	.byte 25	; 25 35 35
	.byte 23	; 23 35 36
	.byte 21	; 21 35 37
	.byte HLIN,34,35,30
	.byte SET_COLOR | LIGHT_GREEN
	.byte BOX,24,20,29,22
	.byte HLIN,27,29,17
	.byte HLIN_ADD_RSAME,26	; 26 29 18
	.byte 25	; 25 29 19
	.byte HLIN,24,27,23
	.byte HLIN_ADD_LSAME,25 ; 24, 25, 24
	.byte HLIN,18,19,26
	.byte VLIN,21,25,19
	.byte 15,16,28
	.byte PLOT,18,27
	.byte SET_COLOR | DARK_BLUE
	.byte BOX,33,6,35,12
	.byte BOX_ADD_RSAME,34,18
	.byte VLIN,19,24,35
	.byte SET_COLOR | PINK
	.byte 7,12,22
	.byte 13,18,23
	.byte 26,31,25
	.byte 21,25,24
	.byte 32,33,26
	.byte SET_COLOR | MEDIUM_BLUE
	.byte BOX,22,27,23,30
	.byte 21,20,22,22
	.byte VLIN,29,32,19
	.byte 13,14,21
	.byte PLOT,21,19
	.byte SET_COLOR | ORANGE
	.byte VLIN,26,31,28
	.byte 23,25,27
	.byte SET_COLOR | GREY1
	.byte HLIN,24,26,6
	.byte END
; total size = 207
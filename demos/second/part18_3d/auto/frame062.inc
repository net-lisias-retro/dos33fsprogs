	.byte SET_COLOR | BROWN
	.byte BOX,13,6,35,34
	.byte BOX_ADD_RSAME,27,41
	.byte SET_COLOR | DARK_BLUE
	.byte BOX,4,6,17,16
	.byte BOX_ADD_LSAME,12,21 ; 4, 17
	.byte BOX,14,17,17,18
	.byte 4,22,17,38
	.byte 15,19,17,40
	.byte HLIN,4,10,39
	.byte HLIN_ADD_LSAME,6 ; 4, 6, 40
	.byte SET_COLOR | GREEN
	.byte BOX,8,23,18,31
	.byte BOX_ADD,9,17,38	; 32
	.byte BOX,12,35,17,39
	.byte HLIN,11,17,22
	.byte 11,17,40
	.byte HLIN_ADD_LSAME,16 ; 11, 16, 41
	.byte HLIN,15,17,21
	.byte PLOT,16,20
	.byte SET_COLOR | MEDIUM_BLUE
	.byte BOX,8,6,17,14
	.byte 20,6,25,18
	.byte 31,6,32,9
	.byte 8,17,12,21
	.byte 32,18,33,24
	.byte 20,19,26,25
	.byte BOX_ADD_RSAME,21,34
	.byte BOX,32,33,34,36
	.byte BOX_ADD,9,18,38	; 37
	.byte BOX,33,37,34,38
	.byte HLIN,8,15,15
	.byte HLIN_ADD_LSAME,13 ; 8, 13, 16
	.byte HLIN,8,10,22
	.byte HLIN_ADD_LSAME,9 ; 8, 9, 23
	.byte HLIN,32,33,32
	.byte 9,10,36
	.byte VLIN,24,26,8
	.byte PLOT,31,10
	.byte 33,17
	.byte 9,35
	.byte SET_COLOR | LIGHT_GREEN
	.byte BOX,15,31,19,32
	.byte 12,35,19,36
	.byte BOX_ADD_LSAME,18,38 ; 12, 37
	.byte BOX,13,39,18,40
	.byte 17,28,19,29
	.byte HLIN,16,19,30
	.byte 14,18,33
	.byte HLIN_ADD,13,19	; 34
	.byte HLIN,13,16,41
	.byte 18,19,27
	.byte VLIN,25,26,18
	.byte SET_COLOR | PINK
	.byte BOX,11,6,17,14
	.byte 11,17,12,18
	.byte HLIN,11,15,15
	.byte HLIN_ADD_LSAME,13 ; 11, 13, 16
	.byte VLIN,19,21,12
	.byte SET_COLOR | GREY1
	.byte BOX,8,11,12,12
	.byte HLIN,24,26,33
	.byte HLIN_ADD_RSAME,22	; 22 26 34
	.byte HLIN,19,24,35
	.byte 23,27,37
	.byte HLIN_ADD,21,28	; 38
	.byte HLIN_ADD_RSAME,22	; 22 28 39
	.byte 23	; 23 28 40
	.byte 24	; 24 28 41
	.byte HLIN,19,20,36
	.byte VLIN,10,13,11
	.byte 37,38,11
	.byte PLOT,19,34
	.byte 26,36
	.byte SET_COLOR | LIGHT_BLUE
	.byte BOX,11,11,12,13
	.byte HLIN,8,9,13
	.byte PLOT,8,10
	.byte 8,12
	.byte 12,14
	.byte SET_COLOR | GREY2
	.byte HLIN,9,10,39
	.byte PLOT,10,38
	.byte SET_COLOR | RED
	.byte HLIN,11,12,12
	.byte SET_COLOR | ORANGE
	.byte PLOT,9,11
	.byte 16,41
	.byte END
; total size = 283
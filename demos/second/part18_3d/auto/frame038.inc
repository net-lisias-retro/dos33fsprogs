	.byte SET_COLOR | BROWN
	.byte BOX,12,6,35,41
	.byte SET_COLOR | GREY1
	.byte 14,22,23,24
	.byte BOX_ADD_RSAME,19,33
	.byte BOX,10,27,13,28
	.byte 10,30,15,31
	.byte BOX_ADD,11,16,33	; 32
	.byte BOX,11,35,23,36
	.byte BOX_ADD_RSAME,12,41
	.byte BOX,4,25,5,27
	.byte HLIN,18,23,21
	.byte 7,12,25
	.byte HLIN_ADD_RSAME,9	; 9 12 26
	.byte HLIN,10,14,29
	.byte 11,17,34
	.byte 4,6,23
	.byte VLIN,29,31,4
	.byte PLOT,9,23
	.byte SET_COLOR | LIGHT_BLUE
	.byte BOX,4,6,11,22
	.byte 19,25,22,27
	.byte HLIN,18,22,21
	.byte HLIN_ADD_RSAME,14	; 14 22 22
	.byte HLIN,14,21,23
	.byte HLIN_ADD_LSAME,19 ; 14, 19, 24
	.byte HLIN,19,23,34
	.byte 7,8,25
	.byte PLOT,21,28
	.byte SET_COLOR | DARK_BLUE
	.byte BOX,9,6,11,22
	.byte HLIN,10,11,23
	.byte 19,21,25
	.byte 18,19,23
	.byte PLOT,22,24
	.byte SET_COLOR | WHITE
	.byte BOX,19,18,23,20
	.byte 19,13,22,17
	.byte HLIN,21,22,12
	.byte SET_COLOR | MEDIUM_BLUE
	.byte BOX,14,10,16,14
	.byte 14,21,16,24
	.byte HLIN,15,16,9
	.byte 14,15,20
	.byte 15,16,25
	.byte PLOT,16,8
	.byte 14,15
	.byte 16,26
	.byte SET_COLOR | GREY2
	.byte HLIN,20,22,21
	.byte 19,20,25
	.byte VLIN,25,27,4
	.byte 26,27,19
	.byte PLOT,22,22
	.byte 20,28
	.byte 4,32
	.byte SET_COLOR | RED
	.byte HLIN,21,22,26
	.byte PLOT,20,25
	.byte SET_COLOR | ORANGE
	.byte 19,24
	.byte END
; total size = 192
	.byte SET_COLOR | BROWN
	.byte BOX,12,6,35,31
	.byte BOX_ADD_RSAME,27,41
	.byte SET_COLOR | DARK_BLUE
	.byte BOX,4,6,17,11
	.byte BOX_ADD_LSAME,12,13 ; 4, 12
	.byte 11,18
	.byte 17,36
	.byte BOX,14,12,17,18
	.byte SET_COLOR | GREEN
	.byte 8,21,18,28
	.byte BOX_ADD_RSAME,7,30
	.byte BOX,8,31,17,32
	.byte BOX_ADD_RSAME,9,36
	.byte HLIN,10,13,19
	.byte 15,17,19
	.byte HLIN_ADD_RSAME,9	; 9 17 20
	.byte HLIN,10,17,38
	.byte HLIN_ADD,7,18	; 39
	.byte HLIN_ADD_RSAME,4	; 4 18 40
	.byte HLIN,4,19,41
	.byte 15,16,18
	.byte PLOT,16,17
	.byte SET_COLOR | MEDIUM_BLUE
	.byte BOX,7,6,17,10
	.byte 20,6,25,9
	.byte BOX_ADD_LSAME,26,25 ; 20, 10
	.byte BOX,8,14,11,18
	.byte 32,14,34,15
	.byte BOX_ADD_RSAME,33,21
	.byte BOX,21,28,26,31
	.byte 9,35,18,36
	.byte 33,30,34,35
	.byte HLIN,32,33,6
	.byte 7,15,11
	.byte HLIN_ADD_LSAME,12 ; 7, 12, 12
	.byte HLIN,8,12,13
	.byte 17,26,26
	.byte HLIN_ADD_RSAME,16	; 16 26 27
	.byte HLIN,8,9,19
	.byte VLIN,20,21,8
	.byte PLOT,33,29
	.byte 34,36
	.byte SET_COLOR | LIGHT_GREEN
	.byte BOX,16,27,19,28
	.byte BOX_ADD_RSAME,15,30
	.byte BOX,10,35,18,36
	.byte 11,38,18,39
	.byte 17,24,18,25
	.byte HLIN,14,19,31
	.byte HLIN_ADD_RSAME,13	; 13 19 32
	.byte 12	; 12 19 33
	.byte HLIN,11,18,34
	.byte 12,18,37
	.byte 10,16,40
	.byte HLIN_ADD_LSAME,15 ; 10, 15, 41
	.byte HLIN,17,19,26
	.byte VLIN,22,23,18
	.byte SET_COLOR | GREY1
	.byte HLIN,8,17,10
	.byte HLIN_ADD_LSAME,15 ; 8, 15, 11
	.byte HLIN,23,26,30
	.byte HLIN_ADD_RSAME,20	; 20 26 31
	.byte HLIN,19,23,32
	.byte 23,27,34
	.byte HLIN_ADD,20,29	; 35
	.byte HLIN_ADD_RSAME,21	; 21 29 36
	.byte HLIN,7,10,36
	.byte HLIN_ADD,23,29	; 37
	.byte HLIN,4,6,37
	.byte HLIN_ADD,24,29	; 38
	.byte HLIN_ADD_RSAME,25	; 25 29 39
	.byte 26	; 26 29 40
	.byte HLIN,27,31,41
	.byte 19,20,33
	.byte VLIN,9,10,9
	.byte PLOT,26,29
	.byte 26,33
	.byte SET_COLOR | PINK
	.byte BOX,11,6,17,9
	.byte HLIN,13,17,10
	.byte HLIN_ADD,11,15	; 11
	.byte VLIN,14,18,11
	.byte SET_COLOR | LIGHT_BLUE
	.byte HLIN,8,9,10
	.byte HLIN_ADD,11,12	; 11
	.byte HLIN_ADD_RSAME,10	; 10 12 12
	.byte 11	; 11 12 13
	.byte VLIN,8,9,8
	.byte 10,11,11
	.byte PLOT,8,11
	.byte SET_COLOR | RED
	.byte 8,9
	.byte 11,11
	.byte 12,12
	.byte SET_COLOR | ORANGE
	.byte 9,10
	.byte 15,41
	.byte END
; total size = 298
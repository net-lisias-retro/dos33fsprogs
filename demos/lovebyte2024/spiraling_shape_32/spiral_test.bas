10 HIMEM:8167
20 POKE 232,231:POKE 233,31
30 FOR L=8167 TO 8175: READ B:POKE L,B:NEXT L
35 HGR:ROT=0:SCALE=2
40 FOR I=1 TO 1: XDRAW I AT I*10,100:NEXT I
90 END
100 DATA 1,0,4,0,17,240,3,32,0

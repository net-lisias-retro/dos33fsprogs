1 GOTO 10
5 SPEED=$)%DEL$LRUSR
10 HGR2:HCOLOR=7
20 FOR X=0 TO 255
30 POKE 2062,X
35 Q=X:IF Q>191 THEN Q=191
40 FOR Y=0 TO Q
50 POKE 2064,Y:CALL 2061
60 HPLOT X-Y,PEEK(36)
70 NEXT Y,X
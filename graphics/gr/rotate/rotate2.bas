5 GR
10 FOR Y=0 TO 16:COLOR=Y+1:HLIN12,28AT(Y*2)+4:HLIN12,28AT(Y*2)+5:NEXT
15 INPUT R
20 A=(R*3.14159265)/180:T=TAN(A/2):S=SIN(A)
30 GOSUB 1000
130 FOR X=0 TO 39:O=(X-20)*S:IF O<0 GOTO 160
150 FOR Y=0 TO 47:C=0:IF ((Y+O)>0) AND ((Y+O)<47) THEN C=SCRN(X,Y+O)
155 GOTO 170
160 FOR Y=47 TO 0 STEP -1:C=0:IF ((Y+O)>0) AND ((Y+O)<47) THEN C=SCRN(X,Y+O)
170 COLOR=C:PLOT X,Y:NEXT Y,X
200 GOSUB 1000
300 END
1000 FOR Y=0 TO 47:O=-(Y-24)*T:IF O<0 GOTO 1030
1010 FOR X=0 TO 39:C=0:IF ((X+O)>0) AND ((X+O)<39) THEN C=SCRN(X+O,Y)
1020 GOTO 1040
1030 FOR X=39 TO 0 STEP -1:C=0:IF ((X+O)>0) AND ((X+O)<39) THEN C=SCRN(X+O,Y)
1040 COLOR=C:PLOT X,Y:NEXT X,Y:RETURN

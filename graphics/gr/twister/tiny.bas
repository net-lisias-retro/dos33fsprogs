0DIMA(1280),B(1280):GR:P=3.14:FORE=0TOP*2STEP.1:?J
1M=120+COS(E)*100:N=P-SIN(E)*P:FORY=0TO19:J=J+1
2F=Y*8/M-N:A(J)=8*SIN(F):B(J)=8*SIN(F+P/2):NEXTY,E
3J=0:FORI=1TO63:FORY=0TO19:J=J+1:S=20-A(J):T=20-B(J):Q=20+A(J):R=20+B(J)
4COLOR=0:HLIN12,27ATY:COLOR=1:U=S:V=T:IFQ<RTHENU=Q:V=R
6HLINU,VATY:COLOR=2:IFR<STHENT=R:Q=S
8HLINT,QATY:NEXTY,I:GOTO3

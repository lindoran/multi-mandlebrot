10 GOSUB1000
100 POKE65495,0
110 FORPY=0TO21
120 FORPX=0TO31
130 XZ=PX*3.5/32-2.5
140 YZ=PY*2/22-1
150 X=0
160 Y=0
170 FORI=0TO14
180 IFX*X+Y*Y>4THEN230
190 XT=X*X-Y*Y+XZ
200 Y=2*X*Y+YZ
210 X=XT
220 NEXTI
230 GOSUB2000
240 NEXTPX
250 NEXTPY
260 POKE65494,0
270 END
1000 PMODE4,1:PCLS1:SCREEN1,1
1010 A=PEEK(65314):POKE65314,A AND7
1020 POKE65477,0:POKE65475,0:POKE65472,0
1030 DIMV(15):I=0:SC=&H0E00:REM ECB &H0600
1040 READV:IFV<0THENRETURN
1050 V(I)=V:I=I+1:GOTO1040
2000 L=SC+PX+PY*256:V=V(I)
2010 FORX=0TO224STEP32
2020 POKEL+X,V
2030 NEXTX
2040 RETURN
3000 DATA 143,159,175,191,207,223,239,255
3010 DATA 143,159,175,191,207,32,96,128,-1

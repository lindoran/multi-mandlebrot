10 SCREEN 0
100 FOR PY=0 TO 21
110 FOR PX=0 TO 31
120 XZ = PX*3.5/32-2.5
130 YZ = PY*2/22-1
140 X = 0
150 Y = 0
160 FOR I=0 TO 14
170 IF X*X+Y*Y > 4 THEN GOTO 215
180 XT = X*X - Y*Y + XZ
190 Y = 2*X*Y + YZ
200 X = XT
210 NEXT I
215 I = I-1
230 VPOKE 0,PY*256+PX*2+1,I*16
240 NEXT PX
250 PRINT ""
260 NEXT PY
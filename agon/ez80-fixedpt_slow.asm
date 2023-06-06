; FP Registers:
;  FP_A: BC
;  FP_B: DE
;  FP_C: HL
;  FP_R: (IX)

fp_remainder:
   dw 0
   db 0

fp_i: ; loop index
   db 0

fp_scratch:
   dw 0
   db 0

   MACRO FP_LDA_BYTE source
      ld b,source
      ld c,0
   ENDMACRO

   MACRO FP_LDB_BYTE source
      ld d,source
      ld e,0
   ENDMACRO

   MACRO FP_LDA_BYTE_IND address
      ld a,(address)
      ld b,a
      ld c,0
   ENDMACRO

   MACRO FP_LDB_BYTE_IND address
      ld a,(address)
      ld d,a
      ld e,0
   ENDMACRO

   MACRO FP_LDA source
      ld bc,source
   ENDMACRO

   MACRO FP_LDB source
      ld de,source
   ENDMACRO

   MACRO FP_LDA_IND address
      ld bc,(address)
   ENDMACRO

   MACRO FP_LDB_IND address
      ld de,(address)
   ENDMACRO

   MACRO FP_STC dest
      ld (dest),hl
   ENDMACRO

fp_floor_byte: ; A = floor(FP_C)
   ld a,h
   bit 7,a
   ret.l z
   ld a,0
   cp l
   ld a,h
   ret.l z
   dec a
   ret.l

fp_floor: ; FP_C = floor(FP_C)
   bit 7,h
   jp z,@zerofrac
   ld a,0
   cp l
   ret.l z
   dec h
@zerofrac:
   ld l,0
   ret.l

   MACRO FP_TCA ; FP_A = FP_C
      ld b,h
      ld c,l
   ENDMACRO

   MACRO FP_TCB ; FP_B = FP_C
      ld d,h
      ld e,l
   ENDMACRO

   MACRO FP_SUBTRACT ; FP_C = FP_A - FP_B
      ld h,b
      ld l,c
      or a
      sbc.s hl,de
   ENDMACRO

   MACRO FP_ADD ; FP_C = FP_A + FP_B
      ld h,b
      ld l,c
      add.s hl,de
   ENDMACRO

fp_divide: ; FP_C = FP_A / FP_B; FP_REM = FP_A % FP_B
   push de              ; preserve FP_B
   bit 7,b
   jp nz,@abs_a         ; get |FP_A| if negative
   ld h,b
   ld l,c               ; FP_C = FP_A
   jp @check_sign_b
@abs_a:
   ld hl,0
   or a
   sbc.s hl,bc            ; FP_C = |FP_A|
@check_sign_b:
   bit 7,d
   jp z,@shift_b
   push hl              ; preserve FP_C
   ld hl,0
   or a
   sbc.s hl,de
   ld d,h
   ld e,l               ; FP_B = |FP_B|
   pop hl               ; restore FP_C
@shift_b:
   ld e,d
   ld d,0
   ld ix,fp_remainder
   ld (ix),d
   ld (ix+1),d          ; FP_R = 0
   push bc              ; preserve FP_A
   ld b,16
@loop1:
   sla l                ; Shift hi bit of FP_C into REM
   rl h
   rl (ix)
   rl (ix+1)
   ld a,(ix)
   sub e                ; trial subtraction
   ld c,a
   ld a,(ix+1)
   sbc a,d
   jp c,@loop2          ; Did subtraction succeed?
   ld (ix),c            ; if yes, save it
   ld (ix+1),a
   inc l                ; and record a 1 in the quotient
@loop2:
   dec b
   jp nz,@loop1
   pop bc               ; restore FP_A
   pop de               ; restore FP_B
   bit 7,d
   jp nz,@check_cancel
   bit 7,b
   ret.l z
   jp @negative
@check_cancel:
   bit 7,b
   ret.l nz
@negative:
   push bc
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc.s hl,bc
   pop bc
   ret.l

fp_multiply: ; FP_C = FP_A * FP_B; FP_R overflow
   push bc              ; preserve FP_A
   push de              ; preserve FP_B
   bit 7,b
   jp z,@check_sign_b
   ld hl,0
   or a
   sbc hl,bc
   FP_TCA               ; FP_A = |FP_A|
@check_sign_b:
   bit 7,d
   jp z,@init_c
   ld hl,0
   or a
   sbc hl,de
   FP_TCB               ; FP_B = |FP_B|
@init_c:
   ld hl,0              ; fp_scratch in register H'
   exx                  ; fp_remainder in register L'
   ld hl,0
   exx                  ; switch to primary registers set
   ld a,16              ; fp_i in register A
@loop1:
   srl d
   rr e
   jp nc,@loop2
   add hl,bc
@loop2:
   rr h
   rr l
   exx                  ; switch to alternative registers set
   rr h
   rr l
   exx                  ; switch to primary registers set
   dec a
   jp nz,@loop1
   ld a,l
   exx                  ; switch to alternative registers set
   ld e,a               ; we don't values in primary set anymore
   ld d,0               ; so will use alternative set as primary
   ld b,8            ; register B as loop counter
@loop3:
   srl d
   rr e
   rr h
   rr l
   djnz @loop3       ; decrement and loop
   pop de            ; restore FP_B
   pop bc            ; restore FP_A
   bit 7,d
   jp nz,@check_cancel
   bit 7,b
   ret.l z
   jp @negative
@check_cancel:
   bit 7,b
   ret.l nz
@negative:
   push bc           ; preserve FP_A
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc hl,bc
   pop bc            ; restore FP_A
   ret.l
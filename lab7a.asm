cpu "8051.tbl"
incl "8051.inc"
;INCL "LCD_LIB.ASM"

RS: EQU P1_0
RW: EQU P1_1
EN: EQU P1_2 
U: EQU 60H
L: EQU 61H

org 2000h

mov a,#80h
mov dptr,#4003h
movx @dptr,a 

mov tmod,#01
here:
mov tl0,#0f2h 
mov th0,#0ffh
cpl p1.5
acall delay
sjmp here

delay:
setb tr0
jnb tf0, $
clr tr0
clr tf0
ret
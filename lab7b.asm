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
mov ie,#10000001b 
mov tmod,#01

main:
mov r7,#120
cpl p1.4
djnz r7,$


jmp main

delay:
 setb tr0
jnb tf0, $
clr tr0
clr tf0

ret


isr:

mov tl0,#0f2h 
mov th0,#0ffh
cpl p1.4
acall delay

reti


ORG 3ff0h

ljmp isr

end
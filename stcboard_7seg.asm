;7seg
;active low
;p2.0 ~ p2.3

;a=p0.0 ~ g=p0.6 logic 0 = turn ON segmen


tenms  equ 51h	
msten  equ 50h


org 0000h
     
ljmp main

org 0100h

main:
mov sp,#30h
mov p2,#0ffh

start:
mov p0,#11111001b

clr p2.0

call delay1s
setb p2.0

mov p0,#10100100b
clr p2.1
call delay1s
setb p2.1

mov p0,#10110000b
clr p2.2
call delay1s
setb p2.2

mov p0,#10011001b
clr p2.3
call delay1s
setb p2.3



sjmp start



jmp main

;========
delay1ms:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret     
;===============

delay10ms:

mov msten,#10          ;1 mc
_dly10ms:
call delay1ms
djnz msten,_dly10ms         ;2 mc   need 921.66
ret                   ; 1 mc
;==========
delay1s:
mov tenms,#90
_delay1s:
call delay10ms
djnz tenms,_delay1s
ret

;===========  
segments:
db 11000000b
db 11111001b
db 10100100b
db 10110000b
db 10011001b
db 10010010b
db 10000010b
db 11111000b
db 10000000b
db 10010000b


END
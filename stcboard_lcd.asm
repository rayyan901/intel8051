  
; lcd 4 bit mode interface, d4~d7 ==> p2.4~P2.7
d7 bit p0.7
d6 bit p0.6
d5 bit p0.5
d4 bit p0.4

RS bit P2.0    ;RS=P2.3
RW bit P2.1 ;  or connect to gnd
EN bit P2.2    ;EN=P2_2	



lcd_port equ P2
tenms  equ 51h	
msten  equ 50h
TEMP DATA 60H
COUNTER EQU 52H

org 0000h
     
ljmp 0100h

org 0100h

mov sp,#30h     
     
CLR RW
CALL INIT         

mov a,#80h  
call LCDCMD
              
MOV DPTR,#TEXT
CALL DISP        

mov a,#0C5h
call LCDCMD

mov a,#"U"
call LCDDATA

mov a,#"P"
call LCDDATA

mov a,#"1"
call LCDDATA

count:
MOV COUNTER,#30H
DISPCOUNT:
	MOV A,#0C9H
	CALL LCDCMD
	MOV A,COUNTER
	CALL LCDDATA
	CALL DELAY1S
INC COUNTER
MOV A,COUNTER
CJNE A, #3AH,DISPCOUNT
JMP COUNT


JMP $

DISP:
CLR A
MOVC A,@A+DPTR
CJNE A,#0,DIS
RET
DIS:
PUSH DPH
PUSH DPL
CALL LCDDATA
POP DPL
POP DPH
INC DPTR
JMP DISP

TEXT: DB "STC 89c52RC LCD",0


;====================================
LCDCMD:
MOV TEMP,A
ANL A,#0F0H
ORL A,#00000100B   ; RS=0 EN=1
;MOV P2,A
call sendLcd
CALL delay1ms
ANL A,#0F0H	        ; RS=0 EN=0
;MOV P2,A
call sendLcd
CALL DELAY1MS

MOV A,TEMP
SWAP A
ANL A,#0F0H
ORL A,#00000100B   ;RS=0 EN=1
;MOV P2,A
call sendLcd
CALL delay1ms
ANL A,#0F0H	       ;RS=0 EN=0
;MOV P2,A
call sendLcd
CALL DELAY1MS
RET
;===============
LCDDATA:
MOV TEMP,A
ANL A,#0F0H
ORL A,#00001100B   ; RS=1 EN=1
;MOV P2,A
CALL sendLcd
CALL delay1ms
ANL A,#11111000B	; RS=1 EN=0
;MOV P2,A
call sendLcd
CALL DELAY1MS

MOV A,TEMP
SWAP A
ANL A,#0F0H
ORL A,#00001100B   ;RS=1 EN=1
;MOV P2,A
call sendLcd
CALL delay1ms
ANL A,#11111000B	;RS=1 EN=0
;MOV P2,A
call sendLcd
CALL DELAY1MS
RET
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

;====
sendLcd:
push acc
RLC A
MOV D7,C
RLC A
MOV D6,C
RLC A
MOV D5,C
RLC A
MOV D4,C
RLC A
MOV RS,C
RLC A
MOV EN,C
RLC A
MOV RW,C
pop acc
RET
;=======
;======
INIT:

call delay10ms
MOV A,#2H
CALL LCDCMD
MOV A,#28H
CALL LCDCMD
MOV A,#28H
CALL LCDCMD
MOV A,#28H
CALL LCDCMD
MOV A,#0CH
CALL LCDCMD
MOV A,#06H
CALL LCDCMD
MOV A,#01H
CALL LCDCMD
RET

 ;========

 ;==============================================           
end
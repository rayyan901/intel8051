
  
; lcd 4 bit mode interface, d4~d7 ==> p2.0~P2.3


RS EQU P2.4    ;0A4H  ;RS=P2.4
EN EQU P2.5  ;0A6H  ;EN: EQU P2_6 	
RW EQU P2.6 ;  or connect to gnd


TEMP DATA 60H

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

TEXT: DB "KEIL 89s52 LCD",0

delay1ms:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret     
;===============
LCDCMD:
MOV TEMP,A
SWAP A
ANL A,#0FH
ORL A,#00100000B   ;EN=1, RS =0
MOV P2,A
CALL delay1ms
ANL A,#00001111B	;EN=0, RS =0
MOV P2,A
CALL DELAY1MS

MOV A,TEMP
ANL A,#0FH
ORL A,#00100000B   ;EN=1, RS =0
MOV P2,A
CALL delay1ms
ANL A,#00001111B	;EN=0, RS =0
MOV P2,A
CALL DELAY1MS
RET
;===============
LCDDATA:
MOV TEMP,A
SWAP A
ANL A,#0FH
ORL A,#00110000B   ;EN=1, RS =1
MOV P2,A
CALL delay1ms
ANL A,#00011111B	;EN=0, RS =1
MOV P2,A
CALL DELAY1MS

MOV A,TEMP
ANL A,#0FH
ORL A,#00110000B   ;EN=1, RS =1
MOV P2,A
CALL delay1ms
ANL A,#00011111B	;EN=0, RS =0
MOV P2,A
CALL DELAY1MS
RET
;========
   
INIT:

CALL delay1ms
CALL delay1ms

MOV A,#02H
MOV P2,A
CLR RS

SETB EN
CALL delay1ms
CLR EN
CALL delay1ms 

SETB EN
CALL delay1ms
CLR EN
CALL delay1ms

SETB EN
CALL delay1ms
CLR EN
CALL delay1ms

MOV A,#28H
CALL LCDCMD
MOV A,#0CH
CALL LCDCMD
MOV A,#06H
CALL LCDCMD
MOV A,#01H
CALL LCDCMD
RET
            
end


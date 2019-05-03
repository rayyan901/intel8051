                     ; lcd 4 bit mode interface, d4~d7 ==> p2.0~P2.3


RS EQU P2.4    ;0A4H  ;RS=P2.4
RW EQU P2.5 ;  sbit RW = 0a5h  =P2_5 ;0A5H
EN EQU P2.6  ;0A6H  ;EN: EQU P2_6 

U DATA 60H
L DATA 61H
TEMP DATA 62H

org 0000h
     
ljmp 0100h

org 0100h

mov sp,#30h     
     
CLR RW
CALL INIT         

mov a,#80h  
call LCD_CMD
              
MOV DPTR,#TEXT
CALL DISP        

mov a,#0C5h
call LCD_CMD

mov a,#"U"
call LCD_DATA

mov a,#"P"
call LCD_DATA

mov a,#"1"
call LCD_DATA

JMP $


DISP:
CLR A
MOVC A,@A+DPTR
CJNE A,#0,DIS
RET
DIS:
PUSH DPH
PUSH DPL
CALL LCD_DATA
POP DPL
POP DPH
INC DPTR
JMP DISP

TEXT: DB "KEIL a51 LCD",0

delay:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret  

SEPERATOR:

MOV L,A
ANL L,#0FH
SWAP A
ANL A,#0FH
MOV U,A

RET
   

MOVE_TO_PORT:

CALL MOVLP2
SETB EN
CALL DELAY
CLR EN
CALL DELAY   
RET         
;==========

movlp2:

mov temp,a 

RRC A
MOV P2.0,C

RRC A
MOV P2.1,C

RRC A
MOV P2.2,C

RRC A
MOV P2.3,C

MOV A,TEMP
ret
   
;======================================================

 ;==================================    
LCD_CMD:

CLR RS
CALL SEPERATOR
MOV A,U
CALL MOVE_TO_PORT
MOV A,L
CALL MOVE_TO_PORT
RET
   
LCD_DATA:

SETB RS
CALL SEPERATOR
MOV A,U
CALL MOVE_TO_PORT
MOV A,L
CALL MOVE_TO_PORT
RET   
   
INIT:

CALL DELAY
CALL DELAY

MOV A,#02H
CALL MOVLP2
CLR RS
SETB EN
CALL DELAY
CLR EN
CALL DELAY  

SETB EN
CALL DELAY
CLR EN
CALL DELAY

SETB EN
CALL DELAY
CLR EN
CALL DELAY


MOV A,#28H
CALL LCD_CMD
MOV A,#0CH
CALL LCD_CMD

MOV A,#06H
CALL LCD_CMD
MOV A,#01H
CALL LCD_CMD
RET
       
       
end

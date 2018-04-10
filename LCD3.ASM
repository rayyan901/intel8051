
; lcd 4 bit mode interface, d4~d7 ==> pa4~pa7

cpu "8051.tbl"
incl "8051.inc"

RS: EQU P1_0
RW: EQU P1_1
EN: EQU P1_2 
U: EQU 60H
L: EQU 61H

org 2000h

mov a,#80h
mov dptr,#4003h
movx @dptr,a 

CLR RW
CALL INIT
              

mov a,#85h
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

MOVX A,@DPTR
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

TEXT: DFB "MAKMAL",0


again:	sjmp again


delay:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret  


SEPERATOR:

MOV U,A
ANL U,#0F0H
SWAP A
ANL A,#0F0H
MOV L,A

RET
   

MOVE_TO_PORT:


mov dptr, #4000h
movx @dptr, a
SETB EN
CALL DELAY
CLR EN
CALL DELAY
   
   
   
RET


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

MOV A,#20H
mov dptr, #4000h
movx @dptr, a
CLR RS
SETB EN
CALL DELAY
CLR EN

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

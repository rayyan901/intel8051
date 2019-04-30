                     ; lcd 4 bit mode interface, d4~d7 ==> p2.0~P2.3

cpu "8051.tbl"
incl "8051.inc"

RS: EQU P2_4
RW: EQU P2_5
EN: EQU P2_6 
U: EQU 60H
L: EQU 61H
TEMP: EQU 62H

org 0000h
     
ljmp 0100h

org 0100h

mov sp,#30h     
     
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

TEXT: DFB "MAKMAL",0


again:	sjmp again


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


;mov dptr, #4000h
;movx @dptr, a
CALL MOVLP2

SETB EN
CALL DELAY
CLR EN
CALL DELAY
   
   
   
RET
   
;======================================================
movlp2:

mov TEMP,a
clr c
rrc a
jc send1p20
clr p2.0
jmp bit1

send1p20: setb p2.0

bit1:

rrc a
jc send1p21
clr p2.1
jmp bit2
send1p21: setb p2.1

bit2:
                   

rrc a
jc send1p22
clr p2.2
jmp bit3
send1p22: setb p2.2

bit3:                   
     
rrc a
jc send1p23
clr p2.3
jmp bit4
send1p23: setb p2.3

bit4:
     
mov a,TEMP
ret
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
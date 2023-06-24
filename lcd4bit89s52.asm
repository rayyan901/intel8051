
  
; lcd 4 bit mode interface, d4~d7 ==> p2.0~P2.3


RS EQU P2.4    ;0A4H  ;RS=P2.4
EN EQU P2.5  ;0A6H  ;EN: EQU P2_5 	
RW EQU P2.6 ;  or connect to gnd
lcd_port equ P2
tenms  equ 51h	
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
	MOV TENMS,#100
	CALL DELAY10MS
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

TEXT: DB "Keil 89s52 LCD",0

delay1ms:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret     
;===============

delay10ms:

mov r7,#18          ;1 mc
loop: mov r6,#255    ;1 mc       
djnz r6,$            ;2 mc     2x255x18
djnz r7, loop        ;2 mc
djnz tenms,delay10ms         ;2 mc   need 921.66
ret                   ; 1 mc
;==========
;==
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
 ;========
lcd_reset:                  ;LCD reset sequence
	mov lcd_port, #0FFH
	mov TENMS,#2           ;20mS delay
	call delay10ms
	mov lcd_port, #23H      ;Data = 30H, EN = 1, First Init
	mov lcd_port, #03H      ;Data = 30H, EN = 0
	mov TENMS,#2           ;20mS delay
	call delay10ms
	mov lcd_port, #23H      ;Second Init, Data = 30H, EN = 1
	mov lcd_port, #03H      ;Data = 30H, EN = 0
	mov TENMS,#1           ;10mS delay
	call delay10ms
	mov lcd_port, #23H      ;Third Init
	mov lcd_port, #03H
	mov TENMS,#1           ;10mS delay
	call delay10ms
	mov lcd_port, #22H      ;Select Data width (2H for 4bit)
	mov lcd_port, #02H      ;Data = 20H, EN = 0
	mov TENMS,#1           ;10mS delay
	call delay10ms
	ret
;===========   
INIT:

mov tenms,#2
call delay10ms
CALL LCD_RESET
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



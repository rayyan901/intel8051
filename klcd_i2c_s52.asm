;...i2c pfc8574 internal connection to lcd
; p0 > rs
; p1 > r/w
; p2 > en
; p3 > backlight
; p4 > d4
; p5 > d5
; p6 > d6
; p7 > d7
;==================================
; keypad connection
; p1.0 ---> col 1
; p1.1 ---> col 2
; p1.2 ---> col 3
; p1.3 ---> col 4
; p1.4 ---> row 1
; p1.5 ---> row 2
; p1.6 ---> row 3
; p1.7 ---> row 4
;***************************************
;Ports Used for I2C Communication
;***************************************
sda equ P3.6
scl equ P3.7
 ;==
keyVal equ 50h
tenms  equ 51h	
ROW    equ 52h
keyRaw EQU 53H
TEMP DATA 60H 
	
org 0h
ljmp 0100h
org 0100h
	
mov sp,#30h
CALL INIT  
mov a,#80h  
call LCDCMD              
MOV DPTR,#TEXT
CALL DISP  
;======
INP:
CALL SCAN
MOV A,#0C7H
CALL LCDCMD
MOV A,KEYVAL
ADD A,#30H
CALL LCDDATA
JMP INP
;================================================
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

TEXT: DB "Keil s52 i2c LCD",0
	 
;*****************************************
;===============
scan:
CALL READCOL
cjne a,#00001111b,scan

nopress:
CALL READCOL
cjne a,#00001111b,pressed
sjmp nopress

pressed:
mov ROW,#11101111b

SCAN_KEY:
mov p1,ROW
mov a,p1
anl a,#00001111b
CJNE A,#00001111B,KEY_FOUND

MOV A,ROW
RL A
MOV ROW,A
CJNE A,#11111110B,SCAN_KEY
RET

KEY_FOUND:
ANL ROW,#11110000B
ORL A,ROW
MOV keyRaw,A
;===========================
MOV DPTR,#KEYDATA
MOV keyVal,#0

FINDKEY:
CLR A
MOVC A,@A+DPTR
CJNE A,keyRaw,NEXTKEY
RET
NEXTKEY:
INC DPTR
INC keyVal
MOV A,keyVal
CJNE A,#17, FINDKEY
MOV keyVal,#16
RET

;================
READCOL:
mov tenms,#10
call delay10ms

mov p1,#00001111B
mov a,p1
anl a,#00001111B
RET
;============
KEYDATA:

DB 01111101B  ;0	
DB 11101110B  ;1
DB 11101101B  ;2
DB 11101011B  ;3
DB 11011110B  ;4
DB 11011101B  ;5	
DB 11011011B  ;6
DB 10111110B  ;7
DB 10111101B  ;8
DB 10111011B  ;9
DB 11100111B  ;A
DB 11010111B  ;B	
DB 10110111B  ;C	
DB 01110111B  ;D	
DB 01111011B  ;#
DB 01111110B  ;* 

;===========
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
 ;===
lcd_reset:                  ;LCD reset sequence

	; Init i2c ports first
	lcall i2cinit
	; Send start condition
	lcall startc
	; Send slave address
	mov a,#4EH
	acall send
	mov TENMS,#2           ;20mS delay
	call delay10ms
	
	mov a, 00111100b ;mov lcd_port, #23H      ;Data = 30H, EN = 1, First Init
	call send
	mov a, 00111000b ;mov lcd_port, #03H      ;Data = 30H, EN = 0
	call send
	mov TENMS,#2           ;20mS delay
	call delay10ms
	
	mov a, 00111100b ;mov lcd_port, #23H      ;Second Init, Data = 30H, EN = 1
	call send
	mov a, 00111000b ;mov lcd_port, #03H      ;Data = 30H, EN = 0
	call send
	mov TENMS,#1           ;10mS delay
	call delay10ms
	
	mov a, 00111100b ;mov lcd_port, #23H      ;Third Init
	call send
	mov a, 00111000b ;mov lcd_port, #03H
	call send
	mov TENMS,#1           ;10mS delay
	call delay10ms
	
	mov a, 00101100b ;mov lcd_port, #22H      ;Select Data width (20H for 4bit)
	call send
	mov a, 00101000b ;mov lcd_port, #02H      ;Data = 20H, EN = 0
	call send
	mov TENMS,#1           ;10mS delay
	call delay10ms
	ret
	;===========
;==
LCDCMD:
MOV TEMP,A
ANL A,#0F0H
ORL A,#00001100B   ;EN=1, RS =0...bl,en,rw,rs
call send
CALL delay1ms
ANL A,#11111000B	;EN=0, RS =0
call send ;MOV P2,A
CALL DELAY1MS

MOV A,TEMP
swap a
ANL A,#0F0H
ORL A,#00001100B   ;EN=1, RS =0
call send ;MOV P2,A
CALL delay1ms
ANL A,#11111000B	;EN=0, RS =0
call send ;MOV P2,A
CALL DELAY1MS
RET
;===============
;===============
LCDDATA:
MOV TEMP,A
ANL A,#0F0H
ORL A,#00001101B   ;EN=1, RS =1
call send ;MOV P2,A
CALL delay1ms
ANL A,#11111001B	;EN=0, RS =1
call send ;MOV P2,A
CALL DELAY1MS

MOV A,TEMP
swap a
ANL A,#0F0H
ORL A,#00001101B   ;EN=1, RS =1
call send ;MOV P2,A
CALL delay1ms
ANL A,#11111001B	;EN=0, RS =0
call send ;MOV P2,A
CALL DELAY1MS
RET
;========
;***************************************
;Initializing I2C Bus Communication
;***************************************
i2cinit:
	setb sda
	setb scl
	ret
 
;****************************************
;ReStart Condition for I2C Communication
;****************************************
rstart:
	clr scl
	setb sda
	setb scl
	clr sda
	ret
 
;****************************************
;Start Condition for I2C Communication
;****************************************
startc:
	setb scl
	clr sda
	clr scl
	ret
 
;*****************************************
;Stop Condition For I2C Bus
;*****************************************
stop:
	clr scl
	clr sda
	setb scl
	setb sda
	ret
 
;*****************************************
;Sending Data to slave on I2C bus
;*****************************************
send:
    push acc
	mov r7,#08
back:
	clr scl
	rlc a
	mov sda,c
	setb scl
	djnz r7,back
	clr scl
	setb sda
	setb scl
	mov c, sda
	clr scl
	pop acc
	ret
 
;*****************************************
;ACK and NAK for I2C Bus
;*****************************************
ack:
	clr sda
	setb scl
	clr scl
	setb sda
	ret
 
nak:
	setb sda
	setb scl
	clr scl
	setb scl
	ret
;*****************************************
;Receiving Data from slave on I2C bus
;*****************************************
;http://www.8051projects.net/wiki/I2C_Implementation_on_8051
;********************
recv:
	mov r7,#08
back2:
	clr scl
	setb scl
	mov c,sda
	rlc a
	djnz r7,back2
	clr scl
	setb sda
	ret 
;*****************************************	
;===============

delay10ms:

mov r7,#18          ;1 mc
loop: mov r6,#255    ;1 mc       
djnz r6,$            ;2 mc     2x255x18
djnz r7, loop        ;2 mc
djnz tenms,delay10ms         ;2 mc   need 921.66
ret                   ; 1 mc
;==========
delay1ms:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret     
;===============
end

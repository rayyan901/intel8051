;...i2c pfc8574 internal connection to lcd
; p0 > rs
; p1 > r/w
; p2 > en
; p3 > backlight
; p4 > d4
; p5 > d5
; p6 > d6
; p7 > d7
;***************************************
;Ports Used for I2C Communication
;***************************************
sda equ P3.6
scl equ P3.7
 ;==
tenms  equ 51h	
TEMP DATA 60H 
	
org 0h
ljmp 0100h
org 0100h
	
	mov sp,#30h
	call init
main:	
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
	call stop
	JMP $
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
;SWAP A
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
;SWAP A
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
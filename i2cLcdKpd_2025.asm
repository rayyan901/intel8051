
scl equ P1.0;
sda equ P1.1;
loww equ 50h
upp equ 51h
temp equ 52h	
slave_add equ 53h
tenms equ 54h
dataw_l equ 55h
dataw_u equ 56h
	
keyVal equ 60h
;tenms  equ 61h	
ROW    equ 62h
keyRaw EQU 63H
		

org 0h
ljmp 100h
org 100h


mov sp,#30h
mov slave_add,#4Eh
main:
mov 69h,#100
delay1sec:
call delay10ms
djnz 69h,delay1sec

call lcd_init		
mov a,#80h
call lcd_send_cmd
mov a,#'a'
call lcd_send_data
mov a,#'b'
call lcd_send_data
mov a,#'C'
call lcd_send_data

mov a,#0C0h
call lcd_send_cmd

;mov a,#'2'
;call lcd_send_data

;sjmp $

readkey:
call scan
MOV A,keyVal
add a,#30h
call lcd_send_data
jmp readkey
;======================

i2c_start:

setb sda	;sda=1;_nop_();_nop_();
nop
nop
setb scl	;scl=1;_nop_();_nop_();
nop
nop
clr sda	;sda=0;_nop_();_nop_();
nop
nop
ret
;===========
i2c_stop:

clr scl		;scl=0;
clr sda		;sda=0;
setb scl	;scl=1;
nop
setb sda	;sda=1;
ret
;==============

i2c_ACK:

clr scl		;scl=0;
setb sda	;sda=1;
setb scl	;scl=1;
jb sda, $	;while(sda);
ret ;===

i2c_write:
push acc
mov r5,#8
back:
	clr scl
	rlc a
	mov sda,c
	setb scl
	djnz r5,back
	pop acc
	ret
;===

;==
lcd_send_cmd:

mov temp,a
swap a
anl a,#0f0h
mov loww,a  ;low
mov a,temp
anl a,#0f0h
mov upp,a	;cmd_u=(cmd &0xf0);
call i2c_start		;i2c_start();			 //BL EN RW RS 1 1 0 0
mov a,slave_add	;i2c_write(slave_add);
call i2c_write
call i2c_ACK		;i2c_ACK();
mov a,upp
orl a,#0ch
call i2c_write

call i2c_ACK	;i2c_ACK();
call delay1ms	;delay_ms(1);

mov a,upp
orl a,#08h
call i2c_write

call i2c_ACK	;i2c_ACK();
call delay10ms		;delay_ms(10);

mov a,loww  ;low
orl a,#0ch
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms		;delay_ms(1);

mov a,loww
orl a,#08h
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay10ms		;delay_ms(10);
call i2c_stop		;i2c_stop();
;}

ret

;=========
;===

lcd_send_data:	;(unsigned char dataw)// 1 1 0 1

mov temp,a
swap a
anl a,#0f0h
mov dataw_l,a  ;low

;dataw_u=(dataw &0xf0);
mov a,temp
anl a,#0f0h
mov dataw_u,a	;cmd_u=(cmd &0xf0);


call i2c_start		;i2c_start();
mov a,slave_add
call i2c_write		;i2c_write(slave_add);
call i2c_ACK		;i2c_ACK();
;i2c_write(dataw_u|0x0D);//BL EN RW RS   1 1 0 1
mov a,dataw_u
orl a,#0dh
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms		;delay_ms(1);
;i2c_write(dataw_u|0x09);// 1 0 0 1
mov a,dataw_u
orl a,#09h
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay10ms		;delay_ms(10);
;i2c_write(dataw_l|0x0D);
mov a,dataw_l
orl a,#0dh
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms			;delay_ms(1);
;i2c_write(dataw_l|0x09);
mov a,dataw_l
orl a,#09h
call i2c_write
call i2c_ACK		;i2c_ACK();
call delay10ms		;delay_ms(10);
call i2c_stop		;i2c_stop();

ret
;===
;===
lcd_init:

;lcd_send_cmd(0x02);	// Return home
mov a,#02h
call lcd_send_cmd

;lcd_send_cmd(0x28);	// 4 bit mode
mov a,#028h
call lcd_send_cmd

;lcd_send_cmd(0x0C);	// Display On , cursor off
mov a,#0ch
call lcd_send_cmd

;lcd_send_cmd(0x06);	// Increment Cursor (shift cursor to right)
mov a,#06h
call lcd_send_cmd

;lcd_send_cmd(0x01); // clear display
mov a,#01h
call lcd_send_cmd

ret


;===
delay1ms:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret     
;===============
;===============

delay10ms:

mov r7,#18          ;1 mc
loop: mov r6,#255    ;1 mc       
djnz r6,$            ;2 mc     2x255x18
djnz r7, loop        ;2 mc
         
ret                   ; 1 mc
;==========

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
mov p2,ROW
call readcolbits ;mov a,p2
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

mov p2,#0fh
call readcolbits
ret


readcolbits:
setb p2.0
setb p2.1
setb p2.2
setb p2.3
mov a,#0

jnb p2.0,p20clr
orl a,#00000001b
p20clr:

jnb p2.1,p21clr
orl a,#00000010b
p21clr:

jnb p2.2,p22clr
orl a,#00000100b
p22clr:

jnb p2.3,p23clr
orl a,#00001000b
p23clr:
ret


;mov p2,#00001111B
;mov a,p2
;anl a,#00001111B
;RET
;============
;==========
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
end

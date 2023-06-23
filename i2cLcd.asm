
scl equ P1.0;
sda equ P1.1;
loww equ 50h
upp equ 51h
temp equ 52h	
slave_add equ 53h
tenms equ 54h
dataw_l equ 55h
dataw_u equ 56h

org 0h
ljmp 100h
org 100h


mov sp,#30h
mov slave_add,#4Eh
main:


call lcd_init		
mov a,#80h
call lcd_send_cmd
mov a,#'A'
call lcd_send_data
mov a,#'b'
call lcd_send_data
mov a,#'C'
call lcd_send_data

mov a,#0C0h
call lcd_send_cmd

mov a,#'2'
call lcd_send_data
jmp $
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
end
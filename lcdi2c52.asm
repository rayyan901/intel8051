


scl bit P1.0;
sda bit P1.1;
cmd_l data 50h
cmd_u data 51h
data_l data 52h
data_u data 53h
temp data 54h	
slave_add data 55h
tenms data 56h


org 0h
ljmp 100h
org 100h


mov sp,#30h
mov slave_add,#4Eh
jmp main
text1: DB "Microp I EEE226",0


main:

call lcd_init		
mov a,#80h
call lcd_send_cmd
mov a,#'A'
call lcd_send_data
mov a,#'b'
call lcd_send_data
mov a,#'c'
call lcd_send_data

mov a,#0C0h
call lcd_send_cmd


mov dptr,#text1
call dispString


jmp $
;=====
;=====

dispString:
clr a
movc a, @a+dptr
cjne a, #0, dispC
ret
dispC:
push dph
push dpl
call lcd_send_data
pop dpl
pop dph
inc dptr
jmp dispString


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
mov cmd_l,a  ;low
mov a,temp
anl a,#0f0h
mov cmd_u,a	;cmd_u=(cmd &0xf0);
call i2c_start		;i2c_start();			 //BL EN RW RS 1 1 0 0
mov a,slave_add	;i2c_write(slave_add);
call i2c_write
call i2c_ACK		;i2c_ACK();
mov a,cmd_u
orl a,#0ch
call i2c_write

call i2c_ACK	;i2c_ACK();
call delay1ms	;delay_ms(1);

mov a,cmd_u
orl a,#08h
call i2c_write

call i2c_ACK	;i2c_ACK();
call delay10ms		;delay_ms(10);

mov a,cmd_l  ;low
orl a,#0ch
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms		;delay_ms(1);

mov a,cmd_l
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
push acc
mov temp,a
swap a
anl a,#0f0h
mov data_l,a  ;low

;data_u=(dataw &0xf0);
mov a,temp
anl a,#0f0h
mov data_u,a	;cmd_u=(cmd &0xf0);


call i2c_start		;i2c_start();
mov a,slave_add
call i2c_write		;i2c_write(slave_add);
call i2c_ACK		;i2c_ACK();
;i2c_write(data_u|0x0D);//BL EN RW RS   1 1 0 1
mov a,data_u
orl a,#0dh
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms		;delay_ms(1);
;i2c_write(data_u|0x09);// 1 0 0 1
mov a,data_u
orl a,#09h
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay10ms		;delay_ms(10);
;i2c_write(data_l|0x0D);
mov a,data_l
orl a,#0dh
call i2c_write

call i2c_ACK		;i2c_ACK();
call delay1ms			;delay_ms(1);
;i2c_write(data_l|0x09);
mov a,data_l
orl a,#09h
call i2c_write
call i2c_ACK		;i2c_ACK();
call delay10ms		;delay_ms(10);
call i2c_stop		;i2c_stop();
pop acc
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

mov tenms,#10
d1ms:
call delay1ms
djnz tenms,d1ms
ret


;==========
end

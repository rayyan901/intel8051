cpu "8051.tbl"
incl "8051.inc"

RS: EQU P1_0
RW: EQU P1_1
EN: EQU P1_3 


org 2000h

mov a,#80h
mov dptr,#4003h
movx @dptr,a

CALL INIT_LCD


mov a,#"U"
call datawrt
call delay
mov a,#"P"
call datawrt
call delay

again:	sjmp again

comnwrt:
mov dptr, #4000h
movx @dptr, a
clr RS
clr RW
setb EN
call delay
clr EN
ret

datawrt:
mov dptr, #4000h
movx @dptr, a
SETB RS
clr RW
setb EN
call delay
clr EN
ret

delay:
       mov r3,#2
here:  mov r4,#255
here1: djnz r4, here1
       djnz r3,here
       ret  

INIT_LCD:       
mov a,#38h
call comnwrt
call delay
mov a,#38h
call comnwrt
call delay
mov a,#38h
call comnwrt
call delay
mov a,#0eh
call comnwrt
call delay
mov a,#0eh
call comnwrt
call delay
mov a,#01h
call comnwrt
call delay
mov a,#06h
call comnwrt
call delay
mov a,#80h
call comnwrt
call delay
RET       
       
       
end

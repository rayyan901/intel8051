; keypad connection
; p1.0 ---> col 1
; p1.1 ---> col 2
; p1.2 ---> col 3
; p1.3 ---> col 4
; p1.4 ---> row 1
; p1.5 ---> row 2
; p1.6 ---> row 3
; p1.7 ---> row 4
; P2   ---> seven segment common anode
;
keyVal equ 50h
tenms  equ 51h	
ROW    equ 52h
keyRaw EQU 53H
	
ORG 00H
ljmp 0100h

org 0100h
mov sp,#30h

MOV DPTR,#seg_data // 
MOV P2,#00000000B // initializes P2 as output port

main:

call scan
MOV A,keyVal
CALL DISPLAY
sjmp main

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
DISPLAY:
        MOV DPTR,#seg_data
        MOVC A,@A+DPTR // gets digit drive pattern for the current key from LUT
        MOV P2,A       // puts corresponding digit drive pattern into P0
        RET

 ;==================================    

delay10ms:

mov r7,#18          ;1 mc
loop: mov r6,#255    ;1 mc       
djnz r6,$            ;2 mc     2x255x18
djnz r7, loop        ;2 mc
djnz tenms,delay10ms         ;2 mc   need 921.66
ret                   ; 1 mc
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
seg_data:

DB 0C0H ;3FH // digit drive pattern for 0
DB 0F9H ;06H // digit drive pattern for 1
DB 0A4H ;5BH // digit drive pattern for 2
DB 0B0H ;4FH // digit drive pattern for 3
DB 099H ;66H // digit drive pattern for 4
DB 092H ;6DH // digit drive pattern for 5
DB 082H ;7DH // digit drive pattern for 6
DB 0F8H ;07H // digit drive pattern for 7
DB 080H ;7FH // digit drive pattern for 8
DB 090H ;6FH // digit drive pattern for 9
DB 11111110B    ;a
DB 11111101B    ;b
DB 11111011B    ;c
DB 11110111B	;d	
DB 11011111B	;e
DB 11101111B	;f
DB 10111111B	;g	

END

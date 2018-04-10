cpu "8051.tbl"
incl "8051.inc" 


PA: EQU 4000H
PB: EQU 4001H
PC: EQU 4002H
PCC: EQU 4003H 

RS: EQU P1_0
RW: EQU P1_1
EN: EQU P1_2 


COLUMN: EQU 51H
ROW:    EQU 52H 
RC:     EQU 53H
KEY:    EQU 54H

org 2000h

MOV SP,#30H
MOV A,#10000001B 
MOV DPTR,#4003H
movx @dptr,a

CALL INIT_LCD   
;CALL INIT_LCD
;CALL INIT_LCD 


mov a,#"U"
call datawrt
call delay
mov a,#"P"
call datawrt
call delay


;===   
INP:
CALL SCAN
CALL LDELAY
CALL MATCH 
MOV A,#87H
CALL COMNWRT
MOV A,KEY
CALL DATAWRT
JMP INP




;===




mov a,#"U"
call datawrt
call delay
mov a,#"P"
call datawrt
call delay

again:	sjmp again    
;==== 
;============================================================
SCAN:
MOV A,#11110000B
MOV DPTR,#PC
MOVX @DPTR,A
MOVX A,@DPTR
ANL A,#00001111B
JZ SCAN

MOV R0,#4
MOV R1,#00010000B

SCAN_NEXT:
MOV A,R1
MOVX @DPTR,A
MOVX A,@DPTR
ANL A,#00001111B
JZ NEXT_COL
ORL A,R1

MOV DPTR,#3300H
MOVX @DPTR,A
MOV 50H,A 


MOV R7,#255
DJNZ R7,$
;===   
DEB:
MOV A,#11110000B
MOV DPTR,#PC
MOVX @DPTR,A
MOVX A,@DPTR
ANL A,#00001111B
JNZ DEB
;==
RET

NEXT_COL:
MOV A,R1 
RL A
MOV R1,A
DJNZ R0,SCAN_NEXT
JMP SCAN
;========================================================

MATCH:
   
MOV DPTR,#3300H
MOVX A,@DPTR
ANL A,#11110000B
SWAP A
   
CALL FIND_RC
MOV COLUMN,RC
    
MOV DPTR,#3300H
MOVX A,@DPTR
ANL A,#00001111B
    
CALL FIND_RC
MOV ROW,RC    

MOV DPTR,#KEYS
MOV A,ROW
MOV B,#4
MUL AB
ADD A,COLUMN

MOVC A,@A+DPTR
MOV DPTR,#3301H
MOVX @DPTR,A
MOV KEY,A              
   
RET  
;========================================================

FIND_RC:
MOV RC,#0   
F_RC:
RRC A
JC FOUND
INC RC
JMP F_RC
FOUND:

RET   


;=====

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
       
;====================

;=======    
LDELAY:
MOV R7,#255
DLY:
MOV R6,#255
DJNZ R6,$
DJNZ R7,DLY
RET
;===============================       

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
        
KEYS:
DFB "123A456B789C*0#D"
        
       
end
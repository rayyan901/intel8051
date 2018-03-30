CPU "8051.TBL"
INCL "8051.INC" 

PA: EQU 4000H
PB: EQU 4001H
PC: EQU 4002H
PCC: EQU 4003H   

COLUMN: EQU 51H
ROW:    EQU 52H

UARTCWF1:       EQU 6001H
UART1:          EQU 6000H


ORG 2000H

MOV SP,#30H
MOV A,#10000001B
MOV DPTR,#4003H
MOVX @DPTR,A         
        
MAIN:   

CALL SCAN    
CALL MATCH 
call transmit   
CJNE A,#"C",MAIN
LJMP 0    
 

;=======    
DELAY:
MOV R7,#255
DLY:
MOV R6,#255
DJNZ R6,$
DJNZ R7,DLY
RET

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



MOV COLUMN,#0
MOV ROW,#0
   
MOV DPTR,#3300H
MOVX A,@DPTR


ANL A,#11110000B
SWAP A
   
   
F_COL:
RRC A
JC ROWW
INC COLUMN
JMP F_COL

ROWW:
    
MOV DPTR,#3300H
MOVX A,@DPTR


ANL A,#00001111B


F_ROW:
RRC A
JC ROW_FND                       
INC ROW
JMP F_ROW    
    
ROW_FND:

MOV DPTR,#KEYS
MOV A,ROW
MOV B,#4
MUL AB
ADD A,COLUMN

MOVC A,@A+DPTR
MOV DPTR,#3301H
MOVX @DPTR,A              
   
RET     


;===========================================
 TRANSMIT:
       MOV 6FH,A
       PUSH DPL
       PUSH DPH
       MOV DPTR,#UARTCWF1
TRX:            MOVX A,@DPTR
                ANL A,#10000001B
                CJNE A,#10000001B,TRX	
	            DEC DPL
                MOV A,6FH
                MOVX @DPTR,A
                POP DPH
                POP DPL
                MOV A,6FH
                RET
;======================================


KEYS:
DFB "123A456B789C*0#D"

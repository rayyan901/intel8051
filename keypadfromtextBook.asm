
ORG 0H
	LJMP MAIN

ORG 100H
	MAIN:
	
	mov tmod,#20h
		mov th1,#-3
		mov scon,#50h
		setb tr1

read:
call k1
sjmp read
;MOV P2, #0FH
K1: 
    MOV P2, #0FH
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, K1
K2: 
    ACALL DELAY
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, OVER
    SJMP K2
OVER: 
    ACALL DELAY
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, OVER1
    SJMP K2
OVER1: 
    MOV P2, #11101111B
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, ROW_0
    MOV P2, #11011111B
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, ROW_1
    MOV P2, #10111111B
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, ROW_2
    MOV P2, #01111111B
    MOV A, P2
    ANL A, #00001111B
    CJNE A, #00001111B, ROW_3
    LJMP K2

ROW_0: MOV DPTR, #KCODE0  ;set DPTR=start address of KCODE0
        SJMP FIND           ;find column key
ROW_1: MOV DPTR, #KCODE1  ;set DPTR=start address of KCODE1
        SJMP FIND           ;find column key
ROW_2: MOV DPTR, #KCODE2  ;set DPTR=start address of KCODE2
        SJMP FIND           ;find column key
ROW_3: MOV DPTR, #KCODE3  ;set DPTR=start address of KCODE3
;=======possible inf loop ==================================================
mov r7,#17
FIND:   RRC A               ;see if any column key is pressed
        JNC MATCH           ;if zero, get out (match found)
        INC DPTR            ;point to next column key address
        djnz r7,find
		;SJMP FIND           ;keep searching
;==================
MATCH:  CLR A               ;set A=0 (match found)
        MOVC A, @A+DPTR     ;get ASCII code of the key
        ;MOV P0, A           ;display pressed key
        CALL TRANS
		ret
		;LJMP K1
		
		DELAY:
		MOV R7,#255
		DJNZ R7,$
		RET	
		
			;================================		
		trans:
		mov sbuf,a
		jnb ti,$
		clr ti
		ret
		
		rx:
		jnb ri,$
		mov a,sbuf
		clr ri
		ret
;===================================================		
;ASCII LOOK-UP TABLE FOR EACH ROW
        ORG 300H
KCODE0: DB '1','2','3','A' ;ROW 0
KCODE1: DB '4','5','6','B' ;ROW 1
KCODE2: DB '7','8','9','C' ;ROW 2
KCODE3: DB '*','0','#','D' ;ROW 3
        END

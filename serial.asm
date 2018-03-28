  CPU "8051.TBL"
  INCL "8051.INC"

   CPORT:          EQU 4003H
   PORTA:          EQU 4000H
   UARTCWF1:       EQU 6001H
   UART1:          EQU 6000H
   UARTCWF2:       EQU 4061H
   UART2:          EQU 4060H
   COUNT:          EQU 230    ;set baud rate to 557 for rs 485 data transmission
                           
  ORG 2000H

;==============================================================
                MOV DPTR,#UARTCWF1      ;INITIALIZE USART1
                CLR A
                MOVX @DPTR,A
                MOVX @DPTR,A
                MOVX @DPTR,A
                NOP
                NOP
                MOV A,#40H
                MOVX @DPTR,A
                NOP
                NOP
                MOV A,#4EH
                MOVX @DPTR,A
                NOP
                NOP
                MOV A,#37H
                MOVX @DPTR,A
;============================================
mov tmod, #20h
mov th1, #-3
mov scon, #50h
setb tr1
;====

         MOV A,#0CH
         CALL TRANSMIT
         MOV DPTR,#MESEJ
CALL WRITE
;CALL CLRSCREEN


  start:  mov a,#0
   incn:  inc a
          call disp2
          call delay
          cjne a,#0ffh,incn
          jmp start

 MAIN:   MOV R7,#10
         MOV A,#30H
 AGAIN:  CALL TRANSMIT
	 call trans	
         CALL DELAY
         INC A
         DJNZ R7,AGAIN
         MOV A,#0DH
         CALL TRANSMIT
	call trans
         MOV A,#0AH
         CALL TRANSMIT
	call trans
         JMP MAIN

disp2:  PUSH ACC
  mov b,#100
  div ab
  mov 50h,a
  mov a,b
  mov b,#10
  div ab
  mov 51h,a
  mov 52h,b

      mov a,#0dh
      call transmit
      mov a,50h
      add a,#30h
      call transmit
      mov a,51h
      add a,#30h
      call transmit
      mov a,52h
      add a,#30h
      call transmit
      POP ACC
      ret

disp: mov r5,a
      mov a,#0dh
      call transmit
      mov a,r5
      mov b,#100
      div ab
      add a,#30h
      call transmit
      mov a,b
      mov b,#10
      div ab
      add a,#30h
      call transmit
      mov a,b
      add a,#30h
      call transmit
      mov a,r5
      ret

;==============================================
  WRITE:   

   NEXT:    MOVX A,@DPTR
         CJNE A,#0DH,GO_ON
         JMP RET1
     GO_ON: CALL TRANSMIT
            INC DPTR
            JMP NEXT
 RET1:          MOV A,#0DH
         CALL TRANSMIT
         MOV A,#0AH
         CALL TRANSMIT
        RET
;=====================
CLRSCREEN: PUSH 7  
          MOV R7,#10
           
   CLRS:
         MOV A,#0DH
         CALL TRANSMIT
         MOV A,#0AH
         CALL TRANSMIT
         DJNZ R7,CLRS
       ;  MOV A,#02H
       ;  CALL TRANSMIT
         POP 7
         RET

trans:

mov sbuf,a
jnb ti, $
clr ti
ret


;*********RX ROUTINE FOR USART1 (LINk TO PC TX LINE)*******

RECEIVE:        PUSH DPL
                PUSH DPH
                MOV DPTR,#UARTCWF1
RX:             MOVX A,@DPTR
                ANL A,#82H
                CJNE A,#82H,RX
                DEC DPL
                MOVX A,@DPTR
                POP DPH
                POP DPL
                RET
;===========================================
 TRANSMIT:
       MOV R4,A
       ;PUSH ACC
       PUSH DPL
       PUSH DPH
       MOV DPTR,#UARTCWF1
TRX:            MOVX A,@DPTR
                ANL A,#10000001B
                CJNE A,#10000001B,TRX	
	        DEC DPL
                MOV A,R4
                MOVX @DPTR,A
                POP DPH
                POP DPL
                ;POP ACC
                MOV A,R4
call trans
                RET
       

;=========================
  DELAY:    MOV R1,#50
            MOV R2,#50
            MOV R3,#10
  LOOP1:    DJNZ R2,$
            DJNZ R1,LOOP1
            DJNZ R3,LOOP1
	    RET
;==========================

 MESEJ: DFB 9H,9H,"SELAMAT DATANG KE PPKEE, KHAMIS 09 JULAI 2002",0DH

org 0				; reset vector
	JMP main		; jump to the main program

org 3				; external 0 interrupt vector
	JMP ext0ISR		; jump to the external 0 ISR

org 0BH				; timer 0 interrupt vector
	JMP timer0ISR	; jump to timer 0 ISR


org 30H
main:
	SETB IT0		; set external 0 interrupt as edge-activated
	SETB EX0		; enable external 0 interrupt
	MOV TMOD, #2	; set timer 0 as 8-bit auto-reload interval timer
	MOV TH0, #-200	; | put -200 into timer 0 high-byte - this reload value, 
   					; | with system clock of 12 MHz, will result in a timer 0 overflow every 200 us
	MOV TL0, #-200	; | put the same value in the low byte to ensure the timer starts counting from 
   					; | 56 (256 - 200) rather than 0
	SETB TR0		; start timer 0
	SETB ET0		; enable timer 0 interrupt





	SETB EA				; set the global interrupt enable bit
	JMP $				; do nothing



;-------------------------------------------------------------------------------




delay:
	MOV R3, #50
	DJNZ R3, $
	RET



; timer 0 ISR - simply starts an ADC conversion
timer0ISR:
	CLR P3.6				; clear ADC WR line
	SETB P3.6				; then set it - this results in the required positive edge to start a conversion
	RETI					; return from interrupt


; external 0 ISR - responds to the ADC conversion complete interrupt
ext0ISR:
	CLR P3.7				; clear the ADC RD line - this enables the data lines
	MOV B, P2				; move ADC outputs to B
	mov p1,p2
    SETB P3.7				; disable the ADC data lines by setting RD
    ;mov p1,p2	
;CALL updateBarGraph		; update the bar graph using the new reading from the ADC
	RETI					; return from interrupt

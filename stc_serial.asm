

rxText data 60h

ORG 0000h        ; Set the origin to the beginning of the program
	
	ljmp main
	org 100h
		
		text0: db "STC 89c52RC development board",0
		text: db "Enter: ",0
		
		main:
		
		mov tmod,#20h
		mov th1,#-3
		mov scon,#50h
		setb tr1
		
		mov dptr,#text0
		call disptext
		mov a,#0dh
		call trans
		mov a,#0ah
		call trans
		
		
		again:
		mov dptr,#text
		call disptext
		call readSerial
		call dispRx
	

		sjmp again
;===========================================		
		readSerial:
		mov r0,#rxText
		nextRx:
		call rx
		cjne a,#0dh,storeChar
		mov @r0,a
		ret
		storeChar:
		mov @r0,a
		inc r0
		sjmp nextRx
;==========================================		
		dispRx:
		mov r0,#rxText
		nextRxx:
		mov a,@r0
		cjne a,#0dh,sendRx
		mov a,#0ah
		call trans
		ret
		sendRx:
		call trans
		inc r0
		sjmp nextRxx
		
;==================================================		
		disptext:
		push dph
		push dpl
		
		;mov dptr,#text
		nextChar:
		clr a
		movc a,@a+dptr
		cjne a,#0,sendA
		pop dpl
		pop dph
		ret
		sendA:
		call trans
		inc dptr
		sjmp nextChar
		ret
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

		
		end
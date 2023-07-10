ORG 0000h        ; Set the origin to the beginning of the program
	
	ljmp main
	org 100h
		main:
		
		mov tmod,#20h
		mov th1,#-3
		mov scon,#50h
		setb tr1
		again:
		mov a,#"1"
		acall trans
		mov a,#32h
		acall trans
		mov a,#"l"
		acall trans
;		mov a,#"l"
		acall trans
		mov a,#"o"
		acall trans
        mov a,#0
;		acall trans
		mov a,#0dh
		acall trans
		mov a,#0ah
		acall trans
		call delay
		sjmp again
		
		trans:
		mov sbuf,a
		jnb ti,$
		clr ti
		ret
		
		cdelay:
		mov r7,#255
		rr6:
		mov r6,#255
		djnz r6,$
		djnz r7,rr6		
		ret
		
		delay:
		mov r5,#10
		rdl:
		call cdelay
		djnz r5,rdl
		ret
		
		end
org 0000h
; RD ----- P0.5
; WR ----- P0.6
; INTR --- P0.7
; D0~D7 -- P2.0~P2.7

ljmp main

org 0100h
main:

mov sp,#30h 

;mov a,#0ffh
;mov p1,a
;sjmp $

	  mov p2,#0ffh
back: clr p0.6
      setb p0.6
here: jb p0.7, here
	  clr p0.5
	  mov a,p2
	  cpl a
	  mov p1,a
	  setb p0.5
	  nop
	  nop
	  nop
	  sjmp back
	  
	  end

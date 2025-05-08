org 0000h
     
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

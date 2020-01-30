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
ORG 00H
ljmp 0100h

org 0100h
	
MOV DPTR,#seg_data // moves starting address of LUT to DPTR

MOV P2,#00000000B // initializes P2 as output port

main:

call scan

sjmp main

scan:

mov p1,#11110000B
mov a,p1
anl a,#11110000B
cjne a,#11110000b,pressed
sjmp scan

pressed:

     MOV P1,#11111110B
	 JB P1.4,NEXT1  // checks whether column 1 is low and jumps to NEXT1 if not low
     MOV A,#1  // loads a with 0D if column is low (that means key 1 is pressed)
     mov keyVal,a
	 ACALL DISPLAY  // calls DISPLAY subroutine
     ret
NEXT1:JB P1.5,NEXT2 // checks whether column 2 is low and so on...
      MOV A,#4
      mov keyVal,a
	 ACALL DISPLAY  // calls DISPLAY subroutine
     ret

NEXT2:JB P1.6,NEXT3
      MOV A,#7
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret

NEXT3:JB P1.7,NEXT4
      MOV A,#10
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret
;============================
NEXT4:
      MOV P1,#11111101B
      JB P1.4,NEXT5
      MOV A,#2
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret

NEXT5:JB P1.5,NEXT6
      MOV A,#5
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret

NEXT6:JB P1.6,NEXT7
      MOV A,#8
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret
NEXT7:JB P1.7,NEXT8
      MOV A,#0
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret
;==========================================
NEXT8:
      MOV P1,#11111011B
	  JB P1.4,NEXT9
      MOV A,#3
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret

NEXT9:JB P1.5,NEXT10
      MOV A,#6
      mov keyVal,a
	  ACALL DISPLAY  // calls DISPLAY subroutine
      ret

NEXT10:JB P1.6,NEXT11
       MOV A,#9
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
       ret

NEXT11:JB P1.7,NEXT12
       MOV A,#10
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
       ret

NEXT12:
       MOV P1,#11110111B
       JB P1.4,NEXT13
       MOV A,#10
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
       ret

NEXT13:JB P1.5,NEXT14
       MOV A,#10
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
       ret

NEXT14:JB P1.6,NEXT15
       MOV A,#10
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
       ret

NEXT15:JB P1.7,notFound
       MOV A,#10
       mov keyVal,a
	   ACALL DISPLAY  // calls DISPLAY subroutine
notFound:       
	   ret
       

DISPLAY:MOVC A,@A+DPTR // gets digit drive pattern for the current key from LUT
        MOV P2,A       // puts corresponding digit drive pattern into P0
        RET



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
DB 00000110B


     END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File:    USER_HW.ASM
;;; Purpose: Test written traps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following DATA will go into USER's DATA Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR x4000
cross_array
.FILL #16
.FILL #16
.FILL #16
.FILL #255
.FILL #16
.FILL #16
.FILL #16
.FILL #16


.ADDR x4050	
all_done
	.STRINGZ "ALL DONE "


.ADDR x4200
	TEMPS 	
	.BLKW x200  
	; lines above reserve 200 words starting at x4200 for temp. variables


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x0000

INIT
  
  CONST R2, #0		; set red color in R2
  HICONST R2, x7C	

  LEA R6, TEMPS 		;R6=data address for TEMPS
  CONST R0, #59			;R0=center x value
  CONST R1, #57			;R1=center y value
  STR R0, R6, #0		;store R0, R1, R2 in TEMPS
  STR R1, R6, #1		
  STR R2, R6, #2	    
  LEA R3, cross_array   ; set R3 to data memory address for cross bits

  TRAP x06 			;call sprite trap

beginloop
  CONST R0, #232		; set R0=1000ms
  HICONST R0, x3	
  TRAP x08				;call getc_timer_trap, output ascii key

  CMPI R0, #10 			;if output is enter, branch to done
  BRz done	

  CONST R2, #105		
  CMP R0, R2			;if output is i, branch to i_type
  BRz i_type
  
  CONST R2, #107
  CMP R0, R2			;if output is k, branch to k_type
  BRz k_type

  CONST R2, #106
  CMP R0, R2			;if output is j, branch to j_type
  BRz j_type
  
  CONST R2, #108
  CMP R0, R2 			;if output is l, branch to l_type
  BRz l_type

  CMPI R0, #0			;if no key was pressed, branch to lfsr
  BRz lfsr_type		

  JMP beginloop

done
  	LEA R0, all_done	; load address of name_array into R0
	TRAP x02 			;call puts trap
	JMP endloop			;jump to endloop

i_type

    LEA R6, TEMPS		;R6=TEMPS data mem
    LDR R0, R6, #0		;R0= x val
    LDR R1, R6, #1		;R1=y val
    CONST R2, #12		;R2=width rectangle to cover cross
    CONST R3, #12		;R3=length rectangle to cover cross
    CONST R4, #1		;R4=rectangle color black (background)
    TRAP x05 			;cover up cross

    LEA R6, TEMPS		;R6=TEMPS data mem
    LDR R0, R6, #0		;R0= x val
    LDR R1, R6, #1		;R1= y val
    LDR R2, R6, #2		;R2= red color
    LEA R3, cross_array ;R3= cross array words
    ADD R1, R1, #-10	;y=y-10 to move north
    CMPI R1, #0			;if off screen, reset locations
    BRn reset
    CMPIU R1, #116
    BRp reset
    
    STR R1, R6, #1		;restore new y value
    TRAP x06			;redraw sprite
    JMP beginloop		;jump back to loop

k_type
	LEA R6, TEMPS		;R6=TEMPS data mem
    LDR R0, R6, #0		;R0=x val
    LDR R1, R6, #1		;R1=y val
    CONST R2, #12		;R2=width rectangle to cover cross
    CONST R3, #12		;R3=length rectangle to cover cross
    CONST R4, #1		;R4=rectangle color black (background)
    TRAP x05 			;cover up cross

    LEA R6, TEMPS 		;R6=TEMPS data mem
    LDR R0, R6, #0		;R0=x val
    LDR R1, R6, #1		;R1=y val
    LDR R2, R6, #2		;R2=red color
    LEA R3, cross_array ;R3=cross array words
    ADD R1, R1, #10		;y=y+10 (move sprite south)
    CMPI R1, #0			;if out of bounds reset sprite location
    BRn reset
    CMPIU R1, #116
    BRp reset

    STR R1, R6, #1		;store new y val
    TRAP x06
    JMP beginloop

j_type
	LEA R6, TEMPS		;see above
    LDR R0, R6, #0
    LDR R1, R6, #1
    CONST R2, #12
    CONST R3, #12
    CONST R4, #1
    TRAP x05
	
    LEA R6, TEMPS
    LDR R0, R6, #0
    LDR R1, R6, #1
    LDR R2, R6, #2
    LEA R3, cross_array
    ADD R0, R0, #-10	;x=x-10 (move left)
    CMPI R0, #0
    BRn reset
    CMPIU R0, #120
    BRp reset

    STR R0, R6, #0		;update x val
    TRAP x06
    JMP beginloop

l_type
    LEA R6, TEMPS		;see above
    LDR R0, R6, #0
    LDR R1, R6, #1
    CONST R2, #12
    CONST R3, #12
    CONST R4, #1
    TRAP x05
	
    LEA R6, TEMPS
    LDR R0, R6, #0
    LDR R1, R6, #1
    LDR R2, R6, #2
    LEA R3, cross_array
    ADD R0, R0, #10		;x=x+10 (move right)
    CMPI R0, #0
    BRn reset
    CMPIU R0, #120
    BRp reset

    STR R0, R6, #0		;update x val
    TRAP x06
    JMP beginloop

lfsr_type
	CONST R0, x78		;set lower 8 bits for seed value (blue)
	HICONST R0, x54
	TRAP x09			;set seed lfsr
	TRAP x0A			;call trap_lfsr, R0=pseudonumber
	CONST R2, #255		;set upper 8 bits to 01111111
	HICONST R2, x7F	    ;set lower 8 bits to 11111111
	AND R0, R0, R2 		;R0=R0 AND R2
	JMP vid_color 		;jump to trap video color
				

vid_color
	TRAP x03			;call trap_video_color
	JMP endloop

reset
  LEA R6, TEMPS 		;R6=data address for TEMPS
  CONST R0, #55
  CONST R1, #52
  STR R0, R6, #0	;starting x and y coords for sprite
  STR R1, R6, #1
  LDR R2, R6, #2
  LEA R3, cross_array
  TRAP x06
  JMP beginloop 

endloop
  LEA R6, TEMPS
  LDR R0, R6, #0
  LDR R1, R6, #1
  CONST R2, #20		;R2=width
  CONST R3, #10		;R3=length
  CONST R4, #0		; R4=color
  HICONST R4, x7C
  TRAP x05				;call draw_rect

END


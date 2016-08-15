;;Square root function
;;B * B <= A
;;R0 = B, R1 = A, R2 = B*B


	.CODE		; This is a code segment
	.ADDR  0x0000	; Start filling in instructions at address 0x00
 
 	CONST R0, #0	; Initialize B to zero

 
 	CMPI R1, #0		; Compare A to 0
 	BRn SUBTRACT	; if (A < 0) Branch to subtract line

LOOP
 	MUL R2, R0, R0	; store B*B in R2
 	CMP R2, R1		; Compare B*B to A
 	BRp SUBTRACT        ; if (B*B > A) Branch to the end

 	ADD R0, R0, #1	; B =  B + 1
 	BRnzp LOOP	; Go back to the beginning of the loop

 SUBTRACT
    ADD R0, R0, #-1	; B =  B - 1

 END
;;LFSR function
;;R0 = input value (changing), R1 = count (Should be 65535), R2 = bit 15, R3 = bit 13, R4 = bit 12, R5 = bit 10, R6 = XOR bit, R7 initial input (for comparison)


	.CODE		; This is a code segment
	.ADDR  0x0000	; Start filling in instructions at address 0x00
 
 INIT
 	CONST R1, 0 		; set counter to 0
 	ADD R7, R0, #0		; set R7 to input for later comparison (unchanging)

LOOP
	CONST R6, 0			; reset xor bit to 0

 	CONST R2, #0		; set R2 lower 8 bits to 0s
 	HICONST R2, x80		; set R2 upper 8 bits to 10000000

 	CONST R3, #0		; set R3 lower 8 bits to 0s
 	HICONST R3, x20		; set R3 upper 8 bits to 00100000

 	CONST R4, #0		; set R4 lower 8 bits to 0s
 	HICONST R4, x10		; set R4 upper 8 bits to 00010000

 	CONST R5, #0		; set R5 lower 8 bits to 0s
 	HICONST R5, #4		; set R5 upper 8 bits to 00000100


 	AND R2, R0, R2		; AND to find bit 15
 	SRL R2, R2, #15		; shift over 15 bits

	AND R3, R0, R3		; AND to find bit 13
 	SRL R3, R3, #13		; shift over 13 bits 	

 	AND R4, R0, R4		; AND to find bit 12
 	SRL R4, R4, #12		; shift over 12 bits 

 	AND R5, R0, R5		; AND to find bit 10
 	SRL R5, R5, #10		; shift over 10 bits 

 	XOR R6, R2, R3		; XOR R2 and R3 bits and store in R6
 	XOR R6, R6, R4		; XOR R4 with R6
 	XOR R6, R6, R5		; Now we have the XOR bit in R6

 	SLL R0, R0, #1		; shift number left by one
 	ADD R0, R0, R6		; add XOR bit

 	ADD R1, R1, #1		; increment counter

 	CMP R0, R7			; compare changing number to original input
 	BRz END				; if it's the same number, end
 	JMP LOOP 			; else jump to loop

 END
NOP


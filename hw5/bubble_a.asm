;; This is the data section
	.DATA
	.ADDR x4000		; Start the data at address 0x4000

	;; R0 - data address, R1 - 1st number, R2 - 2nd number, R3 - swap counter, R4 - line counter
	
global_array
	.FILL #11
	.FILL #0
	.FILL #6
	.FILL #2
	.FILL #-5
	.FILL #1
	.FILL #70
	.FILL #8
	.FILL #0
	.FILL #-1

;; Start of the code section
	.CODE
	.ADDR 0x0000		; Start the code at address 0x0000

INIT
	LEA R0, global_array	; R0 contains the address of the data
	CONST R3, 0		; R3 stores swap counter, incremented each swap
	CONST R4, 0		; R4 stores line counter, incremented each line

BODY
	ADD R4, R4, #1 		; Increment line counter by 1
	LDR R1, R0, #0		; Load first number to to R1
	LDR R2, R0, #1		; Load second number to R2
	CMP R1, R2 			; Compare both integers
	BRp SWITCH 			; if R1 > R2 branch to switch
	JMP INCRCHECK 		; jump to incrementcheck

SWITCH
	STR R1, R0, #1		; Store R1 where R2 was into memory
	STR R2, R0, #0		; Store R2 where R1 was into memory
	ADD R3, R3, #1		; Increment swap counter
	JMP INCRCHECK 		; jump to incrementcheck

INCRCHECK
	CMPI R4, #9 		; Check if we're done iterating through the 10 integers (9 swaps total)
	BRz SWAPCHECK		; if done with list, check swap count
	ADD R0, R0, #1		; Increment address
	JMP BODY			; Loop back to body

SWAPCHECK
	CMPI R3, #0 		; Check if swap count is 0
	BRz END				; If no swaps occurred, branch to end
	JMP INIT			; Reset all values

END

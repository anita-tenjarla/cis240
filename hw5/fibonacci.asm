	;; This is the data section
	;; R0 address data, R1 first fib num, R2 second fib num, R3 next calculated fib, R4 counter
	.DATA
	.ADDR x4000		; Start the data at address 0x4000
	
global_array
	.FILL #0
	.FILL #1

;; Start of the code section
	.CODE
	.ADDR 0x0000		; Start the code at address 0x0000

INIT
	LEA R0, global_array	; R0 contains the address of the data
	CONST R4, 18	; R4 stores counter, which gets decremented
	JMP TEST		; jump to counter

BODY
	LDR R1, R0, #0		; Load first fib number to add into R1
	LDR R2, R0, #1		; Load second fib number to add into R2
	ADD R3, R1, R2		; R3 stores next fib number to store
	STR R3, R0, #2		; Store R3 value into memory

	ADD R0, R0, #1		; increment the address
	ADD R4, R4, #-1		; decrement the loop counter

TEST
	CMPI R4, #0		; check if the loop counter is zero yet
	BRp BODY
END
	NOP
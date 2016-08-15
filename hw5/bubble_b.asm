;; This is the data section
	.DATA
	.ADDR x4000		; Start the data at address x4001

global_array
	.FILL #14
	.FILL #13
	.FILL #12
	.FILL #10
	.FILL #11
	.FILL #0
	.FILL #1
    .FILL #3
	.FILL #2
	.FILL #4
	.FILL #5
	.FILL #5
	.FILL #6
	.FILL #-1
	.FILL #0
	.FILL #-2


	.CODE ;; This section contains code.
	.ADDR x0000 ;; Specify address to start putting the code

;; R0 - start data address, R1 - end data address, R2 - first comp int, R3 - second comp int, R4 - swapcounter


main_start
	CONST R4, 0			; initialize swap counter to 0
	LEA R0, global_array		; initialize R0
	JSR b_sort 			; jump to b_sort
	LEAVE
END
	NOP

.FALIGN
b_sort
	LDR R2, R0, #0		; Load first value into R2
	LDR R3, R0, #1		; Load second value to R3
	CMP R2, R3 			; Compare both integers
	BRp SWITCH 			; if R2 > R3 branch to switch
	JMP LINECHECK 		; jump to linecheck
	RET


SWITCH
	STR R2, R0, #1		; Store R2 where R3 was into memory
	STR R3, R0, #0		; Store R3 where R2 was into memory
	ADD R4, R4, #1		; Increment swap counter
	JMP LINECHECK 		; jump to linecheck

LINECHECK
	ADD R0, R0, #1		; increment address counter
	CMP R0, R1			; compare current address to end address
	BRz SWAPCHECK		; if at end of data memory, check swap count
	JMP b_sort			; else loop back to b_sort

SWAPCHECK	
	CMPI R4, #0			; compare swap count to 0
	BRz LEAVE 		; if swap is 0, leave program
	CONST R4, 0		; else reset swap count to 0
	LEA R0, global_array	; reset R0 back to first mem space
	JMP b_sort		; jump back to b_sort

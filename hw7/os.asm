;;; OS Code
	.OS
	.CODE
	.ADDR x8000

; the TRAP vector table
	JMP TRAP_GETC 			; x00
	JMP TRAP_PUTC 			; x01
	JMP TRAP_PUTS 			; x02
	JMP BAD_TRAP	; x03
	JMP BAD_TRAP	; x04
	JMP TRAP_DRAW_RECT 		; x05
	JMP TRAP_DRAW_SPRITE 	; x06
	JMP BAD_TRAP	; x07
  	JMP TRAP_GETC_TIMER     ; x08	
  	JMP TRAP_LFSR_SET_SEED	; x09
  	JMP TRAP_LFSR 			; X0A
  	JMP BAD_TRAP	; x0B
  	JMP BAD_TRAP	; x0C
	JMP BAD_TRAP	; x0D
	JMP BAD_TRAP	; x0E
	JMP BAD_TRAP	; x0F
	JMP BAD_TRAP	; x10
	JMP BAD_TRAP	; x11
	JMP BAD_TRAP	; x12
	JMP BAD_TRAP	; x13
	JMP BAD_TRAP	; x14
	JMP BAD_TRAP	; x15
	JMP BAD_TRAP	; x16
	JMP BAD_TRAP	; x17
	JMP BAD_TRAP	; x18
	JMP BAD_TRAP	; x19
	JMP BAD_TRAP	; x1A
	JMP BAD_TRAP	; x1B
	JMP BAD_TRAP	; x1C
	JMP BAD_TRAP	; x1D
	JMP BAD_TRAP	; x1E
	JMP BAD_TRAP	; x1F
	JMP BAD_TRAP	; x20
	JMP BAD_TRAP	; x21
	JMP BAD_TRAP	; x22
	JMP BAD_TRAP	; x23
	JMP BAD_TRAP	; x24
	JMP BAD_TRAP	; x25
	JMP TRAP_RESET_VMEM		; x26
	JMP TRAP_BLT_VMEM		; x27

;;; OS memory address constants
USER_CODE_ADDR 	.UCONST x0000
OS_CODE_ADDR 	.UCONST x8000

OS_GLOBALS_ADDR .UCONST xA000
OS_STACK_ADDR 	.UCONST xBFFF
OS_VIDEO_ADDR 	.UCONST xC000
				
OS_KBSR_ADDR	.UCONST xFE00		; keyboard status register
OS_KBDR_ADDR	.UCONST xFE02		; keyboard data register

OS_ADSR_ADDR	.UCONST xFE04		; display status register
OS_ADDR_ADDR	.UCONST xFE06		; display data register

OS_TSR_ADDR	.UCONST xFE08			; timer register
OS_TIR_ADDR	.UCONST xFE0A			; timer interval register

OS_VDCR_ADDR .UCONST xFE0C			; video display control register

OS_VIDEO_NUM_COLS .UCONST #128
OS_VIDEO_NUM_ROWS .UCONST #124

TIM_INIT 	.UCONST #100

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;   OS & TRAP IMPLEMENTATION   ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
.CODE
.ADDR x8200
OS_START
	;; initialize timer
	LC R0, TIM_INIT
	LC R1, OS_TIR_ADDR
	STR R0, R1, #0

	;; R7 <- User code address (x0000)
	LC R7, USER_CODE_ADDR 
	RTI			; RTI removes the privilege bit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xC000 
OS_VIDEO_MEM .BLKW x3E00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; OS DATA MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xA000
;;;  LFSR value used by lfsr code
LFSR .FILL 0x0001

OS_GLOBALS_MEM	.BLKW x1000

	
.CODE
BAD_TRAP
	JMP OS_START 	; restart machine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_RESET_VMEM - In double-buffered video mode, resets the video
;;; display, i.e., turns it to black.
;;; Inputs - none
;;; Outputs - none

.CODE	
TRAP_RESET_VMEM
	LC R4, OS_VDCR_ADDR
	CONST R5, #1
	STR R5, R4, #0
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_BLT_VMEM - In double-buffered video mode, copies the contents
;;; of video memory to the video display.
;;; Inputs - none
;;; Outputs - none

.CODE
TRAP_BLT_VMEM
	LC R4, OS_VDCR_ADDR
	CONST R5, #2
	STR R5, R4, #0
	RTI
	




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_GETC - Check for a character from the keyboard
;;; Inputs - none
;;; Outputs - R0: the value of the KBSR - the MSB is 1 if a character was read
;;; 	      R1: the value of the character read from the keyboard

.CODE
TRAP_GETC
	LC R4, OS_KBSR_ADDR
	LDR R0, R4, #0		; Read the KBSR into R0
	BRzp GETC_END		; Check if the MSB is zero

	LC R4, OS_KBDR_ADDR
	LDR R1, R4, #0		; Read the character into R1
	
GETC_END

	RTI
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_PUTC - Put a character on the console
;;; Inputs - R0: ASCII character value to be output
;;; Outputs - none

.CODE
TRAP_PUTC
	LC R4, OS_ADSR_ADDR
	LDR R1, R4, #0
	BRzp TRAP_PUTC		; Loop while the MSB is zero

	LC R4, OS_ADDR_ADDR
	STR R0, R4, #0		; Write out the character
	
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_PUTS - for writing null-terminated string to ASCII display
;;; Inputs - R0: address of first character in string
;;; Outputs - none

.CODE
TRAP_PUTS
	LDR R1, R0, #0		; Load the next character into R1
	BRz END_TRAP_PUTS	; Check for the zero terminating character

	LC R2, OS_ADSR_ADDR
CHECK_ADSR
	LDR R3, R2, #0
	BRzp CHECK_ADSR		; Loop while ADSR[15] == 0 ie output not ready
	LC R2, OS_ADDR_ADDR
	STR R1, R2, #0		; Write out the character
	ADD R0, R0, #1		; Increment the pointer R0
	BRnzp TRAP_PUTS		; Go back to the top 
	
END_TRAP_PUTS
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_GETC_TIMER - for getting single character from keyboard
;;; Inputs - R0: time to wait
;;; Outputs - R0: character from keyboard or 0 otherwise


.CODE
TRAP_GETC_TIMER
	LC R1, OS_TIR_ADDR	; R1 = address of timer
	STR R0, R1, #0		; Store time to wait in timer interval

COUNT
	LC R2, OS_KBSR_ADDR ; R2 = address of keyboard status
	LDR R2, R2, #0		; R2 = value of keyboard status
	BRn KEYFOUND

	; if no key found
	LC R1, OS_TSR_ADDR 	; R1 = address of timer status
	LDR R1, R1, #0 		; R1 = value of TSR
	BRzp COUNT 			; if the timer is still not completed

	CONST R0 #0 		; if timer expired and no key found, store 0
	BRnzp END_TRAP_GETC_TIMER

KEYFOUND
	LC R0 OS_KBDR_ADDR 	; R0 = address of keyboard data
	LDR R0, R0, #0 		; R0 = value of keyboard data
	BRnzp END_TRAP_GETC_TIMER

END_TRAP_GETC_TIMER
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_LFSR - returns a shifted bit pattern
;;; Inputs - none
;;; Outputs - R0: shifted bit pattern

.CODE
TRAP_LFSR
	LEA R3, LFSR
	LDR R0, R3, 0

	SLL R1, R0, 2		; move bit 13 to MSB
	XOR R2, R0, R1		; xor with bit 15

	SLL R1, R0, 3		; move bit 12 to MSB
	XOR R2, R1, R2

	SLL R1, R0, 5		; move bit 10 to MSB
	XOR R2, R1, R2

	SRL R2, R2, 15		; Shift right logical move MSB to LSB and zeros elsewhere

	SLL R0, R0, 1		; shift left by one bit
	OR  R0, R0, R2		; add in the LSB - note upper bits of R2 are all 0

	STR R0, R3, 0		; update the LFSR in memory

	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_LFSR_SET_SEED - sets the seed value used by TRAP_LFSR
;;; Inputs - R0: initial value
;;; Outputs - none

.CODE
TRAP_LFSR_SET_SEED
	LEA R3, LFSR

	STR R0, R3, #0

	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_DRAW_RECT - draws a rectangular block on the screen.
;;; Inputs - R0: video column (left)
;;;   		 R1: video row (upper)
;;;   		 R2: width of block in pixels
;;;   		 R3: height of block in pixels
;;;   		 R4: color
;;; Outputs - video memory will be updated to place block of approriate color

.CODE
TRAP_DRAW_RECT
	;; Check if width or height is <= 0 
	CMPI R2, #0
	BRnz TRAP_DRAW_RECT_END
	CMPI R3, #0
	BRnz TRAP_DRAW_RECT_END

	;; Compute end row and store in R3
	;; R3 = MIN(OS_VIDEO_NUM_COLS, R3 + R1)	
	ADD R3, R3, R1
	LC R5 OS_VIDEO_NUM_ROWS
	CMP R3, R5
	BRnz TRAP_DRAW_RECT_L1
	LC R3 OS_VIDEO_NUM_ROWS
TRAP_DRAW_RECT_L1

	;; Compute start row and store in R1
	;; R1 = MAX(0, R1)
	CMPI R1, #0
	BRzp TRAP_DRAW_RECT_L2
	CONST R1, #0
TRAP_DRAW_RECT_L2

	;; Compute end column and store in R2
	;; R2 = MIN(OS_VIDEO_NUM_COLS, R0+R2)
	ADD R2, R2, R0
	LC R5 OS_VIDEO_NUM_COLS
	CMP R2, R5
	BRnz TRAP_DRAW_RECT_L3
	LC R2 OS_VIDEO_NUM_COLS
TRAP_DRAW_RECT_L3
	
	;; Compute start col and store in R0
	;; R0 = MAX(0, R0)
	CMPI R0, #0
	BRzp TRAP_DRAW_RECT_L4
	CONST R0, #0
TRAP_DRAW_RECT_L4

	;; Register allocation
	;; R1 - row
	;; R5 - col
	;; R6 - ptr to video memory

;;; for (row = start_row; row < end_row; ++row) {
;;;   ptr = VIDEO_MEM + row*num_cols + start_col
;;;   for (col = start_col; col < end_col; ++col, ++ptr)
;;;       *ptr = color;
;;; }
	
	JMP TRAP_DRAW_RECT_F12

TRAP_DRAW_RECT_F11

	;; Set up ptr in R6 using R5
	SLL R6, R1, #7		; R6 = R1 << 7 = R1*128
	LEA R5, OS_VIDEO_MEM
	ADD R6, R6, R5
	ADD R6, R6, R0

	ADD R5, R0, #0		; col = start_col
	JMP TRAP_DRAW_RECT_F22
TRAP_DRAW_RECT_F21
	STR R4, R6, #0		; *ptr = color
	ADD R6, R6, #1		; increment ptr
	ADD R5, R5, #1		; increment col
TRAP_DRAW_RECT_F22
	CMP R5, R2
	BRn TRAP_DRAW_RECT_F21

	ADD R1, R1, #1 		; increment row
TRAP_DRAW_RECT_F12
	CMP R1, R3
	BRn TRAP_DRAW_RECT_F11
	
TRAP_DRAW_RECT_END
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_DRAW_SPRITE - draws an 8x8 sprite on the screen. 
;;; Inputs - R0: video column (left) 
;;;          R1: video row (upper) 
;;;          R2: color 
;;;          R3: Address of sprite bitmap - an array of 8 words 
;;; Outputs - video memory will be updated to include sprite of approriate color 

.CODE 
TRAP_DRAW_SPRITE 

;; STORE R0, R1 and R7 
LEA R6, OS_GLOBALS_MEM 
STR R0, R6, #0 
STR R1, R6, #1 
STR R7, R6, #2 


;;; for (i=0; i < 8; ++i, ++ptr) { 
;;; temp = i + start_row; 
;;; if (temp < 0) continue; 
;;; if (temp >= NUM_ROWS) end; 
;;; byte = *ptr & 0xFF; 
;;; col = start_col + 7; 
;;; temp = VIDEO_MEM + (temp * 128) + col 
;;; do { 
;;; if (col >= 0 && col < NUM_COLS && byte & 0x1) 
;;; *temp = color 
;;; --col; 
;;; --temp; 
;;; byte >>= 1; 
;;; } while (byte) 
;;; } 
;;; 
;;; Register Allocation 
;;; R0 - i 
;;; R1 - temp 
;;; R2 - color 
;;; R3 - ptr 
;;; R4 - byte 
;;; R5 - col 
;;; R6 - scratch 
;;; R7 - scratch 


	CONST R0, #0 ; i = 0 
	JMP TRAP_DRAW_SPRITE_F12 

TRAP_DRAW_SPRITE_F11 

	LEA R6, OS_GLOBALS_MEM 
	LDR R1, R6, #1 ; load start_row 
	ADD R1, R1, R0 ; temp = i + start_row 
	BRn TRAP_DRAW_SPRITE_F13 ; temp < 0 continue 
	LC R7 OS_VIDEO_NUM_ROWS 
	CMP R1, R7 
	BRzp TRAP_DRAW_SPRITE_END ; (temp >= NUM_ROWS) end 
	LDR R4, R3, #0 ; byte = *ptr 
	CONST R7, 0xFF 
	AND R4, R4, R7 ; byte = byte & xFF 

	LEA R6, OS_GLOBALS_MEM 
	LDR R5, R6, #0 ; load start_col 
	ADD R5, R5, #7 ; col = start_col + 7 

	SLL R1, R1, #7 ; temp = temp * 128 
	ADD R1, R1, R5 ; temp = temp + col 
	LEA R7, OS_VIDEO_MEM 
	ADD R1, R1, R7 ; temp = temp + OS_VIDEO_MEM 

	LC R7, OS_VIDEO_NUM_COLS 

TRAP_DRAW_SPRITE_W1 

	CMPI R5, #0 
	BRn TRAP_DRAW_SPRITE_W2 ; col < 0 continue 

	CMP R5, R7 
	BRzp TRAP_DRAW_SPRITE_W2 ; col >= NUM_COLS continue 

	AND R6, R4, 0x01 
	BRz TRAP_DRAW_SPRITE_W2 ; byte & 0x1 == 0 continue 

	STR R2, R1, 0 ; *temp = color 

TRAP_DRAW_SPRITE_W2 
	
	ADD R5, R5, #-1 ; --col 
	ADD R1, R1, #-1 ; --temp 
	SRL R4, R4, #1 ; byte >>= 1 

	BRnp TRAP_DRAW_SPRITE_W1 

TRAP_DRAW_SPRITE_F13 
	ADD R0, R0, #1 ; ++i 
	ADD R3, R3, #1 ; ++ptr 
TRAP_DRAW_SPRITE_F12 
	CMPI R0, #8 
	BRn TRAP_DRAW_SPRITE_F11 

TRAP_DRAW_SPRITE_END 
	LEA R6, OS_GLOBALS_MEM 
	LDR R7, R6, #2 
RTI
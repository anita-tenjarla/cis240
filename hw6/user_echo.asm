;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File:    USER_ECHO.ASM
;;; Purpose: read characters from the keyboard, 
;;;	     then echo them back to the ASCII display
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following DATA will go into USER's DATA Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR x4000
	name_array
	.STRINGZ "Enter characters : "
	; lines above declare null-terminated string called: name_array
	
.ADDR x4200
	TEMPS 	
	.BLKW x200  
	; lines above reserve 200 words starting at x4200 for temp. variables


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x0000


;;; The following code will print out "name_array" to the ASCII display
;;; notice the loop

	LEA R4, name_array	; load address of name_array into R4
	LEA R5, TEMPS
	STR R4, R5, #0		; store pointer
	
PRINT_STRING_LOOP
	LEA R5, TEMPS
	LDR R4, R5, #0		; retrieve pointer
	LDR R0, R4, #0		; get a character from the string
	
	BRz ECHO_LOOP		; check if character is null
	
	ADD R4, R4, #1		; increment pointer
	STR R4, R5, #0		; store pointer

	TRAP x01		; display character from string
				; this calls trap: PUTC in os.asm

	JMP PRINT_STRING_LOOP
	
;;;  now that "Enter characters: " is on screen
;;;  get characters user types into keyboard
;;;  and echo them back to the screen
ECHO_LOOP


	TRAP x00 		; call trap GETC
	CMPI R0, #10	; compare character to ASCII code for carriage return
	BRz END			; if it is, branch to end

	TRAP x01		; display character

	JMP ECHO_LOOP	; go and get the next character to echo

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;   OS - TRAP VECTOR TABLE   ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.OS
.CODE
.ADDR x8000
  ; TRAP vector table
  JMP TRAP_GETC           ; x00
  JMP TRAP_PUTC           ; x01
  JMP TRAP_PUTS           ; x02
  JMP TRAP_VIDEO_COLOR    ; x03
  JMP TRAP_DRAW_PIXEL     ; x04
  JMP TRAP_DRAW_RECT      ; x05
  JMP TRAP_DRAW_SPRITE    ; x06
  JMP TRAP_TIMER          ; x07
  JMP TRAP_GETC_TIMER     ; x08
  
  JMP TRAP_LFSR_SET_SEED  ; x09
  JMP TRAP_LFSR           ; x0A


  ; CIS 240 - TO DO - add vectors for LFSR_SET_SEED & LFSR
  ; place these vectors at addresses x8009 & x8010 respectively
  ;

  OS_KBSR_ADDR .UCONST xFE00  ; alias for keyboard status reg
  OS_KBDR_ADDR .UCONST xFE02  ; alias for keyboard data reg

  OS_ADSR_ADDR .UCONST xFE04  ; alias for display status register
  OS_ADDR_ADDR .UCONST xFE06  ; alias for display data register

  OS_TSR_ADDR .UCONST xFE08 ; alias for timer status register
  OS_TIR_ADDR .UCONST xFE0A ; alias for timer interval register

  OS_VIDEO_NUM_COLS .UCONST #128
  OS_VIDEO_NUM_ROWS .UCONST #124  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; OS DATA MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xA000
;;;  LFSR value used by lfsr code
LFSR .FILL 0x0001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xC000 
OS_VIDEO_MEM .BLKW x3E00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;   OS & TRAP IMPLEMENTATION   ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x8200
.FALIGN
  ;; by default, return to usercode: PC=x0000
  CONST R7, #0   ; R7 = 0
  RTI            ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - none
;;; Outputs          - R0 = ASCII character from ASCII keyboard

.CODE
TRAP_GETC
    LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
    LDR R0, R0, #0       ; R0 = value of keyboard status reg
    BRzp TRAP_GETC       ; if R0[15]=1, data is waiting!
                             ; else, loop and check again...

    ; reaching here, means data is waiting in keyboard data reg

    LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
    LDR R0, R0, #0       ; R0 = value of keyboard data reg
    RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a single character out to ASCII display
;;; Inputs           - R0 = ASCII character to write to ASCII display
;;; Outputs          - none

.CODE
TRAP_PUTC
  LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
  LDR R1, R1, #0    	; R1 = value of display status reg
  BRzp TRAP_PUTC    	; if R1[15]=1, display is ready to write!
		    	    ; else, loop and check again...

  ; reaching here, means console is ready to display next char

  LC R1, OS_ADDR_ADDR 	; R1 = address of display data reg
  STR R0, R1, #0    	; R1 = value of keyboard data reg (R0)
  RTI			; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a string of characters out to ASCII display
;;; Inputs           - R0 = Address for first character
;;; Outputs          - none

.CODE
TRAP_PUTS

  ADD R6, R0, #0    ; R6 now contains address of first character

  CIRC
  LDR R0, R6, #0    ; R0 contains character to write
  CMPI R0, #0		; Compare R0 to null
  BRz LEAVE         ; if character is null, leave trap
  

  LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
  LDR R1, R1, #0    	; R1 = value of display status reg
  BRzp CIRC    			; if R1[15]=1, display is ready to write, otherwise loop back

  ADD R6, R6, #1    	; console ready to write, increment address of counter
  LC R1, OS_ADDR_ADDR   ; R1 = address of display data reg
  STR R0, R1, #0        ; write R0 to screen
  JMP CIRC          	; loop until string is finished
  
  LEAVE
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_VIDEO_COLOR   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Set all pixels of VIDEO display to a certain color
;;; Inputs           - R0 = color to set all pixels to
;;; Outputs          - none

.CODE
TRAP_VIDEO_COLOR
  

  ;; R0=color, R1=vid start address, R2=num rows, R3=num cols, R4=current pixel
  ;; R5=current x, R6=current y


  LEA R1, OS_VIDEO_MEM        ; R1=start address of video memory
  LC R2, OS_VIDEO_NUM_ROWS    ; R2=num rows
  LC R3, OS_VIDEO_NUM_COLS    ; R3=num cols
  CONST R5, #0                ; set current row to 0
  CONST R6, #0                ; set current column to 0


LOOP_COL

  MUL R4, R6, R3             ; R4=y*num_cols
  ADD R4, R4, R5             ; R4=R4+x
  ADD R4, R4, R1             ; Add offset to start of video mem
  STR R0, R4, #0             ; Fill in current pixel with user given color

  ADD R5, R5, #1             ; increment current x
  CMP R5, R3                 ; compare current x to total num cols
  BRzp INCR_ROW              ; if done iterating thru columns, increment row
  JMP LOOP_COL               ; else keep iterating thru row

  
  INCR_ROW
  ADD R6, R6, #1            ; increment current row
  CMP R6, R2                ; compare current row to total num rows
  BRzp EXIT                 ; if done interating thru rows, leave
  CONST R5, #0				; reset current x to 0
  JMP LOOP_COL              ; continue iteration 

  EXIT
  RTI       ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_PIXEL   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw point on video display
;;; Inputs           - R0 = row to draw on (y)
;;;                  - R1 = column to draw on (x)
;;;                  - R2 = color to draw with
;;; Outputs          - none

.CODE
TRAP_DRAW_PIXEL
  LEA R3, OS_VIDEO_MEM       ; R3=start address of video memory
  LC  R4, OS_VIDEO_NUM_COLS  ; R4=number of columns
  
  CMPIU R1, #0    	     	 ; Checks if x coord from input is > 0
  BRn END_PIXEL
  CMPIU R1, #127    	     ; Checks if x coord from input is < 127
  BRp END_PIXEL
  CMPIU R0, #0    	     	 ; Checks if y coord from input is > 0
  BRn END_PIXEL
  CMPIU R0, #123    	     ; Checks if y coord from input is < 123
  BRp END_PIXEL
  
  MUL R4, R0, R4      	     ; R4= (row * NUM_COLS)
  ADD R4, R4, R1      	     ; R4= (row * NUM_COLS) + col
  ADD R4, R4, R3      	     ; Add the offset to the start of video memory
  STR R2, R4, #0      	     ; Fill in the pixel with color from user (R2)
  
END_PIXEL
  RTI       		     	 ; PC = R7 ; PSR[15]=0
        


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_RECT   ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draws solid rectangle on the video screen at specific loc.
;;; Inputs           - R0 = x coordinate of top left corner of box
;;; Inputs           - R1 = y coordinate of top left corner of box
;;; Inputs           - R2 = width of rectangle
;;; Inputs           - R3 = height of rectangle
;;; Inputs           - R4 = color of rectangle
;;; Outputs          - none


;;data section
.DATA
.ADDR xA020   		; Start the data at address 0xA020
start_data
.FILL #0


;;code section
.CODE
TRAP_DRAW_RECT

  LEA R5, start_data    ; set R5 to start data address
  STR R7, R5, #0        ; store R7 in first data memory

  ADD R2, R2, #-1 			; what to add to init x 
  ADD R3, R3, #-1			; what to add to init y
  ADD R5, R2, R0			; R5=end x coord
  ADD R6, R3, R1			; R6=end y coord

  LC R7, OS_VIDEO_NUM_COLS  ; R7=128

CHECK_BOUNDS
  CMPI R0, #0           ; If start x is < 0, start x=0
  BRn INCREMENT_X
  CMPIU R0, #127           ; if start x > 127, don't draw anything
  BRp ENDP

   
  CMPI R5, #0       ; If end x is < 0, don't draw anything
  BRn ENDP
  CMPIU R5, #127        ; If end x > 127, decrement x until it is valid
  BRp DECREMENT_X


  CMPI R1, #0           ; If start y < 0, increment y until valid
  BRn INCREMENT_Y
  CMPIU R1, #123           ; if start y > 123, don't draw anything
  BRp ENDP	
     
  CMPI R6, #0        ; If end y < 0, don't draw anything
  BRn ENDP
  CMPIU R6, #123        ; If end y > 123, decrement y until valid
  BRp DECREMENT_Y
  JMP LOOP 			;jump to loop

 INCREMENT_X
 	CONST R0, #0		;R0=0
 	JMP CHECK_BOUNDS	;jump back to check_bounds

DECREMENT_X
	CONST R5, #127		;R5=127
	JMP CHECK_BOUNDS 	;jump back to check_bounds

INCREMENT_Y
	CONST R1, #0		;R1=0
	JMP CHECK_BOUNDS 	;jump back to check_bounds

DECREMENT_Y
	CONST R6, #123		;R3=123
	JMP CHECK_BOUNDS 	;jump back to check_bounds

;;R0=start x, R1=start y, R2=end x, R3=end y, R4= color, R5=current pixel, R6=start vid mem address
;;R7=num_cols

LOOP
  LEA R7, start_data    ; set R7 to start data address
  STR R0, R7, #1        ; store original start x in data memory
  ADD R2, R5, #0		;R2=end x
  ADD R3, R6, #0		;R3=end y

LOOPC
  LEA R6, OS_VIDEO_MEM       ; R6=start address of video memory
  LC R7, OS_VIDEO_NUM_COLS  ; R7=128

  MUL R5, R1, R7             ; R5=y*num_cols
  ADD R5, R5, R0             ; R5=R5+x
  ADD R5, R5, R6             ; Add offset to start of video mem

  STR R4, R5, #0             ; Fill in current pixel with user given color

  ADD R0, R0, #1             ; increment current x
  CMP R0, R2                 ; compare current x to end x
  BRp INCREMENT_ROW          ; if done iterating thru row, increment row
  JMP LOOPC                  ; else keep iterating thru row

  
INCREMENT_ROW
  ADD R1, R1, #1            ; increment current y
  CMP R1, R3                ; compare current y to end y
  BRp ENDP            		; if done interating thru rows, leave

  LEA R7, start_data    	; set R7 to start data address
  LDR R0, R7, #1        	; reload original R0 (starting x)
  JMP LOOPC              	; continue iteration 


ENDP
LEA R5, start_data    		; set R5 to start data address again
LDR R7, R5, #0        		; reload original R7 contents

RTI       					; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_SPRITE   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draws a circle on the video screen at a specific loc.
;;; Inputs           - R0 = x coordinate of top left corner of sprite
;;; Inputs           - R1 = y coordinate of top left corner of box
;;; Inputs           - R2 = color of the sprite
;;; Inputs           - R3 = starting address in data memory of sprite pattern
;;; Outputs          - none


;;data section
.DATA
.ADDR xA050   				; Start the data at address 0x4000
startdata
.FILL #0


;;code section
.CODE
TRAP_DRAW_SPRITE

  LEA R6, startdata    		; set R6 to start data address
  STR R7, R6, #0        	; store R7 in first data mem slot

  ADD R4, R0, #7 			; R4=end x
  ADD R5, R1, #7			; R5=end y

START_BOUNDS
  CMPI R0, #0    	     ; If start x<0, increment until valid x
  BRn INCR_X
  CMPIU R0, #127    	     ; If start x>127, nothing to be drawn
  BRp go

  CMPI R1, #0    	     ; If start y<0, increment until valid y
  BRn INCR_Y
  CMPIU R1, #123    	     ; If start y>123, nothing to be drawn
  BRp go
  JMP END_BOUNDS 		;now calculate end bounds
 

  INCR_X
  CONST R0, #0			; increment start x
  JMP START_BOUNDS		; loop back to get_bounds

  INCR_Y
  ADD R1, R1, #0 		; increment start y
  JMP START_BOUNDS   		; loop back to get_bounds

  ;;here, we have valid start x and start y
  ;;now we find valid end x and end y


END_BOUNDS
  CMPI R4, #0    	     ; If end x<0, nothing to draw
  BRn go

  CMPIU R4, #127    	     ; If end x>127, decrement end x
  BRp DECR_X

  CMPI R5, #0 			;if end y < 0, nothing to draw
  BRn go
  CMPIU R5, #123    	     ; If end y>123, decrement end y
  BRp DECR_Y
  JMP BIT_ACCESS 			 ; else jump to bit_access

DECR_X
  CONST R4, #127 		; decrement end x
  JMP END_BOUNDS 		; loop back to end_bounds

DECR_Y
  CONST R5, #123 		; decrement end y
  JMP END_BOUNDS 		; loop back to end_bounds


;;now we have valid start and end bounds
   

BIT_ACCESS 
  LEA R7, startdata  ; set R7 to start data mem
  STR R4, R7, #1 	  ; store end x in second data mem slot 
  STR R5, R7, #2	  ; store end y in third data mem slot
  STR R0, R7, #3	  ; store start x in fourth data mem slot
  STR R1, R7, #4 	  ; store start y in fifth data mem slot
  LDR R6, R3, #0	  ; R6=1st word

SET

  ;;check current x against end x
  LEA R7, startdata  ; set R7 to start data mem
  LDR R4, R7, #1 	  ; R4=end x
  CMPU R0, R4		  ;compare current x to end x
  BRp INCRROW        ;if done row, increment row

  STR R6, R3, #8	;store copy of word 8 spaces away in memory
  CONST R7, #128    ; R7=128
  AND R7, R7, R6    ; R7=word AND 10000000
  BRp DRAW_PIXEL    ; if 1, draw pixel

LOOPRET
  LDR R6, R3, #8 	; R6=modifiable word
  SLL R6, R6, #1	; shift left by 1
  STR R6, R3, #8    ; store shifted word into mem
  ADD R0, R0, #1 	; increment current x
  JMP SET

INCRROW
  LEA R7, startdata  ; set R7 to start data mem
  LDR R0, R7, #3    ;R0=start x (reset x)
  ADD R1, R1, #1	;increment y
  LDR R6, R7, #2	;R6=end y
  CMP R1, R6		;compare current y to end y
  BRp go 			;if done all rows, leave
  ADD R3, R3, #1	;else increment address memory to word
  LDR R6, R3, #0
  STR R6, R3, #8
  JMP SET 			;else jump back to loop

DRAW_PIXEL
  CONST R7, #128        ; R7=128
  LEA R6, OS_VIDEO_MEM   ; R6=video start address
  MUL R5, R1, R7		; R5=y*128
  ADD R5, R5, R0        ; R5=R5+x
  ADD R5, R5, R6   		; R5=R5+vid start address
  STR R2, R5, #0        ; set pixel to color
  JMP LOOPRET 		    ; go back to LOOPRET


go
  LEA R5, startdata    ; set R5 to start data address again
  LDR R7, R5, #0        ; reload original R7 contents

  RTI       ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: 
;;; Inputs           - R0 = time to wait in milliseconds
;;; Outputs          - none

.CODE
TRAP_TIMER
  LC R1, OS_TIR_ADDR 	; R1 = address of timer interval reg
  STR R0, R1, #0    	; Store R0 in timer interval register

COUNT
  LC R1, OS_TSR_ADDR  	; Save timer status register in R1
  LDR R1, R1, #0    	; Load the contents of TSR in R1
  BRzp COUNT    		; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R0 
    
  RTI       			; PC = R7 ; PSR[15]=0
  
  
  
;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - R0 = time to wait
;;; Outputs          - R0 = ASCII character from keyboard (or NULL)

.CODE
TRAP_GETC_TIMER

  LC R1, OS_TIR_ADDR  ; R1 = address of timer interval reg
  STR R0, R1, #0      ; Store R0 in timer interval register


CONTN
 
  LC R2, OS_KBSR_ADDR  ; otherwise R2 = address of keyboard status reg
  LDR R2, R2, #0       ; R2 = value of keyboard status reg
  BRn get_val         ; if R2[15]=1, get value
  LC R1, OS_TSR_ADDR    ; Save timer status register in R1
  LDR R1, R1, #0      ; R1=TSR contents
  BRn SET_ZERO 			;If R1[15]=1, timer has gone off, set to zero
  JMP CONTN 			;loop until timer is done



; reaching here, means data is waiting in keyboard data reg
get_val
  LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
  LDR R0, R0, #0       ; R0 = value of keyboard data reg
  JMP EXT            ; exit trap

 SET_ZERO
  CONST R0, #0        ; R0 = 0

EXT
  RTI                  ; PC = R7 ; PSR[15]=0
  
  
  
  
;;;;;;;;;;;;;;;;;;;;;;;   TRAP_LFSR_SET_SEED   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Sets seed value for TRAP_LFSR
;;; Inputs           - R0 = 16-bit number to become seed
;;; Outputs          - None

.CODE
TRAP_LFSR_SET_SEED

LEA R1, LFSR          ; R1=xA000 (LFSR)
STR R0, R1, #0        ; store contents of R0 in xA000

RTI                   ; PC = R7; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;   TRAP_LFSR   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Performs one-bit shift, stores value back in xA000
;;; Inputs           - None
;;; Outputs          - R0=shifted bit pattern
;;; R0=orig number, R1=xor bit, R2=bit15, R3=bit 13, R4=bit 12, R5=bit 10

.CODE
TRAP_LFSR

  LEA R1, LFSR        ; R1=xA000(LFSR)
  LDR R0, R1, #0      ; load contents of xA000 into R0

  CONST R6, #0         ; set xor bit to 0

  CONST R2, #0    ; set R2 lower 8 bits to 0s
  HICONST R2, x80   ; set R2 upper 8 bits to 10000000

  CONST R3, #0    ; set R3 lower 8 bits to 0s
  HICONST R3, x20   ; set R3 upper 8 bits to 00100000

  CONST R4, #0    ; set R4 lower 8 bits to 0s
  HICONST R4, x10   ; set R4 upper 8 bits to 00010000

  CONST R5, #0    ; set R5 lower 8 bits to 0s
  HICONST R5, #4    ; set R5 upper 8 bits to 00000100

  AND R2, R0, R2    ; AND to find bit 15
  SRL R2, R2, #15   ; shift over 15 bits

  AND R3, R0, R3    ; AND to find bit 13
  SRL R3, R3, #13   ; shift over 13 bits  

  AND R4, R0, R4    ; AND to find bit 12
  SRL R4, R4, #12   ; shift over 12 bits 

  AND R5, R0, R5    ; AND to find bit 10
  SRL R5, R5, #10   ; shift over 10 bits 

  XOR R6, R2, R3    ; XOR R2 and R3 bits and store in R1
  XOR R6, R6, R4    ; XOR R4 with R1
  XOR R6, R6, R5    ; Now we have the XOR bit in R1

  SLL R0, R0, #1    ; shift number left by one
  ADD R0, R0, R6    ; add XOR bit

RTI                   ; PC = R7; PSR[15]=0


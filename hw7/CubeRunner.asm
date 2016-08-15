		.DATA
speed 		.FILL #500
		.DATA
runner_x 		.FILL #60
		.DATA
runner_y 		.FILL #114
		.DATA
runner_vx 		.FILL #0
		.DATA
runner_vy 		.FILL #3
		.DATA
score 		.FILL #0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;printnum;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
printnum
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-13	;; allocate stack space for local variables
	;; function body
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRnp L4_CubeRunner
	LEA R7, L6_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L3_CubeRunner
L4_CubeRunner
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L8_CubeRunner
	LDR R7, R5, #3
	NOT R7,R7
	ADD R7,R7,#1
	STR R7, R5, #-13
	JMP L9_CubeRunner
L8_CubeRunner
	LDR R7, R5, #3
	STR R7, R5, #-13
L9_CubeRunner
	LDR R7, R5, #-13
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRzp L10_CubeRunner
	LEA R7, L12_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L3_CubeRunner
L10_CubeRunner
	ADD R7, R5, #-12
	ADD R7, R7, #10
	STR R7, R5, #-2
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #0
	STR R3, R7, #0
	JMP L14_CubeRunner
L13_CubeRunner
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	LDR R3, R5, #-1
	CONST R2, #10
	MOD R3, R3, R2
	CONST R2, #48
	ADD R3, R3, R2
	STR R3, R7, #0
	LDR R7, R5, #-1
	CONST R3, #10
	DIV R7, R7, R3
	STR R7, R5, #-1
L14_CubeRunner
	LDR R7, R5, #-1
	CONST R3, #0
	CMP R7, R3
	BRnp L13_CubeRunner
	LDR R7, R5, #3
	CONST R3, #0
	CMP R7, R3
	BRzp L16_CubeRunner
	LDR R7, R5, #-2
	ADD R7, R7, #-1
	STR R7, R5, #-2
	CONST R3, #45
	STR R3, R7, #0
L16_CubeRunner
	LDR R7, R5, #-2
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L3_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;endl;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
endl
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, L19_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L18_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;rand16;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
rand16
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	JSR lc4_lfsr
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #127
	AND R7, R7, R3
L20_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.DATA
runner 		.FILL #129
		.FILL #195
		.FILL #219
		.FILL #255
		.FILL #255
		.FILL #219
		.FILL #195
		.FILL #129
;;;;;;;;;;;;;;;;;;;;;;;;;;;;draw_cubes;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
draw_cubes
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-1
L22_CubeRunner
	CONST R7, #0
	STR R7, R5, #-2
L26_CubeRunner
	CONST R7, #0
	HICONST R7, #51
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #8
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R3, R7, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-2
	SLL R3, R3, #1
	ADD R7, R7, #1
	ADD R7, R3, R7
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_rect
	ADD R6, R6, #5	;; free space for arguments
	CONST R7, #0
	HICONST R7, #51
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #8
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R3, R7, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-2
	SLL R3, R3, #1
	ADD R7, R7, #1
	ADD R7, R3, R7
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_rect
	ADD R6, R6, #5	;; free space for arguments
	CONST R7, #0
	HICONST R7, #51
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #9
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R3, #1
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R3, R7, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-2
	SLL R3, R3, #1
	ADD R7, R7, #1
	ADD R7, R3, R7
	LDR R7, R7, #0
	ADD R7, R7, #8
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_rect
	ADD R6, R6, #5	;; free space for arguments
	CONST R7, #0
	HICONST R7, #51
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #1
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #8
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R3, R7, #0
	ADD R3, R3, #8
	ADD R6, R6, #-1
	STR R3, R6, #0
	LDR R3, R5, #-2
	SLL R3, R3, #1
	ADD R7, R7, #1
	ADD R7, R3, R7
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_rect
	ADD R6, R6, #5	;; free space for arguments
L27_CubeRunner
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-2
	LDR R7, R5, #-2
	CONST R3, #4
	CMP R7, R3
	BRn L26_CubeRunner
L23_CubeRunner
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #4
	CMP R7, R3
	BRn L22_CubeRunner
L21_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;draw_runner;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
draw_runner
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, runner
	ADD R6, R6, #-1
	STR R7, R6, #0
	CONST R7, #0
	HICONST R7, #124
	ADD R6, R6, #-1
	STR R7, R6, #0
	LEA R7, runner_y
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	LEA R7, runner_x
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_draw_sprite
	ADD R6, R6, #4	;; free space for arguments
L30_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;redraw;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
redraw
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	JSR lc4_reset_vmem
	ADD R6, R6, #0	;; free space for arguments
	JSR draw_cubes
	ADD R6, R6, #0	;; free space for arguments
	JSR draw_runner
	ADD R6, R6, #0	;; free space for arguments
	JSR lc4_blt_vmem
	ADD R6, R6, #0	;; free space for arguments
L31_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;reset_game_state;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
reset_game_state
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-2	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	LEA R3, score
	STR R7, R3, #0
	LEA R3, runner_x
	CONST R2, #60
	STR R2, R3, #0
	LEA R3, runner_y
	CONST R2, #114
	STR R2, R3, #0
	STR R7, R5, #-2
L33_CubeRunner
	LDR R7, R5, #-2
	CONST R3, #9
	MUL R3, R3, R7
	LEA R2, cube_rows
	ADD R3, R3, R2
	SLL R7, R7, #5
	STR R7, R3, #0
	CONST R7, #0
	STR R7, R5, #-1
L37_CubeRunner
	JSR rand16
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	LDR R3, R5, #-1
	SLL R3, R3, #1
	CONST R2, #9
	LDR R1, R5, #-2
	MUL R2, R2, R1
	LEA R1, cube_rows
	ADD R2, R2, R1
	ADD R2, R2, #1
	ADD R3, R3, R2
	STR R7, R3, #0
L38_CubeRunner
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #4
	CMP R7, R3
	BRn L37_CubeRunner
L34_CubeRunner
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-2
	LDR R7, R5, #-2
	CONST R3, #4
	CMP R7, R3
	BRn L33_CubeRunner
L32_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;update_cubes;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
update_cubes
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-1
L42_CubeRunner
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R3, R7, #0
	LEA R2, runner_vy
	LDR R2, R2, #0
	ADD R3, R3, R2
	STR R3, R7, #0
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	LDR R7, R7, #0
	CONST R3, #116
	CMP R7, R3
	BRn L46_CubeRunner
	CONST R7, #9
	LDR R3, R5, #-1
	MUL R7, R7, R3
	LEA R3, cube_rows
	ADD R7, R7, R3
	CONST R3, #0
	STR R3, R7, #0
	LEA R7, score
	LDR R3, R7, #0
	ADD R3, R3, #1
	STR R3, R7, #0
L46_CubeRunner
L43_CubeRunner
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #4
	CMP R7, R3
	BRn L42_CubeRunner
L41_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;update_runner;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
update_runner
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-1	;; allocate stack space for local variables
	;; function body
	LEA R7, speed
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_getc_timer
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #97
	CMP R7, R3
	BRnp L49_CubeRunner
	LEA R7, runner_vx
	CONST R3, #-2
	STR R3, R7, #0
L49_CubeRunner
	LDR R7, R5, #-1
	CONST R3, #100
	CMP R7, R3
	BRnp L51_CubeRunner
	LEA R7, runner_vx
	CONST R3, #2
	STR R3, R7, #0
L51_CubeRunner
	LEA R7, runner_x
	LDR R3, R7, #0
	LEA R2, runner_vx
	LDR R2, R2, #0
	ADD R3, R3, R2
	STR R3, R7, #0
	LDR R7, R7, #0
	CONST R3, #120
	CMP R7, R3
	BRn L53_CubeRunner
	LEA R7, runner_x
	CONST R3, #120
	STR R3, R7, #0
L53_CubeRunner
	LEA R7, runner_x
	LDR R7, R7, #0
	CONST R3, #0
	CMP R7, R3
	BRp L55_CubeRunner
	LEA R7, runner_x
	CONST R3, #0
	STR R3, R7, #0
L55_CubeRunner
L48_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;dead_runner;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
dead_runner
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	ADD R6, R6, #-4	;; allocate stack space for local variables
	;; function body
	CONST R7, #0
	STR R7, R5, #-2
L58_CubeRunner
	CONST R7, #0
	STR R7, R5, #-1
L62_CubeRunner
	LEA R7, runner_y
	LDR R7, R7, #0
	CONST R3, #9
	LDR R2, R5, #-2
	MUL R3, R3, R2
	LEA R2, cube_rows
	ADD R3, R3, R2
	LDR R3, R3, #0
	ADD R3, R3, #8
	CMP R7, R3
	BRzp L66_CubeRunner
	LEA R7, runner_x
	LDR R7, R7, #0
	STR R7, R5, #-3
	LDR R3, R5, #-1
	SLL R3, R3, #1
	CONST R2, #9
	LDR R1, R5, #-2
	MUL R2, R2, R1
	LEA R1, cube_rows
	ADD R2, R2, R1
	ADD R2, R2, #1
	ADD R3, R3, R2
	LDR R3, R3, #0
	CMP R7, R3
	BRnz L71_CubeRunner
	ADD R7, R3, #8
	LDR R3, R5, #-3
	CMP R3, R7
	BRn L70_CubeRunner
L71_CubeRunner
	LEA R7, runner_x
	LDR R7, R7, #0
	ADD R7, R7, #8
	STR R7, R5, #-4
	LDR R3, R5, #-1
	SLL R3, R3, #1
	CONST R2, #9
	LDR R1, R5, #-2
	MUL R2, R2, R1
	LEA R1, cube_rows
	ADD R2, R2, R1
	ADD R2, R2, #1
	ADD R3, R3, R2
	LDR R3, R3, #0
	CMP R7, R3
	BRnz L68_CubeRunner
	ADD R7, R3, #8
	LDR R3, R5, #-4
	CMP R3, R7
	BRzp L68_CubeRunner
L70_CubeRunner
	CONST R7, #-1
	JMP L57_CubeRunner
L68_CubeRunner
L66_CubeRunner
L63_CubeRunner
	LDR R7, R5, #-1
	ADD R7, R7, #1
	STR R7, R5, #-1
	LDR R7, R5, #-1
	CONST R3, #4
	CMP R7, R3
	BRn L62_CubeRunner
L59_CubeRunner
	LDR R7, R5, #-2
	ADD R7, R7, #1
	STR R7, R5, #-2
	LDR R7, R5, #-2
	CONST R3, #4
	CMP R7, R3
	BRn L58_CubeRunner
	CONST R7, #0
L57_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;main;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
main
	;; prologue
	STR R7, R6, #-2	;; save return address
	STR R5, R6, #-3	;; save base pointer
	ADD R6, R6, #-3
	ADD R5, R6, #0
	;; function body
	LEA R7, L73_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JSR reset_game_state
	ADD R6, R6, #0	;; free space for arguments
	JSR redraw
	ADD R6, R6, #0	;; free space for arguments
	JMP L75_CubeRunner
L74_CubeRunner
	LEA R7, L77_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
L78_CubeRunner
L79_CubeRunner
	LEA R7, speed
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_getc_timer
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	CONST R3, #114
	CMP R7, R3
	BRnp L78_CubeRunner
	JSR reset_game_state
	ADD R6, R6, #0	;; free space for arguments
	JSR redraw
	ADD R6, R6, #0	;; free space for arguments
	LEA R7, L81_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	JMP L83_CubeRunner
L82_CubeRunner
	JSR update_runner
	ADD R6, R6, #0	;; free space for arguments
	JSR update_cubes
	ADD R6, R6, #0	;; free space for arguments
	JSR dead_runner
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #0	;; free space for arguments
	CONST R3, #0
	CMP R7, R3
	BRz L85_CubeRunner
	LEA R7, L87_CubeRunner
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR lc4_puts
	ADD R6, R6, #1	;; free space for arguments
	LEA R7, score
	LDR R7, R7, #0
	ADD R6, R6, #-1
	STR R7, R6, #0
	JSR printnum
	ADD R6, R6, #1	;; free space for arguments
	JMP L75_CubeRunner
L85_CubeRunner
	JSR redraw
	ADD R6, R6, #0	;; free space for arguments
L83_CubeRunner
	JMP L82_CubeRunner
L75_CubeRunner
	JMP L74_CubeRunner
	CONST R7, #0
L72_CubeRunner
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

		.DATA
cube_rows 		.BLKW 36
		.DATA
L87_CubeRunner 		.STRINGZ "Score:"
		.DATA
L81_CubeRunner 		.STRINGZ "Press a and d to move the runner\n"
		.DATA
L77_CubeRunner 		.STRINGZ "\nPress r to reset\n"
		.DATA
L73_CubeRunner 		.STRINGZ "Welcome to CubeRunner!\n"
		.DATA
L19_CubeRunner 		.STRINGZ "\n"
		.DATA
L12_CubeRunner 		.STRINGZ "-32768"
		.DATA
L6_CubeRunner 		.STRINGZ "0"

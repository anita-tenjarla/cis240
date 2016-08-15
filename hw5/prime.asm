;;Prime function
;;Returns 1 if input prime, 0 otherwise
;;R0 = A (input), R1 = 0 or 1 (output); R2 = B; R3 = B*B; R4 = A % B


	.CODE		; This is a code segment
	.ADDR  0x0000	; Start filling in instructions at address 0x00
 
 	CMPI R0, #1		; Compare A to 1
 	BRnz ASSIGNZERO	; if (A <= 1) branch to ASSIGNZERO line

 	CONST R2 #2 ; 	Assign B to 2
 	CONST R1 #1 ; 	Assign output to 1 we assume prime until proven otherwise


 	LOOP
 	MUL R3 R2 R2 ; 	R3 = B*B
 	CMP R3 R0 ; 	Compare B*B to A
 	BRp END ; 		If B*B > A then branch to end

 	MOD R4 R0 R2 ; 	R4 = A % B
 	CMPI R4 #0 ; 	Compare R4 to 0
 	BRnp ADDONE ; 	If A not divisible by B, add one to B

 	BRnzp ASSIGNZERO ; 	If A % B == 0 then branch to ASSIGNZERO

 	ADDONE
 	ADD R2 R2 #1 	; 	B = B+1
 	BRnzp LOOP		; loop back

 	ASSIGNZERO
 	CONST R1 #0 ; 	assign output to 0 

 	END
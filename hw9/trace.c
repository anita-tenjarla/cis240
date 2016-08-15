#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include "ctrl.h" 
#include "lc4.h" 
#include "object_files.h" 
#include <stdio.h> 


//NOTE: This DOES NOT WORK. Major bugs, printed registers won't update

//print out necessary vales to std out
void printOut (unsigned short int PC, unsigned short int instruction) {
	printf("PC: %x\n",PC) ; 
	
	//define variables	
	unsigned short int opcode, opelev, opthree, opfour, rdReg, rsReg, rtReg ; 
	unsigned short int opseven, opnine, imm9, uimm7, uimm8, uimm4, optwo ; 
	signed short int imm7, imm11, imm5, imm6, imm4 ; 

	opcode = instruction >> 12 ; 
	opnine = (instruction >> 9) & 7 ; 
        opelev = instruction >> 11 ; //first 5 bits
        opthree = (instruction >> 3) & 7 ; //bits 3 to 5
        opfour = (instruction >> 4) & 3 ; //bits 4 to 5
        opseven = (instruction >> 7) & 3 ;  //bits 7 to 8
        opnine = instruction >> 9 ; //first 7 bits 

	//print branch statements
	if (opcode == 0) {
		imm9 = instruction & 0x01FF ; 
		if (opnine == 0) {
			printf("NOP\n") ; 
		} else if (opnine == 4) {
			printf("BRn %d\n",imm9) ; 
		} else if (opnine == 6) {
			printf("BRnz %d\n",imm9) ; 
		} else if (opnine == 5) {
			printf("BRnp %d\n",imm9) ;
		} else if (opnine == 2) {
			printf("BRz %d\n",imm9) ;
		} else if (opnine == 3) {
			printf("BRzp %d\n",imm9) ;
		} else if (opnine == 1) {
			printf("BRp %d\n",imm9) ;
		} else if (opnine == 7) {
			printf("BRnzp %d\n",imm9) ;
		}

	//print arithmetic functions
	} else if (opcode == 1) {
		rdReg = (instruction >> 9) & 7 ; 
		rsReg = (instruction >> 6) & 7 ; 
		rtReg = instruction & 7 ; 
		imm5 = instruction & 0x1F ; 

		if (opthree == 0) {
			printf("ADD R%d R%d R%d\n", rdReg, rsReg, rtReg) ; 
		} else if (opthree == 1) {
                        printf("MUL R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree == 2) {
                        printf("SUB R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree == 3) {
                        printf("DIV R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree >= 4) {
                        printf("ADD R%d R%d %d\n", rdReg, rsReg, imm5) ;
                } 

	//print compare functions
	} else if (opcode == 2) {
		rsReg = (instruction >> 9) & 7 ;
                rtReg = instruction & 7 ;
		imm7 = instruction & 0x7F ; 
		uimm7 = instruction & 0x7F ; 

		if (opseven == 0) {
			printf("CMP R%d R%d\n", rsReg, rtReg) ; 
		} else if (opseven == 1) {
                        printf("CMPU R%d R%d\n", rsReg, rtReg) ;
                } else if (opseven == 2) {
			printf("CMPI R%d %d\n", rsReg, imm7) ;
		} else if (opseven == 3) {
                        printf("CMPIU R%d %d\n", rsReg, uimm7) ;
		}

	//jump statements
	} else if (opelev == 9) {
		imm11 = instruction & 0x7FF ; 
		printf("JSR %d\n", imm11) ; 
	} else if (opelev == 8) {
		rsReg = (instruction >> 6) & 7 ; 
		printf("JSRR R%d\n", rsReg) ; 
	
	//logical operators
	} else if (opcode == 5) {
		rdReg = (instruction >> 9) & 7 ;
                rsReg = (instruction >> 6) & 7 ;
                rtReg = instruction & 7 ;
                imm5 = instruction & 0x1F ;

                if (opthree == 0) {
                        printf("AND R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree == 1) {
                        printf("NOT R%d R%d\n", rdReg, rsReg) ;
                } else if (opthree == 2) {
                        printf("OR R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree == 3) {
                        printf("XOR R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                } else if (opthree >= 4) {
                        printf("ADD R%d R%d %d\n", rdReg, rsReg, imm5) ;
                }

	//ldr
	} else if (opcode == 6) {
		rdReg = (instruction >> 9) & 7 ; 
		rsReg = (instruction >> 6) & 7 ; 
		imm6 = instruction & 0x3F ; 
		printf("LDR R%d R%d %d\n", rdReg, rsReg, imm6) ;

	//str
	} else if (opcode == 7) {
		rdReg = (instruction >> 9) & 7 ;
                rsReg = (instruction >> 6) & 7 ;
                imm6 = instruction & 0x3F ;
                printf("STR R%d R%d %d\n", rdReg, rsReg, imm6) ; 
	
	//rti
	} else if (opcode == 8) {
		printf("RTI\n") ; 
	
	//const
	} else if (opcode == 9) {
		rdReg = (instruction >> 9) & 7 ;
		imm9 = instruction & 0x01FF ;
		printf("CONST R%d %d\n", rdReg, imm9) ; 

	//shift operators
	} else if (opcode == 10) {
		rdReg = (instruction >> 9) & 7 ;
                rsReg = (instruction >> 6) & 7 ;
		uimm4 = instruction & 15 ; 
		optwo = (instruction >> 4) & 3 ; 
		rtReg = instruction & 7 ; 
		
		if (optwo == 0) {
			printf("SLL R%d R%d %d\n", rdReg, rsReg, uimm4) ;
		} else if (optwo == 1) {
                        printf("SRA R%d R%d %d\n", rdReg, rsReg, uimm4) ;
                } else if (optwo == 2) {
                        printf("SRL R%d R%d %d\n", rdReg, rsReg, uimm4) ;
                } else if (optwo == 3) {
                        printf("MOD R%d R%d R%d\n", rdReg, rsReg, rtReg) ;
                }
	
	//jmpr
	} else if (opelev == 18) {
		rsReg = (instruction >> 6) & 7 ; 
		printf("JMPR R%d\n", rsReg) ; 
	
	//jmp 
	} else if (opelev == 19) {
		imm11 = instruction & 0x7FF ;
		printf("JMP %d\n", imm11) ; 
	
	//hiconst
	} else if (opcode == 13) {
		rdReg = (instruction >> 9) & 7 ;
		uimm8 = instruction & 0xFF ; 
		printf("HICONST R%d %d\n", rdReg, uimm8) ; 

	//trap
	} else if (opcode == 15) {
		uimm8 = instruction & 0xFF ; 
		printf("TRAP %d\n", uimm8) ; 
	}
}


int main(int argc, char **argv) {

	//declare some variables
	int i, stateValue ;
	unsigned short int statePC, stateInstruction ; 
	machine_state state ;
	FILE *outputFile ; 	

	
	//check arg length if valid
	if (argc < 3) {
		printf("Not enough arguments into main") ; 
		exit(-1) ; 
	}
	
	//initialize output file
	outputFile = fopen(argv[2],"wb") ; 
	if (outputFile == NULL) {
		printf("Output file can't be opened") ; 
		exit(-1) ; 
	} 

	reset(&state) ; 

	//initialize object files for reading input
	for (i = 3 ; i < argc ; i++) {
		if (read_object_file(argv[i], &state) == 1) {
			printf("Can't open obj file to read") ; 
			// free(state) ; 
			fclose(outputFile) ; 
			exit(-1) ; 
		} 	
	} 

	//initialize state simulation pc and instruction
	statePC = state.PC ;
	stateInstruction = state.memory [statePC] ; 

	while (statePC != 0x80FF) {
		
		//update machine state
		stateValue = update_state(&state) ; 		

		//check errors
		if (stateValue >= 1 && stateValue<= 3) {
			fclose(outputFile) ; 
			exit(1) ; 
		
		//if working, print out to output file
		} else if (stateValue == 0) {
			fwrite(&statePC, sizeof(unsigned short int), 1, outputFile) ; 
			fwrite(&stateInstruction, sizeof(unsigned short int), 1, outputFile) ; 
		}


		//print out the pc, instruction, register values, psr, and nzp bits 
		printOut(statePC,stateInstruction) ; 
		statePC = state.PC ; 
		stateInstruction = state.memory [statePC] ; 
		unsigned short int r0Val, r1Val, r2Val, r3Val, r4Val, r5Val, r6Val, r7Val ;
        	r0Val = state.R[0] ;
        	r1Val = state.R[1] ;
        	r2Val = state.R[2] ;
        	r3Val = state.R[3] ;
        	r4Val = state.R[4] ;
        	r5Val = state.R[5] ;
        	r6Val = state.R[6] ;
        	r7Val = state.R[7] ;
        	printf("R0: %x, R1: %x, R2: %x, R3: %x",r0Val,r1Val,r2Val,r3Val) ;
        	printf("R4: %x, R5: %x, R6: %x, R7: %x",r4Val,r5Val,r6Val,r7Val) ;
        	int psrbit = (state.PSR) >> 15 ;
        	printf("PSR[15]: %u",psrbit) ;
        	int nzp1 = (state.PSR) & 4 ;
        	int nzp2 = (state.PSR) & 2 ;
        	int nzp3 = (state.PSR) & 1 ;
        	printf("NZP: %u %u %u",nzp1,nzp2,nzp3) ;
	} 

	printf("Trace completed with no errors\n") ; 
	fclose(outputFile) ; 
	return 0 ; 	 
}

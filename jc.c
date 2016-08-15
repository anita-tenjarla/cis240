#define MAX_TOKEN_LENGTH 250
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "token.h"

//I didn't get to implementing ifs but I 
//implemented everything else

int main (int argc, char *argv[]) {
	//define variables
	FILE *readIn ;
	FILE *writeOut ;  
	int i = 0 ;
	token tok ;  
	int len ;  
	char* origName ; 
	char* str ; 	

	//arg check
	if (argc < 2) {
		printf("Arg 1 must be filename\n") ; 
		exit(1) ; 
	} 

	readIn = fopen(argv[1], "r") ;

	//get asm file name  	
	len = strlen(argv[1]) ;
	char fileName[len+2] ;
	origName = argv[1] ;
	
	for (i = 0 ; i <= len-2 ; i++) {
		fileName[i] = origName[i] ;
	} 
	fileName[len-1] = 'a' ;
	fileName [len] = 's' ;
	fileName [len+1] = 'm' ;
	fileName [len+2] = '\0' ;
	
	writeOut = fopen(fileName,"w") ; 	
	
	//check for errors in opening file
	if (!readIn) {
		printf("Errors encountered when opening file\n") ; 
		exit(1) ; 
	} 

	//by this point, we have opened our in and out files	

	fprintf(writeOut, "%s\n", ".CODE") ;
	fprintf(writeOut, "%s\n\n", ".FALIGN") ;

	int j ; 
	int num_comp = 0 ; 

	while (1) {
		j = read_token(&tok, readIn) ;

		if (j != 0) {
			break ; 
		} 

		//function is being defined, write out prologue
		if (tok.type == 0) {
			//printf("defun read") ; 
			read_token(&tok,readIn) ;
			str = tok.str ;  
			//printf("next token is: %s\n", str) ; 
			fprintf(writeOut,"%s\n",str) ;
			fprintf(writeOut,"     %s\n","STR R7, R6, #-2 ; prologue") ;
			fprintf(writeOut,"     %s\n","STR R5, R6, #-3 ;") ;
			fprintf(writeOut,"     %s\n","ADD R6, R6, #-3 ;") ;
			fprintf(writeOut,"     %s\n\n","ADD R5, R6, #0 ;") ;

		} 

		//function is ident
                else if (tok.type == 1) {
                        fprintf(writeOut,"     %s %s %s\n\n","JSR", tok.str, "; JSR to func") ;
                }

		//tok type is return
		else if (tok.type == 2) {
			fprintf(writeOut,"     %s\n","ADD R6, R5, #0 ; epilogue") ;
			fprintf(writeOut,"     %s\n","ADD R6, R6, #3 ;") ;
			fprintf(writeOut,"     %s\n","STR R7, R6, #-1 ;") ;
			fprintf(writeOut,"     %s\n","LDR R5, R6, #-3 ;") ;
			fprintf(writeOut,"     %s\n","LDR R7, R6, #-2 ;") ; 
			fprintf(writeOut,"     %s\n","ADD R6, R6, #-1 ; ") ;
			fprintf(writeOut,"     %s\n","RET ;") ;
		}

		//tok type is literal, allocate space for local variable and assign
		else if (tok.type == 24) {
			fprintf(writeOut,"     %s\n","ADD R6, R6, #-1 ; store literal in memory") ;
			int orig_value, imm9, uimm8 ; 
			orig_value = tok.literal_value ;
			imm9 = orig_value & 0x1FF ; 
			uimm8 = (orig_value & 0xFF00) >> 8 ; 
			fprintf(writeOut,"     %s%d %s\n","CONST R7, #", imm9, " ;") ;
			if (uimm8 > 0) {
				fprintf(writeOut,"     %s %x %s\n","HICONST R7",uimm8," ; ") ; 
			} 
			fprintf(writeOut, "     %s\n\n", "STR R7, R6, #0 ; " ) ; 
		}  

		//tok type is add
		else if (tok.type == 3) {
			fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; add") ;
			fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
			fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
			fprintf(writeOut,"     %s\n","ADD R7, R0, R1 ; ") ;
			fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
		}	

		//tok type is subtract
                else if (tok.type == 4) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; subtract") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","SUB R7, R0, R1 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is mult
		else if (tok.type == 5) {
			fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; multiply") ; 
			fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
			fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;  
			fprintf(writeOut,"     %s\n","MUL R7, R0, R1 ; ") ; 
			fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ;") ;
		}  

		//tok type is div
                else if (tok.type == 6) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; division") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","DIV R7, R0, R1 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is mod
                else if (tok.type == 7) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; mod") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","MOD R7, R0, R1 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is and
                else if (tok.type == 8) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; and") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","AND R7, R0, R1 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is or 
                else if (tok.type == 9) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; or") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","OR R7, R0, R1 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is not 
                else if (tok.type == 10) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; not") ;
                        fprintf(writeOut,"     %s\n","NOT R7, R0 ; ") ;
                        fprintf(writeOut,"     %s\n\n","STR R7, R6, #0 ; ") ;
                }

		//tok type is lt 
                else if (tok.type == 11) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; less than computation") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ; 
			fprintf(writeOut,"     %s\n","CMP R0, R1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","BRn LT_TRUE",num_comp," ; ") ;
			fprintf(writeOut,"     %s_%d %s\n\n","BRnzp LT_FALSE",num_comp," ; ") ; 
			
			fprintf(writeOut,"%s_%d\n","LT_TRUE",num_comp) ; 
			fprintf(writeOut,"     %s\n","CONST R2 #1 ; ") ; 
			fprintf(writeOut,"     %s_%d %s\n","JMP LT_COMP",num_comp," ; ") ; 
	
			fprintf(writeOut,"%s_%d\n","LT_FALSE",num_comp ) ; 
			fprintf(writeOut,"     %s\n\n","CONST R2 #0 ;") ;

			fprintf(writeOut,"%s_%d\n","LT_COMP",num_comp) ; 
			fprintf(writeOut,"     %s\n\n","STR R2, R6, #0 ; ") ;
			num_comp++ ;   
                }

		//tok type is le
                else if (tok.type == 12) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; leq computation") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","CMP R0, R1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","BRnz LE_TRUE",num_comp," ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n\n","BRnzp LE_FALSE",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","LE_TRUE",num_comp) ;
                        fprintf(writeOut,"     %s\n","CONST R2 #1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","JMP LE_COMP",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","LE_FALSE",num_comp ) ;
                        fprintf(writeOut,"     %s\n\n","CONST R2 #0 ;") ;

                        fprintf(writeOut,"%s_%d\n","LE_COMP",num_comp) ;
                        fprintf(writeOut,"     %s\n\n","STR R2, R6, #0 ; ") ;
                        num_comp++ ;
                }

		//tok type is eq
                else if (tok.type == 13) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; equal comparison") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","CMP R0, R1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","BRz EQ_TRUE",num_comp," ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n\n","BRnzp EQ_FALSE",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","EQ_TRUE",num_comp) ;
                        fprintf(writeOut,"     %s\n","CONST R2 #1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","JMP EQ_COMP",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","EQ_FALSE",num_comp ) ;
                        fprintf(writeOut,"     %s\n\n","CONST R2 #0 ;") ;

                        fprintf(writeOut,"%s_%d\n","EQ_COMP",num_comp) ;
                        fprintf(writeOut,"     %s\n\n","STR R2, R6, #0 ; ") ;
                        num_comp++ ;
                }

		//tok type is ge
                else if (tok.type == 14) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; greater/equal computation") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","CMP R0, R1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","BRzp GE_TRUE",num_comp," ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n\n","BRnzp GE_FALSE",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","GE_TRUE",num_comp) ;
                        fprintf(writeOut,"     %s\n","CONST R2 #1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","JMP GE_COMP",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","GE_FALSE",num_comp ) ;
                        fprintf(writeOut,"     %s\n\n","CONST R2 #0 ;") ;

                        fprintf(writeOut,"%s_%d\n","GE_COMP",num_comp) ;
                        fprintf(writeOut,"     %s\n\n","STR R2, R6, #0 ; ") ;
                        num_comp++ ;
                }

		//tok type is gt
                else if (tok.type == 15) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; greater than computation") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; ") ;
                        fprintf(writeOut,"     %s\n","CMP R0, R1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","BRp GT_TRUE",num_comp," ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n\n","BRnzp GT_FALSE",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","GT_TRUE",num_comp) ;
                        fprintf(writeOut,"     %s\n","CONST R2 #1 ; ") ;
                        fprintf(writeOut,"     %s_%d %s\n","JMP GT_COMP",num_comp," ; ") ;

                        fprintf(writeOut,"%s_%d\n","GT_FALSE",num_comp ) ;
                        fprintf(writeOut,"     %s\n\n","CONST R2 #0 ;") ;

                        fprintf(writeOut,"%s_%d\n","GT_COMP",num_comp) ;
                        fprintf(writeOut,"     %s\n\n","STR R2, R6, #0 ; ") ;
                        num_comp++ ;
                }

		//tok type is drop
		else if (tok.type == 19) {
			fprintf(writeOut,"     %s\n","ADD R6, R6, #1 ; drop command") ; 
		} 

		//tok type is dup 
		else if (tok.type == 20) {
			fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; duplicate ") ; 
			fprintf(writeOut,"     %s\n","ADD R6, R6, #-1 ; ") ; 
			fprintf(writeOut,"     %s\n","STR R0, R6, #0 ; ") ; 
		} 

		//tok type is swap
		else if (tok.type == 21) {
			fprintf(writeOut,"     %s\n","LDR R0, R6, #0 ; swap ") ; 
			fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ; ") ; 
			fprintf(writeOut,"     %s\n","STR R1, R6, #0 ; ") ; 
			fprintf(writeOut,"     %s\n","STR R0, R6, #1 ; ") ; 
		} 

		//tok type is rot
                else if (tok.type == 22) {
                        fprintf(writeOut,"     %s\n","LDR R0, R6, #2 ; rotate") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #1 ;") ;
                        fprintf(writeOut,"     %s\n","STR R1, R6, #2 ;") ;
                        fprintf(writeOut,"     %s\n","LDR R1, R6, #0 ;") ;
                        fprintf(writeOut,"     %s\n","STR R1, R6, #1 ;") ;
                        fprintf(writeOut,"     %s\n\n","STR R0, R6, #0 ;") ;
                }

		//tok type is arg
		else if (tok.type == 23) {
			int j = 0 ; 
			int num_arg ;
			int offset ; 
			num_arg = tok.arg_no ; 
			
			if (num_arg > 20) {
				printf("Too many arguments!\n") ; 
				break ; 
			} 

			offset = 2 + num_arg ; 
			fprintf(writeOut,"     %s%d %s\n","LDR R0, R5, #",offset," ; arg command") ;
			fprintf(writeOut,"     %s\n","ADD R6, R6, #-1 ; ") ; 
			fprintf(writeOut,"     %s\n","STR R0, R6, #0 ; ") ;
		} 	
	}

	//printf("About to close files\n") ; 
	fclose(readIn) ;  
	fclose(writeOut) ; 
}

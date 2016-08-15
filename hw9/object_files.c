#include "ctrl.h"
#include "lc4.h" 
#include "object_files.h" 
#include <stdio.h>
#include <stdlib.h>


int read_object_file(char* filename, machine_state* state) {
	
	//define some variables
	unsigned short int hexbit, address, numwords, value, numchars, num, lower, upper = 0; 
	int i ; 

	//initialize and open incoming binary file
	FILE *objectFile ; 
	objectFile = fopen(filename, "rb"); 

	//check if filename is invalid
	if (objectFile == NULL) {
		printf("Input file doesn't exist") ; 
		return -1 ; 
	}

	while(fread(&hexbit, sizeof(unsigned short int), 1, objectFile) == 1) {

		//undo little endian formatting
		lower = (hexbit & 0xFF00) >> 8 ; 
		upper = (hexbit & 0x00FF) << 8 ; 
		num = upper | lower ; 
		
		//check if read in value is code or data section header
		if (num == 0xCADE ||num  == 0xDADA) {
			
			//read in address of label and numwords (next two args in file)
			fread(&address, sizeof(unsigned short int), 1, objectFile) ; 
			fread(&numwords, sizeof(unsigned short int), 1, objectFile) ; 


			//undo little endian on address and numwords
			lower = (address & 0xFF00) >> 8 ;
                	upper = (address & 0x00FF) << 8 ;
                	address = upper | lower ;
			lower = (numwords & 0xFF00) >> 8 ;
                	upper = (numwords & 0x00FF) << 8 ;
                	numwords = upper | lower ;

			//load in each word instruction in numwords to machine state memory
			for (i = 0; i < numwords; i++) {
				fread(&value, sizeof(unsigned short int), 1, objectFile) ;
				lower = (value & 0xFF00) >> 8 ;
                		upper = (value & 0x00FF) << 8 ;
                		value = upper | lower ;
				state -> memory[address] = value ;
				value = 0 ;  
				address++ ;  
			}

		//check if read in value is symbol header
		} else if (num == 0xC3B7) {
			//read in address and num characters of body, skip these characters
			fread(&address, sizeof(unsigned short int), 1, objectFile) ; 
			fread(&numchars, sizeof(unsigned short int), 1, objectFile) ; 
			
			//fix little endian on address and numchars
			lower = (address & 0xFF00) >> 8 ;
                	upper = (address & 0x00FF) << 8 ;
                	address = upper | lower ;
			lower = (numchars & 0xFF00) >> 8 ;
                	upper = (numchars & 0x00FF) << 8 ;
                	numchars = upper | lower ;

			//read characters but don't do anything, just skip
			for (i = 0; i < numchars; i++) {
				fread(&value, sizeof(unsigned char), 1, objectFile) ;
				//printf("%x\n", value) ; 
			}
			
		//check if read in value is file name header
		} else if (num == 0xF17E) {
			fread(&numchars, 1, 1, objectFile) ; 
			
			//fix little endian on numchars
			lower = (numchars & 0xFF00) >> 8 ;
                	upper = (numchars & 0x00FF) << 8 ;
                	numchars = upper | lower ;
				
			//read characters but don't do anything, just skip
			for (i = 0; i < numchars; i++) {
				fread(&value, 1, 1, objectFile) ;
			}

		//check if read in value is line number header (skip next 3 words)
		} else if(num == 0x715E) {
			for (i=0 ; i < 3; i++) {
				fread(&value, sizeof(unsigned short int), 1, objectFile) ;
			}

		//check for file format error, this was unsuccessful
		} else {
			printf("File format error, can't continue reading properly") ;
			fclose(objectFile) ;
			return -1 ;
		}
	}
	//close file, this was successful
	fclose(objectFile) ; 
	return 0; 
}

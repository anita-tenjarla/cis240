#define MAX_TOKEN_LENGTH 250

#include <ctype.h> 
#include <stdio.h>
#include <stdlib.h> 
#include "token.h"
#include <string.h> 

int read_token (token *theToken, FILE *theFile) {

  int i ;  
  char c = getc(theFile) ;
  int argno ;

  //get token into token string field
  while (1) {

    if (c == EOF) {
    	//printf("Reached end of file\n") ; 
    	return 1 ;
	break ;  
    } else if (isspace(c)) {
    	while (isspace(c)) {
    		c = getc(theFile) ; 
		//printf("Character read from space case: %c\n",c) ; 
    	}
      	//c = getc(theFile) ; 
    } else if (c == ';') {
    	while (c != '\n') {
    		c = getc(theFile) ;
    	}	
      	c = getc(theFile) ;
	//printf("Character read from ; case: %c\n",c) ;
      	//c = getc(theFile) ;
    } else {
    	for (i = 0 ; i < MAX_TOKEN_LENGTH ; i++) {
    		if (isspace(c) || c == EOF) {
			theToken -> str[i] = '\0' ; 
    			break ; 
    		}
    		theToken -> str[i] = c ; 
    		c = getc(theFile) ;
		//printf("Character read from reading case: %c\n",c) ;
    	}
    	break ; 
    }  
  }

//printf("Just read string: %s\n", theToken -> str) ;

  //populate fields

  //check hex literal
  if ((theToken -> str[0] == '0') && (theToken -> str[1] == 'x')) {
  	for (i = 2; i < strlen(theToken -> str) ; i++) {
  		if (!isxdigit(theToken -> str[i])) {
  			printf("Attempting to pass improper hex value\n") ;
  			return 1 ; 
  		}
  	}

  	theToken -> type = LITERAL ; 
  	sscanf(theToken -> str, "%x", &(theToken -> literal_value)) ;
	return 0 ; 

  //check decimal literal
  } else if (((theToken -> str[0] == '-') && isdigit(theToken -> str[1])) || 
  		isdigit(theToken -> str[0])) {
  	for (i = 1 ; i < strlen(theToken -> str) ; i++) {
  		if (!isdigit(theToken -> str[i])) {
  			printf("Attempting to pass improper decimal value\n") ;
  			return 1 ; 
  		}
  	}

  	theToken -> type = LITERAL ;
  	sscanf(theToken -> str, "%d", &(theToken -> literal_value)) ;
	return 0 ; 	
  
  //defun type
  } else if (strcmp (theToken -> str, "defun") == 0) {
    theToken -> type = DEFUN;
    return 0 ; 

  //return type
  } else if (strcmp (theToken -> str, "return") == 0) {
    theToken -> type = RETURN;
    return 0 ; 
  
  //addition type
  } else if (strcmp (theToken -> str, "+") == 0) {
    theToken -> type = PLUS;
    return 0 ; 
  
  //subtraction type
  } else if (strcmp (theToken -> str, "-") == 0) {
    theToken -> type = MINUS;
    return 0 ; 

  //multiplication type
  } else if (strcmp (theToken -> str, "*") == 0) {
    theToken -> type = MUL;
    return 0 ; 

  //division type
  } else if (strcmp (theToken -> str, "/") == 0) {
    theToken -> type = DIV;
    return 0 ; 
  
  //mod type
  } else if (strcmp (theToken -> str, "%") == 0) {
    theToken -> type = MOD;
    return 0 ; 
  
  //and type
  } else if (strcmp (theToken -> str, "and") == 0) {
    theToken -> type = AND;
    return 0 ; 
  
  //or type
  } else if (strcmp (theToken -> str, "or") == 0) {
    theToken -> type = OR;
    return 0 ; 

  //not type
  } else if (strcmp (theToken -> str, "not") == 0) {
    theToken -> type = NOT;
    return 0 ; 

  //less than type
  } else if (strcmp (theToken -> str, "lt") == 0) {
    theToken -> type = LT;
    return 0 ; 
  
  //less than equal type
  } else if (strcmp (theToken -> str, "le") == 0) {
    theToken -> type = LE;
    return 0 ; 
  
  //equal type
  } else if (strcmp (theToken -> str, "eq") == 0) {
    theToken -> type = EQ;
    return 0 ; 
  
  //greater equal type
  } else if (strcmp (theToken -> str, "ge") == 0) {
    theToken -> type = GE;
    return 0 ; 
  
  //greater than type
  } else if (strcmp (theToken -> str, "gt") == 0) {
    theToken -> type = GT;
    return 0 ; 
  
  //if type
  } else if (strcmp (theToken -> str, "if") == 0) {
    theToken -> type = IF;
    return 0 ; 
  
  //else type
  } else if (strcmp (theToken -> str, "else") == 0) {
    theToken -> type = ELSE;
    return 0 ; 
  
  //end if statement type
  } else if (strcmp (theToken -> str, "endif") == 0) {
    theToken -> type = ENDIF;
    return 0 ; 
  
  //drop type
  } else if (strcmp (theToken -> str, "drop") == 0) {
    theToken -> type = DROP;
    return 0 ; 
  
  //dup type
  } else if (strcmp (theToken -> str, "dup") == 0) {
    theToken -> type = DUP;
    return 0 ; 
  
  //swap type
  } else if (strcmp (theToken -> str, "swap") == 0) {
    theToken -> type = SWAP;
    return 0 ; 
  
  //rot type
  } else if (strcmp (theToken -> str, "rot") == 0) {
    theToken -> type = ROT;
    return 0 ; 
  
  //arg type
  } else if ((theToken -> str[0] == 'a') && (theToken -> str[1] == 'r') 
		&& (theToken -> str[2] == 'g')) {
    theToken -> type = ARG ; 
    sscanf(theToken -> str, "arg%d", &(theToken -> arg_no)) ; 
    return 0 ; 

/*  } else if (sscanf(theToken -> str, "arg%n", &argno) == 1) {
    theToken -> type = ARG;
    theToken -> arg_no = argno ; 
    return 0 ; */


  
  //if none of the above, then it's a broken token
  } else {
    //first character of ident must alphabetical
    if (isalpha(theToken -> str[0]) == 0) {
	theToken -> type = BROKEN_TOKEN ; 
	printf("Encountered broken token\n") ; 
    } 

    //all other characters must be alphabet, digit, or underscore
    for (i = 1 ; i < strlen(theToken -> str) ; i++) {
	if ((isalpha(theToken -> str[i]) == 0) && 
		(isdigit(theToken -> str[i]) == 0) && (theToken -> str[i] != '_')) {
		theToken -> type = BROKEN_TOKEN ; 
		printf("Encountered broken token\n") ;
		printf("%s\n",theToken->str) ;  
		return 1 ; 
	} 
    } 
     
    theToken -> type = IDENT ;
    return 0;
  }

  return 0 ; 

}

// Extra functions which you may wish to define and use , or not
//const char *token_type_to_string (int type) {

//}

void print_token (token *theToken) {
	printf("Token type: %u\n",theToken -> type) ;
	printf("Token string: %s\n", theToken -> str) ;  
}

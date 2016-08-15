#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "queue.h"

//constructor for stack
typedef struct node {
        double value ;
        struct node *next ; /*pointer to its own kind */
} double_node ;

//push something into stack
double_node* push (double_node *head, double token) {

	double_node *temp ; 
	temp = malloc(sizeof(double_node)) ; 
        if (temp == NULL) { 
		printf("fail") ; 
		exit(-1) ; 
	} 
	temp -> value = token ;
        temp -> next = head ;
        return (temp) ;
}

//pop something from stack
double_node* pop(double_node *head) { 

	if (head == NULL) {
	  	printf("STACK ERROR\n") ; 
		return NULL ; 
	} else {
		double_node *next_node;
        	next_node = head->next ; 
		free(head) ;
        	return next_node ;
	}
} 

//trim whitespace from input
char* trim(char *str) {
	char *end ; 
	while(isspace(*str)) {
		str++ ; 
	}
	if (*str==0) { 
		return str ; 
	} 
	end = str + strlen(str) - 1 ; 
	while (end > str && isspace(*end)) {
		end-- ; 
	} 
	*(end+1) = 0 ; 
	return str ; 
}


int main() {
	//define stack and queue heads here
	double_node *head = NULL ; 
	string_node *q_head = NULL ; 

	//enter neverending while loop waiting for user input
	while(1) {
		//get input from stdin
		char str [100] ; 
		double numInput, output ;
	  	fgets(str,100,stdin) ;
	  	numInput = atof(str) ;  		
	
		//if input is a double, push into stack
	  	if (numInput != 0) {
	    		head=push(head, numInput) ;
	     		printf("%lf\n",head->value) ;    

		//if not a double, trim and make lowercase
	  	} else { 
	     		char* strn ; 
	     		strn = trim(str) ;    
	     
			for (int i = 0; strn[i]; i++) {
				strn[i] = tolower(strn[i]) ; 
	     		}  
		
			//if def arg, store into queue and print out
	     		if (strncmp(strn,"def",3)==0) {
          			const char s[2] = " " ; 
				char *tok ;
          			tok = strtok(strn,s) ;
          			while(tok != NULL ) {
                			printf("%s\n", tok) ;
					q_head = q_push(q_head,tok) ; 
                			tok = strtok(NULL,s) ;
          			} 
	     		}

			//if print_func arg, print out queue (doesn't work)
			if (strcmp(strn,"print_func")==0) {
				string_node *temp ; 
				temp = q_head ; 
				while(temp != NULL) {
					printf("%s\n",temp->value) ; 
					temp = temp->next ; 
				}
			}
	
			//if + arg, add both previous inputs
	     		if (strn[0] == '+') {
				if (head == NULL) {
					printf("STACK ERROR\n") ; 
					continue ; 
				} else if((head->next)==NULL) { 
					head = pop(head) ; 
					printf("STACK ERROR\n") ;  
				} else {
					double a, b, in, out ;
					//double_node* c ;  
					a = head->value ;
					head = pop(head) ;
					b = head->value ;   
					out = a+b ; 
					//in = a + b ; 
					head = pop(head) ;  
					head = push(head, out) ; 
					printf("%lf\n",out) ;
	    			}
			}
	    
			//subtract two inputs 
	    		if (strn[0] == '-') {
				if (head == NULL) {
					printf("STACK ERROR\n") ; 
				} else if((head->next)==NULL) {
					head = pop(head) ; 
					printf("STACK ERROR\n") ; 
				} else {
					double a, b, in, out ; 
					a = head -> value ; 
					head = pop(head) ; 
					b = head -> value ; 
					out = b-a;  
					//in = b - a ; 
					head = pop(head) ; 
					head = push(head, out) ; 
					printf("%lf\n",out) ; 
	    			}
			}

			//multiply two inputs
	    		if (strn[0] == '*') {
				if(head==NULL) {
					printf("STACK ERROR\n") ; 
				} else if((head->next)==NULL) {
					head = pop(head) ; 
					printf("STACK ERROR\n") ; 
				} else {
					double a, b, in, out ; 
					a = head -> value ; 
					head = pop(head) ; 
					b = head -> value ; 
					out = a * b ;   
					head = pop(head) ; 
					head = push(head, out) ; 
					printf("%lf\n",out) ; 
	    			}
	    		}
	
			//divide two inputs
	    		if (strn[0] == '/') {
				if (head == NULL) { 
					printf("STACK ERROR\n") ; 
				} else if ((head->next)==NULL) {
					head = pop(head) ; 
					printf("STACK ERROR\n") ; 
				} else {
					double a, b, in, out ; 
					a = head -> value ; 
					head = pop(head) ; 
					b = head -> value ; 
					out = b / a ;  
					head = pop(head) ; 
					head = push(head,out) ; 
					printf("%lf\n", out) ; 
	    			}    
	   		}
	
 			//sin last value of stack
	    		if (strcmp(strn,"sin")==0) {  
				double a, in ;  
				a = head -> value ; 
				head = pop(head) ; 
				in = sin(a) ; 
				head = push(head,in) ; 
				printf("%lf\n",in) ; 
	    		}
				
			//cos last value of stack
	    		if (strcmp(strn,"cos")==0) { 
                		double a, b, in ;
                		a = head -> value ;
				head = pop(head) ; 
                		in = cos(a) ; 
                		head = push(head,in) ;
                		printf("%lf\n",in) ;
            		}

			//tan last value of stack
	    		if (strcmp(strn,"tan")==0) {  
                		double a, in ;
                		a = head -> value ;
                		head = pop(head) ; 
                		in = tan(a) ; 
                		head = push(head,in) ;
                		printf("%lf\n",in) ;
            		}

			//sqrt last value of stack
	   		if (strcmp(strn,"sqrt")==0) {  
                		double a, b, in ;
                		a = head -> value ;
                		head = pop(head) ; 
                		in = sqrt(a) ; 
                		head = push(head,in) ;
                		printf("%lf\n",in) ;
            		}

			//pow last two values of stack
	    		if (strcmp(strn,"pow")==0) { 
				double a, b, in ;
                		a = head -> value ;
                		head = pop(head) ; 
                		b = head->value ; 
				in = pow(b,a) ; 
                		head = push(head,in) ;
                		printf("%lf\n",in) ;
            		}

			//duplicate last two values of stack
	    		if (strcmp(strn,"dup")==0) {
                		double a; 
                		a = head -> value ;
                		head = push(head,a) ;
                		printf("%lf\n",a) ;
            		}
	
			//swap last two values of stack
	    		if (strcmp(strn,"swap")==0) {
				double a, b ;  
				a = head -> value ; 	
				head = pop(head) ;
				b = head->value ;  
				head = pop(head) ; 
				head = push(head,a) ; 	
				head = push(head,b) ; 
				printf("%lf\n",b) ; 
	    		}

			//pop last value of stack
	    		if (strcmp(strn,"pop")==0) {
				if (head == NULL) {
					printf("STACK ERROR\n") ; 
				} else {
					double a ; 
					a = head -> value ;  
					head = pop(head) ; 
					printf("%lf\n", a) ;
	    			}
			}
	
			//print whole stack out to console
	    		if (strcmp(strn,"print")==0) {
				double_node *temp;
        			temp = head ;
					while(temp != NULL) {
						printf("%lf\n",temp->value) ;
						temp = temp->next ;  
					}	    	
	    		}
	
			//quit 
	    		if (strcmp(strn,"quit")==0) { 
	   			break ; 
	    		}
	  }

	} 
	return(0) ;  
}

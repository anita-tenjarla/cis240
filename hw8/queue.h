#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

typedef struct q_node {
	char* value ; 
	struct q_node *next ; 
}string_node ; 

string_node* q_push
	(string_node* q_head, char* value_ptr) ; 

string_node* q_pop
	(string_node* q_head) ; 



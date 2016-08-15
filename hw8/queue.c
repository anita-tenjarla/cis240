#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "queue.h"

//push string node into queue
string_node* q_push (string_node* head, char* value_ptr) {
        string_node *temp ;
	temp = head ; 
	string_node *next_node ; 
	next_node =(string_node*) malloc(sizeof(string_node)) ;
	next_node->value = value_ptr ; 

	if (head == NULL) {
		next_node->next = NULL ; 
		head = next_node ;  
	} else {
		while(temp->next != NULL) {
        		temp = temp -> next ; 
		}
        	next_node -> next = NULL ;
		temp->next = next_node ; 
	} 
	return head ; 
}

//pop string node from queue
string_node* q_pop (string_node *head) {
	if (head == NULL) {
		printf("STACK ERROR") ; 
		return NULL ; 
	} else {
        	string_node *next_node ;
        	next_node = head -> next ;
        	free(head) ;
        	return (next_node) ;
	}
}

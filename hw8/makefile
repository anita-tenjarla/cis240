all : calc

calc : calc.c queue.o
	clang -g -o calc calc.c queue.o -lm

queue.o : queue.c queue.h
	clang -g -c queue.c

clean: 
	rm -f *.o

clobber: clean
	rm -f calc



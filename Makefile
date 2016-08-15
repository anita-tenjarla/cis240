all : jc

jc : jc.c token.o  
	clang -g -o jc jc.c token.o 

token.o : token.c token.h
	clang -g -c token.c

clean :
	rm -rf *.o
	rm -rf jc

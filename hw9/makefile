all : trace

trace : trace.c lc4.o ctrl.o object_files.o 
	clang -g -o trace trace.c lc4.o ctrl.o object_files.o

lc4.o : lc4.c lc4.h
	clang -g -c lc4.c

ctrl.o : ctrl.c ctrl.h
	clang -g -c ctrl.c

object_files.o : object_files.c object_files.h
	clang -g -c object_files.c

clean : 
	rm -rf *.o
	rm -rf trace

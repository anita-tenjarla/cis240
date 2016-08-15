/* 
 * CIS 240 HW 9: LC4 Simulator
 * object_files.h - declares functions for object_files.c
 */

/* 
 * Loads an object file into machine memory.
 * Returns 0 if successful and a nonzero error code if not.
 * Params: pointer to file name, pointer to current machine state
 */
int read_object_file(char* filename, machine_state* state);

#include "code_gen.h"

char *asm_func_def(char *name) {
    (void) fprintf(stdout, "\t.globl %s\n",name);
	(void) fprintf(stdout, "\t.type %s, @function\n",name);
	(void) fprintf(stdout, "%s:\n",name);
}
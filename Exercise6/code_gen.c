#include "code_gen.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void asm_func_def(char *name) {
    (void) fprintf(stdout, "\t.globl %s\n",name);
	(void) fprintf(stdout, "\t.type %s, @function\n",name);
	(void) fprintf(stdout, "%s:\n",name);
}

void asm_ret() {
	(void) fprintf(stdout, "\tret\n");
}

void asm_ret_num(tree_node *node) {
	(void) fprintf(stdout, "\tmovq $%d, %%rax\n", node->val);
}
#include "code_gen.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

void asm_move(char *from_reg, char *to_reg){
    assert(from_reg != NULL);
    assert(to_reg != NULL);

    if (strcmp(from_reg, to_reg)) {
	    (void) fprintf(stdout, "\tmovq %s, %s\n", from_reg, to_reg);
    }
}

void asm_func_def(char *name) {
    (void) fprintf(stdout, "\t.globl %s\n",name);
	(void) fprintf(stdout, "\t.type %s, @function\n",name);
	(void) fprintf(stdout, "%s:\n",name);
}

void asm_ret(tree_node *n) {
    asm_move(n->left->reg, n->reg);
    // TODO: leave asm command?
	(void) fprintf(stdout, "\tret\n");
}

void asm_num(tree_node *n) {
    char from_val[20];
    sprintf(from_val, "$%ld", n->val);
    asm_move(from_val, n->reg);
}

void asm_var(tree_node *n) {
    asm_move(get_register(n->var_table, n->name), n->reg);
}
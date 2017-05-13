#include "code_gen.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

void asm_move(char *from_reg, char *to_reg){
    assert(from_reg != NULL);
    assert(to_reg != NULL);

    if (strcmp(from_reg, to_reg)) {
	    fprintf(stdout, "\tmovq %s, %s\n", from_reg, to_reg);
    }
}

void asm_func_def(char *name) {
    fprintf(stdout, "\t.globl %s\n",name);
	fprintf(stdout, "\t.type %s, @function\n",name);
	fprintf(stdout, "%s:\n",name);
}

void asm_ret(tree_node *n) {
    asm_move(n->left->reg, n->reg);
    // TODO: leave asm command?
	fprintf(stdout, "\tret\n");
}

void asm_num(tree_node *n) {
    char from_val[20];
    sprintf(from_val, "$%ld", n->val);
    asm_move(from_val, n->reg);
}

void asm_var(tree_node *n) {
    asm_move(get_register(n->var_table, n->name), n->reg);
}

void asm_add(tree_node *n) {
    fprintf(stdout, "\taddq %%%s, %%%s\n", n->left->reg, n->right->reg);
}

void asm_mul(tree_node *n) {
    fprintf(stdout, "\timulq %%%s, %%%s\n", n->left->reg, n->right->reg);
}

void asm_neg(tree_node *n) {
    fprintf(stdout, "\tnegq %%%s\n", n->left->reg);
}
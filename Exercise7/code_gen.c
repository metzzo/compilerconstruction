#include "code_gen.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

void asm_move(char *from_reg, char *to_reg) {
    assert(from_reg != NULL);
    assert(to_reg != NULL);

    if (strcmp(from_reg, to_reg)) {
	    fprintf(stdout, "\tmovq %s, %s\n", from_reg, to_reg);
    }
}

void asm_func_def(char *name, int num_variables) {
    fprintf(stdout, "\t.globl %s\n",name);
	fprintf(stdout, "\t.type %s, @function\n",name);
	fprintf(stdout, "%s:\n",name);


    fprintf(stdout, "\tpushq %%rbp\n");
    fprintf(stdout, "\tmovq %%rsp, %%rbp\n");
    
    if (num_variables > 0) {
        fprintf(stdout, "\tsubq $%d, %%rsp\n", 8*num_variables);
    }
}


void asm_label_def(char *name) {
    fprintf(stdout, "l_%s:\n", name);
}



void asm_lexpr_var(tree_node *n) {
    asm_move(n->reg, get_register(n->var_table, n->name));
}

void asm_goto(char *label) {
    fprintf(stdout, "\tjmp l_%s\n", label);
}

void asm_if(tree_node *n) {
    
}

void asm_ret(tree_node *n) {
    asm_move(n->left->reg, n->reg);
    fprintf(stdout, "\tleave\n");
	fprintf(stdout, "\tret\n");
}

void asm_cexpr_to_expr(tree_node *n) {
    asm_move(to_literal(n->val), n->reg);
}

void asm_var(tree_node *n) {
    asm_move(get_register(n->var_table, n->name), n->reg);
}

void asm_add(tree_node *n, char *from, char *to) {
    fprintf(stdout, "\taddq %s, %s\n", from, to);
    asm_move(to, n->reg);
}

void asm_mul(tree_node *n, char *from, char *to) {
    fprintf(stdout, "\timulq %s, %s\n", from, to);
    asm_move(to, n->reg);
}

void asm_neg(tree_node *n, char *from) {
    fprintf(stdout, "\tnegq %s\n", from);
}

void asm_and(tree_node *n) {

}
void asm_not(tree_node *n) {

}
void asm_greater(tree_node *n) {

}
void asm_notequ(tree_node *n) {

}

void asm_array_access(tree_node *n) {
    char from_reg[100];
    sprintf(from_reg, "0(%s, %s, 8)", n->left->reg, n->right->reg);
    asm_move(from_reg, n->reg);
}

void asm_add_const(tree_node *n) {
    n->val = n->left->val + n->right->val;
}
void asm_mul_const(tree_node *n) {
    assert(0);
    n->val = n->left->val * n->right->val;
}
void asm_neg_const(tree_node *n) {
    n->val = -n->left->val;
}

char* to_literal(int64_t val) {
    char* literal = malloc(sizeof(char)*100); // TODO: in a real world app, this should be freed somewhere
    sprintf(literal, "$%ld", val);
    return literal;
}
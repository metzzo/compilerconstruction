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
    assert(name != NULL);
    assert(num_variables >= 0);

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
    assert(name != NULL);

    fprintf(stdout, "l_%s:\n", name);
}



void asm_lexpr_var(tree_node *n) {
    assert(n != NULL);
    assert(n->reg != NULL);
    assert(n->var_table != NULL);
    assert(n->name != NULL);
    
    asm_move(n->reg, get_register(n->var_table, n->name));
}


void asm_lexpr_array_access(tree_node *n) {
    assert(n != NULL);
    assert(n->left->reg != NULL);
    assert(n->right->reg != NULL);
    
    char to_reg[100];
    sprintf(to_reg, "0(%s, %s, 8)", n->left->reg, n->right->reg);
    asm_move(n->reg, to_reg);
}

void asm_goto(char *label) {
    assert(label != NULL);
    
    fprintf(stdout, "\tjmp l_%s\n", label);
}

void asm_if(tree_node *n) {
    assert(n != NULL);
    
    fprintf(stdout, "\tjmp l_%s\n", n->name2);
    fprintf(stdout, "l_%s:\n", n->name);
}

void asm_ret(tree_node *n) {
    assert(n != NULL);
    assert(n->reg != NULL);
    assert(n->left != NULL);
    
    asm_move(n->left->reg, n->reg);
    fprintf(stdout, "\tleave\n");
	fprintf(stdout, "\tret\n");
}

void asm_cexpr_to_expr(tree_node *n) {
    assert(n != NULL);
    assert(n->reg != NULL);
    
    asm_move(to_literal(n->val), n->reg);
}

void asm_var(tree_node *n) {
    assert(n != NULL);
    assert(n->reg != NULL);
    assert(n->var_table != NULL);
    assert(n->name != NULL);

    asm_move(get_register(n->var_table, n->name), n->reg);
}

void asm_add(tree_node *n, char *from, char *to) {
    assert(n != NULL);
    assert(from != NULL);
    assert(to != NULL);
    assert(n->reg != NULL);

    fprintf(stdout, "\taddq %s, %s\n", from, to);
    asm_move(to, n->reg);
}

void asm_mul(tree_node *n, char *from, char *to) {
    assert(n != NULL);
    assert(from != NULL);
    assert(to != NULL);
    assert(n->reg != NULL);

    fprintf(stdout, "\timulq %s, %s\n", from, to);
    asm_move(to, n->reg);
}

void asm_neg(tree_node *n, char *from) {
    assert(n != NULL);
    assert(from != NULL);

    fprintf(stdout, "\tnegq %s\n", from);
}

void asm_and(tree_node *n) {
    /*assert(n != NULL);
    assert(n->name != NULL);

    fprintf(stdout, "\tjmp l_%s\n", n->name2);
    fprintf(stdout, "l_%s:\n", n->name);*/
}

void asm_not(tree_node *n) {
    fprintf(stdout, "\tjmp l_%s\n", n->name2);
    fprintf(stdout, "l_%s:\n", n->name);
}
void asm_greater(tree_node *n) {
    assert(n != NULL);
    assert(n->left->reg != NULL);
    assert(n->right->reg != NULL);
    assert(n->name != NULL);

    fprintf(stdout, "\tcmp %s, %s\n\tjge l_%s\n", n->left->reg, n->right->reg, n->name);
}
void asm_notequ(tree_node *n) {
    assert(n != NULL);
    assert(n->left->reg != NULL);
    assert(n->right->reg != NULL);
    assert(n->name != NULL);

    fprintf(stdout, "\tcmp %s, %s\n\tjz l_%s\n", n->left->reg, n->right->reg, n->name);
}

void asm_array_access(tree_node *n) {
    assert(n != NULL);
    assert(n->left->reg != NULL);
    assert(n->right->reg != NULL);
    
    char from_reg[100];
    sprintf(from_reg, "0(%s, %s, 8)", n->left->reg, n->right->reg);
    asm_move(from_reg, n->reg);
}

void asm_add_const(tree_node *n) {
    assert(n != NULL);
    assert(n->left != NULL);
    assert(n->right != NULL);
    
    n->val = n->left->val + n->right->val;
}
void asm_mul_const(tree_node *n) {
    assert(n != NULL);
    assert(n->left != NULL);
    assert(n->right != NULL);
    
    n->val = n->left->val * n->right->val;
}
void asm_neg_const(tree_node *n) {
    assert(n != NULL);
    assert(n->left != NULL);
    
    n->val = -n->left->val;
}

char* to_literal(int64_t val) {
    char* literal = malloc(sizeof(char)*100); // TODO: in a real world app, this should be freed somewhere
    sprintf(literal, "$%ld", val);
    return literal;
}
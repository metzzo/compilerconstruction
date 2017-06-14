#include "code_gen.h"
#include "table.h"

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


    fprintf(stdout, "\tpush %%rbp\n");
    fprintf(stdout, "\tmovq %%rsp, %%rbp\n");
    if (num_variables > 0) {
        fprintf(stdout, "\tsubq $%d, %%rsp\n", 8*num_variables);
    }

    fprintf(stdout, "\tpush %%r12\n");
    fprintf(stdout, "\tpush %%r13\n");
    fprintf(stdout, "\tpush %%r14\n");
    fprintf(stdout, "\tpush %%r15\n");
    fprintf(stdout, "\tpush %%rbx\n");
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
    fprintf(stdout, "\tpop %%rbx\n");
    fprintf(stdout, "\tpop %%r15\n");
    fprintf(stdout, "\tpop %%r14\n");
    fprintf(stdout, "\tpop %%r13\n");
    fprintf(stdout, "\tpop %%r12\n");
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

void asm_param(tree_node *n) {
    assert(n != NULL);
    assert(n->reg != NULL);
    
}

void asm_func_call(tree_node *n) {
    assert(n != NULL);
    assert(n->name != NULL);

    tree_node *traversal = n->right;
    int reg_num = 0;
    while (traversal != NULL && traversal->op != NODE_EMPTY) {
        asm_move(traversal->reg, input_registers[reg_num]);
        traversal = traversal->right;
        reg_num++;
    }

    char *current_tmp = next_tmp_reg(NULL);
    while (strcmp(current_tmp, n->reg) != 0) {
        fprintf(stdout, "\tpush %s\n", current_tmp);
        current_tmp = next_tmp_reg(current_tmp);
    }
    fprintf(stdout, "\tcall %s\n", n->name);
    asm_move("%rax", n->reg);

    current_tmp = next_tmp_reg(NULL);
    char *regs[20];
    int count = 0;
    while (strcmp(current_tmp, n->reg) != 0) {
        regs[count] = current_tmp;
        count++;
        current_tmp = next_tmp_reg(current_tmp);
    }
    for(int i = count - 1; i >= 0; i--) {
        fprintf(stdout, "\tpop %s\n", regs[i]);
    }

    for (int i = 5; i >= 0; i--) {
        fprintf(stdout, "\tpop %s\n", input_registers[i]);
    }
}
void asm_save_stack(tree_node *n) {
    assert(n != NULL);

    for (int i = 0; i < 6; i++) {
        fprintf(stdout, "\tpush %s\n", input_registers[i]);
    }
}

char* to_literal(int64_t val) {
    char* literal = malloc(sizeof(char)*100); // TODO: in a real world app, this should be freed somewhere
    sprintf(literal, "$%ld", val);
    return literal;
}
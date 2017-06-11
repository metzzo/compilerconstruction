#ifndef CODE_GEN_INCL
#define CODE_GEN_INCL

#include "tree.h"
#include <stdint.h>

char* to_literal(int64_t val);

void asm_func_def(char *name, int num_variables);
void asm_label_def(char *name);
void asm_goto(char *label);
void asm_if(tree_node *n);
void asm_ret(tree_node *n);
void asm_cexpr_to_expr(tree_node *n);
void asm_var(tree_node *n);
void asm_add(tree_node *n, char *from, char *to);
void asm_mul(tree_node *n, char *from, char *to);
void asm_neg(tree_node *n, char *from);
void asm_array_access(tree_node *n);
void asm_and(tree_node *n);
void asm_not(tree_node *n);
void asm_greater(tree_node *n);
void asm_notequ(tree_node *n);

void asm_lexpr_var(tree_node *n);
void asm_lexpr_array_access(tree_node *n);

void asm_add_const(tree_node *n);
void asm_mul_const(tree_node *n);
void asm_neg_const(tree_node *n);

void asm_param(tree_node *n);
void asm_func_call(tree_node *n);
void asm_save_stack(tree_node *n);

#endif
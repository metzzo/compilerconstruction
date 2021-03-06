#ifndef CODE_GEN_INCL
#define CODE_GEN_INCL

#include "tree.h"
#include <stdint.h>

char* to_literal(int64_t val);

void asm_func_def(char *name);
void asm_ret(tree_node *n);
void asm_cexpr_to_expr(tree_node *n);
void asm_var(tree_node *n);
void asm_add(tree_node *n, char *from, char *to);
void asm_mul(tree_node *n, char *from, char *to);
void asm_neg(tree_node *n, char *from);
void asm_array_access(tree_node *n);

void asm_add_const(tree_node *n);
void asm_mul_const(tree_node *n);
void asm_neg_const(tree_node *n);

#endif
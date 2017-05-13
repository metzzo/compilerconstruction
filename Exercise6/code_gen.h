#ifndef CODE_GEN_INCL
#define CODE_GEN_INCL

#include "tree.h"

void asm_func_def(char *name);
void asm_ret(tree_node *n);
void asm_num(tree_node *n);
void asm_var(tree_node *n);
void asm_add(tree_node *n);
void asm_mul(tree_node *n);
void asm_neg(tree_node *n);

#endif
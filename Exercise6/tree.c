#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

tree_node *new_node(node_type type, tree_node *left, tree_node *right) {
    tree_node *n = malloc(sizeof(tree_node));
	n->op = type;
	n->left = left;
	n->right = right;
	n->val = 0;
    n->name = NULL;
    n->var_table = NULL;
    n->reg = NULL;
	return n;
}

tree_node *new_num(int64_t val) {
    tree_node *n = new_node(NODE_NUM, NULL, NULL);
    n->val = val;
    return n;
}

tree_node *new_var(table *var_table, char *name) {
    tree_node *n = new_node(NODE_VAR, NULL, NULL);
    n->name = name;
    n->var_table = merge_table(var_table, create_table(), create_table()); // create copy of table, just to be sure
    return n;
}

tree_node *new_empty() {
    return new_node(NODE_EMPTY, NULL, NULL);
}

tree_node *new_return(tree_node *ret) {
    return new_node(NODE_RETURN, ret, NULL);
}

tree_node *new_stat(tree_node *line, tree_node *next) {
    return new_node(NODE_STAT, line, next);
}

tree_node *new_add(tree_node *left, tree_node *right) {
    return new_node(NODE_ADD, left, right);
}

tree_node *new_mul(tree_node *left, tree_node *right) {
    return new_node(NODE_MUL, left, right);
}

tree_node *new_neg(tree_node *expr) {
    return new_node(NODE_NEG, expr, NULL);
}


char *tmp_reg_names[]={"%rax", "%r10", "%r11", "%r9", "%r8", "%rcx", "%rdx", "%rsi", "%rdi"};

char *next_tmp_reg(char *current) {
    int index;
    if (current == NULL) {
        index = 0;
    } else {
        // TODO: only allow usage of r9, r8, rcx, rdx, rsi, rdi if parameter count allows it.
        for (index = 0; index < 9; index++) {
            if (strcmp(tmp_reg_names[index], current) == 0) {
                index++;
                break;
            }
        }
        assert(index < 9);
    }
    return tmp_reg_names[index];
}

void calc_register(tree_node *node) {
    switch (node->op) {
        case NODE_NUM:
        case NODE_EMPTY:
        case NODE_VAR:
            node->reg = NULL;
            break;
        case NODE_RETURN:
            node->reg = "%rax";
            node->left->reg = next_tmp_reg(NULL);
            break;
        case NODE_ADD:
        case NODE_MUL:
            assert(node->reg != NULL);
            node->left->reg = node->reg;
            node->right->reg = next_tmp_reg(node->reg);
            break;
        case NODE_NEG:
            assert(node->reg != NULL);
            node->left->reg = node->reg;
            break;
        default:
            assert(0);
    }
}
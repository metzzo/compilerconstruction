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
    n->reg2 = NULL;
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

tree_node *new_if(tree_node *cond, char *label, char *exit_label) {
    assert(cond != NULL);
    tree_node *node = new_node(NODE_IF, cond, NULL);
    node->name = label;
    node->name2 = exit_label;
    return node;
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

tree_node *new_array_access(tree_node *from, tree_node *offset) {
    return new_node(NODE_ARRAY_ACCESS, from, offset);
}

tree_node *new_assignment(tree_node *lexpr, tree_node *expr) {
    tree_node *node = new_node(NODE_ASSIGNMENT, expr, lexpr);
    
    return node;
}

tree_node *new_lexpr_var(table *var_table, char *name) {
    tree_node *n = new_node(NODE_LEXPR_VAR, NULL, NULL);
    n->name = name;
    n->var_table = merge_table(var_table, create_table(), create_table()); // create copy of table, just to be sure
    return n;
}

tree_node *new_lexpr_array_access(tree_node *from, tree_node *offset) {
    return new_node(NODE_LEXPR_ARRAY_ACCESS, from, offset);
}

tree_node *new_and(tree_node *left, tree_node *right, char *label, char *exit_label) {
    tree_node *n = new_node(NODE_AND, left, right);
    n->name = label;
    n->name2 = exit_label;
    return n;
}
tree_node *new_not(tree_node *left, char *continue_label, char *exit_label) {
    tree_node *n = new_node(NODE_NOT, left, NULL);
    n->name = continue_label;
    n->name2 = exit_label;
    return n;
}
tree_node *new_greater(tree_node *left, tree_node *right, char *label) {
    tree_node *n = new_node(NODE_GREATER, left, right);
    n->name = label;
    return n;
}
tree_node *new_notequ(tree_node *left, tree_node *right, char *label) {
    tree_node *n = new_node(NODE_NOTEQU, left, right);
    n->name = label;
    return n;
}
tree_node *new_func(char *name, int param_num, tree_node *param) {
    tree_node *n = new_node(NODE_FUNC_CALL, new_save_stack(param_num), param);
    n->name = name;
    n->val = param_num;
    return n;
}
tree_node *new_param(tree_node *expr, tree_node *right) {
    return new_node(NODE_PARAM, expr, right);
}
tree_node *new_save_stack(int param_num) {
    tree_node *n = new_node(NODE_SAVE_STACK, NULL, NULL);
    n->val = param_num;
    return n;
}

char *tmp_reg_names[]={"%rax", "%r10", "%r11", "%r9", "%r8", "%rcx", "%rdx", "%rsi", "%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"};

char *next_tmp_reg(char *current) {
    int index;
    if (current == NULL) {
        index = 0;
    } else {
        // TODO: only allow usage of r9, r8, rcx, rdx, rsi, rdi if parameter count allows it.
        for (index = 0; index < 14; index++) {
            if (strcmp(tmp_reg_names[index], current) == 0) {
                index++;
                break;
            }
        }
        assert(index < 14);
    }
    return tmp_reg_names[index];
}

void calc_register(tree_node *node) {
    assert(node != NULL);

    switch (node->op) {
        case NODE_NUM:
        case NODE_EMPTY:
        case NODE_VAR:
            break;
        case NODE_FUNC_CALL:
            node->left->reg = node->reg;
            node->right->reg = node->reg;
            node->right->val = 0;
            break;
        case NODE_PARAM:
            node->left->reg = node->reg;
            node->right->reg = next_tmp_reg(node->reg);
            node->right->val = node->val + 1;

            /*node->left->reg = node->reg2;
            int index = 0;
            while (strcmp(input_registers[index], node->reg) != 0) {
                index++;
            }
            
            node->right->reg = input_registers[index + 1];
            node->right->reg2 = next_tmp_reg(node->reg2);*/
            break;
        case NODE_RETURN:
            node->reg = next_tmp_reg(NULL);
            node->left->reg = node->reg;
            break;
        case NODE_ASSIGNMENT:
            node->right->reg = next_tmp_reg(NULL);
            node->left->reg = node->right->reg;
            break;
        case NODE_ADD:
        case NODE_MUL:
        case NODE_NOTEQU:
        case NODE_GREATER:
            assert(node->reg != NULL);
            node->left->reg = node->reg;
            node->right->reg = next_tmp_reg(node->left->reg);
            break;
        case NODE_NOT:
        case NODE_NEG:
            assert(node->reg != NULL);
            node->left->reg = node->reg;
            break;
        case NODE_LEXPR_ARRAY_ACCESS:
            assert(node->reg != NULL);
            node->left->reg = next_tmp_reg(node->reg);
            node->right->reg = next_tmp_reg(node->left->reg);
            break;
        case NODE_ARRAY_ACCESS:
            assert(node->reg != NULL);
            node->left->reg = node->reg;
            node->right->reg = next_tmp_reg(node->left->reg);

            break;
        case NODE_IF:
            node->left->reg = next_tmp_reg(NULL);
            break;
        case NODE_AND:
            node->left->reg = node->reg;
            node->right->reg = next_tmp_reg(NULL);
            break;
        default:
            assert(0);
    }
}
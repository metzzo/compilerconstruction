#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

tree_node *new_node(node_type type, tree_node *left, tree_node *right) {
    tree_node *n = malloc(sizeof(tree_node));
	n->op = type;
	n->left = left;
	n->right = right;
	n->val = 0;
    n->name = NULL;
	return n;
}

tree_node *new_num(int64_t val) {
    tree_node *n = new_node(NODE_NUM, NULL, NULL);
    n->val = val;
    return n;
}

tree_node *new_empty() {
    return new_node(NODE_EMPTY, NULL, NULL);
}

tree_node *new_return(tree_node *ret) {
    return new_node(NODE_RETURN, ret, NULL);
}
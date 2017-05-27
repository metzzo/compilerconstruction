#ifndef TREE_INCL
#define TREE_INCL

#include <stdint.h>
#include "table.h"

typedef enum node_type {
    NODE_EMPTY = 1,
    NODE_NUM = 2,
    NODE_RETURN = 3,
    NODE_VAR = 4,
    NODE_STAT = 5,
    NODE_ADD = 6,
    NODE_MUL = 7,
    NODE_NEG = 8,
    NODE_ARRAY_ACCESS = 9,
    NODE_ASSIGNMENT = 10,
    NODE_LEXPR_VAR = 11,
    NODE_IF = 12,
    NODE_AND = 13,
    NODE_NOT = 14,
    NODE_GREATER = 15,
    NODE_NOTEQU = 16
} node_type;

typedef struct tree_node_t {
    node_type op;
    struct tree_node_t *left;
    struct tree_node_t *right;
	struct burm_state *label;
    char *reg;
    char *name;
    char *name2;
	int64_t val;
    table *var_table;
} tree_node;

void calc_register(tree_node *node);

// iburg stuff
typedef tree_node *treenodeptr;

#define NODEPTR_TYPE    	treenodeptr
#define OP_LABEL(p)     	((p)->op)
#define LEFT_CHILD(p)   	((p)->left)
#define RIGHT_CHILD(p)  	((p)->right)
#define STATE_LABEL(p)  	((p)->label)
#define PANIC				printf

// functions

tree_node *new_num(int64_t val);
tree_node *new_var(table *var_table, char *name);
tree_node *new_empty();
tree_node *new_return(tree_node *ret);
tree_node *new_if(tree_node *cond, char *name);
tree_node *new_stat(tree_node *line, tree_node *next);
tree_node *new_add(tree_node *left, tree_node *right);
tree_node *new_mul(tree_node *left, tree_node *right);
tree_node *new_neg(tree_node *expr);
tree_node *new_array_access(tree_node *from, tree_node *offset);
tree_node *new_assignment(tree_node *lexpr, tree_node *expr);
tree_node *new_lexpr_var(table *var_table, char *name);
tree_node *new_and(tree_node *left, tree_node *right);
tree_node *new_not(tree_node *left, char *continue_label, char *exit_label);
tree_node *new_greater(tree_node *left, tree_node *right, char  *label);
tree_node *new_notequ(tree_node *left, tree_node *right, char *label);

#endif
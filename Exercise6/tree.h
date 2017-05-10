#ifdef TREE_INCL
#define TREE_INCL

#include <stdint.h>

typedef enum node_type {
    NODE_EMPTY = 1,
    NODE_NUM = 2,
    NODE_RETURN = 3
} node_type;

typedef struct tree_node {
    node_type op;
    struct tree_node *left;
    struct tree_node *right;
	struct burm_state *label;

    char *name;
	int64_t val;
} tree_node;

tree_node *new_node(node_type type, tree_node *left, tree_node *right);
tree_node *new_num(int64_t val);
tree_node *new_empty();
tree_node *new_return(tree_node *ret);

// iburg stuff
typedef tree_node *treenodeptr;

#define NODEPTR_TYPE    	treenodeptr
#define OP_LABEL(p)     	((p)->op)
#define LEFT_CHILD(p)   	((p)->left)
#define RIGHT_CHILD(p)  	((p)->right)
#define STATE_LABEL(p)  	((p)->label)
#define PANIC				printf


#endif
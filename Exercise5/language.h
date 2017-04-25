#ifndef LANGUAGE_FILE_H
#define LANGUAGE_FILE_H

#define IDENT 1
#define NUM 2

#ifdef USE_IBURG
#ifndef BURM
typedef struct burm_state *STATEPTR_TYPE;
#endif
#else
#define STATEPTR_TYPE int
#endif

typedef struct s_node {
	int		op;
	struct s_node   *kids[2];
	STATEPTR_TYPE	state;
    
	char* identifier_name;
	int val;
} treenode;

typedef treenode *treenodep;

#define NODEPTR_TYPE	treenodep
#define OP_LABEL(p)	((p)->op)
#define LEFT_CHILD(p)	((p)->kids[0])
#define RIGHT_CHILD(p)	((p)->kids[1])
#define STATE_LABEL(p)	((p)->state)
#define PANIC		printf


#endif


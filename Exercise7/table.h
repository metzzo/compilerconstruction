#ifndef TABLE_INCL
#define TABLE_INCL

#ifdef DEBUG
#define DEBUG_PRINT(...) fprintf(stderr, __VA_ARGS__);
#else
#define DEBUG_PRINT(...) do {} while(0);
#endif

typedef struct table {
    char **names;
    int name_count;
} table;

table *create_table();
table *create_symbol(table *source, char *name, table *other_table);
table *merge_table(table *table1, table *table2, table *other_table);
void check_identifier(table *source, char *name);
char *get_register(table *source, char *name);

char *to_local_var(char *name);
int is_local_var(char *name);

#endif
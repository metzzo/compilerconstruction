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

table *createTable();
table *createSymbol(table *source, char *name, table *other_table);
table *mergeTable(table *table1, table *table2, table *other_table);

#endif
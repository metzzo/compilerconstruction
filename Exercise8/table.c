#include "table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

table *create_table() {
    DEBUG_PRINT("Create table\n");

    table *t = malloc(sizeof(table));
    t->names = NULL;
    t->name_count = 0;
    return t;
}

int compare_table_name(char *n1, char *n2) {
    if (is_local_var(n1)) {
        n1 += 2;
    }
    if (is_local_var(n2)) {
        n2 += 2;
    }
    return strcmp(n1, n2);
}

int contains(table *source, char *name) {
    DEBUG_PRINT("Search for %s\n", name);
    for (int i = 0; i < source->name_count; i++) {
        DEBUG_PRINT("\tIs %s equals %s?\n", name, source->names[i]);
        if (compare_table_name(source->names[i], name) == 0) {
            DEBUG_PRINT("Did find %s\n", name);
            return 1;
        }
    }
    DEBUG_PRINT("Did not find %s\n", name);
    return 0;
}

table *create_symbol(table *source, char *name, table *other_table) {
    DEBUG_PRINT("Create symbol %s\n", name);

    // check if symbol already exists
    if (contains(source, name) || contains(other_table, name)) {
        fprintf(stderr, "Identifier %s already exists\n", name);
        exit(3);
    }
    
    source->name_count++;

    if (source->names == NULL) {
        source->names = malloc(sizeof(char*));
    } else {
        source->names = realloc(source->names, sizeof(char*)*source->name_count);
    }

    assert(source->names != NULL);

    source->names[source->name_count - 1] = strdup(name);
    DEBUG_PRINT("Symbol %s successfully created\n", name);
    return source;
}

table *merge_table(table *table1, table* table2, table *other_table) {
    DEBUG_PRINT("Merge Table \n");

    table *newTable = create_table();
    for (int i = 0; i < table1->name_count; i++) {
        create_symbol(newTable, table1->names[i], other_table);
    }
    for (int i = 0; i < table2->name_count; i++) {
        create_symbol(newTable, table2->names[i], other_table);
    }
    DEBUG_PRINT("Finish Merging\n");

    return newTable;
}

void check_identifier(table *source, char *name) {
    DEBUG_PRINT("Check if identifier exists %s", name);
    if (!contains(source, name)) {
        fprintf(stderr, "Undefined identifier %s", name);
        exit(3);
    }
}

char *input_registers[] = { "%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"};

char *get_register(table *source, char *name) {
    int local_pos = 1, param_pos = 0;
    
    for (int i = 0; i < source->name_count; i++) {
        if (compare_table_name(source->names[i], name) == 0) {
            if (is_local_var(source->names[i])) {
                char *reg = malloc(100*sizeof(char));
                sprintf(reg, "%d(%%rbp)", -8*local_pos);
                return reg;
            } else {
                int param_count = -1;
                for (int j = 0; j < source->name_count; j++) {
                    if (!is_local_var(source->names[j])) {
                        param_count++;
                    }
                }

                assert(param_pos < 6); // number of elements in input_registers
                return input_registers[param_count - param_pos]; // because parameters are added in reverse order
            }
        } else if (is_local_var(source->names[i])) {
            local_pos++;
        } else {
            param_pos++;
        }
    }
    assert(0);
}

char *to_local_var(char *name) {
    char *new_name = malloc(strlen(name) + 2 + 1); // old name length, local var prefix, \0
    sprintf(new_name, "v_%s", name);
    return new_name;
}

int is_local_var(char *name) {
    return strlen(name) > 2 && name[0] == 'v' && name[1] == '_';
}
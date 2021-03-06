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

int contains(table *source, char *name) {
    DEBUG_PRINT("Search for %s\n", name);
    for (int i = 0; i < source->name_count; i++) {
        DEBUG_PRINT("\tIs %s equals %s?\n", name, source->names[i]);
        if (strcmp(source->names[i], name) == 0) {
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
    for (int i = 0; i < source->name_count; i++) {
        if (strcmp(source->names[i], name) == 0) {
            assert(i < 6); // number of elements in input_registers
            return input_registers[source->name_count - i - 1]; // because parameters are added in reverse order
        }
    }
    assert(0);
}
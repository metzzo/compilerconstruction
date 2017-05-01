%{
    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "language.h"

void yyerror(char *s);
int yylex();

extern int      yylineno;
extern char*    yytext;

table *createTable();
table *createSymbol(table *source, char *name, table *other_table);
table *mergeTable(table *table1, table *table2, table *other_table);

void checkIdentifier(table *source, char *name);

%}

%token KW_RETURN
%token KW_GOTO
%token KW_VAR
%token KW_NOT
%token KW_IF
%token KW_END
%token KW_AND
%token IDENTIFIER
%token NUMBER
%token OP_NOTEQU

@attributes { char* name; } IDENTIFIER
@attributes { table *var_table; } Pars 
@attributes { table *var_table; table *label_table; } Stats 
@attributes { table *var_table; table *label_table; table *new_var_table; } Stat 
@attributes { table *var_table; } Expr 
@attributes { table *var_table; } Cond 
@attributes { table *var_table; } Term 
@attributes { table *var_table; } Lexpr 
@attributes { table *var_table; } AndCond 
@attributes { table *var_table; } Cterm 
@attributes { table *var_table; } AddExpr 
@attributes { table *var_table; } MulExpr 
@attributes { table *var_table; } NegExpr 
@attributes { table *var_table; } FuncCall
@attributes { table *var_table; table *label_table; } Labeldef

@traversal @postorder checkident

%start Program
%%

Program: Funcdef ';' Program
    | /* empty */
    ;

Funcdef: IDENTIFIER '(' Pars ')' Stats KW_END 
        @{
            @i @Stats.var_table@ = @Pars.var_table@;
            @i @Stats.label_table@ = createTable();
        @}
    ;

Pars: IDENTIFIER ',' Pars
        @{
            @i @Pars.0.var_table@ = createSymbol(@Pars.1.var_table@, @IDENTIFIER.name@, createTable());
        @}
    | IDENTIFIER
        @{
            @i @Pars.var_table@ = createSymbol(createTable(), @IDENTIFIER.name@, createTable());
        @}
    | /* empty */
        @{
            @i @Pars.var_table@ = createTable();
        @}
    ;

Stats: Labeldef Stat ';' Stats
        @{
            @i @Labeldef.label_table@ = @Stats.0.label_table@;
            @i @Labeldef.var_table@ = @Stats.0.var_table@;

            @i @Stat.var_table@ = @Stats.0.var_table@;
            @i @Stat.label_table@ = @Stats.0.label_table@;

            @i @Stats.1.var_table@ = mergeTable(@Stats.0.var_table@, @Stat.new_var_table@, @Stat.label_table@);
            @i @Stats.1.label_table@ = @Stats.0.label_table@;
        @}
    | /* empty */
        @{
        @}
    ;

Labeldef: Labeldef IDENTIFIER ':'
        @{
            @i @Labeldef.1.label_table@ = createSymbol(@Labeldef.0.label_table@, @IDENTIFIER.name@, @Labeldef.0.var_table@);
            @i @Labeldef.1.var_table@ = @Labeldef.0.var_table@;
        @}
    | /* empty */
    ;

Stat: KW_RETURN Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = createTable();
        @}
    | KW_GOTO IDENTIFIER
        @{
            @checkident checkIdentifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Stat.new_var_table@ = createTable();
        @}
    | KW_IF Cond KW_GOTO IDENTIFIER
        @{
            @checkident checkIdentifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Cond.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = createTable();
        @}
    | KW_VAR IDENTIFIER '=' Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = createSymbol(createTable(), @IDENTIFIER.name@, @Stat.label_table@);
        @}
    | Lexpr '=' Expr
        @{
            @i @Lexpr.var_table@ = @Stat.var_table@;
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = createTable();
        @}
    | Term
        @{
            @i @Term.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = createTable();
        @}
    ;

Cond: AndCond 
        @{
            @i @AndCond.var_table@ = @Cond.var_table@;
        @}
    | KW_NOT Cterm
        @{
            @i @Cterm.var_table@ = @Cond.var_table@;
        @}
    ;

AndCond: Cterm KW_AND AndCond
        @{
            @i @Cterm.var_table@ = @AndCond.0.var_table@;
            @i @AndCond.1.var_table@ = @AndCond.0.var_table@;
        @}
    | Cterm
        @{
            @i @Cterm.var_table@ = @AndCond.var_table@;
        @}
    ;

Cterm: '(' Cond ')'
        @{
            @i @Cond.var_table@ = @Cterm.var_table@;
        @}
    | Expr OP_NOTEQU Expr
        @{
            @i @Expr.0.var_table@ = @Cterm.var_table@;
            @i @Expr.1.var_table@ = @Cterm.var_table@;
        @}
    | Expr '>' Expr
        @{
            @i @Expr.0.var_table@ = @Cterm.var_table@;
            @i @Expr.1.var_table@ = @Cterm.var_table@;
        @}
    ;

Lexpr: IDENTIFIER
        @{
            @checkident checkIdentifier(@Lexpr.var_table@, @IDENTIFIER.name@);
        @}
    | Term '[' Expr ']'
        @{
            @i @Term.var_table@ = @Lexpr.var_table@;
            @i @Expr.var_table@ = @Lexpr.var_table@;
        @}
    ;

Expr: Term '+' AddExpr
        @{
            @i @Term.var_table@ = @Expr.var_table@;
            @i @AddExpr.var_table@ = @Expr.var_table@;
        @}
    | Term '*' MulExpr
        @{
            @i @Term.var_table@ = @Expr.var_table@;
            @i @MulExpr.var_table@ = @Expr.var_table@;
        @}
    | '-' NegExpr
        @{
            @i @NegExpr.var_table@ = @Expr.var_table@;
        @}
    | Term
        @{
            @i @Term.var_table@ = @Expr.var_table@;
        @}
    ;

AddExpr: Term '+' AddExpr
        @{
            @i @Term.var_table@ = @AddExpr.0.var_table@;
            @i @AddExpr.1.var_table@ = @AddExpr.0.var_table@;
        @}
    | Term
        @{
            @i @Term.var_table@ = @AddExpr.var_table@;
        @}
    ;

MulExpr: Term '*' MulExpr
        @{
            @i @Term.var_table@ = @MulExpr.0.var_table@;
            @i @MulExpr.1.var_table@ = @MulExpr.0.var_table@;
        @}
    | Term
        @{
            @i @Term.var_table@ = @MulExpr.var_table@;
        @}
    ;

NegExpr: '-' NegExpr
        @{ 
            @i @NegExpr.1.var_table@ = @NegExpr.0.var_table@; 
        @}
    | Term
        @{ 
            @i @Term.var_table@ = @NegExpr.var_table@;
            @}
    ;

Term: '(' Expr ')'
        @{
            @i @Expr.var_table@ = @Term.var_table@;
        @}
    | NUMBER
    | Term '[' Expr ']'
        @{
            @i @Term.1.var_table@ = @Term.0.var_table@;
            @i @Expr.var_table@ = @Term.0.var_table@;
        @}
    | IDENTIFIER
        @{
            @checkident checkIdentifier(@Term.var_table@, @IDENTIFIER.name@);
        @}
    | IDENTIFIER '(' FuncCall ')'
        @{
            @i @FuncCall.var_table@ = @Term.var_table@;
        @}
    ;

FuncCall: Expr ',' FuncCall
        @{
            @i @Expr.var_table@ = @FuncCall.0.var_table@;
            @i @FuncCall.1.var_table@ = @FuncCall.0.var_table@;
        @}
    | Expr
        @{
            @i @Expr.var_table@ = @FuncCall.var_table@;
        @}
    | /* empty */

%%

table *createTable() {
    printf("Create table\n");
    fflush(stdout);

    table *t = malloc(sizeof(table));
    t->names = NULL;
    t->name_count = 0;
    return t;
}

int contains(table *source, char *name) {
    printf("Search for %s\n", name);
    for (int i = 0; i < source->name_count; i++) {
        printf("\tIs %s equals %s?\n", name, source->names[i]);
        if (strcmp(source->names[i], name) == 0) {
            printf("Did find %s\n", name);
            return 1;
        }
    }
    printf("Did not find %s\n", name);
    return 0;
}

table *createSymbol(table *source, char *name, table *other_table) {
    printf("Create symbol %s\n", name);
    fflush(stdout);

    // check if symbol already exists
    if (contains(source, name) || contains(other_table, name)) {
        printf("Identifier %s already exists\n", name);
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
    printf("Symbol %s successfully created\n", name);
    return source;
}

table *mergeTable(table *table1, table* table2, table *other_table) {
    printf("Merge Table \n");
    fflush(stdout);

    table *newTable = createTable();
    for (int i = 0; i < table1->name_count; i++) {
        createSymbol(newTable, table1->names[i], other_table);
    }
    for (int i = 0; i < table2->name_count; i++) {
        createSymbol(newTable, table2->names[i], other_table);
    }
    printf("Finish Merging\n");
    fflush(stdout);

    return newTable;
}

void checkIdentifier(table *source, char *name) {
    printf("Check if identifier exists %s", name);
    if (!contains(source, name)) {
        printf("Undefined identifier %s", name);
        exit(3);
    }
}

void yyerror(char *s) {
    fprintf(stderr, "%d: Syntax Error at '%s'\n", yylineno, yytext);
    exit(2);
}

int main(int argc, char *argv[]) {
  yyparse();
  
  return 0;
}

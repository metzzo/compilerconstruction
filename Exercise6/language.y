%{
    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include "tree.h"
#include "table.h"

void yyerror(char *s);
int yylex();

extern int      yylineno;
extern char*    yytext;

void burm_label(NODEPTR_TYPE);
void burm_reduce(NODEPTR_TYPE bnode, int goalnt);

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
@attributes { int64_t val; } NUMBER
@attributes { table *var_table; } Pars 
@attributes { table *var_table; table *label_table; tree_node *node; } Stats 
@attributes { table *var_table; table *label_table; table *new_var_table; tree_node *node; } Stat 
@attributes { table *var_table; tree_node *node; } Expr 
@attributes { table *var_table; } Cond 
@attributes { table *var_table; tree_node *node; } Term 
@attributes { table *var_table; } Lexpr 
@attributes { table *var_table; } AndCond 
@attributes { table *var_table; } Cterm 
@attributes { table *var_table; tree_node *node; } AddExpr 
@attributes { table *var_table; tree_node *node; } MulExpr 
@attributes { table *var_table; tree_node *node; } NegExpr 
@attributes { table *var_table; } FuncCall
@attributes { table *var_table; table *label_table; } Labeldef

@traversal @postorder checkident
@traversal @lefttoright @preorder reggen
@traversal @lefttoright @preorder codegen

%start Program
%%

Program: Funcdef ';' Program
    | /* empty */
    ;

Funcdef: IDENTIFIER '(' Pars ')' Stats KW_END 
        @{
            @i @Stats.var_table@ = @Pars.var_table@;
            @i @Stats.label_table@ = create_table();

            @codegen asm_func_def(@IDENTIFIER.name@);
        @}
    ;

Pars: IDENTIFIER ',' Pars
        @{
            @i @Pars.0.var_table@ = create_symbol(@Pars.1.var_table@, @IDENTIFIER.name@, create_table());
        @}
    | IDENTIFIER
        @{
            @i @Pars.var_table@ = create_symbol(create_table(), @IDENTIFIER.name@, create_table());
        @}
    | /* empty */
        @{
            @i @Pars.var_table@ = create_table();
        @}
    ;

Stats: Labeldef Stat ';' Stats
        @{
            @i @Labeldef.label_table@ = @Stats.0.label_table@;
            @i @Labeldef.var_table@ = @Stats.0.var_table@;

            @i @Stat.var_table@ = @Stats.0.var_table@;
            @i @Stat.label_table@ = @Stats.0.label_table@;

            @i @Stats.1.var_table@ = merge_table(@Stats.0.var_table@, @Stat.new_var_table@, @Stat.label_table@);
            @i @Stats.1.label_table@ = @Stats.0.label_table@;
            
            @i @Stats.0.node@ = new_stat(@Stat.0.node@, @Stats.1.node@);
        @}
    | /* empty */
        @{
            @i @Stats.node@ = new_empty();
        @}
    ;

Labeldef: Labeldef IDENTIFIER ':'
        @{
            @i @Labeldef.1.label_table@ = create_symbol(@Labeldef.0.label_table@, @IDENTIFIER.name@, @Labeldef.0.var_table@);
            @i @Labeldef.1.var_table@ = @Labeldef.0.var_table@;
        @}
    | /* empty */
    ;

Stat: KW_RETURN Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_return(@Expr.0.node@);

            @reggen calc_register(@Stat.node@);
			@codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@,1);
        @}
    | KW_GOTO IDENTIFIER
        @{
            @checkident check_identifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
        @}
    | KW_IF Cond KW_GOTO IDENTIFIER
        @{
            @checkident check_identifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Cond.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
        @}
    | KW_VAR IDENTIFIER '=' Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_symbol(create_table(), @IDENTIFIER.name@, @Stat.label_table@);
            @i @Stat.node@ = new_empty();
        @}
    | Lexpr '=' Expr
        @{
            @i @Lexpr.var_table@ = @Stat.var_table@;
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
        @}
    | Term
        @{
            @i @Term.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
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
            @checkident check_identifier(@Lexpr.var_table@, @IDENTIFIER.name@);
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
            @i @Expr.node@ = new_add(@Term.node@, @AddExpr.node@);

            @reggen calc_register(@Expr.node@);
        @}
    | Term '*' MulExpr
        @{
            @i @Term.var_table@ = @Expr.var_table@;
            @i @MulExpr.var_table@ = @Expr.var_table@;
            @i @Expr.node@ = new_mul(@Term.node@, @MulExpr.node@);

            @reggen calc_register(@Expr.node@);
        @}
    | '-' NegExpr
        @{
            @i @NegExpr.var_table@ = @Expr.var_table@;
            @i @Expr.node@ = new_neg(@NegExpr.node@);

            @reggen calc_register(@Expr.node@);
        @}
    | Term
        @{
            @i @Term.var_table@ = @Expr.var_table@;
            @i @Expr.node@ = @Term.node@;
        @}
    ;

AddExpr: Term '+' AddExpr
        @{
            @i @Term.var_table@ = @AddExpr.0.var_table@;
            @i @AddExpr.1.var_table@ = @AddExpr.0.var_table@;
            @i @AddExpr.0.node@ = new_add(@Term.node@, @AddExpr.1.node@);

            @reggen calc_register(@AddExpr.node@);
        @}
    | Term
        @{
            @i @Term.var_table@ = @AddExpr.var_table@;
            @i @AddExpr.node@ = @Term.node@;
        @}
    ;

MulExpr: Term '*' MulExpr
        @{
            @i @Term.var_table@ = @MulExpr.0.var_table@;
            @i @MulExpr.1.var_table@ = @MulExpr.0.var_table@;
            @i @MulExpr.0.node@ = new_mul(@Term.node@, @MulExpr.1.node@);

            @reggen calc_register(@MulExpr.node@);
        @}
    | Term
        @{
            @i @Term.var_table@ = @MulExpr.var_table@;
            @i @MulExpr.node@ = @Term.node@;
        @}
    ;

NegExpr: '-' NegExpr
        @{ 
            @i @NegExpr.1.var_table@ = @NegExpr.0.var_table@;
            @i @NegExpr.0.node@ = new_neg(@NegExpr.0.node@);

            @reggen calc_register(@NegExpr.node@);
        @}
    | Term
        @{ 
            @i @Term.var_table@ = @NegExpr.var_table@;
            @i @NegExpr.node@ = @Term.node@;
        @}
    ;

Term: '(' Expr ')'
        @{
            @i @Expr.var_table@ = @Term.var_table@;
            @i @Term.node@ = @Expr.node@;
        @}
    | NUMBER
        @{
            @i @Term.node@ = new_num(@NUMBER.val@);
        @}
    | Term '[' Expr ']'
        @{
            @i @Term.node@ = new_empty();
            @i @Term.1.var_table@ = @Term.0.var_table@;
            @i @Expr.var_table@ = @Term.0.var_table@;
        @}
    | IDENTIFIER
        @{
            @i @Term.node@ = new_var(@Term.var_table@, @IDENTIFIER.name@);

            @checkident check_identifier(@Term.var_table@, @IDENTIFIER.name@);
        @}
    | IDENTIFIER '(' FuncCall ')'
        @{
            @i @Term.node@ = new_empty();
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

void yyerror(char *s) {
    fprintf(stderr, "%d: Syntax Error at '%s'\n", yylineno, yytext);
    exit(2);
}

int main(int argc, char *argv[]) {
  yyparse();
  
  return 0;
}

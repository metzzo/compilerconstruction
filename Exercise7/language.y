%{
    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include "tree.h"
#include "table.h"
#include "code_gen.h"

void yyerror(char *s);
int yylex();

extern int      yylineno;
extern char*    yytext;

void burm_label(NODEPTR_TYPE);
void burm_reduce(NODEPTR_TYPE bnode, int goalnt);

char *gen_not_label() {
    static int label_count = 0;
    char *label_name = malloc(100*sizeof(char));
    sprintf(label_name, "continuelabel_%d", label_count);
    label_count++;
    return label_name;
}

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
@attributes { table *var_table; table *label_table; tree_node *node; int num_variables; } Stats 
@attributes { table *var_table; table *label_table; table *new_var_table; tree_node *node; int num_variables; } Stat 
@attributes { table *var_table; tree_node *node; } Expr 
@attributes { table *var_table; tree_node *node; char *label; } Cond 
@attributes { table *var_table; tree_node *node; } Term 
@attributes { table *var_table; tree_node *node; } Lexpr 
@attributes { table *var_table; tree_node *node; char *label; } AndCond 
@attributes { table *var_table; tree_node *node; char *label; } Cterm 
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
    @{
        //@checkident printf("Checking Identifier\n"); fflush(stdout);
        //@reggen printf("Generating Registers\n"); fflush(stdout);
        //@codegen printf("Generating code\n"); fflush(stdout);
    @}
    | /* empty */
    ;

Funcdef: IDENTIFIER '(' Pars ')' Stats KW_END 
        @{
            @i @Stats.var_table@ = @Pars.var_table@;
            @i @Stats.label_table@ = create_table();
            
            @codegen asm_func_def(@IDENTIFIER.name@, @Stats.num_variables@);
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
            @i @Stats.0.num_variables@ = @Stat.num_variables@ + @Stats.1.num_variables@;

            @i @Stats.0.node@ = new_stat(@Stat.0.node@, @Stats.1.node@);
        @}
    | /* empty */
        @{
            @i @Stats.node@ = new_empty();
            @i @Stats.num_variables@ = 0;
        @}
    ;

Labeldef: Labeldef IDENTIFIER ':'
        @{
            @i @Labeldef.1.label_table@ = create_symbol(@Labeldef.0.label_table@, @IDENTIFIER.name@, @Labeldef.0.var_table@);
            @i @Labeldef.1.var_table@ = @Labeldef.0.var_table@;

            @codegen asm_label_def(@IDENTIFIER.name@);
        @}
    | /* empty */
    ;

Stat: KW_RETURN Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_return(@Expr.0.node@);
            @i @Stat.num_variables@ = 0;

            @reggen calc_register(@Stat.node@);
			@codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@,1);
        @}
    | KW_GOTO IDENTIFIER
        @{
            @checkident check_identifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
            @i @Stat.num_variables@ = 0;

            @codegen asm_goto(@IDENTIFIER.name@);
        @}
    | KW_IF Cond KW_GOTO IDENTIFIER
        @{
            @checkident check_identifier(@Stat.label_table@, @IDENTIFIER.name@);
            @i @Cond.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_if(@Cond.node@, @IDENTIFIER.name@);
            @i @Stat.num_variables@ = 0;
            @i @Cond.label@ = @IDENTIFIER.name@;
            
            @reggen calc_register(@Stat.node@);
            @codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@,1);
        @}
    | KW_VAR IDENTIFIER '=' Expr
        @{
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_symbol(create_table(), to_local_var(@IDENTIFIER.name@), @Stat.label_table@);
            @i @Stat.node@ = new_assignment(new_lexpr_var(merge_table(@Stat.var_table@, @Stat.new_var_table@, create_table()), @IDENTIFIER.name@), @Expr.node@);
            @i @Stat.num_variables@ = 1;

            @reggen calc_register(@Stat.node@);

            @codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@,1);
        @}
    | Lexpr '=' Expr
        @{
            @i @Lexpr.var_table@ = @Stat.var_table@;
            @i @Expr.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_assignment(@Lexpr.node@, @Expr.node@);
            
            @i @Stat.num_variables@ = 0;

            @reggen calc_register(@Stat.node@);

            @codegen burm_label(@Stat.node@); burm_reduce(@Stat.node@,1);
        @}
    | Term
        @{
            @i @Term.var_table@ = @Stat.var_table@;
            @i @Stat.new_var_table@ = create_table();
            @i @Stat.node@ = new_empty();
            @i @Stat.num_variables@ = 0;
        @}
    ;

Cond: AndCond 
        @{
            @i @AndCond.var_table@ = @Cond.var_table@;
            @i @Cond.node@ = @AndCond.node@;
            @i @AndCond.label@ = @Cond.label@;
        @}
    | KW_NOT Cterm
        @{
            @i @Cterm.var_table@ = @Cond.var_table@;
            @i @Cond.node@ = new_not(@Cterm.node@, @Cterm.label@, @Cond.label@);
            @i @Cterm.label@ = gen_not_label();

            @reggen calc_register(@Cond.node@);
        @}
    ;

AndCond: Cterm KW_AND AndCond
        @{
            @i @Cterm.var_table@ = @AndCond.0.var_table@;
            @i @AndCond.1.var_table@ = @AndCond.0.var_table@;
            @i @AndCond.0.node@ = new_and(@Cterm.node@, @AndCond.1.node@);
            @i @Cterm.label@ = @AndCond.0.label@;
            @i @AndCond.1.label@ = @AndCond.0.label@;

            @reggen calc_register(@AndCond.0.node@);
        @}
    | Cterm
        @{
            @i @Cterm.var_table@ = @AndCond.var_table@;
            @i @AndCond.node@ = @Cterm.node@;
            @i @Cterm.label@ = @AndCond.0.label@;
        @}
    ;

Cterm: '(' Cond ')'
        @{
            @i @Cond.var_table@ = @Cterm.var_table@;
            @i @Cterm.node@ = @Cond.node@;
            @i @Cond.label@ = @Cterm.label@;
        @}
    | Expr OP_NOTEQU Expr
        @{
            @i @Expr.0.var_table@ = @Cterm.var_table@;
            @i @Expr.1.var_table@ = @Cterm.var_table@;
            @i @Cterm.node@ = new_notequ(@Expr.0.node@, @Expr.1.node@, @Cterm.label@);

            @reggen calc_register(@Cterm.node@);
        @}
    | Expr '>' Expr
        @{
            @i @Expr.0.var_table@ = @Cterm.var_table@;
            @i @Expr.1.var_table@ = @Cterm.var_table@;
            @i @Cterm.node@ = new_greater(@Expr.0.node@, @Expr.1.node@, @Cterm.label@);

            @reggen calc_register(@Cterm.node@);
        @}
    ;

Lexpr: IDENTIFIER
        @{
            @i @Lexpr.node@ = new_lexpr_var(@Lexpr.var_table@, @IDENTIFIER.name@);

            @checkident check_identifier(@Lexpr.var_table@, @IDENTIFIER.name@);
        @}
    | Term '[' Expr ']'
        @{
            @i @Lexpr.node@ = new_empty();

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
            @i @NegExpr.0.node@ = new_neg(@NegExpr.1.node@);

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
            @i @Term.1.var_table@ = @Term.0.var_table@;
            @i @Expr.var_table@ = @Term.0.var_table@;
            @i @Term.0.node@ = new_array_access(@Term.1.node@, @Expr.node@);

            @reggen calc_register(@Term.0.node@);
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

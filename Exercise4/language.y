%{
#include <stdio.h>
#include <stdlib.h>
#include "language.h"

void yyerror(char *s);
int yylex();

extern int      yylineno;
extern char*    yytext;

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

%start Program
%%

id: IDENTIFIER
    ;

num: NUMBER
    ;

Program: Funcdef ';' Program
    | /* empty */
    ;

Funcdef: id '(' Pars ')' Stats KW_END
    ;

Pars: id ',' Pars
    | id
    | /* empty */
    ;

Stats: Stats Labeldef Stat ';' 
    | /* empty */
    ;

Labeldef: Labeldef id ':' 
    | /* empty */
    ;

Stat: KW_RETURN Expr 
    | KW_GOTO id
    | KW_IF Cond KW_GOTO id
    | KW_VAR id '=' Expr
    | Lexpr '=' Expr
    | Term
    ;

Cond: AndCond 
    | KW_NOT Cterm
    ;

AndCond: Cterm KW_AND AndCond
    | Cterm
    ;

Cterm: '(' Cond ')'
    | Expr '!=' Expr
    | Expr '>' Expr
    ;

Lexpr: id
    | Term '[' Expr ']'
    ;

Expr: Term '+' AddExpr
    | Term '*' MulExpr
    | '-' NegExpr
    | Term
    ;

AddExpr: Term '+' AddExpr
    | Term
    ;

MulExpr: Term '*' MulExpr
    | Term
    ;

NegExpr: '-' NegExpr
    | Term
    ;

Term: '(' Expr ')'
    | num
    | Term '[' Expr ']'
    | id
    | id '(' FuncCall ')'
    ;

FuncCall: Expr ',' FuncCall
    | Expr
    | /* empty */

%%

void yyerror(char *s) {
    fprintf(stderr, "%d: Syntax Error at '%s'\n", yylineno, yytext);
    exit(2);
}

int main(int argc, char *argv[]) {
  yyparse();
  /*if (YY_START == comment) {
    yyerror("Missing closing '*)'\n"); 
  }*/
  return 0;
}

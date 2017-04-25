%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
%token OP_NOTEQU

@attributes { char* identifier_name; } IDENTIFIER
@attributes { int val; } NUMBER
@attributes { treenode *n; } id num
@traversal @preorder codegen

%{
extern void invoke_burm(NODEPTR_TYPE root);

treenode *newIdentifierNode(char* identifier);
treenode *newNumberNode(long val);

%}

%start Program
%%

id: IDENTIFIER @{ @i @id.n@ = newIdentifierNode(@IDENTIFIER.identifier_name@); @}
    ;

num: NUMBER @{ @i @num.n@ = newNumberNode(@NUMBER.val@); @}
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
    | Expr OP_NOTEQU Expr
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

treenode *newOperatorNode(int op, treenode *left, treenode *right)
{
  treenode *newNode = malloc(sizeof(treenode));

  if (newNode == NULL) { printf("Out of memory.\n"); exit(4);}

  newNode->op = op;
  newNode->kids[0] = left;
  newNode->kids[1] = right;
  newNode->identifier_name = NULL;
  newNode->val = 0;

  return newNode;
}

treenode *newIdentifierNode(char* identifier)
{
  treenode *newNode = newOperatorNode(IDENT,NULL,NULL);
  newNode->identifier_name = identifier;
  return newNode;
}

treenode *newNumberNode(long val)
{
  treenode *newNode = newOperatorNode(NUM,NULL,NULL);
  newNode->val = val;
  return newNode;
}


void yyerror(char *s) {
    fprintf(stderr, "%d: Syntax Error at '%s'\n", yylineno, yytext);
    exit(2);
}

int main(int argc, char *argv[]) {
  yyparse();
  
  return 0;
}

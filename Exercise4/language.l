%option noyywrap

%{
    #include <stdlib.h>
    #include "language.tab.h"
    void lexerror(char *s);
    void number(char *s);
%}

%x comment
%%
"(*" BEGIN(comment);
<comment>"*)" BEGIN(INITIAL);
<comment>\n|. {}
<comment><<EOF>> {lexerror("Comment not closed."); }

<INITIAL>[0-9_]+ { number(yytext); return NUMBER; }

<INITIAL>" "|"\t"|"\n" { /* nothing */ }
<INITIAL>"end" { printf("%s\n", yytext); return KW_END; }
<INITIAL>"return" { printf("%s\n", yytext); return KW_RETURN; }
<INITIAL>"goto" { printf("%s\n", yytext); return KW_GOTO; }
<INITIAL>"if" { printf("%s\n", yytext); return KW_IF; }
<INITIAL>"var" { printf("%s\n", yytext); return KW_VAR; }
<INITIAL>"and" { printf("%s\n", yytext); return KW_AND; }
<INITIAL>"not" { printf("%s\n", yytext); return KW_NOT; }


<INITIAL>[a-zA-Z][0-9a-zA-Z]* { printf("id %s\n", yytext); return IDENTIFIER; }
<INITIAL>";"|"("|")"|","|":"|"="|"!="|">"|"["|"]"|"-"|"+"|"*" { printf("%s\n", yytext); return yytext[0]; }
<INITIAL>. { lexerror("Unrecognized character"); }
%%

void number(char *s) {
    int nr = 0;
    int power = 1;
    for (int i = strlen(s) - 1; i >= 0; i--) {
        if (s[i] != '_') {
            nr += (s[i] - '0')*power;
            power *= 10;
        }
    }
    printf("num %d\n", nr);
};

void lexerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}
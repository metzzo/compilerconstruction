%option noyywrap

%{
    #include <stdlib.h>
    #include "oxout.tab.h"
    void lexerror(char *s);
    int64_t number(char *s);
%}

whitespace	[\n\t ]
comment		\n|.

%x comment

%%
"(*" BEGIN(comment);
<comment>"*)" BEGIN(INITIAL);
<comment>{comment} {};
<comment><<EOF>> { lexerror("Comment not closed."); };
<INITIAL>[0-9_]+ return NUMBER; @{ @NUMBER.val@ = number(yytext); @}
<INITIAL>{whitespace} {};
<INITIAL>"end" return KW_END;
<INITIAL>"return" return KW_RETURN;
<INITIAL>"goto" return KW_GOTO;
<INITIAL>"if" return KW_IF;
<INITIAL>"var" return KW_VAR;
<INITIAL>"and" return KW_AND;
<INITIAL>"not" return KW_NOT;
<INITIAL>[a-zA-Z][0-9a-zA-Z]* return IDENTIFIER; @{ @IDENTIFIER.name@ = strdup(yytext); @}
<INITIAL>"!=" return OP_NOTEQU;
<INITIAL>";" return ';';
<INITIAL>"(" return '(';
<INITIAL>")" return ')';
<INITIAL>"," return ',';
<INITIAL>":" return ':';
<INITIAL>"=" return '=';
<INITIAL>">" return '>';
<INITIAL>"[" return '[';
<INITIAL>"]" return ']';
<INITIAL>"-" return '-';
<INITIAL>"+" return '+';
<INITIAL>"*" return '*';
<INITIAL>. { lexerror("Unrecognized character"); };
%%

int64_t number(char *s) {
    int64_t nr = 0;
    int64_t power = 1;
    for (int i = strlen(s) - 1; i >= 0; i--) {
        if (s[i] != '_') {
            nr += (s[i] - '0')*power;
            power *= 10;
        }
    }
    return nr;
};

void lexerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

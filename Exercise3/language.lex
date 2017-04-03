%option noyywrap

%{
    void yyerror(char *s, char *text);
    void number(char *s);
%}

%x comment
%%
"(*" BEGIN(comment);
<comment>"*)" BEGIN(INITIAL);
<comment>\n|. {}

<INITIAL>[0-9_]+ { number(yytext); }

<INITIAL>" "|"\t"|"\n" { /* nothing */ }
<INITIAL>"end"|"return"|"goto"|"if"|"var"|"and"|"not" { printf("%s\n", yytext); }
<INITIAL>[a-zA-Z][0-9a-zA-Z]* { printf("id %s\n", yytext);}
<INITIAL>";"|"("|")"|","|":"|"="|"!="|">"|"["|"]"|"-"|"+"|"*" { printf("%s\n", yytext); }
<INITIAL>. { yyerror("Unrecognized character: %s\n", yytext); }
%%

int main(int argc, char *argv[]) {
  yylex();
  if (YY_START == comment) {
    yyerror("Missing closing '*)'\n", ""); 
  }
  return 0;
}

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

void yyerror(char *s, char *text) {
    fprintf(stderr, s, text);
    exit(1);
}
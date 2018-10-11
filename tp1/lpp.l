%{
    /* Declaracoes C diversas */
%}

%option stack

%x AUTHOR
%x DOCTYPE
%x DOCUMENT
%x TITLE

%%
^\s*$ {
    printf("\\begin{document}");
    BEGIN(DOCUMENT);
}

^=title=\[ BEGIN(TITLE);
<TITLE>[^\]]+    printf("\\title{%s}", yytext);

^=author=\[ BEGIN(TITLE);
<AUTHOR>[^\]]+    printf("\\author{%s}", yytext);

^=doctype=\[ BEGIN(DOCTYPE);
<DOCTYPE>[^\]]+    printf("\\documentclass{%s}", yytext);

<TITLE,AUTHOR,DOCTYPE>\]$       BEGIN(INITIAL);

<DOCUMENT>.|\n   ECHO;

<<EOF>>   { puts("\\end{document}"); return 0; /* Se nao acabarmos a funcao, o programa fica em loop */ }

%%
int yywrap ()
{
    return 1;
}

int main ()
{
    yylex();
    return 0;
}

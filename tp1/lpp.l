%{
#include <assert.h>

    /* Declaracoes C diversas */
    int nh = 0;
    char * chaps[] = {
        "chapter",
        "section",
        "subsection",
        "subsubsection",
        "paragraph",
        "subparagraph",
    };
    static const unsigned nc = sizeof(chaps) / sizeof(*chaps);
%}

%option stack

%x AUTHOR
%x BODY
%x BODY_HEADER
%x DOCTYPE
%x TITLE

%%
^\s*$ {
    printf("\\begin{document}");
    BEGIN(BODY);
}

^=author=\[        BEGIN(TITLE);
^=doctype=\[       BEGIN(DOCTYPE);
^=title=\[         BEGIN(TITLE);

<AUTHOR>[^\]]+     printf("\\author{%s}", yytext);
<DOCTYPE>[^\]]+    printf("\\documentclass{%s}", yytext);
<TITLE>[^\]]+      printf("\\title{%s}", yytext);

<TITLE,AUTHOR,DOCTYPE>\]$    BEGIN(INITIAL);

<BODY_HEADER>[^#\n]*$          {
    nh--;
    if (((unsigned) nh) >= nc)
        nh = nc - 1;

    printf("\\%s{%s}", chaps[nh], yytext);
    nh = 0;
    BEGIN(BODY);
}

<BODY>^#+                     { nh = yyleng; BEGIN(BODY_HEADER); }
<BODY>.|\n                   ECHO;

<<EOF>> {
    puts("\\end{document}");
    /* Se nao acabarmos a funcao, o programa fica em loop */
    return 0;
}

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

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
%x LIST_ENUMERATE
%x LIST_ITEMIZE
%x TITLE
%x VERBATIM

%%
^\s*$ {
    printf("\\begin{document}");
    yy_push_state(BODY);
}

^=author=\[        yy_push_state(AUTHOR);
^=doctype=\[       yy_push_state(DOCTYPE);
^=title=\[         yy_push_state(TITLE);

<AUTHOR>[^\]]+     printf("\\author{%s}", yytext);
<DOCTYPE>[^\]]+    printf("\\documentclass{%s}", yytext);
<TITLE>[^\]]+      printf("\\title{%s}", yytext);

<TITLE,AUTHOR,DOCTYPE>\]$    yy_pop_state();

<BODY_HEADER>[^#\n]*$          {
    nh--;
    if (((unsigned) nh) >= nc)
        nh = nc - 1;

    printf("\\%s{%s}", chaps[nh], yytext);
    nh = 0;
    yy_pop_state();
}

<BODY>\\begin\{verbatim\}          { ECHO; yy_push_state(VERBATIM); }
<BODY>^#+                     { nh = yyleng; yy_push_state(BODY_HEADER); }
<BODY>.|\n                   ECHO;

<VERBATIM>\\end\{verbatim\}   { ECHO; yy_pop_state(); }
<VERBATIM>[^}] ECHO;

:\n/\.         { yy_push_state(LIST_ENUMERATE); }
:\n/\.[0-9]    { yy_push_state(LIST_ITEMIZE);   }

<LIST_ENUMERATE,LIST_ITEMIZE>^=$ { yy_pop_state(); }

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

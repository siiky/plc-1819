%{
#define NDEBUG

#ifndef NDEBUG
#define stpush(ST) \
    do {                                       \
        fprintf(stderr, "*** PUSH %s\n", #ST); \
        yy_push_state(ST);                     \
    } while (0)

#define stpop() \
    do {                              \
        fprintf(stderr, "*** POP\n"); \
        yy_pop_state();               \
    } while (0)
#else
#define stpush yy_push_state
#define stpop yy_pop_state
#endif

    /* Supported LaTeX header tags */
    static const char * chaps[] = {
        "chapter",
        "section",
        "subsection",
        "subsubsection",
        "paragraph",
        "subparagraph",
    };

    /* Number of supported LaTeX header tags */
    static const unsigned nc = sizeof(chaps) / sizeof(*chaps);

    /* Header level, 0-nc */
    int nh = 0;
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
    /*
     * An empty line starts the body of the document,
     * so all the headers must come before any empty line
     */
    printf("\\begin{document}");
    stpush(BODY);
}

^=author=\[  stpush(AUTHOR);
^=doctype=\[ stpush(DOCTYPE);
^=title=\[   stpush(TITLE);

<AUTHOR>[^\]\n]+  printf("\\author{%s}",        yytext);
<DOCTYPE>[^\]\n]+ printf("\\documentclass{%s}", yytext);
<TITLE>[^\]\n]+   printf("\\title{%s}",         yytext);

<TITLE,AUTHOR,DOCTYPE>\]$ stpop();

<BODY_HEADER>[^#\n]*$ {
    /* Make sure `nh` is in bounds */
    if (((unsigned) --nh) >= nc)
        nh = nc - 1;

    printf("\\%s{%s}", chaps[nh], yytext);
    nh = 0;
    stpop();
}

<BODY>\\begin\{verbatim\} { ECHO; stpush(VERBATIM); }
<BODY>^#+                 { nh = yyleng; stpush(BODY_HEADER); }
<BODY>:/\n\.              { printf("\\begin{itemize}");   stpush(LIST_ITEMIZE);   }
<BODY>:/\n\.[0-9]         { printf("\\begin{enumerate}"); stpush(LIST_ENUMERATE); }
<BODY>.|\n                ECHO;

<VERBATIM>\\end\{verbatim\} { ECHO; stpop(); }
<VERBATIM>.|\n              ECHO;

<LIST_ITEMIZE>^\.\s*         { printf("\\item "); }
<LIST_ENUMERATE>^\.[0-9]+\s* { printf("\\item "); }

<LIST_ENUMERATE,LIST_ITEMIZE>.|\n ECHO;

<LIST_ENUMERATE>^\s*=\s*$ { printf("\\end{enumerate}"); stpop(); }
<LIST_ITEMIZE>^\s*=\s*$   { printf("\\end{itemize}");   stpop(); }

<<EOF>> {
    printf("\\end{document}");
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

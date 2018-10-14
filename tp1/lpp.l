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
%x LIST_DESCRIPTION
%x TITLE
%x VERBATIM
%x BOLD
%x ITALIC

%%

<INITIAL,
 AUTHOR,
 BODY,
 BODY_HEADER,
 DOCTYPE,
 LIST_ENUMERATE,
 LIST_ITEMIZE,
 LIST_DESCRIPTION,
 TITLE,
 BOLD,
 ITALIC>{
         á       { printf("\\'a");} 
         à       { printf("\\`a");} 
         ã       { printf("\\~a");}
         â       { printf("\\^a");}
         é       { printf("\\'e");}
         ê       { printf("\\^e");}
         í       { printf("\\'{\\i}");}
         Í       { printf("\\'I");}
         ó       { printf("\\'o");}
         õ       { printf("\\~o");}
         ô       { printf("\\^o");}
         ú       { printf("\\'u");}
         ç       { printf("\\c{c}");}
         Ç       { printf("\\c{C}");}
         [0-9]+ª { yytext[yyleng-2]='\0'; printf("%s\\textordfeminine",yytext);}
         [0-9]+º { yytext[yyleng-2]='\0'; printf("%s\\textordmasculine",yytext);}
        }



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

<BODY>^=indice=       { printf("\\tableofcontents");}
<BODY>\\bverb[ \n\t]           { printf("\\begin{verbatim}"); stpush(VERBATIM); }
<BODY>^#+                 { nh = yyleng; stpush(BODY_HEADER); }
<BODY>:/\n\.              { printf("\\begin{itemize}");   stpush(LIST_ITEMIZE);   }
<BODY>:/\n\.[0-9]         { printf("\\begin{enumerate}"); stpush(LIST_ENUMERATE); }
<BODY>:/\n\.\[            { printf("\\begin{description}"); stpush(LIST_DESCRIPTION);}
<BODY>\\bf\{              { printf("\\textbf{"); stpush(BOLD); }
<BODY>\\it\{              { printf("\\textit{"); stpush(ITALIC); }

<BODY>.|\n                ECHO;

<VERBATIM>\\everb         { printf("\\end{verbatim}"); stpop(); }
<VERBATIM>.|\n              ECHO;

<LIST_ITEMIZE>^\.\s*         { printf("\\item "); }
<LIST_ENUMERATE>^\.[0-9]+\s* { printf("\\item "); }
<LIST_DESCRIPTION>^\.\[      { printf("\\item ["); }

<LIST_ENUMERATE,LIST_ITEMIZE,LIST_DESCRIPTION>.|\n      ECHO;
<LIST_ENUMERATE,LIST_ITEMIZE,LIST_DESCRIPTION>\\bf\{    { printf("\\textbf{"); stpush(BOLD); }
<LIST_ENUMERATE,LIST_ITEMIZE,LIST_DESCRIPTION>\\it\{    { printf("\\textit{"); stpush(ITALIC); }

<LIST_ENUMERATE>^\s*=\s*$    { printf("\\end{enumerate}"); stpop(); }
<LIST_ITEMIZE>^\s*=\s*$      { printf("\\end{itemize}");   stpop(); }
<LIST_DESCRIPTION>^\s*=\s*$  { printf("\\end{description}"); stpop(); }

<ITALIC>\\bf\{               { printf("\\textbf{"); stpush(BOLD); }
<BOLD>\\it\{                 { printf("\\textit{"); stpush(ITALIC); }
<BOLD,ITALIC>[^\("\bf"|"\it")}]*\}        { ECHO; stpop(); }


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
%{
#include <stdio.h>

#include "lex.yy.h"
#include "gen.h"

int yyerror (const char *s);

%}

%token EQ
%token NEQ
%token LEQ
%token GEQ
%token WRITE
%token IF
%token BOOL_VALUE
%token FLOAT_VALUE
%token UNTIL
%token INT_VALUE
%token STR
%token TYPE
%token VAR
%token READ

%%

programa : statement
         | statement programa
         ;

statement : '(' statement_list ')' ;

statement_list : ':' TYPE VAR DEFAULT
               | '=' VAR expression
               | WRITE writable
               | READ VAR
               | IF expression2 '(' programa ')' else_clause
               | UNTIL expression2 '(' programa ')'
               ;

writable : expression
         | STR
         ;

DEFAULT :
        | expression
        ;

else_clause :
            | '(' programa ')'
            ;

expression : VALUE
           | expression2
           | '(' expression_list ')'
           ;

VALUE : INT_VALUE
      | FLOAT_VALUE
      ;

arith_op : '+' { gen_op('+', 0); }
         | '*' { gen_op('*', 0); }
         | '-' { gen_op('-', 0); }
         | '/' { gen_op('/', 0); }
         | '%' { gen_op('%', 0); }
         ;

expression_list : arith_op expression expression {
                /* if (typeof($2) != typeof($3)) error(); */
                }
                ;

expression2 : VAR
            | BOOL_VALUE
            | '(' expression2_list ')'
            ;

log_op : EQ  { gen_op(EQ, 0); }
       | LEQ { gen_op(LEQ, 0); }
       | GEQ { gen_op(GEQ, 0); }
       | NEQ { gen_op(NEQ, 0); }
       | '<' { gen_op('<', 0); }
       | '>' { gen_op('>', 0); }
       ;

expression2_list : '~' expression2              { gen_op('~', 0); }
                 | log_op expression expression {
                 /* if (typeof($2) != typeof($3)) error(); */
                 }
                 ;

%%

int yyerror (const char *s)
{
  return fprintf(stderr, "ERRO: '%s'\n", s);
}

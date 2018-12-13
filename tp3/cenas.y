%{
#include <stdio.h>

#include "lex.yy.h"

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

arith_op : '+'
         | '*'
         | '-'
         | '/'
         | '%'
         ;

expression_list : arith_op expression expression {
                /* if (typeof($2) != typeof($3)) error(); */
                /* gen_op($1, typeof($2)); */
                }
                ;

expression2 : VAR
            | BOOL_VALUE
            | '(' expression2_list ')'
            ;

log_op : EQ
       | LEQ
       | GEQ
       | NEQ
       | '<'
       | '>'
       ;

expression2_list : '~' expression2
                 | log_op expression expression {
                 /* if (typeof($2) != typeof($3)) error(); */
                 /* gen_op($1, typeof($2)); */
                 }
                 ;

%%

int yyerror (const char *s)
{
  return fprintf(stderr, "ERRO: '%s'\n", s);
}

int main ()
{
    yyparse();
    return 0;
}

%{
#include <stdio.h>

#include "lex.yy.h"
#include "env.h"
#include "gen.h"

int yyerror (const char *s);

%}

%union {
    char * valString;
    float  valFloat;
    int    valBool;
    int    valInt;
    unsigned char valType;
    struct {
        unsigned char type;
    } valExpr;
}

%token EQ
%token NEQ
%token LEQ
%token GEQ
%token WRITE
%token IF
%token UNTIL
%token READ

%token <valBool>  BOOL_VALUE
%token <valFloat> FLOAT_VALUE
%token <valInt>   INT_VALUE
%token <valString>STR
%token <valString>VAR
%token <valType>  TYPE

%type <valInt> arith_op
%type <valInt> log_op
%type <valExpr>expression
%type <valExpr>expression_list
%type <valExpr>expression2
%type <valExpr>expression2_list
%type <valExpr>writable
%type <valType>VALUE
%type <valExpr>DEFAULT

%%

programa : statements
         | statements programa
         ;

statements : '(' statement ')' ;

statement : ':' TYPE VAR DEFAULT {
              if ($4.type != TYPE_ERROR && $2 != $4.type)
                  yyerror("Types don't match");
              struct var var = { .id = $3, .type = $2, };
              env_new_var(env, var);
          }
          | '=' VAR expression {
              struct var * v = env_var(env, $2);
          }
          | WRITE writable
          | READ VAR {
              struct var * v = env_var(env, $2);
          }
          | IF expression2 '(' programa ')' else_clause
          | UNTIL expression2 '(' programa ')'
          ;

writable : expression { $$.type = $1.type; }
         | STR        { $$.type = TYPE_STRING; }
         ;

DEFAULT :            { $$.type = TYPE_ERROR; }
        | expression { $$.type = $1.type; }
        ;

else_clause :
            | '(' programa ')'
            ;

expression : VALUE                   { $$.type = $1; puts(yytext); }
           | expression2             { $$.type = $1.type; }
           | '(' expression_list ')' { $$.type = $2.type; puts(yytext); }
           ;

VALUE : INT_VALUE   { $$ = TYPE_INT; }
      | FLOAT_VALUE { $$ = TYPE_FLOAT; }
      ;

arith_op : '+' { $$ = '+'; }
         | '*' { $$ = '*'; }
         | '-' { $$ = '-'; }
         | '/' { $$ = '/'; }
         | '%' { $$ = '%'; }
         ;

expression_list : arith_op expression expression {
                    enum type t1 = $2.type;
                    enum type t2 = $3.type;
                    if (t1 == TYPE_ERROR || t2 == TYPE_ERROR || t1 != t2)
                        yyerror("Types don't match");
                    gen_op($1, t1);
                    $$.type = t1;
                }
                ;

expression2 : VAR {
                if (env_typeof(env, $1) == TYPE_ERROR)
                    yyerror("Variable not found");
                $$.type = TYPE_BOOL;
            }
            | BOOL_VALUE { $$.type = TYPE_BOOL; puts(yytext); }
            | '(' expression2_list ')' { $$.type = TYPE_BOOL; }
            ;

log_op : EQ  { $$ = EQ;  }
       | LEQ { $$ = LEQ; }
       | GEQ { $$ = GEQ; }
       | NEQ { $$ = NEQ; }
       | '<' { $$ = '<'; }
       | '>' { $$ = '>'; }
       ;

expression2_list : '~' expression2              { $$.type = $2.type; gen_op('~', 0); }
                 | log_op expression expression {
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     if (t1 == TYPE_ERROR || t2 == TYPE_ERROR || t1 != t2)
                         yyerror("Types don't match");
                     gen_op($1, t1);
                     $$.type = TYPE_BOOL;
                 }
                 ;

%%

int yyerror (const char *s)
{
  return fprintf(stderr, "ERRO: '%s'\n", s);
}

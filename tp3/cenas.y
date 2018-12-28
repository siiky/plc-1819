%{
#include <stdbool.h>
#include <stdio.h>

#include "env.h"
#include "gen.h"
#include "str.h"
#include "rope.h"

#include "lex.yy.h"

int yyerror (const char *s);

#ifndef NDEBUG
#define log(...) (fprintf(stderr, __VA_ARGS__))
#else
#define log(...) ((void) 0)
#endif /* NDEBUG */

#define cbapp(self, other) do { \
    if (!rope_append(&(self), &(other)))            \
        log("Error appending code blocks: %s:%d\n", \
            __FILE__,                               \
            __LINE__);                              \
    (other) = rope_free(other);                     \
    } while (0)

%}

%union {
    struct expr {
        struct rope   code;
        struct env *  env;
        unsigned char type;
    }             valExpr;

    bool          valBool;
    char *        valString;
    float         valFloat;
    int           valInt;
    struct rope   valCode;
    unsigned char valType;
}

%token AND
%token OR
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

%type <valCode>code_block
%type <valCode>else_clause
%type <valCode>statement
%type <valCode>statements

%type <valExpr>DEFAULT
%type <valExpr>expression
%type <valExpr>expression2
%type <valExpr>expression2_list
%type <valExpr>expression_list
%type <valExpr>writable

%type <valInt> arith_op
%type <valInt> log_op
%type <valInt> num_op

%type <valType>VALUE

%%

programa : code_block {
             for (rope_iter(&$1); rope_itering(&$1); rope_iter_next(&$1)) {
                 struct str str = rope_get_nth(&$1, rope_iter_idx(&$1));
                 if (!str_push(&str, '\0')) {
                     log("Error adding NULL byte\n");
                     break;
                 }
                 puts(str_as_slice(&str));
             }
             $1 = rope_free($1);
         }
         ;

code_block : statements            { $$ = $1; }
           | statements code_block {
               $$ = $1;
               cbapp($$, $2);
           }
           ;

statements : '(' statement ')' { $$ = $2; }
           ;

statement : ':' TYPE VAR DEFAULT {
              if ($4.type > TYPE_ERROR && $4.type < TYPE_DEFAULT && $2 != $4.type)
                  log("Types don't match:\tDECL: TYPE = %s, DEFAULT = %s\n", type2str($2), type2str($4.type));

              struct var var = { .id = $3, .type = $2, };
              env_set_var(env, var);

              $$ = $4.code;
          }
          | '=' VAR expression {
              struct var * v = env_var(env, $2);
              $$ = $3.code;
          }
          | WRITE writable {
              $$ = $2.code;
              gen_op(&$$, WRITE, $2.type);
          }
          | READ VAR {
              $$ = (struct rope) {0};
              struct var * v = env_var(env, $2);
              if (v == NULL)
                  log("Variable not found");
              else
                  gen_op(&$$, READ, v->type);
          }
          | IF expression2 '(' code_block ')' else_clause {
              unsigned num = gen_ifno();

              $$ = $2.code;
              gen_jz(&$$, "TIF", num); /* jump to else label */
              cbapp($$, $4);
              gen_jump(&$$, "EIF", num); /* jump to endif label */
              gen_nlbl(&$$, "TIF", num); /* create else label */
              cbapp($$, $6);
              gen_nlbl(&$$, "EIF", num); /* create endif label */
          }
          | UNTIL expression2 '(' code_block ')' {
              $$ = (struct rope) {0};
              unsigned num = gen_untilno();

              gen_nlbl(&$$, "UNTIL", num);
              cbapp($$, $4);
              cbapp($$, $2.code);
              gen_jz(&$$, "UNTIL", num);
          }
          ;

writable : expression {
             $$.code = $1.code;
             $$.type = $1.type;
         }
         | STR        {
             $$.code = (struct rope) {0};
             $$.type = TYPE_STRING;
             gen_push(&$$.code, TYPE_STRING, yytext, false);
         }
         ;

DEFAULT : {
            $$ = (struct expr) {0};
            $$.type = TYPE_DEFAULT;
        }
        | expression { $$ = $1; }
        ;

else_clause :                    { $$ = (struct rope) {0}; }
            | '(' code_block ')' { $$ = $2; }
            ;

expression : VALUE {
               $$ = (struct expr) {0};
               $$.type = $1;
               gen_push(&$$.code, $1, yytext, false);
           }
           | expression2             { $$ = $1; }
           | '(' expression_list ')' { $$ = $2; }
           ;

VALUE : INT_VALUE   { $$ = TYPE_INT;   }
      | FLOAT_VALUE { $$ = TYPE_FLOAT; }
      ;

arith_op : '+' { $$ = '+'; }
         | '*' { $$ = '*'; }
         | '-' { $$ = '-'; }
         | '/' { $$ = '/'; }
         | '%' { $$ = '%'; }
         ;

expression_list : arith_op expression expression {
                    $$ = (struct expr) {0};
                    enum type t1 = $2.type;
                    enum type t2 = $3.type;
                    if (t1 == TYPE_ERROR || t2 == TYPE_ERROR || t1 != t2)
                        log("Types don't match");
                    $$.type = t1;

                    $$.code = $2.code;
                    cbapp($$.code, $3.code);
                    gen_op(&$$.code, $1, t1);
                }
                ;

expression2 : VAR {
                $$ = (struct expr) {0};
                enum type t = env_typeof(env, $1);
                if (t == TYPE_ERROR)
                    log("Variable not found");
                $$.type = t;

                /* LOAD VARIABLE */
                /*
                 gen_load(&$$.code, 
                 */
            }
            | BOOL_VALUE {
                $$.code = (struct rope) {0};
                $$.type = TYPE_BOOL;
                gen_push(&$$.code, TYPE_BOOL, NULL, yylval.valBool);
            }
            | '(' expression2_list ')' {
                $$.code = $2.code;
                $$.type = $2.type;
            }
            ;

num_op : EQ  { $$ = EQ;  }
       | LEQ { $$ = LEQ; }
       | GEQ { $$ = GEQ; }
       | NEQ { $$ = NEQ; }
       | '<' { $$ = '<'; }
       | '>' { $$ = '>'; }
       ;

log_op : AND { $$ = AND; }
       | OR  { $$ = OR;  }
       ;

expression2_list : '~' expression2 {
                     enum type t = $2.type;
                     if (t != TYPE_BOOL)
                         log("Types don't match");
                     $$.type = t;

                     $$.code = $2.code;

                     gen_op(&$$.code, '~', $2.type);
                 }
                 | num_op expression expression {
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     if (t1 == TYPE_ERROR || t2 == TYPE_ERROR || t1 != t2)
                         log("Types don't match");
                     $$.type = TYPE_BOOL;

                     $$.code = $2.code;
                     cbapp($$.code, $3.code);
                     gen_op(&$$.code, $1, t1);
                 }
                 | log_op expression2 expression2 {
                     enum type t = $2.type;
                     if (t != TYPE_BOOL)
                         log("Types don't match");
                     $$.type = t;

                     $$.code = $2.code;
                     cbapp($$.code, $3.code);
                     gen_op(&$$.code, $1, t);
                 }
                 ;

%%

int yyerror (const char *s)
{
  return fprintf(stderr, "ERRO: '%s'\n", s);
}

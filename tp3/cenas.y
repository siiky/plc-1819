%{
#include <stdbool.h>
#include <stdio.h>

#include "env.h"
#include "gen.h"
#include "str.h"
#include "rope.h"

#include "lex.yy.h"

int yyerror (const char *s);

/** Mensagens de erro */
#define err(...) ((void) fprintf(stderr, "ERR: " __VA_ARGS__))

#ifndef NDEBUG
/** Mensagens para debugging */
#define log(...) ((void) fprintf(stderr, "LOG: " __VA_ARGS__))
#else
#define log(...) ((void) 0)
#endif /* NDEBUG */

/** Mostra as producoes por onde passa */
#ifdef TRACE
#define trace(...) (log("TRACE: %s:%d\n", __FILE__, __LINE__))
#else
#define trace(...) ((void) 0)
#endif /* TRACE */

#define type_valid(t) ((t) > TYPE_ERROR && (t) < TYPE_DEFAULT)
#define type_compat(t1, t2) ((t1) == (t2))

/**
 * Concatena dois blocos de codigo, @a self e @a other, e imprime
 * uma mensagem em caso de erro
 */
#define cbapp(self, other) do { \
    if (!rope_append(&(self), &(other)))      \
        err("appending code blocks: %s:%d\n", \
            __FILE__, __LINE__);              \
    (other) = rope_free(other);               \
    } while (0)

/**
 * Gera wrappers para funcoes geradoras de codigo que imprimem
 * uma mensagem em caso de erro
 */
#define gen_(f, ...)           \
    (((f)(__VA_ARGS__)) ?      \
        true:                  \
        (err(#f "(): %s:%d\n", \
            __FILE__, __LINE__), false))

#define gen_jump(c, l, n)    gen_(gen_jump, (c), (l), (n))
#define gen_jz(  c, l, n)    gen_(gen_jz,   (c), (l), (n))
#define gen_nlbl(c, l, n)    gen_(gen_nlbl, (c), (l), (n))
#define gen_op(  c, o, t)    gen_(gen_op,   (c), (o), (t))
#define gen_push(c, t, a, b) gen_(gen_push, (c), (t), (a), (b))

%}

%union {
    struct expr {
        enum type   type;
        struct rope code;
    }           valExpr;

    bool        valBool;
    char *      valString;
    enum type   valType;
    float       valFloat;
    int         valInt;
    struct rope valCode;
}

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

%type <valInt>arith_op
%type <valInt>log_op
%type <valInt>num_op

%type <valType>VALUE

%%

programa : code_block { trace();
             /* TODO: print vars */
             fputs("START\n", yyout);
             rope_fprint(&$1, yyout);
             fputs("STOP\n", yyout);
             $1 = rope_free($1);
         }
         ;

code_block : statements            { trace(); $$ = $1; }
           | statements code_block { trace();
               $$ = $1;
               cbapp($$, $2);
           }
           ;

statements : '(' statement ')' { trace(); $$ = $2; }
           ;

statement : ':' TYPE VAR DEFAULT { trace();
              if ($4.type == TYPE_ERROR
              || (type_valid($4.type) && !type_compat($2, $4.type)))
                  err("Type error:\tDECL: TYPE = %s, DEFAULT = %s\n", type2str($2), type2str($4.type));

              struct var var = { .id = $3, .type = $2, };
              env_set_var(env, var);

              $$ = $4.code;
          }
          | '=' VAR expression { trace();
              struct var * v = env_var(env, $2);
              if (v == NULL)
                  err("Variable not found: `%s`\n", $2);
              $$ = $3.code;
              /* TODO: STORE */
              /* gen_store(&$$); */
          }
          | WRITE writable { trace();
              $$ = $2.code;
              gen_op(&$$, WRITE, $2.type);
          }
          | READ VAR { trace();
              /* TODO: READ and convert */
              $$ = (struct rope) {0};
              struct var * v = env_var(env, $2);
              if (v == NULL)
                  err("Variable not found: `%s`\n", $2);
              else
                  gen_op(&$$, READ, v->type);
              /* gen_store(&$); */
          }
          | IF expression2 '(' code_block ')' else_clause { trace();
              unsigned num = gen_ifno();

              $$ = $2.code;
              gen_jz(&$$, "TIF", num);   /* jump to else label? */
              cbapp($$, $4);             /* then block */
              gen_jump(&$$, "EIF", num); /* jump to endif label */
              gen_nlbl(&$$, "TIF", num); /* else label */
              cbapp($$, $6);             /* else block (possibly empty) */
              gen_nlbl(&$$, "EIF", num); /* endif label */
          }
          | UNTIL expression2 '(' code_block ')' { trace();
              $$ = (struct rope) {0};
              unsigned num = gen_untilno();

              gen_nlbl(&$$, "UNTIL", num); /* until label */
              cbapp($$, $4);               /* loop body block */
              cbapp($$, $2.code);          /* condition */
              gen_jz(&$$, "UNTIL", num);   /* jump to until label? */
          }
          ;

writable : expression { trace(); $$ = $1; }
         | STR        { trace();
             $$ = (struct expr) {0};
             $$.type = TYPE_STRING;
             gen_push(&$$.code, TYPE_STRING, yytext, false);
         }
         ;

DEFAULT : { trace();
            $$ = (struct expr) {0};
            $$.type = TYPE_DEFAULT;
        }
        | expression { trace(); $$ = $1; }
        ;

else_clause :                    { trace(); $$ = (struct rope) {0}; }
            | '(' code_block ')' { trace(); $$ = $2; }
            ;

expression : VALUE { trace();
               $$ = (struct expr) {0};
               $$.type = $1;
               gen_push(&$$.code, $1, yytext, false);
           }
           | expression2             { trace(); $$ = $1; }
           | '(' expression_list ')' { trace(); $$ = $2; }
           ;

VALUE : INT_VALUE   { trace(); $$ = TYPE_INT;   }
      | FLOAT_VALUE { trace(); $$ = TYPE_FLOAT; }
      ;

arith_op : '+' { trace(); $$ = '+'; }
         | '*' { trace(); $$ = '*'; }
         | '-' { trace(); $$ = '-'; }
         | '/' { trace(); $$ = '/'; }
         | '%' { trace(); $$ = '%'; }
         ;

expression_list : arith_op expression expression { trace();
                    $$ = (struct expr) {0};
                    enum type t1 = $2.type;
                    enum type t2 = $3.type;
                    if (t1 == TYPE_ERROR || t2 == TYPE_ERROR || t1 != t2)
                        err("Type error: op1::%s and op2::%s\n", type2str(t1), type2str(t2));
                    $$.type = t1;

                    $$.code = $2.code;
                    cbapp($$.code, $3.code);
                    gen_op(&$$.code, $1, t1);
                }
                ;

expression2 : VAR { trace();
                $$ = (struct expr) {0};
                $$.type = env_typeof(env, $1);
                if (!type_valid($$.type))
                    err("Variable not found: `%s`\n", $1);

                /* TODO: LOAD VARIABLE */
                /*
                 gen_load(&$$.code, v);
                 */
            }
            | BOOL_VALUE { trace();
                $$ = (struct expr) {0};
                $$.type = TYPE_BOOL;
                gen_push(&$$.code, TYPE_BOOL, NULL, yylval.valBool);
            }
            | '(' expression2_list ')' { trace(); $$ = $2; }
            ;

num_op : '<' { trace(); $$ = '<'; }
       | '=' { trace(); $$ = '='; }
       | '>' { trace(); $$ = '>'; }
       | GEQ { trace(); $$ = GEQ; }
       | LEQ { trace(); $$ = LEQ; }
       | NEQ { trace(); $$ = NEQ; }
       ;

log_op : '&' { trace(); $$ = '&'; }
       | '|' { trace(); $$ = '|'; }
       ;

expression2_list : '~' expression2 { trace();
                     $$ = (struct expr) {0};
                     enum type t = $2.type;
                     if (t != TYPE_BOOL)
                         err("Type error: Expected Bool, got %s\n", type2str(t));
                     $$.type = t;

                     $$.code = $2.code;

                     gen_op(&$$.code, '~', $2.type);
                 }
                 | num_op expression expression { trace();
                     $$ = (struct expr) {0};
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     if (!type_valid(t1) || !type_valid(t2) || !type_compat(t1, t2))
                         err("Type error: op1::%s and op2::%s\n", type2str(t1), type2str(t2));
                     $$.type = TYPE_BOOL;

                     $$.code = $2.code;
                     cbapp($$.code, $3.code);
                     gen_op(&$$.code, $1, t1);
                 }
                 | log_op expression2 expression2 { trace();
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     if (t1 != TYPE_BOOL || t2 != TYPE_BOOL)
                         err("Type error: Expected Bool but op1::%s and op2::%s\n", type2str(t1), type2str(t2));

                     $$ = $2;

                     cbapp($$.code, $3.code);
                     gen_op(&$$.code, $1, t1);
                 }
                 ;

%%

int yyerror (const char *s)
{
  return fprintf(stderr, "ERRO: '%s'\n", s);
}

%{
#include <stdbool.h>
#include <stdio.h>

#include "env.h"
#include "gen.h"
#include "str.h"
#include "rope.h"

#include "lex.yy.h"

int yyerror (const char *s);

/**
 * Verifica se uma condicao e verdadeira e, caso nao seja,
 * imprime uma mensagem de erro e aborta o programa
 */
#define assert(cond, ...)                       \
    if (!(cond)) do {                           \
        fprintf(stderr, "ERROR: " __VA_ARGS__); \
        return 1;                               \
    } while (0)

/** Se activado, mostra as producoes por onde passa */
#ifdef TRACE
#define trace(...) ((void) fprintf(stderr, "TRACE: %s:%d\n", __FILE__, __LINE__))
#else
#define trace(...) ((void) 0)
#endif /* TRACE */

#define type_valid(t)       ((t) > TYPE_ERROR && (t) < TYPE_DEFAULT)
#define type_compat(t1, t2) ((t1) == (t2))

/**
 * Concatena dois blocos de codigo, @a self e @a other, e imprime
 * uma mensagem em caso de erro
 */
#define cbapp(self, other) do {                \
        assert(rope_append(&(self), &(other)), \
            "appending code blocks: %s:%d\n",  \
            __FILE__, __LINE__);               \
        (other) = rope_free(other);            \
    } while (0)

/**
 * Gera wrappers para funcoes geradoras de codigo que imprimem
 * uma mensagem em caso de erro
 */
#define gen_(f, ...)               \
    assert((gen_##f)(__VA_ARGS__), \
        #f "(): %s:%d\n",          \
        __FILE__, __LINE__)

#define gen_jump(  c, l, n)    gen_(jump,   (c), (l), (n))
#define gen_jz(    c, l, n)    gen_(jz,     (c), (l), (n))
#define gen_nlbl(  c, l, n)    gen_(nlbl,   (c), (l), (n))
#define gen_load(  c, i)       gen_(load,   (c), (i))
#define gen_op(    c, o, t)    gen_(op,     (c), (o), (t))
#define gen_push(  c, t, a, b) gen_(push,   (c), (t), (a), (b))
#define gen_pushgp(c)          gen_(pushgp, (c))
#define gen_storeg(c, i)       gen_(storeg, (c), (i))

static struct rope _var_decs = {0};
static struct rope * const var_decs = &_var_decs;

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

%token INC
%token GEQ
%token IF
%token LEQ
%token NEQ
%token PRINT
%token READ
%token UNTIL
%token WRITE

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
             rope_fprint(var_decs, yyout);
             fputs("START\n", yyout);
             rope_fprint(&$1, yyout);
             fputs("STOP\n", yyout);
             $1 = rope_free($1);
             _var_decs = rope_free(_var_decs);
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
              assert($4.type == TYPE_DEFAULT
                  || (type_valid($4.type) && type_compat($2, $4.type)),
                  "%s:%s but default value is of type %s\n",
                  $3, type2str($2), type2str($4.type));

              struct var var = { .id = $3, .type = $2, };
              assert(env_new_var(env, var), "creating variable `%s`\n", $3);

              $$ = $4.code;
              if (!rope_is_empty(&$$))
                  gen_storeg(&$$, env_var_gp_idx(env, $3));

              gen_push(var_decs, $2,
                  (($2 == TYPE_FLOAT) ? "0.0" : "0"),
                  yylval.valBool);
          }
          | INC VAR { trace();
              $$ = (struct rope) {0};
              struct var * v = env_var(env, $2);
              enum type t = env_typeof(env, $2);
              unsigned gidx = env_var_gp_idx(env, $2);

              assert(v != NULL, "Variable not found: `%s`\n", $2);

              assert(t == TYPE_INT || t == TYPE_FLOAT,
                  "type: Expected Int or Float but got %s\n",
                  type2str(t));

              const char * arg = (t == TYPE_INT) ? "1" : "1.0";

              gen_pushgp(&$$);
              gen_load(&$$, gidx);
              gen_push(&$$, t, arg, false);
              gen_op(&$$, '+', t);
              gen_storeg(&$$, gidx);
          }
          | '=' VAR expression { trace();
              struct var * v = env_var(env, $2);
              assert(v != NULL, "Variable not found: `%s`\n", $2);
              assert(type_compat(v->type, $3.type),
                  "Types don't match: Expected %s but got %s\n",
                  type2str(v->type),
                  type2str($3.type));
              $$ = $3.code;
              gen_storeg(&$$, env_var_gp_idx(env, $2));
          }
          | WRITE writable { trace();
              $$ = $2.code;
              gen_op(&$$, WRITE, $2.type);
          }
          | PRINT writable { trace();
              $$ = $2.code;
              gen_op(&$$, WRITE, $2.type);
              gen_push(&$$, TYPE_STRING, "\"\\n\"", false);
              gen_op(&$$, WRITE, TYPE_STRING);
          }
          | READ VAR { trace();
              $$ = (struct rope) {0};
              struct var * v = env_var(env, $2);
              assert(v != NULL, "Variable not found: `%s`\n", $2);

              assert(v->type == TYPE_INT || v->type == TYPE_FLOAT,
                  "`read`: Expected Int or Float but got %s\n",
                  type2str(v->type));

              gen_read(&$$);
              gen_aton(&$$, v->type);
              gen_storeg(&$$, env_var_gp_idx(env, $2));
          }
          | IF expression2 '(' code_block ')' else_clause { trace();
              unsigned num = gen_ifno();

              $$ = $2.code;
              gen_jz(&$$, "ELSE", num);    /* jump to else label? */
              cbapp($$, $4);               /* then block */
              gen_jump(&$$, "ENDIF", num); /* jump to endif label */
              gen_nlbl(&$$, "ELSE", num);  /* else label */
              cbapp($$, $6);               /* else block (possibly empty) */
              gen_nlbl(&$$, "ENDIF", num); /* endif label */
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
                    assert(type_valid(t1) && type_valid(t2) && type_compat(t1, t2),
                        "`%c`: Types don't match: op1:%s and op2:%s\n",
                        $1, type2str(t1), type2str(t2));
                    $$.type = t1;

                    assert($$.type != TYPE_FLOAT || $1 != '%',
                        "`%%`: Expected Int, got %s\n",
                        type2str($$.type));

                    $$.code = $2.code;
                    cbapp($$.code, $3.code);
                    gen_op(&$$.code, $1, t1);
                }
                ;

expression2 : VAR { trace();
                $$ = (struct expr) {0};
                $$.type = env_typeof(env, $1);
                assert(type_valid($$.type), "Variable not found: `%s`\n", $1);

                gen_pushgp(&$$.code);
                gen_load(&$$.code, env_var_gp_idx(env, $1));
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
                     assert(t == TYPE_BOOL, "`~`: Expected Bool, got %s\n", type2str(t));
                     $$.type = t;

                     $$.code = $2.code;

                     gen_op(&$$.code, '~', $2.type);
                 }
                 | num_op expression expression { trace();
                     $$ = (struct expr) {0};
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     assert(type_valid(t1) && type_valid(t2) && type_compat(t1, t2),
                         "`%c`: Types don't match: op1:%s and op2:%s\n",
                         $1, type2str(t1), type2str(t2));
                     $$.type = TYPE_BOOL;

                     $$.code = $2.code;
                     cbapp($$.code, $3.code);
                     if ($1 == NEQ) {
                         gen_op(&$$.code, '=', t1);
                         gen_op(&$$.code, '~', TYPE_BOOL);
                     } else {
                         gen_op(&$$.code, $1, t1);
                     }
                 }
                 | log_op expression2 expression2 { trace();
                     enum type t1 = $2.type;
                     enum type t2 = $3.type;
                     assert(t1 == TYPE_BOOL && t2 == TYPE_BOOL,
                         "`%c`: Expected Bool, got op1:%s and op2:%s\n",
                         $1, type2str(t1), type2str(t2));

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

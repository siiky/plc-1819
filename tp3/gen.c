#include <stdio.h>

#include "gen.h"

#include "y.tab.h"

static const char * op2inst_bool (const int op)
{
    switch (op) {
        case   '~': return "NOT";
        case   AND: return "MUL";
        case    OR: return "ADD";
        case WRITE: return "WRITEI";
        default:  return NULL;
    }
}

static const char * op2inst_int (const int op)
{
    switch (op) {
        case    EQ: return "EQUAL";
        case   '%': return "MOD";
        case   '*': return "MUL";
        case   '+': return "ADD";
        case   '-': return "SUB";
        case   '/': return "DIV";
        case   '<': return "INF";
        case   '>': return "SUP";
        case   GEQ: return "SUPEQ";
        case   LEQ: return "INFEQ";
        case   NEQ: return "SUB";
        case WRITE: return "WRITEI";
        default:  return NULL;
    }
}

static const char * op2inst_float (const int op)
{
    switch (op) {
        case    EQ: return "EQUAL";
        case   '%': return "FMOD";
        case   '*': return "FMUL";
        case   '+': return "FADD";
        case   '-': return "FSUB";
        case   '/': return "FDIV";
        case   '<': return "FINF";
        case   '>': return "FSUP";
        case   GEQ: return "FSUPEQ";
        case   LEQ: return "FINFEQ";
        case   NEQ: return "FSUB";
        case WRITE: return "WRITEF";
        default:  return NULL;
    }
}

static const char * op2inst_string (const int op)
{
    switch (op) {
        case WRITE: return "WRITES";
        default: return NULL;
    }
}

typedef const char * (* op2inst_type) (const int op);
static const char * _type2inst (const int op, enum type type)
{
    static const op2inst_type op2inst[] = {
        [TYPE_ERROR]   = NULL,
        [TYPE_BOOL]    = op2inst_bool,
        [TYPE_FLOAT]   = op2inst_float,
        [TYPE_INT]     = op2inst_int,
        [TYPE_STRING]  = op2inst_string,
        [TYPE_DEFAULT] = NULL,
    };

    if (type >= TYPE_DEFAULT)
        type = TYPE_DEFAULT;

    return (op2inst[type] != NULL) ?
        op2inst[type](op):
        NULL;
}

bool gen_op (struct rope * code, const int op, enum type type)
{
    const char * inst = _type2inst(op, type);
    struct str str = {0};

    return (inst != NULL
            && str_cat(&str, inst)
            && rope_push(code, str))
        || (str_free(str), false);
}

bool gen_push (struct rope * code, enum type type, const char * arg, bool bv)
{
    struct str str = {0};
    bool ret = true;

    switch (type) {
        case TYPE_BOOL:
            ret = str_cat(&str, "PUSHI ")
                && str_cat(&str, ((bv) ? "1" : "0"));
            break;
        case TYPE_FLOAT:
            ret = str_cat(&str, "PUSHF ")
                && str_cat(&str, arg);
            break;
        case TYPE_INT:
            ret = str_cat(&str, "PUSHI ")
                && str_cat(&str, arg);
            break;
        case TYPE_STRING:
            ret = str_cat(&str, "PUSHS ")
                && str_cat(&str, arg);
            break;
        default:
            return false;
    }

    return (ret) ?
        rope_push(code, str):
        (str_free(str), false);
}

unsigned gen_ifno (void)
{
    static unsigned ret = 0;
    return ret++;
}

unsigned gen_untilno (void)
{
    static unsigned ret = 0;
    return ret++;
}

bool gen_jz (struct rope * code, const char * lbl, unsigned num)
{
    static char lblnum[10] = "";
    snprintf(lblnum, 10, "%u", num);
    struct str str = {0};

    return str_cat(&str, "JZ ")
        && str_cat(&str, lbl)
        && str_cat(&str, lblnum)
        && rope_push(code, str);
}

bool gen_jump (struct rope * code, const char * lbl, unsigned num)
{
    static char lblnum[10] = "";
    snprintf(lblnum, 10, "%u", num);
    struct str str = {0};

    return str_cat(&str, "JUMP ")
        && str_cat(&str, lbl)
        && str_cat(&str, lblnum)
        && rope_push(code, str);
}

bool gen_nlbl (struct rope * code, const char * lbl, unsigned num)
{
    static char lblnum[10] = "";
    snprintf(lblnum, 10, "%u", num);
    struct str str = {0};

    return str_cat(&str, lbl)
        && str_cat(&str, lblnum)
        && str_cat(&str, ":")
        && rope_push(code, str);
}

#include "y.tab.h"

#include "gen.h"

#include <stdio.h>

const char * _op2inst (const unsigned char op, int type)
{
    (void) type;
    static const char * insts[] = {
        "ERROR",
        [EQ]  = "EQUAL",
        [LEQ] = "INFEQ",
        [GEQ] = "SUPEQ",
        [NEQ] = "SUB",
        ['>'] = "SUP",
        ['<'] = "INF",
        ['~'] = "NOT",
        ['+'] = "ADD",
        ['*'] = "MUL",
        ['-'] = "SUB",
        ['/'] = "DIV",
        ['%'] = "MOD",
    };

    return insts[op];
}

bool _gen_inst (const char * inst)
{
    puts(inst);
    return true;
}

bool gen_op (unsigned char op, int type)
{
    return _gen_inst(_op2inst(op, type));
}

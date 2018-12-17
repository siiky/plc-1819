#include "y.tab.h"

#include "gen.h"

#include <stdio.h>

const char * _op2inst (const int op, int type)
{
    switch (op) {
        case EQ: return "EQUAL";
        case LEQ: return "INFEQ";
        case GEQ: return "SUPEQ";
        case NEQ: return "SUB";
        case '>': return "SUP";
        case '<': return "INF";
        case '~': return "NOT";
        case '+': return "ADD";
        case '*': return "MUL";
        case '-': return "SUB";
        case '/': return "DIV";
        case '%': return "MOD";
        default: return "ERROR";
    }
}

bool _gen_inst (const char * inst)
{
    puts(inst);
    return true;
}

bool gen_op (int op, int type)
{
    return _gen_inst(_op2inst(op, type));
}

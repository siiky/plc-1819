#include "type.h"

const char * type2str (enum type type)
{
    static const char * tbl[] = {
        [TYPE_ERROR]   = "ERROR",
        [TYPE_BOOL]    = "Bool",
        [TYPE_FLOAT]   = "Float",
        [TYPE_INT]     = "Int",
        [TYPE_STRING]  = "String",
        [TYPE_DEFAULT] = "DEFAULT",
    };

    return tbl[type];
}

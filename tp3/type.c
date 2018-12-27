#include "type.h"

const char * type2str (enum type type)
{
    static const char * tbl[] = {
        [TYPE_ERROR]   = "TYPE_ERROR",
        [TYPE_BOOL]    = "TYPE_BOOL",
        [TYPE_FLOAT]   = "TYPE_FLOAT",
        [TYPE_INT]     = "TYPE_INT",
        [TYPE_STRING]  = "TYPE_STRING",
        [TYPE_DEFAULT] = "TYPE_DEFAULT",
    };

    return tbl[type];
}

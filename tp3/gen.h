#ifndef _GEN_H
#define _GEN_H

#include <stdbool.h>

#include "str.h"
#include "rope.h"
#include "type.h"

bool gen_op   (struct rope * code, const int op, enum type type);
bool gen_push (struct rope * code, enum type type, const char * arg, bool bv);

#endif /* _GEN_H */

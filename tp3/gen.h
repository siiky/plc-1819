#ifndef _GEN_H
#define _GEN_H

#include <stdbool.h>

#include "str.h"
#include "rope.h"
#include "type.h"

bool     gen_jump    (struct rope * code, const char * lbl, unsigned num);
bool     gen_jz      (struct rope * code, const char * lbl, unsigned num);
bool     gen_nlbl    (struct rope * code, const char * lbl, unsigned num);
bool     gen_op      (struct rope * code, const int op, enum type type);
bool     gen_push    (struct rope * code, enum type type, const char * arg, bool bv);
unsigned gen_ifno    (void);
unsigned gen_untilno (void);

#endif /* _GEN_H */

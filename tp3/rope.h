#ifndef _ROPE_H
#define _ROPE_H

#define VEC_CFG_DATA_TYPE     struct str
#define VEC_CFG_DATA_TYPE_CMP str_cmp
#define VEC_CFG_DTOR          str_free
#define VEC_CFG_VEC           rope
#include "vec.h"

#include <stdio.h>

bool rope_eprint (const struct rope * self);
bool rope_fprint (const struct rope * self, FILE * out);
bool rope_print  (const struct rope * self);

#endif /* _ROPE_H */

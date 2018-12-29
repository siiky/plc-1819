#ifndef _STR_H
#define _STR_H

#define VEC_CFG_DATA_TYPE char
#define VEC_CFG_VEC       str
#include "vec.h"

#include <stdio.h>

bool str_cat    (struct str * self, const char * cstr);
bool str_eprint (const struct str * self);
bool str_fprint (const struct str * self, FILE * out);
bool str_print  (const struct str * self);
int  str_cmp    (struct str a, struct str b);

#endif /* _STR_H */

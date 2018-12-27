#ifndef _STR_H
#define _STR_H

#define VEC_CFG_DATA_TYPE char
#define VEC_CFG_VEC       str
#include "vec.h"

bool str_cat (struct str * self, const char * cstr);
int  str_cmp (struct str a, struct str b);

#endif /* _STR_H */

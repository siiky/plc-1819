#define VEC_CFG_IMPLEMENTATION
#include "str.h"

#include <string.h>

int str_cmp (struct str a, struct str b)
{
    return (a.ptr == b.ptr) ?
        0 :
        (a.length == b.length) ?
        strncmp(a.ptr, b.ptr, a.length) :
        (a.length < b.length) ?
        -1 :
        1 ;
}

bool str_cat (struct str * self, const char * cstr)
{
    if (self == NULL || cstr == NULL)
        return false;

    bool ret = true;

    for (; ret && *cstr; cstr++)
        ret = str_push(self, *cstr);

    return ret;
}

bool str_fprint (const struct str * self, FILE * out)
{
    if (self == NULL || out == NULL)
        return false;

    size_t len = self->length;
    for (size_t i = 0; i < len; i++)
        fputc(self->ptr[i], out);

    return true;
}

bool str_eprint (const struct str * self)
{
    return str_fprint(self, stderr);
}

bool str_print (const struct str * self)
{
    return str_fprint(self, stdout);
}

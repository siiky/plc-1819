#include "str.h"

#define VEC_CFG_IMPLEMENTATION
#include "rope.h"

bool rope_fprint (const struct rope * self, FILE * out)
{
    if (self == NULL || out == NULL)
        return false;

    bool ret = true;
    size_t len = self->length;
    for (size_t i = 0; ret && i < len; i++) {
        ret = str_fprint(self->ptr + i, out);
        fputc('\n', out);
    }

    return ret;
}

bool rope_eprint (const struct rope * self)
{
    return rope_fprint(self, stderr);
}

bool rope_print (const struct rope * self)
{
    return rope_fprint(self, stdout);
}

#ifndef _ENV_H
#define _ENV_H

#include <stdbool.h>

#include "type.h"

struct var {
    char * id;

    enum type type;

    union {
        bool  Bool;
        float Float;
        int   Int;
    } value;
};

#define VEC_CFG_DATA_TYPE struct var
#define VEC_CFG_VEC env
#include "vec.h"

bool         env_new_var (struct env * self, struct var var);
enum type    env_typeof  (struct env * self, char * id);
struct var * env_var     (struct env * self, char * id);

extern struct env * const env;

#define env_id2var(id) ((struct var){.id = (id)})

#endif /* _ENV_H */

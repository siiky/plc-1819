#define VEC_CFG_DATA_TYPE_CMP(L, R) (strcmp((L).id, (R).id))
#define VEC_CFG_IMPLEMENTATION
#include "env.h"

bool env_new_var (struct env * self, struct var var)
{
    /* permitir redefinir variaveis? */
#if 1
    struct var * v = env_var(self, var.id);
    return (v != NULL) ?
        ((*v = var), true):
        env_push(self, var);
#else
    return !env_elem(self, var)
        && env_push(self, var);
#endif
}

enum type env_typeof (struct env * self, char * id)
{
    struct var * v = env_var(self, id);
    return (v != NULL) ?
        v->type:
        TYPE_ERROR;
}

struct var * env_var (struct env * self, char * id)
{
    size_t idx = env_var_gp_idx(self, id);
    return (idx < env_len(self)) ?
        env_as_mut_slice(self) + idx:
        NULL;
}

size_t env_var_gp_idx (const struct env * self, char * id)
{
    return env_find(self, env_id2var(id));
}

static struct env _env = {0};
struct env * const env = &_env;

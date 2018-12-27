#define VEC_CFG_DATA_TYPE_CMP(L, R) (strcmp((L).id, (R).id))
#define VEC_CFG_IMPLEMENTATION
#include "env.h"

bool env_set_var (struct env * self, struct var var)
{
    struct var * v = env_var(self, var.id);
    return (v != NULL) ?
        ((*v = var), true):
        env_push(self, var);
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
    return (!env_is_empty(self) && idx < env_len(self)) ?
        env_as_mut_slice(self) + idx:
        NULL;
}

size_t env_var_gp_idx (const struct env * self, char * id)
{
    return env_find(self, env_id2var(id));
}

static struct env _env = {0};
struct env * const env = &_env;

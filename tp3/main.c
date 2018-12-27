#include "env.h"
#include "gen.h"
#include "str.h"
#include "rope.h"

#include "y.tab.h"

int main (void)
{
    return yyparse();
}

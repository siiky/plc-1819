%{
#include "y.tab.h"
%}

%%
"=="                       return EQ;
"!="                       return NEQ;
"<="                       return LEQ;
">="                       return GEQ;
"read"                     return READ;
"until"                    return UNTIL;
"if"                       return IF;
"write"                    return WRITE;
[:()=+*-/<>~%]             return yytext[0];
"True"|"False"             return BOOL_VALUE;
"Int"|"Float"|"Bool"       return TYPE;
[a-zA-Z][a-zA-Z]*          return VAR;
-?[0-9]+\.[0-9]+           return FLOAT_VALUE;
-?[0-9]+                   return INT_VALUE;
\"[^"]*\"                  return STR;
#.*$                       ;
.|\n                       ;
%%

int yywrap ()
{
    return 1;
}

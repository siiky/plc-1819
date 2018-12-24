%{
#include <stdbool.h>

#include "y.tab.h"
#include "type.h"
%}

%%
"=="                                                   return EQ;
"!="                                                   return NEQ;
"<="                                                   return LEQ;
">="                                                   return GEQ;
"read"                                                 return READ;
"until"                                                return UNTIL;
"if"                                                   return IF;
"write"                                                return WRITE;
[:()=+*-/<>~%]                                         return yytext[0];
"False"           { yylval.valBool   = false;          return BOOL_VALUE; }
"True"            { yylval.valBool   = true;           return BOOL_VALUE; }
"Bool"            { yylval.valType   = TYPE_BOOL;      return TYPE; }
"Float"           { yylval.valType   = TYPE_FLOAT;     return TYPE; }
"Int"             { yylval.valType   = TYPE_INT;       return TYPE; }
[a-zA-Z][a-zA-Z]* { yylval.valString = strdup(yytext); return VAR; }
-?[0-9]+\.[0-9]+                                       return FLOAT_VALUE;
-?[0-9]+                                               return INT_VALUE;
\"[^"]*\"                                              return STR;
#.*$              ;
.|\n              ;
%%

int yywrap ()
{
    return 1;
}
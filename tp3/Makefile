CFLAGS := \
    -Wall \
    -Wextra \
    -static \
    -ggdb \

all: cenas

cenas: y.tab.h y.tab.c lex.yy.h lex.yy.c
	gcc -DYYERROR_VERBOSE $(CFLAGS) y.tab.c lex.yy.c -o cenas

y.tab.h y.tab.c: cenas.y
	yacc --defines=y.tab.h cenas.y

lex.yy.h lex.yy.c: cenas.l
	flex --header-file=lex.yy.h cenas.l

clean:
	$(RM) lex.yy.c lex.yy.h y.tab.c y.tab.h cenas

.PHONY: all clean

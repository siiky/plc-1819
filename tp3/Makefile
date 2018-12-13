EXEC := cenas

SRC := \
    lex.yy.c \
    y.tab.c  \
    main.c   \
    gen.c    \

OBJS := $(SRC:.c=.o)

CFLAGS := \
    -Wall \
    -Wextra \
    -static \
    -ggdb \

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o cenas

y.tab.h y.tab.c: cenas.y
	yacc --defines=y.tab.h cenas.y

lex.yy.h lex.yy.c: cenas.l
	flex --header-file=lex.yy.h cenas.l

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) -DYYERROR_VERBOSE -c lex.yy.c -o $@

y.tab.o: y.tab.c lex.yy.h
	$(CC) $(CFLAGS) -DYYERROR_VERBOSE -c y.tab.c -o $@

gen.o: gen.c lex.yy.h
	$(CC) $(CFLAGS) -DYYERROR_VERBOSE -c gen.c -o $@

clean:
	$(RM) $(OBJS) lex.yy.c lex.yy.h y.tab.c y.tab.h cenas

.PHONY: all clean

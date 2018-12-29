CC := gcc
EXEC := cenas

SRC := \
    lex.yy.c \
    y.tab.c  \
    env.c    \
    gen.c    \
    main.c   \
    rope.c   \
    str.c    \
    type.c   \

OBJS := $(SRC:.c=.o)

CFLAGS := \
    -DYYDEBUG           \
    -DYYERROR_VERBOSE   \
    -D_XOPEN_SOURCE=500 \
    -Wall               \
    -Wextra             \
    -ggdb               \
    -static             \
    -std=c11            \

EXAMPLES := $(patsubst %.z,%.vm,$(wildcard examples/*.z))

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o cenas

y.tab.h y.tab.c: cenas.y
	yacc --defines=y.tab.h cenas.y

lex.yy.h lex.yy.c: cenas.l
	flex --header-file=lex.yy.h cenas.l

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) -c lex.yy.c -o $@

y.tab.o: y.tab.c lex.yy.h
	$(CC) $(CFLAGS) -c y.tab.c -o $@

gen.o: gen.c y.tab.h
	$(CC) $(CFLAGS) -c gen.c -o $@

main.o: main.c y.tab.h
	$(CC) $(CFLAGS) -c main.c -o $@

clean:
	$(RM) $(OBJS) $(EXAMPLES) lex.yy.c lex.yy.h y.tab.c y.tab.h cenas

examples: all $(EXAMPLES)

%.vm: %.z
	./$(EXEC) < $< > $@

.PHONY: all clean examples

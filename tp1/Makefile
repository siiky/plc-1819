CC := cc
EXEC := lpp
SRC := lpp.l

OPT := -Og -g
CFLAGS := \
    $(OPT)            \
    -D_POSIX_C_SOURCE \
    -Wall             \
    -Wconversion      \
    -Wextra           \
    -flto             \
    -pedantic         \
    -static           \
    -std=c11          \

all: $(EXEC)

$(EXEC): lex.yy.c
	$(CC) $(CFLAGS) $< -o $(EXEC)

lex.yy.c: lpp.l
	flex $<

clean:
	$(RM) $(EXEC) lex.yy.c

.PHONY: all clean

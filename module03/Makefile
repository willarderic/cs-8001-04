CC = g++

CFLAGS = -std=c++11

all: parser

lex.yy.c: terms.l
	flex terms.l

terms.tab.c: terms.y lex.yy.c
	bison -t -v terms.y

parser: lex.yy.c terms.tab.c
	$(CC) $(CFLAGS) -o parser terms.tab.c
    
clean:
	rm parser terms.tab.c lex.yy.c terms.output

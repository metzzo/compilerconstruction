# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall -std=gnu99

# the build target executable:
TARGET = gesamt

all: $(TARGET)

lex.yy.c: oxout.l
	flex oxout.l

oxout.tab.c oxout.tab.h: oxout.y
	bison -vd oxout.y

oxout.y oxout.l: language.y language.l
	ox language.y language.l

code.c: language.bfe
	bfe < language.bfe | iburg > code.c

$(TARGET): lex.yy.c oxout.tab.c oxout.tab.h code.c
	$(CC) $(CFLAGS) lex.yy.c oxout.tab.c code.c table.c tree.c code_gen.c -o $(TARGET)

clean:
	$(RM) $(TARGET) lex.yy.c oxout.tab.c oxout.tab.h oxout.h oxout.c oxout.l oxout.y oxout.output code.c 

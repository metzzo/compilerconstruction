# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall -std=c99

# the build target executable:
TARGET = scanner

all: $(TARGET)

lex.yy.c: language.lex
	flex language.lex

$(TARGET): lex.yy.c
	$(CC) $(CFLAGS) lex.yy.c -o scanner

clean:
	$(RM) scanner lex.yy.c
	


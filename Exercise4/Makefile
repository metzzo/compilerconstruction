# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall -std=c99

# the build target executable:
TARGET = parser

all: $(TARGET)

lex.yy.c: language.l
	flex language.l

language.tab.c: language.y
	bison -vd language.y

$(TARGET): lex.yy.c language.tab.c
	$(CC) $(CFLAGS) lex.yy.c language.tab.c -o $(TARGET)

clean:
	$(RM) $(TARGET) lex.yy.c language.tab.c language.tab.h language.output
	

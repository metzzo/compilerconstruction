# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall -std=c99

# the build target executable:
TARGET = asma

all: $(TARGET)

$(TARGET): *.s
	$(CC) $(CFLAGS) -c *.s

clean:
	$(RM) asmb asmb.o


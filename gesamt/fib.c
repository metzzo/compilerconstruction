#include <stdlib.h>
#include <stdio.h>

extern long fib(long n);

int main()
{
    printf("13th Fibonacci number = %li\n", fib(13));
    return 0;
}

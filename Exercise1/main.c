#include <stdio.h>
#include <stdlib.h>

extern void asma(unsigned long x0, unsigned long x1, unsigned long y, unsigned long *a);

int main(void) {
    unsigned long *a = malloc(sizeof(unsigned long)*3);
    unsigned long x0 = 10;
    unsigned long x1 = 20;
    unsigned long y = 5;

    asma(x0, x1, y, a);
    for (int i = 0; i < 3; i++) {
        printf("%08lu", a[i]);
    }
    printf("\n");
    free(a);

    return 0;
}




        .file   "sample.c"
        .text
.globl asma
        .type   asma, @function
asma:
.LFB0:
        .cfi_startproc
        rep

        mov %rdx, %r8

        // Calculate r0
        
        // move rdi into rax
        movq %rdi, %rax
        // multiply rax by r8
        mulq %r8
        // save high bits to r9
        movq %rdx, %r9
        // move low bits into 0 bytes after rcx => save r0
        movq %rax, 0(%rcx)

        // Calculate r1

        // move rsi into rax
        movq %rsi, %rax
        // multiply rax by r8
        mulq %r8
        // save high bits to r10
        movq %rdx, %r10
        // save result in stack
        addq %rax, %r9

        // move rax into 8 bytes after rcx => save r1
        movq %r9, 8(%rcx)
        
        // Calculate r2
        adc $0, %r10
        movq %r10, 16(%rcx)

        ret
        .cfi_endproc
.LFE0:
        .size   asma, .-asma
        .ident  "GCC: (Debian 4.4.5-8) 4.4.5"
        .section        .note.GNU-stack,"",@progbits
        

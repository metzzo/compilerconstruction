        .file   "sample.c"
        .text
.globl asmb
        .type   asmb, @function
asmb:
.LFB0:
        .cfi_startproc
        rep
        mov %rdx, %r8
        mov %rcx, %r9
        mov %rsi, %rcx

        // Calculate r0
        jrcxz size_0
        jmp size_not_0
size_0:
        movq $0, 0(%r9)
        ret
size_not_0:
        
        // move 0th position of rdi into rax
        movq 0(%rdi), %rax
        // multiply rax by r8
        mulq %r8
        // save high bits to r10
        movq %rdx, %r10
        // move low bits into 0 bytes after r9 => save r0
        movq %rax, 0(%r9)
        // execute the following n-1 times
        dec %rcx
        // Calculate rn
continue:
        // move to next position
        
        add $8, %r9
        add $8, %rdi

        // move current postion of x into rax
        movq 0(%rdi), %rax
        // multiply rax by r8 (y)
        mulq %r8
        // save high bits to r10
        movq %rdx, %r11
        // add previous result to rax
        addq %r10, %rax
        // save to a
        movq %rax, 0(%r9)
        movq %r11, %r10
        adc $0, %r10

        loop continue

        // Calculate rn+1
        movq %r10, 8(%r9)

        ret
        .cfi_endproc
.LFE0:
        .size   asmb, .-asmb
        .ident  "GCC: (Debian 4.4.5-8) 4.4.5"
        .section        .note.GNU-stack,"",@progbits



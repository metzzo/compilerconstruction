.globl h
.type h, @function
h:
mov $4, %rax
imul %rdi, %rax
jmp .L1
.L1:
ret # end function h
.globl f
.type f, @function
f:
push %rbp
mov %rsp, %rbp
sub $8, %rsp
movq %rdi, -8(%rbp)
lea 6(%rdi), %rax
push %rax
lea 4(%rdi), %rax
push %rax
pop %rdi
call h
movq -8(%rbp), %rdi
push %rax
lea 2(%rdi), %rax
push %rax
pop %rdi
pop %rsi
pop %rdx
call g
movq -8(%rbp), %rdi
jmp .L2
.L2:
leave
ret # end function f

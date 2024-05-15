
section .text

    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rax, 60

    syscall
    

global _start

section .bss 
    input resb 32

section .text
_start:

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 32
    syscall

    xor rdx, rdx
loop:
    mov al, byte [input + rdx]
    cmp al, 10
    je foundNewline
    inc rdx
    jmp loop

foundNewline:
    dec rdx 
    movzx eax, byte [input + rdx]  
    sub al, '0'         

    test al, 1
    jnz _error

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

_error:
    mov rax, 60
    mov rdi, 1
    syscall


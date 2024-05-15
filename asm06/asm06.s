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


    mov rdi, 0
    xor r8, r8
    xor rax, rax
convert:
    mov al, [input + rdi]
    cmp al, 10
    je done

    cmp al, '0'
    jl _error

    cmp al, '9'
    jg _error

    sub al, 48
    imul r8, 10
    add r8, rax

    inc rdi
    jmp convert

done:
    xor rdi, rdi
    xor rax, rax
    mov rcx, 2

    cmp r8, 1
    je _notprime

    cmp r8, 2
    je _prime

loop:
    xor rdx, rdx
    mov rax, r8
    div rcx
    cmp rdx, 0
    je found
    inc rcx
    jmp loop

found:
    cmp rcx, r8
    je _prime
    jne _notprime
    

_prime: 
    mov rax, 60
    mov rdi, 0
    syscall

_notprime:
    mov rax, 60
    mov rdi, 1
    syscall

_error:
    mov rax, 60
    mov rdi, 20
    syscall

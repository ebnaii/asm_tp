msg: db "1337", 01
.len: equ $ - msg

; SIMPLE CODE THAT PRINTS 1337

section .text

    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg.len 
    syscall

    mov rax, 60
    mov rdi, 0
    syscall



    section .data


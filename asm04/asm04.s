global _start

section .bss 
    input resb 32

section .data
    help: db "Check if user input is even or odd, return 0 if even, 1 if odd", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm04", 10
    .lenUsage: equ $ - usage

section .text
_start:

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 32
    syscall       ; we ask user input

    xor rdx, rdx
loop:
    mov al, byte [input + rdx] ; we count each char from start to newline char
    cmp al, 10
    je foundNewline            ; when we found newline we jump to check parity
    inc rdx
    jmp loop

foundNewline:
    dec rdx                       ; we get back to before the newline char
    movzx eax, byte [input + rdx] ; we mov the last byte of the input
    sub al, '0'                   ; we sub 0 to get if its 0 or 1 
                                  ; last byte means the parity of the number

    test al, 1                    ; we check if its 1
    jnz _odd                      ; if test returns not zero, its odd
    jz _even                      ; if it return 0 its even

_odd:
    mov rdi, 1
    jmp _exit

_even:
    mov rdi, 0
_exit:
    mov rax, 60
    syscall

_error:

    mov rax, 1    ; print help message if there is an error
    mov rdi, 1
    mov rsi, help
    mov rdx, help.lenHelp
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, usage
    mov rdx, usage.lenUsage
    syscall


    mov rax, 60
    mov rdi, 1
    syscall


global _start

section .bss
    input resb 2

section .data
    msg: db "1337", 01
    .len: equ $ - msg
    help: db "Take number as parameter, return 1337 if parameter is 42", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm03 NUMBER", 10
    .lenUsage: equ $ - usage


section .text
_start:
    
    mov r13, [rsp]
    cmp r13, 0x2
    jne _error      ; we check if there is the attended parameter number

    mov rsi, rsp        
    add rsi, 16        
    mov rsi, [rsi]    
    mov rdi, input   
    mov rcx, 4      
    rep movsb       ; we grab the first parameter 

    mov al, [input] ; we check if the first char is 4
    cmp al, '4'
    jne _not42

    mov al, [input + 1] ; we check if the second is 2
    cmp al, '2'     
    jne _not42

    mov al, [input + 2] ; we check if the last is the end of string char
    cmp al, 0
    jne _not42

_exit:
    mov rax, 1    ; if the parameter is 42, we end here, printing 1337 and exiting 0
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg.len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

_not42:           ; if its not 42 we end here and exit 1 with no print
    mov rax, 60
    mov rdi, 1 
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

global _start

section .bss
    input resb 32

section .data
    help: db "Check if a number given in stdin is prime or not", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm08", 10
    .lenUsage: equ $ - usage


section .text
_start:

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 32
    syscall         ; we call stdin to get user input

    mov rdi, 0
    xor r8, r8
    xor rax, rax
convert:            ; we convert the input that is a string to decimal
    mov al, [input + rdi]
    cmp al, 10
    je done

    cmp al, '0'     ; we check if its a number or not, which means between char 0 (48) and char 9 (57)
    jl _error

    cmp al, '9'
    jg _error

    sub al, 48 ; we sub the value for char 0 (48) to get its decimal form
    imul r8, 10 ; imul to write number from left to right
    add r8, rax

    inc rdi
    jmp convert

done:             ; we prepare to enter the loop by setting our register 
    xor rax, rax  ; rax set to 0 for the div later
    mov rcx, 2    ; rcx is our divisor, we start at 2 to not count 1 in

    cmp r8, 1     ; we check 1 and 2 separetly cause they wont work otherwise
    je _notprime

    cmp r8, 2
    je _prime

loop:             ; we div the number by every number from 2 to himself
    xor rdx, rdx    
    mov rax, r8   ; we reset rax everytime with the value cause it changes after every div
    div rcx
    cmp rdx, 0    ; if rdx = 0, it means the rest is 0 so our number is divisable by the current value in rcx
    je found      ; if we found a value that divide we jump out of the loop
    inc rcx       ; otherwise we increment rcx and go back at the start of the loop
    jmp loop

found:
    cmp rcx, r8   ; if rcx = r8, then it means we divided the number by himself
    je _prime     ; so the number is prime
    jne _notprime ; otherwise its not
    

_prime: 
    mov rax, 60
    mov rdi, 0    ; we return 0 if its prime
    syscall

_notprime:
    mov rax, 60
    mov rdi, 1    ; we return 1 if its not prime
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
    mov rdi, 20
    syscall

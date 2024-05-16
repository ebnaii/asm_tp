global _start 

section .bss
    nb resb 32


section .text
_start:

    mov r13, [rsp]
    cmp r13, 0x2
    jne _error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, nb
    mov rcx, 4
    rep movsb

    xor rdi, rdi
    mov r8, 0

convert:
    mov al, [nb + rdi]
    cmp al, 0
    je done

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r8, 10
    add r8, rax
    
    inc rdi
    jmp convert

done:
    mov r9, 0
    mov rax, 0
    dec r8
loop:
    add rax, r9
    
    cmp r9, r8
    je _end

    inc r9
    jmp loop


_end:
    call std__to_string
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

_error:
    mov rax, 60
    mov rdi, 1
    syscall

std__to_string:
    ; ----------------------------------------------------------------------
    ;    TAKES
    ;        ||------> 1. RAX => Number
    ;                  2. RSI => Output string
    ;
    ;    GIVES
    ;        ||------> 1. RSI = Number as a string
    ;                  2. RDX = Length of the string (number of digits)
    ;
    ; ----------------------------------------------------------------------

    push rsi              ; Keep the output string pointer on the stack for later
    push rax              ; Keep the value of RAX on the stack because the next loop will change its value

    mov rdi, 1            ; For keeping the number of digits in the original number
    mov rcx, 1            ; For keeping the divisor
    mov rbx, 10           ; For dividing the number by ten in each iteration 
    .get_divisor:
        xor rdx, rdx
        div rbx           ; Reduce the RAX by one digit
        
        cmp rax, 0        ; Compare RAX with zero
        je ._after         ; Break the loop if equal
        imul rcx, 10      ; Otherwise increase the divisor (RCX) ten times
        inc rdi           ; Increment number of digits as well (RDI)
        jmp .get_divisor   ; Unconditional jump to the first instruction of the 'loop'


    ._after:
        pop rax           ; Get back the value of RAX from the stack
        push rdi          ; Put the number of digits on the stack for later

    .to_string:
        xor rdx, rdx
        div rcx           ; Divide the number (RAX) by the divisor to get the first digit from the left

        add al, '0'       ; Add the base (48) to the digit because we want to store an ASCII string
        mov [rsi], al     ; Move the value into the string
        inc rsi           ; Increment the pointer to the next byte

        push rdx          ; Push the remaining part of the number onto the stack
        xor rdx, rdx      
        mov rax, rcx     
        mov rbx, 10       
        div rbx           ; Reduce the divisor (RCX) ten times
        mov rcx, rax      ; Put the new divisor back into (RCX)

        pop rax           ; Pop the top the stack into (RAX). It's the remaining part of the number
        
        cmp rcx, 0        ; See if the divisor has become zero
        jg .to_string      ; If not, repeat the same process

    pop rdx               ; Pop the top of the stack into (RDX). It's the value of (RDI): the number of digits in the original number
    pop rsi               ; Bring (RSI) to the beginning of the string before returning as well
    ret

    

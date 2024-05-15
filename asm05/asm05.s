global _start

section .bss
    nb1 resb 32
    nb2 resb 32
    signNb1 resb 1 
    signNb2 resb 1
    finalSign resb 1


section .text
_start:
    
    mov r13, [rsp]
    cmp r13, 3
    jne _error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, nb1
    mov rcx, 4
    rep movsb

    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    mov rdi, nb2
    mov rcx, 4
    rep movsb

    mov byte [signNb1], 0
    mov byte [signNb2], 0
    mov byte [finalSign], 0


    xor rdi, rdi
    mov r8, 0

sign1:
    mov al, [nb1 + rdi]
    cmp al, '-'
    je ._negativ
    jne convert1
    ._negativ:    
        mov byte [signNb1], 1
        inc rdi
        jmp convert1
    
convert1: 
    mov al, [nb1 + rdi]
    cmp al, 0
    je done1

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r8, 10
    add r8, rax

    inc rdi
    jmp convert1

done1:
    xor rdi, rdi
    mov r9, 0

sign2:
    mov al, [nb2]
    cmp al, '-'
    je ._negativ
    jne convert2
    ._negativ:    
        inc rdi
        mov byte [signNb2], 1
        jmp convert2
 

convert2:
    mov al, [nb2 + rdi]
    cmp rax, 0
    je done2

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r9, 10
    add r9, rax

    inc rdi
    jmp convert2

done2:

    mov al, [signNb1]
    mov bl, [signNb2]
    cmp al, bl
    je ._sameSign
    jne ._diffSign

    ._sameSign:
        cmp al, 0
        jne ._neg
        add r9, r8
        jmp _end ; both positiv we can already exit 
        ._neg:
            mov byte [finalSign], 1
            add r9, r8 ; both negativ we can exit with finalSign swapped to 1
            jmp _end
    ._diffSign:
        cmp r8, r9
        ja ._nb1Greater
        jb ._nb2Greater
        mov r9, 0 ; if nb 1 = nb 2, result is 0 dont even need to add
        jmp _end
        ._nb1Greater:
            sub r8, r9
            mov r9, r8
            mov al, [signNb1]
            mov [finalSign], al
            jmp _end
        ._nb2Greater:
            sub r9, r8
            mov al, [signNb2]
            mov [finalSign], al
            jmp _end



_end:
    mov rax, r9
    mov rcx, [finalSign]
    call std__to_string

_exit:
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

_test: 
    mov rax, 60
    mov rdi, 20
    syscall

std__to_string:
    ; ----------------------------------------------------------------------
    ;    TAKES
    ;        ||------> 1. RAX => Number
    ;                  2. RSI => Output string
    ;                  3. RCX => finalSign (0 or 1)
    ;
    ;    GIVES
    ;        ||------> 1. RSI = Number as a string
    ;                  2. RDX = Length of the string (number of digits)
    ;
    ; ----------------------------------------------------------------------

    push rsi              ; Keep the output string pointer on the stack for later
    push rax              ; Keep the value of RAX on the stack because the next loop will change its value

    cmp rcx, 1            ; Check if finalSign is 1
    jne .no_sign          ; If not, jump to .no_sign

    mov byte [rsi], '-'   ; Add '-' at the beginning of the string
    inc rsi               ; Increment the string pointer
    mov rdi, 2            ; Set the initial number of digits to 2 to account for the negative sign

    jmp .continue         ; Jump to the main loop

.no_sign:
    mov rdi, 1            ; Set the initial number of digits to 1 (no negative sign)

.continue:
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


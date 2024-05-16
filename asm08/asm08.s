global _start 

section .data
    help: db "Convert a number to hex (-h) or binary (-b)", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm08 -[h|b] NUMBER", 10
    .lenUsage: equ $ - usage


section .bss
    nb resb 32
    string resb 32
    conversion resb 1


section .text
_start:

    mov r13, [rsp] ; is there the attended arguments ?
    cmp r13, 0x3
    jne _error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, conversion
    mov rcx, 4
    rep movsb ; keeping the arg1

    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    mov rdi, nb
    mov rcx, 4
    rep movsb ; keeping the number sent

    xor rdi, rdi
    mov r8, 0

hexOrBinary:
    mov al, [conversion]
    cmp al, '-'
    jne _error

    mov al, [conversion + 1] ; is the first argument -b ?
    cmp al, 'b'
    je ._isBinary
    
    cmp al, 'h' ; its not -b so
    je ._isHex ; is the first argument -h ?
    jne _error ; its none of them -> exit
    ._isBinary:
        mov byte [conversion], 1  ; is binary
        xor rdi, rdi              ; conversion = 1 for binary
        jmp convert   
    ._isHex:
        mov byte [conversion], 0  ; conversion = 0 for hex
        xor rdi, rdi
        jmp convert

convert:
    mov al, [nb + rdi] ; cause the number is in "string mode" we swap it to "decimal mode"
    cmp al, 0
    je doneConvert

    cmp rax, '0' ; we check if its a number or not, which means between char 0 (48) and char 9 (57)
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48 ; we sub the value for char 0 (48) to get its decimal form
    imul r8, 10 ; imul to write number from left to right 
    add r8, rax
    
    inc rdi
    jmp convert

doneConvert:

    mov al, [conversion] ; since conversion to decimal is done, we need to convert it in 
    cmp al, 0            ; hex or binary, the choice change changes the value of rcx to 
    je ._convertHex      ; divide the number by rcx
    jne ._convertBin
    ._convertHex:
        mov rcx, 16      ; if its hex we need to divide by 16
        jmp ._choosen
    ._convertBin:
        mov rcx, 2       ; if its binary we need to divide by 2
        jmp ._choosen
    ._choosen:
        mov rax, r8      ; we move the decimal value to rax, need for the div instruction

loop:
    xor rdx, rdx         ; we xor rdx cause we dont need it and div takes [rdx:rax] as input
    
    div rcx

    push rdx             ; we push the value to get it back later in the right order
    
    inc r10
    cmp rax, 0           ; unless rax (quotient) is 0 we continue
    je done

    jmp loop

done:
    mov r13, r10
    inc r13 ; keep length + 1 for string + 0
    xor rdi, rdi
    mov rdi, string
    
addToString:
    
    pop r11
    cmp r11, 10     ; we need to differentiate between letters and numbers for hex
    jb ._dec
    jae ._ascii

    ._dec:             ; if its between 0 and 9, we can write a number by adding the value for '0'
        add r11, '0'
        jmp ._store
    ._ascii:
        add r11, 87    ; if its above or equal 10, its a letter, so we need to add (a-10) which is 87
        jmp ._store
    ._store:
      mov [rdi], r11    ; we store the new value which are now ascii decimal to a string
      inc rdi
      dec r10
      cmp r10, 0
      je _end
      jmp addToString
  


_end:
    mov byte [rdi], 0 ; we add end of string char
    
    mov rsi, string ; we print the string which contains the conversion
    mov rdi, 1
    mov rax, 1
    mov rdx, r13    ; we kept the length earlier for here
    syscall

    mov rax, 60
    mov rdi, 0
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



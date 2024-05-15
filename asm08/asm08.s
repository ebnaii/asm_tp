global _start 

section .bss
    nb resb 32
    string resb 32


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
    je doneConvert

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r8, 10
    add r8, rax
    
    inc rdi
    jmp convert

doneConvert:
    mov rax, r8
    mov rcx, 16
    

loop:
    xor rdx, rdx
    
    div rcx

    push rdx
    
    inc r10
    cmp rax, 0
    je done

    jmp loop

done:
    xor rdi, rdi
    mov rdi, string
    
addToString:
    
    pop r11
    cmp r11, 10 
    jb ._dec
    jae ._ascii

    ._dec:
        add r11, '0'
        jmp ._store
    ._ascii:
        add r11, 87
        jmp ._store
    ._store:
      mov [rdi], r11
      inc rdi
      dec r10
      cmp r10, 0
      je _end
      jmp addToString
  


_end:
    mov byte [rdi], 10
    mov rax, r8
    
    mov rsi, string
    mov rdi, 8
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



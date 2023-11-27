.model flat, c

.code

mas_func proc
    push ebp
    mov ebp, esp
    
    array equ [ebp + 8]
    result equ [ebp + 12]
    
    mov esi, array
    mov edi, result
    mov ebx, 0
    mov ecx, 0
    
    finit
    
    cycle:
    cmp ecx, 10
    jge exit
    
    fld dword ptr [esi + ebx]  
    fsin
    fstp dword ptr [edi, + ebx]
    
    add ebx, 4
    inc ecx
    jmp cycle

    exit:
    pop ebp
    ret
mas_func endp

end
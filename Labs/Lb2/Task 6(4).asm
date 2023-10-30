
data segment
    str_input db "Input string: ", "$"
    str_output db "Output string : ", "$"
    buf db 200 dup ("$")     
    str db 0Ah, 0Dh, "$"
    a_len dw 0
    b_len dw 0
    a_spos dw 0
    a_epos dw 0
    b_spos dw 0
    b_epos dw 0
    i_spos dw 0
    i_epos dw 0
    j_spos dw 0
    j_epos dw 0
    i dw 0
    j dw 0
    amid dw 0
    sub_len dw 0
    cur_pos dw 0
    cur_word dw 0
    words_num dw 0
    a_buf db 1, "$"    
data ends

stack segment
    dw   100h  dup(0)
stack ends
 
print_str macro buf
    mov dx, offset str
    mov ah, 09h
    int 21h
    mov ah, 09h
    mov dx, offset buf + 2
    int 21h
endm 
 
code segment  
start:
    mov ax, @data
    mov ds, ax    
    
    lea dx, str_input
    mov ah, 09h
    int 21h
     
    mov dx, offset buf
    mov ah, 0Ah
    int 21h
       
    mov dx, offset str
    mov ah, 09h
    int 21h          
    
    xor al, al
    mov si, 0
    mov cur_pos, 2
    mov words_num, 0
    
words_counting:
    mov si, cur_pos
    mov al, buf[si]
    cmp al, 13
    je end_count
    cmp al, '$'
    je end_count
    inc cur_pos
    cmp al, 'A'
    jl words_counting
    cmp al, 'z'
    ja words_counting
    cmp al, 'Z'
    jle A_Z_b
    cmp al, 'a'
    jae a_z_l
A_Z_b:
    mov si, cur_pos
    mov al, buf[si]
    cmp al, 13
    je A_Z_b_cont
    cmp al, ' '
    jne words_counting
    A_Z_b_cont:
    inc words_num
    jmp words_counting
a_z_l:
    mov si, cur_pos
    mov al, buf[si]
    cmp al, 13
    je a_z_l_cont
    cmp al, ' '
    jne words_counting
    a_z_l_cont:
    inc words_num
    jmp words_counting
end_count:

    xor si, si
    mov cur_word, 0
    mov cur_pos, 2
    mov a_len, 0
    mov b_len, 0
    mov i, 0
    mov j, 0
    jmp find_word1
start_sorting_i:    
    inc i
    mov cur_word, 1
    mov si, a_epos
    inc si
    mov cur_pos, si
    mov i_spos, 0
    mov j_epos, 2
    mov a_len, 0
    mov a_spos, 0
    mov a_epos, 0
    mov b_spos, 0
    mov b_epos, 0
    mov b_len, 0    
find_word1:
    mov si, i
    mov di, words_num
    cmp si, di
    je ending
    mov si, cur_pos
    mov al, buf[si]
    cmp al, 13
    je start_sorting_i
    cmp al, '$'
    je start_sorting_i
    cmp al, ' '
    jne word1_len
    inc cur_pos
    jmp find_word1
    
    start_sorting_j:
    mov b_len, 0
    mov si, j_epos
    mov cur_pos, si
    find_word2:
        mov si, cur_word
        mov di, words_num
        cmp si, di
        ja start_sorting_i
        mov si, cur_pos
        mov al, buf[si]
        cmp al, 13
        je start_sorting_i
        cmp al, '$'
        je start_sorting_i
        cmp al, ' '
        jne word2_len
        inc cur_pos
        ;inc j_epos
        jmp find_word2
        
word1_len:
    inc cur_word
    inc j
    mov bx, cur_pos
    mov i_spos, bx
    mov a_spos, bx
    mov si, i_spos
    mov al, buf[si]
    while_len1: 
    cmp al, ' '
    je end_while_len1
    cmp al, '$'
    je end_while_len1
    cmp al, 13
    je end_while_len1
    mov a_epos, si
    mov i_epos, si
    inc cur_pos
    inc si
    inc a_len
    mov al, buf[si]
    jmp while_len1    
    end_while_len1:
    jmp find_word2
    
word2_len:
    inc cur_word
    inc j
    mov bx, cur_pos
    mov j_spos, bx
    mov j_epos, bx
    mov b_spos, bx
    mov si, j_spos
    mov al, buf[si]
    while_len2: 
    cmp al, ' '
    je end_while_len2
    cmp al, '$'
    je end_while_len2
    cmp al, 13
    je end_while_len2
    mov b_epos, si
    mov j_epos, si
    inc cur_pos
    inc si
    inc b_len
    mov al, buf[si]
    jmp while_len2    
    end_while_len2:
    
comparing:
    mov si, a_len
    mov di, b_len
    cmp si, di
    je a_b_equal
    cmp si, di
    ja a_longer
    jmp b_longer
a_b_equal:
    mov cx, a_len
    mov si, a_spos
    mov di, b_spos
    compare_a_b_equal:
    mov al, buf[si]
    mov bl, buf[di]
    cmp al, bl
    jb a_longer_sort_end
    cmp al, bl
    ja a_longer_sort
    inc si
    inc di
    loop compare_a_b_equal
    jmp a_longer_sort    
a_longer:
    mov cx, b_len
    mov si, a_spos
    mov di, b_spos
    compare_b_a:
    mov al, buf[si]
    mov bl, buf[di]
    cmp al, bl
    jb a_longer_sort_end
    cmp al, bl
    ja a_longer_sort
    inc si
    inc di
    loop compare_b_a
    ja a_longer_sort
b_longer:
    mov cx, a_len
    mov si, a_spos
    mov di, b_spos
    compare_a_b:
    mov al, buf[si]
    mov bl, buf[di]
    cmp al, bl
    jb b_longer_sort_end
    cmp al, bl
    ja b_longer_sort
    inc si
    inc di
    loop compare_a_b    
    jmp b_longer_sort_end
a_longer_sort:
    mov cx, a_len
    mov si, a_spos
    a_sort_a_stack:
    mov bx, offset buf
    mov al, buf[si]
    push ax
    inc si
    loop a_sort_a_stack
    mov cx, b_len
    mov si, b_spos
    a_sort_b_stack:
    mov bx, offset buf
    mov al, buf[si]
    push ax
    inc si
    loop a_sort_b_stack 
    mov si, a_epos
    mov di, b_spos
    sub di, si
    dec di
    mov amid, di    
    cmp di, 0
    je a_longer_sort_ab_len_swap
    mov cx, di
    mov di, b_spos
    dec di
    a_longer_sort_amid_stack_push:
    mov bx, offset buf
    mov al, [bx+di]
    push ax
    dec di
    loop a_longer_sort_amid_stack_push
    
    a_longer_sort_ab_len_swap:
    mov si, a_len
    mov di, b_len
    sub si, di
    mov sub_len, si
    mov di, b_spos
    sub di, si
    mov b_spos, di
    mov di, si
    mov si, a_epos
    sub si, di
    mov a_epos, si
    mov di, amid
    cmp di, 0
    je a_longer_sort_amid_shift_end
    mov cx, di
    mov si, a_epos
    inc si
    a_longer_sort_amid_shift:
    pop ax
    mov buf[si], al
    inc si
    loop a_longer_sort_amid_shift
    a_longer_sort_amid_shift_end:
    mov si, sub_len
    mov di, b_len
    add di, si
    mov b_len, di
    mov di, a_len
    sub di, si
    mov a_len, di
    mov cx, a_len
    mov si, a_epos
    a_longer_sort_new_a:
    pop ax
    mov buf[si], al
    dec si
    loop a_longer_sort_new_a
    mov cx, b_len
    mov si, b_epos
    a_longer_sort_new_b:
    pop ax
    mov buf[si], al
    dec si
    loop a_longer_sort_new_b
    a_longer_sort_end:
    mov si, b_epos
    inc si
    mov j_epos, si
    jmp start_sorting_j

b_longer_sort:
    mov cx, a_len
    mov si, a_spos
    b_sort_a_stack:
    mov bx, offset buf
    mov al, buf[si]
    push ax
    inc si
    loop b_sort_a_stack
    mov cx, b_len
    mov si, b_spos
    b_sort_b_stack:
    mov bx, offset buf
    mov al, buf[si]
    push ax
    inc si
    loop b_sort_b_stack
    mov si, a_epos
    mov di, b_spos
    sub di, si
    dec di
    mov amid, di    
    cmp di, 0
    je b_longer_sort_ab_len_swap
    mov cx, di
    mov di, b_spos
    dec di
    b_longer_sort_amid_stack_push:
    mov bx, offset buf
    mov al, [bx+di]
    push ax
    dec di
    loop b_longer_sort_amid_stack_push
    
    b_longer_sort_ab_len_swap:
    mov si, b_len
    mov di, a_len
    sub si, di
    mov sub_len, si
    mov di, b_spos
    add di, si
    mov b_spos, di
    mov di, si
    mov si, a_epos
    add si, di
    mov a_epos, si
    mov di, amid
    cmp di, 0
    je b_longer_sort_amid_shift_end
    mov cx, di
    mov si, a_epos
    inc si
    b_longer_sort_amid_shift:
    pop ax
    mov buf[si], al
    inc si
    loop b_longer_sort_amid_shift
    b_longer_sort_amid_shift_end:
    mov si, sub_len
    mov di, a_len
    add di, si
    mov a_len, di
    mov di, b_len
    sub di, si
    mov b_len, di
    mov cx, a_len
    mov si, a_epos
    b_longer_sort_new_a:
    pop ax
    mov buf[si], al
    dec si
    loop b_longer_sort_new_a
    mov cx, b_len
    mov si, b_epos
    b_longer_sort_new_b:
    pop ax
    mov buf[si], al
    dec si
    loop b_longer_sort_new_b
    b_longer_sort_end:
    mov si, b_epos
    inc si
    mov j_epos, si
    jmp start_sorting_j
    
ending:
    lea dx, str_output
    mov ah, 09h
    int 21h
    print_str (buf)
    mov ax, 4C00h
    int 21h    
code ends

end start  

    
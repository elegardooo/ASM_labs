
data segment
    str_input db "Input string: ", "$"
    buf db 200 dup ("$")     
    str db 0Ah, 0Dh, "$"
    a_len dw 0
    b_len dw 0
    a_pos dw 0
    b_pos dw 0
    i_pos dw 0
    j_pos dw 0
    cur_pos dw 0
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
    
 
    ;xor al, al
    ;mov si, 2
    ;mov al, buf[si]
    ;mov a_buf, al
    ;mov dx, offset a_buf
    ;mov ah, 09h
    ;int 21h
    xor al, al
    mov si, 0
    mov cur_pos, 2
next_word:
    mov si, cur_pos
    mov al, buf[si]
    cmp al, '$'
    je ending
    cmp al, ' '
    jne word1_len
    inc cur_pos
    ;print_str (buf)
    mov a_len, 0
    mov b_len, 0
    jmp next_word
word1_len:
    mov bx, cur_pos
    mov i_pos, bx
    mov si, i_pos
    mov al, buf[si]
    while: cmp al, ' '
    je end_while
    cmp al, '$'
    je end_while  
    inc i_pos
    inc si
    inc a_len
    mov al, buf[si]
    jmp while
    
    end_while:
    
    
    ending:    
    ;print_str (buf)  
    ;int 21h
    mov ah, 09h 
    mov bx, a_len
    mov al, buf[bx]
    mov a_buf, al
    mov dx, offset a_buf
    int 21h
    
    mov ax, 4C00h
    int 21h    
code ends

end start  

    
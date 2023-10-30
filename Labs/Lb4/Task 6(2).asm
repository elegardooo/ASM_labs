.8086

.model SMALL

.data
    pkey db "press any key...$"
    blocks_remain_count dw 56
    ;blocks_destroyed dw 0
    score_remain dw "Blocks remains: $"
    blocks_remain dw "56$"
    ;score_destroyed dw "Blocks destroyed: $" 
    score_message dw 0F53h, 0F63h, 0F6Fh, 0F72h, 0F65h, 0F3Ah, 0F20h, 0F30h, 32 dup(0F20h)
    score_line_position dw 4
    map_wigth dw 4
    ball_position dw 1928
    lost_position dw 2200
.stack  100h  

.code         

draw_field proc
    push bp    
    mov ah, 07
    mov al, 23
    mov bh, 070h
    mov ch, 01
    mov cl, 01
    mov dh, 23
    mov dl, 58
    int 10h
    
    mov ah, 07
    mov al, 21
    mov bh, 00h
    mov ch, 02
    mov cl, 02
    mov dh, 22
    mov dl, 57
    int 10h    
    pop bp
    ret
draw_field endp

draw_blocks proc
    push bp
    
    mov ah, 07
    mov al, 1
    mov ch, 4
    mov cl, 2
    mov dh, 4
    mov dl, 5
    
    mov di, 7
    mov si, 2
    
    blocks_drawing_loop1:
    mov bh, 040h
    int 10h
    
    mov bh, 030h
    add cl, 4
    add dl, 4
    int 10h        
    
    add cl, 4
    add dl, 4
    
    dec di
    cmp di, 0
    ja blocks_drawing_loop1
    
    mov cl, 2
    mov dl, 5
    mov di, 7
    add ch, 2
    add dh, 2
    
    dec si
    cmp si, 0
    ja blocks_drawing_loop1
    
    mov ch, 5
    mov cl, 2
    mov dh, 5
    mov dl, 5
    
    mov di, 7
    mov si, 2
    
    blocks_drawing_loop2:
    mov bh, 030h
    int 10h
    
    mov bh, 040h
    add cl, 4
    add dl, 4
    int 10h
    
    add cl, 4
    add dl, 4
    
    dec di
    cmp di, 0
    ja blocks_drawing_loop2
    
    mov cl, 2
    mov dl, 5
    mov di, 7
    add ch, 2
    add dh, 2
    
    dec si
    cmp si, 0
    ja blocks_drawing_loop2
    
    pop bp
    ret
draw_blocks endp

draw_platform proc
    push bp

    mov ah, 07
    mov al, 1
    mov bh, 010h
    mov ch, 20
    mov cl, 24
    mov dh, 20
    mov dl, 34
    int 10h
    pop bp
    ret    
draw_platform endp

draw_ball proc
    push bp
       
    mov ah, 07
    mov al, 1
    mov bh, 0F0h
    mov ch, 19
    mov cl, 28
    mov dh, 19
    mov dl, 28   
    int 10h
       
    pop bp
    ret
draw_ball endp

draw_score proc
    push bp
    
    mov ah, 02
    mov bh, 0
    mov dh, 4
    mov dl, 70
    int 10h
    
    mov ah, 13h
    mov al, 0
    mov cx, 10
    mov dl, 044h
    mov dh, 4
    mov dl, 70
    lea bp, score_remain
    int 10h
    
    pop bp
    ret
draw_score endp

draw_score_line proc
    push cx

    mov si, offset score_message
    mov di, score_line_position

    mov cx, map_wigth
    draw_score_line_loop:
        movsw
    loop draw_score_line_loop

    pop cx
    ret
draw_score_line endp

PRINT PROC
     push bp 
     mov bp, sp
            
     mov si, [bp + 4]
     xor bx, bx
     mov dh, [bp + 6]
     mov dl, [bp + 8]
     page equ [bp + 10]
     
     mov ah, 02h
     int 10h

print_loop:
     xor cx, cx
     mov cx, 1
     mov bh, page
     mov bl, 15
     mov ah, 09h
     mov al, [si]
     cmp al, '$'
     je end_print
     inc si
     int 10h
   
     inc dl
     mov ah, 02h
     int 10h

    jmp print_loop
        
end_print:
    xor si ,si
        xor cx, cx
        pop bp
        ret 8
PRINT ENDP

print_block_score PROC
    
    mov ax, 0
    push ax
    mov dx, 60
    push dx
    mov si, 2
    push si
    mov cx, offset score_remain
    push cx
    call PRINT
    ret
print_block_score ENDP        

TO_NUM PROC
      push bp
      mov bp, sp 
      
      xor si, si
      mov si, [bp + 4]
      
      xor ax, ax
      xor bx, bx
      xor dx, dx
      xor cx, cx
      mov cl, [si]

convert_loop:
      xor cx, cx
      mov cl, [si]
      cmp cl, 13
      je done 
      xor bx, bx
      mov bx, 10
      imul bx
      sub cl, '0'
      add ax, cx
      inc si
      jmp convert_loop

done:
      pop bp
      ret 2
TO_NUM ENDP

print_score PROC
    
    mov ax, 0
    push ax
    mov dx, 76
    push dx
    mov si, 2
    push si
    mov cx, offset blocks_remain
    push cx
    call PRINT
    ret
print_score ENDP
    
start:
    mov ax, @data
    mov ds, ax

    xor bx, bx
    xor dx, dx
    xor ax, ax

    mov ah, 00
    mov al, 03
    int 10h

    mov ah, 07
    mov al, 0
    int 10h

    mov ah, 05
    mov al, 0
    int 10h

    call draw_field
    ;call draw_blocks    
    call draw_platform
    call draw_ball
    call print_block_score
    call print_score     
    
    game_cycle:
    mov cx, 0
    mov ah, 86h
    mov dx, 65535
    int 15h
    int 15h
    int 15h
    
    mov dx, lost_position
    cmp ball_position, dx
    jae game_over
    
    jmp game_cycle
    
    game_over:
    mov ax, 4C00h
    int 21h

end start

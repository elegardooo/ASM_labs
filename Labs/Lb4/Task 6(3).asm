.8086

.model SMALL

.data
    pkey db "press any key...$"
    blocks_remain_count dw 56
    ;blocks_destroyed dw 0
    score_remain dw "Blocks remains: $"
    victory_text dw "Victory !$"
    blocks_remain dw "56$"
    ;score_destroyed dw "Blocks destroyed: $" 
    score_message dw 0F53h, 0F63h, 0F6Fh, 0F72h, 0F65h, 0F3Ah, 0F20h, 0F30h, 32 dup(0F20h)
    score_line_position dw 4
    map_wigth dw 4
    ball_position dw 1928
    lost_position dw 2200     
    platform_direction db ?
    platform_left_pos db 24
    platform_pos db 24
    platform_right_pos db 34
    platform_y db 20 
    ball_direction_x db 'a'
    ball_direction_y db 'w'  
    ball_x db 28
    ball_y db 19
    destroy_pos db 0
    destroy_pos_left db 0
    destroy_pos_right db 0
    destroy_atr db ?
    direction_changed db 0
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
    mov ch, platform_y
    mov cl, platform_pos
    mov dh, platform_y
    mov dl, platform_pos
    add dl, 10
    int 10h
    pop bp
    ret    
draw_platform endp

draw_ball proc
    push bp
       
    mov ah, 07
    mov al, 1
    mov bh, 0F0h
    mov ch, ball_y
    mov cl, ball_x
    mov dh, ball_y
    mov dl, ball_x   
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

print_victory PROC
    
    mov ax, 0
    push ax
    mov dx, 30
    push dx
    mov si, 10
    push si
    mov cx, offset victory_text
    push cx
    call PRINT
    ret
print_victory ENDP 

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

conv_to_string PROC
     push bp
     xor si, si
     mov bp, sp

     xor cx, cx

     mov ax, [bp + 4]  
     xor bx, bx
     mov bx, 10

     cmp ax, 0
     jge conv_to_string_loop

conv_to_string_loop:
    xor dx, dx
    div bx 

    push dx 
    inc cx

continue:
     cmp ax, 0
     jnz conv_to_string_loop

conv_to_string_print: 
     xor dx, dx     
     pop dx 
     add dl, '0'
     mov blocks_remain[si], dx
     add si, 1
     ;mov ah, 02h
     ;int 21h
     
loop conv_to_string_print
     mov blocks_remain[si], '$'
     pop bp
     ret 2
conv_to_string ENDP

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

clear proc
   push bp

    mov ah, 07
    mov al, 1
    mov bh, 000h
    mov ch, platform_y
    mov cl, platform_pos
    ;sub cl, 5
    mov dh, platform_y
    mov dl, platform_pos
    add dl, 10
    int 10h
    pop bp
    ret          
            
clear endp   

clear_ball proc
    push bp
       
    mov ah, 07
    mov al, 1
    mov bh, 000h
    mov ch, ball_y
    mov cl, ball_x
    mov dh, ball_y
    mov dl, ball_x   
    int 10h
       
    pop bp
    ret
clear_ball endp

get_atr proc
    push bp
    
    mov ah, 02h
    mov bh, 0
    mov dh, ball_y
    mov dl, ball_x
    int 10h
    
    mov ah, 08h
    mov bh, 0
    int 10h
    
    pop bp
    ret
get_atr endp    

get_block_atr macro param1
    mov ah, 02h
    mov bh, 0
    mov dh, ball_y
    mov dl, param1
    int 10h
    
    mov ah, 08h
    mov bh, 0
    int 10h
endm

destroy_block proc
    push bp
    
    mov bh, destroy_pos
    mov destroy_pos_left, bh
    mov destroy_pos_right, bh
    call get_atr
    mov destroy_atr, ah
    left_block_check:
    sub destroy_pos_left, 1
    get_block_atr destroy_pos_left
    cmp ah, destroy_atr
    jne right_block_check    
    jmp left_block_check
    
        
    right_block_check:
    ;add destroy_pos_left, 1
    
    add destroy_pos_right, 1
    get_block_atr destroy_pos_right
    cmp ah, destroy_atr
    jne destroy_block_check_ending    
    jmp right_block_check
     
     
    destroy_block_check_ending:
    ;sub destroy_pos_right, 1
    
    xor cx, cx
    xor dx, dx
    
    mov ah, 07
    mov al, 1
    mov bh, 00h
    mov ch, ball_y
    mov cl, destroy_pos_left
    add cl, 1
    mov dh, ball_y
    mov dl, destroy_pos_right
    sub dl, 1
    int 10h
    
    mov destroy_pos_left, 0
    mov destroy_pos_right, 0
    mov destroy_atr, 0
    
    sub blocks_remain_count, 1
    mov ax, blocks_remain_count
    push ax
    call conv_to_string
    mov ah, 07
    mov al, 1
    mov bh, 00h
    mov ch, 2
    mov cl, 76
    mov dh, 2
    mov dl, 77
    int 10h
    call print_score
    
    pop bp
    ret
destroy_block endp
    
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
    call draw_blocks   
    call draw_platform   
    call draw_ball
    call print_block_score
    call print_score     
    
    game_cycle:
    mov cx, 0
    mov ah, 86h
    mov dx, 65535
    int 15h
    
    ;mov dx, lost_position
    ;cmp ball_y, 22
    ;jae game_over
    
    mov dx, blocks_remain_count
    cmp dx, 0
    je victory  
    
    mov ah, 6h
    mov dl, 0ffh
    int 21h
    
    cmp al, 'a'
    je left_direction
    cmp al, 'd'
    je right_direction 
 
ball_move:
    cmp ball_direction_x, 'a'
    je ball_left_direction
    cmp ball_direction_X, 'd'
    je ball_right_direction
    
    
    
    jmp game_cycle
    
left_direction:      
    cmp platform_pos, 2
    je game_cycle 
    call clear
    sub platform_pos, 1 
    call draw_platform                 
jmp ball_move
                
                
right_direction:
    cmp platform_pos, 47
    je game_cycle  
    call clear
    add platform_pos, 1 
    call draw_platform     
jmp ball_move

ball_left_direction:
    mov ball_direction_x, 'a' 
    
    cmp ball_direction_y, 'w'
    je ball_left_w
    
    cmp ball_direction_y, 's'
    je ball_left_s
        
    ;cmp ball_x, 2
    ;je  game_cycle    
    
    ball_left_w:
    
    left_w_pos_x_check:
    mov direction_changed, 0
    sub ball_x, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne blw_c1
    mov ball_direction_x, 'd'
    mov direction_changed, 1 
    blw_c1:
    cmp ah, 040h
    jne blw_c2
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    blw_c2:
    cmp ah, 030h
    jne blw_c3
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    blw_c3:
    cmp ah, 010h
    jne blw_c7
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    blw_c7:
    add ball_x, 1
    
    sub ball_y, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne blw_c4
    mov ball_direction_y, 's'
    mov direction_changed, 1 
    blw_c4:
    cmp ah, 040h
    jne blw_c5
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 's'
    mov direction_changed, 1
    blw_c5:
    cmp ah, 030h
    jne blw_c6
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 's'
    mov direction_changed, 1
    blw_c6:
    cmp ah, 010h
    jne blw_c8:
    mov ball_direction_y, 's'
    mov direction_changed, 1
    blw_c8:
    add ball_y, 1
    jmp ball_left_w_dir_end
    
    
    
    
    
    ball_left_s:
    
    left_s_pos_x_check:
    mov direction_changed, 0
    sub ball_x, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne bls_c1
    mov ball_direction_x, 'd'
    mov direction_changed, 1 
    bls_c1:
    cmp ah, 040h
    jne bls_c2
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    bls_c2:
    cmp ah, 030h
    jne bls_c3
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    bls_c3:
    cmp ah, 010h
    jne bls_c7
    mov ball_direction_x, 'd'
    mov direction_changed, 1
    bls_c7:
    add ball_x, 1
    
    add ball_y, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne bls_c4
    mov ball_direction_y, 'w'
    mov direction_changed, 1 
    bls_c4:
    cmp ah, 040h
    jne bls_c5
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    bls_c5:
    cmp ah, 030h
    jne bls_c6
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    bls_c6:
    cmp ah, 010h
    jne bls_c8
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    bls_c8:
    sub ball_y, 1
    jmp ball_left_s_dir_end
    
    
    
     
     
    ball_left_w_dir_end:
    cmp direction_changed, 1
    je dir_changed1
    call clear_ball
    sub ball_x, 1
    sub ball_y, 1
    call draw_ball
    jmp game_cycle
    
    
    
    
    ball_left_s_dir_end:
    cmp direction_changed, 1
    je dir_changed1
    call clear_ball
    sub ball_x, 1
    add ball_y, 1
    call draw_ball
    jmp game_cycle
    
    dir_changed1:
jmp game_cycle

ball_right_direction:
    ;mov ball_direction_x, 'd' 
   
    ;cmp ball_x, 57
    ;je  game_cycle
    
    ;call clear_ball
    ;add ball_x, 1
    ;sub ball_y, 1
    ;call draw_ball
    
    mov ball_direction_x, 'd' 
    
    cmp ball_direction_y, 'w'
    je ball_right_w
    
    cmp ball_direction_y, 's'
    je ball_right_s
        
    ;cmp ball_x, 2
    ;je  game_cycle    
    
    ball_right_w:
    
    right_w_pos_x_check:
    mov direction_changed, 0
    add ball_x, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne brw_c1
    mov ball_direction_x, 'a'
    mov direction_changed, 1 
    brw_c1:
    cmp ah, 040h
    jne brw_c2
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brw_c2:
    cmp ah, 030h
    jne brw_c3
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brw_c3:
    cmp ah, 010h
    jne brw_c7
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brw_c7:
    sub ball_x, 1
    
    sub ball_y, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne brw_c4
    mov ball_direction_y, 's'
    mov direction_changed, 1 
    brw_c4:
    cmp ah, 040h
    jne brw_c5
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 's'
    mov direction_changed, 1
    brw_c5:
    cmp ah, 030h
    jne brw_c6
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 's'
    mov direction_changed, 1
    brw_c6:
    cmp ah, 010h
    jne brw_c8:
    mov ball_direction_y, 's'
    mov direction_changed, 1
    brw_c8:
    add ball_y, 1
    jmp ball_right_w_dir_end
    
    
    
    
    
    ball_right_s:
    
    right_s_pos_x_check:
    mov direction_changed, 0
    add ball_x, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne brs_c1
    mov ball_direction_x, 'a'
    mov direction_changed, 1 
    brs_c1:
    cmp ah, 040h
    jne brs_c2
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brs_c2:
    cmp ah, 030h
    jne brs_c3
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brs_c3:
    cmp ah, 010h
    jne brs_c7
    mov ball_direction_x, 'a'
    mov direction_changed, 1
    brs_c7:
    sub ball_x, 1
    
    add ball_y, 1
    ;070 wall 040 030
    call get_atr
    cmp ah, 070h
    jne brs_c4
    mov ball_direction_y, 'w'
    mov direction_changed, 1 
    brs_c4:
    cmp ah, 040h
    jne brs_c5
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    brs_c5:
    cmp ah, 030h
    jne brs_c6
    mov bh, ball_x
    mov destroy_pos, bh
    call destroy_block
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    brs_c6:
    cmp ah, 010h
    jne brs_c8
    mov ball_direction_y, 'w'
    mov direction_changed, 1
    brs_c8:
    sub ball_y, 1
    jmp ball_right_s_dir_end
    
    
    
     
     
    ball_right_w_dir_end:
    cmp direction_changed, 1
    je dir_changed2
    call clear_ball
    add ball_x, 1
    sub ball_y, 1
    call draw_ball
    jmp game_cycle
    
    
    
    
    ball_right_s_dir_end:
    cmp direction_changed, 1
    je dir_changed2
    call clear_ball
    add ball_x, 1
    add ball_y, 1
    call draw_ball
    jmp game_cycle
    
    dir_changed2:
jmp game_cycle
                   
    victory:              
    call print_victory
 

    
    game_over:
    mov ax, 4C00h
    int 21h

end start
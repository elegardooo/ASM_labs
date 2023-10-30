.model SMALL

.data
    pkey db "press any key...$"


.stack  100h  

.code
    
start_position dw 0      

saves proc
    
    mov ah, 02
    mov bh, 0
    mov dh, 1
    mov dl, 1
    int 10h
    
    mov ah, 09
    mov bh, 0
    mov al, 0
    mov bl, 80h
    mov cx, 60
    int 10h
saves endp

draw_field proc
    push bp    
    mov ah, 07
    mov al, 23
    mov bh, 070h
    mov ch, 01
    mov cl, 01
    mov dh, 23
    mov dl, 65
    int 10h
    
    mov ah, 07
    mov al, 21
    mov bh, 00h
    mov ch, 02
    mov cl, 02
    mov dh, 22
    mov dl, 64
    int 10h    
    pop bp
    ret
draw_field endp

draw_platform proc
    push bp
    mov ah, 07
    mov al, 1
    mov bh, 010h
    mov ch, 20
    mov cl, 27
    mov dh, 21
    mov dl, 37
    int 10h
    pop bp
    ret    
draw_platform endp

draw_blocks proc
    
    mov ah, 07
    int 10h
    
    ret
draw_blocks endp
    
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
    call draw_platform
    ;call draw_blocks
    
    mov ah, 00
    int 16h

    mov ax, 4c00h
    int 21h

end start

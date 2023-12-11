.286
.model tiny
    
.code 
org 100h 

START:                            
    call INSTALL_NEW_HANDLER
    call OPEN_FILE
 
    for0:
        call READ_FROM_FILE
        call OUTPUT_BUFFER
    jmp for0
    
EXIT:     
    call INSTALL_OLD_HANDLER
    call CLOSE_FILE    
    int 20h         
    
READ_FROM_FILE proc
    mov ah, 3fh
    mov bx, FILE_DESKRIPTOR
    xor cx, cx
    mov cl, BUFFER_SIZE       
    lea dx, BUFFER
    int 21h               
    cmp al, 0 
    je EXIT
    mov BYTES_WAS_READ, al
    ret
READ_FROM_FILE endp

OUTPUT_BUFFER proc
    xor cx, cx
    mov cl, BYTES_WAS_READ
    lea di, BUFFER        
    
    LOOP1:
        mov dl, [di]
        mov ah, 02h
        int 21h
        inc di
        
        push cx

        mov cx, 0FFFh
        LOOP2:        
           cmp CLOSE, 1
           je EXIT
           cmp STOP, 1
           je LOOP2
        loop LOOP2  

        pop cx            
    loop LOOP1

    ret  
OUTPUT_BUFFER endp   
                                                                                                                                      
OPEN_FILE proc 
    mov ah, 3dh
    mov al, 0
    lea dx, FILE_NAME
    int 21h
    mov FILE_DESKRIPTOR, ax
    jc ERROR
    ret
ERROR:
    jmp EXIT
OPEN_FILE endp

CLOSE_FILE proc
    mov ah, 3Eh
    mov bx, FILE_DESKRIPTOR
    int 21h
    ret
CLOSE_FILE endp

NEW_INT9 proc far
    push es
    in al, 60h         
    
    cmp al, 0AEh
    je EOI
    
    cmp al, 9DH
    je EOI
    
    cmp al, 1
    je SET_EXIT_FLAG    
    
    cmp al, 2Eh
    jne RESET
    
CTRL_IS_PRESSED:
    cmp PREW_SCAN_CODE, 1Dh
    jne RESET
    int 1bh         
    jmp EOI                 

SET_EXIT_FLAG:
    mov CLOSE, 1
    jmp EOI
    
RESET:
    mov STOP, 0  
    
EOI:
    mov PREW_SCAN_CODE, al
    mov al, 20h
    out 20h, al
    pop es
    iret
NEW_INT9 endp  

NEW_INT1B proc
    mov STOP, 1
    iret
NEW_INT1b endp


INSTALL_NEW_HANDLER proc 
    mov ax, 3509h
    int 21h
    mov word ptr [OLD_INT9 + 2], es
    mov word ptr OLD_INT9, bx
    
    mov ax, 351Bh
    int 21h
    mov word ptr [OLD_INT1B + 2], es
    mov word ptr OLD_INT1B, bx
    
    mov ax, 2509h
    lea dx, NEW_INT9
    int 21h    
    
    mov ax, 251Bh
    lea dx, NEW_INT1B
    int 21h      
    ret
INSTALL_NEW_HANDLER endp

INSTALL_OLD_HANDLER proc
    mov dx, word ptr OLD_INT9
    mov ds, word ptr [OLD_INT9 + 2]
    mov ax, 2509h
    int 21h
    
    mov dx, word ptr OLD_INT1B
    mov ds, word ptr [OLD_INT1B + 2]
    mov ax, 251Bh
    int 21h
    
    ret
INSTALL_OLD_HANDLER endp

OLD_INT9 dd ?
OLD_INT1B dd ?

STOP db 0
CLOSE db 0        
PREW_SCAN_CODE db 0

FILE_DESKRIPTOR dw 0
FILE_NAME db "file.txt",0        

BUFFER db 100 dup('$')                    
BUFFER_SIZE db 100
BYTES_WAS_READ db 0

end start
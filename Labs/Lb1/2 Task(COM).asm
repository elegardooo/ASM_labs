        .model tiny       
        .code
        org 100h
start:  mov ah, 09h
        mov dx, offset str1
        int 21h
        ret
 str1 db "String", 0Ah, 0Dh, '$'            
        end start       





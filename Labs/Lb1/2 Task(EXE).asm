        .model small
        .stack 100h       
        .code
start:  mov ax, @data
        mov ds, ax
        mov dx, offset str1       
        mov ah, 09h
        int 21h
        mov ax, 4C00H
        int 21h
        .data
 str1 db "String", 0Ah, 0Dh, '$'            
        end start       





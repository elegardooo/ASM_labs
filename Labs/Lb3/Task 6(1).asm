data segment
    array_input db "Input Array: ", 0Dh, 0Ah, "$"
    array_output db 0Dh, 0Ah, "Output Array: ", 0Dh, 0Ah, "$"        
    n dw 0
    negative_sign db '+'
    MAX_16BIT_NUM dw 32767
    input_buf dw 200 dup ('$')
    array dw 200 dup ('$')
    array_size equ 5        
data ends

stack segment
    dw 100h dup(0)    
stack ends

TO_NUM PROC
      push bp
      mov bp, sp
      xor si, si
      mov si, [bp + 4]
      mov negative_sign, '+'
      xor ax, ax
      xor bx, bx
      xor dx, dx
      xor cx, cx
      mov cl, [si]
      cmp cl, '-'
      je l1

convert_loop:
      xor cx, cx
      mov cl, [si]
      cmp cl, 13
      je done 
      xor bx, bx
      mov bx, 10
      imul bx
      jo over7
      sub cl, '0'
      add ax, cx
      jo over7
      inc si
      jmp convert_loop

done:
      cmp negative_sign, '-'
      je l2
      pop bp
      ret 2
      l1:
      inc si
      mov negative_sign, '-'
      jmp convert_loop
      l2:
      neg ax
      pop bp
      ret
      over7:
      push ax
      call HANDLE_OVERFLOW
      cmp negative_sign, '-'
      je l2
      pop bp
      ret
ENDP

HANDLE_OVERFLOW PROC
    push bp
    mov bp, sp

    mov ax, [bp + 4]

    mov ax, MAX_16BIT_NUM 

    mov sp, bp
    pop bp
    ret 2
HANDLE_OVERFLOW ENDP

conv_to_string PROC
     push bp
     mov bp, sp

     xor cx, cx

     mov negative_sign, '+'
     mov ax, [bp + 4]  
     xor bx, bx
     mov bx, 10

     cmp ax, 0
     jge conv_to_string_loop

     neg ax
     mov negative_sign, '-'

conv_to_string_loop:
    xor dx, dx
    div bx 

    push dx 
    inc cx

continue:
     cmp ax, 0
     jnz conv_to_string_loop

conv_to_string_print:
     cmp negative_sign, '-'
     je add_neg
continue2: 
     xor dx, dx     
     pop dx 
     add dl, '0'
     mov ah, 02h
     int 21h
loop conv_to_string_print

     mov negative_sign, '+'
     pop bp
     ret 2
conv_to_string ENDP

add_neg:
mov dl, negative_sign
mov ah, 02h
int 21h
mov negative_sign, 0
jmp continue2

code segment
start:
    mov ax, @data
    mov ds, ax
    xor ax, ax
    mov cx, array_size
    xor si, si
    
    lea dx, array_input
    mov ah, 09h
    int 21h
    
    input_array:
    mov dx, offset input_buf
    mov ah, 0Ah
    int 21h
    mov ax, offset input_buf + 2
    push ax
    call TO_NUM
    ;sub al, 30h
    mov array[si], ax
    inc si
    
    cmp si, array_size
    jl input_array
    
    xor si, si
    mov cx, array_size
    
    lea dx, array_output
    mov ah, 09h
    int 21h
    lea bx, array
    
    output_array:
    mov ah, 02h
    mov dx, [bx]
    ;add dl, 30h
    int 21h
    inc bx
    loop output_array
    
    end:
    mov ax, 4C00h
    int 21h
code ends

end start
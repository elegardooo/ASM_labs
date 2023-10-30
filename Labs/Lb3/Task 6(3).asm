.model SMALL

.data
    array_input db 0Dh, 0Ah, "Input Array: ", "$"
    length_input db "Input length of array(Default size for invalid input - 30): ", "$"
    array_output db 0Dh, 0Ah, "Output Array: ", "$" 
    enter_element db  0Dh, 0Ah, "Enter element: ", "$"
    output_element db 0Dh, 0Ah, "Element: ", "$"       
    output_average db 0Dh, 0Ah, "Average value of array elements: ", "$"
    negative_sign db '+'
    MAX_16BIT_NUM dw 32767
    input_buf db 50 dup ("$")
    array dw 200 dup ('$')
    array_size dw 5
    real_array_size dw 5
    def_array_size equ 30
    def_array dw 0
    average dw 0
    rest dw 0

.stack 100h

.code   
    
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
      mov def_array, 1
      pop bp
      ret 2
      over7:
      push ax
      mov def_array, 1
      call HANDLE_OVERFLOW
      cmp negative_sign, '-'
      je l2
      pop bp
      ret 2
TO_NUM ENDP

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

      
GET MACRO buff
    mov dx, offset buff
    mov ah, 0ah
    int 21h
    
    ;mov si, dx
    ;mov si, 1
    ;mov al, "$"
    
    ;mov [si], al
ENDM

OUTPUT MACRO buff
    mov dx, offset buff
    mov ah, 09h
    int 21h
ENDM

input_array PROC
    push bp
    xor di, di
    OUTPUT array_input     
    mov ax, 2
    imul array_size
    mov array_size, ax
    input_elements:
    lea dx, enter_element
    mov ah, 09h
    int 21h
    
    GET input_buf         
    mov ax, offset input_buf + 2
    push ax
    call TO_NUM
    mov array[di], ax
    add di, 2
    
    cmp di, array_size
    jl input_elements
    pop bp
    ret    
input_array ENDP

output_array PROC
    push bp
    xor di, di
    OUTPUT array_output    
    mov si, array_size
    output_elements:
    xor bx, bx    
    mov bx, array[di]
    mov ax, bx
    push ax
    OUTPUT output_element    
    call conv_to_string
    add di, 2
    cmp di, array_size
    jl output_elements
    pop bp
    ret
output_array ENDP    
    
input_array_size PROC
    push bp
    OUTPUT length_input
    GET input_buf
    mov ax, offset input_buf + 2
    push ax
    call TO_NUM
    cmp def_array, 1
    jne not_def_size
    mov dx, def_array_size
    mov array_size, dx
    jmp len_continue
    
    not_def_size:
    mov array_size, ax
    len_continue:
    pop bp
    ret
input_array_size ENDP            

calculate_average PROC
    push bp   
    mov ax, array_size
    mov di, 2
    idiv di
    mov cx, ax
    xor di, di
    average_calculating:
    mov ax, array[di]
    add average, ax
    add di, 2    
    loop average_calculating
    
    mov ax, array_size
    mov cx, 2
    idiv cx
    mov cx, ax
    mov real_array_size, cx
    mov ax, average
    idiv cx
    mov average, ax
    mov rest, dx
    
    OUTPUT output_average
    mov ax, average
    push ax
    call conv_to_string
    mov dx, "."
    mov ah, 02h
    int 21h
    
    mov ax, 100
    imul rest
    mov rest, ax
    mov cx, real_array_size
    mov ax, rest
    idiv cx
    mov rest, ax
    
    mov ax, rest
    push ax
    call conv_to_string
    
    pop bp
    ret        
calculate_average ENDP    

start:
    mov ax, @data
    mov ds, ax    
    
    call input_array_size        
    call input_array    
    call calculate_average 
    call output_array   
    
    
    mov ax, 4C00h
    int 21h

end start

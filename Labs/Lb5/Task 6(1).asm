.8086
.model small

.data

  f_name                        db  "file.txt"   
  file_handle                   dw  ?
  buffer                        db  100 dup('$')
  buffer_length                 dw  $ - buffer
  count_of_non_empty_strings    db  0

 
.code
      
open_file proc

    push bp
    mov bp, sp
        
    file_name       equ [bp + 4]

    mov ax, 3D00h
    mov dx, file_name
    int 21h
        
    pop bp
    ret 2
   
open_file endp 

read_from_file_to_buffer proc

    push bp
    mov bp, sp

    mov ah, 3Fh
    mov bx, [bp + 8]                      ;handle
    mov cx, [bp + 6]                      ;buffer length
    mov dx, [bp + 4]                      ;buffer
    int 21h

    pop bp 
    ret 6

read_from_file_to_buffer endp

print_data proc

    push bp
    mov bp, sp

    mov ah, 40h
    mov bx, 01h                           ;stdout handle
    mov cx, [bp + 6]                      ;count to print
    mov dx, [bp + 4]                      ;buffer whith data
    int 21h
    
    pop bp 
    ret 6

print_data endp

is_letter proc

    push bp 
    mov bp, sp

    cmp al, 'A'
    jl not_letter
    cmp al, 'Z'
    jbe its_letter

    cmp al, 'a'
    jl not_letter
    cmp al, 'z'
    jbe its_letter

    not_letter: 
        mov al, 0
        pop bp
        ret 0

    its_letter:
        mov al, 1
        pop bp
        ret 0
    
  is_letter endp

start:
  mov ax, @data
  mov ds, ax
  push offset f_name
  call open_file                          ;if error - exit
  jc exit 
  mov file_handle, ax

  read_data:

    push file_handle
    push buffer_length
    push offset buffer
    call read_from_file_to_buffer         ;if error - exit
    jc close_file 
    mov cx, ax                            ;cx - count of bytes read
    jcxz close_file                       ;if cx = 0 - close file

    mov si, 0
    is_true:

    mov al, [buffer + si]
    cmp al, '$'
    je  countinue
    call is_letter
    cmp al, 1 
    je go_to_next_line
    inc si
    jne is_true

    countinue:

  jmp short read_data 

go_to_next_line:
    inc count_of_non_empty_strings
    qq:
    inc si
    mov al, [buffer + si]
    cmp al, '$'
    je countinue
    cmp al, 0Ah
    je is_true
    jmp qq

  close_file:
    mov ah,3Eh
    int 21h

  exit:
    mov ah, 2h
    mov dh, 0h
    mov dl, count_of_non_empty_strings
    add dx, '0'
    int 21h
    mov ax, 4C00h
    int 21h

end start




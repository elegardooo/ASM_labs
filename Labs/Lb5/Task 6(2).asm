.8086
.model small

.data
  
  ;f_name                        db  "file.txt" 
  f_name                        db  100 dup (0)  
  file_handle                   dw  ?
  buffer                        db  100 dup('$')
  buffer_length                 dw  $ - buffer
  symbol_buffer                db 100 dup('$')
  count_of_chosen_symbols_strings    db  0
  input_symbols db "Input symbols: ", "$",  0Dh, 0Ah
  count_of_strings db "Count of strings: ", "$"
  symbol_i db 0 
 
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

check_symbol proc

    push bp 
    mov bp, sp

    cmp al, dl
    je true
    jne false
    
    false:
    mov dl, 0
    pop bp
    ret 0
    
    true:
    inc di
    mov dl, [symbol_buffer + di]
    cmp dl, '$'
    je true_got
    cmp dl, 13
    je true_got
    
    true_end:
    pop bp
    ret 0 
    
    true_got:
    mov dl, 1
    pop bp
    ret 0
    
check_symbol endp

start:
  mov ax, @data
        mov ds, ax
        
        xor bx, bx
        mov bl, es:[80h] ;CLA length
        add bx, 80h      ;last symbol
        mov si, 82h      ;first symbol
        lea di, f_name

        parse_path:
            cmp BYTE PTR es:[si], ' '
            je parsed_path
            cmp BYTE PTR es:[si], 0Dh
            je parsed_path

            mov al, es:[si]
            mov [di], al

            inc di
            inc si
            cmp si, bx
            jbe parse_path

        parsed_path:
              lea dx, f_name
              
        inc si      
        xor di, di
        xor dx, dx
        lea di, symbol_buffer
            
        parse_symbols:
            cmp BYTE PTR es:[si], ' '
            je parsed_symbols
            cmp BYTE PTR es:[si], 0Dh
            je parsed_symbols
            
            mov al, es:[si]
            mov [di], al

            inc di
            inc si
            cmp si, bx
            jbe parse_symbols

        parsed_symbols:
            lea dx, symbol_buffer
        
  
  ;mov ah, 0Ah
  ;mov dx, offset symbol_buffer
  ;int 21h
  
  
  push offset f_name
  call open_file                          ;if error - exit
  jc exit 
  mov file_handle, ax
     
  ;mov ah, 0Ah
  ;mov dx, offset symbol_buffer
  ;int 21h
  
  read_data:

    push file_handle
    push buffer_length
    push offset buffer
    call read_from_file_to_buffer         ;if error - exit
    jc close_file 
    mov cx, ax                            ;cx - count of bytes read
    jcxz close_file                       ;if cx = 0 - close file

    mov di, 0
    mov si, 0
    jmp is_true
        
    is_true_new:
    mov di, 0
    inc si
    jmp new_string_cont_back
    
    is_true:
    mov al, [buffer + si]
    cmp al, '$'
    je  countinue
    
    cmp al, 0Ah
    je is_true_new
    
    new_string_cont_back:
    mov al, [buffer + si]
    mov dl, [symbol_buffer + di]
    ;cmp dl, '$'
    ;je go_to_next_line_symb
    ;cmp dl, 13
    ;je go_to_next_line_symb
    
    call check_symbol
    cmp dl, 1
    je go_to_next_line_symb
    inc si
    jne is_true

    countinue:

  jmp short read_data 

go_to_next_line_symb:
    inc count_of_chosen_symbols_strings
    ;mov di, 2
go_to_next_line:
    qq:
    inc si
    mov al, [buffer + si]
    cmp al, '$'
    je countinue
    cmp al, 0Ah
    je is_true_new
    jmp qq

  close_file:
    mov ah,3Eh
    int 21h

  exit:
    mov ah, 09h
    mov dx, offset count_of_strings
    int 21h
    mov ah, 2h
    mov dh, 0h
    mov dl, count_of_chosen_symbols_strings
    add dx, '0'
    int 21h
    mov ax, 4C00h
    int 21h

exit_pr:
    ret

end start




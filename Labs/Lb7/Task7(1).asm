.186
.model small

.data
  
  ;f_name                        db  "file.txt"
  command_line db 125 
  f_buffer                        db  100 dup (0)
  f_name_buffer                   db 100 dup (0)
  
  
  EBP_block dw 0
    dw offset command_line, 0
    dw 005ch, 0
    dw 006ch, 0

    
  file_handle                   dw  ?       
  buffer                        db  100 dup('$')
  buffer_length                 dw  $ - buffer
  symbol_buffer                db 100 dup('$')
  count_of_chosen_symbols_strings    db  0
  input_symbols db "Input symbols: ", "$",  0Dh, 0Ah
  count_of_strings db "Count of strings: ", "$"
  symbol_i db 0 
  
  data_segment_size = $ - EBP_block
.code
      
open_file proc

    push bp
    mov bp, sp
    
    ;mov ah, 09h
    ;mov dx, [bp + 4]
    ;int 21h
    
    mov ax, 4B00h
    lea dx, f_name_buffer
    lea bx, EBP_block
    int 21h
    ;jc exit_half
       
    pop bp
    ret

open_file endp 

start:
    mov ah, 4Ah
    mov bx, (code_segment_size/16 + 1) + (data_segment_size/16 + 1) + 256/16 + 256/16
    int 21h
    ;jc exit_half                

    mov ax, @data
        mov ds, ax
        
        xor bx, bx
        mov bl, es:[80h] ;CLA length
        add bx, 80h      ;last symbol
        mov si, 82h      ;first symbol
        lea di, f_buffer

        parse_path:
            cmp BYTE PTR es:[si], 0Dh
            je parsed_path

            mov al, es:[si]
            mov [di], al

            inc di
            inc si
            cmp si, bx
            jbe parse_path

            parsed_path:
            mov al, '$'
            mov [di], al
              lea dx, f_buffer
  
  mov ax, @data
  mov ds, ax
  mov ax, ds
  mov word ptr [EBP_block + 4],  ax 
  mov ax, cs 
  mov word ptr [EBP_block + 8],  ax 
  mov word ptr [EBP_block + 12], ax 
  
  xor si, si
  xor dx, dx
  xor di, di
  ;lea di, f_name_buffer
  jmp read_file_name
  
  exit_half:
  jmp exit

  read_file_name:
  cmp [f_buffer + si], '$'
  je open_exe
  cmp [f_buffer + si], ' '
  je open_exe
  mov al, [f_buffer + si]
  mov [f_name_buffer + di], al
  
  inc di
  inc si
  
  jmp read_file_name    
  
  open_exe:
  mov [f_name_buffer + di], '$'
  mov dx, offset f_name_buffer
  ;mov ah, 09h
  ;int 21h
  ;mov [f_name_buffer + di], '$'
  ;lea dx, f_name_buffer
  push dx
  call open_file
  pop dx
  cmp [f_buffer + si], '$'
  je exit
  inc si
  xor di, di
  xor dx, dx
  jmp read_file_name
  
  
  
  mov ah, 09h
  mov dx, offset f_buffer
  int 21h
     
  exit:
    ;lea dx, f_name_buffer
    ;mov ah, 09h
    ;int 21h
    
    mov ax, 4C00h
    int 21h
    
  code_segment_size = $ - start

end start




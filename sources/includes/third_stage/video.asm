;*******************************************************************************************************************
video_print_hexa:  ; A routine to print a 16-bit value stored in di in hexa decimal (4 hexa digits)
pushaq
mov rbx,0x0B8000          ; set BX to the start of the video RAM
;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    mov rcx,0x10                                ; Set loop counter for 4 iterations, one for eacg digit
    ;mov rbx,rdi                                 ; DI has the value to be printed and we move it to bx so we do not change ot
    .loop:                                    ; Loop on all 4 digits
            mov rsi,rdi                           ; Move current bx into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]             ; get the right hexadcimal digit from the array           
            mov byte [rbx],al     ; Else Store the charcater into current video location
            inc rbx                ; Increment current video location
            mov byte [rbx],1Fh    ; Store Blue Backgroun, Yellow font color
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg .loop                            ; Loop again we did not yet finish the 4 digits
    add [start_location],word 0x20
    cmp qword[start_location],0xFA0
    jl .skip_scrolling3
    call video_scroll
    .skip_scrolling3:
    popaq
    ret
;*******************************************************************************************************************


video_print:
    pushaq
    mov rbx,0x0B8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    xor rcx,rcx
video_print_loop:           ; Loop for a character by charcater processing
    lodsb                   ; Load character pointer to by SI into al
    cmp al,13               ; Check end of string to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check  new line character to stop printing
    je out_video_print_loop1 ; If so get out
    mov byte [rbx],al     ; Else Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Fh    ; Store Blue Backgroun, Yellow font color
    inc rbx                ; Increment current video location
                            ; Each position on the screen is represented by 2 bytes
                            ; The first byte stores the ascii code of the character
                            ; and the second one stores the color attributes
                            ; Foreground and background colors (16 colors) stores in the
                            ; lower and higher 4-bits
    inc rcx
    inc rcx
    ;add qword[start_location],2
    jmp video_print_loop    ; Loop to print next character
out_video_print_loop: ;if new line
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX

    mov qword[cursor],rax

    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax

  ;  .nulls_loop:
   ; mov byte [rbx],0    ; Else Store the charcater into current video location
    ;inc rbx                ; Increment current video location
    ;mov byte [rbx],1Fh    ; Store Blue Backgroun, Yellow font color
    ;inc rbx
    ;add qword[cursor],2
    ;mov r14,qword[cursor]
    ;cmp qword[start_location],r14
    ;jl .nulls_loop

    cmp qword[start_location],0xFA0
    jl .skip_scrolling1
    call video_scroll
    .skip_scrolling1:
    jmp finish_video_print_loop
out_video_print_loop1: ;if end of string
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax

    cmp qword[start_location],0xFA0
    jl .skip_scrolling2
    call video_scroll
    .skip_scrolling2:
finish_video_print_loop:
    popaq
ret

;**************************************
video_scroll:
pushaq
        mov rcx,3840 ;80*24*2 total number of bytes
        xor rsi,rsi
        mov rsi, 0xB80A0 ;the address of the second line
        xor rdi,rdi
        mov rdi, 0xB8000 ;the adress of the first line
        rep movsb
        mov qword[start_location],0xF00;set the cursor position to the beginning of the last line = 24, mov [], 0x170F00
popaq
ret
;***********************************
clear_screen:
pushaq
    xor rbx,rbx
    mov rbx,0xB8000
    .clear_loop:
    mov byte[rbx],0x20
    inc rbx
    mov byte[rbx],0x88 ;responsible for grey color for the font and the background
    inc rbx
    cmp rbx,0xB8FA0
    jl .clear_loop
    mov qword[start_location],0x0 ;to move the cursor back to the top left
popaq
ret

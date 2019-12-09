;************************************** bios_print.asm **************************************      
      bios_print:       ; a subroutine to print the string stored in si character by character
            pusha                   ; push the values of the registers on the stack
            .print_loop:            ; the fucntion loop
                  xor ax,ax         ; ax=0
                  lodsb             ; c[si++]
                  or al, al         ; if al=0 the zero flag will be true
                  jz .done          ; if zero flag=true, exit the loop
                                    ; otherwise print the character in al
                  mov ah, 0x0E      ; calling function 0x0E in int 0x10 to print a character
                  int 0x10          ; Print character loaded in al
                  jmp .print_loop   ; Loop
                  .done:            ; to exit the loop after finishing
                        popa        ; pop the registers from the stack
                        ret         ; jump back

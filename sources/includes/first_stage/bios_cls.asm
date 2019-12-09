;************************************** bios_cls.asm **************************************      
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen
            pusha       ; push the values of the registers to the stack      
            mov ah,0x0  ; to call function 0 in interrupt 0x10
            mov al,0x3  ; 80x25 16 color text mode
            int 0x10    ; Issue INT 0x10
            popa        ; pop the values of the registers from the stack
            ret

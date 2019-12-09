;************************************** get_key_stroke.asm **************************************      
        get_key_stroke: ; a function to print a confirmation message and wait for key press to go to second boot stage
            pusha    ; push the values of the registers on the stack
            mov ah,0x0 ; calling function 0 in int 0x16 wait for a keyboard input
            int 0x16 ; interrupt 0x16
            popa    ; pop the values of the registers from the stack
            ret 
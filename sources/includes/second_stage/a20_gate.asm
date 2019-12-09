check_a20_gate:
    pusha  ; Save all general purpose registers on the stack
        temp dw 0 ;a variable to check if we have already accessed the enable_a20 label
        check_a20:
                mov ax,0x2402 ;ax=0x2402 function number
                int 0x15 ;call interrupt 0x15
                jc error_a20 ;to check the kind of error if the carry flag is set
                cmp al,0x0 ;otherwise to compare al with 0x0 to see if a20 is enabled
                je check2_a20 ;to check if we previously tried to enable it and jmp to enable otherwise
                jmp done_a20 ;otherwise jump to done

        check2_a20:
                cmp word[temp],0x1 ;if [temp]=1 then there's an unknown errpr
                jne enable_a20 ;otherwise jump to enable_a20 to enable it
                jmp error_a20_3

        enable_a20:
                mov word[temp],0x1 ;set [temp] to 0x1 as an indicator that this label has been accessed
                mov ax,0x2402 ;function number
                int 0x15 ;call interrupt 0x15
                jc error_a20_2 ;to print error message that a20 is not enabled
                jmp check_a20 ;to back to check again
        
        error_a20_1: ;function not supported
                 mov si,a20_function_not_supported_msg; to store the error msg in si to print it
                 call bios_print
                 jmp hang
        error_a20_2: ;A20 not enabled
                 mov si,a20_not_enabled_msg; to store the error msg in si to print it
                 call bios_print
                 jmp hang
        error_a20_3: ;unknown error
                 mov si,unknown_a20_error; to store the error msg in si to print it
                 call bios_print
                 jmp hang
        error_a20_4: ;keyboard controller error
                 mov si,keyboard_controller_error_msg; to store the error msg in si to print it
                 call bios_print
                 jmp hang
        error_a20:
                cmp ah,0x1 ;if ah=0x1 then the keyboard controller is in secure mode or unavailable
                je error_a20_4
                cmp ah,0x86 ;if ah=0x86 then a20 function is not supported
                je error_a20_1
                jmp hang
        done_a20:
                mov si,a20_enabled_msg
                call bios_print
    popa ; pop the values of registers from the stack
    ret
;********************************* detect_boot_disk.asm **********************************      
      detect_boot_disk: ; a function to get the storage device number of the device we try to                       boot from so that after calling the function,[boot_drive] should                            contain the device number
                        ; Upon booting the bios stores the boot device number in dl
            pusha  ; push the values of the registers to the stack


            mov si,fault_msg ; put the address of fault_msg in si
            xor ax,ax ; ax=0 to reset
            int 13h; calling interrupt 0x13
            jc .exit_with_error ; to exit if there's an error carry (flag=true)
            mov si,booted_from_msg ;put the address of booted_from_msg in si
            call bios_print ; to jump to bios print function
            mov [boot_drive],dl ; to assidn the boot drive value to be equal to dl
            cmp dl,0 ; check if dl is zero
            je .floppy ; to jump to .floppy if 0
            call load_boot_drive_params ; to call load_boot_drive_params otherwise
            mov si,drive_boot_msg ; put drive_boot_msg into si  
            jmp .finish ; to end the function
            .floppy:
                  mov si,floppy_boot_msg ; put the address of floppy_boot_msg into si
                  jmp .finish
            .exit_with_error:
                  jmp hang ; to freeze the program
            .finish:
                  call bios_print ; to print the message stored in si

                  
            popa  ;pop the values of the registers from the stack
            ret
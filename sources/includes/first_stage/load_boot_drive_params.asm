;********************************* load_boot_drive_params.asm *********************************
      load_boot_drive_params: ; to read the [boot_drive] parameters and set [hpc] and [spt]
            pusha     ; push the values of the registers on the stack

            xor di , di ; di=0
            mov ah,0x8 ; to call function 0x8 in int 0x13
            mov dl,[boot_drive] ; to determine the number of the disk
            int 0x13 ; call interrupt 0x13
            inc dh ; dh++ to get the number of head per cylinder
            mov word [hpc],0x0 ; [hpc]=0
            mov [hpc+1],dh ; move the value of dh into the lower byte of the of [hpc]. 
            and cx, 0000000000111111b ; to get the right most 6 bits
            mov word [spt], cx ; move the value of cx into [spt]

            popa      ; pop the values of the registers from the stack
            ret                                       

 ;*********************************** read_disk_sectors.asm ***********************************
      read_disk_sectors: ;to read a number of 512-sectors stored in DI as the sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
            pusha    ; push the values of the registers on the stack

            add di,[lba_sector]; Add lba_sector to DI as it's the last sector to read
            mov ax,[disk_read_segment]; to load the address where read sectors will be loaded in es:bx
      mov es,ax; es=ax as we can't set es directly
      add bx,[disk_read_offset]; set bx to the offset
      mov dl,[boot_drive]; to read from boot drive
      .read_sector_loop:
            call lba_2_chs;to convert the LBA to CHS first
            mov ah,0x2; ah=0x2
            mov al,0x1; al=0x1
            mov cx,[Cylinder]; cx[cylinder]
            shl cx,0xA; Shift the value of CX 0xA bits to the left 
            or cx,[Sector]; Store Sector into CX first 6 bits
            mov dh,[Head]; dh=[Head]
            int 0x13; call int 0x13
            jc .read_disk_error; to print error message if carry flag is true
            mov si,dot; to print a '.' when a sector is read
            call bios_print
            inc word[lba_sector]; to move to the next sector
            add bx,0x200; to move to the next memory location
            cmp word[lba_sector],di; to see if the are done
            jl .read_sector_loop; loop

            jmp .finish; to end the functino
      .read_disk_error:
            mov si,disk_error_msg; to store the error msg in si to print it
            call bios_print
            jmp hang
      .finish:
            popa  ; pop the values of the registers from the stack
            ret

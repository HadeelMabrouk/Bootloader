 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; a function to convert from LBA to CHS
                  ; [Sector] = [lba_sector] mod [spt] +1
                  ; [Cylinder] = ([lba_sector]/[spt]) / [hpc]
                  ; [Head] = ([lba_sector]/[spt]) mod [hpc]
            pusha   ; push the values of the registers on the stack

                  xor dx,dx; dx=0
                  mov ax, [lba_sector]; put the value of [lba_sector] to ax
                  div word[spt]; ([lba_sector]/[spt])
                  inc dx; dx++ to get the value of the sector
                  mov [Sector],dx ; store the value of dx in [Sector] 
                  xor dx,dx; dx=0
                  div word [hpc] ; ([lba_sector]/[spt]) / [hpc]
                  mov [Cylinder],ax; [Cylinder] = ([lba_sector]/[spt]) / [hpc]
                  mov [Head],dl; [Head] = ([lba_sector]/[spt]) mod [hpc]

            popa    ; pop the values of the registers from the stack
            ret
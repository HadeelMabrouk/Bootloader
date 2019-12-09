%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150      


    sum dq 0 ;to store in it the total size of the memory of type 1


    memory_scanner:
            pusha  ; push the values of the registers on the stack

            mov ax,MEM_REGIONS_SEGMENT 
            mov es,ax ; es = 0x2000
            xor ebx,ebx ; ebx=0
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0 ; make [0x2000:0x1000] a counter for memory regions
            mov di, PTR_MEM_REGIONS_TABLE ; di = 0x1018 to be 24-bytes aligned
            .memory_scanner_loop: ; to scan available memory regions
            mov edx,MEM_MAGIC_NUMBER ; dx = 0x0534D4150 = 'SMAP', the magic number
            mov word [es:di+20], 0x1 ; [es:di+20]=0x1
            mov eax, 0xE820 ; move the memory scanner function number to eax
            mov ecx,0x18 ;to store the data of the region
            int 0x15 ;call interrupt 0x15
            jc .memory_scan_failed ; to print failure message if the carry flag is set
            cmp eax,MEM_MAGIC_NUMBER ; to compare eax with the magic number
            jnz .memory_scan_failed ; if they're not equal, then something must be wrong
            add di,0x18 ; otherwise, we increment di to point to the next entry in the table
            inc word [es:PTR_MEM_REGIONS_COUNT] ; memory regions counter++
            cmp ebx,0x0 ;if ebx=0, then there're no more regions so we need to exit
            jne .memory_scanner_loop ; loop to get the following region
            jmp .finish_memory_scan ; to jump to the end of the section and skip the error part
            .memory_scan_failed:
                mov si,memory_scan_failed_msg ; to print failure message
                call bios_print
                jmp hang
            .finish_memory_scan:

            popa      ;to pop the values of the registers from the stack
            ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax       
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018 
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix


                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix
                
                cmp dword [es:si+16],0x1
                jne .skip_addition
                mov eax,dword [es:si+8] ;move to eax the size of the memory region
                add [sum],eax ;add it to sum

           .skip_addition:
                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop

                mov edi,[sum] ;moving the value stored in sum to edi to print it
                call bios_print_hexa

            popa
            ret

    
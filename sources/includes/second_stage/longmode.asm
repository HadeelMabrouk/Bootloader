%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT

        %define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000

switch_to_long_mode:
        pusha

        ;cr4
        ; Set the PAE bit 5 and PGE bits bit 7 of cr4
        mov eax, 10100000b
        mov cr4, eax

        ;cr3
        mov edi,PAGE_TABLE_EFFECTIVE_ADDRESS
        mov edx, edi ; to make cr3 point to page table address PLM4
        mov cr3, edx

        ; MSR
        mov ecx, 0xC0000080 ;set ecx tp 0xC0000080
        rdmsr ;to read from MSR
        or eax, 0x00000100 ; to modify bit 8 to enable longmode
        wrmsr ;to write to MSR

        ;cr0
        mov ebx, cr0 ;to modify cr0 and set it back
        or ebx,0x80000001 ; Set Bit 0 for protected mode and 31 to enable paging
        mov cr0, ebx 

        lgdt[GDT64.Pointer] ;to load the GDT pointer
        jmp CODE_SEG:LM64 ;to jump to LM64 to jump to long mode
        
        popa    

    ret
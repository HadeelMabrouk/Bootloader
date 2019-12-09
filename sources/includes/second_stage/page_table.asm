%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3 ; 011b
%define MEM_PAGE_4K 0x1000
build_page_table:
 pusha
        ; Store into es:di 0x000:0x1000
        mov ax,PAGE_TABLE_BASE_ADDRESS
        mov es,ax
        xor eax,eax
        mov edi,PAGE_TABLE_BASE_OFFSET
        ; Initialize 4 memory pages
        mov ecx, 0x1000 ; ecx = 4K
        xor eax, eax ; eax =0
        cld ; to reset direction flag
        rep stosd ; to map 4 memory pages
        mov edi,PAGE_TABLE_BASE_OFFSET ; edi = 0x1000

        ; PML4 is now at [es:di] = [0x0000:0x1000]
        lea eax, [es:di + MEM_PAGE_4K] ; store the flat address in eax
        or eax, PAGE_PRESENT_WRITE ; enable bit 0 and 1
        mov [es:di], eax ; the first entry of the PML4 = 0x2003

        ; PDP is now at [es:di] = [0x0000:0x2000]
        add di,MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K] ; store the flat address in eax
        or eax, PAGE_PRESENT_WRITE ; enable bit 0 and 1
        mov [es:di], eax ; the first entry of the PML4 = 0x3003

        ; PD is now at [es:di] = [0x0000:0x3000]
        add di,MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K] ; store the flat address in eax
        or eax, PAGE_PRESENT_WRITE ; enable bit 0 and 1
        mov [es:di], eax ; the first entry of the PML4 = 0x4003

        ; PT is now at [es:di] = [0x0000:0x4000]
        add di,MEM_PAGE_4K
        mov eax, PAGE_PRESENT_WRITE ; enable bit 0 and 1
        .pte_loop: ; to map the first 2 MB
        mov [es:di], eax
        add eax, MEM_PAGE_4K
        add di, 0x8
        cmp eax, 0x200000 ; Check if we mapped 2 MB.
        jl .pte_loop ; loop if eax is still < 2 MB
popa
ret
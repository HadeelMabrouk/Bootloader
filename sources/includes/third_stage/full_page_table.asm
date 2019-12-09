%define MEM_REGIONS_SEGMENT         0x2000 
%define PTR_MEM_REGIONS_COUNT       0x21000
%define PTR_MEM_REGIONS_TABLE       0x21018 

check_max_size:
            pushaq 
            mov rsi,PTR_MEM_REGIONS_TABLE
            mov rax,qword[PTR_MEM_REGIONS_COUNT]
            mov qword[mem_region_count],rax
            .max_size_loop
                mov rax,qword [rsi] ;rax = start of the region
                mov rbx,qword [rsi+8]
                add rbx,rax ;rbx = end of the region
                xor rcx,rcx
                mov ecx,dword [rsi+16]
                cmp rcx,0x1 ;check if of type 1
                jne .skip_max_size_loop
                mov qword[max_size],rbx ;set the max size to be = the end of the last region of type 1
                .skip_max_size_loop
                dec qword[mem_region_count] ;decrement the counter
                add rsi,0x18 ;to point to the next mem region
                cmp qword[mem_region_count],0x0 ;to exit the loop when the counter reaches 0
                jne .max_size_loop
            popaq
            ret



check_memory_regions:
            pushaq 
            mov rsi,PTR_MEM_REGIONS_TABLE 
            sub rsi,0x18
            mov qword[memory_type],0x0
            .check_memory_regions_loop
                add rsi,0x18
                mov rax,qword [rsi] ;rax = start of the region
                mov rbx,qword [rsi+8]
                add rbx,rax ;rbx = end of the region
                cmp qword[current_map_page],rax ;to check whether the page is within the limits of the memory region
                jl .check_memory_regions_loop
                cmp qword[current_map_page],rbx
                jg .check_memory_regions_loop
                xor rcx,rcx
                mov ecx,dword [rsi+16] ;if yes then move to [memory_type] the value of the type
                mov qword[memory_type],rcx
            popaq
            ret

full_page_table:
pushaq
        call check_max_size
        ;mov qword[current_map_page],0xf1000
        ;call check_memory_regions
        ;mov rdi,qword[memory_type]
        ;call video_print_hexa
        ;hlt 

        .PLM4_loop:

                mov rax,qword[PLM4_ptr]
                mov rbx,qword[PDP_ptr]
                or rbx,0x3
                mov qword[rax],rbx

                mov qword[PDP_counter],0x0 ;reset the counter
                .PDP_loop:

                        mov rax,qword[PDP_ptr]
                        mov rbx,qword[PD_ptr]
                        or rbx,0x3
                        mov rdi,rbx
                        call video_print_hexa
                        mov rsi,newline
                        call video_print
                        mov qword[rax],rbx

                        mov qword[PD_counter],0x0 ;reset the counter
                        .PD_loop:   
                                mov rax,qword[PD_ptr]
                                mov rbx,qword[PT_ptr] 
                                or rbx,0x3
                                mov qword[rax],rbx;

                                mov qword[PT_counter],0x0 ;reset the counter
                                .PT_loop:
                                        mov rax,qword[max_size] ;to compare the current map page with the max size
                                        mov rbx,qword[current_map_page]
                                        cmp rbx,rax
                                        jg .finish ;to exit if the current map page exceeds the max
                                        
                                        cmp qword[current_map_page],0x200000
                                        jle .skip_checking_region
                                        call check_memory_regions
                                        cmp qword[memory_type],0x1 ;to check if the page is of type 1
                                        jne .skip_mapping ;to skip mapping if it's of type 2
                                        
                                        .skip_checking_region:
                                        mov rax,[current_map_page]
                                        or rax,0x3 ;to set the least 2 bits of the page to be 1
                                        mov rbx,qword[PT_ptr] ;to store in rbx the value of the pt pointer
                                        mov qword [rbx],rax ;to store the address of the page in the PT pointer
                                
                                        add qword[PT_ptr],0x8 ;increment the pointer by 8 bytes
                                        .skip_mapping
                                        add qword[current_map_page],0x1000 ;advance to the next page
                                        inc qword[PT_counter] ;increment the PT loop counter
                                        cmp qword[PT_counter],0x200 ;to exit the PT loop if > 512
                                        jl .PT_loop
                                        mov rax,qword[ptable_ptr]
                                        mov qword[PT_ptr],rax
                                        add qword[ptable_ptr],0x1000
                                cmp qword[PDP_counter],0x0
                                jnz .skip_cr3_load
                                mov rax,qword[PLM4_ptr]
                                mov cr3,rax ;to update the cr3 to increase the memory
                        .skip_cr3_load:
                        add qword[PD_ptr],0x8 ;increment the pointer by 8 bytes
                        inc qword[PD_counter] ;increment the PD loop counter
                        cmp qword[PD_counter],0x200 ;to exit the PD loop if > 512
                        ;jmp .finish
                        jl .PD_loop
                ;jmp .finish
                mov rax,qword[ptable_ptr]
                mov qword[PD_ptr],rax
                add qword[ptable_ptr],0x1000
 
;                mov r14,qword[PT_ptr]
;                or r14,0x3
;                mov rbx,qword[PD_ptr]
;                mov [rbx],r14
;                mov qword[PD_ptr],r14

                add qword[PDP_ptr],0x8 ;increment the pointer by 8 bytes
                inc qword[PDP_counter] ;increment the PDP loop counter
                cmp qword[PDP_counter],0x200 ;to exit the PDP loop if > 512
                ;jz .finish
                jl .PDP_loop

        add qword[PLM4_ptr],0x8 ;increment the pointer by 8 bytes
        inc qword[PLM4_counter] ;increment the PLM4 loop counter
        cmp qword[PLM4_counter],0x4 ;to exit the PLM4 loop if > 4
        jl .PLM4_loop               

        
        .finish: 
        mov rax,qword[PLM4_ptr]
        mov cr3,rax ;to update the cr3 to increase the memory 
popaq     
ret
[ORG 0x10000]

[BITS 64]

call full_page_table                ; mapping the page table at the beginning of the thrid stage 
;a code to test page table
mov rax,0x80000010
mov byte[rax],'A'                   ; insert the value of A inyo rax
inc rax                             ; increament the rax value
mov byte[rax],13                    ; new line 
inc rax                             ; 
mov byte[rax],0
inc rax
mov rsi,0x80000010
call video_print

Kernel:

bus_loop:                               ; CONFIGURing SPACE OF DEVICES
    device_loop:
        function_loop:
            call get_pci_device         ; call the PCI device function to configure the device space

            ;printing pci device info
            ;cmp word[pci_header],0xffff
            ;je .skip_print_pci
            ;mov rdi,[pci_header]
            ;call video_print_hexa
            ;mov rsi,newline
            ;call video_print

            ;.skip_print_pci:
            inc byte [function]         ; increament the function number to get up to 8 functions
            cmp byte [function],8
        jne device_loop
        inc byte [device]               ; increament the device number to get up to 32 
        mov byte [function],0x0 
        cmp byte [device],32
        jne device_loop
    inc byte [bus]                      ; increament the bus number to configure all the 256 buses
    mov byte [device],0x0
    cmp byte [bus],255
    jne bus_loop

call clear_screen                       ; call clean screen subroutine after printing the configured devices 

channel_loop:
    mov qword [ata_master_var],0x0
    master_slave_loop:
        mov rdi,[ata_channel_var]
        mov rsi,[ata_master_var]
        call ata_identify_disk
        inc qword [ata_master_var]
        cmp qword [ata_master_var],0x2
        jl master_slave_loop

    inc qword [ata_channel_var]
    inc qword [ata_channel_var]
    cmp qword [ata_channel_var],0x4
    jl channel_loop
    

call init_idt
call setup_idt



mov rsi,hello_world_str
call video_print







kernel_halt: 
    hlt
    jmp kernel_halt


;*******************************************************************************************************************
      
      %include "sources/includes/third_stage/pushaq.asm"
      %include "sources/includes/third_stage/pic.asm"
      %include "sources/includes/third_stage/idt.asm"
      %include "sources/includes/third_stage/pci.asm"
      %include "sources/includes/third_stage/video.asm"
      %include "sources/includes/third_stage/pit.asm"
      %include "sources/includes/third_stage/ata.asm"
      %include "sources/includes/third_stage/full_page_table.asm"

;*******************************************************************************************
PLM4_ptr dq 0x100000
PDP_ptr dq 0x101000
PD_ptr dq 0x102000
PT_ptr dq 0x103000
ptable_ptr dq 0x104000
mem_limit dq 0x0

current_map_page dq 0x0

PT_counter dq 0x0
PD_counter dq 0x0
PDP_counter dq 0x0
PLM4_counter dq 0x0

mem_region_count dq 0x0
max_size dq 0x0
memory_type dq 0x0

cursor dq 0x0
nofbytes dq 0x0

rows dq 0x0
cols dq 0x0

colon db ':',0
comma db ',',0
newline db 13,0

end_of_string  db 13        ; The end of the string indicator
start_location   dq  0x0  ; A default start position (Line # 8)

    hello_world_str db 'Hello all here',13, 0
    hello_third_stage db 'Hello third stage',13,0
    memory_works db 'Memory workds',13,0

    ata_channel_var dq 0
    ata_master_var dq 0

    bus db 0
    device db 0
    function db 0
    offset db 0
    hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
    ALIGN 4


;times 8192-($-$$) db 0
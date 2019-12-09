;******************************* second_stage.asm ************************************

ORG 0xC000        ; Since this code will be loaded at 0xC000 we need all the addresses to be relative to 0xC000
                  ; The ORG directive tells the linker to generate all addresses relative to 0xC000   
BITS 16

%define M_REGIONS_SEGMENT           0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x18
%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT
;********************************* Main Program **************************************
      call bios_cls
      mov si, greeting_msg    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen. 
      mov si,enable_a20_question
      call bios_print
      call get_key_stroke     ; Wait for key storke to jump to second boot stage
      call check_a20_gate
      mov si,check_cpuid_question
      call bios_print
      call get_key_stroke     ; Wait for key storke
      call check_long_mode
      mov si,scan_mem_question
      call bios_print
      call get_key_stroke     ; Wait for key storke
      call memory_scanner
      mov si,print_mem_reg_table_question
      call bios_print
      call get_key_stroke     ; Wait for key storke
      call print_memory_regions
      call get_key_stroke     ; Wait for key storke to jump to second boot stage
      ;jmp hang
      ;call mapping_first2mb
      
      call build_page_table 

      mov si,pml4_page_table_msg
      call bios_print 
      call get_key_stroke

      call disable_pic
      call bios_cls

      call load_idt_descriptor
      call switch_to_long_mode

        lgdt[GDT64.Pointer]
        jmp CODE_SEG:LM64
        
      hang:                   ; An infinite loop just in case interrupts are enabled. More on that later.
            hlt               ; Halt will suspend the execution. This will not return unless the processor got interrupted.
            jmp hang          ; Jump to hang so we can halt again.
;************************************* Data ******************************************


greeting_msg      db "___  ___      _____ _____          ___  _   _ _____ ", 13, 10
                  db "|  \/  |     |  _  /  ___|  ____  / _ \| | | /  __ \", 13, 10
                  db "| .  . |_   _| | | \ `--.  / __ \/ /_\ \ | | | /  \/", 13, 10
                  db "| |\/| | | | | | | |`--. \/ / _` |  _  | | | | |    ", 13, 10
                  db "| |  | | |_| \ \_/ /\__/ / | (_| | | | | |_| | \__/\", 13, 10
                  db "\_|  |_/\__, |\___/\____/ \ \__,_\_| |_/\___/ \____/", 13, 10
                  db "         __/ |             \____/                   ", 13, 10
                  db "        |___/                                       ", 13, 10
                  db " _____               _   _                          ", 13, 10
                  db "|  __ \             | | (_)                         ", 13, 10
                  db "| |  \/_ __ ___  ___| |_ _ _ __   __ _ ___          ", 13, 10
                  db "| | __| '__/ _ \/ _ \ __| | '_ \ / _` / __|         ", 13, 10
                  db "| |_\ \ | |  __/  __/ |_| | | | | (_| \__ \         ", 13, 10
                  db " \____/_|  \___|\___|\__|_|_| |_|\__, |___/         ", 13, 10
                  db "                                  __/ |             ", 13, 10
                  db "                                 |___/              ", 13, 10
                  db " _____  _____ _____  _____       _____  _____  __   ", 13, 10
                  db "/  __ \/  ___/  __ \|  ___|     / __  \|____ |/  |  ", 13, 10
                  db "| /  \/\ `--.| /  \/| |__ ______`' / /'    / /`| |  ", 13, 10
                  db "| |     `--. \ |    |  __|______| / /      \ \ | |  ", 13, 10
                  db "| \__/\/\__/ / \__/\| |___      ./ /___.___/ /_| |_ ", 13, 10
                  db " \____/\____/ \____/\____/      \_____/\____/ \___/ ", 13, 10
                  db "Second Stage Boot Loader is ready, press any key to resume",13,10,0  
done_msg    db 'A lot should be done here',13,10,0
hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
hexa_prefix                   db '0x',0
newline                       db 13,10,0
space                         db ' ',0
double_space                  db '  ',0
unknown_a20_error db 'Unknown A20 error',13,10,0
keyboard_controller_error_msg db 'Keyboard controller is in secure mode',13,10,0
a20_function_not_supported_msg db 'A20 function not supported',13,10,0
a20_enabled_msg db 'A20 is enabled',13,10,0
a20_not_enabled_msg db 'A20 is not enabled',13,10,0
cpuid_not_supported db 'CPUID not supported',13,10,0
cpuid_supported db 'CPUID supported',13,10,0
long_mode_supported_msg db 'Long mode supported',13,10,0
long_mode_not_supported_msg db 'Long mode not supported !!!!',13,10,0
memory_scan_failed_msg db 'Memory Scan Failed',13,10,0
read_region_msg db 'read memory region',13,10,0
pic_disabled_msg db 'PIC disabled',13,10,0
pml4_page_table_msg db 'PML4 page table created successfully',13,10,0

enable_a20_question db 'Press key to enable A20 gate',13,10,0
check_cpuid_question db 'Press key to check cpuid',13,10,0
check_longmode_question db 'Press key to check long mode support',13,10,0
scan_mem_question db 'Press key to scan memory regions',13,10,0
print_mem_reg_table_question db 'Press key to print table details',13,10,0
video_x db 0
video_y db 0
;**************************** Subroutines/Functions **********************************
      %include "sources/includes/first_stage/bios_cls.asm"
      %include "sources/includes/first_stage/bios_print.asm"
      %include "sources/includes/first_stage/bios_print_hexa.asm"
      %include "sources/includes/first_stage/get_key_stroke.asm"
      %include "sources/includes/second_stage/a20_gate.asm"
      %include "sources/includes/second_stage/check_long_mode.asm"
      %include "sources/includes/second_stage/memory_scanner.asm"
      %include "sources/includes/second_stage/pic.asm"
      %include "sources/includes/second_stage/idt.asm"
      %include "sources/includes/second_stage/video.asm"
      %include "sources/includes/second_stage/gdt.asm"
      %include "sources/includes/second_stage/page_table.asm"
      %include "sources/includes/second_stage/longmode.asm"
     ; %include "sources/includes/second_stage/mapping_first2mb.asm"

;**************************** Long Mode 64-bit  **********************************
[BITS 64]

LM64:

    mov ax, DATA_SEG ; Set data segment to GDT Data Segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp 0x10000

lm_hang:             ; Halt Loop
      hlt
      jmp lm_hang

times 4096-($-$$) db 0


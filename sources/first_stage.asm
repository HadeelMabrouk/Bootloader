;****************************************************************************************
;**************                MyOS First Stage Boot Loader                **************
;****************************************************************************************
[ORG 0x7c00]      ; Since this code will be loaded at 0x7c00 we need all the addresses to be relative to 0x7c00
                  ; The ORG directive tells the linker to generate all addresses relative to 0x7c00
;******************************************* Macros **********************************************
%define SECOND_STAGE_CODE_SEG       0x0000      ; The segment address where we should load the second stage boot laoder
%define SECOND_STAGE_OFFSET         0xC000      ; The offset where we should start loading the second stage boot loader
%define THIRD_STAGE_CODE_SEG        0x1000      ; The segment address where we should load the second stage boot laoder
%define THIRD_STAGE_OFFSET          0x0000      ; The offset where we should start loading the second stage boot loader
%define STACK_OFFSET                0xB000      ; The offset of the stack. The stack should grow upward from 0xB000 - 0x8000  
;*************************************** Main Program ********************************************
      xor ax,ax                           ; ax=0
      mov ds,ax                           ; ds=0
      mov ss,ax                           ; ss=0
      mov sp,STACK_OFFSET                 ; Stack grows upwards so we have atleast 0x2000 = 8192 bytes = 8 K stack large
      call bios_cls                       ; to clear the screen
      mov si,greeting_msg                 ; move the greeting msg address to si
      call bios_print                     
      call detect_boot_disk             ; to set all disk parameters and to start reading sectors.
      mov di,0x8 ;di=0x8
      mov word [disk_read_segment],SECOND_STAGE_CODE_SEG
      mov word [disk_read_offset],SECOND_STAGE_OFFSET
      call read_disk_sectors              ; to read 4 KB (8 512-sectors) which have the second stage boot loader
      mov di,0x7F ;di=0x74
      mov word [disk_read_segment],THIRD_STAGE_CODE_SEG
      mov word [disk_read_offset],THIRD_STAGE_OFFSET
      call read_disk_sectors   ; to read 63.5 KB which contains the third stage boot loader, 
                               
      mov si,second_stage_loaded_msg      ; move the address of second_stage_loaded_msg into si
      call bios_print
      call get_key_stroke                 ; to wait for key press to jump to second boot stage
      jmp SECOND_STAGE_OFFSET             ; to perform a long jump as we are going to jump to another segment jmp ox1000:0x0000

      hang:             ; to freeze in case of intrrupt 
            hlt         ; to suspend the execution
            jmp hang    ; loop
;****************************** Data Declaration and Definition **********************************
      %include "sources/includes/first_stage/first_stage_data.asm"
;****************************** Subroutines/Functions Includes ***********************************
      %include "sources/includes/first_stage/detect_boot_disk.asm"
      %include "sources/includes/first_stage/load_boot_drive_params.asm"
      %include "sources/includes/first_stage/lba_2_chs.asm"
      %include "sources/includes/first_stage/read_disk_sectors.asm"
      %include "sources/includes/first_stage/bios_cls.asm"
      %include "sources/includes/first_stage/bios_print.asm"
      %include "sources/includes/first_stage/get_key_stroke.asm"
;**************************** Partition Table ****************************************
times 446-($-$$) db 0
      pt_e1:
            db 0x80 ;to make it bootable
            db 0x0 ;starting head
            dw 0000010000000000b ;starting sector and cylinder
            db 0x83 ;for the file system ID 83
            db 0x2 ;ending head
            dw 0000100000000001b ;ending sector and ending cylinder
            dd 0x1 ;LBA relative sector number
            dd 0x1 ;total number of sectors
      pt_e2:
            times 16 db 0
      pt_e3:
            times 16 db 0
      pt_e4:
            times 16 db 0

;**************************** Padding and Signature **********************************

      times 510-($-$$) db 0   ; $$ refers to the start address of the current section, $ refers to the current address.
                              ; ($-$$) is the size of the above code/data
                              ; times take a count and a data item and repeat it as many time as the value of count.
                              ; We subtract ($-$$) from 510 and use "times" to fill in the rest of the 510 with zero bytes.
                              ; We use 510 instead of 512 to reserve the last two bytes for the signature below. 
      db 0x55,0xAA            ; Boot sector MBR signature



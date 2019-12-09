;************************************ first_stage_data.asm ************************************
      boot_drive        db 0x0      ; to store the boot drive number
      lba_sector        dw 0x1      ; to store the next sector to read initially 0x1
      spt               dw 0x12     ; to store the number of sectors/track initially the default value of floppy
      hpc               dw 0x2      ; to store the number of head/cylinder initially the default value of floppy
      ; to store values while converting from LBA to CHS
      Cylinder          dw 0x0
      Head              db 0x0
      Sector            dw 0x0
      ;messages to print during first stage boot loader
      disk_error_msg                db 'Disk Error', 13, 10, 0
      fault_msg                     db 'Unknown Boot Device', 13, 10, 0
      booted_from_msg               db 'Booted from ', 0
      floppy_boot_msg               db 'Floppy', 13, 10, 0
      drive_boot_msg                db 'Disk', 13, 10, 0
      greeting_msg                  db '1st Stage Loader', 13, 10, 0
      second_stage_loaded_msg       db 13,10,'2nd Stage loaded, press any key to resume!', 0
      dot                           db '.',0
      newline                       db 13,10,0
      disk_read_segment             dw 0
      disk_read_offset              dw 0
      ; "13,10" is for "\r\n". "0" for a null char to end the string

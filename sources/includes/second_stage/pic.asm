%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    disable_pic:
        pusha
        mov al,0xFF
        out MASTER_PIC_DATA_PORT,al ;to disable the master
        out SLAVE_PIC_DATA_PORT,al ;to disable the slave
        nop ;no operations to give some time for the controller to shut down
        nop
        mov si, pic_disabled_msg ;print success message
        call bios_print
        popa
        ret
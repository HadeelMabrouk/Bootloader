ALIGN 4                 ; to make the IDT starts at a 4-byte aligned address    
IDT_DESCRIPTOR:         ;the address of the IDT descriptor
      .Size dw    0x0     ; Table size =0
      .Base dd    0x0     ; Table base address =0

load_idt_descriptor:
    pusha
    lidt [IDT_DESCRIPTOR]    ; to overwrite the IDT descriptor

    popa
    ret
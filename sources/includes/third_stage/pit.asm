%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43

pit_counter dq    0x0               ; A variable for counting the PIT ticks

handle_pit:
      pushaq
            mov rdi,[pit_counter]         ; Value to be printed in hexa
            ;push qword [start_location]
            ;mov qword [start_location],0
            call video_print_hexa          ; Print pit_counter in hexa
            ;pop qword [start_location]
            inc qword [pit_counter]       ; Increment pit_counter
            mov rsi,newline
            call video_print
      popaq
      ret



configure_pit:
    pushaq
      mov rdi,32 ; PIT is connected to IRQ0 -> Interrupt 32
      mov rsi, handle_pit ; The handle_pit is the subroutine that will be invoked when PIT fires
      call register_idt_handler ; We register handle_pit to be invoked through IRQ32
      mov al,00110110b ; Set PIT Command Register 00 -> Channel 0, 11 -> Write lo,hi bytes, 011 -> Mode 3, 0-> Bin
      out PIT_COMMAND,al ; Write command port
      xor rdx,rdx ; Zero out RDX for division
      mov rcx,1000 ;the value of the counter
      mov rax,1193180 ; 1.193180 MHz
      div rcx ; Calculate divider -> 11931280/50
      out PIT_DATA0,al ; Write low byte to channel 0 data port
      mov al,ah ; Copy high byte to AL
      out PIT_DATA0,al ; Write high byte to channel 0 data port
    popaq
    ret
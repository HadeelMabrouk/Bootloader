        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            mov si,check_longmode_question
            call bios_print
            call get_key_stroke     ; Wait for key storke
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack


            pushfd ; push the eflags to get them back at the end of the subroutine

            pushfd ; push them again for comparison
            pushfd 
            pop eax ;to copy the flags to eax
            xor eax,0x0200000 ; to switch the value of bit 21
            push eax ; push eax on the stack
            popfd
            pushfd 
            pop eax ; copy eflags to eax
            pop ecx ; ecx= the orginal eflags
            ; if bit 21 got modified then ecx should be different from eax
            xor eax,ecx ; so if we xored the 2 bits we should get 1
            and eax,0x0200000 ; to zero all the bits except the one that we're investigating
            cmp eax,0x0 ; to see if it was modified above
            jne .cpuid_supported ; print success message
            mov si,cpuid_not_supported ; otherwise print failure message
            call bios_print
            jmp hang
            .cpuid_supported: ; Print a message indicating that cpuid is supported
            mov si,cpuid_supported
            call bios_print
            popfd ; get the efalgs back

            popa                ; pop the values of the registers from the stack
            ret


        check_long_mode_with_cpuid:
            pusha  ; to push the values of the registers on the stack

            mov eax,0x80000000 ; cpuid function to determine the largest function number
            cpuid
            cmp eax,0x80000001 ; If the largest function number is less than 0x80000001 then it is not supported
            jl .long_mode_not_supported ; Error and hang
            mov eax,0x80000001 ; Else invoke cpuid function 0x80000001 to get the processor extended features bits (EDX).
            cpuid
            and edx,0x20000000 ; Mask out all bits in edx except bit # 29 which is the Long Mode LM-bit
            cmp edx,0 ; if edx is zero them LM-bit is not set
            je .long_mode_not_supported ; to print failure message and hang
            mov si,long_mode_supported_msg ; to print success message
            call bios_print
            jmp .exit_check_long_mode_with_cpuid ; jmp to the end of the code
            .long_mode_not_supported:
            mov si,long_mode_not_supported_msg ; to print the failure message
            call bios_print ; Print an error message and jump to hang
            jmp hang
            .exit_check_long_mode_with_cpuid:

            popa  ;to pop the values of the registers from the stack
            ret
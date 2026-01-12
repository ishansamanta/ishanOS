[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000    ; This MUST match your linker.ld start address

start:
    mov [BOOT_DRIVE], dl    ; BIOS stores boot drive in DL, save it!

    ; Setup stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --- NEW: LOAD KERNEL FROM DISK ---
    mov bx, KERNEL_OFFSET   ; Destination address
    mov dh, 15              ; Number of sectors to read (increase if kernel grows)
    mov dl, [BOOT_DRIVE]
    call disk_load
    ; ----------------------------------

    cli                     ; Disable interrupts for GDT switch
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp CODE_SEG:protected_start

; --- DISK LOAD FUNCTION ---
disk_load:
    push dx
    mov ah, 0x02            ; BIOS read sector function
    mov al, dh              ; Read DH sectors
    mov ch, 0x00            ; Cylinder 0
    mov dh, 0x00            ; Head 0
    mov cl, 0x02            ; Start reading from second sector (after bootloader)
    int 0x13
    jc disk_error           ; Jump if error (Carry Flag set)
    pop dx
    ret

disk_error:
    jmp $                   ; Stay here if disk fails

gdt_start:
gdt_null:
    dq 0
gdt_code:
    dw 0xFFFF               ; Limit
    dw 0x0000               ; Base
    db 0x00                 ; Base
    db 10011010b            ; Access (Notice: no 0x prefix here!)
    db 11001111b            ; Flags
    db 0x00                 ; Base
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00 
    db 10010010b            ; Access for Data (Corrected)
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
BOOT_DRIVE db 0             ; Variable to store drive number

[BITS 32]
protected_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, 0x90000        ; Set up 32-bit stack
    
    call KERNEL_OFFSET      ; JUMP TO THE ADDRESS, not the name!

    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55
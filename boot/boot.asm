[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000    

start:
    mov [BOOT_DRIVE], dl    

    ; Setup stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov bx, KERNEL_OFFSET  
    mov dh, 15              
    mov dl, [BOOT_DRIVE]
    call disk_load
   
    cli                     
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp CODE_SEG:protected_start


disk_load:
    push dx
    mov ah, 0x02           
    mov al, dh              
    mov ch, 0x00           
    mov dh, 0x00            
    mov cl, 0x02           
    int 0x13
    jc disk_error           
    pop dx
    ret

disk_error:
    jmp $                  

gdt_start:
gdt_null:
    dq 0
gdt_code:
    dw 0xFFFF               
    dw 0x0000               
    db 0x00               
    db 10011010b            
    db 11001111b            
    db 0x00                 
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00 
    db 10010010b           
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
BOOT_DRIVE db 0          

[BITS 32]
protected_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, 0x90000        
    
    call KERNEL_OFFSET      

    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55

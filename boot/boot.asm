[BITS 16]
[ORG 0x7C00]

start:
    mov si, buffer
    mov di, buffer

read_key:
    mov ah, 0x00
    int 0x16

    cmp al, 0x08
    je backspace
    cmp al, 0x0D
    je enter

    mov [si], al
    inc si

    mov ah, 0x0E
    int 0x10
    jmp read_key

strcmp:
    push si
    push di
.compare:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .compare
.not_equal:
    pop di
    pop si
    ret                ; ZF is 0
.equal:
    pop di
    pop si
    cmp al, al         ; Force ZF = 1 (match!)
    ret

backspace:
    cmp si, di
    je read_key
    dec si
    mov byte [si], 0
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp read_key

enter:
    mov byte [si], 0
    
    ; Check HELP
    mov si, buffer
    mov di, cmd_help
    call strcmp
    je do_help

    ; Check CLEAR
    mov si, buffer
    mov di, cmd_clear
    call strcmp
    je do_clear

    ; If no match
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov si, msg_unknown
    call print_string
    jmp reset_input

do_help:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov si, msg_help
    call print_string
    jmp reset_input

do_clear:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov si, buffer     ; Reset pointer
    jmp read_key

reset_input:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov si, buffer
    jmp read_key

print_string:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

cmd_help db 'help', 0
cmd_clear db 'clear', 0
msg_help db 'Commands: help clear', 0
msg_unknown db 'Unknown command', 0

buffer times 64 db 0

times 510 - ($ - $$) db 0
dw 0xAA55
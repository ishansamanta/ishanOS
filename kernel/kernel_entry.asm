[bits 32]
[extern _kernel_main] ; Tells NASM that the 'door' is in another file (kernel.c)
                      ; Note the underscore! MinGW/Windows GCC needs it.

_start:
    call _kernel_main ; Jump into your C code
    jmp $             ; If the C code ever finishes, stay here forever
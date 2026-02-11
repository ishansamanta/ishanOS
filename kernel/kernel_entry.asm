[bits 32]
[extern _kernel_main] 
                     

_start:
    call _kernel_main 
    jmp $             

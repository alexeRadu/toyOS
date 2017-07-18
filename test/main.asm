use16
org 0x7C00

    ; You should do further initializations here
    ; like setup the stack and segment registers.

    ; Load stage 2 to memory.
    mov ah, 0x02
    ; Number of sectors to read.
    mov al, 1
    ; This may not be necessary as many BIOS set it up as an initial state.
    mov dl, 0x80
    ; Cylinder number.
    mov ch, 0
    ; Head number.
    mov dh, 0
    ; Starting sector number. 2 because 1 was already loaded.
    mov cl, 2
    ; Where to load to.
    mov bx, stage2
    int 0x13

    jmp stage2

    ; Magic bytes.    
    times ((0x200 - 2) - ($ - $$)) db 0x00
    dw 0xAA55

stage2:

    ; Print 'a'.
    mov ax, 0x0E61
    int 0x10

    cli
    hlt

    ; Pad image to multiple of 512 bytes.
    times ((0x400) - ($ - $$)) db 0x00

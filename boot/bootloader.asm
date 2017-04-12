	; This is code is part of the boot sector that is going to be loaded
	; at address 0x7c00. This is the first code that the CPU will run after
	; BIOS when it is still in 16 bit real-mode. Therefore the compiler
	; needs to know that all the instructions are 16 bits wide.
	bits 16

	; This is the start of the bootloader; it is the point of entry for the
	; bootloader.
start:
	; Before we do anything else we disable (or clear) the interrupts. We
	; enable them after the new interrupt table (IDT) is set.
	cli

	; We setup the stack: it ends at 0xa000 and has a size of 1KB. The way
	; we code it is to set the stack segment (ss) at the bottom limit and
	; the base pointer (bp) to zero. Then the stack pointer is set up to
	; have the value of the size of the stack, in our case 1KB. This
	; approach creates clarity and offers the posibility to quickly change
	; the stack parameters by changing only one parameter at a time:
	; - the start memory location: whe change only ss
	; - the size of the stack: we change the stack pointer
	mov ax, 0x0a00
	mov ss, ax
	mov bp, 0x0000
	mov sp, 0x0400

	; The screen may contain some printed information (maybe from BIOS).
	; Before moving forward we clear the screen to allow fresh messages
	; to appear on the screen in an orderly fashion.
	call cls

	; Print welcome message.
	; The welcome message is stored in the variable "welcome_msg". The
	; address of this variable is computed by the compiler as being relative
	; to the start of the files (which is address 0x0000). When this code is
	; loaded into memory the "welcome_msg" will be placed relative to the
	; start of the boot sector, which is 0x7c00 and any access of the
	; address [welcome_msg] will yeald an incorrect value. To solve this
	; usually one can include the directive "org 0x7c00" at the beginning
	; at the file. This isn't possible here because the NASM compiler
	; that accept it unless for binary output. We want ELF output because
	; we want to use it for debugging.

	; Our solution consists of setting the data segment to 0x0000 and add
	; the offset 0f 0x7c00 to si to get the actual address of the string.
	; This will eliminate extra steps required for saving and restoring
	; the data segment when it should be changed for memcpy. Additionally
	; es is set to 0x0000 as well.
	mov ax, 0x0000
	mov ds, ax
	mov es, ax

	; The print routing accepts the string to be printed in the ds:si
	; registers.
	mov si, welcome_msg
	add si, 0x7c00
	call print

	; We need to load the kernel into memory above the limit of 1 MB which
	; is not possible while in real mode. One solution would be to read one
	; sector, switch to protected mode and copy it to the final destination
	; and repeat the process for all the other sectors. This is difficult
	; and it may lead to code that extends beyond the first sector. Instead
	; we have opted to switch to the "bit unreal mode" that enables to write
	; 16 bit code but access the whole memory.
	call switch_to_umode

	mov ax, 0x7c00
	mov ds, ax
	mov ax, 0x0000
	mov ds, ax

	; Setup the buffer that will contain the data read from disk. This will
	; be located after the boot sector and it will be 1 sector long.
	mov bx, 0x7e00

	; Initial setup of parameters.
	; Read 1 sector starting from CHS (0, 0, 1).
	mov al, 1
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x02

	; Read from disk 0 = floppy.
	mov dl, 0x00

read_sector:
	; Read disk sector.
	call read_disk

	; If return value (ah) is not zero then an error has happened. Print
	; error message and exit.
	cmp ah, 0x00
	jne kernel_load_err

	; If no error copy sector to kernel memory location.
	mov esi, 0x00007e00
	mov edi, [0x7c00 + kern_load_addr]

	mov cx, 0x10
	call memcpy

	; Update kernel sector count variable. If zero exit loading kernel.
	mov al, [0x7c00 + kern_sect_count]
	dec al
	cmp al, 0x00
	je kernel_load_ok
	mov [0x7c00 + kern_sect_count], al

	; Update CHS for the next sector.
	; TODO: implement update_chs function
	mov al, 1
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x03

	jmp kernel_load_ok

kernel_load_err:
	mov si, kern_load_err_msg
	add si, 0x7c00
	call print

kernel_load_ok:
	mov si, kern_load_msg
	add si, 0x7c00
	call print

infinite_loop:
	; Catch the CPU in an infinite loop
	jmp $


	%include "screen.asm"
	%include "disk.asm"
	%include "modes.asm"
	%include "memory.asm"

	; Global definitions
	welcome_msg 	   	db 'Starting Operating System', 0x0a, 0x0d, 0
	kern_load_err_msg  	db 'Error loading kernel', 0x0a, 0x0d, 0
	kern_load_msg 		db 'Kernel loaded', 0x0a, 0x0d, 0

	kern_sect_count db 2
	kern_load_addr	dd 0x00200000


; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

; Padd with 0xff another sector
	times 1024 db 0xfe

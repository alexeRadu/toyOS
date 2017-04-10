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

	; Our solution consists of setting the data segment to 0x07c0 which will
	; generate the address 0x07c0:[welcome_msg] for the welcome_msg string.
	mov ax, 0x07c0
	mov ds, ax

	; The print routing accepts the string to be printed in the ds:si
	; registers.
	mov si, welcome_msg
	call print

	; We need to load the kernel into memory above the limit of 1 MB which
	; is not possible while in real mode. One solution would be to read one
	; sector, switch to protected mode and copy it to the final destination
	; and repeat the process for all the other sectors. This is difficult
	; and it may lead to code that extends beyond the first sector. Instead
	; we have opted to switch to the "bit unreal mode" that enables to write
	; 16 bit code but access the whole memory.
	call switch_to_umode


	mov bx, 0x0f01
	mov eax, 0x00200000
	mov word [ds:eax], bx
	add eax, 2
	mov word [ds:eax], bx
	add eax, 2
	mov word [ds:eax], bx
	add eax, 2
	mov word [ds:eax], bx
	add eax, 2
	mov word [ds:eax], bx

	mov ax, 0x07c0				; copy additional sectors after the boot sector
	mov es, ax				; es points to the same data segment
	mov bx, 0x200				; bx points after boot sector

	mov al, [kern_sect_count]
	mov ch, 0x00				; cylinder 0
	mov dh, 0x00				; head 0
	mov cl, 0x02				; sector 1 (after the boot sector)
	mov dl, 0x00				; select floppy 0

	call read_disk

	cmp ah, 0
	jne .err_sect_load
	mov si, sect_load_msg
	call print

	jmp infinite_loop

.err_sect_load:
	mov si, err_sect_load_msg
	call print

infinite_loop:
	; Catch the CPU in an infinite loop
	jmp $


	%include "screen.asm"
	%include "disk.asm"
	%include "modes.asm"

; Global definitions
	welcome_msg db 'Starting Operating System', 0x0a, 0x0d, 0
	err_sect_load_msg db 'Error loading sector(s)', 0x0a, 0x0d, 0
	sect_load_msg db 'Sector(s) successfully loaded', 0x0a, 0x0d, 0
	kern_sect_count db 2


; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

; Padd with 0xff another sector
	times 1024 db 0xfe

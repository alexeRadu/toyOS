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

	; switch to big unreal mode to be able to copy the additional kernel sectors to
	; a location in memory above the 1MB limit
sw_unreal:
	push ds

	lgdt [gdt_descriptor]

	mov eax, cr0
	or al, 1
	mov cr0, eax

	jmp $+2

	bits 32

	mov bx, 0x08
	mov ds, bx

	and al, 0xfe
	mov cr0, eax

	bits 16

	pop ds

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

	call load_sect

	cmp ah, 0
	jne .err_sect_load
	mov si, sect_load_msg
	call print
	jmp .set_gdt

.err_sect_load:
	mov si, err_sect_load_msg
	call print

.set_gdt:
	lgdt [gdt_descriptor]

	mov eax, cr0				; To make the switch to protected mode, we set
	or eax, 0x01				; the first bit of CR0, a control register
	mov cr0, eax				; Update the control register

	jmp loop

loop:
	jmp $					; Catch the CPI in an infinite loop

; Load sector(s) to memory
; al - number of sectors
; ch - cylinder number (0..79)
; cl - sector number (1..18)
; dh - head number (0..1)
; es:bx - data buffer
; return ah - 0 if successfull
load_sect:
	pusha

	mov ah, 0x02				; read disk sector to memory interrupt
	mov dl, 0x00				; floppy 0
	int 0x13

	mov [_load_sect_ret], ah		; save return value - it will be use to test for errors
	popa
	mov ah, [_load_sect_ret]		; restore return value
	ret

	_load_sect_ret db 0

; GDT - Global Descriptor Table
; It described the basic flat model: 2 segments (one for code, one for data)
; overlapped and spanning the whole 4GB of memory
gdt_start:

gdt_null:					; the mandatory null descriptor
	dd 0x0					; the first null double-word (dd)
	dd 0x0					; the second null double-word

gdt_code:					; the code segment descriptor
	; base = 0x00, limit = 0xfffff
	; 1st flags: (present) 1 (privilege)00 (descriptor type) 1 -> 1001b (0x9)
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b (0xa)
	; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b (0xc)
	dw 0xffff		; Limit (bits 0-15)
	dw 0x00			; Base (bits 0-15)
	db 0x00			; Base (bits 16-23)
	db 0x9a			; 1st flags, type flags
	db 0xcf			; 2nd flags, Limit (bits 16-19)
	db 0x00			; Base (bits 24-31)

gdt_data:					; the data segment descriptor
	; Same as code except for the type flags:
	; type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b (0x2)
	dw 0xffff		; Limit (bits 0-15)
	dw 0x00			; Base (bits 0-15)
	db 0x00			; Base (bits 16-23)
	db 0x92			; 1st flags, type flags
	db 0xcf			; 2nd flags, Limit (bits 16-19)
	db 0x00			; Base (bits 24-31)

gdt_end:

; GDT descriptor
gdt_descriptor:
	dw gdt_end - gdt_start - 1		; the size of the GDT (2 bytes)
	dd gdt_start				; start of the GDT (4 bytes)


	%include "screen.asm"

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

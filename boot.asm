	bits 16
start:
	cli					; Disable interrupts

	mov ax, 0x07c0				; Set data segment to point to the current
	mov ds, ax				; sector; this is usefull for pointers to
						; string message that are stored in si:ds

	mov ax, 0x0a00				; The stach should start at 0xa000 and should
	mov ss, ax				; have a size of 1KB
	mov bp, 0x0000
	mov sp, 0x0400

	call cls				; clear the screen

	mov si, message				; This way ds:si will point to message
	call print				; Print message to screen

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

; print a string to console
; si	- [in] string to be printed
print:
	pusha					; Save registers to be used
	mov ah, 0x0e				; int 10h 'print char' function

.print_loop:
	lodsb					; Get character from string
	cmp al, 0
	je .print_end				; If char is 0, end of string
	int 0x10				; Otherwise print it
	jmp .print_loop

.print_end:
	popa					; Restore contents of registers
	ret					; Return from print

; clear screen
cls:
	pusha

	mov ah, 0x06				; select scroll up page
	mov al, 0x00				; clear entire window
	mov bh, 0x0f				; white on black background
	mov ch, 0x00				;
	mov cl, 0x00				; start at (0, 0) = top left
	mov dh, 25				;
	mov dl, 80				; end at (40, 25) = bottom right
	int 10h

	mov ah, 0x02				; set cursor position
	mov dh, 0x00
	mov dl, 0x00				; at (0, 0)
	mov bh, 0x00				; use page 0
	int 0x10

	popa
	ret

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

; Global definitions
	message db 'Starting Operating System', 0x0a, 0x0d, 0
	err_sect_load_msg db 'Error loading sector(s)', 0x0a, 0x0d, 0
	sect_load_msg db 'Sector(s) successfully loaded', 0x0a, 0x0d, 0
	kern_sect_count db 2


; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

; Padd with 0xff another sector
	times 1024 db 0xfe

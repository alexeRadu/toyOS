	BITS 16

start:
	cli					; Disable interrupts

	mov ax, 0x07c0				; Set data segment to be the same as text segment
	mov ds, ax
	mov es, ax				; Set extra segment

	add ax, 0x400				; Leave two sectors empty
	mov ss, ax				; Set stack segment to start at exactly after boot sector
	mov sp, 0x1000				; Stack is 4 KB

	call cls				; clear the screen

	mov si, message				; This way ds:si will point to message
	call print				; Print message to screen

	mov al, 0x01				; copy one sector
	mov ch, 0x00				; cylinder 0
	mov dh, 0x00				; head 0
	mov cl, 0x02				; sector 1 (after the boot sector)
	mov bx, 0x200				; copy in memory just after the first sector
	call load_sect

	cmp ah, 0
	jne .err_sect_load
	mov si, sect_load_msg
	call print
	jmp .loop

.err_sect_load:
	mov si, err_sect_load_msg
	call print

.loop:
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

	mov [_load_sect_ret], ah
	popa
	mov ah, [_load_sect_ret]
	ret

	_load_sect_ret db 0

; Global definitions
	message db 'Starting Operating System', 0x0a, 0x0d, 0
	err_sect_load_msg db 'Error loading sector', 0x0a, 0x0d, 0
	sect_load_msg db 'Sector successfully loaded', 0x0a, 0x0d, 0



; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

; Padd with 0xff another sector
	times 512 db 0xfe

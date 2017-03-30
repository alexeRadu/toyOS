	BITS 16

start:
	cli					; Disable interrupts

	mov ax, 0x07c0				; Set data segment to be the same as text segment
	mov ds, ax

	add ax, 0x200				;
	mov ss, ax				; Set stack segment to start at exactly after boot sector
	mov sp, 0x1000				; Stack is 4 KB

	mov si, message				; This way ds:si will point to message
	call print				; Print message to screen

	jmp $					; Catch the CPI in an infinite loop

	message db 'ToyOS - the new operating system from Alexe Radu', 0

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

	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

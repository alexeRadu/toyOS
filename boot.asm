	BITS 16

start:
	cli					; Disable interrupts

	mov ax, 0x07c0				; Set data segment to be the same as text segment
	mov ds, ax

	add ax, 0x200				;
	mov ss, ax				; Set stack segment to start at exactly after boot sector
	mov sp, 0x1000				; Stack is 4 KB

	call cls				; clear the screen

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

; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

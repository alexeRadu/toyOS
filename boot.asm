	BITS 16

start:
	cli					; Disable interrupts

	mov ax, 0x07c0				; Set data segment to be the same as text segment
	mov ds, ax

	mov si, message				; This way ds:si will point to message
	call pr_str				; Print message to screen

	jmp $					; Catch the CPI in an infinite loop

	message db 'ToyOS - the new operating system from Alexe Radu', 0

pr_str:
	mov ah, 0Eh

.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	ret

	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

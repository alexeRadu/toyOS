	BITS 16

start:
	cli

	mov ax, 0x07c0
	mov ds, ax

	mov si, message
	call pr_str

	jmp $			; infinite loop

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

	times 510 - ($ - $$) db 0
	db 0x55
	db 0xAA

bits 32

global start
start:
	; Set the stack for the kernel.
	mov esp, sys_stack

	; Infinite loop.
	jmp $

	times 512 - ($ - $$) db 0

; BSS section. This is where the uninitialized data goes.
SECTION .bss
	resb 8192

; This is the stack for the kernel.
sys_stack:

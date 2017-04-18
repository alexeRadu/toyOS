bits 32

SECTION .text

global start
extern kmain

start:
	; Set the stack for the kernel.
	mov esp, sys_stack

	; Jump to kmain function.
	call kmain

; BSS section. This is where the uninitialized data goes.
SECTION .bss
	resb 8192

; This is the stack for the kernel.
sys_stack:

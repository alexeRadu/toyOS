.code16
.section .bootsector.txt
.globl _start;
.extern main

_start:
	mov $0x0a00, %ax
	mov %ax, %ss
	mov $0x0000, %bp
	mov $0x0400, %sp
	
	call main

_loop:
	jmp _loop

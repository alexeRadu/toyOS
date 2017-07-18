.code16
.globl _start;
.extern boot
.section .text

_start:
	jmp _start

_loop:
	jmp _loop

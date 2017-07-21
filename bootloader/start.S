.code16
.globl _start
.extern boot
.section .text

_start:
	jmp 	boot

_loop:
	jmp	_loop

; Filename: screen.asm
; Author: Radu-Andrei Alexe
; Date: 09.04.2017

; This file contains functions related to screen manipulation: printing,
; clearing, etc. It uses the BIOS interrupts and are intended to be used for any
; code running in real 16 bit mode.
bits 16


; ------------------------------------------------------------------------------
; Function: 	print
; Description: 	print a string to the screen
; @param ds:si	input string. Each string should end with the sequence of bytes
;	"0x0a, 0x0d, 0x00":
;	- 0x0a - new line/ line feed - move the cursor on a new line
;	- 0x0d - carriage return - move the cursor at the beginning of the
;		current line
;	- 0x00 - null - signals the end of the line
; ------------------------------------------------------------------------------

print:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	pusha

	; We print a string to the screen by printing every character of the
	; defined string. We do this by selecting the function 0x0e for interupt
	; 0x10.
	mov ah, 0x0e


 .print_loop:
	; The loop loads a byte from ds:si to al and compares the just-loaded
	; byte to 0x00 (end of string).
	lodsb
	cmp al, 0x00

	; If the end of the string was detected jump to the end (a.k.a return).
	je .print_end

	; If any other character was found print it to the screen (or do any
	; any required action).
	int 0x10

	; Continue loop for the next character.
	jmp .print_loop

 .print_end:
	popa
	ret


; ------------------------------------------------------------------------------
; Function: 	cls (clear screen)
; Description:	clear the screen. This is achieved by scrolling up the entire
;	window and re-writing the blank lines at the bottom of the screen. New
;	text will be white on black background. At the end the cursor will be
;	positioned at (0, 0).
; ------------------------------------------------------------------------------

cls:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	pusha

	; Scrolling the page up functionality is achieved by setting register
	; ah to value 0x06.
	mov ah, 0x06

	; This interrupt enables scrolling up only part of the whole screen in
	; the form of a rectangle which is named a window. The coordinates of
	; window are set in the following way (see image):
	; - (ch, cl) - row, column of windows's upper left corner
	; - (dh, dl) - row, column of windows's lower right corner
	;
	; (ch, cl)
	;	+-----------------------------------------------+
	;	|						|
	;	|						|
	;	|						|
	;	|						|
	;	+-----------------------------------------------+
	;							(dh, dl)
	;
	; In our case the window starts at (0, 0) and ends at (25, 80)
	; effectively encompasing all of the screen.
	mov ch, 0
	mov cl, 0
	mov dh, 25
	mov dl, 80

	; Register al contains the number of lines that the window should be
	; scrolled down with. Setting it to zero means clearing the entire
	; window.
	mov al, 0x00

	; The new (blank) lines at the bottom of the screen are repainted
	; using the attribute stored in register bh. It's msb contains the
	; background color (0x0 - black), and it's lsb contains the foreground
	; color (0xf - white).
	mov bh, 0x0f

	int 10h

	; Clearing the screen does not change the cursor position. Therefore,
	; before returning from this routine, we first position the cursor
	; at (0, 0) on the screen.
	mov dh, 0
	mov dl, 0
	mov bh, 0
	call goto_xy

	popa
	ret


; ------------------------------------------------------------------------------
; Function: 	goto_xy
; Description:	goto position (x, y) on screen
; @param dh	row
; @param dl	column
; @param bh	page number (0..7)
; ------------------------------------------------------------------------------

goto_xy:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	pusha

	; We set the cursor position by selecting function 0x02 for the
	; interrupt 0x10.
	mov ah, 0x02

	int 0x10

	popa
	ret

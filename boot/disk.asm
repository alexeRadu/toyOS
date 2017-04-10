; Filename: disk.asm
; Author: Radu-Andrei Alexe
; Date: 10.04.2017

; This file contains functions related to loading sectors of data from disk to
; memory.These functions use the BIOS interrupts and are intended to be used for
; any code running in real 16 bit mode.
bits 16

; ------------------------------------------------------------------------------
; Function: 	read_disk
; Description:	read disk sectors into memory
; @param al	number of sectors to read/write (must be nonzero)
; @param ch	cylinder number (0..79)
; @param cl	sector number (1..18)
; @param dh	head number (0..1)
; @param dl	drive number (0..3)
; @param es:bx	memory location where sector data is to be copied
; @return ah	status (0 if successful)
;	  al	number of sectors actually read
;	  cf	flag set on error
; ------------------------------------------------------------------------------

read_disk:
	; Select corresponding function for the interrupt 0x13
	mov ah, 0x02
	int 0x13

	; Here there is no need to store the register values on the stack and
	; pop them at the end because almost all the registers are used. Those
	; overriden by the interrupt should be returned as is.
	ret

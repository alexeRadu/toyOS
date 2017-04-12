; Filename: memory.asm
; Author: Radu-Andrei Alexe
; Date: 12.04.2017

; This file contains functions related to memory manipulation. We start off in
; real mode.
bits 16

; ------------------------------------------------------------------------------
; Function: 	memcpy
; Description:	copy a number of bytes from source to destination
; @param ds:si	source
; @param ds:di	destination
; @param cx	number of bytes to copy
; ------------------------------------------------------------------------------

memcpy:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	pusha

 .write_byte:
 	mov al, [ds:esi]
 	mov [ds:edi], al
 	inc esi
 	inc edi
 	loop .write_byte

	popa
	ret
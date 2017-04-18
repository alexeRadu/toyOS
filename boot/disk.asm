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
; @param ch	cylinder number (0..79)
; @param cl	sector number (1..18)
; @param dh	head number (0..1)
; @param es:bx	memory location where sector data is to be copied
; @return ah	status (0 if successful)
;	  al	number of sectors actually read
;	  cf	flag set on error
; ------------------------------------------------------------------------------

read_disk_sector:
	; Read only one sector from the disk. For now, for simplicity, we read
	; only one sector. Other variants may use a different count of sectors
	; read.
	mov al, 0x01

	; For now we read the disk 0. Depending on the moterboard settings this
	; may need to change to target other disks (cd-rom).
	mov dl, 0x00

	; Select corresponding function for the interrupt 0x13.
	mov ah, 0x02
	int 0x13

	; Here there is no need to store the register values on the stack and
	; pop them at the end because almost all the registers are used. Those
	; overriden by the interrupt should be returned as is.
	ret


; ------------------------------------------------------------------------------
; Function: 	update_chs
; Description:	Update CHS (cylinder, head, sector) number by a number of
;	sectors
; @param ch	cylinder number (0..79)
; @param dh	head number (0..1)
; @param cl	sector number (1..18)
; @param al	number of sectors to incremeant CHS by
; @return ch	the updated cylinder number
;	  dh	the updated head number
;	  cl	the updated sector number
; ------------------------------------------------------------------------------

update_chs:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	push ax

 .chs_start:
	cmp al, 0x0000
	je .chs_end
	dec al

	inc cl
	cmp cl, 19
	jne .chs_start
	mov cl, 1

	inc dh
	cmp dh, 2
	jne .chs_start
	mov dh, 0

	inc ch

 .chs_end:
	call write_chs

 	pop ax
	ret


; ------------------------------------------------------------------------------
; Function: 	read_chs
; Description:	Read CHS (cylinder, head, sector) number from memory.
; @return ch	the cylinder number
;	  dh	the head number
;	  cl	the sector number
; ------------------------------------------------------------------------------

read_chs:
	mov cl, [sector + 0x7c00]
	mov dh, [head + 0x7c00]
	mov ch, [cylinder + 0x7c00]
	ret


; ------------------------------------------------------------------------------
; Function: 	write_chs
; Description:	Write CHS (cylinder, head, sector) number to memory.
; @return ch	the cylinder number
;	  dh	the head number
;	  cl	the sector number
; ------------------------------------------------------------------------------

write_chs:
	mov [sector + 0x7c00], cl
	mov [head + 0x7c00], dh
	mov [cylinder + 0x7c00], ch
	ret


; ------------------------------------------------------------------------------
; Global Variables
; ------------------------------------------------------------------------------
	sector		db 2
	head		db 0
	cylinder	db 0
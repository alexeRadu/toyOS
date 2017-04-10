; Filename: modes.asm
; Author: Radu-Andrei Alexe
; Date: 10.04.2017

; This file contains functions related to switching back and forth to different
; modes (protected, big-unreal). We first start in real 16 bit mode.
bits 16


; ------------------------------------------------------------------------------
; Function: 	switch_to_umode
; Description: 	switch to the big unreal mode. This mode allows to access more
;	than 1 MB of memory, limit imposed by the 16 bit real mode. This mode is
;	achieved by switching first to protected mode and setting the required
;	segment registers to point to one of the global descriptors. This has
;	the effect of setting the segment descriptor cache register to the value
;	written from the GDT table. On switch back to real mode the offset of
;	the segment descriptor cache register retains it's value allowing any
;	instruction that uses the corresponding segment register to access
;	the memory whitin the limit imposed by the descriptor.
; ------------------------------------------------------------------------------

switch_to_umode:
	; The caller expects that all the registers (except the ones that
	; contain return values) have the same value after returning from
	; routine as before entering the routine. To this end we save all the
	; registers on stack before executing any instruction and restore them
	; at the end of the routine.
	pusha

	; Load the GDT table.
	lgdt [gdt_descriptor]

	; Switch to protected mode by setting the pmode bit from the cr0
	; register while making sure that the rest of the bits are left
	; unchanged.
	mov eax, cr0
	or al, 1
	mov cr0, eax

	; This instruction forces the CPU to flush its cache of pre-fetched and
	; real mode decoded instructions which can cause problems.
	jmp $ + 2

	; Now we are in 32 bit protected mode. This must be signaled to the
	; compiler.
	bits 32

	; Set the data segment to point to the data descriptor from the GDT
	; table. This will allow that any combination of memory addressing that
	; uses either ds or es to point outside of the 1 MB limit.
	mov bx, 0x10
	mov ds, bx

	; Switch back to real mode by resetting the pmode bit.
	and al, 0xfe
	mov cr0, eax

	; We are again in the 16 bit real mode.
	bits 16

	popa
	ret

; ------------------------------------------------------------------------------
; Function: 	switch_to_pmode
; Description: 	switch to the protected mode.
; ------------------------------------------------------------------------------

switch_to_pmode:
	; Load the GDT table.
	lgdt [gdt_descriptor]

	; Switch to protected mode by setting the pmode bit from the cr0
	; register while making sure that the rest of the bits are left
	; unchanged.
	mov eax, cr0
	or al, 1
	mov cr0, eax

	; This instruction forces the CPU to flush its cache of pre-fetched and
	; real mode decoded instructions which can cause problems.
	jmp $ + 2


; ------------------------------------------------------------------------------
; Table: 	Global Descriptor Table (GDT)
; Description: 	a list/table of 32 bit descriptors that provide a mapping of the
;	memory into segments. This table describes the basic flat model:
;	- one 32 GB code segment spanning the whole
;	- one 32 GB data segment spanning the whole
;	This table is used for entering both the protected mode and big-unreal
; mode.
; ------------------------------------------------------------------------------

gdt_start:

	; The first entry in the table is a mandatory null descriptor
 gdt_null:
	dd 0x0
	dd 0x0

	; This is the code segment descriptor. It is 32 GB in size, spanning all
	; available memory and has the following values:
	; 	base 		0x00
	;	limit 		0xfffff
	; 	1st flags 	1001b (0x9)
	;		(present) 1 (privilege)00 (descriptor type) 1
	; 	type flags	1010b (0xa)
	;		(code)1 (conforming)0 (readable)1 (accessed)0
	;	2nd flags 	1100b (0xc)
	;		(granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0
 gdt_code:
	dw 0xffff		; Limit (bits 0-15)
	dw 0x00			; Base (bits 0-15)
	db 0x00			; Base (bits 16-23)
	db 0x9a			; 1st flags, type flags
	db 0xcf			; 2nd flags, Limit (bits 16-19)
	db 0x00			; Base (bits 24-31)

	; This is the data descriptor which is identic to the code segment
	; except for the type flags: 0010b (0x2)
	; 	(code)0 (expand down)0 (writable)1 (accessed)0
 gdt_data:
	dw 0xffff		; Limit (bits 0-15)
	dw 0x00			; Base (bits 0-15)
	db 0x00			; Base (bits 16-23)
	db 0x92			; 1st flags, type flags
	db 0xcf			; 2nd flags, Limit (bits 16-19)
	db 0x00			; Base (bits 24-31)

 gdt_end:


; ------------------------------------------------------------------------------
; Name: 	GDT descriptor
; Description: 	this is a structure in memory that describes the GDT table. The
;	first two bytes represent the size of the GDT (minus 1) and the next
;	four bytes represent the start of the GDT table.
; ------------------------------------------------------------------------------

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

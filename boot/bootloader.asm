	; This is code is part of the boot sector that is going to be loaded
	; at address 0x7c00. This is the first code that the CPU will run after
	; BIOS when it is still in 16 bit real-mode. Therefore the compiler
	; needs to know that all the instructions are 16 bits wide.
	bits 16

	; This is the start of the bootloader; it is the point of entry for the
	; bootloader.
start:
	; Before we do anything else we disable (or clear) the interrupts. We
	; enable them after the new interrupt table (IDT) is set.
	cli

	; We setup the stack: it ends at 0xa000 and has a size of 1KB. The way
	; we code it is to set the stack segment (ss) at the bottom limit and
	; the base pointer (bp) to zero. Then the stack pointer is set up to
	; have the value of the size of the stack, in our case 1KB. This
	; approach creates clarity and offers the posibility to quickly change
	; the stack parameters by changing only one parameter at a time:
	; - the start memory location: whe change only ss
	; - the size of the stack: we change the stack pointer
	mov ax, 0x0a00
	mov ss, ax
	mov bp, 0x0000
	mov sp, 0x0400

	; The screen may contain some printed information (maybe from BIOS).
	; Before moving forward we clear the screen to allow fresh messages
	; to appear on the screen in an orderly fashion.
	call cls

	; Print welcome message.
	; The welcome message is stored in the variable "welcome_msg". The
	; address of this variable is computed by the compiler as being relative
	; to the start of the files (which is address 0x0000). When this code is
	; loaded into memory the "welcome_msg" will be placed relative to the
	; start of the boot sector, which is 0x7c00 and any access of the
	; address [welcome_msg] will yeald an incorrect value. To solve this
	; usually one can include the directive "org 0x7c00" at the beginning
	; at the file. This isn't possible here because the NASM compiler
	; that accept it unless for binary output. We want ELF output because
	; we want to use it for debugging.

	; Our solution consists of setting the data segment to 0x0000 and add
	; the offset of 0x7c00 to si to get the actual address of the string.
	; This will eliminate extra steps required for saving and restoring
	; the data segment when it should be changed for memcpy. Additionally
	; es is set to 0x0000 as well.
	mov ax, 0x0000
	mov ds, ax
	mov es, ax

	; The print routing accepts the string to be printed in the ds:si
	; registers. Here I have loaded the address of the welcoming message
	; into the si to which I have added 0x7c00. This is because the compiler
	; sets the address of the variable 'welcome_msg' relative to the start
	; of the file (which is as far as the compiler is concerned at 0x0000).
	; It does not know that this sector is going to be loaded at 0x7c00 so
	; we add the extra address increment.
	mov si, welcome_msg + 0x7c00
	call print

	; We need to load the kernel into memory above the limit of 1 MB which
	; is not possible while in real mode. One solution would be to read one
	; sector, switch to protected mode, copy it to the final destination,
	; switch back to real mode and repeat the process for all the other
	; sectors. There are two problems with this approach:
	;	1. it is difficult to implement / understand
	;	2. it may lead to longer code that may extend beyond the first
	; sector of code that we have available. Instead we have opted to switch
	; to the "bit unreal mode" that enables code in 16 bitmode but at the
	; same time pointers on 32 bits, which enables access to the whole 4 GB
	; of memory ram.
	call switch_to_umode

	; The next section is dedicated to copying the kernel to the desired
	; memory location. Therefore we set the source and destination
	; registers. Both contain values loaded from variables. The source
	; represents the location in memory where the sector from disk is to
	; be first loaded; the destination is the final kernel memory location.
	mov esi, [kern_sect_addr + 0x7c00]
	mov edi, [kern_load_addr + 0x7c00]

	; Loading the kernel to the target location is an iterative process
	; where in each step we read a sector from disk to an intermediate
	; location, and then 'memcpy' it back to the final kernel location
	; in memory. This is because copying a sector from disk to memory
	; uses the BIOS interrupt which uses 16 bit addressing mode. 'Memcpy'
	; instead can address (via unreal mode) the whole 4 GB of memory.
read_sector:
	; Read CHS (cylinder, head, sector) number from memory. We keep these
	; values in memory because it easier and creates a cleaner code compared
	; to saving them on the stack.
	call read_chs

	; Read one sector from the disk to the intermmediate memory location.
	mov bx, si
	call read_disk_sector

	; If return value (ah) is not zero then an error has happened. Print
	; error message and exit.
	cmp ah, 0x00
	jne kernel_load_err

	; If there is no error while reading the sector update the CHS values
	; to point to the next sector on disk. This function also saves them
	; as variables so that next time they can be read.
	call update_chs

	; The number of segments copied is returned in al; left shifting this
	; value by 9 mean multiplying the number of segemnts with the length of
	; the segment (512 bytes) resulting the number of bytes to be copied.
	; This value is passed as a parameter to memcpy (cx). After the segment
	; is copied we update the destination pointer (edi) by the amount
	; copied.
	xor ecx, ecx
	mov cl, al
	shl cx, 0x09
	call memcpy
	add edi, ecx

	; The last thing in this loop is to decrement the number of kernel
	; sectors to be loaded in memory and test this value against zero.
	mov ax, [kern_sect_count + 0x7c00]
	dec ax
	mov [kern_sect_count + 0x7c00], ax

	; If it reached zero then continue with the rest of the bootloader.
	; Else do another loop.
	cmp ax, 0x00
	je kernel_load_ok
	jmp read_sector

kernel_load_err:
	mov si, kern_load_err_msg + 0x7c00
	call print
	jmp infinite_loop

kernel_load_ok:
	mov si, kern_load_msg + 0x7c00
	call print

load_gdt:
	mov ebx, [kern_load_addr + 0x7c00]
	jmp switch_to_pmode

infinite_loop:
	; Catch the CPU in an infinite loop
	jmp $


	%include "screen.asm"
	%include "disk.asm"
	%include "modes.asm"
	%include "memory.asm"

	; Global definitions
	welcome_msg 	   	db 'Starting Operating System', 0x0a, 0x0d, 0
	kern_load_err_msg  	db 'Error loading kernel', 0x0a, 0x0d, 0
	kern_load_msg 		db 'Kernel loaded', 0x0a, 0x0d, 0

	kern_sect_count dw 1
	kern_load_addr	dd 0x00200000
	kern_sect_addr	dd 0x00007e00


; End of the files
	times 510 - ($ - $$) db 0		; Pad remainder of boot sector with 0s
	dw 0xAA55				; The standard PC boot signature

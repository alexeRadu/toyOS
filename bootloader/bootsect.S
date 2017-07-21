.code16

	jmp _boot

data:
	.byte	0x01	/* number of sectors to read */
	.byte 	0x00	/* cylinder */
	.byte 	0x02	/* sector */
	.byte	0x00	/* head */
	.byte	0x00	/* drive */
err_msg:
	.ascii	"Error loading second stage bootloader\x00"

_boot:
	/*
	 * Setup the stack.
	 * The stack starts below the bootsector (0x7c00) and grows downwards
	 * up to 0x0500, which is the end of the BIOS DATA.
	 */
	movw	$0x0050, %ax
	movw	%ax, %ss
	movw	$0x0000, %bp
	movw	$0x7700, %sp

	/* set DS, ES to point to the current sector */
	movw	$0x07c0, %ax
	movw	%ax, %ds

	/* 
	 * Load the second stage bootloader into memory starting from 0x7e00,
	 * right after the bootsector.
	 */
	movw	$data, %si
	mov	(%si), %al
	mov	1(%si), %ch
	mov	2(%si), %cl
	mov	3(%si), %dh
	mov	4(%si), %dl
	movw	$0x7e00, %bx
	mov	$0x02, %ah
	int	$0x13

	/* In case of error print message */
	cmp	$0x00, %ah
	jne	_pr_err

	/* Else goto _start */
	movw	$0x7e00, %cx
	jmp	*%cx

_pr_err:
	mov	$0x0e, %ah
	movw	$err_msg, %si
_putch:
	mov	(%si), %al
	cmp	$0x00, %al
	je	_loop
	int	$0x10
	inc	%si
	jmp	_putch

_loop:
	jmp	_loop

/* bootsector signature */
.org 0x1fe
.word 0xaa55

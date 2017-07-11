.code16
.section .bootsector.txt
.globl compute_chs

compute_chs:
	push %ax

 .chs_start:
	cmp $0,%al
	je .chs_end
	dec %al

	inc %cl
	cmp $19,%cl
	jne .chs_start
	mov $1, %cl

	inc %dh
	cmp $2,%dh
	jne .chs_start
	mov $0, %dh

	inc %ch

 .chs_end:
 	pop %ax
	ret

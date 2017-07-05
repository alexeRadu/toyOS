#ifndef CPU_H
#define CPU_H

#include "types.h"

#define __read_reg8(name)	\
	({ u8 r; asm volatile("movb %0,%%"name : "=rm" (r)); r; })

#define __read_reg16(name)	\
	({ u16 r; asm volatile("movw %0,%%"name : "=rm" (r)); r; })

#define __write_reg8(val, name)	\
	do { asm volatile("movb %0,%%"name : : "rmi" (val)); } while(0)

#define __write_reg16(val, name)\
	do { asm volatile("movw %0,%%"name : : "rmi" (val)); } while(0)

#define ah() 	__read_reg8("ah")
#define al() 	__read_reg8("al")

#define set_al(val)	__write_reg8(val, "al")
#define set_ah(val)	__write_reg8(val, "ah")

#define set_bl(val)	__write_reg8(val, "bl")
#define set_bh(val)	__write_reg8(val, "bh")

#define set_cl(val)	__write_reg8(val, "cl")
#define set_ch(val)	__write_reg8(val, "ch")

#define set_dl(val)	__write_reg8(val, "dl")
#define set_dh(val)	__write_reg8(val, "dh")

#define bios_int(val)	\
	do { asm volatile("int %0" : : "i" (val)); } while(0)

#endif /* CPU_H */

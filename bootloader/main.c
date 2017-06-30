__asm__(".code16gcc\n");

typedef unsigned char 	u8;
typedef unsigned short 	u16;

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



static void putch(char c)
{
	set_al(c);

	set_ah(0x0e);
	bios_int(0x10);
}

static void puts(const char *s)
{
	while (*s != 0) {
		putch(*s);
		s++;
	}
}

static void goto_xy(u8 x, u8 y)
{
	set_dh(y);		/* row */
	set_dl(x);		/* column */
	set_bh(0);		/* page */

	set_ah(0x02);
	bios_int(0x10);
}

static void cls()
{
	set_al(80);
	set_bh(0x0f);
	set_ch(0x00);
	set_cl(0x00);
	set_dh(25);
	set_dl(80);

	set_ah(0x06);
	bios_int(0x10);

	goto_xy(0, 0);
}

void main()
{
	char *c = "Hello there junior";

	cls();
	puts(c);
}

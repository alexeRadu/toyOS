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

void main()
{
	char *c = "Hello there junior";

	puts(c);
}

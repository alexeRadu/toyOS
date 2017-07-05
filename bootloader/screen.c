__asm__(".code16gcc\n");

#include "cpu.h"

static void putch(char c)
{
	set_al(c);

	set_ah(0x0e);
	bios_int(0x10);
}

void puts(const char *s)
{
	while (*s != 0) {
		putch(*s);

		if (*s == '\n')
			putch('\r');

		s++;
	}
}

void goto_xy(u8 x, u8 y)
{
	set_dh(y);		/* row */
	set_dl(x);		/* column */
	set_bh(0);		/* page */

	set_ah(0x02);
	bios_int(0x10);
}

static void __scroll_by(u8 nlines)
{
	set_al(nlines);
	set_bh(0x0f);
	set_ch(0x00);
	set_cl(0x00);
	set_dh(25);
	set_dl(80);

	set_ah(0x06);
	bios_int(0x10);
}

void cls()
{
	__scroll_by(25);
	goto_xy(0, 0);
}

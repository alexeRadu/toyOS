#include "types.h"
#include "system.h"
#include "screen.h"

#define VIDEO_MEMORY_BASE_ADDRESS	0x000b8000

#define VGA_COLUMN_COUNT	80
#define VGA_ROW_COUNT		25	

/* cursor position */
u16 cx = 0;
u16 cy = 0;
u16 attr = (COLOR_BLACK << 12) | (COLOR_WHITE << 8);

static void update_cursor()
{
	u16 pos = cy * VGA_COLUMN_COUNT + cx;

	outb(0x3d4, 14);
	outb(0x3d5, pos >> 8);
	outb(0x3d4, 15);
	outb(0x3d5, pos);
}

void goto_xy(u16 x, u16 y)
{
	cx = (x >= VGA_COLUMN_COUNT) ? VGA_COLUMN_COUNT - 1 : x;
	cy = (y >= VGA_ROW_COUNT) ? VGA_ROW_COUNT - 1 : y;

	update_cursor();
}

void scroll_by(unsigned int nlines)
{
	u16 *src = (u16*)VIDEO_MEMORY_BASE_ADDRESS;
	u16 *dst = (u16*)VIDEO_MEMORY_BASE_ADDRESS;
	int i;

	nlines = (nlines >= VGA_ROW_COUNT) ? VGA_ROW_COUNT : nlines;
	src += nlines * VGA_COLUMN_COUNT;

	for (i = 0; i < (VGA_ROW_COUNT - nlines) * VGA_COLUMN_COUNT; i++) {
		*dst = *src;
		src++;
		dst++;
	}

	for (i = 0; i < nlines * VGA_COLUMN_COUNT; i++)
		*dst++ = attr | 0x20;

	if (nlines > cy) {
		cy = 0;
		cx = 0;
	} else {
		cy -= nlines;
	}
	update_cursor();
}

/*
 * This is equivalent to scroll_by(VGA_ROW_COUNT). For now I prefer to leave it
 * as is because it is faster then the alternative and provides a clearer
 * understanding to the reader (this is an educational kernel after all).
 */
void cls()
{
	u16 *addr = (u16*)VIDEO_MEMORY_BASE_ADDRESS;
	int i;

	for (i = 0; i < VGA_ROW_COUNT * VGA_COLUMN_COUNT; i++)
			*addr++ = attr | 0x20;

	cx = cy = 0;
	update_cursor();
}

void putch(const char c)
{
	volatile u16 *addr = (u16*)VIDEO_MEMORY_BASE_ADDRESS;
	addr += (cy * VGA_COLUMN_COUNT + cx);

	switch(c) {
	default:
		*addr = attr | c;
		cx += 1;
		if (cx == VGA_COLUMN_COUNT) {
			cx = 0;
			cy = (cy == VGA_ROW_COUNT) ? 0 : cy + 1;
		}
		update_cursor();
	}
}

void puts(const char *s)
{
	while (*s != 0) {
		putch(*s);
		s++;
	}
}

void set_screen_color(unsigned char bgcolor, unsigned char fgcolor)
{
	attr = (bgcolor << 12) | (fgcolor << 8);
}

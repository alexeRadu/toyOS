#include "types.h"
#include "system.h"

#define VIDEO_MEMORY_BASE_ADDRESS	0x000b8000

#define COLOR_BLACK		0x0
#define COLOR_BLUE		0x1
#define COLOR_GREEN		0x2
#define COLOR_CYAN		0x3
#define COLOR_RED		0x4
#define COLOR_MAGENTA		0x5
#define COLOR_BROWN		0x6
#define COLOR_LIGHT_GREY	0x7
#define COLOR_DARK_GREY		0x8
#define COLOR_LIGHT_BLUE	0x9
#define COLOR_LIGHT_GREEN	0xa
#define COLOR_LIGHT_CYAN	0xb
#define COLOR_LIGHT_RED		0xc
#define COLOR_LIGHT_MAGENTA	0xd
#define COLOR_LIGHT_BROWN	0xe
#define COLOR_WHITE		0xf

#define VGA_COLUMN_COUNT	80
#define VGA_ROW_COUNT		25	

/* cursor position */
u16 cx, cy;
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

void cls()
{
	unsigned int i, j;
	volatile u16 *addr = (u16*)VIDEO_MEMORY_BASE_ADDRESS;
	u16 blank = (COLOR_BLACK << 12) | (COLOR_WHITE << 8) | 0x20;

	for (i = 0; i < VGA_ROW_COUNT; i++) {
		for (j = 0; j < VGA_COLUMN_COUNT; j++) {
			*addr = blank;
			addr++;
		}
	}
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

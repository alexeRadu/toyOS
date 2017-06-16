#include "system.h"
#include "screen.h"

#define VIDEO_MEMORY_BASE_ADDRESS	0x000b8000

#define VGA_COLUMN_COUNT	80
#define VGA_ROW_COUNT		25	

/* should be a multiple of 2 */
#define TAB_SIZE		8

/* cursor position */
unsigned short cx = 0;
unsigned short cy = 0;
unsigned short attr = (COLOR_BLACK << 12) | (COLOR_WHITE << 8);

static void update_cursor()
{
	unsigned short pos = cy * VGA_COLUMN_COUNT + cx;

	outb(0x3d4, 14);
	outb(0x3d5, pos >> 8);
	outb(0x3d4, 15);
	outb(0x3d5, pos);
}

void goto_xy(unsigned short x, unsigned short y)
{
	cx = (x >= VGA_COLUMN_COUNT) ? VGA_COLUMN_COUNT - 1 : x;
	cy = (y >= VGA_ROW_COUNT) ? VGA_ROW_COUNT - 1 : y;

	update_cursor();
}

static void scroll()
{
	unsigned short *src = (unsigned short*)VIDEO_MEMORY_BASE_ADDRESS +
			     VGA_COLUMN_COUNT;
	unsigned short *dst = (unsigned short*)VIDEO_MEMORY_BASE_ADDRESS;
	int i;

	if (cy >= VGA_ROW_COUNT) {
		for (i = 0; i < (VGA_ROW_COUNT - 1) * VGA_COLUMN_COUNT; i++)
			*dst++ = *src++;

		for (i = 0; i < VGA_COLUMN_COUNT; i++)
			*dst++ = attr | 0x20;

		cy = VGA_ROW_COUNT - 1;
	}
}

void cls()
{
	unsigned short *addr = (unsigned short*)VIDEO_MEMORY_BASE_ADDRESS;
	int i;

	for (i = 0; i < VGA_ROW_COUNT * VGA_COLUMN_COUNT; i++)
		*addr++ = attr | 0x20;

	cx = cy = 0;
	update_cursor();
}

static void __putch(const char c)
{
	unsigned short *addr = (unsigned short*)VIDEO_MEMORY_BASE_ADDRESS;
	addr += (cy * VGA_COLUMN_COUNT + cx);

	*addr = attr | c;
	cx++;
}

void putch(const char c)
{
	switch(c) {
	case 0x20 ... 0x7f: /* any printable character */
		__putch(c);
		break;
	case '\b': 	/* 0x08 - backspace */
		cx = (cx == 0) ? 0 : (cx - 1);
		break;
	case '\t':	/* 0x09 - tab */
		cx = (cx + TAB_SIZE) & ~(TAB_SIZE - 1);
		break;
	case '\n':	/* 0x0a - line-feed == newline */
		cx = 0;
		cy++;
		break;
	case '\r':	/* 0x0d - carriage return */
		cx = 0;
		break;
	}

	if (cx >= VGA_COLUMN_COUNT) {
		cx = 0;
		cy++;
	}

	scroll();
	update_cursor();
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

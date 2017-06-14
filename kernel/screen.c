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

void goto_xy(u16 x, u16 y)
{
	u16 pos;

	x = (x >= VGA_COLUMN_COUNT) ? VGA_COLUMN_COUNT - 1 : x;
	y = (y >= VGA_ROW_COUNT) ? VGA_ROW_COUNT - 1 : y;

	pos = y * VGA_COLUMN_COUNT + x;

	outb(0x3d4, 14);
	outb(0x3d5, pos >> 8);
	outb(0x3d4, 15);
	outb(0x3d5, pos);

	cx = x;
	cy = y;
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

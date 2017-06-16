#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"

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

void goto_xy(u16 x, u16 y);
void cls();
void putch(const char c);
void puts(const char *s);
void set_screen_color(unsigned char bgcolor, unsigned char fgcolor);

#endif /* SCREEN_H */

#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"

void goto_xy(u16 x, u16 y);
void scroll_by(unsigned int nlines);
void cls();
void putch(const char c);
void puts(const char *s);
void set_screen_color(unsigned char bgcolor, unsigned char fgcolor);

#endif /* SCREEN_H */

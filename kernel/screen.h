#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"

void goto_xy(u16 x, u16 y);
void cls();
void putch(const char c);

#endif /* SCREEN_H */

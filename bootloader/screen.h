#ifndef SCREEN_H
#define SCREEN_H

#include "cpu.h"

void puts(const char *s);
void goto_xy(u8 x, u8 y);
void cls();

#endif /* SCREEN_H */

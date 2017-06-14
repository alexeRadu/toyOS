#include "screen.h"

void kmain()
{
	cls();
	goto_xy(0, 0);
	putch(0x70);

	/* This is the infinite loop */
	while (1) {
	}
}

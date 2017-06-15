#include "screen.h"

void kmain()
{
	cls();
	goto_xy(0, 0);
	putch('r');
	putch('a');
	putch('d');
	putch('u');

	/* This is the infinite loop */
	while (1) {
	}
}

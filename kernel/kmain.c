#include "screen.h"

void kmain()
{
	cls();
	goto_xy(26, 80);
	puts("Radu is here");

	scroll_by(26);

	/* This is the infinite loop */
	while (1) {
	}
}

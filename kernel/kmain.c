#include "screen.h"

void kmain()
{
	set_screen_color(COLOR_CYAN, COLOR_RED);
	cls();

	set_screen_color(COLOR_LIGHT_BROWN, COLOR_DARK_GREY);
	goto_xy(9, 24);
	puts("Radu \nis\t here\t\tradu\bolaaaaaaaaa\x33\x03\x05");

	puts("\n");
	puts("1. \t\t fruits\n");
	puts("2. \t\t vegetables\n");
	puts("3. \t\t drinks\n");

	/* This is the infinite loop */
	while (1) {
	}
}

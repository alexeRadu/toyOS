#include "screen.h"

void kmain()
{
	set_screen_color(COLOR_CYAN, COLOR_RED);
	cls();

	goto_xy(5, 7);
	puts("Radu is here");

	set_screen_color(COLOR_LIGHT_BROWN, COLOR_DARK_GREY);
	scroll_by(3);

	/* This is the infinite loop */
	while (1) {
	}
}

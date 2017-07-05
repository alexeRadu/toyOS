__asm__(".code16gcc\n");

#include "screen.h"
#include "boot.h"

const char BOOTSECTOR_DATA *greet_msg = "Hello there";

void BOOTSECTOR main()
{
	cls();
	puts(greet_msg);
}

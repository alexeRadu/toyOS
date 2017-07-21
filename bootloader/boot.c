__asm__(".code16gcc\n");

#include "screen.h"

void boot()
{
	cls();
	puts("Second stange bootloader started\n");
}

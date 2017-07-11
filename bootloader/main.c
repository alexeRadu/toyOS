__asm__(".code16gcc\n");

#include "screen.h"
#include "boot.h"
#include "disk.h"

extern void boot2();

void BOOTSECTOR main()
{
	cls();

	if (read_disk_sectors(0x7e00, 0, 1, 1)) {
		puts("Error\n");
	}

	boot2();
}

__asm__(".code16gcc\n");

#include "screen.h"
#include "boot.h"
#include "disk.h"

const char BOOTSECTOR_DATA *greet_msg = "Hello there";

void BOOTSECTOR main()
{
	cls();
	puts(greet_msg);

	if (read_disk_sectors(0x7e00, 0, 1, 1)) {
		puts("Unable to read 2nd stage bootloader\n");
	}
}

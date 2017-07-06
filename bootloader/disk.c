__asm__(".code16gcc\n");

#include "cpu.h"
#include "boot.h"

int read_disk_sectors(int mem, unsigned int drive,
				 unsigned int sector_start,
				 unsigned int sector_count)
{
	u8 sector;
	u8 head;
	u8 cylinder;

	if (drive > 3)
		return 1;

	/* convert the sector index to C, H, S */
	sector = (sector_start % 18) + 1;
	sector_start = sector_start / 18;

	head = sector_start % 2;
	sector_start = sector_start / 2;

	cylinder = sector_start % 80;
	sector_start = sector_start / 80;

	if (sector_start)
		return 1;

	set_al(sector_count);
	set_ch(cylinder);
	set_cl(sector);
	set_dh(head);
	set_dl(drive);
	set_bx(mem);

	set_ah(0x02);
	bios_int(0x13);

	if (ah() != 0 || al() != sector_count)
		return 1;
	
	return 0;
}

__asm__(".code16gcc\n");

#include "cpu.h"
#include "boot.h"

void compute_chs();

int BOOTSECTOR read_disk_sectors(int mem, unsigned int drive,
				 unsigned int sector_start,
				 unsigned int sector_count)
{
	set_cl(1);	/* sector = 1 */
	set_dh(0);	/* head = 0 */
	set_ch(0);	/* cylinder = 0 */
	set_al(sector_start);

	compute_chs();

	/* read disk sectors */
	set_al(sector_count);
	set_dl(drive);
	set_bx(mem);

	set_ah(0x02);
	bios_int(0x13);

	if (ah() != 0 || al() != sector_count)
		return 1;
	
	return 0;
}

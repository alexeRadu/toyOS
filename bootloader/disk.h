#ifndef DISK_H
#define DISK_H

int read_disk_sectors(int mem, unsigned int drive, unsigned int sector_start,
		     unsigned int sector_count);

#endif /* DISK_H */

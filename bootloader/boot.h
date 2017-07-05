#ifndef BOOT_H
#define BOOT_H

#define SECTION(s)	__attribute__ ((section (s)))

#define BOOTSECTOR		SECTION(".bootsector.txt")
#define BOOTSECTOR_DATA		SECTION(".bootsector.data")

#endif /* BOOT_H */

OUTPUT_FORMAT("elf32-i386")
ENTRY(_start)
phys = 0x7c00;
SECTIONS
{
	. = 0x7c00;
	.bootsector : AT(0x7c00)
	{
		*(.bootsector.txt);
		*(.bootsector.data);
		main.o(.rodata);
	}

	. = 0x7dfe;
	.sig : AT(0x7dfe)
	{
		SHORT(0xaa55);
	}

	. = 0x7e00;
	.text : AT(0x7e00)
	{
		*(.text);
		*(.rodata);
		. = ALIGN(0x200);
	}
}

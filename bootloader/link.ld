OUTPUT_FORMAT("elf32-i386")
ENTRY(_start)
phys = 0x7e00;
SECTIONS
{
	. = 0x7e00;
	.text : AT(0x7e00)
	{
		*(.text);
		*(.rodata);
		*(.data);
		*(.bss);
		. = ALIGN(0x200);
	}
}

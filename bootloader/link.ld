OUTPUT_FORMAT("elf32-i386")
ENTRY(_start)
phys = 0x7c00;
SECTIONS
{
	. = 0x7c00;
	.text : AT(0x7c00)
	{
		*(.text);
	}
	.sig : AT(0x7dfe)
	{
		SHORT(0xaa55);
	}
}

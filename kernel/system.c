void outb(unsigned short port, unsigned char data)
{
	asm volatile ("outb %1, %0" : : "dN" (port), "a" (data));
}


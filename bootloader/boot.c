__asm__(".code16gcc\n");

#include "screen.h"
#include "vsnprintf.h"

void boot()
{
	char msg[256];
	//char *name = "Radu";
	//int age = 35;

	cls();
	puts("Second stange bootloader started\n");

	/*
	snprintf(msg, 256, "My name is %s and I am %d years old\n", name, age);
	*/
	snprintf(msg, 256, "Hello %% there\n");
	puts(msg);
}

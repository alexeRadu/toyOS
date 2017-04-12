all: bootloader.bin bootloader.elf

bootloader.bin: bootloader.asm screen.asm disk.asm modes.asm memory.asm
	nasm -f bin -o bootloader.bin bootloader.asm

bootloader.elf: bootloader.asm screen.asm disk.asm modes.asm memory.asm
	nasm -f elf64 -F dwarf -g -o bootloader.elf bootloader.asm

clean:
	rm bootloader.bin
	rm bootloader.elf

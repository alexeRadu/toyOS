all: bootloader.bin bootloader.o

bootloader.bin: bootloader.asm screen.asm disk.asm modes.asm memory.asm
	nasm -f bin -o bootloader.bin bootloader.asm

bootloader.o: bootloader.asm screen.asm disk.asm modes.asm memory.asm
	nasm -f elf64 -F dwarf -g -o bootloader.o bootloader.asm

clean:
	rm -f bootloader.bin
	rm -f bootloader.o

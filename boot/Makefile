all: bootloader.bin bootloader.o

bootloader.bin: bootloader.o
	objcopy -O binary bootloader.o bootloader.bin

bootloader.o: bootloader.asm screen.asm disk.asm modes.asm memory.asm
	nasm -f elf64 -F dwarf -g -o bootloader.o bootloader.asm

clean:
	rm bootloader.bin
	rm bootloader.o

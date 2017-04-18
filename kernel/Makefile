all: kernel.bin

kernel.bin: start.o
	ld -T link.ld -o kernel.bin start.o

start.o: start.asm
	nasm -f elf64 -F dwarf -g -o start.o start.asm

clean:
	rm kernel.bin
	rm start.o

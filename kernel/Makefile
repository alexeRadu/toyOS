all: kernel.bin

kernel.bin: start.o kmain.o
	ld -T link.ld -o kernel.bin start.o kmain.o

start.o: start.asm
	nasm -f elf64 -F dwarf -g -o start.o start.asm

kmain.o: kmain.c
	gcc -Wall -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o kmain.o kmain.c

clean:
	rm kernel.bin
	rm start.o
	rm kmain.o

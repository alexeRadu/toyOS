OPTIONS := -Wall -g -ggdb -fno-builtin -g -O -fomit-frame-pointer -finline-functions -nostdinc

all: kernel.bin kernel.o

kernel.bin: start.o kmain.o screen.o
	ld -T link.ld -o kernel.bin start.o kmain.o screen.o

kernel.o: start.o kmain.o screen.o
	ld -T linko.ld -g -o kernel.o start.o kmain.o screen.o

start.o: start.asm
	nasm -f elf64 -F dwarf -g -o start.o start.asm

kmain.o: kmain.c screen.h
	gcc $(OPTIONS) -c -o kmain.o kmain.c

screen.o: screen.c types.h
	gcc $(OPTIONS) -c -o screen.o screen.c

clean:
	rm kernel.bin
	rm kernel.o
	rm start.o
	rm kmain.o
	rm screen.o

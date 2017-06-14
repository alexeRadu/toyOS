OPTIONS := -Wall -g -ggdb -fno-builtin -nostdinc

kernel.bin: kernel.o
	objcopy -O "binary" kernel.o kernel.bin

kernel.o: start.o kmain.o screen.o system.o
	ld -T link.ld -g -o kernel.o start.o kmain.o screen.o system.o

start.o: start.asm
	nasm -f elf64 -F dwarf -g -o start.o start.asm

kmain.o: kmain.c screen.h
	gcc $(OPTIONS) -c -o kmain.o kmain.c

screen.o: screen.c types.h system.h
	gcc $(OPTIONS) -c -o screen.o screen.c

system.o: system.c
	gcc $(OPTIONS) -c -o system.o system.c

clean:
	rm -f kernel.bin
	rm -f kernel.o
	rm -f start.o
	rm -f kmain.o
	rm -f screen.o
	rm -f system.o

bootloader.bin: bootloader.o
	objcopy  -O "binary" bootloader.o bootloader.bin

bootloader.o: start.o main.o
	ld -T link.ld -m elf_i386 -g -nostdlib -o bootloader.o start.o main.o

main.o: main.c
	gcc -c -g -m32 -ffreestanding -Wall -Werror -o main.o main.c

start.o: start.S
	as -32 -g -o start.o start.S

clean:
	rm -f start.o
	rm -f main.o
	rm -f bootloader.o
	rm -f bootloader.bin

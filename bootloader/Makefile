bootloader.bin: bootloader.o
	objcopy  -O "binary" bootloader.o bootloader.bin

bootloader.o: start.o
	ld -T link.ld -m elf_i386 -g -nostdlib -o bootloader.o start.o

start.o: start.S
	as -32 -g -o start.o start.S

clean:
	rm -f start.o
	rm -f bootloader.o
	rm -f bootloader.bin

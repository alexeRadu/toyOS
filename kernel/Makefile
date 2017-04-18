all: kernel.bin kernel.elf

kernel.bin: start.asm
	nasm -f bin -o kernel.bin start.asm

kernel.elf: start.asm
	nasm -f elf64 -F dwarf -g -o kernel.elf start.asm

clean:
	rm kernel.bin
	rm kernel.elf
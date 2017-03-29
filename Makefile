
all: boot.flp boot.elf

boot.flp: boot.bin
	dd status=noxfer conv=notrunc if=boot.bin of=boot.flp

boot.bin: boot.asm
	nasm -f bin -o boot.bin boot.asm

boot.elf: boot.asm
	nasm -f elf64 -F dwarf -g -o boot.elf boot.asm

clean:
	rm boot.flp
	rm boot.bin
	rm boot.elf

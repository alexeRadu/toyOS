boot.flp: boot.bin
	dd status=noxfer conv=notrunc if=boot.bin of=boot.flp

boot.bin: boot.asm
	nasm -f bin -o boot.bin boot.asm

clean:
	rm boot.flp
	rm boot.bin

main.img: main.asm
	nasm -f bin -o main.img main.asm

run:
	qemu-system-i386 main.img

clean:
	rm main.img

define rm_file
        if [ -f $(1) ]; then           \
                rm $(1);               \
                echo "RM        $(1)"; \
        fi
endef

bootloader.bin: bootloader.o
	objcopy  -O "binary" bootloader.o bootloader.bin

bootloader.o: start.o main.o
	ld -T link.ld -m elf_i386 -g -nostdlib -o bootloader.o start.o main.o

main.o: main.c
	gcc -c -g -m32 -ffreestanding -Wall -Werror -o main.o main.c

start.o: start.S
	as -32 -g -o start.o start.S

clean:
	@$(call rm_file, start.o)
	@$(call rm_file, main.o)
	@$(call rm_file, bootloader.o)
	@$(call rm_file, bootloader.bin)

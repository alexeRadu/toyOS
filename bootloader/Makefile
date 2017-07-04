
CC := gcc
AS := as
LD := ld

CFLAGS := -g -m32 -Wall -Werror -ffreestanding
ASFLAGS := -g -32
LDFLAGS := -g -m elf_i386 -nostdlib

define rm_file
        if [ -f $(1) ]; then           \
                rm $(1);               \
                echo "RM        $(1)"; \
        fi
endef

bootloader.bin: bootloader.o
	objcopy  -O "binary" bootloader.o bootloader.bin

bootloader.o: start.o main.o
	$(LD) -T link.ld $(LDFLAGS) $^ -o $@

main.o: main.c
	$(CC) -c $(CFLAGS) $< -o $@

start.o: start.S
	$(AS) $(ASFLAGS) $< -o $@

clean:
	@$(call rm_file, start.o)
	@$(call rm_file, main.o)
	@$(call rm_file, bootloader.o)
	@$(call rm_file, bootloader.bin)

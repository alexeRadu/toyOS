
CC := gcc
AS := as
LD := ld

DEBUG := -g

CFLAGS := $(DEBUG) -m32 -Wall -Werror -ffreestanding -fno-exceptions -fno-asynchronous-unwind-tables -Qn
ASFLAGS := $(DEBUG) -32
LDFLAGS := $(DEBUG) -m elf_i386 -nostdlib

define rm_file
        if [ -f $(1) ]; then           \
                rm $(1);               \
                echo "RM        $(1)"; \
        fi
endef

define do_cc
	cfile=$(1);                                \
	ofile="$${cfile%.*}.o";                    \
	$(CC) -c $(CFLAGS) $${cfile} -o $${ofile}; \
	echo "CC        $(1)"
endef

define do_as
        asfile=$(1);                              \
	ofile="$${asfile%.*}.o";                  \
	$(AS) $(ASFLAGS) $${asfile} -o $${ofile}; \
	echo "AS        $(1)"
endef

define do_objcopy
	ofile=$(1);					\
	binfile="$${ofile%.*}.bin";			\
	objcopy -O "binary" $${ofile} $${binfile};	\
	echo "OBJCOPY   $${binfile}"
endef

bootloader.bin: bootloader.o
	@$(call do_objcopy,$<)

bootloader.o: start.o main.o screen.o disk.o chs.o boot2.o
	@$(LD) -T link.ld $(LDFLAGS) $^ -o $@
	@echo "LD        $@"

main.o: main.c screen.h types.h boot.h disk.h
	@$(call do_cc,$<)

screen.o: screen.c cpu.h types.h boot.h
	@$(call do_cc,$<)

disk.o: disk.c cpu.h types.h boot.h
	@$(call do_cc,$<)

chs.o: chs.S
	@$(call do_as,$<)

start.o: start.S
	@$(call do_as,$<)

boot2.o: boot2.c screen.h boot.h
	@$(call do_cc,$<)

clean:
	@$(call rm_file,start.o)
	@$(call rm_file,main.o)
	@$(call rm_file,screen.o)
	@$(call rm_file,disk.o)
	@$(call rm_file,chs.o)
	@$(call rm_file,boot2.o)
	@$(call rm_file,bootloader.o)
	@$(call rm_file,bootloader.bin)

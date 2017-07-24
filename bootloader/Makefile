
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
        asfile=$(1)                               \
	ofile="$${asfile%.*}.o";                  \
	$(AS) $(ASFLAGS) $${asfile} -o $${ofile}; \
	echo "AS        $(1)"
endef

define do_objcopy
        ofile=$(1)                                 \
	binfile="$${ofile%.*}.bin";                \
	objcopy -O "binary" $${ofile} $${binfile}; \
	echo "OBJCOPY   $(1)"
endef

bootloader.bin: bootsect.bin boot2.bin
	@cat bootsect.bin > bootloader.bin
	@cat boot2.bin >> bootloader.bin
	@echo "DONE      $@"

bootsect.bin: bootsect.o
	@$(call do_objcopy,$<)

bootsect.o: bootsect.S
	@$(call do_as,$<)

boot2.bin: boot2.o
	@$(call do_objcopy,$<)

boot2.o: start.o boot.o screen.o vsnprintf.o
	@$(LD) -T link.ld $(LDFLAGS) $^ -o $@
	@echo "LD        $@"

start.o: start.S
	@$(call do_as,$<)

boot.o: boot.c
	@$(call do_cc,$<)

screen.o: screen.c
	@$(call do_cc,$<)

vsnprintf.o: vsnprintf.c
	@$(call do_cc,$<)

clean:
	@$(call rm_file,bootloader.bin)
	@$(call rm_file,bootsect.bin)
	@$(call rm_file,bootsect.o)
	@$(call rm_file,boot2.bin)
	@$(call rm_file,boot2.o)
	@$(call rm_file,start.o)
	@$(call rm_file,boot.o)
	@$(call rm_file,screen.o)

disk.bin: boot/bootloader.bin kernel/kernel.bin
	cat boot/bootloader.bin > disk.bin
	cat kernel/kernel.bin >> disk.bin

boot/bootloader.bin:
	$(MAKE) -C boot

kernel/kernel.bin:
	$(MAKE) -C kernel

clean:
	$(MAKE) clean -C boot
	$(MAKE) clean -C kernel
	rm -f disk.bin

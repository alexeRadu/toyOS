# Toy Operating System
This project was inteded as a playground for me to study operating system design by implementing the basics of a kernel for the x86 platform.

## Development environment
The implementation requires a debian-based host machine. It can either be a native machine or virtual one. The tools/prerequisites are the standard one:

* git/gitk - for source control
* gcc/nasm - for compilation/linking
* make
* gdb - for debugging
* qemu - for device emulation

## GDB
GDB is a powerfull debugger that integrates well with simulators. It's drawback is the lack of a powerful interface that would ease debugging. The variant that I am testing right now is a better command line interface. It does not need additional add-ons and is implemented through the use of a .gdbinit file. It can be downloaded from https://github.com/cyrus-and/gdb-dashboard.git. A variant has been included in the tools directory. To use it just copy it in the home directory.

```bash
$ cp tools/.gdbinit ~
```

## Usefull links
 * [emu8086 references](http://courses.ee.sun.ac.za/OLD/2003/Rekenaarstelsels245/8086_Instruksies/)
 * [8086 instruction set](http://www.electronics.dit.ie/staff/tscarff/8086_instruction_set/8086_instruction_set.html)
 * [x86 memory map](https://wiki.osdev.org/Memory_Map_(x86))

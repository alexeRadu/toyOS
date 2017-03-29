# Development Environment Setup

This document is intended to provide a complete specification for the environment used for the development of the toyOS. It is based on Ubuntu 16.04 LTS or any other distro that is built on top of it. The environment can be setup either on a Linux machine, with the distro installed as a host OS, or on a Windows machine with the distro installed inside a virtual machine.

## On Linux
There are a few prerequisites you need to install:

```bash
$ sudo apt-get install gcc
$ sudo apt-get install nasm
$ sudo apt-get install make
$ sudo apt-get install gdb
$ sudo apt-get install git
$ sudo apt-get install gitk
$ sudo apt-get install qemu
```
It is pretty obvious from the commands what utilities are installed. If you don't know yet about any of those please inform yourself. Additionally an editor is needed but none is enforced.
 

## XWindow on Windows
Cygwin/X11 doesn't work on win32. To make graphical cygwin application run I have installed a X11 server called Xming. You can download Xming from https://sourceforge.net/projects/xming/. After installing it set your display address to :0.0 and on cygwin console write:

```bash
$ export DISPLAY=:0.0
```

You should place this variable in bashrc so that you won't type it everytime you start bash.

## GDB
GDB is a powerfull debugger that integrates well with simulators. It's drawback is the lack of a powerful interface that would ease debugging. The variant that I am testing right now is a better command line interface. It does not need additional add-ons and is implemented through the use of a .gdbinit file. It can be downloaded from https://github.com/cyrus-and/gdb-dashboard.git. A variant has been included in the tools directory. To use it just copy it in the home directory.

```bash
$ cp tools/.gdbinit ~
```

## Test Images
To test the setup there are several images provided by the qemu team. You can find them at:
http://wiki.qemu-project.org/Testing/System_Images

For simplicity one has been added at images/minix204. To start the image just run:

```bash
$ ./start
```

After running the start script you will be in the gdb console waiting for other commands. Issue __continue__ to start the image.

```gdb
> continue
```

# Bareboard development tools

This folder contains a set of tools (VMs, compilers, debuggers) for bareboard development together with configuration scripts.

## Cygwin
On windows I use the cygwin environemnt. Cygwin is a collection of GNU and Open Source tools which provide functionality similar to a Linux distribution on Windows. To install it go to https://www.cygwin.com and follow the installation steps. The installer is a graphical package manager that enable the instalation of a selection of packages from a big repository of packages. Make sure to install the following:
 * gcc
 * make
 * git
 * gitk
 * vim (if this is your editor)

## XWindow on Windows
Cygwin/X11 doesn't work on win32. To make graphical cygwin application run I have installed a X11 server called Xming. You can download Xming from https://sourceforge.net/projects/xming/. After installing it set your display address to :0.0 and on cygwin console write:

```bash
$ export DISPLAY=:0.0
```

You should place this variable in bashrc so that you won't type it everytime you start bash.

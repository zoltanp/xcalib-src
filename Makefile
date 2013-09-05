# Makefile for xcalib
#
# (c) 2004-2007 Stefan Doehla <stefan AT doehla DOT de>
#
# This program is GPL-ed postcardware! please see README
#
# It is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA.
#

#
# the following targets are defined:
# - xcalib
#   default
# - win_xcalib
#   version for MS-Windows systems with MinGW (internal parser)
# - fglrx_xcalib
#   version for ATI's proprietary fglrx driver (internal parser)
# - xrandr_xcalib
#   version for usage with the XRandR protocol (internal parser)
# - vs_xcalib.exe
#   version for MS-Windows with Visual Studio build (internal parser)
#
# - clean
#   delete all objects and binaries
#
# if it doesn't compile right-out-of-the-box, it may be sufficient
# to change the following variables

XCALIB_VERSION = 0.8
CFLAGS = -O0 -ggdb
# CFLAGS += -Wall -Wextra
XINCLUDEDIR = /usr/X11R6/include
XLIBDIR = /usr/X11R6/lib
# for ATI's proprietary driver (must contain the header file fglrx_gamma.h)
FGLRXINCLUDEDIR = ./fglrx
FGLRXLIBDIR = ./fglrx

# default make target
all: xcalib
	

# low overhead version (internal parser)
xcalib: xcalib.c
	$(CC) $(CFLAGS) -c xcalib.c -I$(XINCLUDEDIR) -DXCALIB_VERSION=\"$(XCALIB_VERSION)\"
	$(CC) $(CFLAGS) -L$(XLIBDIR) -o xcalib xcalib.o -lm -lX11 -lXxf86vm -lXext

fglrx_xcalib: xcalib.c
	$(CC) $(CFLAGS) -c xcalib.c -I$(XINCLUDEDIR) -DXCALIB_VERSION=\"$(XCALIB_VERSION)\" -I$(FGLRXINCLUDEDIR) -DFGLRX
	$(CC) $(CFLAGS) -L$(XLIBDIR) -L$(FGLRXLIBDIR) -o xcalib xcalib.o -lfglrx_gamma -lm -lX11 -lXxf86vm -lXext

win_xcalib: xcalib.c
	$(CC) $(CFLAGS) -c xcalib.c -DXCALIB_VERSION=\"$(XCALIB_VERSION)\" -DWIN32GDI
	windres.exe resource.rc resource.o
	$(CC) $(CFLAGS) -mwindows resource.o -o xcalib xcalib.o -lm

xrandr_xcalib: xcalib.c gamma_randr.c gamma_randr.h
	$(CC) $(CFLAGS) -c xcalib.c -DXCALIB_VERSION=\"$(XCALIB_VERSION)\" -DXRANDR
	$(CC) $(CFLAGS) -c gamma_randr.c -DXCALIB_VERSION=\"$(XCALIB_VERSION)\" -std=c99 -DXRANDR
	$(CC) $(CFLAGS) -L$(XLIBDIR) -o xrandr_xcalib xcalib.o gamma_randr.o -lm -lxcb-randr

vs_xcalib.exe: xcalib.c
	$(CC) -c xcalib.c -DXCALIB_VERSION=\"$(XCALIB_VERSION)\" -DWIN32GDI
	windres.exe resource.rc resource.obj
	$(CC) xcalib.obj resource.obj Gdi32.lib User32.lib /Fevs_xcalib.exe

install:
	cp ./xcalib $(DESTDIR)/usr/local/bin/
	chmod 0644 $(DESTDIR)/usr/local/bin/xcalib

clean:
	rm -f xcalib.o
	rm -f resource.o
	rm -f gamma_randr.o
	rm -f xrandr_xcalib
	rm -f xcalib
	rm -f xcalib.exe
	rm -f xcalib.exe.so


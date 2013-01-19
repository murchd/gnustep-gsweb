#   -*-makefile-*-
#   gsweb.make
#
#   Makefile flags and configs to build with the base library.
#
#   Copyright (C) 2002-2003 Free Software Foundation, Inc.
#
#   Author: Mirko Viviani <mirko.viviani@rccr.cremona.it>
#   Based on code originally in the gnustep make package
#
#   This file is part of the GNUstep Base Library.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

ifeq ($(GSWEB_MAKE_LOADED),)
GSWEB_MAKE_LOADED=yes

GSWEB_VERSION = 1.3.0
GSWEB_MAJOR_VERSION = 1
GSWEB_MINOR_VERSION = 3
GSWEB_SUBMINOR_VERSION = 0

ifeq ($(GSW_NAMES),wo)
  AUXILIARY_GSW_LIBS += -lWebObjects -lWOExtensions -lWOExtensionsGSW
else
#  AUXILIARY_GSW_LIBS += -lGSWeb -lGSWExtensions -lGSWExtensionsGSW
endif


AUXILIARY_INCLUDE_DIRS +=  -I/usr/include/libxml2
AUXILIARY_TOOL_LIBS += -lpng -lz   -lxml2

#GDL2=yes
#ifeq ($(GDL2),yes)
#include $(GNUSTEP_MAKEFILES)/Auxiliary/gdl2.make
#endif

endif # GSWEB_MAKE_LOADED


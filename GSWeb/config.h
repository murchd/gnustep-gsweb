/* config.h.  Generated from config.h.in by configure.  */
/* Machine/OS specific configuration information for GSWeb

   Copyright (C) 2002 Free Software Foundation, Inc.

   Written by: Mirko Viviani <mirko.viviani@rccr.cremona.it>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */

#ifndef	included_config_h
#define	included_config_h


#define HAVE_LIBZ 1
#define HAVE_LIBPNG 1
/* #undef HAVE_LIBWRAP */
#define HAVE_GDL2 1

#define RCS_ID(name) \
	static const char RCSID[] = name; \
	static inline const char *getGswRCSID() { if (0) getGswRCSID(); return RCSID;}

#endif

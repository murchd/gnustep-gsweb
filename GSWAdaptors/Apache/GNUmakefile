#   Makefile for Apache GNUstepWeb module
#   Copyright (C) 2005 Free Software Foundation, Inc.
#   
#   Written by:		David Ayers <d.ayers@inode.at>
#   Based on work by:	Manuel Guesdon <mguesdon@sbuilders.com>
#   Date:		March 2005
#   
#   This file is part of the GNUstep Web Library.
#   
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#   
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#   
#   You should have received a copy of the GNU Library General Public
#   License along with this library; if not, write to the Free
#   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

APXS:=/usr/bin/apxs2
SERVERAPI:=Apache2
APRCONFIG:=/usr/bin/apr-config

C_CPPFLAGS=
C_LDFLAGS=


# To avoid ABI (Application Binary Interface) issues
# we build all module components with APXS which should
# invoke the same compiler with the same options with
# which the Apache server was built.
# The following variables should be the basis of any
# Apache specific flags we need to build the module.
# Some are currently unused and should be removed once
# this file stabalizes.
AP_CC         := $(shell ($(APXS) -q CC))
AP_CFLAGS     := $(shell ($(APXS) -q CFLAGS))
AP_CFLAGS_SH  := $(shell ($(APXS) -q CFLAGS_SHLIB))
AP_LDFLAGS_SH := $(shell ($(APXS) -q LDFLAGS_SHLIB))
AP_LIBS_SH    := $(shell ($(APXS) -q LIBS_SHLIB))

AP_INCDIR := $(shell ($(APXS) -q INCLUDEDIR))
AP_LIBDIR := $(shell ($(APXS) -q LIBEXECDIR))
AP_SYSDIR := $(shell ($(APXS) -q SYSCONFDIR))

ifeq ($(SERVERAPI),Apache2)
APR_CFLAGS   := $(shell ($(APRCONFIG) --cflags))
APR_CPPFLAGS := $(shell ($(APRCONFIG) --cppflags))
APR_INCDIR   := $(shell ($(APRCONFIG) --includedir))
APR_LDFLAGS  := $(shell ($(APRCONFIG) --ldflags))
APR_LIBS     := $(shell ($(APRCONFIG) --libs))

ifneq ($(APR_INCDIR),)
APR_CPPFLAGS += -I$(APR_INCDIR)
endif
endif

# It is not clear, why some versions of of apxs  do not 
# specify -shared in AP_LDFLAGS_SH as it seems to be the 
# key flag to create DSO (Dynamic Shared Objects) which
# is stated goal of apxs compilation.  For now we 
# simply add it if AP_LDFLAGS_SH is not set.
ifeq ($(AP_LDFLAGS_SH),)
AP_LDFLAGS_SH = -shared
endif

CC:=$(APXS) -c

# Not really sure how this variable is useful.
SRCROOT = ..

ifeq ($(MOD_CONF_DIR),)
MOD_CONF_DIR=$(AP_SYSDIR)
endif

ifeq ($(SERVERAPI),Apache2)
ADAPTOR  := mod_gsweb.la
else
ADAPTOR  := mod_gsweb.so
endif
MOD_CONF := mod_gsweb.conf

COMMON = $(SRCROOT)/common

GSW_CPPFLAGS = \
	-D$(SERVERAPI) -DREENTRANT -DEAPI \
	-I. -I$(COMMON) \
	-I$(AP_INCDIR) $(APR_CPPFLAGS) \
	$(C_CPPFLAGS) $(OTHER_CPPFLAGS)

GSW_CFLAGS = \
	$(AP_CFLAGS) $(AP_CFLAGS_SH) \
	$(APR_CFLAGS) \
	$(OTHER_CFLAGS)

GSW_LDFLAGS = \
	$(AP_LDFLAGS_SH) $(AP_LIBS_SH) \
	$(APR_LDFLAGS) $(APR_LIBS) \
	-lPropList \
	$(C_LDFLAGS) $(OTHER_LDFLAGS)

# We currently include the CPPFLAGS in the CFLAGS so the
# common makefiles still work.
comma:=,
CFLAGS  = $(GSW_CPPFLAGS)
CFLAGS += $(addprefix -Wc$(comma),$(GSW_CFLAGS))
LDFLAGS = $(addprefix -Wl$(comma),$(GSW_LDFLAGS))

# Declare default rule before including common.make 
all:: $(ADAPTOR) $(MOD_CONF)

# Include common.make to set COMMONFILES
include $(COMMON)/common.make

# Link the final adaptor module with APXS
$(ADAPTOR): $(COMMONFILES) $(SRCROOT)/Apache/mod_gsweb.c
	$(APXS) -c -o $@ $(APXS_FLAGS) $(CFLAGS) $(LDFLAGS) \
		$(COMMONFILES) $(SRCROOT)/Apache/mod_gsweb.c

# Create mod_gsweb.conf file based on MOD_CONF_DIR (apxs)
$(MOD_CONF):
	@echo "Creating $(MOD_CONF)" ; \
	echo "# The this file is maintained by GSWeb " > $(MOD_CONF) ; \
	echo "GSWeb_ConfigFilePath $(MOD_CONF_DIR)/gsweb.conf" \
		>> $(MOD_CONF) ; \
	echo "GSWeb_Alias /GSWeb" >> $(MOD_CONF) ; \
	echo "<Location /GSWeb*>" >> $(MOD_CONF) ; \
	echo "  SetHandler GSWeb" >> $(MOD_CONF) ; \
	echo "</Location>" >> $(MOD_CONF) ;

# Install module (via apxs) and mod_gsweb.conf file
install: $(ADAPTOR) $(MOD_CONF)
	$(APXS) -i -n gsweb $(ADAPTOR)
	cp $(MOD_CONF) $(MOD_CONF_DIR) 

httpdconfig: $(ADAPTOR)
	$(APXS) -e -a -n gsweb $(ADAPTOR)
	@if ( ! grep '$(MOD_CONF)' $(AP_SYSDIR)/httpd.conf \
	     > /dev/null ) ; then \
	  echo Updating $(AP_SYSDIR)/httpd.conf ; \
	  echo "" >> $(AP_SYSDIR)/httpd.conf ; \
	  echo "# The following line was added by GSWeb " \
	    >> $(AP_SYSDIR)/httpd.conf ; \
	  echo "Include $(AP_SYSDIR)/$(MOD_CONF)" \
	    >> $(AP_SYSDIR)/httpd.conf ; \
	fi

clean:
	rm -f $(ADAPTOR) $(MOD_CONF) core *~
	rm -rf .libs ../common/.libs
	rm -f *.o *.la *.lo *.slo
	rm -f ../common/*.o ../common/*.la ../common/*.lo ../common/*.slo

distclean: clean
	rm -rf config.log config.status GNUmakefile autom4te.cache

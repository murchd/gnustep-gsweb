GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

GSWAPP_NAME = SimpleDemo
SimpleDemo_HAS_GSW_COMPONENTS = YES
SimpleDemo_PRINCIPAL_CLASS = SimpleDemo
#SimpleDemo_RESOURCE_FILES = Resources/SimpleDemo.eomodeld
SimpleDemo_OBJC_FILES = \
    SimpleDemo.m \
    Session.m \
    SimpleDemo_main.m \
    Main.m \
    Details.m


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/gswapp.make
-include GNUmakefile.postamble

#############################################################
# Required variables for each makefile
# Discard this section from all parent makefiles
# Expected variables (with automatic defaults):
#   CSRCS (all "C" files in the dir)
#   SUBDIRS (all subdirs with a Makefile)
#   GEN_LIBS - list of libs to be generated ()
#   GEN_IMAGES - list of object file images to be generated ()
#   GEN_BINS - list of binaries to be generated ()
#   COMPONENTS_xxx - a list of libs/objs in the form
#     subdir/lib to be extracted and rolled up into
#     a generated lib/image xxx.a ()
#
TARGET = eagle

USE_OPEN_LWIP = 140
USE_OPEN_DHCPS = 1

UP_EXTRACT_DIR = ..

ifndef PDIR # {
GEN_LIBS = libsdk.a
SUBDIRS =	\
	system	\
	phy		\
	wpa		

ifdef USE_OPEN_LWIP
SUBDIRS += lwip
endif

endif # } PDIR

APPDIR = .

COMPONENTS_libsdk = \
	system/libaddmmain.a	\
	phy/libaddmphy.a	\
	wpa/libaddwpa.a	

ifdef USE_OPEN_LWIP
COMPONENTS_libsdk += lwip/liblwip.a	
endif


CONFIGURATION_DEFINES =	-D__ets__ \
			-DICACHE_FLASH	\
			-DPBUF_RSV_FOR_WLAN	\
			-DLWIP_OPEN_SRC	\
			-DEBUF_LWIP

ifdef USE_OPEN_LWIP
CONFIGURATION_DEFINES +=-DUSE_OPEN_LWIP
endif 

ifdef USE_OPEN_DHCPS
CONFIGURATION_DEFINES +=-DUSE_OPEN_DHCPS
endif 


DEFINES +=				\
	$(UNIVERSAL_TARGET_DEFINES)	\
	$(CONFIGURATION_DEFINES)

DDEFINES +=				\
	$(UNIVERSAL_TARGET_DEFINES)	\
	$(CONFIGURATION_DEFINES)


#############################################################
# Recursion Magic - Don't touch this!!
#
# Each subtree potentially has an include directory
#   corresponding to the common APIs applicable to modules
#   rooted at that subtree. Accordingly, the INCLUDE PATH
#   of a module can only contain the include directories up
#   its parent path, and not its siblings
#
# Required for each makefile to inherit from the parent
#

INCLUDES := $(INCLUDES) -I $(PDIR)include
INCLUDES += -I ./
PDIR := ../$(PDIR)
sinclude $(PDIR)Makefile


.PHONY: FORCE
FORCE:

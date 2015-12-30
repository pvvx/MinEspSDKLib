include rules.mk
include image.mk

CFLAGS += -std=gnu90 -Os
CFLAGS += -Wall -Wno-pointer-sign
CFLAGS += -fno-tree-ccp -foptimize-register-move
CFLAGS += -mno-target-align -mno-serialize-volatile

CDEFS += \
  ICACHE_FLASH \
  PBUF_RSV_FOR_WLAN \
  LWIP_OPEN_SRC \
  EBUF_LWIP

CFLAGS += -Wundef -Wpointer-arith -Werror
CFLAGS += -Wl,-EL -fno-inline-functions -nostdlib
CFLAGS += -mlongcalls -mtext-section-literals

CDIRS += include

TARGET.LIBS += lwip/api/liblwipapi
lwip/api/liblwipapi.SRCS = $(wildcard src/lwip/api/*.c)

TARGET.LIBS += lwip/app/liblwipapp
lwip/app/liblwipapp.SRCS = $(wildcard src/lwip/app/*.c)

TARGET.LIBS += lwip/core/liblwipcore
lwip/core/liblwipcore.SRCS = $(wildcard src/lwip/core/*.c)

TARGET.LIBS += lwip/core/ipv4/liblwipipv4
lwip/core/ipv4/liblwipipv4.SRCS = $(wildcard src/lwip/core/ipv4/*.c)

TARGET.LIBS += lwip/netif/liblwipnetif
lwip/netif/liblwipnetif.SRCS = $(wildcard src/lwip/netif/*.c)

TARGET.LIBS += lwip/liblwip
lwip/liblwip.DEPLIBS += \
  lwip/api/liblwipapi \
  lwip/app/liblwipapp \
  lwip/core/liblwipcore \
  lwip/core/ipv4/liblwipipv4 \
  lwip/netif/liblwipnetif

TARGET.LIBS += phy/libaddmphy
phy/libaddmphy.SRCS = $(wildcard src/phy/*.c)

TARGET.LIBS += pp/libaddpp
pp/libaddpp.SRCS = $(wildcard src/pp/*.c)

TARGET.LIBS += system/libaddmmain
system/libaddmmain.SRCS = $(wildcard src/system/*.c)

TARGET.LIBS += wpa/libaddwpa
wpa/libaddwpa.SRCS = $(wildcard src/wpa/*.c)

TARGET.LIBS += libsdk
libsdk.DEPLIBS += \
  system/libaddmmain \
  phy/libaddmphy \
  pp/libaddpp \
  wpa/libaddwpa

USE_OPEN_LWIP ?= 140
USE_OPEN_DHCPS ?= 1

ifneq (,$(USE_OPEN_LWIP))
  libsdk.DEPLIBS += lwip/liblwip
  CDEFS += USE_OPEN_LWIP
endif

ifneq (,$(USE_OPEN_DHCPS))
  CDEFS += USE_OPEN_DHCPS
endif

libsdk.DEPLIBS += $(addprefix esp/,\
  libmgcc \
  libmmain \
  libmphy \
  libpp \
  libmwpa \
  libnet80211)

ifeq (,$(USE_OPEN_LWIP))
  libsdk.DEPLIBS += $(addprefix esp/,\
    liblwipif \
    libmlwip)
endif

ifeq (,$(USE_OPEN_DHCPS))
  libsdk.DEPLIBS += esp/libdhcps
endif

# Application

LDSCRIPTS += \
  ld/eagle.app.v6.ld \
  ld/eagle.rom.addr.v6.ld
LDFLAGS += \
  -nostartfiles \
	-nodefaultlibs \
	-nostdlib \
  -Tld/eagle.app.v6.ld \
	-Wl,--no-check-sections	\
  -u call_user_start \
  -Wl,-static

TARGET.LIBS += libdummy_app
libdummy_app.SRCS += $(wildcard example/dummy_app/*.c)

TARGET.IMGS += dummy_app
dummy_app.DEPLIBS += libsdk libdummy_app

TARGET.LIBS += libmem_usage
libmem_usage.SRCS += $(wildcard example/mem_usage/*.c)

TARGET.IMGS += mem_usage
mem_usage.DEPLIBS += libsdk libmem_usage

$(foreach lib,$(TARGET.LIBS),$(eval $(call LIB_RULES,$(lib))))
$(foreach img,$(TARGET.IMGS),$(eval $(call IMG_RULES,$(img))))

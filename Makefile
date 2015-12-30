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
lwip/api/liblwipapi.SRCS = $(wildcard app/sdklib/lwip/api/*.c)

TARGET.LIBS += lwip/app/liblwipapp
lwip/app/liblwipapp.SRCS = $(wildcard app/sdklib/lwip/app/*.c)

TARGET.LIBS += lwip/core/liblwipcore
lwip/core/liblwipcore.SRCS = $(wildcard app/sdklib/lwip/core/*.c)

TARGET.LIBS += lwip/core/ipv4/liblwipipv4
lwip/core/ipv4/liblwipipv4.SRCS = $(wildcard app/sdklib/lwip/core/ipv4/*.c)

TARGET.LIBS += lwip/netif/liblwipnetif
lwip/netif/liblwipnetif.SRCS = $(wildcard app/sdklib/lwip/netif/*.c)

TARGET.LIBS += lwip/liblwip
lwip/liblwip.DEPLIBS += \
  lwip/api/liblwipapi \
  lwip/app/liblwipapp \
  lwip/core/liblwipcore \
  lwip/core/ipv4/liblwipipv4 \
  lwip/netif/liblwipnetif

TARGET.LIBS += phy/libaddmphy
phy/libaddmphy.SRCS = $(wildcard app/sdklib/phy/*.c)

TARGET.LIBS += pp/libaddpp
pp/libaddpp.SRCS = $(wildcard app/sdklib/pp/*.c)

TARGET.LIBS += system/libaddmmain
system/libaddmmain.SRCS = $(wildcard app/sdklib/system/*.c)

TARGET.LIBS += wpa/libaddwpa
wpa/libaddwpa.SRCS = $(wildcard app/sdklib/wpa/*.c)

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

TARGET.LIBS += libuser
libuser.SRCS += $(wildcard app/user/*.c)
libuser.LDSCRIPTS += \
  ld/eagle.app.v6.ld \
  ld/eagle.rom.addr.v6.ld

user.DEPLIBS += libsdk libuser
user.LDFLAGS += \
  -nostartfiles \
	-nodefaultlibs \
	-nostdlib \
  -Tld/eagle.app.v6.ld \
	-Wl,--no-check-sections	\
  -u call_user_start \
  -Wl,-static

$(foreach target,$(TARGET.LIBS),$(eval $(call LIB_RULES,$(target))))
$(eval $(call IMG_RULES,user))

# Path patterns
IMG_P = bin/$(1).bin

# Programing setup
ESPTOOL ?= esptool.py
ESPTOOL_OPTION ?= -p /dev/ttyUSB0 -b 256000

# Image
DEFAULT_ADDR := 0x7C000
DEFAULT_BIN := $(call BIN_P,esp_init_data_default)

BLANK_ADDR := 0x7E000
BLANK_BIN := $(call BIN_P,blank)

CLEAR_EEP_ADDR := 0x79000
CLEAR_EEP_BIN := $(call BIN_P,clear_eep)

# 40 or 80 [MHz]
FLASH_SPEED_MHZ ?= 80
# QIO, DIO, QOUT, DOUT
FLASH_MODE ?= QIO
# Use 512 for all size Flash (512 kbytes .. 16 Mbytes Flash autodetect)
FLASH_SIZE_KB ?= 512

ifeq ($(FLASH_SPEED_MHZ),26.7)
  FLASH_FREQ_DIV := 1
  FLASH_FREQ := 26
else
  ifeq ($(FLASH_SPEED_MHZ),20)
    FLASH_FREQ_DIV := 2
    FLASH_FREQ := 20
  else
    ifeq ($(FLASH_SPEED_MHZ),80)
      FLASH_FREQ_DIV := 15
      FLASH_FREQ := 80
    else
      FLASH_FREQ_DIV := 0
      FLASH_FREQ := 40
    endif
  endif
endif

ifeq ($(FLASH_MODE),QOUT)
  FLASH_MODE_ID := 1
  FLASH_MODE_NAME := qout
else
  ifeq ($(FLASH_MODE),DIO)
    FLASH_MODE_ID := 2
    FLASH_MODE_NAME := dio
  else
    ifeq ($(FLASH_MODE),DOUT)
      FLASH_MODE_ID := 3
      FLASH_MODE_NAME := dout
    else
      FLASH_MODE_ID := 0
      FLASH_MODE_NAME := qio
    endif
  endif
endif

# flash larger than 1024KB only use 1024KB to storage user1.bin and user2.bin
ifeq ($(FLASH_SIZE_KB),256)
  FLASH_SIZE_ID := 1
  FLASH_SIZE_USER_KB := 256
  FLASH_SIZE_MBITS := 2
else
  ifeq ($(FLASH_SIZE_KB),1024)
    FLASH_SIZE_ID := 2
    FLASH_SIZE_USER_KB := 1024
    FLASH_SIZE_MBITS := 8
  else
    ifeq ($(FLASH_SIZE_KB),2048)
      FLASH_SIZE_ID := 3
      FLASH_SIZE_USER_KB := 1024
      FLASH_SIZE_MBITS := 16
    else
      ifeq ($(FLASH_SIZE_KB),4096)
        FLASH_SIZE_ID := 4
        FLASH_SIZE_USER_KB := 1024
        FLASH_SIZE_MBITS := 32
      else
        FLASH_SIZE_ID := 0
        FLASH_SIZE_USER_KB := 512
        FLASH_SIZE_MBITS := 4
      endif
    endif
  endif
endif

CDEFS += USE_FIX_QSPI_FLASH=$(FLASH_SPEED_MHZ)

IMG_OPTION ?= -ff $(FLASH_FREQ)m -fm $(FLASH_MODE_NAME) -fs $(FLASH_SIZE_MBITS)m

IMG1_ADDR := 0x00000
IMG2_ADDR := 0x40000

# Image rules
define IMG_RULES
$$(eval $$(call BIN_RULES,$(1)))

$(1).IMG := $$(call IMG_P,$(1))

build: build.img.$(1)
build.img.$(1): $$($(1).IMG)

$$($(1).IMG): $$($(1).BIN)
	@echo TARGET $(1) IMAGE
	$(Q)mkdir -p $$(dir $$@)
	$(Q)$(OBJCOPY) --only-section .lit4 -O binary $$< $$(call IMG_P,$(1)-addld)
	$(Q)$(ESPTOOL) elf2image -o $$(dir $$@)$(1)- $(IMG_OPTION) $$<
	$(Q)$(ESPTOOL) image_info $$(call IMG_P,$(1)-$(IMG1_ADDR))
	$(Q)cp -f $$(call IMG_P,$(1)-$(IMG1_ADDR)) $$@
	$(Q)dd if=$$(call IMG_P,$(1)-addld) >>$$@

clean: clean.img.$(1)
clean.img.$(1):
	@echo TARGET $(1) IMG CLEAN
	$(Q)rm -f $$($(1).IMG) $$(call IMG_P,$(1)-addld) $$(call IMG_P,$(1)-$(IMG1_ADDR)) $$(call IMG_P,$(1)-$(IMG2_ADDR))
endef

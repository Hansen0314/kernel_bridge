# Do not:
# o  use make's built-in rules and variables
#    (this increases performance and avoids hard-to-debug behaviour);
# o  print "Entering directory ...";
MAKEFLAGS += -rR --no-print-directory
# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif

ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif
ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif
# If the user is running make -s (silent mode), suppress echoing of
# commands

ifneq ($(filter 4.%,$(MAKE_VERSION)),)	# make-4
ifneq ($(filter %s ,$(firstword x$(MAKEFLAGS))),)
  quiet=silent_
endif
else					# make-3.8x
ifneq ($(filter s% -s%,$(MAKEFLAGS)),)
  quiet=silent_
endif
endif

export quiet Q KBUILD_VERBOSE
MOD_PATH := $(shell pwd)/modules
SRC_FOLDER := $(shell find $(MOD_PATH) -maxdepth 1 -type d)
BASE_SRC_FOLDER := $(basename $(patsubst $(MOD_PATH)/%, %, $(SRC_FOLDER)))
BASE_SRC_FOLDER := $(filter-out $(MOD_PATH), $(BASE_SRC_FOLDER))

uname_r = $(shell uname -r)
KBUILD ?= /usr/src/linux-headers-$(uname_r)
KO_DIR ?= /lib/modules/$(uname_r)/extra/seeed
make_options="CROSS_COMPILE=${CC} KDIR=${x86_dir}/KERNEL"

all:
	@for dir in ${BASE_SRC_FOLDER}; do make -C $(KBUILD) M=$(MOD_PATH)/$$dir ||exit; done


clean:
	@for dir in ${BASE_SRC_FOLDER}; do make -C $(KBUILD) M=$(MOD_PATH)/$$dir clean ||exit; done

install:
	mkdir -p /lib/modules/$(uname_r)/extra/seeed || true
	@for dir in ${BASE_SRC_FOLDER}; do cp $(MOD_PATH)/$$dir/*.ko $(KO_DIR) ||exit; done
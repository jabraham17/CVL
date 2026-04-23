SLEEF_DIR := $(shell pwd)/sleef-install
OS := $(shell uname -s)

SLEEF_ARGS := --set useSLEEF --set SLEEF_INSTALL='$(SLEEF_DIR)'
ifeq ($(OS),Linux)
	SLEEF_ARGS += --ccflags=-Wno-unused-command-line-argument --ccflags=-no-pie --ldflags=-no-pie
endif

.PHONY: all
all: $(SLEEF_DIR)/lib/libsleef.a

$(SLEEF_DIR)/lib/libsleef.a:
	./install.sh

.PHONY: printchplflags
printchplflags:
	$(info $(SLEEF_ARGS))

.PHONY: clean
clean:
	./clean.sh

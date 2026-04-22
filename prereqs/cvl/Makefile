ARCH := $(shell uname -m)

X86_ARGS := --ccflags=-msse4.1 --ccflags=-mavx2 --ccflags=-mfma
ARM_ARGS := --ccflags=-march=armv8.2-a+fp16

FLAGS :=
ifeq ($(ARCH),x86_64)
	FLAGS += $(X86_ARGS)
else ifeq ($(ARCH),aarch64)
	FLAGS += $(ARM_ARGS)
else ifeq ($(ARCH),arm64)
	FLAGS += $(ARM_ARGS)
endif

.PHONY: all
all:
	@if [ "$(ARCH)" != "x86_64" ] && [ "$(ARCH)" != "aarch64" ] && [ "$(ARCH)" != "arm64" ]; then \
		echo "Unsupported architecture for CVL: $(ARCH)"; \
		exit 1; \
	fi

.PHONY: printchplflags
printchplflags:
	$(info $(FLAGS))

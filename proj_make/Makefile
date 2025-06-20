SRV32_PATH = /home/nikhil/srv32-build/srv32
SRV32_MAKEFILE = $(SRV32_PATH)/Makefile
SW_PROJ_MAKEFILE = $(SRV32_PATH)/proj_make/Makefile

PROJ ?= 
SRC_TXT_TO_REPLACE = /src/file/name
SRC_FILE = $(PROJ).c

ifneq ($(PROJ),)
	FULL_PROJ_PATH := $(SRV32_PATH)/sw/$(PROJ)
endif

default: create-srv32-project
.PHONY: default create-srv32-project

create-srv32-project:
	@echo "Creating srv32 project..."
	@if [ -z "$(FULL_PROJ_PATH)" ]; then \
		echo "[NO_PROJ_SPECIFIED]: Failed to generate the FULL_PROJ_PATH , please set PROJ variable so absolute path can be set to FULL_PROJ_PATH var "; \
		exit 1; \
	fi
	mkdir -p $(FULL_PROJ_PATH)
	sed "s|$(SRC_TXT_TO_REPLACE)|$(SRC_FILE)|" $(SW_PROJ_MAKEFILE) > $(FULL_PROJ_PATH)/Makefile
	touch $(FULL_PROJ_PATH)/$(SRC_FILE)
	@echo "Project created at $(FULL_PROJ_PATH) with SRC_FILE: $(SRC_FILE)"
	code $(FULL_PROJ_PATH)/


run-srv32:
	make -f $(SRV32_MAKEFILE) $(PROJ)
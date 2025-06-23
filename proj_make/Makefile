SRV32_PATH = /home/nikhil/srv32-build/srv32
SRV32_MAKEFILE = $(SRV32_PATH)/Makefile
SW_PROJ_MAKEFILE = $(SRV32_PATH)/proj_make/Makefile.sw

RTL_DIR = $(SRV32_PATH)/rtl
TESTBENCH_DIR = $(SRV32_PATH)/testbench

PROJ ?= 
PROJECT_NAME ?=

BOARD  ?= nexysvideo
CONSTR ?= $(BOARD).xdc
ifeq ($(BOARD), nexysvideo)
  PART     ?= xc7a200tsbg484-1
  DIFF_CLK ?= 0
  CLK_PER  ?= 10.0
else
ifeq ($(BOARD), genesys2)
  PART     ?= xc7k325tffg900-2
  DIFF_CLK ?= 1
  CLK_PER  ?= 5.0
else
ifeq ($(BOARD), xc7vx690tffg1157)
  PART     ?= xc7vx690tffg1157-3
  DIFF_CLK ?= 0
  CLK_PER  ?= 20.0
else
ifeq ($(BOARD), nexysa7)
  PART     ?= xc7a100tcsg324-1
  DIFF_CLK ?= 0
  CLK_PER  ?= 10.0
endif
endif
endif
endif

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

create-vivado-proj:
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "[NO_PROJ_NAME_SPECIFIED]: KINDLY PROVIDE PROJECT NAME FOR VIVADO PROJECT "; \
		exit 1; \
	fi
	mkdir -p $(FULL_PROJ_PATH)/vivado_project
	vivado -mode tcl -source $(SRV32_PATH)/proj_make/vivado_proj_gen.tcl -tclargs $(RTL_DIR) \
	$(TESTBENCH_DIR) $(PROJECT_NAME) $(FULL_PROJ_PATH)/vivado_project $(PART) $(CONSTR)
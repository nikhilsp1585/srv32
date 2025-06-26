
include ../common/Makefile.common

EXE      = .elf
SRC      = vle32_test_srv32.c
CFLAGS  += -L../common
LDFLAGS += -T ../common/default.ld
TARGET   = $(basename $(SRC))
OUTPUT   = $(TARGET)$(EXE)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	@echo "$(memsize)"
	$(CC) $(CFLAGS) -o $(OUTPUT) $(SRC) $(LDFLAGS)
	$(OBJDUMP) -d $(OUTPUT) > $(TARGET).dis
	$(READELF) -a $(OUTPUT) > $(TARGET).symbol

clean:
	$(RM) *.o $(OUTPUT) $(TARGET).dis $(TARGET).symbol

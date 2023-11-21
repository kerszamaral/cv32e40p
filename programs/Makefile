###############################################################################
# Common variables
BANNER=*******************************************************************************************
dir	  			 ?= $*
TEST_FILES        = $(filter %.c %.S,$(wildcard  $(dir)/*))
FILES_DIR 		 ?= $(dir)/
BIN_PATH		  = bin

ifeq ($(CV_SW_TOOLCHAIN),) 
RISCV 		  = /opt/riscv
else
RISCV 		  = $(CV_SW_TOOLCHAIN)
endif

ifeq ($(CV_SW_PREFIX),)
RISCV_PREFIX  = riscv32-unknown-elf-
else
RISCV_PREFIX  = $(CV_SW_PREFIX)
endif

RISCV_EXE_PREFIX = $(RISCV)/bin/$(RISCV_PREFIX)

DATA_WIDTH 		?= 4

%.coe: %.hex
	@echo "$(BANNER)"
	@echo "* Generating coe file"
	@echo "$(BANNER)"
	$(BIN_PATH)/hex2coe $(FILES_DIR)$*.hex $(FILES_DIR)$*.coe

###############################################################################
# Rule to generate hex (loadable by simulators) from elf
#    $@ is the file being generated.
#    $< is first prerequiste.
#    $^ is all prerequistes.
#    $* is file_name (w/o extension) of target
%.hex: %.elf
	@echo "$(BANNER)"
	@echo "* Generating hexfile, readelf and objdump files"
	@echo "$(BANNER)"
	$(RISCV_EXE_PREFIX)objcopy -O verilog \
		$(FILES_DIR)$< \
		--verilog-data-width $(DATA_WIDTH) \
		$(FILES_DIR)$*.hex
	$(RISCV_EXE_PREFIX)readelf -a $(FILES_DIR)$< > $(FILES_DIR)$*.readelf
	$(RISCV_EXE_PREFIX)objdump \
		-d \
		-M no-aliases \
		-M numeric \
		-S \
		$(FILES_DIR)$*.elf > $(FILES_DIR)$*.objdump
	$(RISCV_EXE_PREFIX)objdump \
    	-d \
        -S \
		-M no-aliases \
		-M numeric \
        -l \
		$(FILES_DIR)$*.elf | ${BIN_PATH}/objdump2itb - > $(FILES_DIR)$*.itb

# Patterned targets to generate ELF.  Used only if explicit targets do not match.
#
.PRECIOUS : %.elf


ifeq ($(CV_SW_MARCH),)
RISCV_MARCH      = rv32imczicsr
else
RISCV_MARCH      = $(CV_SW_MARCH)
endif

RISCV_CC         = gcc
RISCV_CFLAGS     = $(CV_SW_CFLAGS)
TEST_CFLAGS 	+=  -Wall -pedantic -Wl,--no-warn-rwx-segments
MAP_FILE 		 = -Xlinker -Map=$(FILES_DIR)$*.map

LD_LIBRARY 	= bsp/crt0.S bsp/handlers.S bsp/syscalls.c bsp/vectors.S
LD_FILE 	= bsp/link.ld

ASM = asm
BSP = bsp

%.elf: $(TEST_FILES)
	@echo "$(BANNER)"
	@echo "* Compiling test-program $@"
	@echo "$(BANNER)"
	$(RISCV_EXE_PREFIX)$(RISCV_CC) \
		-march=$(RISCV_MARCH) \
		-o $(FILES_DIR)$@ \
		-w -Os \
		-g -static \
		-nostartfiles -nostdlib \
		$(RISCV_CFLAGS) \
		$(TEST_CFLAGS) \
		$(MAP_FILE) \
		$(TEST_FILES) \
		-I $(ASM) \
		-I $(BSP) \
		-I $(RISCV)/riscv32-unknown-elf/include \
		-T $(LD_FILE) \
		$(LD_LIBRARY) \
		-L $(RISCV)/riscv32-unknown-elf/lib \
		-lc -lm -lgcc

%.cln:
	@echo "$(BANNER)"
	@echo "* Cleaning test-program $@"
	@echo "$(BANNER)"
	@rm -rf $(FILES_DIR)$*.elf $(FILES_DIR)$*.hex $(FILES_DIR)$*.readelf $(FILES_DIR)$*.objdump $(FILES_DIR)$*.map $(FILES_DIR)$*.itb $(FILES_DIR)$*.coe

clean:
	rm -rf *.elf *.hex *.readelf *.objdump *.map *.itb *.coe

clean_all:
	rm -rf *.elf *.hex *.readelf *.objdump *.map *.itb *.coe
	rm -rf */*.elf */*.hex */*.readelf */*.objdump */*.map */*.itb */*.coe
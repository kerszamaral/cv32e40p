###############################################################################
# Common variables
BANNER=*******************************************************************************************
dir	  			 ?= $*
TEST_FILES        = $(filter %.c %.S,$(wildcard  $(dir)/*))
BIN_PATH		  = bin


RISCV            = $(CV_SW_TOOLCHAIN)
RISCV_PREFIX     = $(CV_SW_PREFIX)
RISCV_EXE_PREFIX = $(RISCV)/bin/$(RISCV_PREFIX)

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
		$< \
		prog.hex
	$(RISCV_EXE_PREFIX)readelf -a $< > $*.readelf
	$(RISCV_EXE_PREFIX)objdump \
		-d \
		-M no-aliases \
		-M numeric \
		-S \
		$*.elf > $*.objdump
	$(RISCV_EXE_PREFIX)objdump \
    	-d \
        -S \
		-M no-aliases \
		-M numeric \
        -l \
		$*.elf | ${BIN_PATH}/objdump2itb - > $*.itb

# Patterned targets to generate ELF.  Used only if explicit targets do not match.
#
.PRECIOUS : %.elf

RISCV_MARCH      = $(CV_SW_MARCH)
RISCV_CC         = gcc
RISCV_CFLAGS     = $(CV_SW_CFLAGS)
TEST_CFLAGS 	+=  -Wall -pedantic -Wl,--no-warn-rwx-segments
MAP_FILE 		 = -Xlinker -Map=$*.map

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
		-o $@ \
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

clean:
	rm -rf *.elf *.hex *.readelf *.objdump *.map *.itb
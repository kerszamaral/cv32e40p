###############################################################################
# Common variables
BANNER=*******************************************************************************************
TEST_TEST_DIR	  = 
TEST_FILES        = $(filter %.c %.S,$(wildcard  $(TEST_TEST_DIR)/*))
BIN_PATH		  = programs/bin


RISCV            = $(CV_SW_TOOLCHAIN)
RISCV_PREFIX     = $(CV_SW_PREFIX)
RISCV_EXE_PREFIX = $(RISCV)/bin/$(RISCV_PREFIX)

RISCV_MARCH      = $(CV_SW_MARCH)
RISCV_CC         = $(CV_SW_CC)
RISCV_CFLAGS     = $(CV_SW_CFLAGS)

CFLAGS ?= -Os -g -static -mabi=ilp32 -march=$(RISCV_MARCH) -Wall -pedantic $(RISCV_CFLAGS)

SIM_TEST_PROGRAM_RESULTS

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
		$@
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


# If a test defines "default_cflags" in its yaml, then it is responsible to define ALL flags
# Otherwise add the default cflags in the variable CFLAGS defined above
ifneq ($(TEST_DEFAULT_CFLAGS),)
TEST_CFLAGS += $(TEST_DEFAULT_CFLAGS)
else
TEST_CFLAGS += $(CFLAGS)
endif

# Optionally use linker script provided in test directory
# this must be evaluated at access time, so ifeq/ifneq does
# not get parsed correctly
TEST_RESULTS_LD = $(addprefix $(SIM_TEST_PROGRAM_RESULTS)/, link.ld)
TEST_LD         = $(addprefix $(TEST_TEST_DIR)/, link.ld)

LD_LIBRARY 	= $(if $(wildcard $(TEST_RESULTS_LD)),-L $(SIM_TEST_PROGRAM_RESULTS),$(if $(wildcard $(TEST_LD)),-L $(TEST_TEST_DIR),))
LD_FILE 	= $(if $(wildcard $(TEST_RESULTS_LD)),$(TEST_RESULTS_LD),$(if $(wildcard $(TEST_LD)),$(TEST_LD),$(BSP)/link.ld))
LD_LIBRARY += -L $(SIM_BSP_RESULTS)

%.elf: $(TEST_FILES)
	mkdir -p $(SIM_TEST_PROGRAM_RESULTS)
	make bsp
	@echo "$(BANNER)"
	@echo "* Compiling test-program $@"
	@echo "$(BANNER)"
	$(RISCV_EXE_PREFIX)$(RISCV_CC) \
		$(CFG_CFLAGS) \
		$(TEST_CFLAGS) \
		$(RISCV_CFLAGS) \
		-I $(ASM) \
		-I $(BSP) \
		-o $@ \
		-nostartfiles \
		$(TEST_FILES) \
		-T $(LD_FILE) \
		$(LD_LIBRARY) \
		-lcv-verif

.PHONY: hex

# Shorthand target to only build the firmware using the hex and elf suffix rules above
hex: $(SIM_TEST_PROGRAM_RESULTS)/$(TEST_PROGRAM)$(OPT_RUN_INDEX_SUFFIX).hex
// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Matthias Baer - baermatt@student.ethz.ch                   //
//                                                                            //
// Additional contributions by:                                               //
//                 Sven Stucki - svstucki@student.ethz.ch                     //
//                                                                            //
//                                                                            //
// Design Name:    RISC-V processor core                                      //
// Project Name:   RI5CY                                                      //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Defines for various constants used by the processor core.  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

package cv32e40p_pkg;

  ////////////////////////////////////////////////
  //    ___         ____          _             //
  //   / _ \ _ __  / ___|___   __| | ___  ___   //
  //  | | | | '_ \| |   / _ \ / _` |/ _ \/ __|  //
  //  | |_| | |_) | |__| (_) | (_| |  __/\__ \  //
  //   \___/| .__/ \____\___/ \__,_|\___||___/  //
  //        |_|                                 //
  ////////////////////////////////////////////////

  localparam OPCODE_SYSTEM = 7'h73;
  localparam OPCODE_FENCE = 7'h0f;
  localparam OPCODE_OP = 7'h33;
  localparam OPCODE_OPIMM = 7'h13;
  localparam OPCODE_STORE = 7'h23;
  localparam OPCODE_LOAD = 7'h03;
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JALR = 7'h67;
  localparam OPCODE_JAL = 7'h6f;
  localparam OPCODE_AUIPC = 7'h17;
  localparam OPCODE_LUI = 7'h37;
  localparam OPCODE_OP_FP = 7'h53;
  localparam OPCODE_OP_FMADD = 7'h43;
  localparam OPCODE_OP_FNMADD = 7'h4f;
  localparam OPCODE_OP_FMSUB = 7'h47;
  localparam OPCODE_OP_FNMSUB = 7'h4b;
  localparam OPCODE_STORE_FP = 7'h27;
  localparam OPCODE_LOAD_FP = 7'h07;
  localparam OPCODE_AMO = 7'h2F;

  // Those custom opcodes are used for PULP custom instructions
  localparam OPCODE_CUSTOM_0 = 7'h0b;
  localparam OPCODE_CUSTOM_1 = 7'h2b;
  localparam OPCODE_CUSTOM_2 = 7'h5b;
  localparam OPCODE_CUSTOM_3 = 7'h7b;

  localparam REGC_S1 = 2'b10;
  localparam REGC_S4 = 2'b00;
  localparam REGC_RD = 2'b01;
  localparam REGC_ZERO = 2'b11;

  //////////////////////////////////////////////////////////////////////////////
  //      _    _    _   _    ___                       _   _                  //
  //     / \  | |  | | | |  / _ \ _ __   ___ _ __ __ _| |_(_) ___  _ __  ___  //
  //    / _ \ | |  | | | | | | | | '_ \ / _ \ '__/ _` | __| |/ _ \| '_ \/ __| //
  //   / ___ \| |__| |_| | | |_| | |_) |  __/ | | (_| | |_| | (_) | | | \__ \ //
  //  /_/   \_\_____\___/   \___/| .__/ \___|_|  \__,_|\__|_|\___/|_| |_|___/ //
  //                             |_|                                          //
  //////////////////////////////////////////////////////////////////////////////

  localparam ALU_OP_WIDTH = 7;

  typedef enum logic [ALU_OP_WIDTH-1:0] {

    ALU_ADD   = 7'b0011000,
    ALU_SUB   = 7'b0011001,
    ALU_ADDU  = 7'b0011010,
    ALU_SUBU  = 7'b0011011,
    ALU_ADDR  = 7'b0011100,
    ALU_SUBR  = 7'b0011101,
    ALU_ADDUR = 7'b0011110,
    ALU_SUBUR = 7'b0011111,

    ALU_XOR = 7'b0101111,
    ALU_OR  = 7'b0101110,
    ALU_AND = 7'b0010101,

    // Shifts
    ALU_SRA = 7'b0100100,
    ALU_SRL = 7'b0100101,
    ALU_ROR = 7'b0100110,
    ALU_SLL = 7'b0100111,

    // bit manipulation
    ALU_BEXT  = 7'b0101000,
    ALU_BEXTU = 7'b0101001,
    ALU_BINS  = 7'b0101010,
    ALU_BCLR  = 7'b0101011,
    ALU_BSET  = 7'b0101100,
    ALU_BREV  = 7'b1001001,

    // Bit counting
    ALU_FF1 = 7'b0110110,
    ALU_FL1 = 7'b0110111,
    ALU_CNT = 7'b0110100,
    ALU_CLB = 7'b0110101,

    // Sign-/zero-extensions
    ALU_EXTS = 7'b0111110,
    ALU_EXT  = 7'b0111111,

    // Comparisons
    ALU_LTS = 7'b0000000,
    ALU_LTU = 7'b0000001,
    ALU_LES = 7'b0000100,
    ALU_LEU = 7'b0000101,
    ALU_GTS = 7'b0001000,
    ALU_GTU = 7'b0001001,
    ALU_GES = 7'b0001010,
    ALU_GEU = 7'b0001011,
    ALU_EQ  = 7'b0001100,
    ALU_NE  = 7'b0001101,

    // Set Lower Than operations
    ALU_SLTS  = 7'b0000010,
    ALU_SLTU  = 7'b0000011,
    ALU_SLETS = 7'b0000110,
    ALU_SLETU = 7'b0000111,

    // Absolute value
    ALU_ABS   = 7'b0010100,
    ALU_CLIP  = 7'b0010110,
    ALU_CLIPU = 7'b0010111,

    // Insert/extract
    ALU_INS = 7'b0101101,

    // min/max
    ALU_MIN  = 7'b0010000,
    ALU_MINU = 7'b0010001,
    ALU_MAX  = 7'b0010010,
    ALU_MAXU = 7'b0010011,

    // div/rem
    ALU_DIVU = 7'b0110000,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_DIV  = 7'b0110001,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REMU = 7'b0110010,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REM  = 7'b0110011,  // bit 0 is used for signed mode, bit 1 is used for remdiv

    ALU_SHUF  = 7'b0111010,
    ALU_SHUF2 = 7'b0111011,
    ALU_PCKLO = 7'b0111000,
    ALU_PCKHI = 7'b0111001

  } alu_opcode_e;

  localparam MUL_OP_WIDTH = 3;

  typedef enum logic [MUL_OP_WIDTH-1:0] {

    MUL_MAC32 = 3'b000,
    MUL_MSU32 = 3'b001,
    MUL_I     = 3'b010,
    MUL_IR    = 3'b011,
    MUL_DOT8  = 3'b100,
    MUL_DOT16 = 3'b101,
    MUL_H     = 3'b110

  } mul_opcode_e;

  // vector modes
  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;


  // FSM state encoding
  typedef enum logic [4:0] {
    RESET,
    BOOT_SET,
    SLEEP,
    WAIT_SLEEP,
    FIRST_FETCH,
    DECODE,
    IRQ_FLUSH_ELW,
    ELW_EXE,
    FLUSH_EX,
    FLUSH_WB,
    XRET_JUMP,
    DBG_TAKEN_ID,
    DBG_TAKEN_IF,
    DBG_FLUSH,
    DBG_WAIT_BRANCH,
    DECODE_HWLOOP
  } ctrl_state_e;

  // Debug FSM state encoding
  // State encoding done one-hot to ensure that debug_havereset_o, debug_running_o, debug_halted_o
  // will come directly from flip-flops. *_INDEX and debug_state_e encoding must match

  localparam HAVERESET_INDEX = 0;
  localparam RUNNING_INDEX = 1;
  localparam HALTED_INDEX = 2;

  typedef enum logic [2:0] {
    HAVERESET = 3'b001,
    RUNNING   = 3'b010,
    HALTED    = 3'b100
  } debug_state_e;

  typedef enum logic {
    IDLE,
    BRANCH_WAIT
  } prefetch_state_e;

  typedef enum logic [2:0] {
    IDLE_MULT,
    STEP0,
    STEP1,
    STEP2,
    FINISH
  } mult_state_e;

  /////////////////////////////////////////////////////////
  //    ____ ____    ____            _     _             //
  //   / ___/ ___|  |  _ \ ___  __ _(_)___| |_ ___ _ __  //
  //  | |   \___ \  | |_) / _ \/ _` | / __| __/ _ \ '__| //
  //  | |___ ___) | |  _ <  __/ (_| | \__ \ ||  __/ |    //
  //   \____|____/  |_| \_\___|\__, |_|___/\__\___|_|    //
  //                           |___/                     //
  /////////////////////////////////////////////////////////

  // CSRs mnemonics
  // imported form IBEX, some regs may be still not implemented
  typedef enum logic [11:0] {

    ///////////////////////////////////////////////////////
    // User CSRs
    ///////////////////////////////////////////////////////

    // User trap setup
    CSR_USTATUS = 12'h000,  // Not included (PULP_SECURE = 0)

    // Floating Point
    CSR_FFLAGS = 12'h001,  // Included if FPU = 1
    CSR_FRM    = 12'h002,  // Included if FPU = 1
    CSR_FCSR   = 12'h003,  // Included if FPU = 1

    // User trap setup
    CSR_UTVEC = 12'h005,  // Not included (PULP_SECURE = 0)

    // User trap handling
    CSR_UEPC   = 12'h041,  // Not included (PULP_SECURE = 0)
    CSR_UCAUSE = 12'h042,  // Not included (PULP_SECURE = 0)

    ///////////////////////////////////////////////////////
    // User Custom CSRs
    ///////////////////////////////////////////////////////

    // Hardware Loop
    CSR_LPSTART0 = 12'hCC0,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPEND0   = 12'hCC1,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPCOUNT0 = 12'hCC2,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPSTART1 = 12'hCC4,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPEND1   = 12'hCC5,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPCOUNT1 = 12'hCC6,  // Custom CSR. Included if PULP_HWLP = 1

    // User Hart ID
    CSR_UHARTID = 12'hCD0,  // Custom CSR. User Hart ID

    // Privilege
    CSR_PRIVLV = 12'hCD1,  // Custom CSR. Privilege Level

    // ZFINX
    CSR_ZFINX = 12'hCD2,  // Custom CSR. ZFINX

    ///////////////////////////////////////////////////////
    // Machine CSRs
    ///////////////////////////////////////////////////////

    // Machine trap setup
    CSR_MSTATUS = 12'h300,
    CSR_MISA    = 12'h301,
    CSR_MIE     = 12'h304,
    CSR_MTVEC   = 12'h305,

    // Performance counters
    CSR_MCOUNTEREN    = 12'h306,
    CSR_MCOUNTINHIBIT = 12'h320,
    CSR_MHPMEVENT3    = 12'h323,
    CSR_MHPMEVENT4    = 12'h324,
    CSR_MHPMEVENT5    = 12'h325,
    CSR_MHPMEVENT6    = 12'h326,
    CSR_MHPMEVENT7    = 12'h327,
    CSR_MHPMEVENT8    = 12'h328,
    CSR_MHPMEVENT9    = 12'h329,
    CSR_MHPMEVENT10   = 12'h32A,
    CSR_MHPMEVENT11   = 12'h32B,
    CSR_MHPMEVENT12   = 12'h32C,
    CSR_MHPMEVENT13   = 12'h32D,
    CSR_MHPMEVENT14   = 12'h32E,
    CSR_MHPMEVENT15   = 12'h32F,
    CSR_MHPMEVENT16   = 12'h330,
    CSR_MHPMEVENT17   = 12'h331,
    CSR_MHPMEVENT18   = 12'h332,
    CSR_MHPMEVENT19   = 12'h333,
    CSR_MHPMEVENT20   = 12'h334,
    CSR_MHPMEVENT21   = 12'h335,
    CSR_MHPMEVENT22   = 12'h336,
    CSR_MHPMEVENT23   = 12'h337,
    CSR_MHPMEVENT24   = 12'h338,
    CSR_MHPMEVENT25   = 12'h339,
    CSR_MHPMEVENT26   = 12'h33A,
    CSR_MHPMEVENT27   = 12'h33B,
    CSR_MHPMEVENT28   = 12'h33C,
    CSR_MHPMEVENT29   = 12'h33D,
    CSR_MHPMEVENT30   = 12'h33E,
    CSR_MHPMEVENT31   = 12'h33F,

    // Machine trap handling
    CSR_MSCRATCH = 12'h340,
    CSR_MEPC     = 12'h341,
    CSR_MCAUSE   = 12'h342,
    CSR_MTVAL    = 12'h343,
    CSR_MIP      = 12'h344,

    // Physical memory protection (PMP)
    CSR_PMPCFG0   = 12'h3A0,  // Not included (USE_PMP = 0)
    CSR_PMPCFG1   = 12'h3A1,  // Not included (USE_PMP = 0)
    CSR_PMPCFG2   = 12'h3A2,  // Not included (USE_PMP = 0)
    CSR_PMPCFG3   = 12'h3A3,  // Not included (USE_PMP = 0)
    CSR_PMPADDR0  = 12'h3B0,  // Not included (USE_PMP = 0)
    CSR_PMPADDR1  = 12'h3B1,  // Not included (USE_PMP = 0)
    CSR_PMPADDR2  = 12'h3B2,  // Not included (USE_PMP = 0)
    CSR_PMPADDR3  = 12'h3B3,  // Not included (USE_PMP = 0)
    CSR_PMPADDR4  = 12'h3B4,  // Not included (USE_PMP = 0)
    CSR_PMPADDR5  = 12'h3B5,  // Not included (USE_PMP = 0)
    CSR_PMPADDR6  = 12'h3B6,  // Not included (USE_PMP = 0)
    CSR_PMPADDR7  = 12'h3B7,  // Not included (USE_PMP = 0)
    CSR_PMPADDR8  = 12'h3B8,  // Not included (USE_PMP = 0)
    CSR_PMPADDR9  = 12'h3B9,  // Not included (USE_PMP = 0)
    CSR_PMPADDR10 = 12'h3BA,  // Not included (USE_PMP = 0)
    CSR_PMPADDR11 = 12'h3BB,  // Not included (USE_PMP = 0)
    CSR_PMPADDR12 = 12'h3BC,  // Not included (USE_PMP = 0)
    CSR_PMPADDR13 = 12'h3BD,  // Not included (USE_PMP = 0)
    CSR_PMPADDR14 = 12'h3BE,  // Not included (USE_PMP = 0)
    CSR_PMPADDR15 = 12'h3BF,  // Not included (USE_PMP = 0)

    // Trigger
    CSR_TSELECT  = 12'h7A0,
    CSR_TDATA1   = 12'h7A1,
    CSR_TDATA2   = 12'h7A2,
    CSR_TDATA3   = 12'h7A3,
    CSR_TINFO    = 12'h7A4,
    CSR_MCONTEXT = 12'h7A8,
    CSR_SCONTEXT = 12'h7AA,

    // Debug/trace
    CSR_DCSR = 12'h7B0,
    CSR_DPC  = 12'h7B1,

    // Debug
    CSR_DSCRATCH0 = 12'h7B2,
    CSR_DSCRATCH1 = 12'h7B3,

    // Hardware Performance Monitor
    CSR_MCYCLE        = 12'hB00,
    CSR_MINSTRET      = 12'hB02,
    CSR_MHPMCOUNTER3  = 12'hB03,
    CSR_MHPMCOUNTER4  = 12'hB04,
    CSR_MHPMCOUNTER5  = 12'hB05,
    CSR_MHPMCOUNTER6  = 12'hB06,
    CSR_MHPMCOUNTER7  = 12'hB07,
    CSR_MHPMCOUNTER8  = 12'hB08,
    CSR_MHPMCOUNTER9  = 12'hB09,
    CSR_MHPMCOUNTER10 = 12'hB0A,
    CSR_MHPMCOUNTER11 = 12'hB0B,
    CSR_MHPMCOUNTER12 = 12'hB0C,
    CSR_MHPMCOUNTER13 = 12'hB0D,
    CSR_MHPMCOUNTER14 = 12'hB0E,
    CSR_MHPMCOUNTER15 = 12'hB0F,
    CSR_MHPMCOUNTER16 = 12'hB10,
    CSR_MHPMCOUNTER17 = 12'hB11,
    CSR_MHPMCOUNTER18 = 12'hB12,
    CSR_MHPMCOUNTER19 = 12'hB13,
    CSR_MHPMCOUNTER20 = 12'hB14,
    CSR_MHPMCOUNTER21 = 12'hB15,
    CSR_MHPMCOUNTER22 = 12'hB16,
    CSR_MHPMCOUNTER23 = 12'hB17,
    CSR_MHPMCOUNTER24 = 12'hB18,
    CSR_MHPMCOUNTER25 = 12'hB19,
    CSR_MHPMCOUNTER26 = 12'hB1A,
    CSR_MHPMCOUNTER27 = 12'hB1B,
    CSR_MHPMCOUNTER28 = 12'hB1C,
    CSR_MHPMCOUNTER29 = 12'hB1D,
    CSR_MHPMCOUNTER30 = 12'hB1E,
    CSR_MHPMCOUNTER31 = 12'hB1F,

    CSR_MCYCLEH        = 12'hB80,
    CSR_MINSTRETH      = 12'hB82,
    CSR_MHPMCOUNTER3H  = 12'hB83,
    CSR_MHPMCOUNTER4H  = 12'hB84,
    CSR_MHPMCOUNTER5H  = 12'hB85,
    CSR_MHPMCOUNTER6H  = 12'hB86,
    CSR_MHPMCOUNTER7H  = 12'hB87,
    CSR_MHPMCOUNTER8H  = 12'hB88,
    CSR_MHPMCOUNTER9H  = 12'hB89,
    CSR_MHPMCOUNTER10H = 12'hB8A,
    CSR_MHPMCOUNTER11H = 12'hB8B,
    CSR_MHPMCOUNTER12H = 12'hB8C,
    CSR_MHPMCOUNTER13H = 12'hB8D,
    CSR_MHPMCOUNTER14H = 12'hB8E,
    CSR_MHPMCOUNTER15H = 12'hB8F,
    CSR_MHPMCOUNTER16H = 12'hB90,
    CSR_MHPMCOUNTER17H = 12'hB91,
    CSR_MHPMCOUNTER18H = 12'hB92,
    CSR_MHPMCOUNTER19H = 12'hB93,
    CSR_MHPMCOUNTER20H = 12'hB94,
    CSR_MHPMCOUNTER21H = 12'hB95,
    CSR_MHPMCOUNTER22H = 12'hB96,
    CSR_MHPMCOUNTER23H = 12'hB97,
    CSR_MHPMCOUNTER24H = 12'hB98,
    CSR_MHPMCOUNTER25H = 12'hB99,
    CSR_MHPMCOUNTER26H = 12'hB9A,
    CSR_MHPMCOUNTER27H = 12'hB9B,
    CSR_MHPMCOUNTER28H = 12'hB9C,
    CSR_MHPMCOUNTER29H = 12'hB9D,
    CSR_MHPMCOUNTER30H = 12'hB9E,
    CSR_MHPMCOUNTER31H = 12'hB9F,

    CSR_CYCLE        = 12'hC00,
    CSR_INSTRET      = 12'hC02,
    CSR_HPMCOUNTER3  = 12'hC03,
    CSR_HPMCOUNTER4  = 12'hC04,
    CSR_HPMCOUNTER5  = 12'hC05,
    CSR_HPMCOUNTER6  = 12'hC06,
    CSR_HPMCOUNTER7  = 12'hC07,
    CSR_HPMCOUNTER8  = 12'hC08,
    CSR_HPMCOUNTER9  = 12'hC09,
    CSR_HPMCOUNTER10 = 12'hC0A,
    CSR_HPMCOUNTER11 = 12'hC0B,
    CSR_HPMCOUNTER12 = 12'hC0C,
    CSR_HPMCOUNTER13 = 12'hC0D,
    CSR_HPMCOUNTER14 = 12'hC0E,
    CSR_HPMCOUNTER15 = 12'hC0F,
    CSR_HPMCOUNTER16 = 12'hC10,
    CSR_HPMCOUNTER17 = 12'hC11,
    CSR_HPMCOUNTER18 = 12'hC12,
    CSR_HPMCOUNTER19 = 12'hC13,
    CSR_HPMCOUNTER20 = 12'hC14,
    CSR_HPMCOUNTER21 = 12'hC15,
    CSR_HPMCOUNTER22 = 12'hC16,
    CSR_HPMCOUNTER23 = 12'hC17,
    CSR_HPMCOUNTER24 = 12'hC18,
    CSR_HPMCOUNTER25 = 12'hC19,
    CSR_HPMCOUNTER26 = 12'hC1A,
    CSR_HPMCOUNTER27 = 12'hC1B,
    CSR_HPMCOUNTER28 = 12'hC1C,
    CSR_HPMCOUNTER29 = 12'hC1D,
    CSR_HPMCOUNTER30 = 12'hC1E,
    CSR_HPMCOUNTER31 = 12'hC1F,

    CSR_CYCLEH        = 12'hC80,
    CSR_INSTRETH      = 12'hC82,
    CSR_HPMCOUNTER3H  = 12'hC83,
    CSR_HPMCOUNTER4H  = 12'hC84,
    CSR_HPMCOUNTER5H  = 12'hC85,
    CSR_HPMCOUNTER6H  = 12'hC86,
    CSR_HPMCOUNTER7H  = 12'hC87,
    CSR_HPMCOUNTER8H  = 12'hC88,
    CSR_HPMCOUNTER9H  = 12'hC89,
    CSR_HPMCOUNTER10H = 12'hC8A,
    CSR_HPMCOUNTER11H = 12'hC8B,
    CSR_HPMCOUNTER12H = 12'hC8C,
    CSR_HPMCOUNTER13H = 12'hC8D,
    CSR_HPMCOUNTER14H = 12'hC8E,
    CSR_HPMCOUNTER15H = 12'hC8F,
    CSR_HPMCOUNTER16H = 12'hC90,
    CSR_HPMCOUNTER17H = 12'hC91,
    CSR_HPMCOUNTER18H = 12'hC92,
    CSR_HPMCOUNTER19H = 12'hC93,
    CSR_HPMCOUNTER20H = 12'hC94,
    CSR_HPMCOUNTER21H = 12'hC95,
    CSR_HPMCOUNTER22H = 12'hC96,
    CSR_HPMCOUNTER23H = 12'hC97,
    CSR_HPMCOUNTER24H = 12'hC98,
    CSR_HPMCOUNTER25H = 12'hC99,
    CSR_HPMCOUNTER26H = 12'hC9A,
    CSR_HPMCOUNTER27H = 12'hC9B,
    CSR_HPMCOUNTER28H = 12'hC9C,
    CSR_HPMCOUNTER29H = 12'hC9D,
    CSR_HPMCOUNTER30H = 12'hC9E,
    CSR_HPMCOUNTER31H = 12'hC9F,

    // Machine information
    CSR_MVENDORID = 12'hF11,
    CSR_MARCHID   = 12'hF12,
    CSR_MIMPID    = 12'hF13,
    CSR_MHARTID   = 12'hF14
  } csr_num_e;

  // CSR operations

  localparam CSR_OP_WIDTH = 2;

  typedef enum logic [CSR_OP_WIDTH-1:0] {
    CSR_OP_READ  = 2'b00,
    CSR_OP_WRITE = 2'b01,
    CSR_OP_SET   = 2'b10,
    CSR_OP_CLEAR = 2'b11
  } csr_opcode_e;

  // CSR interrupt pending/enable bits
  localparam int unsigned CSR_MSIX_BIT = 3;
  localparam int unsigned CSR_MTIX_BIT = 7;
  localparam int unsigned CSR_MEIX_BIT = 11;
  localparam int unsigned CSR_MFIX_BIT_LOW = 16;
  localparam int unsigned CSR_MFIX_BIT_HIGH = 31;

  // SPR for debugger, not accessible by CPU
  localparam SP_DVR0 = 16'h3000;
  localparam SP_DCR0 = 16'h3008;
  localparam SP_DMR1 = 16'h3010;
  localparam SP_DMR2 = 16'h3011;

  localparam SP_DVR_MSB = 8'h00;
  localparam SP_DCR_MSB = 8'h01;
  localparam SP_DMR_MSB = 8'h02;
  localparam SP_DSR_MSB = 8'h04;

  // Privileged mode
  typedef enum logic [1:0] {
    PRIV_LVL_M = 2'b11,
    PRIV_LVL_H = 2'b10,
    PRIV_LVL_S = 2'b01,
    PRIV_LVL_U = 2'b00
  } PrivLvl_t;

  typedef struct packed {
    logic uie;
    // logic sie;      - unimplemented, hardwired to '0
    // logic hie;      - unimplemented, hardwired to '0
    logic mie;
    logic upie;
    // logic spie;     - unimplemented, hardwired to '0
    // logic hpie;     - unimplemented, hardwired to '0
    logic mpie;
    // logic spp;      - unimplemented, hardwired to '0
    // logic[1:0] hpp; - unimplemented, hardwired to '0
    PrivLvl_t mpp;
    logic mprv;
  } Status_t;

  typedef struct packed {
    logic [31:28] xdebugver;
    logic [27:16] zero2;
    logic ebreakm;
    logic zero1;
    logic ebreaks;
    logic ebreaku;
    logic stepie;
    logic stopcount;
    logic stoptime;
    logic [8:6] cause;
    logic zero0;
    logic mprven;
    logic nmip;
    logic step;
    PrivLvl_t prv;
  } Dcsr_t;

  // Floating Point State
  typedef enum logic [1:0] {
    FS_OFF     = 2'b00,
    FS_INITIAL = 2'b01,
    FS_CLEAN   = 2'b10,
    FS_DIRTY   = 2'b11
  } FS_t;

  // Machine Vendor ID - OpenHW JEDEC ID is '2 decimal (bank 13)'
  localparam MVENDORID_OFFSET = 7'h2;  // Final byte without parity bit
  localparam MVENDORID_BANK = 25'hC;  // Number of continuation codes

  // Machine Architecture ID (https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md)
  localparam MARCHID = 32'h4;

  localparam MHPMCOUNTER_WIDTH = 64;

  ///////////////////////////////////////////////
  //   ___ ____    ____  _                     //
  //  |_ _|  _ \  / ___|| |_ __ _  __ _  ___   //
  //   | || | | | \___ \| __/ _` |/ _` |/ _ \  //
  //   | || |_| |  ___) | || (_| | (_| |  __/  //
  //  |___|____/  |____/ \__\__,_|\__, |\___|  //
  //                              |___/        //
  ///////////////////////////////////////////////

  // forwarding operand mux
  localparam SEL_REGFILE = 2'b00;
  localparam SEL_FW_EX = 2'b01;
  localparam SEL_FW_WB = 2'b10;

  // operand a selection
  localparam OP_A_REGA_OR_FWD = 3'b000;
  localparam OP_A_CURRPC = 3'b001;
  localparam OP_A_IMM = 3'b010;
  localparam OP_A_REGB_OR_FWD = 3'b011;
  localparam OP_A_REGC_OR_FWD = 3'b100;

  // immediate a selection
  localparam IMMA_Z = 1'b0;
  localparam IMMA_ZERO = 1'b1;

  // operand b selection
  localparam OP_B_REGB_OR_FWD = 3'b000;
  localparam OP_B_REGC_OR_FWD = 3'b001;
  localparam OP_B_IMM = 3'b010;
  localparam OP_B_REGA_OR_FWD = 3'b011;
  localparam OP_B_BMASK = 3'b100;

  // immediate b selection
  localparam IMMB_I = 4'b0000;
  localparam IMMB_S = 4'b0001;
  localparam IMMB_U = 4'b0010;
  localparam IMMB_PCINCR = 4'b0011;
  localparam IMMB_S2 = 4'b0100;
  localparam IMMB_S3 = 4'b0101;
  localparam IMMB_VS = 4'b0110;
  localparam IMMB_VU = 4'b0111;
  localparam IMMB_SHUF = 4'b1000;
  localparam IMMB_CLIP = 4'b1001;
  localparam IMMB_BI = 4'b1011;

  // bit mask selection
  localparam BMASK_A_ZERO = 1'b0;
  localparam BMASK_A_S3 = 1'b1;

  localparam BMASK_B_S2 = 2'b00;
  localparam BMASK_B_S3 = 2'b01;
  localparam BMASK_B_ZERO = 2'b10;
  localparam BMASK_B_ONE = 2'b11;

  localparam BMASK_A_REG = 1'b0;
  localparam BMASK_A_IMM = 1'b1;
  localparam BMASK_B_REG = 1'b0;
  localparam BMASK_B_IMM = 1'b1;


  // multiplication immediates
  localparam MIMM_ZERO = 1'b0;
  localparam MIMM_S3 = 1'b1;

  // operand c selection
  localparam OP_C_REGC_OR_FWD = 2'b00;
  localparam OP_C_REGB_OR_FWD = 2'b01;
  localparam OP_C_JT = 2'b10;

  // branch types
  localparam BRANCH_NONE = 2'b00;
  localparam BRANCH_JAL = 2'b01;
  localparam BRANCH_JALR = 2'b10;
  localparam BRANCH_COND = 2'b11;  // conditional branches

  // jump target mux
  localparam JT_JAL = 2'b01;
  localparam JT_JALR = 2'b10;
  localparam JT_COND = 2'b11;

  // Atomic operations
  localparam AMO_LR = 5'b00010;
  localparam AMO_SC = 5'b00011;
  localparam AMO_SWAP = 5'b00001;
  localparam AMO_ADD = 5'b00000;
  localparam AMO_XOR = 5'b00100;
  localparam AMO_AND = 5'b01100;
  localparam AMO_OR = 5'b01000;
  localparam AMO_MIN = 5'b10000;
  localparam AMO_MAX = 5'b10100;
  localparam AMO_MINU = 5'b11000;
  localparam AMO_MAXU = 5'b11100;

  ///////////////////////////////////////////////
  //   ___ _____   ____  _                     //
  //  |_ _|  ___| / ___|| |_ __ _  __ _  ___   //
  //   | || |_    \___ \| __/ _` |/ _` |/ _ \  //
  //   | ||  _|    ___) | || (_| | (_| |  __/  //
  //  |___|_|     |____/ \__\__,_|\__, |\___|  //
  //                              |___/        //
  ///////////////////////////////////////////////

  // PC mux selector defines
  localparam PC_BOOT = 4'b0000;
  localparam PC_JUMP = 4'b0010;
  localparam PC_BRANCH = 4'b0011;
  localparam PC_EXCEPTION = 4'b0100;
  localparam PC_FENCEI = 4'b0001;
  localparam PC_MRET = 4'b0101;
  localparam PC_URET = 4'b0110;
  localparam PC_DRET = 4'b0111;
  localparam PC_HWLOOP = 4'b1000;

  // Exception PC mux selector defines
  localparam EXC_PC_EXCEPTION = 3'b000;
  localparam EXC_PC_IRQ = 3'b001;

  localparam EXC_PC_DBD = 3'b010;
  localparam EXC_PC_DBE = 3'b011;

  // Exception Cause
  localparam EXC_CAUSE_INSTR_FAULT = 5'h01;
  localparam EXC_CAUSE_ILLEGAL_INSN = 5'h02;
  localparam EXC_CAUSE_BREAKPOINT = 5'h03;
  localparam EXC_CAUSE_LOAD_FAULT = 5'h05;
  localparam EXC_CAUSE_STORE_FAULT = 5'h07;
  localparam EXC_CAUSE_ECALL_UMODE = 5'h08;
  localparam EXC_CAUSE_ECALL_MMODE = 5'h0B;

  // Interrupt mask
  localparam IRQ_MASK = 32'hFFFF0888;

  // Trap mux selector
  localparam TRAP_MACHINE = 2'b00;
  localparam TRAP_USER = 2'b01;

  // Debug Cause
  localparam DBG_CAUSE_NONE = 3'h0;
  localparam DBG_CAUSE_EBREAK = 3'h1;
  localparam DBG_CAUSE_TRIGGER = 3'h2;
  localparam DBG_CAUSE_HALTREQ = 3'h3;
  localparam DBG_CAUSE_STEP = 3'h4;
  localparam DBG_CAUSE_RSTHALTREQ = 3'h5;

  // Debug module
  localparam DBG_SETS_W = 6;

  localparam DBG_SETS_IRQ = 5;
  localparam DBG_SETS_ECALL = 4;
  localparam DBG_SETS_EILL = 3;
  localparam DBG_SETS_ELSU = 2;
  localparam DBG_SETS_EBRK = 1;
  localparam DBG_SETS_SSTE = 0;

  localparam DBG_CAUSE_HALT = 6'h1F;

  // Constants for the dcsr.xdebugver fields
  typedef enum logic [3:0] {
    XDEBUGVER_NO     = 4'd0,  // no external debug support
    XDEBUGVER_STD    = 4'd4,  // external debug according to RISC-V debug spec
    XDEBUGVER_NONSTD = 4'd15  // debug not conforming to RISC-V debug spec
  } x_debug_ver_e;

  // Trigger types
  typedef enum logic [3:0] {
    TTYPE_MCONTROL = 4'h2,
    TTYPE_ICOUNT   = 4'h3,
    TTYPE_ITRIGGER = 4'h4,
    TTYPE_ETRIGGER = 4'h5
  } trigger_type_e;

  // Floating-point extensions configuration
  localparam bit C_RVF = 1'b1;  // Is F extension enabled
  localparam bit C_RVD = 1'b0;  // Is D extension enabled - NOT SUPPORTED CURRENTLY

  // Transprecision floating-point extensions configuration
  localparam bit C_XF16 = 1'b0;  // Is half-precision float extension (Xf16) enabled
  localparam bit C_XF16ALT = 1'b0; // Is alternative half-precision float extension (Xf16alt) enabled
  localparam bit C_XF8 = 1'b0;  // Is quarter-precision float extension (Xf8) enabled
  localparam bit C_XFVEC = 1'b0;  // Is vectorial float extension (Xfvec) enabled

  // Latency of FP operations: 0 = no pipe registers, 1 = 1 pipe register etc.
  localparam int unsigned C_LAT_FP64 = 'd0;
  localparam int unsigned C_LAT_FP32 = 'd0;
  localparam int unsigned C_LAT_FP16 = 'd0;
  localparam int unsigned C_LAT_FP16ALT = 'd0;
  localparam int unsigned C_LAT_FP8 = 'd0;
  localparam int unsigned C_LAT_DIVSQRT = 'd1;  // divsqrt post-processing pipe
  localparam int unsigned C_LAT_CONV = 'd0;
  localparam int unsigned C_LAT_NONCOMP = 'd0;

  // General FPU-specific defines

  // Length of widest floating-point format = width of fp regfile
  localparam C_FLEN = C_RVD ? 64 :  // D ext.
  C_RVF ? 32 :  // F ext.
  C_XF16 ? 16 :  // Xf16 ext.
  C_XF16ALT ? 16 :  // Xf16alt ext.
  C_XF8 ? 8 :  // Xf8 ext.
  0;  // Unused in case of no FP

  localparam C_FFLAG = 5;
  localparam C_RM = 3;

endpackage

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Tue Nov 21 14:54:49 2023
// Host        : c-am-i running 64-bit Ubuntu 23.10
// Command     : write_verilog -force -mode synth_stub
//               /home/kersz/Documents/cv32e40p/cv32e40p.gen/sources_1/ip/dp_blk_ram/dp_blk_ram_stub.v
// Design      : dp_blk_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *)
module dp_blk_ram(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="ena,wea[3:0],addra[16:0],dina[31:0],douta[31:0],enb,web[3:0],addrb[16:0],dinb[31:0],doutb[31:0]" */
/* synthesis syn_force_seq_prim="clka" */
/* synthesis syn_force_seq_prim="clkb" */;
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [3:0]wea;
  input [16:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [3:0]web;
  input [16:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule

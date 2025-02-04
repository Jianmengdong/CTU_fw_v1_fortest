// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
// Date        : Tue Nov 10 14:41:44 2020
// Host        : J-Dong running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/VivadoProject/CTU_v0/CTU_fw_v1_fortest/CTU_fw_v1.srcs/sources_1/ip/ila_1/ila_1_stub.v
// Design      : ila_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1926-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2018.1" *)
module ila_1(clk, probe0, probe1, probe2, probe3)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[0:0],probe2[31:0],probe3[31:0]" */;
  input clk;
  input [0:0]probe0;
  input [0:0]probe1;
  input [31:0]probe2;
  input [31:0]probe3;
endmodule

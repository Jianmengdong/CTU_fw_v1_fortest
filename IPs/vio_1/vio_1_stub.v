// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
// Date        : Wed Mar 17 10:42:42 2021
// Host        : J-Dong running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/VivadoProject/CTU_v0/CTU_fw_v1_fortest/CTU_fw_v1.srcs/sources_1/ip/vio_1/vio_1_stub.v
// Design      : vio_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1926-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.1" *)
module vio_1(clk, probe_in0, probe_in1, probe_out0, 
  probe_out1, probe_out2, probe_out3, probe_out4, probe_out5, probe_out6, probe_out7, probe_out8)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[0:0],probe_in1[1:0],probe_out0[167:0],probe_out1[15:0],probe_out2[4:0],probe_out3[0:0],probe_out4[4:0],probe_out5[31:0],probe_out6[0:0],probe_out7[4:0],probe_out8[0:0]" */;
  input clk;
  input [0:0]probe_in0;
  input [1:0]probe_in1;
  output [167:0]probe_out0;
  output [15:0]probe_out1;
  output [4:0]probe_out2;
  output [0:0]probe_out3;
  output [4:0]probe_out4;
  output [31:0]probe_out5;
  output [0:0]probe_out6;
  output [4:0]probe_out7;
  output [0:0]probe_out8;
endmodule

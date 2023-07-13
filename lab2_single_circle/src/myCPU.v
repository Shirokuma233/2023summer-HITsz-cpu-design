`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  inst_addr,
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_wen,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

// TODO: 完成你自己的单周期CPU设计
//pc output signals
wire[31:0] pc;

//npc output signals
wire[31:0] npc;
wire[31:0] pc4;

//control output signals
wire[1:0] npc_op;
wire rf_we;
wire[1:0] rf_wsel;
wire[2:0] sext_op;
wire alub_sel;
wire dram_we;
wire[3:0] alu_op;

//sext output signals
wire[31:0] ext;

//register files output signals
wire[31:0] rD1;
wire[31:0] rD2;
wire[31:0] wD;

//alu output signals
wire[31:0] alu_c;
wire alu_f;

//dram output signals
wire[31:0] rd;

pc PC(
  .rst(cpu_rst),
  .clk(cpu_clk),
  .din(npc),
  .pc(pc)
);

npc NPC(
  .op(npc_op),
  .br(alu_f),
  .offset(ext),
  .rs_imm(alu_c),
  .pc(pc),
  .pc4(pc4),
  .npc(npc)
);

//irom part
assign inst_addr = pc[15:2];

control CU(
  .inst(inst),
  .npc_op(npc_op),
  .rf_we(rf_we),
  .rf_wsel(rf_wsel),
  .sext_op(sext_op),
  .alub_sel(alub_sel),
  .dram_we(dram_we),
  .alu_op(alu_op)
);

sext SEXT(
  .din(inst),
  .op(sext_op),
  .ext(ext)
);

RF U_RF(
  .clk(cpu_clk),
  .rR1(inst[19:15]),
  .rR2(inst[24:20]),
  .wR(inst[11:7]),
  .we(rf_we),
  //the following four datas are components of wD that is a result of the mux
  .rf_wsel(rf_wsel),
  .pc4(pc4), //from npc
  .ext(ext), //from sext
  .alu_c(alu_c), //from alu
  .rd(rd),  //from dram
  .rD1(rD1),
  .rD2(rD2),
  .wD(wD) //only for debug
);

alu ALU(
  .rs1(rD1),
  .rs2(rD2),
  .imm(ext),
  .alub_sel(alub_sel),
  .alu_op(alu_op),
  .alu_c(alu_c),
  .alu_f(alu_f)
);

//dram part 
assign Bus_addr = alu_c;  //DRAM_addr will be alu_c[15:2],you can see it in the Soc part
assign rd = Bus_rdata;    //lw read 
assign Bus_wen = dram_we; //lw and sw mem
assign Bus_wdata = rD2;   //sw

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = (debug_wb_have_inst) ? pc : 32'b0;
    assign debug_wb_ena       = (debug_wb_have_inst && rf_we) ? 1'b1 : 1'b0;
    assign debug_wb_reg       = (debug_wb_ena) ? inst[11:7] : 5'b0;
    assign debug_wb_value     = (debug_wb_ena) ? wD : 32'b0;
`endif

endmodule

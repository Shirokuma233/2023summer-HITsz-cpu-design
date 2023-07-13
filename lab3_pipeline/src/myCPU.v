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

//IROM output signals (is located in the above segment, the interface with IROM)

//IF_ID output signals
wire[31:0] ID_inst;
wire[31:0] ID_pc4;

//control output signals
wire[1:0] npc_op;
wire rf_we;
wire[1:0] rf_wsel;
wire[2:0] sext_op;
wire alub_sel;
wire dram_we;
wire[3:0] alu_op;
wire[1:0] rf_re;

//sext output signals
wire[31:0] ext;

//register files output signals
wire[31:0] rD1;
wire[31:0] rD2;
wire[31:0] wD;

//ID_EX output signals
wire[1:0] EX_npc_op;
wire EX_ram_we;
wire[3:0] EX_alu_op;
wire EX_alub_sel;
wire EX_rf_we;
wire[1:0] EX_rf_wsel;
wire[4:0] EX_wR;
wire[31:0] EX_pc4;
wire[31:0] EX_rD1;
wire[31:0] EX_rD2;
wire[31:0] EX_ext;

//alu output signals
wire[31:0] alu_c;
wire alu_f;

//EX_MEM output signals
wire MEM_ram_we;
wire MEM_rf_we;
wire[1:0] MEM_rf_wsel;
wire[4:0] MEM_wR;
wire[31:0] MEM_pc4;
wire[31:0] MEM_alu_c;
wire[31:0] MEM_rD2;
wire[31:0] MEM_ext;

//dram output signals
wire[31:0] rd;

//MEM_WB output signals
wire WB_rf_we;
wire[1:0] WB_rf_wsel;
wire[4:0] WB_wR;
wire[31:0] WB_pc4;
wire[31:0] WB_alu_c;
wire[31:0] WB_rd;
wire[31:0] WB_ext;

//data_hazard_detection output signals
wire[31:0] new_rD1;
wire[31:0] new_rD2;
wire data_hazard;

//control_hazard_detection output signals
wire control_hazard;

pc PC(
  .rst(cpu_rst),
  .clk(cpu_clk),
  .din(npc),
  .data_hazard(data_hazard),
  .control_hazard(control_hazard),
  .pc(pc)
);

npc NPC(
  .op(EX_npc_op),
  .br(alu_f),
  .offset(EX_ext),
  .rs_imm(alu_c),
  .pc(pc),
  .pc4(pc4),
  .npc(npc)
);

//IROM part
assign inst_addr = pc[15:2];

IF_ID U_IF_ID(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .IF_inst(inst),
  .IF_pc4(pc4),
  .data_hazard(data_hazard),
  .control_hazard(control_hazard),  //control_hazard has the top priority!!
  .ID_inst(ID_inst),
  .ID_pc4(ID_pc4)
);

control CU(
  .inst(ID_inst),
  .npc_op(npc_op),
  .rf_we(rf_we),
  .rf_wsel(rf_wsel),
  .sext_op(sext_op),
  .alub_sel(alub_sel),
  .dram_we(dram_we),
  .alu_op(alu_op),
  .rf_re(rf_re)
);

sext SEXT(
  .din(ID_inst),
  .op(sext_op),
  .ext(ext)
);

RF U_RF(
  .clk(cpu_clk),
  .rR1(ID_inst[19:15]),
  .rR2(ID_inst[24:20]),
  .wR(WB_wR),
  .we(WB_rf_we),
  //the following four datas are components of wD that is a result of the mux
  .rf_wsel(WB_rf_wsel),
  .pc4(WB_pc4), //from npc
  .ext(WB_ext), //from sext
  .alu_c(WB_alu_c), //from alu
  .rd(WB_rd),  //from dram
  .rD1(rD1),
  .rD2(rD2),
  .wD(wD) //only for debug
);

ID_EX U_ID_EX(
  .clk(cpu_clk),
  .rst(cpu_rst),

  .ID_npc_op(npc_op),
  .ID_ram_we(dram_we),
  .ID_alu_op(alu_op),
  .ID_alub_sel(alub_sel),
  .ID_rf_we(rf_we),
  .ID_rf_wsel(rf_wsel),
  .ID_wR(ID_inst[11:7]),
  .ID_pc4(ID_pc4),
  .ID_rD1(new_rD1),
  .ID_rD2(new_rD2),
  .ID_ext(ext),

  .EX_npc_op(EX_npc_op),
  .EX_ram_we(EX_ram_we),
  .EX_alu_op(EX_alu_op),
  .EX_alub_sel(EX_alub_sel),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_wR(EX_wR),
  .EX_pc4(EX_pc4),
  .EX_rD1(EX_rD1),
  .EX_rD2(EX_rD2),
  .EX_ext(EX_ext),

  .control_hazard(control_hazard),//two hazard have the same flush
  .data_hazard(data_hazard)
);

alu ALU(
  .rs1(EX_rD1),
  .rs2(EX_rD2),
  .imm(EX_ext),
  .alub_sel(EX_alub_sel),
  .alu_op(EX_alu_op),
  .alu_c(alu_c),
  .alu_f(alu_f)
);

EX_MEM U_EX_MEM(
  .clk(cpu_clk),
  .rst(cpu_rst),

  .EX_ram_we(EX_ram_we),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_wR(EX_wR),
  .EX_pc4(EX_pc4),
  .EX_alu_c(alu_c),
  .EX_rD2(EX_rD2),
  .EX_ext(EX_ext),

  .MEM_ram_we(MEM_ram_we),
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_wR(MEM_wR),
  .MEM_pc4(MEM_pc4),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rD2(MEM_rD2),
  .MEM_ext(MEM_ext)
);

//dram part 
assign Bus_addr = MEM_alu_c;  //DRAM_addr will be alu_c[15:2],you can see it in the Soc part
assign rd = Bus_rdata;    //lw read 
assign Bus_wen = MEM_ram_we; //sw mem
assign Bus_wdata = MEM_rD2;   //sw

MEM_WB U_MEM_WB(
  .clk(cpu_clk),
  .rst(cpu_rst),
  
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_wR(MEM_wR),
  .MEM_pc4(MEM_pc4),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rd(rd),
  .MEM_ext(MEM_ext),

  .WB_rf_we(WB_rf_we),
  .WB_rf_wsel(WB_rf_wsel),
  .WB_wR(WB_wR),
  .WB_pc4(WB_pc4),
  .WB_alu_c(WB_alu_c),
  .WB_rd(WB_rd),
  .WB_ext(WB_ext)
);

data_hazard_detection U_datahazard_detection(
  .ID_rR1(ID_inst[19:15]),
  .ID_rR2(ID_inst[24:20]),
  .ID_rf_re(rf_re), //read enable
  .ID_rD1(rD1),
  .ID_rD2(rD2),

  .EX_wR(EX_wR),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_pc4(EX_pc4),
  .EX_ext(EX_ext),
  .EX_alu_c(alu_c),

  .MEM_wR(MEM_wR),
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_pc4(MEM_pc4),
  .MEM_ext(MEM_ext),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rd(rd),

  .WB_wR(WB_wR),
  .WB_rf_we(WB_rf_we),
  .WB_rf_wsel(WB_rf_wsel),
  .WB_pc4(WB_pc4),
  .WB_ext(WB_ext),
  .WB_alu_c(WB_alu_c),
  .WB_rd(WB_rd),

  .new_rD1(new_rD1),
  .new_rD2(new_rD2),
  .data_hazard(data_hazard)
);

control_hazard_detection U_control_hazard_detection(
  .EX_npc_op(EX_npc_op),
  .alu_f(alu_f),
  .control_hazard(control_hazard)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = (WB_pc4 == 32'b0) ? 0 : 1; //if pc4 == 0,it must be nop
    assign debug_wb_pc        = (debug_wb_have_inst) ? (WB_pc4 - 4) : 32'b0;
    assign debug_wb_ena       = (debug_wb_have_inst && WB_rf_we) ? 1'b1 : 1'b0;
    assign debug_wb_reg       = (debug_wb_ena) ? WB_wR : 5'b0;
    assign debug_wb_value     = (debug_wb_ena) ? wD : 32'b0;  //wD is only for debug
`endif

endmodule

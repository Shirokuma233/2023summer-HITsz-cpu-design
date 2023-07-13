`include "defines.vh"
module IF_ID(
  input wire clk,         
  input wire rst,
  input wire[31:0] IF_inst, //IF阶段的inst 
  input wire[31:0] IF_pc4,  //IF阶段的pc+4
  input wire data_hazard,   //数据冒险标志
  input wire control_hazard,  //控制冒险标志，control_hazard has the top priority!!
  output reg[31:0] ID_inst, //传给ID阶段的inst
  output reg[31:0] ID_pc4   //传给ID阶段的pc+4
);


always @(posedge clk or posedge rst) begin
  if(rst) ID_inst<=0;
  else if(control_hazard) ID_inst<=0;
  else if(data_hazard) ID_inst<=ID_inst;
  else ID_inst<=IF_inst;
end

always @(posedge clk or posedge rst) begin
  if(rst) ID_pc4<=0;
  else if(control_hazard) ID_pc4<=0;  //若有控制冒险则应该请空该寄存器信号
  else if(data_hazard) ID_pc4<=ID_pc4;//若有数据冒险，则维持一个clk不变
  else ID_pc4<=IF_pc4;
end

endmodule
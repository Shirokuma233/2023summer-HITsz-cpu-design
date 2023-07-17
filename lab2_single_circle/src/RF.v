`include "defines.vh"
module RF(
  input wire clk,     //时钟
  input wire[4:0] rR1,//一号寄存器地址
  input wire[4:0] rR2,//二号寄存器地址
  input wire[4:0] wR, //写寄存器地址
  input wire we,      //写寄存器使能
                    //the following four datas are components of wD
  input wire[1:0] rf_wsel,//写寄存器数据选择信号
  input wire[31:0] pc4, //from npc，被选择数据之一
  input wire[31:0] ext, //from sext，被选择数据之一 
  input wire[31:0] alu_c, //from alu，被选择数据之一
  input wire[31:0] rd,  //from dram，被选择数据之一
  output wire[31:0] rD1,//rR1地址读出的寄存器值
  output wire[31:0] rD2,//rR2地址读出的寄存器值
  output reg[31:0] wD  //only for debug,仅用于trace测试的时候给出写入RF的值
);

//RF
reg[31:0] rf[31:0];

//read
assign rD1 = (rR1 == 5'b0)? 32'b0 : rf[rR1];
assign rD2 = (rR2 == 5'b0)? 32'b0 : rf[rR2];

//wb,mux
always @(*) begin
  case(rf_wsel)
    `S_ALU_C : wD = alu_c;
    `S_DRAM_rd : wD = rd;
    `S_PC4 : wD = pc4;
    `S_SEXT_ext : wD = ext;
    default: wD = pc4;
  endcase
end

//wb,write
always @(posedge clk) begin
    if(we && (wR != 5'b0)) rf[wR] <= wD;
end

endmodule
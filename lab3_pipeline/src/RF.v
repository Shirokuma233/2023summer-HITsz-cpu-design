`include "defines.vh"
module RF(
  input wire clk,
  input wire[4:0] rR1,
  input wire[4:0] rR2,
  input wire[4:0] wR,
  input wire we,
                    //the following four datas are components of wD
  input wire[1:0] rf_wsel,
  input wire[31:0] pc4, //from npc
  input wire[31:0] ext, //from sext
  input wire[31:0] alu_c, //from alu
  input wire[31:0] rd,  //from dram
  output wire[31:0] rD1,
  output wire[31:0] rD2,
  output reg[31:0] wD  //only for debug
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
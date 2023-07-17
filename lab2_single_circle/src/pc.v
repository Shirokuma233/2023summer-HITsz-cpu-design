`include "defines.vh"
module pc(
  input wire rst, //复位信号
  input wire clk, //cpu时钟
  input wire[31:0] din, //下一条pc
  output reg[31:0] pc //当前pc
);

always @(posedge clk or posedge rst) begin
  if(rst) begin
    `ifdef RUN_TRACE
      pc<=-4;
    `else
      pc<=0;
    `endif
  end
  else pc <= din;
end

endmodule
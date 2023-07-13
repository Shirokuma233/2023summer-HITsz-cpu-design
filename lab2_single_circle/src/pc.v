`include "defines.vh"
module pc(
  input wire rst,
  input wire clk,
  input wire[31:0] din,
  output reg[31:0] pc
);

always @(posedge clk or posedge rst) begin
  if(rst) pc <= 0;
  else pc <= din;
end

endmodule
`include "defines.vh"
module sext(
  input wire[31:0] din,
  input wire[2:0] op,
  output reg[31:0] ext
);

//SEXT
wire sign=din[31];
always @(*) begin
  if(op == `SEXT_R) ext=0;
  else if(op == `SEXT_I) ext={{20{sign}},{din[31:20]}};
  else if(op == `SEXT_MOVE) ext={{27{1'b0}},{din[24:20]}};
  else if(op == `SEXT_S) ext={{20{sign}},{din[31:25]},{din[11:7]}};
  else if(op == `SEXT_B) ext={{19{sign}},{din[31]},{din[7]},{din[30:25]},{din[11:8]},{1'b0}};
  else if(op == `SEXT_U) ext={{din[31:12]},{12{1'b0}}};
  else if(op == `SEXT_J) ext={{11{sign}},{din[31]},{din[19:12]},{din[20]},{din[30:21]},{1'b0}};
  else ext = 0;
end

endmodule
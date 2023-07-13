module leds(
  input wire clk,
  input wire rst,
  input wire[31:0] data,
  input wire data_en,
  output reg[23:0] led
);

reg[31:0] mydata;

always @(posedge clk or posedge rst) begin
  if(rst) mydata<=0;
  else if(data_en) mydata<=data;
  else mydata <= mydata;
end

always @(*) begin
  if(rst) led=0;
  else led=mydata[23:0];
end

endmodule
`include "defines.vh"
module alu(
  input wire[31:0] rs1, //rD1
  input wire[31:0] rs2, //rD2
  input wire[31:0] imm, //立即数
  input wire alub_sel,  //第二个数据的选择信号
  input wire[3:0] alu_op,   //ALU运算类型信号
  output wire[31:0] alu_c,  //ALU结果
  output wire alu_f     //用于B型指令的比较结果标志
);

  wire[31:0] dataA = rs1;
  wire[31:0] dataB = alub_sel ? imm : rs2;
  reg[31:0] result;

    always @(*) begin
        case(alu_op)
            `ADD : result = dataA + dataB;
            `SUB : result = dataA - dataB;
            `AND : result = dataA & dataB;
            `OR  : result = dataA | dataB;
            `XOR : result = dataA ^ dataB;
            `SLL : result = dataA << dataB[4:0];
            `SRL : result = dataA >> dataB[4:0];
            `SRA : result = ($signed(dataA)) >>> dataB[4:0];
            default : result = 0;
        endcase

    end

    assign alu_c = result;

    wire[31:0] sub = dataA - dataB;
    reg f;
    always @(*) begin
      if(alu_op == `BEQ && sub == 0) f = 1;
      else if(alu_op == `BNE && sub != 0) f = 1;
      else if(alu_op == `BLT && sub[31]) f = 1;
      else if(alu_op == `BGE && sub[31] == 0) f = 1;
      else f = 0; 
    end

    assign alu_f = f;

endmodule
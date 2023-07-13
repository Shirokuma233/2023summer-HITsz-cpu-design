module alu(
  input wire[31:0] rs1,
  input wire[31:0] rs2,
  input wire[31:0] imm,
  input wire alub_sel,
  input wire[3:0] alu_op,
  output wire[31:0] alu_c,
  output wire alu_f
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
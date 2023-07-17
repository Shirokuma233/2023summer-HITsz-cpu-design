`include "defines.vh"
module control #(
  //各种指令类型的opcode
    localparam OP_R    = 7'b0110011,
    localparam OP_I    = 7'b0010011,
    localparam OP_LOAD = 7'b0000011,
    localparam OP_S    = 7'b0100011,
    localparam OP_B    = 7'b1100011,
    localparam OP_LUI  = 7'b0110111,
    localparam OP_JAL  = 7'b1101111,
    localparam OP_JALR = 7'b1100111
)
(
  input wire[31:0] inst,  //当前指令
  output reg[1:0] npc_op, //给出npc的op
  output reg rf_we,       //给出寄存器写使能
  output reg[1:0] rf_wsel,//给出寄存器的数据选择信号
  output reg[2:0] sext_op,//给出立即数扩展信号
  output reg alub_sel,    //给出alu第二个运算数据的数据选择信号
  output reg dram_we,     //给出DRAM的写使能
  output reg[3:0] alu_op  //给出ALU的计算类型信号
);

wire[6:0] opcode = inst[6:0];
wire[2:0] funct3 = inst[14:12];
wire[6:0] funct7 = inst[31:25];

//npc_op
always @(*) begin
  case(opcode)
    OP_R, OP_I, OP_LOAD, OP_LUI, OP_S: npc_op = `C_NPC_PC4;
    OP_JALR:                           npc_op = `C_NPC_JALR;
    OP_B:                              npc_op = `C_NPC_B;
    OP_JAL:                            npc_op = `C_NPC_JAL;
    default:                           npc_op = `C_NPC_PC4;
  endcase
end

//rf_we
always @(*) begin
  if(opcode == OP_B || opcode == OP_S) rf_we = 0;
  else rf_we  = 1;
end

//rf_wsel
always @(*) begin
  case(opcode)
    OP_R, OP_I: rf_wsel = `S_ALU_C;
    OP_LOAD: rf_wsel = `S_DRAM_rd;
    OP_JALR, OP_JAL: rf_wsel = `S_PC4;
    OP_LUI: rf_wsel = `S_SEXT_ext;
    default: rf_wsel = `S_ALU_C;
  endcase
end

//sext_op
always @(*) begin
  case(opcode)
    OP_I:
      case(funct3)
        3'b001, 3'b101: sext_op = `SEXT_MOVE; //
        default: sext_op = `SEXT_I;
      endcase
    OP_LOAD, OP_JALR: sext_op = `SEXT_I;
    OP_LUI: sext_op = `SEXT_U;
    OP_JAL: sext_op = `SEXT_J;
    OP_B: sext_op = `SEXT_B;
    OP_S: sext_op = `SEXT_S;
    OP_R: sext_op = `SEXT_R;
    default: sext_op = `SEXT_R;
  endcase
end

//alub_sel
always @ (*) begin
    case (opcode)
        OP_I, OP_LOAD, OP_S, OP_JALR:
            alub_sel = 1; //imm
        default:
            alub_sel = 0; //rs2
    endcase
end

//dram_we
always @(*) begin
  if(opcode == OP_S) dram_we = 1;
  else dram_we = 0;
end

//alu_op
always @ (*) begin
    case (opcode)
        OP_R: begin
            case (funct3)
                3'b000 : alu_op = funct7[5] ? `SUB : `ADD;
                3'b111 : alu_op = `AND;
                3'b110 : alu_op = `OR ;
                3'b100 : alu_op = `XOR;
                3'b001 : alu_op = `SLL;
                3'b101 : alu_op = funct7[5] ? `SRA : `SRL;
                default: alu_op = `AND;
            endcase
        end
        OP_I: begin
            case (funct3)
                3'b000 : alu_op = `ADD;
                3'b111 : alu_op = `AND;
                3'b110 : alu_op = `OR ;
                3'b100 : alu_op = `XOR;
                3'b001 : alu_op = `SLL;
                3'b101 : alu_op = funct7[5] ? `SRA : `SRL;
                default: alu_op = `AND;
            endcase
        end
        OP_LOAD, OP_S, OP_JALR:
            alu_op = `ADD;
        OP_B:begin
            case(funct3)
              3'b000 : alu_op = `BEQ;
              3'b001 : alu_op = `BNE;
              3'b100 : alu_op = `BLT;
              3'b101 : alu_op = `BGE;
              default: alu_op = `BEQ;
            endcase
        end
        default:
            alu_op = `AND;
    endcase
end

endmodule
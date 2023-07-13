module npc(
  input wire[1:0] op,
  input wire br,
  input wire[31:0] offset,
  input wire[31:0] rs_imm,
  input wire[31:0] pc,
  output wire[31:0] pc4,
  output reg[31:0] npc
);

assign pc4 = pc+4;

always @(*) begin
  if(op == `C_NPC_PC4) npc = pc+4;
  else if(op == `C_NPC_JALR) npc = rs_imm;
  else if(op == `C_NPC_B && br == 1) npc = pc+offset;
  else if(op == `C_NPC_B && br == 0) npc = pc+4;
  else if(op == `C_NPC_JAL) npc = pc+offset;
end

endmodule
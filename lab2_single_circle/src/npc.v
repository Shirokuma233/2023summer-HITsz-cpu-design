`include "defines.vh"
module npc(
  input wire[1:0] op, //npc_op控制npc的选择
  input wire br,      //B型指令跳转标志，1是跳转
  input wire[31:0] offset,  //B型、Jal指令的offset
  input wire[31:0] rs_imm,  //jalr指令的跳转目的地址
  input wire[31:0] pc,  //当前pc
  output wire[31:0] pc4,  //当前pc+4
  output reg[31:0] npc  //下一个pc取值
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
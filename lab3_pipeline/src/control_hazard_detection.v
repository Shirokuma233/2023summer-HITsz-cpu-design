`include "defines.vh"
module control_hazard_detection(
  input wire[1:0] EX_npc_op,  //EX阶段的npc_op
  input wire alu_f,           //EX阶段的alu_f
  output reg control_hazard   //控制冒险标志
);

always @(*) begin
  if(EX_npc_op == `C_NPC_JALR || EX_npc_op == `C_NPC_JAL) control_hazard = 1'b1;//jal、jalr都是无条件跳转
  else if(EX_npc_op == `C_NPC_B && alu_f == 1) control_hazard = 1'b1;           //B型指令需要满足alu_f==1
  else control_hazard = 1'b0;
end

endmodule
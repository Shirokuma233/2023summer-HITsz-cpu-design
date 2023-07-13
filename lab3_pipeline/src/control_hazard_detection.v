`include "defines.vh"
module control_hazard_detection(
  input wire[1:0] EX_npc_op,
  input wire alu_f,
  output reg control_hazard
);

always @(*) begin
  if(EX_npc_op == `C_NPC_JALR || EX_npc_op == `C_NPC_JAL) control_hazard = 1'b1;
  else if(EX_npc_op == `C_NPC_B && alu_f == 1) control_hazard = 1'b1;
  else control_hazard = 1'b0;
end

endmodule
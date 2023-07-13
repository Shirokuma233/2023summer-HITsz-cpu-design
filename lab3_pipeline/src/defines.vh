// Annotate this macro before synthesis
//`define RUN_TRACE

// TODO: 在此处定义你的宏
//IF
`define C_NPC_PC4 2'b00
`define C_NPC_JALR 2'b01
`define C_NPC_B 2'b10
`define C_NPC_JAL 2'b11
//ID
`define SEXT_R 3'b000
`define SEXT_I 3'b001
`define SEXT_MOVE 3'b010
`define SEXT_S 3'b011
`define SEXT_B 3'b100
`define SEXT_U 3'b101
`define SEXT_J 3'b110
//EX(ALU)
`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0010
`define OR 4'b0011
`define XOR 4'b0100
`define SLL 4'b0101
`define SRL 4'b0110
`define SRA 4'b0111
`define BEQ 4'b1000
`define BNE 4'b1001
`define BLT 4'b1010
`define BGE 4'b1011
//WB(rf_wsel)
`define S_ALU_C 2'b00
`define S_DRAM_rd 2'b01
`define S_PC4 2'b10
`define S_SEXT_ext 2'b11

// 外设I/O接口电路的端口地�??
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078

//pipeline relevant
//`define DATA_HAZARD_1 3'b001
//`define DATA_HAZARD_2 3'b010
//`define DATA_HAZARD_3 3'b011
//`define CONTROL_HAZARD 1'b1
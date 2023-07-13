`include "defines.vh"
module data_hazard_detection(
  input wire[4:0] ID_rR1,
  input wire[4:0] ID_rR2,
  input wire[1:0] ID_rf_re, //read enable
  input wire[31:0] ID_rD1,
  input wire[31:0] ID_rD2,

  input wire[4:0] EX_wR,
  input wire EX_rf_we,
  input wire[1:0] EX_rf_wsel,
  input wire[31:0] EX_pc4,
  input wire[31:0] EX_ext,
  input wire[31:0] EX_alu_c,

  input wire[4:0] MEM_wR,
  input wire MEM_rf_we,
  input wire[1:0] MEM_rf_wsel,
  input wire[31:0] MEM_pc4,
  input wire[31:0] MEM_ext,
  input wire[31:0] MEM_alu_c,
  input wire[31:0] MEM_rd,

  input wire[4:0] WB_wR,
  input wire WB_rf_we,
  input wire[1:0] WB_rf_wsel,
  input wire[31:0] WB_pc4,
  input wire[31:0] WB_ext,
  input wire[31:0] WB_alu_c,
  input wire[31:0] WB_rd,

  output reg[31:0] new_rD1, //传给ID/EX的rD1被改模块所代理
  output reg[31:0] new_rD2, //传给ID/EX的rD2被改模块所代理
  output wire data_hazard   //if only we counter with load-use, it will be 1,and stop pipeline a clk
);

//Because the implemention is stopping,the load-use instruction is regarded as a normal R type instrucion,so don't have special process.
//Acordding to the final situaion,I maybe consider the forward delivery

//three data hazards
//A,ID and EX
wire rR1_a = (ID_rR1 == EX_wR) & EX_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);//仅当ID寄存器地址与EX写地址相同 & EX有写使能 & 这个ID寄存器地址是确实要读数据的 & ID寄存器地址不是0,那么发生了ID/EX的数据冒险
wire rR2_a = (ID_rR2 == EX_wR) & EX_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);
//B,ID and MEM
wire rR1_b = (ID_rR1 == MEM_wR) & MEM_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);
wire rR2_b = (ID_rR2 == MEM_wR) & MEM_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);
//C,ID and WB
wire rR1_c = (ID_rR1 == WB_wR) & WB_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);
wire rR2_c = (ID_rR2 == WB_wR) & WB_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);

//这个data_hazard不是严格意义的数据冒险，他只有在发生load-use型的数据冒险时才会是1，代表的是暂停流水线1clk，而另外几种普通的数据冒险都可以由前递解决。如下代码所示，仅当发生ID/EX数据冒险 & EX的写选择是DRAM的读出结果时才发生。
assign data_hazard = (rR1_a && EX_rf_wsel == `S_DRAM_rd) || (rR2_a && EX_rf_wsel == `S_DRAM_rd);

always @(*) begin
  if(rR1_a) begin
    case(EX_rf_wsel)
      `S_PC4: new_rD1=EX_pc4;
      `S_SEXT_ext: new_rD1=EX_ext;
      `S_ALU_C: new_rD1=EX_alu_c;
      default: new_rD1=EX_alu_c;
    endcase
  end
  else if(rR1_b) begin
    case(MEM_rf_wsel)
    `S_PC4: new_rD1=MEM_pc4;
    `S_SEXT_ext: new_rD1=MEM_ext;
    `S_ALU_C: new_rD1=MEM_alu_c;
    `S_DRAM_rd: new_rD1=MEM_rd;
    default: new_rD1=MEM_alu_c;
    endcase
  end
  else if(rR1_c) begin
    case(WB_rf_wsel)
    `S_PC4: new_rD1=WB_pc4;     //要写pc+4
    `S_SEXT_ext: new_rD1=WB_ext;//要写立即数
    `S_ALU_C: new_rD1=WB_alu_c; //要写ALU结果
    `S_DRAM_rd: new_rD1=WB_rd;  //要写DRAM读出数据
    default: new_rD1=WB_alu_c;  
    endcase
  end
  else new_rD1=ID_rD1;
end

always @(*) begin
  if(rR2_a) begin
    case(EX_rf_wsel)
      `S_PC4: new_rD2=EX_pc4;
      `S_SEXT_ext: new_rD2=EX_ext;
      `S_ALU_C: new_rD2=EX_alu_c;
      default: new_rD2=EX_alu_c;
    endcase
  end
  else if(rR2_b) begin
    case(MEM_rf_wsel)
    `S_PC4: new_rD2=MEM_pc4;
    `S_SEXT_ext: new_rD2=MEM_ext;
    `S_ALU_C: new_rD2=MEM_alu_c;
    `S_DRAM_rd: new_rD2=MEM_rd;
    default: new_rD2=MEM_alu_c;
    endcase
  end
  else if(rR2_c) begin
    case(WB_rf_wsel)
    `S_PC4: new_rD2=WB_pc4;
    `S_SEXT_ext: new_rD2=WB_ext;
    `S_ALU_C: new_rD2=WB_alu_c;
    `S_DRAM_rd: new_rD2=WB_rd;
    default: new_rD2=WB_alu_c;
    endcase
  end
  else new_rD2=ID_rD2;
end

endmodule
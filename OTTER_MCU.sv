`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Slaanesh Systems
// Engineer: Cultist Chavez
// 
// Create Date: 0.150.935.M41 11:06:09 AM
// Design Name: Eye of Terror
// Module Name: CHAOS_OTTER_MCU
// Project Name: Black Crusade
// Target Devices: Chaos Predator Tank
// Tool Versions: 1
// Description: Death to the False Emperor!
// 
// Dependencies: Daemonic Possession of Target Device
// 
// Revision: 1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input CLK,
    input RST,
    input INTR,
    input TX,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output IOBUS_WR,
    output RX
    );
    logic [1:0] srcB_OUT, WR_SEL_IN;
    logic [2:0] PC_SOURCE;
    logic INTR_FSM, INT_TAKEN, MIE, CSR_WRITE, BR_EQ, srcA_OUT, BR_LTU, BR_LT, PC_WRITE, REG_WRITE, MEM_WRITE2, MEM_READ1, MEM_READ2;
    logic [31:0] CSR_MTVEC, CSR_MEPC,RD, IR, PC_OUT, RS1, PC_IN, PC_PLUS_FOUR, MEM2_DOUT2, muxA_OUT, muxB_OUT, WR_SEL_OUT;
    logic [31:0] I_IMMED, U_IMMED, S_IMMED, J_IMMED, B_IMMED;
    logic [31:0] PC_BRANCH, PC_JAL, PC_JALR;
    logic [3:0] ALU_FUN_IN;
    
    //Branch CondGen
    always_comb
    begin
    if(RS1==IOBUS_OUT)
    BR_EQ = 1;
    else
    BR_EQ = 0;
    if(RS1<IOBUS_OUT)
    BR_LTU = 1;
    else
    BR_LTU = 0;
    if($signed(RS1)<$signed(IOBUS_OUT))
    BR_LT = 1;
    else
    BR_LT = 0;
    end
    
    assign INTR_FSM = INTR & MIE;
    assign PC_PLUS_FOUR = PC_OUT + 3'b100;
    
   
    //Immed Gen
    assign I_IMMED = {{21{IR[31]}}, IR[30:20]};
    assign S_IMMED = {{21{IR[31]}}, IR[30:25], IR[11:7]};
    assign B_IMMED = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
    assign U_IMMED = {IR[31:12], 12'b0}; 
    assign J_IMMED = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0}; 
    
    //Target Gen
    assign PC_BRANCH = PC_OUT + B_IMMED;
    assign PC_JAL = PC_OUT + J_IMMED;
    assign PC_JALR = RS1 + I_IMMED; 
    
Mux6_1 Mux6_1_inst1(.sel(PC_SOURCE), .zero(PC_PLUS_FOUR), .one(PC_JALR), .two(PC_BRANCH), .three(PC_JAL), .four(CSR_MTVEC), .five(CSR_MEPC), .Q(PC_IN));
PC PC_inst1(.DIN(PC_IN), .RESET(RST), .CLK(CLK), .PC_WRITE(PC_WRITE), .DOUT(PC_OUT));
OTTER_mem_byte OTTER_mem_byte_inst1(.MEM_READ1(MEM_READ1), .MEM_READ2(MEM_READ2), .MEM_WRITE2(MEM_WRITE2), .MEM_ADDR2(IOBUS_ADDR),.MEM_DIN2(IOBUS_OUT),.MEM_DOUT2(MEM2_DOUT2), .MEM_CLK(CLK), .MEM_SIGN(IR[14]), .MEM_SIZE(IR[13:12]), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_ADDR1(PC_OUT),.MEM_DOUT1(IR) );
ALU ALU_inst(.A(muxA_OUT), .B(muxB_OUT), .ALU_FUN(ALU_FUN_IN),.ALU_OUT(IOBUS_ADDR));
RegisterFile RegisterFile(.ADR1(IR[19:15]), .EN(REG_WRITE), .CLK(CLK), .ADR2(IR[24:20]), .WA(IR[11:7]), .WD(WR_SEL_OUT), .RS1(RS1), .RS2(IOBUS_OUT));
CUDecoder CUDecoder_inst1(.INT_TAKEN(INT_TAKEN), .BR_EQ(BR_EQ), .BR_LTU(BR_LTU), .BR_LT(BR_LT), .FUNC3(IR[14:12]), .FUNC7(IR[31:25]), .CU_OPCODE(IR[6:0]), .ALU_FUN(ALU_FUN_IN), .ALU_SRCA(srcA_OUT), .ALU_SRCB(srcB_OUT), .PC_SOURCE(PC_SOURCE), .RF_WR_SEL(WR_SEL_IN));
CU_FSM CU_FSM_inst1( .INTR(INTR_FSM), .FUNC3(IR[14:12]), .CSR_WRITE(CSR_WRITE), .INT_TAKEN(INT_TAKEN), .CLK(CLK), .RST(RST), .CU_OPCODE(IR[6:0]), .PC_WRITE(PC_WRITE), .REG_WRITE(REG_WRITE), .MEM_WRITE(MEM_WRITE2), .MEM_READ1(MEM_READ1), .MEM_READ2(MEM_READ2));
Mux4_1 Mux4_1_inst2(.sel(WR_SEL_IN), .zero(PC_PLUS_FOUR), .one(RD), .two(MEM2_DOUT2), .three(IOBUS_ADDR), .Q(WR_SEL_OUT));
Mux4_1 Mux4_1_inst3(.sel(srcB_OUT), .zero(IOBUS_OUT), .one(I_IMMED), .two(S_IMMED), .three(PC_OUT), .Q(muxB_OUT));
Mux2_1 Mux2_1_inst1(.sel(srcA_OUT), .zero(RS1), .one(U_IMMED), .Q(muxA_OUT));
CSR CSR_inst1(.CLK(CLK), .RST(RST), .INT_TAKEN(INT_TAKEN), .ADDR(IR[31:20]), .PC(PC_OUT), .WD(IOBUS_ADDR), .WR_EN(CSR_WRITE), .RD(RD), .CSR_MTVEC(CSR_MTVEC), .CSR_MEPC(CSR_MEPC), .CSR_MIE(MIE));
endmodule
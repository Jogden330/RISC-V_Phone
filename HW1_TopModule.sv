`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2020 11:22:34 AM
// Design Name: 
// Module Name: HW1_TopModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HW1_TopModule(
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    output [31:0] DOUT,
    input RESET,
    input CLK,
    input PC_WRITE,
    input MEM_READ1,
    input [1:0] PC_SOURCE
    );
    logic [31:0] T1,T2, T3;
    
    assign T3 = T2 + 3'b100;
    
    Mux4_1 Mux4_1_inst1(.zero(T3), .one(JALR), .two(BRANCH), .three(JAL), .Q(T1), .sel(PC_SOURCE));
    PC     PC_inst1(.CLK(CLK), .DIN(T1), .RESET(RESET), .PC_WRITE(PC_WRITE), .DOUT(T2));
    OTTER_mem_byte OTTER_mem_byte_inst1(.MEM_ADDR1(T2), .MEM_DOUT1(DOUT), .MEM_CLK(CLK), .MEM_READ1(MEM_READ1));
endmodule

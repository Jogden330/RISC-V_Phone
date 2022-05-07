`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 01:23:59 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_FUN,
    output logic [31:0] ALU_OUT
    );
  
    always_comb
    begin
    
 
   
    case (ALU_FUN)
    4'b0000: ALU_OUT = A + B;
    4'b1000: ALU_OUT = A - B;
    4'b0110: ALU_OUT = A | B;
    4'b0111: ALU_OUT = A & B;
    4'b0100: ALU_OUT = A ^ B;
    4'b0101: ALU_OUT = A >> B[4:0];
    4'b0001: ALU_OUT = A << B[4:0];
    4'b1101: ALU_OUT = $signed(A) >>> B[4:0];
    4'b0010: ALU_OUT = ($signed(A) < $signed(B)) ? 1:0;
    4'b0011: ALU_OUT = (A < B) ? 1:0;
    4'b1001: ALU_OUT = A;    
    
    
    endcase
    end
    
endmodule

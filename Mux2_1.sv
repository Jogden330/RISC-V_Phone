`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2020 01:22:36 PM
// Design Name: 
// Module Name: Mux2_1
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


module Mux2_1(
    input sel,
    input [31:0] zero, one,
    output logic [31:0] Q
    );
    
    always_comb
    begin
        case(sel)
        1'b0: Q <= zero;
        1'b1: Q <= one;
        endcase
    end        
endmodule

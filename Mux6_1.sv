`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2020 10:33:46 AM
// Design Name: 
// Module Name: Mux6_1
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


module Mux6_1(
    input [2:0] sel,
    input [31:0] zero, one, two, three, four, five,
    output logic [31:0] Q
    );
    
    always_comb
    begin
        case(sel)
        3'b000: Q <= zero;
        3'b001: Q <= one;
        3'b010: Q <= two;
        3'b011: Q <= three;
        3'b100: Q <= four;
        3'b101: Q <= five;
        endcase
    end        
endmodule

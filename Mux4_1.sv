`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2020 10:31:57 AM
// Design Name: 
// Module Name: Mux4_1
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


module Mux4_1(
    input [1:0] sel,
    input [31:0] zero, one, two, three,
    output logic [31:0] Q
    );
    
    always_comb
    begin
        case(sel)
        2'b00: Q <= zero;
        2'b01: Q <= one;
        2'b10: Q <= two;
        2'b11: Q <= three;
        endcase
    end        
endmodule

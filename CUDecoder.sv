`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2020 01:33:31 PM
// Design Name: 
// Module Name: CUDecoder
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


module CUDecoder(
    input BR_EQ,
    input BR_LT,
    input BR_LTU,
    input INT_TAKEN,
    input [2:0] FUNC3,
    input [6:0] FUNC7,
    input [6:0] CU_OPCODE,
    output logic [3:0] ALU_FUN,
    output logic ALU_SRCA,
    output logic [1:0] ALU_SRCB,
    output logic [2:0] PC_SOURCE,
    output logic [1:0] RF_WR_SEL
    );
    
    typedef enum logic [6:0] {
            LUI     = 7'b0110111,
            AUIPC   = 7'b0010111,
            JAL     = 7'b1101111,
            JALR    = 7'b1100111,
            BRANCH  = 7'b1100011,
            LOAD    = 7'b0000011,
            STORE   = 7'b0100011,
            OP_IMM  = 7'b0010011,
            OP      = 7'b0110011,
            SYSTEM  = 7'b1110011          
    } opcode_t;
    
    opcode_t OPCODE;
    assign OPCODE = opcode_t' (CU_OPCODE);
    
    always_comb
    begin
    ALU_FUN = 0; 
    ALU_SRCA = 0;
    ALU_SRCB = 0; 
    PC_SOURCE = 0; 
    RF_WR_SEL = 0;
 
    case(OPCODE)
    LUI: begin ALU_FUN <= 9; ALU_SRCA <= 1; RF_WR_SEL <= 3; if(INT_TAKEN) PC_SOURCE <= 4; end
    AUIPC: begin ALU_SRCA <= 1; ALU_SRCB <= 3; RF_WR_SEL <= 3; if(INT_TAKEN) PC_SOURCE <= 4; end
    JAL: begin if(INT_TAKEN) PC_SOURCE <= 4; else PC_SOURCE <= 3;  end
    JALR: begin if(INT_TAKEN) PC_SOURCE <= 4; else PC_SOURCE <= 1;  end
    BRANCH: if((FUNC3 == 3'b000 && BR_EQ==1)||(FUNC3 == 3'b001 && BR_EQ == 0)||(FUNC3 == 3'b100&&BR_LT==1)||(FUNC3==3'b101&&BR_LT==0)||(FUNC3==3'b110&&BR_LTU==1)||(FUNC3==3'b111&&BR_LTU==00))
            PC_SOURCE = 2; else if(INT_TAKEN) PC_SOURCE <= 4;         
    LOAD: begin ALU_FUN <= 0; ALU_SRCA <= 0; ALU_SRCB <= 1; RF_WR_SEL <= 2; if(INT_TAKEN) PC_SOURCE <= 4; end
    STORE: begin ALU_FUN <= 0; ALU_SRCA <= 0; ALU_SRCB <= 2; RF_WR_SEL <= 0; if(INT_TAKEN) PC_SOURCE <= 4; end
    OP_IMM: begin if(FUNC3==5)ALU_FUN = {FUNC7[5], FUNC3};else ALU_FUN = {1'b0, FUNC3};ALU_SRCB <= 1; RF_WR_SEL <= 3; if(INT_TAKEN) PC_SOURCE <= 4;  end
    OP: begin ALU_FUN = {FUNC7[5], FUNC3}; RF_WR_SEL <= 3; if(INT_TAKEN) PC_SOURCE <= 4;  end
    SYSTEM: begin ALU_FUN <= 9; RF_WR_SEL <= 1; if(FUNC3 == 3'b000) PC_SOURCE <= 5; else if(INT_TAKEN) PC_SOURCE <= 4; end
    endcase
    end
    
     
endmodule

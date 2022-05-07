`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2020 01:29:20 PM
// Design Name: 
// Module Name: CU_FSM
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


module CU_FSM(
    input CLK,
    input INTR,
    input RST,
    input [2:0] FUNC3,
    input [6:0] CU_OPCODE,
    output logic PC_WRITE,
    output logic CSR_WRITE, INT_TAKEN,
    output logic REG_WRITE,
    output logic MEM_WRITE,
    output logic MEM_READ1,
    output logic MEM_READ2
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
    
    parameter [1:0] FETCH = 2'b00, EXEC = 2'b01, WB = 2'b11, INTER = 2'b10;
    logic [1:0] NS;
    logic [1:0] PS = FETCH;
    
    
    always_ff@( posedge CLK)
    begin
    if(RST) PS = FETCH;
    else    PS = NS;
    end
    
    always_comb
    begin
    PC_WRITE = 0; REG_WRITE = 0; MEM_WRITE=0; MEM_READ1=0; MEM_READ2=0; CSR_WRITE=0; INT_TAKEN=0;
    
    case(PS)
    
    FETCH:
    begin
    if(RST)
    NS = FETCH;
    else
    MEM_READ1 = 1; NS = EXEC;
    end
    
    EXEC: 
    begin
    case(OPCODE)
    LUI: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    AUIPC: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH;end
    JAL: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    JALR: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    BRANCH: begin PC_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    LOAD: begin MEM_READ2 = 1; if(INTR) NS=INTER; else NS = WB; end
    STORE: begin PC_WRITE = 1; MEM_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    OP_IMM: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    OP: begin PC_WRITE = 1; REG_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH; end
    SYSTEM: begin if (FUNC3 == 3'b001)begin REG_WRITE = 1; PC_WRITE = 1; CSR_WRITE = 1;end else PC_WRITE=1; if(INTR) NS=INTER; else NS = FETCH; end
    endcase
    end
    
    WB:
    begin
    REG_WRITE = 1; PC_WRITE = 1; if(INTR) NS=INTER; else NS = FETCH;
    end
    
    INTER:
    begin
    INT_TAKEN = 1; PC_WRITE = 1; NS = FETCH;
    end
    
    endcase 
    
    end
    
endmodule

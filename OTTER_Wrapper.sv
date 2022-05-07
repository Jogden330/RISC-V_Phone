`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Calllenes
//           P. Hummel
// 
// Create Date: 01/20/2019 10:36:50 AM
// Design Name: 
// Module Name: OTTER_Wrapper 
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

module OTTER_Wrapper(
   input CLK,
   input BTNL,
//   input INTR, // for testing only change on mcu also
   input BTNC,
   input [15:0] SWITCHES,
   input PS2Clk,
   input PS2Data,
   input RX, 
   output logic [15:0] LEDS,
   output logic ARDUINO_EN,
   output logic [3:0] ARDUINO_NUM,
   output [7:0] CATHODES,
   output [3:0] ANODES,
   output [7:0] VGA_RGB,
   output VGA_HS,
   output VGA_VS,
   output TX
   );
        
    logic sclk2 =0;
    // INPUT PORT IDS ////////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more MMIO, and you'll have
    // to add constants here for the mux below
    localparam SWITCHES_AD = 32'h11000000;
    localparam VGA_READ_AD = 32'h11040000;
           
    // OUTPUT PORT IDS ///////////////////////////////////////////////////////
    // In future labs you can add more MMIO
    localparam LEDS_AD      = 32'h11080000;
    localparam SSEG_AD     = 32'h110C0000;
    localparam VGA_ADDR_AD = 32'h11100000;
    localparam VGA_COLOR_AD = 32'h11140000; 
    localparam KEYBOARD_AD = 32'h11200000;
    localparam ARDUINO_NUMBER_AD = 32'h11280000;
           
    
   // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////////
   logic s_interrupt, keyboard_int, btn_int;
   logic s_reset,s_load;
   logic sclk, arduino_clk;   
   
   // Signals for connecting VGA Framebuffer Drivlr
   logic r_vga_we, arduino_en_;              // enable
   logic [7:0] T0, T1, T2, T3, T4, T5, T6, T7, T8, T9; //connections to mux
   logic E0, E1, E2, E3, E4, E5, E6, E7, E8, E9; //For enable AND gate
   logic [3:0] mux_counter = 0; // cycles through mux inputs
   logic [7:0] arduino_num_;     //           passes bcd into ARDUINO_DELAY
   logic [3:0] delay_sel; //Controls delay mux
   logic [12:0] r_vga_wa;      // address of framebuffer to read and write
   logic [7:0] r_vga_wd;       // pixel color data to write to framebuffer
   logic [7:0] r_vga_rd;       // pixel color data read from framebuffe 
   logic [15:0]  r_SSEG;       // = 16'h0000;

   logic [7:0] s_scancode;
     
   logic [31:0] IOBUS_out,IOBUS_in,IOBUS_addr;
   logic IOBUS_wr;
   
   assign s_interrupt = keyboard_int | btn_int;
   
    // Declare OTTER_CPU ///////////////////////////////////////////////////////
   OTTER_MCU MCU (.RST(s_reset),.INTR(s_interrupt), .CLK(sclk), .TX(TX), .RX(RX), 
                   .IOBUS_OUT(IOBUS_out),.IOBUS_IN(IOBUS_in),.IOBUS_ADDR(IOBUS_addr),.IOBUS_WR(IOBUS_wr));

   // Declare Seven Segment Display /////////////////////////////////////////
   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
   
   // Declare Debouncer One Shot  ///////////////////////////////////////////
   debounce_one_shot DB(.CLK(sclk), .BTN(BTNL), .DB_BTN(btn_int));
   

   // Declare VGA Frame Buffer //////////////////////////////////////////////
   vga_fb_driver_80x60 VGA(.CLK_50MHz(sclk), .WA(r_vga_wa), .WD(r_vga_wd),
                               .WE(r_vga_we), .RD(r_vga_rd), .ROUT(VGA_RGB[7:5]),
                               .GOUT(VGA_RGB[4:2]), .BOUT(VGA_RGB[1:0]),
                               .HS(VGA_HS), .VS(VGA_VS));   
 
                                          
   
  
 // Declare Keyboard Driver //////////////////////////////////////////////
    KeyboardDriver KEYBD (.CLK(CLK), .PS2DATA(PS2Data), .PS2CLK(PS2Clk),
                          .INTRPT(keyboard_int), .SCANCODE(s_scancode)); 
                          
 // Declare Arduino Clock Divider (10MHz)
     clk_div arduino_clk_div ( .clk(sclk), .sclk(arduino_clk));
     
 // Declare 10_1 MUX
    MUX_10_1 Delay_Mux (.zero(T0), .one(T1), .two(T2), .three(T3), .four(T4), .five(T5), .six(T6), .seven(T7), .eight(T8), .nine(T9), .sel(delay_sel), .Q(arduino_num_));
 
 // Declare Arduino Delay Module
     ARDUINO_OUTPUT_DELAY AOD (.CLK(arduino_clk), .NUM_IN(arduino_num_), .EN_IN(arduino_en_), .NUM_OUT(ARDUINO_NUM), .EN_OUT(ARDUINO_EN), .delay_sel(delay_sel));
     
  
                           
   // Clock Divider to create 50 MHz Clock /////////////////////////////////
   always_ff @(posedge CLK) begin
       sclk <= ~sclk;
   end
   

    // Connect Signals ////////////////////////////////////////////////////////////
   assign s_reset = BTNC;
   
   //assign LEDS[15]=keyboard_int;
   // Connect Board peripherals (Memory Mapped IO devices) to IOBUS /////////////////////////////////////////
    always_ff @ (posedge sclk)
    begin
        r_vga_we<=0;
        if(delay_sel == 4'hA)
        begin
            E0 <= 0; E1 <= 0; E2 <= 0; E3 <= 0; E4 <= 0; E5 <= 0; E6 <= 0; E7 <= 0; E8 <= 0; E9 <= 0;
        end    
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS <= IOBUS_out;    
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                ARDUINO_NUMBER_AD:begin  //Commented out for testing multiplexe
                                         case(mux_counter)
                                         4'h0: begin T0 <= IOBUS_out[7:0]; mux_counter = 4'h1; E0 = 1'b1; end
                                         4'h1: begin T1 <= IOBUS_out[7:0]; mux_counter = 4'h2; E1 = 1'b1; end
                                         4'h2: begin T2 <= IOBUS_out[7:0]; mux_counter = 4'h3; E2 = 1'b1; end
                                         4'h3: begin T3 <= IOBUS_out[7:0]; mux_counter = 4'h4; E3 = 1'b1; end
                                         4'h4: begin T4 <= IOBUS_out[7:0]; mux_counter = 4'h5; E4 = 1'b1; end
                                         4'h5: begin T5 <= IOBUS_out[7:0]; mux_counter = 4'h6; E5 = 1'b1; end
                                         4'h6: begin T6 <= IOBUS_out[7:0]; mux_counter = 4'h7; E6 = 1'b1; end
                                         4'h7: begin T7 <= IOBUS_out[7:0]; mux_counter = 4'h8; E7 = 1'b1; end
                                         4'h8: begin T8 <= IOBUS_out[7:0]; mux_counter = 4'h9; E8 = 1'b1; end
                                         4'h9: begin T9 <= IOBUS_out[7:0]; mux_counter = 4'h0; E9 = 1'b1; end
                                         endcase
                                         end  
                VGA_ADDR_AD: r_vga_wa <= IOBUS_out[12:0];
                VGA_COLOR_AD: begin  r_vga_wd <= IOBUS_out[7:0];
                                     r_vga_we <= 1;  
                              end     
            endcase
            end
            
            assign arduino_en_ = E0 & E1 & E2 & E3 & E4 & E5 & E6 & E7 & E8 & E9;
            
            
 
            
//         if(keyboard_int)
//         r_SSEG <= {8'b0,s_scancode};
  
    always_comb
    begin
        IOBUS_in=32'b0;
        case(IOBUS_addr)
            SWITCHES_AD: IOBUS_in[15:0] = SWITCHES;
            VGA_READ_AD: IOBUS_in[15:0] = r_vga_rd;           
            KEYBOARD_AD: IOBUS_in[7:0] = s_scancode;
            default: IOBUS_in=32'b0;
        endcase
    end
   endmodule


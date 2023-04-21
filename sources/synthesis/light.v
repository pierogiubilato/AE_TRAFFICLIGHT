/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                           Traffic light example                            ##
##                                                                            ##
\#############################################################################*/

// INFO
// The light module transform a 2-bit signal (4 states) into a color-coded
// output for the Arty board.


// -----------------------------------------------------------------------------
// --                                PARAMETERS                               --
// -----------------------------------------------------------------------------
//
// C_CLK_FRQ:       frequency of the clock in [cycles per second] {100000000}. 
// C_INTERVAL:      the time interval the signal must be stable to pass through
//					and reach the fabric. [ms] {10}.


// -----------------------------------------------------------------------------
// --                                I/O PORTS                                --
// -----------------------------------------------------------------------------
//
// rstb:                INPUT, synchronous reset, ACTIVE LOW. 
// clk:                 INPUT, master clock.
// in [1 : 0]:          INPUT, the light state signal.
// out_LED [11 : 0]:    OUTPUT: the signal toward the board RGB LEDs.
//                              each LED is RGB and used 3 bit to encode the color.

// Tool timescale.
`timescale 1 ns / 1 ps

// Behavioural.
module  light # (
		parameter [11:0] C_COLORS = {1'b1, 1'b0, 1'b0,   
		                             1'b0, 1'b1, 1'b0,   
		                             1'b1, 1'b1, 1'b0,   
		                             1'b1, 1'b1, 1'b1} // RGB bits for each LED.
	) (
		input rstb,               // Reset (bar).  
		input clk,                // Clock.
		input [1 : 0] inSel,      // Selection (light selection).
		output [11:0] outLED      // Output LED to fabric.
	);


   	// =========================================================================
    // ==                        Registers and wires                          ==
    // =========================================================================

    reg [11:0] rColor = C_COLORS;      // Color mask (3 bits for each RGB LED).
	reg [11:0] rMask;                  // Output mask.
	
	
	// =========================================================================
    // ==                      Asynchronous assignments                       ==
    // =========================================================================
	
	// Output bitlist.
	assign outLED = rColor & rMask;  // Bitwise AND 
	
	
	// =========================================================================
    // ==                        Synchronous processes                        ==
    // =========================================================================

	// Update the output accordingly to the selection signal.
	always @ (posedge clk) begin
        case (inSel)
            2'b00: rMask <= 12'b111000000000;
            2'b01: rMask <= 12'b000111000000;
            2'b10: rMask <= 12'b000000111000;
            2'b11: rMask <= 12'b000000000111;
        endcase
	end
	
endmodule



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
// The control module implements the State Machine prforming the traffic light
// operations.


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
// inPedestrian:        INPUT, pedestrian crossing.
// outLight [1 : 0]:    OUTPUT: selected light

// Tool timescale.
`timescale 1 ns / 1 ps

// Behavioural.
module control # (
    parameter [11:0] C_COLORS = {1'b1, 1'b0, 1'b0,   
		                             1'b0, 1'b1, 1'b0,   
		                             1'b1, 1'b1, 1'b0,   
		                             1'b1, 1'b1, 1'b1} // RGB bits for each LED.
	) (
		input rstb,                   // Reset (bar).  
		input clk,                    // Clock.
		input [1 : 0] inPedestrian,   // Pedestrian imput.
		output [1 : 0] outLight       // Output light.
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



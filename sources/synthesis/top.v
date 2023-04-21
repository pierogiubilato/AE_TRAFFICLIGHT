/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                          Counter didactical example                        ##
##                                                                            ##
\#############################################################################*/

// The top module is the topmost wrapper of the whole project, and contains
// all the I/O ports used by the FPGA.


// -----------------------------------------------------------------------------
// --                                PARAMETERS                               --
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// --                                I/O PORTS                                --
// -----------------------------------------------------------------------------
//
// sysRstb:         INPUT, synchronous reset, ACTIVE LOW.
// sysClk:          INPUT, master clock. Defines the timing of the transmission.
//
// [3:0] sw:        INPUT, connected to the board switches.
// [3:0] btn:       INPUT, connected to the board push buttons.
// [3:0] led:       OUTPUT, connected to the board LEDs.
// [11:0] ledRGB:   INPUT, connected to the board RGB LEDs, grouped by 3 for
//                  each LED: [11:9] = R,G,B for led 3, [8:6] = R,G,B for led 2,
//                  [5:3] = R,G,B for led 1, [2:0] = R,G,B for led 0,




// Tool timescale.
`timescale 1 ns / 1 ps

// Behavioural.
module top # () (
        
        // Timing.
        input sysRstb,          // System reset, active low.
        input sysClk,           // System clock, SE input.
                
        // External switches and buttons inputs.
        input [3:0] sw,         // Switches.
        input [3:0] btn,        // Push buttons.
        
        // Standard LEDs outputs.
        output [3:0] led,       // LEDs.   
        output [11:0] ledRGB    // RGB LEDs
    );
    

    // =========================================================================
    // ==                                Wires                                ==
    // =========================================================================
    


    // =========================================================================
    // ==                             Registers                               ==
    // =========================================================================
    

    // 24 bit counter.
    reg [23:0] rCount = 0;
        
    
    // =========================================================================
    // ==                    Asynchronous assignments                         ==
    // =========================================================================
    
    // Push buttons to LEDs.
    assign led[1] = btn[1];
    assign led[2] = btn[2];
    assign led[3] = btn[3];
    
    // Switches to a single RGB LED.
    assign ledRGB[0] = sw[0];
    assign ledRGB[1] = sw[1];
    assign ledRGB[2] = sw[2];
    
    // Counter to a LED.
    assign led[0] = rCount[23];
    
    
    
    // =========================================================================
    // ==                       Synchronous processes                         ==
    // =========================================================================
    
    // Simple count process.
    always @ (posedge(sysClk)) begin
        rCount <= rCount + 1;
    end

endmodule

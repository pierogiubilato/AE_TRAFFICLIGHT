/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                          Traffic Light Example                             ##
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
module top # (

        // Clocking and timing parameters.
        C_CLK_BRD_FRQ = 100_000_000,// Board clock frequency [Hz].
        C_CLK_VAR_FRQ = 10_000_000, // Master clock frequency [Hz].
        C_DBC_INTERVAL = 10,        // Debouncer lock interval [ms].
        
        // "Human timebase" blinker.
        C_BLK_PERIOD = 100,         // Blinker period [ms].

        // Traffic lights intervals (in 'blinks' units).
        C_INT_RED = 40,             // Red interval [blinks]
        C_INT_GREEN = 40,           // Green interval [blinks]
        C_INT_YELLOW = 10,          // Yellow interval [blinks]
        C_INT_WALK = 40,            // Walk interval [blinks]

        // Colors of the lights:       R     G     B.
        parameter [11:0] C_COLORS = {1'b1, 1'b0, 1'b0,  // Red state.   
		                             1'b0, 1'b1, 1'b0,  // Green state.
		                             1'b1, 1'b1, 1'b0,  // Yellow state.
		                             1'b1, 1'b1, 1'b1}  // Walk state.

    ) (
        
        // Timing.
        input sysRstb,              // System reset, active low.
        input sysClk,               // System clock, SE input.
                
        // External switches and buttons inputs.
        input [3:0] sw,             // Switches.
        input [3:0] btn,            // Push buttons.
        
        // Standard LEDs outputs.
        output [3:0] led,           // LEDs.   
        output [11:0] ledRGB        // RGB LEDs
    );
   
        
    
    // =========================================================================
    // ==                                Wires                                ==
    // =========================================================================
    
    // Cocks.
    wire wClk_VAR_0;
    
    // (debounced) buttons.
    wire wDbcPedestrian;            // Debounced wire for pedestrian button.
        
    // (debounced) switches.
    wire wDbcMode;                  // Debounced wire for mode switch.
        
    // Blinker.
    wire wBlink;                    // Blinker output.
    
    // Control.
    wire [1:0] wCtrlLight;          // Control light status.
    wire wPedestrianLatch;          // Status of the pedestrian latch.
        
        
    
    // =========================================================================
    // ==                             Modules                                 ==
    // =========================================================================

    // Clock manager tile.
    clockHrd #(
        .C_IN_FRQ(C_CLK_BRD_FRQ),       // Board clock frequency [Hz].
        .C_VAR_FRQ(C_CLK_VAR_FRQ)       // Programmable clock frequency [Hz].
    ) CLOCK (
        .rstn(sysRstb),
        .clkIn(sysClk),                 // Clock from the board.    
        
        //.clk100_0(wClk_100_0),        // 100 MHz out clock.
        .clkVar_0(wClk_VAR_0)           // Programmable clock output.
    );
        
    // Debouncer for the pedestriam button.
    debounce #(
        .C_CLK_FRQ(C_CLK_VAR_FRQ),      // Reference clock frequency [Hz].
        .C_INTERVAL(C_DBC_INTERVAL)     // Debounce lock interval [ms].
    ) DBC_PEDESTRIAN (
        .rstb(sysRstb),
        .clk(wClk_VAR_0),
        .in(btn[0]),                    // Input button #0.
        .out(wDbcPedestrian)
    );   
    
    // Debouncer for the mode selector.
    debounce #(
        .C_CLK_FRQ(C_CLK_VAR_FRQ),          // Clock frequency [Hz].
        .C_INTERVAL(C_DBC_INTERVAL)         // Debounce lock interval [ms].
    ) DBC_MODE (
        .rstb(sysRstb),
        .clk(wClk_VAR_0),
        .in(sw[0]),                         // Input switch #0.
        .out(wDbcMode)
    );   
        
    // Blink timebase generatior.
    blinker #(
        .C_CLK_FRQ(C_CLK_VAR_FRQ),      // Reference clock frequency [Hz].
        .C_PERIOD(C_BLK_PERIOD)         // Blinker period [ms].
    ) BLINKER (
        .rstb(sysRstb),
        .clk(wClk_VAR_0),
        .out(wBlink)                    // Blink signal.
    );
    
    // Main control unit.
    control #(
        .C_INT_RED(C_INT_RED),          // Red interval [blinks].
        .C_INT_GREEN(C_INT_GREEN),      // Green interval [blinks].
        .C_INT_YELLOW(C_INT_YELLOW),    // Yellow interval [blinks].    
        .C_INT_WALK(C_INT_WALK)         // Walk interval [blinks].
    ) CONTROL (
        
        // Timing.
        .rstb(sysRstb),
        .clk(wClk_VAR_0),
        .blink(wBlink),
        
        // Inputs.
        .inMode(wDbcMode),              // From DBC_PEDESTRIAN. 
        .inTraffic(1'b0),               // UNUSED.
	    .inPedestrian(wDbcPedestrian),  // From DBC_PEDESTRIAN.
        
        // Outputs.
        .outPedLatch(wPedestrianLatch), // Latch of the pedestrian button.
        .outLight(wCtrlLight)
    );
    
    // State to RGB LEDs conversion.
    light #(
        .C_COLORS(C_COLORS)             // Light RGB colors.    
    ) LIGHT (
        .rstb(sysRstb),
        .clk(wClk_VAR_0),
        .inSel(wCtrlLight),             // Light status from Control.  
        .outLED(ledRGB)                 // Toward output RGB LEDs.
    );

    
    // =========================================================================
    // ==                     Asynchronous connections                        ==
    // =========================================================================

    // Connects the blinker signal to (non-RGB) led #0.
    assign led[0] = wBlink;
    
    // Connects the pedestrin button signal to (non-RGB) led #1.
    assign led[1] = wDbcPedestrian;
    
    // Connects the pedestrian mode to (non-RGB) led #2.
    assign led[2] = wDbcMode;
    
    // Connects the pedestrian mode to (non-RGB) led #3.
    assign led[3] = wPedestrianLatch;
    
endmodule

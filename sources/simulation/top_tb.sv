/*#############################################################################\
##                                                                            ##
##       APPLIED ELECTRONICS - Physics Department - University of Padova      ##
##                                                                            ## 
##       ---------------------------------------------------------------      ##
##                                                                            ##
##                           Traffic Light example                            ##
##                                                                            ##
\#############################################################################*/


// Set timescale (default time unit if not otherwise specified).
`timescale 1ns / 1ps

// Define Module for Test Fixture
module top_tb ();

    // ==========================================================================
    // ==                               Parameters                             ==
    // ==========================================================================
    
    // Timing parameters.
    parameter C_CLK_FRQ         = 100_000_000;      // Main clock frequency [Hz].
    parameter C_CLK_JTR         = 50;               // Main clock jitter [ps].
    localparam real C_CLK_PERIOD = 1E9 / C_CLK_FRQ; // Master clock period [ns].
        
    
    
    
    // ==========================================================================
    // ==                              Seeding                                 ==
    // ==========================================================================
    
    // Seeding for (repeatable) random number generation.
    static int seed = $urandom + 0;


    // ==========================================================================
    // ==                      DUT Params and Signals                           ==
    // ==========================================================================
            
    // Clocking and timing parameters. Here the values are arranged to allow 
    // having a "reasonable" simulation time.
    parameter C_CLK_VAR_FRQ = 10_000_000;   // Target clock frequency [Hz].
    parameter C_DBC_INTERVAL = 0.01;        // Debouncer lock interval [ms].
    parameter C_BLK_PERIOD = 1.0;           // Blinker period [ms].

    // Traffic lights intervals (in 'blinks' units).
    parameter C_INT_RED = 10;               // Red interval [blinks]
    parameter C_INT_GREEN = 10;             // Green interval [blinks]
    parameter C_INT_YELLOW = 2;             // Yellow interval [blinks]
    parameter C_INT_WALK = 5;               // Walk interval [blinks]

    // Colors of the lights:       R     G     B.
    parameter [11:0] C_COLORS = {1'b1, 1'b0, 1'b0,  // Red state.   
	                             1'b0, 1'b1, 1'b0,  // Green state.
	                             1'b1, 1'b1, 1'b0,  // Yellow state.
	                             1'b1, 1'b1, 1'b1}; // Walk state.
        
    // System timing signals.
    reg rSysRstb;
    reg rSysClk;
        
    // Data in.
    reg [3:0] rButton;
    reg [3:0] rSwitch;
    
    // Data out.
    wire [3:0]  wLed;
    wire [11:0] wLedRGB;
    


    // ==========================================================================
    // ==                                 DUTs                                 ==
    // ==========================================================================


    // Instantiate the 'top' DUT
    top #(
        .C_CLK_BRD_FRQ(C_CLK_FRQ),
        .C_CLK_VAR_FRQ(C_CLK_VAR_FRQ),
        
        .C_DBC_INTERVAL(C_DBC_INTERVAL),
        .C_BLK_PERIOD(C_BLK_PERIOD),
        .C_INT_RED(C_INT_RED),
        .C_INT_GREEN(C_INT_GREEN),
        .C_INT_YELLOW(C_INT_YELLOW),
        .C_INT_WALK(C_INT_WALK),
        .C_COLORS(C_COLORS)
        
    ) TOP (
        
        // Timing.
        .sysRstb(rSysRstb),
        .sysClk(rSysClk),
        
        // Inputs.
        .sw(rSwitch),
        .btn(rButton),
	    
        // Outputs.
        .led(wLed),
        .ledRGB(wLedRGB)
    );

    // Initialize Inputs
    initial begin
		$display ($time, " << Starting the Simulation >> ");
        rSysRstb <= 1'b0;
		rSysClk <= 1'b0;
		rSwitch <= 4'b0000;
		rButton <= 4'b0000;
        #2000 rSysRstb = 1'b1;
        
        // At half simulation, switch mode to 1.
        #50ms rSwitch[0] <= 1'b1;
        
    end

    // Main clock generation. This process generates a clock with period equal to 
    // C_CLK_PERIOD. It also add a pseudorandom jitter, normally distributed 
    // with mean 0 and standard deviation equal to 'kClockJitter'.  
    always begin
        #(0.001 * $dist_normal(seed, 1000.0 * C_CLK_PERIOD / 2, C_CLK_JTR));
        rSysClk = ! rSysClk;
    end  
        
    // Pedestrian button.
    always begin
        # (1ms * $dist_normal(seed, 10, 10));
        rButton[0] = 1'b1;
        # 20us; //(10us * $dist_normal(seed, 20, 10));
        rButton[0] = 1'b0;
    end  
        
   
endmodule
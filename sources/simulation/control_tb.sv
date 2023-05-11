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
module control_tb ();

    // ==========================================================================
    // ==                               Parameters                             ==
    // ==========================================================================
    
    // Timing properties.
    parameter C_CLK_FRQ         = 100000000;    // Main clock frequency [Hz].
    parameter C_CLK_JTR         = 50;           // Main clock jitter [ps].
    localparam real C_CLK_PERIOD = 1E9 / C_CLK_FRQ;  // Master clock period [ns].
        
    
    
    // ==========================================================================
    // ==                              Seeding                                 ==
    // ==========================================================================
    
    // Seeding for (repeatable) random number generation.
    static int seed = $urandom + 0;


    // ==========================================================================
    // ==                      DUT Params and Signals                           ==
    // ==========================================================================
            
    // Parameters.
    parameter C_PERIOD = 1;       // Light switching [ms].
    
    // Intervals
    parameter C_INT_RED = 15;
    parameter C_INT_GREEN = 20;
    parameter C_INT_YELLOW = 5;
    parameter C_INT_PEDESTRIAN = 10;
        
    // Timing signal.
    reg rRstb;
    reg rClk;
    reg rBlink;
    
    // Data in.
    reg rMode = 1'b0;
    reg rPedestrian = 1'b0;
    reg rTraffic = 1'b0;
    
    // Data out.
    wire [1:0] wLight;



    // ==========================================================================
    // ==                                 DUTs                                 ==
    // ==========================================================================

    // Instantiate the 'control' DUT
    control #(
    
        // Intervals.
        .C_INT_RED(C_INT_RED),
        .C_INT_GREEN(C_INT_GREEN),
        .C_INT_YELLO(C_INT_YELLOW),
        .C_INT_PEDESTRIAN(C_INT_PEDESTRIAN)
  
    ) DUT (
        
        // Timing.
        .rstb(rRstb),
        .clk(rClk),
        .blink(rBlink),
        
        // Inputs.
        .inMode(rMode),
        .inTraffic(rTraffic),
	    .inPedestrian(rPedestrian),
        
        // Outputs.
        .outLight(wLight)
    );

    // Initialize Inputs
    initial begin
		$display ($time, " << Starting the Simulation >> ");
        rRstb = 1'b0;
		rClk = 1'b0;
		rBlink = 1'b0;
        #200 rRstb = 1'b1;
    end

    // Main clock generation. This process generates a clock with period equal to 
    // C_CLK_PERIOD. It also add a pseudorandom jitter, normally distributed 
    // with mean 0 and standard deviation equal to 'kClockJitter'.  
    always begin
        #(0.001 * $dist_normal(seed, 1000.0 * C_CLK_PERIOD / 2, C_CLK_JTR));
        rClk = ! rClk;
    end  
    
    // Blink generator. Generates a 1ms beat for quick simulation. 
    always begin
        #0.0005s;
        rBlink = ! rBlink;
    end  
   
endmodule
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
    parameter C_INT_RED = 4;
    parameter C_INT_GREEN = 6;
    parameter C_INT_YELLOW = 2;
    parameter C_INT_WALK = 4;
        
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
        .C_INT_YELLOW(C_INT_YELLOW),
        .C_INT_WALK(C_INT_WALK)
  
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
		rMode = 1'b0;
		rBlink = 1'b0;
		rPedestrian = 1'b0;
        #200 rRstb = 1'b1;
        
        // At half simulation, switch mode to 1.
        #50ms rMode <= 1'b1;
        
    end

    // Main clock generation. This process generates a clock with period equal to 
    // C_CLK_PERIOD. It also add a pseudorandom jitter, normally distributed 
    // with mean 0 and standard deviation equal to 'kClockJitter'.  
    always begin
        #(0.001 * $dist_normal(seed, 1000.0 * C_CLK_PERIOD / 2, C_CLK_JTR));
        rClk = ! rClk;
    end  
    
    // Blink generator. Generates a 100us beat for quick simulation. 
    always begin
        # 50000;
        rBlink = ! rBlink;
    end
    
    // Pedestrian button.
    always begin
        # (100us * $dist_normal(seed, 50, 20));
        rPedestrian = 1'b1;
        # (10us * $dist_normal(seed, 20, 10));
        rPedestrian = 1'b0;
    end  
    
    
   
endmodule
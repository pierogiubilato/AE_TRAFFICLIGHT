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
module blinker_tb ();

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
    parameter C_PERIOD = 10;       // Period of the generated square wave [ms].
        
    // Timing signal.
    reg rRstb;
    reg rClk;
    
    // Data out.
    wire wOut1;
    wire wOut2;


    // ==========================================================================
    // ==                                 DUTs                                 ==
    // ==========================================================================

    // Instantiate the DUT #1
    blinker #(
        .C_CLK_FRQ(C_CLK_FRQ),
        .C_PERIOD(C_PERIOD)
    ) DUT1 (
        // Inputs.
        .rstb(rRstb),
        .clk(rClk),
        
        // Out.
        .out(wOut1)
    );

    // Instantiate the DUT #2
    blinker #(
        .C_CLK_FRQ(C_CLK_FRQ),
        .C_PERIOD(2)
    ) DUT2 (
        // Inputs.
        .rstb(rRstb),
        .clk(rClk),
        
        // Out.
        .out(wOut2)
    );

    // Initialize Inputs
    initial begin
		$display ($time, " << Starting the Simulation >> ");
        rRstb = 1'b0;
		rClk = 1'b0;
        #200 rRstb = 1'b1;
    end

    // Main clock generation. This process generates a clock with period equal to 
    // C_CLK_PERIOD. It also add a pseudorandom jitter, normally distributed 
    // with mean 0 and standard deviation equal to 'kClockJitter'.  
    always begin
        #(0.001 * $dist_normal(seed, 1000.0 * C_CLK_PERIOD / 2, C_CLK_JTR));
        rClk = ! rClk;
    end  
   
endmodule